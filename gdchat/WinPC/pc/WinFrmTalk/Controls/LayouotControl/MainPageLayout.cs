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
        /// �����ڶ���
        /// </summary>
        public FrmMain MainForm { get; set; }

        /// <summary>
        /// �ж���ʾ��ҳ
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

                        if (FriendInfo.Friend.UserId == "10001")//������֤
                        {

                            UserVerifyPage.Visible = true;
                            BlockPage.Visible = false;
                            FriendInfo.Visible = false;
                        }
                        else if (FriendInfo.Friend.UserId == "9999")//������
                        {
                            BlockPage.Visible = true;
                            UserVerifyPage.Visible = false;
                            FriendInfo.Visible = false;
                        }
                        else//����
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
                        BlockPage.LoadData();//��ʾ������
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

        #region �����¼�
        private void MainPageLayout_Load(object sender, System.EventArgs e)
        {
            sendMsgPanel.Visible = true;
            sendMsgPanel.SetChooseFriend(new Friend());     //����û��ѡ���������ʱ��ȴ�յ�֪ͨ���·�������
            sendMsgPanel.Visible = false;
            this.FriendInfo.SendAction = SendFriendMessage;//���ú��ѷ��Ͱ�ť����
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
                groupInfo.GroupInfo = new Friend();//�����Ҳ�Ⱥ���������
            }

            if (IsChatFriend(msg.ChatJid))
            {
                //�����Ҳ���Ϣ����ҳ��
                sendMsgPanel.SetChooseFriend(null);
                sendMsgPanel.Visible = false;
            }
        }

        private void SendGroupMessage(Friend group)
        {
            MainForm.SendMessageToFriend(group.Clone());
        }

        #region ������Ϣ
        private void SendFriendMessage(Friend friend)
        {
            MainForm.SendMessageToFriend(friend.Clone());
        }
        #endregion

        #region �����������
        /// <summary>
        /// �����������
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

        #region ������ʾ����
        /// <summary>
        /// ������ʾ����(������ʾ���������ٴӽӿڻ�ȡ��ˢ������)
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


            if (FriendInfo.Friend.UserId == Friend.ID_NEW_FRIEND)//������֤
            {
                FriendInfo.Visible = false;
                BlockPage.Visible = false;
                UserVerifyPage.Visible = true;
                UserVerifyPage.LoadData();
            }
            else if (FriendInfo.Friend.UserId == Friend.ID_BAN_LIST)//������
            {
                FriendInfo.Visible = false;
                BlockPage.Visible = true;
                UserVerifyPage.Visible = false;
            }
            else//����
            {
                FriendInfo.Visible = true;
                BlockPage.Visible = false;
                UserVerifyPage.Visible = false;
            }
        }
        #endregion


        #region ������ʾ����
        /// <summary>
        /// ������ʾ����(������ʾ���������ٴӽӿڻ�ȡ��ˢ������)
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


        #region ��ʾȺ����
        /// <summary>
        /// ��ʾȺ����
        /// </summary>
        /// <param name="item">Ⱥ����</param>
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

        // �ж��������Ҳ��Ƿ����������
        public bool IsNullChatFriend()
        {

            if (sendMsgPanel.ChooseTarget == null || string.IsNullOrEmpty(sendMsgPanel.ChooseTarget.UserId))
            {
                return true;
            }

            return false;
        }

        // �ж��������Ҳ���������Ƿ��� userid
        public bool IsChatFriend(string userid)
        {
            if (!IsNullChatFriend() && sendMsgPanel.ChooseTarget.UserId.Equals(userid))
            {
                return true;
            }

            return false;
        }

        // �Ƿ���ʾ��ǰ������Ϣ���
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

        // �Ƿ���ʾ��ǰȺ����Ϣ���
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
                    if (Friend.ID_NEW_FRIEND.Equals(userid))//������֤
                    {
                        UserVerifyPage.Refresh();
                    }
                    else if (Friend.ID_BAN_LIST.Equals(userid))//������
                    {
                        BlockPage.Refresh();
                    }
                    else//����
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
