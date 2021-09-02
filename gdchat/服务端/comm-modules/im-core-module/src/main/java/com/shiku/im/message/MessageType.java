package com.shiku.im.message;

import java.util.HashSet;
import java.util.Set;

public  interface MessageType {

    //扫码手动充值-后台审核后的通知
    //{
    // "type":78
    // "fromUserId":""
    // "fromUserName":""
    // "content":""
    // "timeSend":""
    //
    public static final int MANUAL_RECHARGE=78;

    //扫码手动提现-后台审核后的通知
    //{
    // "type":79
    // "fromUserId":""
    // "fromUserName":""
    // "content":""
    // "timeSend":""
    //
    public static final int MANUAL_WITHDRAW=79;

    //收红包
    //{
    //  "type":83
    //	"fromUserId":""
    //	"fromUserName":""
    //	"ObjectId":"如果是群聊，则为房间Id"
    //	"timeSend":123
    public static final int  OPENREDPAKET=83;

    // 红包退款
    // {
    //	 "type":86
    //   "fromUserId":""
    //   "fromUserName":""
    // 	 "ObjectId":"如果是群聊，则为房间Id"
    //	 "timeSend":123
    public static final int RECEDEREDPAKET=86;

    // 转账收款
    // {
    //    "type":88
    //    "fromUserId":""
    //    "fromUserName":""
    //    "ObjectId":""
    //    "timeSend":123
    public static final int RECEIVETRANSFER = 88;

    // 转账退回
    // {
    //    "type":89
    //    "fromUserId":""
    //    "fromUserName":""
    //    "ObjectId":""
    //    "timeSend":123
    public static final int REFUNDTRANSFER = 89;

    // 付款码已付款通知
    // {
    //    "type":90
    //    "fromUserId":""
    //    "fromUserName":""
    //	  "ObjectId":""
    //    "timeSend":123
    public static final int CODEPAYMENT = 90;

    // 付款码已到账通知
    // {
    //    "type":91
    //    "fromUserId":""
    //    "fromUserName":""
    //	  "ObjectId":""
    //    "timeSend":123
    public static final int CODEARRIVAL = 91;

    // 二维码收款已付款通知
    // {
    //    "type":91
    //    "fromUserId":""
    //    "fromUserName":""
    //	  "ObjectId":""
    //    "timeSend":123
    public static final int CODERECEIPT = 92;

    // 二维码收款已到账通知
    // {
    //    "type":93
    //    "fromUserId":""
    //    "fromUserName":""
    //	  "ObjectId":""
    //    "timeSend":123
    public static final int CODEERECEIPTARRIVAL = 93;

    // 第三方应用调取IM支付成功通知
    public static final int OPENPAYSUCCESS = 97;

    //上传文件
    //{
    //"type":401,
    //"content":"文件名",
    //"fromUserId":"上传者",
    //"fromUserName":"",
    //"ObjectId":"文件Id"
    //"timeSend":123
    //}
    public static final int FILEUPLOAD=401;

    //删除文件
    //{
    //"type":402,
    //"content":"文件名",
    //"fromUserId":"删除者",
    //"fromUserName":"",
    //"ObjectId":"文件Id",
    //"timeSend":123
    //}
    public static final int DELETEFILE=402;

    /**
     后台删除好友（客户端自己封装的xmpp，这里用于后台的用户管理删除好友）
     {
     fromUserId:10005
     "type":515
     "objectId": 封装 fromUserId  toUserId 用于接收系统号发送xmpp消息的用户
     }
     */
    public static final int deleteFriends=515;

    /**
     后台加入黑名单（客户端自己封装的xmpp，这里用于后台的用户管理中的加入黑名单）
     {
     fromUserId:10005
     "type":513
     "objectId": 封装 fromUserId  toUserId 用于接收系统号发送xmpp消息的用户
     }
     */
    public static final int joinBlacklist=513;

