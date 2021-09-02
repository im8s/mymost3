package com.sk.weichat.socket.msg;

import android.text.TextUtils;
import android.util.Log;

import com.alibaba.fastjson.JSONObject;
import com.sk.weichat.MyApplication;
import com.sk.weichat.bean.Friend;
import com.sk.weichat.bean.message.XmppMessage;
import com.sk.weichat.db.dao.ChatMessageDao;
import com.sk.weichat.db.dao.FriendDao;
import com.sk.weichat.socket.EMConnectionManager;
import com.sk.weichat.ui.base.CoreManager;
import com.sk.weichat.util.Base64;
import com.sk.weichat.util.DES;
import com.sk.weichat.util.secure.AES;
import com.sk.weichat.util.secure.DH;
import com.sk.weichat.util.secure.chat.SecureChatUtil;
import com.sk.weichat.xmpp.listener.ChatMessageListener;

public class ChatMessage extends AbstractMessage {
    private static final String TAG = "ChatMessage";
    private String fromUserId;
    private String toUserId;
    private String fromUserName;
    private String toUserName;
    private short type; // 消息类型;(如：0:text、1:image、2:voice、3:vedio、4:music、5:news)
    private String content;
    private boolean isEncrypt;  // 是否加密传输
    private int encryptType; // 消息加密类型(新)  为int 类型
    private String signature;
    private boolean isReadDel;  // 是否阅后即焚
    private String fileName;
    private long fileSize; //  文件大小 单位字节
    private long fileTime; // 文件播放时长  录音时长，视频时长
    private double location_x;// 1.当为地理位置时，有效 2.特殊：当为图片时，该值为图片的宽度
    private double location_y;// 1.当为地理位置时，有效 2.特殊：当为图片时，该值为图片的高度
    private long deleteTime;  // 消息到期时间(当前时间+消息保存天数=到期时间)
    private int messageState;
    private String objectId;
    private String other;
    private long timeSend;

    public ChatMessage() {
    }

