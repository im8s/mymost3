package com.sk.weichat.socket;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.google.protobuf.Descriptors;
import com.sk.weichat.MyApplication;
import com.sk.weichat.R;
import com.sk.weichat.bean.Friend;
import com.sk.weichat.bean.MsgRoamTask;
import com.sk.weichat.bean.event.EventLoginStatus;
import com.sk.weichat.bean.message.XmppMessage;
import com.sk.weichat.db.dao.FriendDao;
import com.sk.weichat.db.dao.MsgRoamTaskDao;
import com.sk.weichat.db.dao.login.MachineDao;
import com.sk.weichat.socket.msg.AbstractMessage;
import com.sk.weichat.socket.msg.AuthMessage;
import com.sk.weichat.socket.msg.AuthRespMessage;
import com.sk.weichat.socket.msg.ChatMessage;
import com.sk.weichat.socket.msg.ErrorMessage;
import com.sk.weichat.socket.msg.ExitGroupMessage;
import com.sk.weichat.socket.msg.JoinGroupMessage;
import com.sk.weichat.socket.msg.MessageHead;
import com.sk.weichat.socket.msg.MessageReceiptStatus;
import com.sk.weichat.socket.msg.PingMessage;
import com.sk.weichat.socket.msg.PullBatchGroupMessage;
import com.sk.weichat.socket.msg.PullBatchGroupRespMessage;
import com.sk.weichat.socket.msg.SuccessMessage;
import com.sk.weichat.socket.protocol.Command;
import com.sk.weichat.socket.protocol.MessageProBuf;
import com.sk.weichat.socket.protocol.ProBufUtils;
import com.sk.weichat.socket.protocol.TcpPacket;
import com.sk.weichat.socket.protocol.TcpServerDecoder;
import com.sk.weichat.socket.protocol.TcpServerEncoder;
import com.sk.weichat.ui.base.CoreManager;
import com.sk.weichat.util.DeviceInfoUtil;
import com.sk.weichat.util.ThreadManager;
import com.sk.weichat.util.ToastUtil;
import com.sk.weichat.util.log.LogUtils;
import com.sk.weichat.view.cjt2325.cameralibrary.util.LogUtil;
import com.sk.weichat.xmpp.NotifyConnectionListener;
import com.sk.weichat.xmpp.ReceiptManager;
import com.sk.weichat.xmpp.SendReceiptManager;
import com.sk.weichat.xmpp.SocketPingManager;
import com.sk.weichat.xmpp.XChatMessageListener;
import com.sk.weichat.xmpp.XMuChatMessageListener;
import com.sk.weichat.xmpp.listener.AuthStateListener;
import com.sk.weichat.xmpp.listener.ChatReceiptListener;

import java.io.BufferedOutputStream;
import java.io.Closeable;
import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import de.greenrobot.event.EventBus;

/**
 * XMPP连接类
 */
public class EMConnectionManager {
    public static final int SOCKET_PORT = 6666;
    // 关闭多点登录时发消息用的设备名是"youjob",
    public static String CURRENT_DEVICE = "android";
    public String SOCKET_HOST = "192.168.0.168";
    Handler mMainHandler = new Handler(Looper.getMainLooper());// 用于线程中切换到主线程，进行ui操作
    // 当前登录用户的用户名与密码
    private String mCurrentLoginUserToken;
    private String mCurrentLoginUserId;
    private SocketThread mSocketThread;
    private NotifyConnectionListener mConnectListener;
    private ChatReceiptListener mChatReceiptListener;
    private XChatMessageListener mChatMessageListener;
    private XMuChatMessageListener mGroupMessageListener;
    private List<ChatMessage> mOffChatMessage;
    private List<ChatMessage> mOffGroupMessage;
    private SendReceiptManager mSendReceiptManager;

    public EMConnectionManager(Context context) {
        SOCKET_HOST = CoreManager.requireConfig(context).XMPPHost;

        mCurrentLoginUserToken = CoreManager.requireSelfStatus(MyApplication.getContext()).accessToken;
        mCurrentLoginUserId = CoreManager.requireSelf(MyApplication.getContext()).getUserId();
        mOffChatMessage = new ArrayList<>();
        mOffGroupMessage = new ArrayList<>();
        Log.e("xuan", " new EMConnectionManager: " + mCurrentLoginUserToken + " ,  socket ip: " + SOCKET_HOST);
        mSocketThread = new SocketThread(this, SOCKET_HOST, SOCKET_PORT);
        mSocketThread.start();

        mSendReceiptManager = new SendReceiptManager(this);
    }

