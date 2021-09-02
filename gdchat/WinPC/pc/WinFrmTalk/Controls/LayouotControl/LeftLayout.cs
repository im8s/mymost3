using agsXMPP;
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.Properties;
using WinFrmTalk.socket;

namespace WinFrmTalk
{
    public partial class LeftLayout : UserControl
    {

        #region Private Properties
        private MainTabIndex mCurrSelect;
        private MainTabIndex mLastSelect = MainTabIndex.RecentListPage;
        private int totalChatUnreadCount;
        private int totalContactUnreadCount;
        #endregion

        #region Const
        /// <summary>
        /// 显示固定总聊天消息未读数量
        /// </summary>
        public const string NOTIFY_CHAT_UNREADCOUNT = nameof(NOTIFY_CHAT_UNREADCOUNT);
        /// <summary>
        /// 显示固定总联系人未读数量
        /// </summary>
        public const string NOTIFY_CONTACT_UNREADCOUNT = nameof(NOTIFY_CONTACT_UNREADCOUNT);
        #endregion

        /// <summary>
        /// 主窗口对象
        /// </summary>
        public FrmMain MainForm { get; set; }

        /// <summary>
        /// 设置选中的对象
        /// </summary>
        public MainTabIndex SelectIndex
        {
            get { return mCurrSelect; }
            set
            {
                mCurrSelect = value;
                ChangeSelect(SelectIndex);
            }
        }


        private void ChangeSelect(MainTabIndex index)
        {
            if (index == mLastSelect)
            {
                return;
            }

            // 选中当前项
            ChangeViewSelect(index, true);
            // 取消选中上一个项
            ChangeViewSelect(mLastSelect, false);
            mLastSelect = index;
        }


        private void ChangeViewSelect(MainTabIndex index, bool isPress)
        {
            switch (index)
            {
                case MainTabIndex.RecentListPage:
                    //btnRecent.BackgroundImage = isPress ? Resources.ic_recent_press : Resources.ic_recent;//绿色
                    DisplayChatUnReadCount(totalChatUnreadCount);//重绘消息未读角标
                    break;
                case MainTabIndex.FriendsPage:
                    //btnContacts.BackgroundImage = isPress ? Resources.ic_contact_press : Resources.ic_contact;//绿色
                    DisplayContactUnReadCount(totalContactUnreadCount);//重绘联系人未读角标
                    break;
                case MainTabIndex.GroupPage:
                    btnGroup.BackgroundImage = isPress ? Resources.ic_group_press : Resources.ic_group;//绿色
                    break;
                case MainTabIndex.Colleague:
                    btnColleague.BackgroundImage = isPress ? Resources.ic_colleage_press : Resources.ic_colleage;
                    break;
                case MainTabIndex.Collect:
                    btnCollect.BackgroundImage = isPress ? Resources.ic_collect_press : Resources.ic_collect;
                    break;
                case MainTabIndex.TagPage:
                    btnTags.BackgroundImage = isPress ? Resources.ic_Tags_press : Resources.ic_Tags;
                    break;
            }
        }


        #region Constructor
        public LeftLayout()
        {
            InitializeComponent();
            Control.CheckForIllegalCrossThreadCalls = false;
        }
        #endregion

        #region 初始化字体图标
        /// <summary>
        /// 初始化字体图标
        /// </summary>
        private void InitialIconFont()
        {
            //btnRecent.Font = new Font(Program.ApplicationFontCollection.Families.Last(), 20f);
            //btnContacts.Font = new Font(Program.ApplicationFontCollection.Families.Last(), 20f);
            //btnGroup.Font = new Font(Program.ApplicationFontCollection.Families.Last(), 20f);
            btnSettings.Font = new Font(Program.ApplicationFontCollection.Families.Last(), 20f);
        }
        #endregion

        #region 加载事件

        private void LeftLayout_Load(object sender, EventArgs e)
        {
            try
            {
                InitialIconFont();//初始化字体图标
                InitialMyDetail();//设置用户信息
                RegisterMessenger();
            }
            catch (Exception ex)
            {
                LogUtils.Log("LeftLayout_Load" + ex.Message);
            }
        }
        #endregion

