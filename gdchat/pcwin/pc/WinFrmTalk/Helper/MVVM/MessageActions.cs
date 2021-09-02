using System;

public class MessageActions
{


    #region 消息状态相关
    /// <summary>
    /// 已读消息发送成功（已读发送方）更新数据库原消息已读标志位，更新未读红点UI 参数  messageObject
    /// </summary>
    public const string XMPP_UPDATE_SEND_READ = "update_send_read";

    /// <summary>
    /// 收到对方已读消息 （已读接收方）更新UI已读标志  参数  messageObject
    /// </summary>
    public const string XMPP_UPDATE_RECEIVED_READ = "update_received_read";
    /// <summary>
    /// 口令红包
    /// </summary>
    public const string RED_UPDATE_COMMAND = "red_update_command";
    public const string RED_OPEN_COMMAND = "red_open_command";
    /// <summary>
    /// 更新UI消息发送失败标志 消息已发送失败 参数 messageObject
    /// </summary>
    public const string XMPP_UPDATE_SEND_FAILED = "update_message_failed";

    /// <summary>
    /// 更新UI送达标志 消息已发送成功 参数 messageObject
    /// </summary>
    public const string XMPP_UPDATE_SEND_SUCCESS = "update_message_success";
    #endregion

    #region 消息相关
    /// <summary>
    /// 更新UI 收到一条新的普通消息 参数 messageObject
    /// </summary>
    public const string XMPP_UPDATE_NORMAL_MESSAGE = "update_normal_message";

    /// <summary>
    /// 更新UI 收到一条消息撤回 messageObject
    /// </summary>
    public const string XMPP_UPDATE_RECALL_MESSAGE = "update_recall_message";

    /// <summary>
    /// 更新UI 收到了一条好友验证消息 messageObject
    /// </summary>
    public const string XMPP_UPDATE_VERIFY_MESSAGE = "update_verify_message";

    /// <summary>
    /// 更新UI 收到了一条好友验证回执 messageObject
    /// </summary>
    public const string XMPP_UPDATE_VERIFY_RECEPIT = nameof(XMPP_UPDATE_VERIFY_RECEPIT);

    /// <summary>
    /// 更新UI 收到了一个群组控制消息 messageObject
    /// </summary>
    public const string XMPP_UPDATE_ROOM_CHANGE_MESSAGE = "update_room_message";

    /// <summary>
    /// 更新UI 收到了一个音视频协议消息 messageObject
    /// </summary>
    public const string XMPP_UPDATE_MEETING_MESSAGE = "update_meeting_message";

    /// <summary>
    /// 更新UI 收到了一个音视频协议消息回执 messageObject
    /// </summary>
    public const string XMPP_UPDATE_MEETING_RECEIPT = "update_meeting_receipt";
    /// <summary>
    /// 更新UI 收到了一个客服协议消息messageObject
    /// </summary>
    public const string XMPP_UPDATE_CUSTOMERSERVICE = "update_customerservice";


    #endregion

    #region 群组相关
    /// <summary>
    /// 更新UI 我退出了某一个群组(主动离开)messageObject
    /// </summary>
    public const string XMPP_UPDATE_ROOM_DELETE = "update_room_del";


    /// <summary>
    /// 更新UI Xmpp状态变更 参数state（xmpp连接，断开，被挤下线等）
    /// </summary>
    public const string XMPP_UPDATE_STATE = "update_xmpp_state";

    /// <summary>
    /// 更新UI 我退出了某一个群组(主动离开)messageObject
    /// </summary>
    public const string Room_UPDATE_ROOM_DELETE = "liuhuan_del_room_";

    /// <summary>
    /// 添加好友
    /// </summary>
    public const string Room_UPDATE_ROOM_ADD = "liuhuan_add_room_";
    /// <summary>
    /// 删除群公告
    /// </summary>
    public const string Room_Deleate_ROOM_TIPS = "liuhuan_deleate_roomTips";
    /// <summary>
    /// 禁言       我被管理员禁言了    群主开启了全部禁言 参数 MessageObject
    /// </summary>
    public const string ROOM_UPDATE_BANNED_TALK = "ROOM_BANNED_TALK";


    /// <summary>
    /// 邀请，我被邀请到一个新的群，刷新列表 参数meessageObject
    /// </summary>
    public const string ROOM_UPDATE_INVITE = "ROOM_UPDATE_INVITE";


    /// <summary>
    /// 与我相关的@群成员消息  参数Friend
    /// </summary>
    public const string ROOM_UPDATE_AT_ME = "ROOM_UPDATE_AT_ME";



    #endregion

    #region 好友相关
    /// <summary>
    /// 更新好友备注
    /// </summary>
    public const string UPDATE_FRIEND_REMARKS = "update_friend_remarks";
    /// <summary>
    /// 删除好友
    /// </summary>
    public const string DELETE_FRIEND = "delete_friend";
    /// <summary>
    /// 加入黑名单
    /// </summary>
    public const string ADD_BLACKLIST = "add_blacklist";

    /// <summary>
    /// 清除一个朋友的聊天记录 参数 string: userid
    /// </summary>
    public const string CLEAR_FRIEND_MSGS = "clear_friend_msgs";

    /// <summary>
    /// 更新一个朋友的最后一条聊天记录 参数 Friend
    /// </summary>
    public const string UPDATE_FRIEND_LAST_CONTENT = "update_friend_last_content";

    #endregion



    #region 列表相关

    /// <summary>
    /// 显示一条消息(针对于消息列表)
    /// </summary>
    public const string XMPP_SHOW_SINGLE_MESSAGE = "show_single_message";

    /// <summary>
    /// 收到批量消息，一次性刷新(针对于消息列表)
    /// </summary>
    public const string XMPP_SHOW_ALL_MESSAGE = "show_all_message";

    /// <summary>
    /// 更新朋友消息置顶
    /// </summary>
    public const string UPDATE_FRIEND_TOP = "friend_message_top";


    /// <summary>
    /// 更新朋友消息免打扰
    /// </summary>
    public const string UPDATE_FRIEND_DISTURB = "friend_message_disturb";

    /// <summary>
    /// 更新朋友消息阅后即焚
    /// </summary>
    public const string UPDATE_FRIEND_READDEL = "friend_message_readdel";
    /// <summary>
    /// 最近消息列表下载完成
    /// </summary>
    public const string DOWN_CHATLIST_COMPT = "down_chats_compte";

    #endregion


    #region 多点登录
    /// <summary>
    /// 多点登录上线离线消息
    /// </summary>
    public const string UPDATE_DEVICE_STATE = "update_device_state";
    internal const string FILE_DOWN_COMPT = "FILE_DOWN_COMPT";

    #endregion

    #region 刷新头像
    public const string UPDATE_HEAD = "update_head";
    #endregion

    #region 刷新配置
    public const string UPDATE_CONFIG = "update_config";
    public const string SHOW_LOGINFORM = "show_login_form";
    public const string UPDATE_COLLECT_LIST = "update_collect_list";
    public const string UPDATE_COURSE_LIST = "update_course_list";  // 更新我的讲课
    public const string UPDATE_LABLE_LIST = "update_lable_list";// 
    public const string RESTART_APP = "restart_app";// 重启程序

    #endregion
}
