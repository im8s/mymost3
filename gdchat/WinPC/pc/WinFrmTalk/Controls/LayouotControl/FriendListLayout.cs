using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Threading;
using System.Timers;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;
using WinFrmTalk.View.list;

namespace WinFrmTalk
{
    // 主界面好友列表
    public partial class FriendListLayout : UserControl
    {

        #region Member
        private delegate void ProcessVerifyMsg(MessageObject obj);
        public delegate void ProcesMainFriend(Friend friend);
        private delegate void ProcesMainString(string userid);

        /// <summary>
        /// 当前选中的项目
        /// </summary>
        public FriendItem SelectedItem { get; set; }

        /// <summary>
        /// 主窗口对象
        /// </summary>
        public FrmMain MainForm { get; set; }

        private FriendAdapter mAdapter;
        #endregion

        #region 常量
        /// <summary>
        /// 发送消息Token
        /// </summary>
        public const string SEND_FRIEND_CARD = nameof(SEND_FRIEND_CARD);

        /// <summary>
        /// 查看详情Token
        /// </summary>
        public const string SHOW_DETAIL = nameof(SHOW_DETAIL);

        /// <summary>
        /// 拉黑Token 
        /// </summary>
        public const string BLOCK_FRIENDITEM = nameof(BLOCK_FRIENDITEM);


        /// <summary>
        /// 添加已存在的好友至UI列表中 
        /// <para>(调用时将已通过验证(不管是对方通过还是自己通过验证)的好友添加至列表Token)</para>
        /// </summary>
        public const string ADD_EXISTS_FRIEND = nameof(ADD_EXISTS_FRIEND);

        /// <summary>
        /// 删除好友Token
        /// </summary>
        public const string DELETE_FRIENDITEM = nameof(DELETE_FRIENDITEM);

        /// <summary>
        /// 通知好友列表未读数量显示就是新的朋友 + 黑名单
        /// </summary>
        public const string NOTIFY_FRIENDLIST_UNREAD_COUNT = nameof(NOTIFY_FRIENDLIST_UNREAD_COUNT);

        #endregion

        #region Contructor
        public FriendListLayout()
        {
            InitializeComponent();

            mAdapter = new FriendAdapter();

            RegisterMessenger();


            xListView.HeaderRefresh += XListView_HeaderRefresh;
            xListView.FooterRefresh += XListView_FooterRefresh;
        }


        bool isLock = false;
        bool limitPage = false;
        int pageindex = 0;

        private void XListView_FooterRefresh()
        {
            Console.WriteLine("XListView_FooterRefresh" + isLock);

            if (UIUtils.IsNull(txtSearch.Text) && limitPage)
            {
                if (!isLock)
                {
                    isLock = true;
                    pageindex++;
                    LoadLimitPageData();
                }
            }
        }

        private void XListView_HeaderRefresh()
        {
            Console.WriteLine("XListView_HeaderRefresh" + isLock);
            if (UIUtils.IsNull(txtSearch.Text) && limitPage)
            {
                if (!isLock && pageindex > 0)
                {
                    isLock = true;
                    pageindex--;
                    LoadLimitPageData();
                }

            }
        }
        #endregion

        #region 加载事件
        private void MainListLayout_Load(object sender, EventArgs e)
        {
            this.txtSearch.GotFocus += SearchFocused;
            this.txtSearch.LostFocus += SearchUnFocused;
        }


        #endregion