        #region 注册通知
        private void RegisterMessenger()
        {
            #region 最近消息未读角标
            Messenger.Default.Register<int>(this, LeftLayout.NOTIFY_CHAT_UNREADCOUNT, (count) =>
            {
                DisplayChatUnReadCount(count);
            });

            #endregion


            #region 朋友列表的未读角标
            Messenger.Default.Register<int>(this, LeftLayout.NOTIFY_CONTACT_UNREADCOUNT, (count) =>
            {
                DisplayContactUnReadCount(count);
            });

            #endregion

            Messenger.Default.Register<SocketConnectionState>(this, MessageActions.XMPP_UPDATE_STATE, (count) =>
            {
                ChangeXmppState(count);
            });

            #region 刷新头像
            Messenger.Default.Register<string>(this, MessageActions.UPDATE_HEAD, (userId) =>
             {
                 if (Applicate.MyAccount.userId.Equals(userId))
                 {
                     InitialMyDetail();
                 }
             });
            #endregion



        }
        #endregion

        #region 显示联系人未读角标
        private void DisplayContactUnReadCount(int unreadcount)
        {
            totalContactUnreadCount = unreadcount;
            #region 恢复初始图标
            if (SelectIndex == MainTabIndex.FriendsPage)
            {
                btnContacts.BackgroundImage = Resources.ic_contact_press;
            }
            else
            {
                btnContacts.BackgroundImage = Resources.ic_contact;
            }
            #endregion
            if (unreadcount <= 0)
                return;

            //绘制红点
            Bitmap headImage = new Bitmap(btnContacts.BackgroundImage);
            string text = unreadcount < 100 ? unreadcount.ToString() : "99+";
            btnContacts.BackgroundImage = EQControlManager.DrawPointToCrl(headImage, text, new Point(32, 4));
        }
        #endregion

        #region 显示聊天时的未读总数
        /// <summary>
        /// 显示聊天时的未读总数
        /// </summary>
        /// <param name="unreadcount"></param>
        /// 
        bool isChatParess;
        public void DisplayChatUnReadCount(int unreadcount)
        {

            if (isChatParess == (SelectIndex == MainTabIndex.RecentListPage))
            {
                if (unreadcount >= totalChatUnreadCount && totalChatUnreadCount >= 100)
                {
                    return;
                }
            }

            isChatParess = SelectIndex == MainTabIndex.RecentListPage;
            totalChatUnreadCount = unreadcount;

            #region 恢复初始图标
            if (isChatParess)
            {
                btnRecent.BackgroundImage = Resources.ic_recent_press;//绿色
            }
            else
            {
                btnRecent.BackgroundImage = Resources.ic_recent;//灰色
            }
            #endregion



            if (unreadcount <= 0)
            {
                return;
            }


            Image bitmap = btnRecent.BackgroundImage;
            string text = unreadcount < 100 ? unreadcount.ToString() : "99+";
            btnRecent.BackgroundImage = EQControlManager.DrawPointToCrl(bitmap, text, new Point(32, 4));
        }
        #endregion

        #region 设置主窗口自己的信息
        /// <summary>
        /// 设置主窗口自己的信息
        /// </summary>
        private void InitialMyDetail()
        {
            pic_myIcon.isDrawRound = true;
            ImageLoader.Instance.DisplayAvatar(Applicate.MyAccount.userId, pic_myIcon);//设置头像

        }
        #endregion

        #region 设置点击事件
        /// <summary>
        /// 设置点击事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Settings_Click(object sender, EventArgs e)
        {
            if (e is MouseEventArgs me)
                if (me.Button != MouseButtons.Left)
                    return;

            var tmpset = Applicate.GetWindow<FrmSet>();
            var parent = Applicate.GetWindow<FrmMain>();
            if (tmpset == null)
            {
                var set = new FrmSet();
                set.Location = new Point(parent.Location.X + (parent.Width - set.Width) / 2, parent.Location.Y + (parent.Height - set.Height) / 2);//居中
                set.Show();
            }
            else
            {
                tmpset.Activate();
            }
        }
        #endregion