    public void login(final String token, String userId) {
        if (mSocketThread == null) {
            Log.e("zq", "SocketThread对象空了，创建一个SocketThread对象");
            mSocketThread = new SocketThread(this, SOCKET_HOST, SOCKET_PORT);
            mSocketThread.start();
        } else {
            Log.e("zq", "login: " + token + " ,  " + userId + " ,  " + getCurrentState());
            mSocketThread.login(token, userId);
        }
    }

    /**
     * 返回当前登陆账号
     *
     * @return
     */
    public String getLoginUserID() {
        return mCurrentLoginUserId;
    }

    public int getCurrentState() {
        if (mSocketThread == null) {
            return AuthStateListener.AUTH_STATE_INIT;
        }
        return mSocketThread.mSocketConnectState;
    }

    public boolean isConnected() {
        if (getCurrentState() > AuthStateListener.AUTH_STATE_INIT) {
            return true;
        }
        return false;
    }

    public boolean isAuthenticated() {
        Log.i("socket conn state", "isAuthenticated: " + getCurrentState());
        return getCurrentState() == AuthStateListener.AUTH_STATE_SUCCESS;
    }

    public void disconnect() {
        if (mSocketThread != null) {
            mSocketThread.disconnect();
            mSocketThread = null;
            Log.e("zq", "Socket disconnect success");
        } else {
            Log.e("zq", "SocketThread = null");
        }
    }

    public void sendMessage(ChatMessage chatMessage) {
        mSocketThread.send(chatMessage);
    }

    public void sendPingMessage() {
        mSocketThread.ping();
    }

    // 批量回执
    private void addReceipt(MessageHead messageHead) {
        mSendReceiptManager.addReceipt(messageHead);
    }

    public void sendReceipt(List<MessageHead> messageHeadList) {
        mSocketThread.sendReceipt(messageHeadList);
    }

    // 批量加入群组，拉取群离线消息
    public void batchJoinRoom(PullBatchGroupMessage message) {
        if (mSocketThread != null) {
            mSocketThread.batchJoinRoom(message);
        }
    }

    public void joinRoom(JoinGroupMessage message) {
        if (mSocketThread != null) {
            mSocketThread.joinRoom(message);
        }
    }

    public void exitRoom(ExitGroupMessage message) {
        mSocketThread.exitRoom(message);
    }

    /**
     * 连接监听
     *
     * @param connectionListener
     */
    public void addConnectionListener(NotifyConnectionListener connectionListener) {
        this.mConnectListener = connectionListener;
    }

    public void removeConnectionListener() {
        this.mConnectListener = null;
    }

    /**
     * 消息回执监听
     *
     * @param chatReceiptListener
     */
    public void addReceiptReceivedListener(ChatReceiptListener chatReceiptListener) {
        this.mChatReceiptListener = chatReceiptListener;
    }

    /**
     * 单聊消息监听
     *
     * @param messageListener
     */
    public void addIncomingListener(XChatMessageListener messageListener) {
        if (messageListener == null) {
            return;
        }

        this.mChatMessageListener = messageListener;
        if (mOffChatMessage != null && mOffChatMessage.size() > 0) {
            for (int i = mOffChatMessage.size() - 1; i >= 0; i--) {
                mChatMessageListener.onReceMessage(mOffChatMessage.get(i).toSkMessage(mCurrentLoginUserId));
                mOffChatMessage.remove(i);
            }
        }
    }

    /**
     * 群聊消息监听
     *
     * @param groupMessageListener
     */
    public void addMuChatMessageListener(XMuChatMessageListener groupMessageListener) {
        if (groupMessageListener == null) {
            return;
        }
        this.mGroupMessageListener = groupMessageListener;
    }

    /**
     * 核心
     */
    private class SocketThread extends Thread {
        private static final int MAX_SIZE = 2048; // max size 256
        private static final String TAG = "xuan";
        private String mIp;
        private int mPort;

        private Socket socket;
        private InputStream inputStream;
        private OutputStream outputStream;

        private boolean mLoginIng;
        private int mSocketConnectState = AuthStateListener.AUTH_STATE_INIT;
        // 输入缓冲区，
        private ByteBuffer dataBuffer = ByteBuffer.allocate(MAX_SIZE);

        private int pingFailedCount = 0;
        private EMConnectionManager mConnectionManager;
        // 用户退出登录等主动退出的情况，
        private boolean disconnected = false;