        #region 注册Messenger 
        private void RegisterMessenger()
        {
            Messenger.Default.Register<bool>(this, FriendListLayout.SHOW_DETAIL, (_) =>
            {
                var friend = new FrmFriendsBasic();
                friend.ShowUserInfoById(SelectedItem.FriendData.UserId);
                friend.Show();
            });

            Messenger.Default.Register<bool>(this, FriendListLayout.SEND_FRIEND_CARD, (_) =>
            {
                var friend = new FrmFriendSelect();
                friend.LoadFriendsData(1);
                friend.AddConfrmListener((UserFriends) =>
                {
                    foreach (var userFriend in UserFriends)
                    {
                        if (userFriend.Value.IsGroup == 1)
                        {
                            if (ShiKuManager.SendRoomMsgVerify(userFriend.Value))
                            {
                                HttpUtils.Instance.ShowTip(userFriend.Value.NickName + " 禁言状态,不能发名片");
                                continue;
                            }

                            if (userFriend.Value.AllowSendCard == 0)
                            {
                                HttpUtils.Instance.ShowTip(userFriend.Value.NickName + " 不允许群成员私聊,不能发名片");
                                continue;
                            }
                        }

                        MessageObject msg = ShiKuManager.SendCardMessage(userFriend.Value, SelectedItem.FriendData);
                        Messenger.Default.Send(msg, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                    }
                });

            });

            Messenger.Default.Register<bool>(this, FriendListLayout.BLOCK_FRIENDITEM, BlockFriend);
            Messenger.Default.Register<bool>(this, FriendListLayout.DELETE_FRIENDITEM, DeleteFriendItem);

            Messenger.Default.Register<Friend>(this, MessageActions.UPDATE_FRIEND_REMARKS, UpdateRemarks);

            Messenger.Default.Register<string>(this, FriendListLayout.ADD_EXISTS_FRIEND, CreateFriendItem);
            Messenger.Default.Register<Friend>(this, MessageActions.ADD_BLACKLIST, RemoveFriendItem);
            Messenger.Default.Register<Friend>(this, MessageActions.DELETE_FRIEND, RemoveFriendItem);

            Messenger.Default.Register<string>(this, MessageActions.UPDATE_HEAD, RefreshFriendHead);

            Messenger.Default.Register<string>(this, FriendListLayout.NOTIFY_FRIENDLIST_UNREAD_COUNT, RefreshVerifyUnRead);
        }
        #endregion

        #region 刷新朋友头像
        private void RefreshFriendHead(string userId)
        {

            if (Thread.CurrentThread.IsBackground)
            {
                var main = new ProcesMainString(RefreshFriendHead);
                Invoke(main, userId);
                return;
            }

            int index = mAdapter.GetIndexByFriendId(userId);
            if (xListView.DataCreated(index))
            {
                FriendItem item = xListView.GetItemControl(index) as FriendItem;
                item.LoadHeadImage();
            }
        }
        #endregion

        #region 刷新的朋友&黑名单未读数量
        private void RefreshVerifyUnRead(string userId)
        {
            var temp = new Friend() { UserId = userId }.GetByUserId();
            temp.MsgNum++;
            temp.UpdateRedNum(temp.MsgNum);

            // 获取新的朋友未读数量
            int count = new Friend() { UserId = Friend.ID_NEW_FRIEND }.GetNuRedNum();
            int totalCount = count;

            int index = mAdapter.GetIndexByFriendId(Friend.ID_NEW_FRIEND);
            var verifyitem = GetItemControl(index);
            if (verifyitem != null)
            {
                verifyitem.DrawUnRead(count);
            }

            // 获取给黑名单未读数量
            count = new Friend() { UserId = Friend.ID_BAN_LIST }.GetNuRedNum();
            index = mAdapter.GetIndexByFriendId(Friend.ID_BAN_LIST);
            verifyitem = GetItemControl(index);
            if (verifyitem != null)
            {
                verifyitem.DrawUnRead(count);
            }

            totalCount += count;

            //当前导航栏不为好友
            Messenger.Default.Send(totalCount, LeftLayout.NOTIFY_CONTACT_UNREADCOUNT);
        }
        #endregion

        #region 刷新一个好友的备注
        private void UpdateRemarks(Friend friend)
        {
            // 先找到所在项的索引号
            int index = mAdapter.GetIndexByFriendId(friend.UserId);
            if (index > -1)
            {

                // 判断是否在列表中创建了
                if (xListView.DataCreated(index))
                {
                    // 创建了就去刷新数据
                    FriendItem item = xListView.GetItemControl(index) as FriendItem;
                    item.FriendData = friend;

                    if (friend.IsDismiss != 4)
                    {
                        //根据名称排序
                        int last = GetFriendIndexByName(friend);
                        xListView.MoveItem(index, last);
                        mAdapter.MoveData(index, last);
                    }

                }
                else
                {
                    // 没有创建就去改变数组上的数据
                    Friend data = mAdapter.GetDatas(index);
                    data = friend;
                    if (friend.IsDismiss != 4)
                    {
                        //根据名称排序
                        int last = GetFriendIndexByName(friend);
                        xListView.MoveItem(index, last);
                        mAdapter.MoveData(index, last);
                    }
                }
            }
        }
        #endregion

        #region 添加一个好友到好友列表中
        private void CreateFriendItem(string userId)
        {
            if (Thread.CurrentThread.IsBackground)
            {
                var main = new ProcesMainString(CreateFriendItem);
                Invoke(main, userId);
                return;
            }

            int index = mAdapter.GetIndexByFriendId(userId);
            if (!xListView.DataCreated(index) && UIUtils.IsNull(lastSearchText))
            {
                var friend = new Friend { UserId = userId, IsGroup = 0 }.GetByUserId();//尝试获取好友
                if (friend != null)
                {
                    // 插入到排序位置
                    int insert = GetFriendIndexByName(friend);
                    mAdapter.InsertData(insert, friend);
                    xListView.InsertItem(insert);//插入
                }
            }
        }
        #endregion

        #region 将一个朋友从好友列表中移除
        public void RemoveFriendItem(Friend friend)
        {
            if (Thread.CurrentThread.IsBackground)
            {
                var main = new ProcesMainFriend(RemoveFriendItem);
                Invoke(main, friend);
                return;
            }


            int index = mAdapter.GetIndexByFriendId(friend.UserId);

            if (index > -1)
            {
                // 从列表中删除数据
                xListView.RemoveItem(index);
                mAdapter.RemoveData(index);

                if (MainForm.mainPageLayout.IsCurrtFirend(friend.UserId))
                {
                    MainForm.mainPageLayout.SelectFriend(null);
                }

            }

            //var verifyitem = xListView.GetFriendItemByFriend(friend.userId);
            //if (verifyitem != null && UIUtils.IsNull(lastSearchText))
            //{

            //}
        }
        #endregion

        #region 右键菜单-加入黑名单
        private void BlockFriend(bool para)
        {
            var friend = SelectedItem.FriendData.Clone();//获取选中好友
            if (MessageBox.Show("是否将 " + friend.NickName + " 加入黑名单？", "加入黑名单", MessageBoxButtons.OKCancel) == DialogResult.OK)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + ApplicateConst.BanFriend)
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("toUserId", SelectedItem.FriendData.UserId)
                    .Build().Execute((isSuccessed, result) =>
                    {
                        if (isSuccessed)
                        {
                            ShiKuManager.SendBlockfriend(friend);//发送拉黑好友推送
                        }
                    });
            }
        }
        #endregion