    /**
     * 对消息content进行加密
     *
     * @param chatMessage
     * @param isGroup
     */
    private static void encryptContent(com.sk.weichat.bean.message.ChatMessage chatMessage, boolean isGroup) {
        String mLoginUserId = CoreManager.requireSelf(MyApplication.getContext()).getUserId();
        if (!isGroup) {// 单聊
            // 对消息content字段进行加密传输
            if (!TextUtils.isEmpty(chatMessage.getContent())
                    && !XmppMessage.filter(chatMessage)) {
                if (!mLoginUserId.equals(chatMessage.getToUserId())) {
                    Friend friend = FriendDao.getInstance().getFriend(mLoginUserId, chatMessage.getToUserId());
                    if (friend == null) {//  明文传输
                        chatMessage.setIsEncrypt(0);
                    } else {
                        if (friend.getEncryptType() == 1) {//  3des, compatible old version, generate key no change
                            String key = SecureChatUtil.getSymmetricKey(chatMessage.getTimeSend(), chatMessage.getPacketId());
                            try {
                                chatMessage.setContent(DES.encryptDES(chatMessage.getContent(), key));
                                chatMessage.setIsEncrypt(1);
                            } catch (Exception e) {
                                // 3des加密失败
                                Log.e(TAG, "3des加密失败");
                                chatMessage.setIsEncrypt(0);
                                e.printStackTrace();
                            }
                        } else if (friend.getEncryptType() == 2) { // aes
                            String key = SecureChatUtil.getSymmetricKey(chatMessage.getPacketId());
                            chatMessage.setContent(AES.encryptBase64(chatMessage.getContent(), Base64.decode(key)));
                            chatMessage.setIsEncrypt(2);
                        } else if (friend.getEncryptType() == 3) { // dh/aes
                            if (TextUtils.isEmpty(friend.getPublicKeyDH())) {
                                // 客户端在开启端到端加密时，需要判断好友是否有dh公钥，如没有是不允许开启的
                                // 以防万一，如果出现这种情况，将isEncrypt置为0
                                Log.e(TAG, "好友dh公钥为空");
                                chatMessage.setIsEncrypt(0);
                            } else {
                                try {
                                    String key = DH.getCommonSecretKeyBase64(SecureChatUtil.getDHPrivateKey(mLoginUserId), friend.getPublicKeyDH());
                                    String realKey = SecureChatUtil.getSingleSymmetricKey(chatMessage.getPacketId(), key);
                                    chatMessage.setContent(AES.encryptBase64(chatMessage.getContent(), Base64.decode(realKey)));
                                    chatMessage.setIsEncrypt(3);// attention:这个一定要放在设置签名前面，因为接收方验签时的isEncrypt为3
                                    chatMessage.setSignature(SecureChatUtil.getSignatureSingle(chatMessage.getFromUserId(), chatMessage.getToUserId(),
                                            chatMessage.getIsEncrypt(), chatMessage.getPacketId(), realKey,
                                            chatMessage.getContent()));// 对已成型的消息进行签名
                                    // 对数据库内该条消息也进行加密
                                    ChatMessageDao.getInstance().encrypt(mLoginUserId, chatMessage.getToUserId(),
                                            chatMessage.getPacketId(), chatMessage.getSignature());
                                } catch (Exception e) {
                                    // 获取对称密钥K失败
                                    Log.e(TAG, "获取对称密钥K失败");
                                    chatMessage.setIsEncrypt(0);
                                    e.printStackTrace();
                                }
                            }
                        }
                    }
                } else {
                    // 自己给其他端发消息
                }
            } else {
                chatMessage.setIsEncrypt(0);
            }
        } else {// 群聊
            // 对消息content字段进行加密传输
            if (!TextUtils.isEmpty(chatMessage.getContent())
                    && !XmppMessage.filter(chatMessage)) {
                Friend friend = FriendDao.getInstance().getFriend(mLoginUserId, chatMessage.getToUserId());
                if (friend == null) {
                    chatMessage.setIsEncrypt(0);
                } else {
                    if (friend.getEncryptType() == 1) {
                        String key = SecureChatUtil.getSymmetricKey(chatMessage.getTimeSend(), chatMessage.getPacketId());
                        try {
                            chatMessage.setContent(DES.encryptDES(chatMessage.getContent(), key));
                            chatMessage.setIsEncrypt(1);
                        } catch (Exception e) {
                            // 3des加密失败
                            Log.e(TAG, "3des加密失败");
                            chatMessage.setIsEncrypt(0);
                            e.printStackTrace();
                        }
                    } else if (friend.getEncryptType() == 2) {
                        String key = SecureChatUtil.getSymmetricKey(chatMessage.getPacketId());
                        chatMessage.setContent(AES.encryptBase64(chatMessage.getContent(), Base64.decode(key)));
                        chatMessage.setIsEncrypt(2);
                    }

                    // 私密群组使用第三种加密方式
                    if (friend.getIsSecretGroup() == 1) {
                        String key = SecureChatUtil.decryptChatKey(chatMessage.getToUserId(), friend.getChatKeyGroup());
                        String realKey = SecureChatUtil.getSingleSymmetricKey(chatMessage.getPacketId(), key);
                        chatMessage.setContent(AES.encryptBase64(chatMessage.getContent(), Base64.decode(realKey)));
                        chatMessage.setIsEncrypt(3);
                        chatMessage.setSignature(SecureChatUtil.getSignatureMulti(chatMessage.getFromUserId(), chatMessage.getToUserId(),
                                chatMessage.getIsEncrypt(), chatMessage.getPacketId(), realKey,
                                chatMessage.getContent()));// 对已成型的消息进行签名
                        // 对数据库内该条消息也进行加密
                        ChatMessageDao.getInstance().encrypt(mLoginUserId, chatMessage.getToUserId(),
                                chatMessage.getPacketId(), chatMessage.getSignature());
                    }
                }
            }
        }
    }