        public SocketThread(EMConnectionManager connectionManager, String ip, int port) {
            this.mIp = ip;
            this.mPort = port;
            this.mConnectionManager = connectionManager;
            // 准备连接
            notifyConnect(1, AuthStateListener.AUTH_STATE_ING);
        }

        private void notifyConnect(int which, int authState) {
            Log.e("zq", "which：" + which);
            mSocketConnectState = authState;
            if (authState == AuthStateListener.AUTH_STATE_ING) {
                if (mConnectListener != null) {
                    mConnectListener.notifyConnecting();
                }
            } else if (authState == AuthStateListener.AUTH_STATE_SUCCESS) {
                if (mConnectListener != null) {
                    mConnectListener.notifyAuthenticated();
                }
            }
        }

        private void notifyClose() {
            mLoginIng = false;
            mSocketConnectState = AuthStateListener.AUTH_STATE_CLOSE;
            if (mConnectListener != null) {
                mConnectListener.notifyConnectionClosed();
            }
        }

        private void notifyError(String exception) {
            mLoginIng = false;
            mSocketConnectState = AuthStateListener.AUTH_STATE_ERROR;
            if (mConnectListener != null) {
                mConnectListener.notifyConnectionClosedOnError(exception);
            } else {
                LogUtil.e("zq", "notifyError-->mConnectListener空了");
            }
        }

        @Override
        public void run() {
            initSocket();
            try {
                startRead();
            } catch (IOException e) {
                LogUtils.e(TAG, "decodeSocket: read抛异常", e);
                closeAll();
                notifyError(SocketException.SELECTION_KEY_INVALID);
            }
        }

        private void initSocket() {
            try {
                // socket重新连接次数，
                int tryTimes = 3;
                // 重连间隔时间，避免连不上服务器时无限触发外部的重连机制，
                long durationTime = TimeUnit.SECONDS.toMillis(1);
                long startTime = System.currentTimeMillis();
                while (tryTimes-- > 0) {
                    try {
                        // 构造同时连接，
                        socket = new Socket(mIp, mPort);
                        break;
                    } catch (IOException e) {
                        // 连接失败，休息后重新连接，
                        // 计算休息时间，确保尝试连接一次的时间不小于durationTime,
                        // 避免无意义的重连，因为当服务器没有启动时socket连接会立即抛出异常，
                        LogUtils.d(TAG, "连接失败，剩余连接次数 " + tryTimes, e);
                        long sleepTime = startTime + durationTime - System.currentTimeMillis();
                        if (sleepTime > 0) {
                            try {
                                sleep(sleepTime);
                            } catch (InterruptedException e1) {
                                throw new IOException("连接中断", e1);
                            }
                        }
                        startTime = System.currentTimeMillis();
                    }
                }
                if (socket == null) {
                    throw new IOException("连接失败, host=" + mIp + ", port=" + mPort);
                }
                // 输出不需要缓冲，因为有自己维护缓冲区，
                inputStream = socket.getInputStream();
                // 输出需要缓冲，否则会一个一个字节发送，
                outputStream = new BufferedOutputStream(socket.getOutputStream());
                // 已连接
                notifyConnect(2, AuthStateListener.AUTH_STATE_ING);
                Log.e(TAG, "已连接服务器: " + mIp);
                login(mCurrentLoginUserToken, mCurrentLoginUserId);
            } catch (IOException e) {
                LogUtils.e(TAG, "initSocket  : 连接服务器失败", e);
                notifyError(SocketException.FINISH_CONNECT_EXCEPTION);
            }
        }

        private void startRead() throws IOException {
            while (isConnected()) {
                decodeSocket();
            }
        }

        public void disconnect() {
            disconnected = true;
            mSocketThread.mLoginIng = false;
            closeAll();
            mSocketThread.interrupt();
        }

        private void closeAll() {
            if (inputStream != null) {
                finallyClose(inputStream);
            }
            if (outputStream != null) {
                finallyClose(outputStream);
            }
            if (socket != null) {
                finallyClose(socket);
            }
        }