        #region 最近消息点击
        private void btnRecent_Click(object sender, EventArgs e)
        {
            if (e is MouseEventArgs me)
                if (me.Button != MouseButtons.Left)
                    return;

            Console.WriteLine("btnRecent_Click");
            SelectIndex = MainTabIndex.RecentListPage;

            MainForm.SelectIndex = MainTabIndex.RecentListPage;
        }
        #endregion

        #region 最近消息双击
        private void OnDoubleClickRecent(object sender, EventArgs e)
        {
            Console.WriteLine("OnDoubleClickRecent");
            var recent = MainForm.GetRecentList();
            var uncount = recent.NextUnpoint();
            if (totalChatUnreadCount != uncount)
            {
                DisplayChatUnReadCount(uncount);//重绘消息未读角标
            }
        }
        #endregion

        #region 联系人点击
        private void btnContacts_Click(object sender, EventArgs e)
        {
            if (e is MouseEventArgs me)
                if (me.Button != MouseButtons.Left)
                    return;

            SelectIndex = MainTabIndex.FriendsPage;
            MainForm.SelectIndex = MainTabIndex.FriendsPage;
        }
        #endregion

        #region 群组点击
        private void btnGroup_Click(object sender, EventArgs e)
        {
            if (e is MouseEventArgs me)
                if (me.Button != MouseButtons.Left)
                    return;

            SelectIndex = MainTabIndex.GroupPage;
            MainForm.SelectIndex = MainTabIndex.GroupPage;
        }
        #endregion

        #region 我的同事点击
        private void BtnCon_Click(object sender, EventArgs e)
        {
            if (e is MouseEventArgs me)
                if (me.Button != MouseButtons.Left)
                    return;

            SelectIndex = MainTabIndex.Colleague;
            MainForm.SelectIndex = MainTabIndex.Colleague;
            MainForm.ColleagueList.httpData();//刷新收藏页面
        }
        #endregion

        #region 标签显示
        private void BtnTags_Click(object sender, EventArgs e)
        {
            if (e is MouseEventArgs me)
                if (me.Button != MouseButtons.Left)
                    return;

            SelectIndex = MainTabIndex.TagPage;
            MainForm.SelectIndex = MainTabIndex.TagPage;

            MainForm.UserTagPage.DataLableLoad();
        }
        #endregion

        #region 收藏点击
        private void BtnCollect_Click(object sender, EventArgs e)
        {
            if (e is MouseEventArgs me)
                if (me.Button != MouseButtons.Left)
                    return;

            SelectIndex = MainTabIndex.Collect;
            MainForm.SelectIndex = MainTabIndex.Collect;
            MainForm.MyCollection.WholeData();//刷新收藏页面
        }
        #endregion

        #region 头像点击
        private void pic_myIcon_Click(object sender, EventArgs e)
        {
            if (e is MouseEventArgs me)
                if (me.Button != MouseButtons.Left)
                    return;

            FrmFriendsBasic detial = new FrmFriendsBasic();
            detial.ShowUserInfoById(Applicate.MyAccount.userId);//显示个人详情
        }
        #endregion

        public Color Statebrg = Color.Gray;

        private void ChangeXmppState(SocketConnectionState state)
        {
            //Console.WriteLine("ChangeXmppState" + state);
            switch (state)
            {
                case SocketConnectionState.Authenticated:
                    Statebrg = ColorTranslator.FromHtml("#0AD007"); // 变绿色 - 在线
                    this.Refresh();
                    break;
                case SocketConnectionState.Disconnected:
                    Statebrg = ColorTranslator.FromHtml("#BBBBBB"); // 变灰色 - 离线
                    this.Refresh();
                    break;

                default:
                    Statebrg = Color.Yellow;// 变黄色 - 连接中
                    this.Refresh();
                    break;
            }
        }

        private void pic_myIcon_Paint(object sender, PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.CompositingQuality = CompositingQuality.HighQuality;
            g.DrawEllipse(new Pen(Statebrg), new Rectangle(pic_myIcon.Width - 14, pic_myIcon.Height - 14, 12, 12));
            Brush b = new SolidBrush(Statebrg);
            g.FillEllipse(b, new Rectangle(pic_myIcon.Width - 14, pic_myIcon.Height - 14, 12, 12));
        }

    }
}
