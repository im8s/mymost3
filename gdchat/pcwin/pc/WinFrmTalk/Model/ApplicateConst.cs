namespace WinFrmTalk
{

    /// <summary>
    /// Http接口路径定义
    /// </summary>
    public static class ApplicateConst
    {

        /// <summary>
        /// 登录接口
        /// </summary>
        public const string Login = "user/login";

        /// <summary>
        /// 验证手机号
        /// </summary>
        public const string TelephoneVerify = "verify/telephone";

        /// <summary>
        /// 上传文件(包括图片和音频)
        /// </summary>
        public const string UploadData = "upload/UploadifyAvatarServlet";

        /// <summary>
        /// 注册用户
        /// </summary>
        public const string RegisterAccount = "user/register";

        /// <summary>
        /// 删除群成员
        /// </summary>
        public const string DeleteRoomMember = "room/member/delete";

        /// <summary>
        /// 删除群成员
        /// </summary>
        public const string DeleteGroupMember = "room/member/delete";


        /// <summary>
        /// 群组详情
        /// </summary>
        public const string RoomDetail = "room/get";

        /// <summary>
        /// 更新群组信息(包括群成员)
        /// </summary>
        public const string RoomUpdate = "room/update";

        /// <summary>
        /// 获取群成员详情
        /// </summary>
        public const string RoomMemberDetail = "room/member/get";

        /// <summary>
        /// 加入群聊
        /// </summary>
        public const string JoinGroup = "room/join";

        /// <summary>
        /// 获取群成员列表
        /// </summary>
        public const string RoomMemberList = "room/member/list";

        /// <summary>
        /// 获取当前用户加入的群聊
        /// </summary>
        public const string JoinedGroupList = "room/list/his";

        /// <summary>
        /// 获取群组列表(所有群？)
        /// </summary>
        public const string AllGroupList = "room/list";


        /// <summary>
        /// 获取用户详情
        /// </summary>
        public const string GetUserDetail = "user/get";

        /// <summary>
        /// 好友添加
        /// </summary>
        public const string AddFriend = "friends/attention/add";

        /// <summary>
        /// 删除群组
        /// </summary>
        public const string DeleteRoom = "room/delete";

        /// <summary>
        /// 退出
        /// </summary>
        public const string AccountLogout = "user/outtime";

        /// <summary>
        /// 获取附近的人
        /// </summary>
        public const string NearByAccount = "nearby/user";

        /// <summary>
        /// 获取好友列表
        /// </summary>
        public const string FriendList = "friends/list";

        /// <summary>
        /// 用户信息更新
        /// </summary>
        public const string UserUpdate = "user/update";

        /// <summary>
        /// 创建群组
        /// </summary>
        public const string RoomCreate = "room/add";

        /// <summary>
        /// 更新对应的
        /// </summary>
        public const string UpdateMember = "room/member/update";

        /// <summary>
        /// 设置群管理员
        /// </summary>
        public const string SetRoomAdmin = "room/set/admin";

        /// <summary>
        /// 转让群主
        /// </summary>
        public const string TransferRoom = "room/transfer";

        /// <summary>
        /// 添加至黑名单
        /// </summary>
        public const string BanFriend = "friends/blacklist/add";

        /// <summary>
        /// 获取黑名单
        /// </summary>
        public const string BlackList = "friends/blacklist";

        /// <summary>
        /// 移除黑名单
        /// </summary>
        public const string DeleteBlackItem = "friends/blacklist/delete";

        /// <summary>
        /// 删除好友
        /// </summary>
        public const string DeleteFriend = "friends/delete";

        /// <summary>
        /// 更新好友昵称
        /// </summary>
        public const string UpdateFriendRemark = "friends/remark";

        /// <summary>
        /// 删除消息(撤回消息)
        /// </summary>
        public const string DeleteMessage = "tigase/deleteMsg";

        /// <summary>
        /// 更新个人用户设置
        /// </summary>
        public const string UpdateAccountSettings = "user/settings/update";

        /// <summary>
        /// 获取用户设置
        /// </summary>
        public const string UserSettings = "user/settings";

        /// <summary>
        /// 获取群聊
        /// </summary>
        public const string GroupChatHistory = "tigase/shiku_muc_msgs";

        /// <summary>
        /// 获取单聊历史消息
        /// </summary>
        public const string ChatHistory = "tigase/shiku_msgs";

        /// <summary>
        /// 最近聊天消息(上次聊天消息项)
        /// </summary>
        public const string ChatRecentList = "tigase/getLastChatList";

        /// <summary>
        /// 查询群共享
        /// </summary>
        public const string RoomShare = "room/share/find";

        /// <summary>
        /// 添加群共享
        /// </summary>
        public const string AddToRoomShare = "room/add/share";

        /// <summary>
        /// 删除群共享
        /// </summary>
        public const string DeleteRoomShare = "room/share/delete";

        /// <summary>
        ///  获取单个群共享
        /// </summary>
        public const string SingleRoomShare = "room/share/get";

        /// <summary>
        ///  更新群内昵称
        /// </summary>
        public const string UpdateMemberRemarkname = "room/member/update";

        /// <summary>
        /// 设置群组消息免打扰
        /// </summary>
        public const string OfflineNoPushing = "room/member/setOfflineNoPushMsg";

        /// <summary>
        /// 获取标识列表
        /// </summary>
        public const string UserLabels = "label/getUserLabels";

    }



    public static class HttpConfigApi
    {
        #region 业务相关

        /// <summary>
        /// 登录接口
        /// </summary>
        public static string Login
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.Login; }
        }

        /// <summary>
        /// 退出
        /// </summary>
        public static string AccountLogout
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.AccountLogout; }
        }


        /// <summary>
        /// 验证手机号
        /// </summary>
        public static string TelephoneVerify
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.TelephoneVerify; }
        }


        /// <summary>
        /// 注册用户
        /// </summary>
        public static string Register
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.RegisterAccount; }
        }

        #endregion


        #region 好友相关

        /// <summary>
        /// 添加至黑名单
        /// </summary>
        public static string BanFriend = "friends/blacklist/add";

        /// <summary>
        /// 获取黑名单
        /// </summary>
        public static string BlackList = "friends/blacklist";

        /// <summary>
        /// 移除黑名单
        /// </summary>
        public static string DeleteBlackItem = "friends/blacklist/delete";

        /// <summary>
        /// 删除好友
        /// </summary>
        public static string DeleteFriend = "friends/delete";

        /// <summary>
        /// 更新好友昵称
        /// </summary>
        public static string UpdateFriendRemark = "friends/remark";


        /// <summary>
        /// 好友添加
        /// </summary>
        public static string AddFriend = "friends/attention/add";




        /// <summary>
        /// 获取附近的人
        /// </summary>
        public static string NearByAccount = "nearby/user";

        /// <summary>
        /// 获取好友列表
        /// </summary>
        public static string FriendList = "friends/list";
        #endregion

        #region 群组相关

        /// <summary>
        /// 删除群成员
        /// </summary>
        public static string DeleteRoomMember
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.DeleteRoomMember; }
        }

        /// <summary>
        /// 加入群聊
        /// </summary>
        public static string JoinGroup
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.JoinGroup; }
        }

        /// <summary>
        /// 删除群组
        /// </summary>
        public static string DeleteRoom
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.DeleteRoom; }
        }

        /// <summary>
        /// 群组详情
        /// </summary>
        public static string RoomDetail
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.RoomDetail; }
        }

        /// <summary>
        /// 获取群组内群成员列表详情
        /// </summary>
        public static string RoomMemberDetail
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.RoomMemberDetail; }
        }

        /// <summary>
        /// 更新群组信息(包括群成员)
        /// </summary>
        public static string RoomUpdate
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.RoomUpdate; }
        }


        /// <summary>
        /// 获取群成员列表
        /// </summary>
        public static string RoomMemberList
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.RoomMemberList; }
        }

        /// <summary>
        /// 获取当前用户加入的群聊
        /// </summary>
        public static string JoinedGroupList
        {
            get { return Applicate.URLDATA.data.apiUrl + ApplicateConst.JoinedGroupList; }
        }

        #endregion

        /// <summary>
        /// 上传文件(包括图片和音频)
        /// </summary>
        public static string UploadData = "upload/UploadifyAvatarServlet";


        /// <summary>
        /// 获取用户详情
        /// </summary>
        public static string GetUserDetail = "user/get";


        /// <summary>
        /// 用户信息更新
        /// </summary>
        public static string UserUpdate = "user/update";

        /// <summary>
        /// 创建群组
        /// </summary>
        public static string RoomCreate = "room/add";

        /// <summary>
        /// 更新对应的
        /// </summary>
        public static string UpdateMember = "room/member/update";

        /// <summary>
        /// 设置群管理员
        /// </summary>
        public static string SetRoomAdmin = "room/set/admin";

        /// <summary>
        /// 转让群主
        /// </summary>
        public static string TransferRoom = "room/transfer";

 
        /// <summary>
        /// 删除消息(撤回消息)
        /// </summary>
        public static string DeleteMessage = "tigase/deleteMsg";

        /// <summary>
        /// 更新个人用户设置
        /// </summary>
        public static string UpdateAccountSettings = "user/settings/update";

        /// <summary>
        /// 获取用户设置
        /// </summary>
        public static string UserSettings = "user/settings";

        /// <summary>
        /// 获取群聊
        /// </summary>
        public static string GroupChatHistory = "tigase/shiku_muc_msgs";

        /// <summary>
        /// 获取单聊历史消息
        /// </summary>
        public static string ChatHistory = "tigase/shiku_msgs";

        /// <summary>
        /// 最近聊天消息(上次聊天消息项)
        /// </summary>
        public static string ChatRecentList = "tigase/getLastChatList";

        /// <summary>
        /// 查询群共享
        /// </summary>
        public static string RoomShare = "room/share/find";

        /// <summary>
        /// 添加群共享
        /// </summary>
        public static string AddToRoomShare = "room/add/share";

        /// <summary>
        /// 删除群共享
        /// </summary>
        public static string DeleteRoomShare = "room/share/delete";

        /// <summary>
        ///  获取单个群共享
        /// </summary>
        public static string SingleRoomShare = "room/share/get";

        /// <summary>
        ///  更新群内昵称
        /// </summary>
        public static string UpdateMemberRemarkname = "room/member/update";

        /// <summary>
        /// 设置群组消息免打扰
        /// </summary>
        public static string OfflineNoPushing = "room/member/setOfflineNoPushMsg";

        /// <summary>
        /// 获取标识列表
        /// </summary>
        public static string UserLabels = "label/getUserLabels";


    }

}