    /**
     后台移除黑名单（客户端自己封装的xmpp，这里用于后台的用户管理中的移除黑名单）
     {
     fromUserId:10005
     "type":514
     "objectId": 封装 fromUserId  toUserId 用于接收系统号发送xmpp消息的用户
     }
     */
    public static final int moveBlacklist=514;

    /**
     通讯录批量添加好友
     {
     fromUserId:我的新通讯录好友
     "type":510
     "toUserId": 我
     }
     */
    public static final int batchAddFriend=510;

    /**
     用户注册后更新通讯录好友
     {
     fromUserId:我的新通讯录好友
     "type":511
     "toUserId": 我
     }
     */
    public static final int registAddressBook=511;

    /**
     *后台删除用户用于客户端更新本地数据
     {
     fromUserId:系统用户
     "type":512
     "toUserId": 被删除用户的所有好友Id
     "objectId" ： 被删除人的id
     }
     */
    public static final int consoleDeleteUsers=512;


    /**
     * 多点登录用户相关操作用于同步数据
     *{
     fromUserId:自己
     "type":800
     "toUserId": 自己
     "other": 0：修改密码，1：设置支付密码，2：用户隐私设置
     *}
     */
    public static final int multipointLoginDataSync=800;

    /**
     * 多点登录更新个人资料
     *{
     fromUserId:自己
     "type":801
     "toUserId": 自己
     *}
     */
    public static final int updatePersonalInfo =801;


    /**
     * 多点登录更新群组相关信息
     *{
     fromUserId:自己
     "type":801
     "toUserId": 自己
     "objectId": "房间Id",
     *}
     */
    public static final int updateRoomInfo =802;

    /**
     *  给好友发送更新公钥的xmpp 消息 803
     */
    public static final int updateFriendsEncryptKey =803;

    /**
     * 授权消息通知
     */
    public static final int AUTHLOGINDEVICE =810;

    /**
     * 后台管理封号
     */
    public static final int CONSOLELOCKUSER = 811;


    // 修改昵称
    // {
    // "type": 901,
    // "objectId": "房间Id",
    // "fromUserId": 10005,
    // "fromUserName": "10005",
    // "toUserId": 用户Id,
    // "toUserName": "用户昵称",
    // "timeSend": 123
    // }
    public static final int CHANGE_NICK_NAME = 901;

    // 修改房间名
    // {
    // "type": 902,
    // "objectId": "房间Id",
    // "content": "房间名",
    // "fromUserId": 10005,
    // "fromUserName": "10005",
    // "timeSend": 123
    // }
    public static final int CHANGE_ROOM_NAME = 902;

    // 删除成员
    // {
    // "type": 904,
    // "objectId": "房间Id",
    // "fromUserId": 0,
    // "fromUserName": "",
    // "toUserId": 被删除成员Id,
    // "timeSend": 123
    // }
    public static final int DELETE_MEMBER = 904;
    // 删除房间
    // {
    // "type": 903,
    // "objectId": "房间Id",
    // "content": "房间名",
    // "fromUserId": 10005,
    // "fromUserName": "10005",
    // "timeSend": 123
    // }
    public static final int DELETE_ROOM = 903;
    // 禁言
    // {
    // "type": 906,
    // "objectId": "房间Id",
    // "content": "禁言时间",
    // "fromUserId": 10005,
    // "fromUserName": "10005",
    // "toUserId": 被禁言成员Id,
    // "toUserName": "被禁言成员昵称",
    // "timeSend": 123
    // }
    public static final int GAG = 906;
    // 新成员
    // {
    // "type": 907,
    // "objectId": "房间Id",
    // "fromUserId": 邀请人Id,
    // "fromUserName": "邀请人昵称",
    // "toUserId": 新成员Id,
    // "toUserName": "新成员昵称",
    // "content":"是否显示阅读人数",  1:开启  0：关闭
    // "timeSend": 123
    // }
    public static final int NEW_MEMBER = 907;
    // 新公告
    // {
    // "type": 905,
    // "objectId": "房间Id",
    // "content": "公告内容",
    // "fromUserId": 10005,
    // "fromUserName": "10005",
    // "timeSend": 123
    // }
    public static final int NEW_NOTICE = 905;
    //用户离线
    //
    //{
    // "type": 908,
    // "userId":"用户ID"
    // "name":"用户昵称"
    // "coment":"用户离线"
    //}
    public static final int OFFLINE = 908;
    //用户上线
    //{
    // "type": 909,
    // "userId":"用户ID"
    // "name":"用户昵称"
    // "coment":"用户上线"
    //}
    public static final int ONLINE = 909;

