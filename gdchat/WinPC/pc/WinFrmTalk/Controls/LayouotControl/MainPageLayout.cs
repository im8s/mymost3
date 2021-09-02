using System;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls.LayouotControl
{
    public partial class MainPageLayout : UserControl
    {

        #region Private Member
        private MainTabIndex index;
        #endregion

        #region PublicMember
        /// <summary>
        /// 主窗口对象
        /// </summary>
        public FrmMain MainForm { get; set; }

        /// <summary>
        /// 判断显示的页
        /// </summary>
        public MainTabIndex SelectedIndex
        {
            get { return index; }
            set
            {
                index = value;

                switch (index)
                {
                    case MainTabIndex.RecentListPage:

                        groupInfo.Visible = false;
                        FriendInfo.Visible = false;
                        UserVerifyPage.Visible = false;
                        BlockPage.Visible = false;
                        sendMsgPanel.Visible = !IsNullChatFriend();

                        break;
                    case MainTabIndex.FriendsPage:

                        groupInfo.Visible = false;
                        sendMsgPanel.Visible = false;

                        if (FriendInfo.Friend == null || string.IsNullOrEmpty(FriendInfo.Friend.UserId))
                        {
                            UserVerifyPage.Visible = false;
                            BlockPage.Visible = false;
                            FriendInfo.Visible = false;

                            return;
                        }

                        if (FriendInfo.Friend.UserId == "10001")//好友验证
                        {

                            UserVerifyPage.Visible = true;
                            BlockPage.Visible = false;
                            FriendInfo.Visible = false;
                        }
                        else if (FriendInfo.Friend.UserId == "9999")//黑名单
                        {
                            BlockPage.Visible = true;
                            UserVerifyPage.Visible = false;
                            FriendInfo.Visible = false;
                        }
                        else//好友
                        {
                            FriendInfo.Visible = true;
                            UserVerifyPage.Visible = false;
                            BlockPage.Visible = false;
                        }

                        break;
                    case MainTabIndex.GroupPage:

                        FriendInfo.Visible = false;
                        sendMsgPanel.Visible = false;
                        UserVerifyPage.Visible = false;
                        BlockPage.Visible = false;

                        if (groupInfo.GroupInfo != null && !string.IsNullOrEmpty(groupInfo.GroupInfo.UserId))
                        {
                            groupInfo.Visible = true;
                        }
                        else
                        {
                            groupInfo.Visible = false;
                        }

                        break;
                    case MainTabIndex.FriendVerifyPage:
                        groupInfo.Visible = false;
                        FriendInfo.Visible = false;
                        sendMsgPanel.Visible = false;
                        BlockPage.Visible = false;
                        UserVerifyPage.Visible = true;
                        break;
                    case MainTabIndex.BlockPage:
                        groupInfo.Visible = false;
                        FriendInfo.Visible = false;
                        sendMsgPanel.Visible = false;
                        UserVerifyPage.Visible = false;
                        BlockPage.LoadData();//显示黑名单
                        BlockPage.Visible = true;
                        break;

                    case MainTabIndex.Collect:
                        groupInfo.Visible = false;
                        FriendInfo.Visible = false;
                        sendMsgPanel.Visible = false;
                        UserVerifyPage.Visible = false;
                        BlockPage.Visible = false;
                        break;
                    case MainTabIndex.RecentListPage_null:
                        groupInfo.Visible = false;
                        FriendInfo.Visible = false;
                        sendMsgPanel.Visible = false;
                        UserVerifyPage.Visible = false;
                        BlockPage.Visible = false;
                        sendMsgPanel.SetChooseFriend(new Friend());
                        break;
                    default:
                        break;
                }
            }
        }
        #endregion

        #region Contructor
        /// <summary>
        /// Contructor
        /// </summary>
        public MainPageLayout()
        {
            InitializeComponent();
        }
        #endregion

        #region 加载事件
        private void MainPageLayout_Load(object sender, System.EventArgs e)
        {
            sendMsgPanel.Visible = true;
            sendMsgPanel.SetChooseFriend(new Friend());     //避免没有选择聊天对象时，却收到通知导致发生错误
            sendMsgPanel.Visible = false;
            this.FriendInfo.SendAction = SendFriendMessage;//设置好友发送按钮动作
            this.groupInfo.SendAction = SendGroupMessage;//
            RegisterMessenger();
        }
        #endregion

        private void RegisterMessenger()
        {

            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_ROOM_DELETE, XmppDeleteGroup);
        }

        private void XmppDeleteGroup(MessageObject msg)
        {
            if (groupInfo.GroupInfo != null && groupInfo.GroupInfo.UserId == msg.ChatJid)
            {
                groupInfo.GroupInfo = new Friend();//重置右侧群组详情面板
            }

            if (IsChatFriend(msg.ChatJid))
            {
                //重置右侧消息气泡页面
                sendMsgPanel.SetChooseFriend(null);
                sendMsgPanel.Visible = false;
            }
        }

        private void SendGroupMessage(Friend group)
        {
            MainForm.SendMessageToFriend(group.Clone());
        }

        #region 发送消息
        private void SendFriendMessage(Friend friend)
        {
            MainForm.SendMessageToFriend(friend.Clone());
        }
        #endregion

        #region 设置聊天对象
        /// <summary>
        /// 设置聊天对象
        /// </summary>
        /// <param name="friend"></param>
        /// 
        public void SetChoiceFriend(Friend session, int readNum = 0)
        {



            string messageId = "";
            if (readNum > 0 && session != null && !string.IsNullOrEmpty(session.UserId))
            {
                MessageObject msg = new MessageObject() { FromId = session.UserId }.GetMsgByRowIndex(readNum + 1);
                messageId = msg.messageId;
            }

            sendMsgPanel.SetChooseFriend(session, readNum, messageId);
            SelectedIndex = MainTabIndex.RecentListPage;
            MainForm.SelectIndex = MainTabIndex.RecentListPage;
        }
        #endregion

        #region 设置显示好友
        /// <summary>
        /// 设置显示好友(需先显示本地数据再从接口获取并刷新数据)
        /// </summary>
        /// <param name="friend"></param>
        public void SelectFriend(Friend friend)
        {
            FriendInfo.DisplayFriend(friend);

            if (friend == null)
            {
                FriendInfo.Visible = false;
                BlockPage.Visible = false;
                UserVerifyPage.Visible = false;

                return;
            }


            if (FriendInfo.Friend.UserId == Friend.ID_NEW_FRIEND)//好友验证
            {
                FriendInfo.Visible = false;
                BlockPage.Visible = false;
                UserVerifyPage.Visible = true;
                UserVerifyPage.LoadData();
            }
            else if (FriendInfo.Friend.UserId == Friend.ID_BAN_LIST)//黑名单
            {
                FriendInfo.Visible = false;
                BlockPage.Visible = true;
                UserVerifyPage.Visible = false;
            }
            else//好友
            {
                FriendInfo.Visible = true;
                BlockPage.Visible = false;
                UserVerifyPage.Visible = false;
            }
        }
        #endregion


        #region 设置显示聊天
        /// <summary>
        /// 设置显示好友(需先显示本地数据再从接口获取并刷新数据)
        /// </summary>
        /// <param name="friend"></param>
        public void SelectChat(Friend friend)
        {
            sendMsgPanel.SetChooseFriend(friend);

            if (friend == null || string.IsNullOrEmpty(friend.UserId))
            {
                sendMsgPanel.Visible = false;
            }
            else
            {
                sendMsgPanel.Visible = true;
            }
        }
        #endregion


        #region 显示群详情
        /// <summary>
        /// 显示群详情
        /// </summary>
        /// <param name="item">群详情</param>
        public void SelectGroup(Friend item)
        {
            groupInfo.DisplayGroup(item);
        }


        public void ChangeGroupName(Friend friend)
        {
            if (groupInfo.GroupInfo != null && friend.UserId.Equals(groupInfo.GroupInfo.UserId))
            {
                groupInfo.ChangeGroupName(friend.NickName);
            }
        }

        #endregion

        // 判断主窗口右侧是否有聊天对象
        public bool IsNullChatFriend()
        {

            if (sendMsgPanel.ChooseTarget == null || string.IsNullOrEmpty(sendMsgPanel.ChooseTarget.UserId))
            {
                return true;
            }

            return false;
        }

        // 判断主窗口右侧聊天对象是否是 userid
        public bool IsChatFriend(string userid)
        {
            if (!IsNullChatFriend() && sendMsgPanel.ChooseTarget.UserId.Equals(userid))
            {
                return true;
            }

            return false;
        }

        // 是否显示当前朋友信息面板
        public bool IsCurrtFirend(string userId)
        {

            if (FriendInfo.Friend != null && FriendInfo.Friend.UserId != null)
            {
                if (FriendInfo.Friend.UserId.Equals(userId))
                {
                    return true;
                }
            }

            return false;
        }

        // 是否显示当前群组信息面板
        public bool IsCurrtGroup(string roomJid)
        {

            if (groupInfo.GroupInfo != null && groupInfo.GroupInfo.UserId != null)
            {
                if (groupInfo.GroupInfo.UserId.Equals(roomJid))
                {
                    return true;
                }
            }

            return false;
        }


        public void RefreshView()
        {
            switch (index)
            {
                case MainTabIndex.RecentListPage:
                    if (sendMsgPanel.Visible)
                    {
                        sendMsgPanel.Refresh();
                    }
                    break;
                case MainTabIndex.FriendsPage:

                    if (FriendInfo.Friend == null || string.IsNullOrEmpty(FriendInfo.Friend.UserId))
                    {
                        return;
                    }
                    var userid = FriendInfo.Friend.UserId;
                    if (Friend.ID_NEW_FRIEND.Equals(userid))//好友验证
                    {
                        UserVerifyPage.Refresh();
                    }
                    else if (Friend.ID_BAN_LIST.Equals(userid))//黑名单
                    {
                        BlockPage.Refresh();
                    }
                    else//好友
                    {
                        FriendInfo.Refresh();
                    }
                    break;
                case MainTabIndex.GroupPage:
                    if (groupInfo.GroupInfo != null && !string.IsNullOrEmpty(groupInfo.GroupInfo.UserId))
                    {
                        groupInfo.Refresh();
                    }
                    break;
                case MainTabIndex.FriendVerifyPage:
                    UserVerifyPage.Refresh();
                    break;
                case MainTabIndex.BlockPage:
                    BlockPage.Refresh();
                    break;
                case MainTabIndex.Collect:
                case MainTabIndex.RecentListPage_null:
                default:
                    break;
            }
        }
    }
}