        #region 右键菜单-删除好友
        private void DeleteFriendItem(bool obj)
        {
            var friend = SelectedItem.FriendData.Clone();//获取选中好友
            if (MessageBox.Show("是否删除 " + friend.NickName + " ？", "删除联系人", MessageBoxButtons.OKCancel) == DialogResult.OK)
            {
                // 修改禅道#8068
                DeleteLocalFriend(friend);

                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + ApplicateConst.DeleteFriend)
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("toUserId", friend.UserId)
                    .Build().Execute((isSuccessed, result) =>
                    {
                        if (isSuccessed)
                        {
                            ShiKuManager.SendDelFriendMsg(friend);//发送删除好友推送
                        }
                    });
            }
        }

        public void DeleteLocalFriend(Friend friend)
        {
            // 通知界面刷新
            Messenger.Default.Send(friend, MessageActions.DELETE_FRIEND);
        }

        #endregion

        #region 加载数据
        public void LoadData()
        {
            LoadFriendsList();
        }
        #endregion

        #region 获取并添加好友到列表

        private void LoadLimitPageData()
        {
            if (pageindex < 0)
            {
                pageindex = 0;
            }

            var friends = new Friend().GetFriendsList();//获取列表
            int start = pageindex * 200;
            limitPage = friends.Count > start;
            if (limitPage)
            {
                int count = Math.Min(friends.Count - start, 200);
                var data = friends.GetRange(start, count);

                mAdapter.BindDatas(data);
                xListView.SetAdapter(mAdapter);
            }

            isLock = false;
        }

        /// <summary>
        /// 获取并添加好友到列表
        /// </summary>
        private void LoadFriendsList(string search = "")
        {
            var load = new LodingUtils { parent = this.xListView, Title = "加载中" };
            load.start();
            List<Friend> friends = null;

            if (string.IsNullOrEmpty(search))
            {
                pageindex = 0;
                friends = new Friend().GetFriendsList();//获取列表
                int start = pageindex * 200;
                limitPage = friends.Count > start;
                if (friends.Count > start)
                {
                    limitPage = true;
                    int count = Math.Min(friends.Count - start, 200);
                    friends = friends.GetRange(start, count);
                }
            }
            else
            {

                friends = new Friend().SearchFriendsByName(search);
                LogUtils.Log("LoadFriendsList  " + search + " , " + friends.Count);
            }


            Application.DoEvents();
            MainForm.SuspendLayout();


            // 加载数据到控件上
            mAdapter.FriendList = this;
            mAdapter.MainForm = MainForm;
            mAdapter.BindDatas(friends);
            xListView.SetAdapter(mAdapter);


            MainForm.ResumeLayout();
            load.stop();
        }
        #endregion

        #region 根据控件获取对应项

        public FriendItem GetItemControl(int index)
        {

            if (xListView.DataCreated(index))
            {
                FriendItem item = xListView.GetItemControl(index) as FriendItem;
                return item;
            }
            else
            {
                return null;
            }
        }

        #endregion

        #region 搜索框获取焦点时
        /// <summary>
        /// 搜索框获取焦点时
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SearchFocused(object sender, EventArgs e)
        {
            //txtSearch.Text = "";
            txtSearch.ForeColor = Color.Black;
            txtSearch.BackColor = Color.White;
        }
        #endregion

        #region 搜索框获取焦点时
        /// <summary>
        /// 搜索框获取焦点时
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SearchUnFocused(object sender, EventArgs e)
        {
            //txtSearch.Text = "搜索...";
            txtSearch.ForeColor = Color.Gray;
            txtSearch.BackColor = Color.FromArgb(219, 217, 217);
        }
        #endregion

        #region 搜索文本改变时
        private string lastSearchText;

        private void SearchTextChanged(object sender, EventArgs e)
        {
            searchTime.Stop();
            // 清空了搜索框
            if (string.IsNullOrEmpty(txtSearch.Text))
            {
                searchTime_Tick(null, null);
            }
            else
            {
                searchTime.Start();
            }
        }


        private void searchTime_Tick(object sender, EventArgs e)
        {
            searchTime.Stop();
            string currText = txtSearch.Text;

            if (string.IsNullOrEmpty(currText) && string.IsNullOrEmpty(lastSearchText))
            {
                LogUtils.Log("SearchTextChanged null");
                return;
            }

            if (string.Equals(lastSearchText, currText))
            {
                LogUtils.Log("SearchTextChanged Equals");
                return;
            }

            // 清空了搜索框
            if (string.IsNullOrEmpty(currText) && !string.IsNullOrEmpty(lastSearchText))
            {
                lastSearchText = currText;
                //tlpFriends.ClearTabel();
                // 恢复原列表
                LoadFriendsList();
                return;
            }

            lastSearchText = currText;
            if (!string.IsNullOrEmpty(currText))
            {
                //tlpFriends.ClearTabel();
                // 加载搜索数据
                LoadFriendsList(currText);
                return;
            }
        }
        #endregion

        #region +号按钮点击事件
        private void btnPlus_Click(object sender, EventArgs e)
        {
            var tmpset = Applicate.GetWindow<FrmFriendQuery>();
            var parent = Applicate.GetWindow<FrmMain>();
            if (tmpset == null)//单例打开好友添加窗口
            {
                var query = new FrmFriendQuery();
                query.Location = new Point(parent.Location.X + (parent.Width - query.Width) / 2, parent.Location.Y + (parent.Height - query.Height) / 2);//居中
                query.Show();
            }
            else
            {
                tmpset.Activate();
            }

        }
        #endregion

        #region 左键和右键选中事件
        public void MouseDownItem(object sender, MouseEventArgs e)
        {

            // 过滤重复点击项
            FriendItem temp = sender as FriendItem;
            ModifyVerifyPoint(temp);
            if (SelectedItem != null && SelectedItem.FriendData != null)
            {
                if (temp.FriendData.UserId.Equals(SelectedItem.FriendData.UserId))
                {
                    return;
                }
            }

            // 改变选中背景颜色
            if (SelectedItem != null && SelectedItem.FriendData != null)
            {
                // 把上一个取消选中
                SelectedItem.IsSelected = false;
            }
            temp.IsSelected = true;

            SelectedItem = temp;

            if (e == null || e.Button == MouseButtons.Left)
            {
                //ModifyVerifyPoint(SelectedItem);
                MainForm.mainPageLayout.SelectFriend(SelectedItem.FriendData);
            }


        }

        #endregion

        #region 处理验证角标
        private void ModifyVerifyPoint(FriendItem item)
        {
            switch (item.FriendData.UserId)
            {
                case Friend.ID_NEW_FRIEND:

                    MainForm.SelectIndex = MainTabIndex.FriendVerifyPage;//显示好友验证页面
                    item.FriendData.UpdateRedNum(0);
                    item.DrawUnRead(0);

                    // 清空了新的好友数量，所以只需要查询黑名单数量通知到左侧更新就行
                    int num1 = new Friend() { UserId = Friend.ID_BAN_LIST }.GetNuRedNum();
                    Messenger.Default.Send(num1, LeftLayout.NOTIFY_CONTACT_UNREADCOUNT);
                    break;
                case Friend.ID_BAN_LIST:

                    MainForm.SelectIndex = MainTabIndex.BlockPage;//显示黑名单页面
                    item.FriendData.UpdateRedNum(0);
                    item.DrawUnRead(0);

                    // 清空了黑名单数量，所以只需要查询新的朋友数量通知到左侧更新就行
                    int num2 = new Friend() { UserId = Friend.ID_NEW_FRIEND }.GetNuRedNum();
                    Messenger.Default.Send(num2, LeftLayout.NOTIFY_CONTACT_UNREADCOUNT);
                    break;
            }

        }

        #endregion

        #region 得到当前名字排序位置
        private int GetFriendIndexByName(Friend friend)
        {
            if (mAdapter.GetItemCount() <= 7)
            {
                return mAdapter.GetItemCount();
            }

            long frist = PinYinUtils.GetIntSpellCode(friend.GetRemarkName());

            for (int i = mAdapter.GetItemCount() - 1; i > 6; i--)
            {
                long temp = PinYinUtils.GetIntSpellCode(mAdapter.GetDatas(i).GetRemarkName());
                if (frist > temp)
                {
                    return i;
                }
            }

            int insert = Math.Min(mAdapter.GetItemCount(), 7);
            return insert;
        }

        #endregion
    }
}