    //弹幕
    //{
    //	"type":910,
    //	"formUserId":"用户ID"
    //	"fromUserName":"用户昵称"
    //	"content":"弹幕内容"
    //	"timeSend": 123
    //}
    public static final int BARRAGE= 910;

    //送礼物
    //{
    //	"type":911
    //	"fromUserId":"用户ID"
    //	"fromUserName":"用户昵称"
    //	"content":"礼物"
    //	"timeSend":123
    //}
    public static final int GIFT=911;

    //直播点赞
    //{
    //	"type":912
    //	}
    public static final int LIVEPRAISE=912;

    //设置管理员
    //{
    //	"type":913
    //	"fromUserId":"发送者Id"
    //	"fromUserName":"发送者昵称"
    //	"content":"1为启用  0为取消管理员"
    // 	"timeSend":123
    //}
    public static final int SETADMIN=913;

    //进入直播间
    // {
    //	"type":914
    //	"fromUserId":"发送者Id"
    //	"fromUserName":"发送者昵称"
    //	"objectId":"房间的JID"
    //	"timeSend":123
    //}
    public static final int JOINLIVE=914;


    /**
     显示阅读人数
     {
     "type":915
     "objectId":"房间JId"
     "content":"是否显示阅读人数" 1：开启 2：关闭
     }
     */
    public static final int SHOWREAD=915;

    /**
     群组是否需要验证
     {
     "type":916
     "objectId":"房间JId"
     "content": 1：开启验证   0：关闭验证
     }
     */
    public static final int RoomNeedVerify=916;

    /**
     房间是否公开
     {
     "type":917
     "objectId":"房间JId"
     "content": 1：不公开 隐私群   0：公开
     }
     */
    public static final int RoomIsPublic=917;

    /**
     普通成员 是否可以看到 群组内的成员
     关闭 即普通成员 只能看到群主
     {
     "type":918
     "objectId":"房间JId"
     "content": 1：可见   0：不可见
     }
     */
    public static final int RoomShowMember=918;
    /**
     群组允许发送名片
     {
     "type":919
     "objectId":"房间JId"
     "content": 1：   允许发送名片   0：不允许发送
     }
     */
    public static final int RoomAllowSendCard=919;

    /**
     群组全员禁言
     {
     "type":920
     "objectId":"房间JId"
     "content": tailTime   禁言截止时间
     }
     */
    public static final int RoomAllBanned=920;

    /**
     群组允许成员邀请好友
     {
     "type":921
     "objectId":"房间JId"
     "content": 1：  允许成员邀请好友   0：不允许成员邀请好友
     }
     */
    public static final int RoomAllowInviteFriend=921;

    /**
     群组允许成员上传群共享文件
     {
     "type":922
     "objectId":"房间JId"
     "content": 1：  允许成员上传群共享文件   0：不允许成员上传群共享文件
     }
     */
    public static final int RoomAllowUploadFile=922;
    /**
     群组允许成员召开会议

     {
     "type":923
     "objectId":"房间JId"
     "content": 1：  允许成员召开会议   0：不允许成员召开会议
     }
     */
    public static final int RoomAllowConference=923;