    /**
     * 将业务逻辑使用的ChatMessage转换为传输的ChatMessage
     *
     * @param message
     * @return
     */
    public static ChatMessage toSocketMessage(com.sk.weichat.bean.message.ChatMessage message, boolean isNewFriendMsg) {
        com.sk.weichat.bean.message.ChatMessage chatMessage = message.clone(message.isGroup());
        chatMessage.setGroup(message.isGroup());

        if (!isNewFriendMsg) {// 非新朋友消息，需对消息进行加密
            encryptContent(chatMessage, message.isGroup());
        }

        ChatMessage chat = new ChatMessage();
        chat.setFromUserId(chatMessage.getFromUserId());
        chat.setToUserId(chatMessage.getToUserId());
        chat.setFromUserName(chatMessage.getFromUserName());
        chat.setToUserName(chatMessage.getToUserName());
        chat.setType((short) chatMessage.getType());
        chat.setContent(chatMessage.getContent());
        // todo 注：现新增两种加密方式，但传输层对isEncrypt的字段定义为了boolean类型，android本地又定义为了int类型(在传输的时候进行了转换)，
        //  所以传输层新增encryptType字段(int类型)，代表加密类型。
        //  所以在传输层还需要对encryptType进行赋值
        //  同时，为了兼容给老版本发消息，isEncrypt字段还需要继续进行赋值
        chat.setEncrypt(chatMessage.getIsEncrypt() == 1);
        chat.setEncryptType(chatMessage.getIsEncrypt());
        chat.setReadDel(chatMessage.getIsReadDel());
        chat.setFileName(chatMessage.getFilePath());
        chat.setFileSize(chatMessage.getFileSize());
        chat.setFileTime(chatMessage.getTimeLen());
        if (!TextUtils.isEmpty(chatMessage.getLocation_x())) {
            double x = Double.parseDouble(chatMessage.getLocation_x());
            chat.setLocation_x(x);
        }
        if (!TextUtils.isEmpty(chatMessage.getLocation_y())) {
            double y = Double.parseDouble(chatMessage.getLocation_y());
            chat.setLocation_y(y);
        }
        chat.setDeleteTime(chatMessage.getDeleteTime());
        chat.setObjectId(chatMessage.getObjectId());
        chat.setSignature(chatMessage.getSignature());
        chat.setTimeSend(chatMessage.getTimeSend());

        MessageHead head = new MessageHead();
        head.setChatType((byte) (chatMessage.isGroup() ? 2 : 1)); // 标记是否单聊
        head.setFrom(chatMessage.getFromUserId() + "/" + EMConnectionManager.CURRENT_DEVICE);
        if (chat.getFromUserId().equals(chat.getToUserId())) {
            head.setTo(chatMessage.getToUserId() + "/" + chat.getToUserName());
        } else {
            head.setTo(chatMessage.getToUserId());
        }
        head.setMessageId(chatMessage.getPacketId());
        chat.setMessageHead(head);

        return chat;
    }

    public String getFromUserId() {
        return fromUserId;
    }

    public void setFromUserId(String fromUserId) {
        this.fromUserId = fromUserId;
    }

    public String getToUserId() {
        return toUserId;
    }

    public void setToUserId(String toUserId) {
        this.toUserId = toUserId;
    }

    public String getFromUserName() {
        return fromUserName;
    }

    public void setFromUserName(String fromUserName) {
        this.fromUserName = fromUserName;
    }

    public String getToUserName() {
        return toUserName;
    }

    public void setToUserName(String toUserName) {
        this.toUserName = toUserName;
    }

    public short getType() {
        return type;
    }