        private void finallyClose(Closeable closeable) {
            try {
                closeable.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        /********************************************************************************
         *   Todo 发送各种类型消息，与服务器进行交互
         ********************************************************************************/
        private boolean isConnected() {
            return socket != null && socket.isConnected() && !disconnected;
        }

        private boolean inSocket(AbstractMessage message, Descriptors.Descriptor descriptor, short comm) {
            boolean success = false;
            byte[] bytes = ProBufUtils.encodeMessageBody(message, descriptor);
            TcpPacket packet = new TcpPacket(comm, bytes);
            ByteBuffer dataBuffer = TcpServerEncoder.encode(packet);
            dataBuffer.flip();
            // 输出到通道
            try {
                if (isConnected() || outputStream != null) {
                    // 强行保留旧代码的ByteBuffer,
                    outputStream.write(dataBuffer.array(), dataBuffer.position(), dataBuffer.remaining());
                    outputStream.flush();
                    dataBuffer.position(dataBuffer.limit());
                } else {
                    return false;
                }
                success = true;
            } catch (IOException e) {
                LogUtils.e(TAG, "initSocket  : 发送数据失败", e);
                notifyError(SocketException.SELECTION_KEY_INVALID);
                closeAll();
            }
            return success;
        }

        public synchronized void login(final String token, String userId) {
            if (mLoginIng) {
                Log.e("zq", "login：当前正在登录，不允许重复登录");
                return;
            }
            mLoginIng = true;
            ThreadManager.getPool().execute(() -> {
                AuthMessage auth = new AuthMessage();
                auth.setToken(token);
                auth.setPassword("");
                auth.setDeviceId(DeviceInfoUtil.getDeviceId(MyApplication.getContext()));
                MessageHead head = new MessageHead();
                head.setChatType((byte) 1);
                head.setFrom(userId + "/" + EMConnectionManager.CURRENT_DEVICE);
                head.setTo("service");
                head.setMessageId(UUID.randomUUID().toString().replaceAll("-", ""));
                auth.setMessageHead(head);

                Descriptors.Descriptor descriptor = MessageProBuf.AuthMessage.getDescriptor();
                notifyConnect(3, AuthStateListener.AUTH_STATE_ING);
                if (!inSocket(auth, descriptor, Command.COMMAND_AUTH_REQ)) {
                    notifyError(SocketException.LOGIN_MESSAGE_SEND_FAILED_EXCEPTION);
                }
            });
        }

        /**
         * @param message
         */
        private void send(final ChatMessage message) {
            ThreadManager.getPool().execute(new Runnable() {
                @Override
                public void run() {
                    String str = message.messageHead.getChatType() == 2 ? "群聊" : "单聊";
                    if (inSocket(message, MessageProBuf.ChatMessage.getDescriptor(), Command.COMMAND_CHAT_REQ)) {
                        Log.e(TAG, "发送" + str + "聊天消息 成功: " + message.toString());
                    } else {
                        Log.e(TAG, "发送" + str + "聊天消息 失败: " + message.toString());
                        mChatReceiptListener.onReceiveReceipt(ReceiptManager.RECEIPT_ERR, message.getMessageId());
                    }
                }
            });
        }

        private void ping() {
            ThreadManager.getPool().execute(new Runnable() {
                @Override
                public void run() {
                    String messageId = UUID.randomUUID().toString().replace("-", "");
                    PingMessage ping = new PingMessage();
                    MessageHead head = new MessageHead();
                    head.setChatType((byte) 1);
                    head.setFrom(mCurrentLoginUserId + "/" + CURRENT_DEVICE);
                    head.setTo("service");
                    head.setMessageId(messageId);
                    ping.setMessageHead(head);

                    Descriptors.Descriptor descriptor = MessageProBuf.PingMessageProBuf.getDescriptor();
                    if (inSocket(ping, descriptor, Command.COMMAND_PING_REQ)) {
                        pingFailedCount = 0;
                        Log.e("ping", "发送Ping消息给服务器 成功");
                    } else {
                        pingFailedCount++;
                        Log.e("ping", "发送Ping消息给服务器 失败--->pingFailedCount==" + pingFailedCount);
                        if (pingFailedCount == 2) {
                            Log.e("ping", "Ping失败两次，本地连接置为离线");
                            notifyError(SocketException.SOCKET_PING_FAILED);
                        }
                    }
                }
            });
        }

        /**
         * @param messageHead
         */
        private void addReceipt(MessageHead messageHead) {
            mConnectionManager.addReceipt(messageHead);
        }

        /**
         * @param messageHeadList
         */
        private void sendReceipt(List<MessageHead> messageHeadList) {
            ThreadManager.getPool().execute(new Runnable() {
                @Override
                public void run() {
                    StringBuilder messageId = new StringBuilder();
                    for (int i = 0; i < messageHeadList.size(); i++) {
                        messageId.append(messageHeadList.get(i).getMessageId()).append(",");
                    }
                    MessageReceiptStatus messageReceiptStatus = new MessageReceiptStatus();
                    messageReceiptStatus.setMessageId(messageId.toString());
                    messageReceiptStatus.setStatus((byte) 2);

                    MessageHead head = new MessageHead();
                    head.setChatType(messageHeadList.get(0).getChatType());
                    head.setFrom(mCurrentLoginUserId + "/" + EMConnectionManager.CURRENT_DEVICE);
                    head.setTo(messageHeadList.get(0).getTo());
                    head.setMessageId(UUID.randomUUID().toString().replaceAll("-", ""));
                    messageReceiptStatus.setMessageHead(head);

                    Descriptors.Descriptor descriptor = MessageProBuf.MessageReceiptStatusProBuf.getDescriptor();
                    if (inSocket(messageReceiptStatus, descriptor, Command.COMMAND_MESSAGE_RECEIPT_REQ)) {
                        Log.e(TAG, "发送回执消息给服务器 成功" + messageReceiptStatus.toString());
                    } else {
                        Log.e(TAG, "发送回执消息给服务器 失败" + messageReceiptStatus.toString());
                    }
                }
            });
        }

        private void batchJoinRoom(final PullBatchGroupMessage message) {
            ThreadManager.getPool().execute(new Runnable() {
                @Override
                public void run() {
                    Descriptors.Descriptor descriptor = MessageProBuf.PullBatchGroupMessageReqProBuf.getDescriptor();
                    if (inSocket(message, descriptor, Command.COMMAND_BATCH_JOIN_GROUP_REQ)) {
                        Log.e("batchJoinRoom", "发送消息 批量获取群组离线消息 成功: messageId :" + message.getMessageHead().getMessageId() + "  jidList:" + message.getJidList().toString());
                    } else {
                        Log.e("batchJoinRoom", "发送消息 批量获取群组离线消息 失败: messageId :" + message.getMessageHead().getMessageId() + "  jidList:" + message.getJidList().toString());
                    }
                }
            });
        }

        private void joinRoom(final JoinGroupMessage message) {
            ThreadManager.getPool().execute(new Runnable() {
                @Override
                public void run() {
                    Descriptors.Descriptor descriptor = MessageProBuf.JoinGroupMessageProBuf.getDescriptor();
                    if (inSocket(message, descriptor, Command.COMMAND_JOIN_GROUP_REQ)) {
                        Log.e(TAG, "发送消息 加入房间 成功: messageId :" + message.getMessageHead().getMessageId());
                    } else {
                        Log.e(TAG, "发送消息 加入房间 失败: messageId :" + message.getMessageHead().getMessageId());
                        mChatReceiptListener.onReceiveReceipt(ReceiptManager.RECEIPT_ERR, message.getMessageHead().getMessageId());
                    }
                }
            });
        }

        private void exitRoom(final ExitGroupMessage message) {
            ThreadManager.getPool().execute(new Runnable() {
                @Override
                public void run() {
                    Descriptors.Descriptor descriptor = MessageProBuf.ExitGroupMessageProBuf.getDescriptor();
                    if (inSocket(message, descriptor, Command.COMMAND_EXIT_GROUP_REQ)) {
                        Log.e(TAG, "发送消息 退出房间 成功: messageId : " + message.getMessageHead().getMessageId());
                    } else {
                        Log.e(TAG, "发送消息 退出房间 失败: messageId : " + message.getMessageHead().getMessageId());
                        mChatReceiptListener.onReceiveReceipt(ReceiptManager.RECEIPT_ERR, message.getMessageHead().getMessageId());
                    }
                }
            });
        }

        /********************************************************************************
         *  Todo 收到各种类型消息，解析分发
         ********************************************************************************/
        private void decodeSocket() throws IOException {
            // 复用dataBuffer, 以便接上一个tcp剩下的数据一起处理，
            if (dataBuffer.remaining() == 0) {
                realloc();
            }
            // 强行保留旧代码的ByteBuffer,
            int count = inputStream.read(dataBuffer.array(), dataBuffer.position(), dataBuffer.remaining());

            if (count == -1) {
                // 读到EOF, 基本上表示服务器关闭了输出流，
                // 抛出去结束连接，
                throw new EOFException();
            } else if (count > 0) {
                dataBuffer.position(dataBuffer.position() + count);
                // 重新遍历缓冲区，排除剩下没读取的0，
                // flip后limit就会是已经读取了的字节数，而不是缓冲区总长度，
                dataBuffer.flip();
                // 标记是否有剩下数据，
                boolean left = false;
                while (dataBuffer.hasRemaining()) {
                    if (dataBuffer.get(dataBuffer.position()) == 0) {
                        // 保留旧代码，协议为0时跳出循环，实际上应该不会出现，
                        LogUtils.e(TAG, "异常数据报，协议版本为0，直接清了这个缓冲区，length = " + dataBuffer.remaining());
                        // 恢复指针和limit,
                        dataBuffer.clear();
                        break;
                    }
                    TcpPacket packet = TcpServerDecoder.decode(dataBuffer);
                    if (packet == null) {
                        // dataBuffer可能还有剩，比如一个tcp包放不下，最后一个业务包有部分在下一个tcp包，
                        // 此时当前tcp包的最后一个业务包是残缺的，不能处理，要留在缓冲区里，
                        // 这里重置dataBuffer, 剩下的数据放在开头等下个包来接上再处理，
                        // 可以断点等待阻塞输入流模拟分包情况，
                        LogUtils.e(TAG, "decodeSocket: 业务包不完全读取，整理缓冲区等下个socket包，\n" +
                                "capacity=" + dataBuffer.capacity() + "\n" +
                                "limit=" + dataBuffer.limit() + "\n" +
                                "position=" + dataBuffer.position() + "\n" +
                                "");
                        int leftLength = dataBuffer.remaining();
                        byte[] tmp = new byte[leftLength];
                        dataBuffer.get(tmp);
                        // 恢复指针和limit,
                        dataBuffer.clear();
                        dataBuffer.put(tmp);
                        left = true;
                        break;
                    }
                    decodePacket(packet);
                }
                // 如果没有数据剩下，直接清空缓冲区，
                if (!left) {
                    // 恢复指针和limit,
                    dataBuffer.clear();
                }
            } else {
                LogUtils.e(TAG, "decodeSocket: 读取到0个字节，\n" +
                        "capacity=" + dataBuffer.capacity() + "\n" +
                        "limit=" + dataBuffer.limit() + "\n" +
                        "position=" + dataBuffer.position() + "\n" +
                        "");
            }
        }

        private void realloc() {
            // 考虑一个业务包就大于整个输入缓冲区的情况，会导致输入缓冲区永远被充满，
            // 这种情况需要扩容输入缓冲区，分配两倍空间，保留旧数据，继续读取后续部分，
            LogUtils.e(TAG, "decodeSocket: 缓冲区满，增加空间，\n" +
                    "capacity=" + dataBuffer.capacity() + "\n" +
                    "limit=" + dataBuffer.limit() + "\n" +
                    "position=" + dataBuffer.position() + "\n" +
                    "");
            dataBuffer.rewind();
            ByteBuffer newBuffer = ByteBuffer.allocate(dataBuffer.capacity() * 2);
            newBuffer.put(dataBuffer);
            dataBuffer = newBuffer;
        }

        private void decodePacket(TcpPacket packet) {
            if (packet == null) {
                Log.e(TAG, "decode: TCP解码失败");
                return;
            }
            Log.e(TAG, "decode: TCP解码成功" + packet.getCommand());
            /**
             * 登录结果返回 || 登录冲突
             */
            if (packet.getCommand() == Command.COMMAND_AUTH_RESP || packet.getCommand() == Command.COMMAND_LOGIN_CONFLICT_RESP) {
                if (packet.getCommand() == Command.COMMAND_AUTH_RESP) {
                    mLoginIng = false;
                    AuthRespMessage auth = ProBufUtils.decoderMessageBody(packet.getBytes(), MessageProBuf.AuthRespMessageProBuf.getDescriptor(), AuthRespMessage.class);
                    if (auth.getStatus() == 1) { // 1 登陆 成功  0 登陆失败
                        if (mSocketConnectState == AuthStateListener.AUTH_STATE_SUCCESS) { // 这个是有其他设备登录进来了
                            Log.e(TAG, "收到其他设备登录的信息: 当前在线设备: " + auth.getResources());
                        } else {
                            Log.e(TAG, "登录成功:" + mCurrentLoginUserId + "在线设备:" + auth.getResources());
                            notifyConnect(4, AuthStateListener.AUTH_STATE_SUCCESS);
                            Log.e("zq", "成功---HashCode：" + socket.hashCode());

                            // 开始Ping 服务器
                            SocketPingManager.getInstance().registerPing(mConnectionManager);
                        }
                    }
                    if (!TextUtils.isEmpty(auth.getResources())) {
                        MachineDao.getInstance().changeDevice(auth.getResources());
                        EventBus.getDefault().post(new EventLoginStatus(auth.getResources(), true));
                    }
                    // Todo  断网重连之后会先回调到登录成功，间隔几十毫秒之后又突然回调到这里且Status==0 auth.getArg()==null，
                    // Todo 与服务端联调，服务端说只收到一条登录消息请求，同时也只回了一条过来。服务端说他只收到
                    // Todo  所以结果就是断网重连之后连不上。但是当我下面notifyError的代码注释掉之后，Socket的连接居然正常了，让人摸不着头脑，先记录一下
                    /*else {
                        Log.e("zq", "登录失败:：" + mCurrentLoginUserId + " ,  " + auth.getArg());
                        notifyError(SocketException.LOGIN_FAILED_EXCEPTION + "--->HashCode：" + mSelector.hashCode());
                    }*/
                } else {
                    Log.e(TAG, "有其他安卓设备登录我的账号: 我被挤下线了");
                    notifyError(SocketException.LOGIN_CONFLICT_EXCEPTION);
                }
                return;
            }

            if (packet.getCommand() == Command.COMMAND_ERROR) {
                Log.e(TAG, "消息发送失败: ");
                ErrorMessage errorMessage = ProBufUtils.decoderMessageBody(packet.getBytes(), MessageProBuf.CommonErrorProBuf.getDescriptor(), ErrorMessage.class);
                if (errorMessage != null) {
                    //{"arg":"敏感词","code":-1,"messageHead":{"chatType":1,"from":"10002111/android","messageId":"287548f0c8a84d4c936b27172f155ea1","offline":false,"to":"10008295"}}
                    if (errorMessage.getCode() == -2) {// 敏感词error
                        mChatReceiptListener.onReceiveReceipt(ReceiptManager.RECEIPT_ERR, errorMessage.getMessageHead().getMessageId());
                        mMainHandler.post(() -> ToastUtil.showToast(MyApplication.getContext(), MyApplication.getContext().getString(R.string.not_allow_send_by_dangerous_char, errorMessage.getArg())));
                    }
                }
            } else if (packet.getCommand() == Command.COMMAND_CHAT_REQ) {
                // 解析数据包消息
                ChatMessage chatMessage = ProBufUtils.decoderMessageBody(packet.getBytes(), MessageProBuf.ChatMessage.getDescriptor(), ChatMessage.class);
                if (chatMessage == null || chatMessage.getMessageHead() == null) {
                    Log.e("xuan", "decodePacket: 解析出错");
                    return;
                }
                // 发消息回执给服务器通知服务器客户端已收到
                byte chatType = chatMessage.getMessageHead().getChatType();
                // 发送回执给服务器
                addReceipt(chatMessage.getMessageHead());
                if (chatType == 2) { // 群组聊天
                    if (chatMessage.getFromUserId().equals(mCurrentLoginUserId)) { // 我自己的消息当做回执来处理
                        String device = chatMessage.getMessageHead().getFrom().replaceAll(mCurrentLoginUserId + "/", "");
                        Log.e(TAG, "收到群聊回执  消息发送成功: " + chatMessage.toString());
                        if (CURRENT_DEVICE.equals(device)) {
                            mChatReceiptListener.onReceiveReceipt(ReceiptManager.RECEIPT_YES, chatMessage.getMessageId());
                            if (chatMessage.getType() == XmppMessage.TYPE_READ
                                    || chatMessage.getType() == XmppMessage.TYPE_SECURE_LOST_KEY
                                    || chatMessage.messageHead.isOffline()) {
                                // 收到自己发送的群已读回执的同时，还需要在onReceMessage方法内处理一下
                                mGroupMessageListener.onReceMessage(chatMessage, chatMessage.toSkMessage(mCurrentLoginUserId), chatMessage.messageHead.isOffline());
                            }
                        } else {
                            mGroupMessageListener.onReceMessage(chatMessage, chatMessage.toSkMessage(mCurrentLoginUserId), chatMessage.messageHead.isOffline());
                        }
                    } else {
                        if (mGroupMessageListener != null) {
                            Log.e(TAG, "收到群组聊天消息  来自 ：" + chatMessage.getFromUserId() + "   content: " + chatMessage.getContent());
                            mGroupMessageListener.onReceMessage(chatMessage, chatMessage.toSkMessage(mCurrentLoginUserId), chatMessage.messageHead.isOffline());
                        } else {
                            Log.e(TAG, "收到群组离线消息来自 ：" + chatMessage.messageHead.getTo() + "   content: " + chatMessage.getContent());
                            mOffGroupMessage.add(0, chatMessage);
                        }
                    }
                } else {
                    if (mChatMessageListener != null) {
                        Log.e(TAG, "收到单聊聊天消息来自 ：" + chatMessage.getFromUserId() + "   content: " + chatMessage.getContent());
                        mChatMessageListener.onReceMessage(chatMessage.toSkMessage(mCurrentLoginUserId));
                    } else {
                        Log.e(TAG, "收到单聊离线消息来自 ：" + chatMessage.getFromUserId() + "   content: " + chatMessage.getContent());
                        mOffChatMessage.add(0, chatMessage);
                    }
                }
            } else if (packet.getCommand() == Command.COMMAND_BATCH_JOIN_GROUP_RESP) {
                PullBatchGroupRespMessage pullBatchGroupRespMessage = ProBufUtils.decoderMessageBody(packet.getBytes(),
                        MessageProBuf.PullGroupMessageRespProBuf.getDescriptor(), PullBatchGroupRespMessage.class);

                Log.e("batchJoinRoom", "批量拉取群组消息结果返回：" + pullBatchGroupRespMessage.getMessageId());
                Friend friend = FriendDao.getInstance().getFriend(mCurrentLoginUserId, pullBatchGroupRespMessage.getJid());
                String name = friend != null ? friend.getNickName() : pullBatchGroupRespMessage.getJid();
                List<ChatMessage> offLineChatMessageList = pullBatchGroupRespMessage.getMessageList();
                Log.e("batchJoinRoom", "群组：" + name + "，一共有" + pullBatchGroupRespMessage.getCount() + "条离线消息，" + "实际返回" + offLineChatMessageList.size() + "条消息");

                // todo 获取该群组最后一个漫游任务，为什么这里加上这样的一个逻辑，详情请看XMuChatMessageListener类100行左右注释代码及其下面todo介绍
                MsgRoamTask mLastMsgRoamTask = MsgRoamTaskDao.getInstance().getFriendLastMsgRoamTask(mCurrentLoginUserId, pullBatchGroupRespMessage.getJid());
                if (mLastMsgRoamTask != null) {
                    if (pullBatchGroupRespMessage.getCount() > offLineChatMessageList.size()) {
                        Log.e("batchJoinRoom", "群组：" + name + "，离线消息数量大于实际返回离线消息数量，更新漫游任务endTime");
                        MsgRoamTaskDao.getInstance().updateMsgRoamTaskEndTime(mCurrentLoginUserId,
                                pullBatchGroupRespMessage.getJid(),
                                mLastMsgRoamTask.getTaskId(),
                                offLineChatMessageList.get(0).getTimeSend());
                    } else {
                        Log.e("batchJoinRoom", "群组：" + name + "，离线消息数量小于(理论上不太可能出现小于)/等于实际返回离线消息数量，删除漫游任务");
                        MsgRoamTaskDao.getInstance().deleteMsgRoamTask(mCurrentLoginUserId,
                                pullBatchGroupRespMessage.getJid(),
                                mLastMsgRoamTask.getTaskId());
                    }
                } else {
                    Log.e("batchJoinRoom", "群组：" + name + "没有漫游任务");
                }

                if (mGroupMessageListener != null) {
                    for (int i = 0; i < offLineChatMessageList.size(); i++) {
                        mGroupMessageListener.onReceMessage(offLineChatMessageList.get(i), offLineChatMessageList.get(i).toSkMessage(mCurrentLoginUserId), true);
                    }
                } else {
                    mOffGroupMessage.addAll(offLineChatMessageList);
                }
                // 服务端最多返回100条离线消息，剩下的需要靠漫游获取，但未读消息数量我们要显示准确，这里更新一下
                if (pullBatchGroupRespMessage.getCount() > 100) {
                    FriendDao.getInstance().markUserMessageUnRead2(mCurrentLoginUserId, pullBatchGroupRespMessage.getJid(), (int) (pullBatchGroupRespMessage.getCount() - 100));
                }
            } else if (packet.getCommand() == Command.COMMAND_SUCCESS) {
                SuccessMessage success = ProBufUtils.decoderMessageBody(packet.getBytes(), MessageProBuf.CommonSuccessProBuf.getDescriptor(), SuccessMessage.class);
                MessageHead head = success.getMessageHead();
                Log.e(TAG, "收到回执消息  消息发送成功: " + head.getMessageId());
                mChatReceiptListener.onReceiveReceipt(ReceiptManager.RECEIPT_YES, head.getMessageId());
            }
        }
    }
}