    /**
     群组允许成员开启 讲课
     {
     "type":924
     "objectId":"房间JId"
     "content": 1：  允许成员开启 讲课   0：不允许成员开启 讲课
     }
     */
    public static final int RoomAllowSpeakCourse=924;
    /**
     群组转让 接口
     {
     fromUserId:旧群主ID
     "type":925
     "objectId":"房间JId"
     "toUserId": 新群组用户ID
     }
     */
    public static final int RoomTransfer=925;

    /**
     *  房间是否锁定
     {
     "type":926
     "objectId":"房间JId"
     "content": 1：锁定房间   0：解锁房间
     }
     *
     */
    public static final int RoomDisable=926;

    /**
     *  直播间中退出、被踢出直播间
     {
     "type":927
     "objectId":"房间JId"
     "content": 退出被踢出直播间
     }
     *
     */
    public static final int LiveRoomSignOut=927;

    /**
     *  直播间中的禁言、取消禁言
     {
     "type":928
     "objectId":"房间JId"
     "content": 0：禁言，1：取消禁言
     }
     *
     */
    public static final int LiveRoomBannedSpeak=928;

    /**
     *  直播间中设置、取消管理员
     {
     "type":929
     "objectId":"房间JId"
     "content": 0:设置管理员  1:取消管理员
     }
     *
     */
    public static final int LiveRoomSettingAdmin=929;

    /**
     *  群组中设置 隐身人和监控人
     {
     "type":930
     "objectId":"房间JId"
     "content": 1:设置隐身人  -1:取消隐身人，2：设置监控人，0：取消监控人
     }
     *
     */
    public static final int SetRoomSettingInvisibleGuardian=930;

    /**
     *后台锁定、取消锁定群组
     {
     fromUserId:系统用户
     "type":931
     "content":1：解锁，-1：锁定
     "objectId" ： roomJid
     }
     */
    public static final int consoleProhibitRoom=931;

    /**
     * 聊天记录超时设置
     {
     "type":932
     "objectId":"房间JId"
     "content": 1.0:保存一天  -1:永久保存  365.0保存一年
     }
     */
    public static final int ChatRecordTimeOut = 932;

    /**
     *
     {
     "type":933
     "objectId":"房间JId"
     "content": 1
     }
     */
    public static final int LocationRoom = 933;

    /**
     * 修改群公告
     {
     "type":934
     "objectId":"房间JId"
     "content": notice
     }
     */
    public static final int ModifyNotice = 934;

    /**
     * 修改群组加密类型
     {
     "type":935
     "objectId":"房间JId"
     "content": encryptType
     }
     */
    public static final int ModifyEncryptType = 935;

    /**
     * 用户离线移出直播间
     {
     "type":936
     "objectId":"房间JId"
     "content": encryptType
     "other":"创建者Id"
     }
     */
    public static final int RemoveLiveRoom = 936;

    /**
     * 禁止退群
     */
    public static final int ForbidQuit = 937;

    /**
     * 设置大神
     */
    public static final int SetGod = 938;

    /**
     * 设置导师
     */
    public static final int SetTutor = 939;


    // 点赞
    //{
    //	"type":301
    //
    //
    //}
    public static final int PRAISE=301;

    // 评论
    //{
    //	"type":302
    //}
    public static final int COMMENT=302;

    // 取消点赞
    //{
    //	"type":303
    //
    //
    //}
    public static final int CANCELPRAISE=303;


    //朋友圈的提醒
    //{
    //"type":304
    //}
    public static final int REMIND=304;

    /**
     生活圈新消息

     */
    public static final int MSG_NEW=305;

    public static final Set<Integer> liveRoomType = new HashSet<Integer>(){{
        add(BARRAGE);
        add(GIFT);
        add(LIVEPRAISE);
        add(JOINLIVE);
        add(LiveRoomSignOut);
        add(LiveRoomBannedSpeak);
        add(LiveRoomSettingAdmin);
        add(RemoveLiveRoom);
    }};

}