    public void setType(short type) {
        this.type = type;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public boolean isEncrypt() {
        return isEncrypt;
    }

    public void setEncrypt(boolean encrypt) {
        isEncrypt = encrypt;
    }

    public int getEncryptType() {
        return encryptType;
    }

    public void setEncryptType(int encryptType) {
        this.encryptType = encryptType;
    }

    public String getSignature() {
        return signature;
    }

    public void setSignature(String signature) {
        this.signature = signature;
    }

    public boolean isReadDel() {
        return isReadDel;
    }

    public void setReadDel(boolean readDel) {
        isReadDel = readDel;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public long getFileSize() {
        return fileSize;
    }

    public void setFileSize(long fileSize) {
        this.fileSize = fileSize;
    }

    public long getFileTime() {
        return fileTime;
    }

    public void setFileTime(long fileTime) {
        this.fileTime = fileTime;
    }

    public double getLocation_x() {
        return location_x;
    }

    public void setLocation_x(double location_x) {
        this.location_x = location_x;
    }

    public double getLocation_y() {
        return location_y;
    }

    public void setLocation_y(double location_y) {
        this.location_y = location_y;
    }

    public long getDeleteTime() {
        return deleteTime;
    }

    public void setDeleteTime(long deleteTime) {
        this.deleteTime = deleteTime;
    }

    public int getMessageState() {
        return messageState;
    }

    public void setMessageState(int messageState) {
        this.messageState = messageState;
    }

    public String getObjectId() {
        return objectId;
    }

    public void setObjectId(String objectId) {
        this.objectId = objectId;
    }

    public String getOther() {
        return other;
    }

    public void setOther(String other) {
        this.other = other;
    }

    public long getTimeSend() {
        return timeSend;
    }

    public void setTimeSend(long timeSend) {
        this.timeSend = timeSend;
    }

    public String getMessageId() {
        return messageHead.getMessageId();
    }

    @Override
    public String toString() {
        JSONObject object = new JSONObject();
        object.put("fromUserId", this.fromUserId);
        object.put("toUserId", this.toUserId);
        object.put("toUserName", this.toUserName);
        object.put("fromUserName", this.fromUserName);
        object.put("type", this.type);
        object.put("content", this.content);
        object.put("isEncrypt", this.isEncrypt);
        object.put("encryptType", this.encryptType);
        object.put("signature", this.signature);
        object.put("isReadDel", this.isReadDel);
        object.put("fileName", this.fileName);
        object.put("fileSize", this.fileSize);
        object.put("fileTime", this.fileTime);
        object.put("location_x", this.location_x);
        object.put("location_y", this.location_y);
        object.put("deleteTime", this.deleteTime);
        object.put("objectId", this.objectId);
        object.put("timeSend", this.timeSend);
        object.put("other", this.other);
        object.put("messageHead", this.messageHead);
        String msg = object.toString();
        return msg;
    }

    /**
     * 将传输过程中的ChatMessage转换为业务逻辑使用的ChatMessage
     *
     * @param loginId
     * @return
     */
    public com.sk.weichat.bean.message.ChatMessage toSkMessage(String loginId) {
        com.sk.weichat.bean.message.ChatMessage chat = new com.sk.weichat.bean.message.ChatMessage();

        chat.setFromUserId(this.fromUserId);
        chat.setToUserId(this.toUserId);
        chat.setFromUserName(this.fromUserName);
        chat.setToUserName(this.toUserName);
        chat.setType(this.type);
        chat.setContent(this.content);
        // todo 注：现新增两种加密方式，但传输层对isEncrypt的字段定义为了boolean类型，android本地又定义为了int类型(在传输的时候进行了转换)，
        //  所以传输层新增encryptType字段(int类型)，代表加密类型。
        //  因为android端的isEncrypt原本就是int类型并且在业务逻辑内使用了，所以传输层收到的encryptType本地全部转为isEncrypt使用
        //  同时，为了兼容老版本发过来的加密消息，如果encryptType==0并且isEncrypt==true，将encryptType赋值为1
        if (this.encryptType == 0 && this.isEncrypt) {
            chat.setIsEncrypt(1);
        } else {
            chat.setIsEncrypt(this.encryptType);
        }
        chat.setIsReadDel(this.isReadDel ? 1 : 0);
        chat.setSignature(this.signature);
        chat.setFilePath(this.fileName);
        chat.setFileSize((int) this.fileSize);
        chat.setTimeLen((int) this.fileTime);
        chat.setLocation_x(String.valueOf(this.location_x));
        chat.setLocation_y(String.valueOf(this.location_y));
        chat.setDeleteTime(this.deleteTime);
        chat.setObjectId(this.objectId);
        chat.setOther(this.other);
        chat.setTimeSend(this.timeSend);

        chat.setPacketId(this.messageHead.getMessageId());
        chat.setGroup(this.messageHead.chatType == 2);
        chat.setDelayMsg(messageHead.offline);

        chat.setMessageState(ChatMessageListener.MESSAGE_SEND_SUCCESS); // 收到的消息默认成功

        String from = this.messageHead.getFrom();
        String to = this.messageHead.getTo();
        from = from.replaceAll(this.fromUserId + "/", "");
        to = to.replaceAll(this.toUserId + "/", "");
        chat.setFromId(from);
        chat.setToId(to);

        if (fromUserId.equals(toUserId)) {
            chat.setMySend(EMConnectionManager.CURRENT_DEVICE.equals(from));
        } else {
            chat.setMySend(loginId.equals(this.fromUserId));
        }
        return chat;
    }
}
