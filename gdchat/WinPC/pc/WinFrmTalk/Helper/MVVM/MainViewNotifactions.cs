#region 登录注册页面通知Token
/// <summary>
/// 登录注册页面通知Token
/// </summary>
public static class LoginNotifications
{
    /// <summary>
    /// 登录页面初始化用户(记住密码使用)
    /// </summary>
    public const string InitialAccount = nameof(InitialAccount);
    
}
#endregion

#region 主窗口通知Token
/// <summary>
/// 主窗口通知Token
/// </summary>
public static class MainViewNotifactions
{
  
    /// <summary>
    /// 主页面添加最近消息项(一般用于<see cref="MainViewModel"/>中RecentList集合的添加)
    /// </summary>
    public const string MainAddRecentItem = nameof(MainAddRecentItem);

    /// <summary>
    /// 设置主窗口选中的最近消息项
    /// </summary>
    public const string MainChangeRecentListIndex = nameof(MainChangeRecentListIndex);

    /// <summary>
    /// 更新主窗口对应UserId的名称(或备注)
    /// </summary>
    public const string UpdateAccountName = nameof(UpdateAccountName);

    /// <summary>
    /// 插入RecentMessageList
    /// </summary>
    public const string MainInsertRecentItem = nameof(MainInsertRecentItem);

    /// <summary>
    /// 主窗口添加好友项目
    /// </summary>
    public const string MainAddFriendListItem = nameof(MainAddFriendListItem);

    /// <summary>
    /// 控制主窗口页面
    /// </summary>
    public const string MainGoToPage = nameof(MainGoToPage);

    /// <summary>
    /// 主窗口加载好友列表(True为本地加载,False为调用接口加载)
    /// </summary>
    public const string MainViewLoadFriendList = nameof(MainViewLoadFriendList);

    /// <summary>
    /// 主窗口加载群组列表(True为本地加载,False为调用接口加载)
    /// </summary>
    public const string MainViewLoadGroupList = nameof(MainViewLoadGroupList);

    /// <summary>
    /// 主窗口加载黑名单列表(True为本地加载,False为调用接口加载)
    /// </summary>
    public const string MainViewLoadBlockList = nameof(MainViewLoadBlockList);

    /// <summary>
    /// 转发消息
    /// </summary>
    public const string ForwardMessage = nameof(ForwardMessage);

    /// <summary>
    /// 撤回消息
    /// </summary>
    public const string WithDrawMessage = nameof(WithDrawMessage);

    /// <summary>
    ///  主窗口提示消息通知Token
    /// </summary>
    public const string SnacbarMessage = nameof(SnacbarMessage);

    /// <summary>
    /// 创建或更新消息列表项通知Token
    /// </summary>
    public const string CreateOrUpdateRecentItem = nameof(CreateOrUpdateRecentItem);

    /// <summary>
    /// 主窗口更新最近消息项通知Token
    /// </summary>
    public const string UpdateRecentItemContent = nameof(UpdateRecentItemContent);

    /// <summary>
    /// 更新我的账号详情
    /// </summary>
    public const string UpdateMyAccount = nameof(UpdateMyAccount);

    /// <summary>
    /// Xmpp连接状态改变时
    /// </summary>
    public const string XmppConnectionStateChanged = nameof(XmppConnectionStateChanged);

    /// <summary>
    /// 聊天输入框内容改变
    /// </summary>
    public const string InputTextChanged = nameof(InputTextChanged);

    /// <summary>
    /// 取消黑名单
    /// </summary>
    public const string CancelBlockItem = nameof(CancelBlockItem);

    /// <summary>
    /// 删除单个群组
    /// </summary>
    public const string MainRemoveGroupItem = nameof(MainRemoveGroupItem);

    /// <summary>
    /// 闪烁任务栏
    /// </summary>
    public const string FlashWindow = nameof(FlashWindow);


}
#endregion


#region 通用通知Token
/// <summary>
/// 通用通知Token (包括Xmpp通知Token和全局UI刷新)
/// </summary>
public static class CommonNotifications
{
    /// <summary>
    /// 添加气泡消息到聊天列表
    /// </summary>
    public const string XmppMsgAddTable = nameof(XmppMsgAddTable);

    /// <summary>
    /// 收到Xmpp消息时
    /// </summary>
    public const string XmppMsgRecived = nameof(XmppMsgRecived);

    /// <summary>
    /// 收到Xmpp消息回执时
    /// </summary>
    public const string XmppMsgReceipt = nameof(XmppMsgReceipt);

    /// <summary>
    /// 更新群组成员昵称
    /// </summary>
    public const string UpdateGroupMemberNickname = nameof(UpdateGroupMemberNickname);

    /// <summary>
    /// 更新我的详情
    /// </summary>
    public const string UpdateMyAccountDetail = nameof(UpdateMyAccountDetail);

    /// <summary>
    /// 群聊创建成功
    /// </summary>
    public const string CreateNewGroupFinished = nameof(CreateNewGroupFinished);

    /// <summary>
    /// 更新群聊成员人数
    /// </summary>
    public const string AddGroupMemberSize = nameof(AddGroupMemberSize);

    /// <summary>
    /// 移除群组成员
    /// 参数为Dictionary<string，List<DataofMember>>键为Jid
    /// </summary>
    public const string RemoveGroupMember = nameof(RemoveGroupMember);

    /// <summary>
    /// 音频聊天请求
    /// </summary>
    public const string AudioChatRequest = nameof(RemoveGroupMember);

    /// <summary>
    /// 视频聊天请求
    /// </summary>
    public const string VideoChatRequest = nameof(VideoChatRequest);


}
#endregion

#region 消息气泡列表通知Token
/// <summary>
/// 消息气泡列表通知Token
/// </summary>
public static class ChatBubblesNotifications
{

    /// <summary>
    /// 批量显示消息气泡(一般用于<see cref="ChatBubbleListViewModel"/>批量显示消息气泡)
    /// </summary>
    public const string ShowBubbleList = nameof(ShowBubbleList);

    /// <summary>
    /// 批量显示消息气泡(一般用于<see cref="ChatBubbleListViewModel"/>单个显示消息气泡)
    /// </summary>
    public const string ShowSingleBubble = nameof(ShowSingleBubble);

    /// <summary>
    /// 气泡撤回消息通知Token
    /// </summary>
    public const string WithDrawSingleMessage = nameof(WithDrawSingleMessage);

    /// <summary>
    /// 气泡撤回消息通知Token
    /// </summary>
    public const string DeleteMessage = nameof(DeleteMessage);

    //可以在下面添加自己以后还要用到的消息
    

}
#endregion

#region 好友详情通知Token
/// <summary>
/// 好友详情通知Token
/// </summary>
public static class UserDetailNotifications
{
    /// <summary>
    /// 显示用户详情,用于通知<see cref="UserDetailViewModel"/>中
    /// </summary>
    public const string ShowUserDetial = nameof(ShowUserDetial);

    /// <summary>
    /// 显示自己详情
    /// </summary>
    public const string ShowMyDetial = nameof(ShowMyDetial);

    /// <summary>
    /// 更新用户详情，用于通知<see cref="UserDetailViewModel"/>中
    /// </summary>
    public const string UpdateUserDetail = nameof(UpdateUserDetail);


}
#endregion

#region 好友验证列表通知Token
/// <summary>
/// 好友验证列表通知Token
/// </summary>
public static class VerifyFriendLIstToken
{
    /// <summary>
    /// 显示用户详情,用于通知<see cref="UserVerifyListViewModel"/>中
    /// </summary>
    public const string DeleteVerifyItem = nameof(DeleteVerifyItem);


}
#endregion
