using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Threading;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Model;
using WinFrmTalk.View;
using WinFrmTalk.View.list;

namespace WinFrmTalk
{
    /// <summary>
    /// 群组列表
    /// </summary>
    public partial class GroupListLayout : UserControl
    {

        #region Private Member

        private delegate void ProcesssMessage(MessageObject msg);
        private delegate void ProcesssFriend(Friend msg);

        /// <summary>
        /// 当前选中的项目
        /// </summary>
        private FriendItem SelectedItem { get; set; }

        /// <summary>
        /// 主窗口对象
        /// </summary>
        public FrmMain MainForm { get; set; }

        #endregion

        #region 常量
        /// <summary>
        /// 删除群组Token
        /// </summary>
        public const string DELETE_GROUP_ITEM = nameof(DELETE_GROUP_ITEM);

        /// <summary>
        /// 发送群组消息Token
        /// </summary>
        public const string SEND_GROUP_MSG = nameof(SEND_GROUP_MSG);

        private delegate void DelegateString(string msg);

        private GroupListAdapter mAdapter;

        #endregion

        public GroupListLayout()
        {
            InitializeComponent();

            mAdapter = new GroupListAdapter();

            // 由于程序加载时先显示的最近消息列表，而此列表不会加载，导致load事件不会被调用，监听不到xmpp离线过来的加群消息，导致群组列表不统一
            RegisterMessenger();


            xListView.HeaderRefresh += XListView_HeaderRefresh;
            xListView.FooterRefresh += XListView_FooterRefresh;
        }

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


        #region 加载事件
        private void GroupListLayout_Load(object sender, EventArgs e)
        {
            this.txtSearch.GotFocus += SearchFocused;
            this.txtSearch.LostFocus += SearchUnFocused;
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
            txtSearch.BackColor = Color.FromArgb(219, 217, 217); ;
        }
        #endregion

        #region 加载群列表

        bool limitPage = false;
        bool isLock = false;
        int pageindex = 0;

        private void LoadLimitPageData()
        {
            if (pageindex < 0)
            {
                pageindex = 0;
            }

            var friends = new Friend() { IsGroup = 1 }.GetGroupsList();
            int start = pageindex * 200;
            limitPage = friends.Count > start;
            if (limitPage)
            {
                int count = Math.Min(friends.Count - start, 200);
                var data = friends.GetRange(start, count);

                mAdapter.BindFriendData(data);
                xListView.SetAdapter(mAdapter);
            }

            isLock = false;
        }

        /// <summary>
        /// 加载群列表
        /// </summary>
        public void LoadRoomList(string searchText = "")
        {
            var load = new LodingUtils { parent = this.xListView, Title = "加载中" };
            load.start();

            Application.DoEvents();
            MainForm.SuspendLayout();

            List<Friend> rooms = null;
            if (string.IsNullOrEmpty(searchText))
            {

                pageindex = 0;
                rooms = new Friend() { IsGroup = 1 }.GetGroupsList();//获取列表

                int start = pageindex * 200;
                limitPage = rooms.Count > start;
                if (rooms.Count > start)
                {
                    limitPage = true;
                    int count = Math.Min(rooms.Count - start, 200);
                    rooms = rooms.GetRange(start, count);
                }
            }
            else
            {
                rooms = new Friend() { IsGroup = 1 }.SearchFriendsByName(searchText, 1);
            }


            mAdapter.MainForm = MainForm;
            mAdapter.GroupList = this;

            mAdapter.BindFriendData(rooms);
            xListView.SetAdapter(mAdapter);

            //List<Control> roomsControls = new List<Control>();
            //foreach (var room in rooms)
            //{
            //    var item = ModelToControl(room);
            //    roomsControls.Add(item);
            //}
            //tlpRoomList.AddViewsToPanel(roomsControls);

            MainForm.ResumeLayout();
            load.stop();
        }
        #endregion

        #region 注册通知
        private void RegisterMessenger()
        {
            Messenger.Default.Register<bool>(this, GroupListLayout.DELETE_GROUP_ITEM, DeleteGroup);
            Messenger.Default.Register<bool>(this, GroupListLayout.SEND_GROUP_MSG, (_) =>
            {
                MainForm.SendMessageToFriend(SelectedItem.FriendData);
            });

            // 修改群组名称
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_ROOM_CHANGE_MESSAGE, UpdateRommItem);

            // 我退出了一个群
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_ROOM_DELETE, UpdateRommItem);

            // 我被邀请进入了一个群
            Messenger.Default.Register<Friend>(this, MessageActions.ROOM_UPDATE_INVITE, CreteItemView);

            Messenger.Default.Register<string>(this, MessageActions.UPDATE_HEAD, RefreshFriendHead);
        }

        #endregion

        #region 刷新用户头像
        private void RefreshFriendHead(string userId)
        {

            if (Thread.CurrentThread.IsBackground)
            {
                var main = new DelegateString(RefreshFriendHead);
                Invoke(main, userId);
                return;
            }

            int index = mAdapter.GetIndexByFriendId(userId);
            if (xListView.DataCreated(index))
            {
                FriendItem item = xListView.GetItemControl(index) as FriendItem;
                // 刷新用户头像
                item.LoadHeadImage();
            }
        }
        #endregion

        #region 刷新群组名称
        private void UpdateRommName(Friend friend)
        {
            int index = mAdapter.GetIndexByFriendId(friend.UserId);
            if (index > -1)
            {
                mAdapter.ChangeData(index, friend);

                if (xListView.DataCreated(index))
                {
                    FriendItem item = xListView.GetItemControl(index) as FriendItem;
                    // 修改名称
                    item.FriendData.NickName = friend.NickName;
                    item.ChangeFriendName();

                    MainForm.mainPageLayout.ChangeGroupName(item.FriendData);
                }
            }
        }
        #endregion

        #region 修改群名称
        private void UpdateRommItem(MessageObject message)
        {
            if (Thread.CurrentThread.IsBackground == true)
            {
                var tmp = new ProcesssMessage(UpdateRommItem);
                this.Invoke(tmp, message);
                return;
            }


            switch (message.type)
            {
                case kWCMessageType.RoomNameChange:
                    Friend friend = message.GetFriend();
                    if (friend != null)
                    {
                        friend.NickName = message.content;
                        UpdateRommName(friend);
                    }
                    break;
                case kWCMessageType.RoomDismiss:
                case kWCMessageType.RoomExit:
                    if (!UIUtils.IsNull(message.toUserId))
                    {
                        if (string.Equals(message.toUserId, Applicate.MyAccount.userId))
                        {
                            RemoveItemView(message.ChatJid);
                        }
                    }
                    else
                    {
                        RemoveItemView(message.ChatJid);
                    }

                    break;
                default:
                    break;
            }
        }
        #endregion

        #region 根据RoomJId删除项
        private void RemoveItemView(string roomjid)
        {
            int index = mAdapter.GetIndexByFriendId(roomjid);
            if (index > -1)
            {
                xListView.RemoveItem(index);
                mAdapter.RemoveData(index);

                if (MainForm.mainPageLayout.IsCurrtGroup(roomjid))
                {
                    SelectedItem = new FriendItem();
                    MainForm.mainPageLayout.SelectedIndex = MainTabIndex.RecentListPage_null;
                }
            }
        }
        #endregion

        #region 根据Friend创建项
        private void CreteItemView(Friend room)
        {
            if (Thread.CurrentThread.IsBackground == true)
            {
                var tmp = new ProcesssFriend(CreteItemView);
                this.Invoke(tmp, room);
                return;
            }

            int index = mAdapter.GetIndexByFriendId(room.UserId);

            // 没有就添加
            if (index == -1)
            {
                mAdapter.InsertData(0, room);
                xListView.InsertItem(0);
            }
        }
        #endregion

        #region 右键菜单-删除|退出群聊
        private void DeleteGroup(bool para)
        {


            var group = SelectedItem.FriendData.Clone();//获取选中群组
            if (CurrIsLeader(Applicate.MyAccount.userId, group.RoomId))
            {
                if (MessageBox.Show("是否解散  " + group.NickName + " ？", "删除群聊", MessageBoxButtons.OKCancel) == DialogResult.OK)
                {
                    var load = new LodingUtils { parent = this.xListView, Title = "加载中" };
                    load.start();
                    HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + ApplicateConst.DeleteRoom)
                        .AddParams("access_token", Applicate.Access_Token)
                        .AddParams("roomId", SelectedItem.FriendData.RoomId)
                        .AddErrorListener((code, msg) =>
                        {
                            HttpUtils.Instance.ShowTip(msg);
                        })
                        .Build().Execute((state, data) =>
                        {
                            load.stop();

                            if (state)
                            {
                                RemoveItemView(SelectedItem.FriendData.UserId);
                            }

                        });
                }
            }
            else
            {
                if (MessageBox.Show("是否退出  " + group.NickName + " ？", "退出群聊", MessageBoxButtons.OKCancel) == DialogResult.OK)
                {
                    var load = new LodingUtils { parent = this.xListView, Title = "加载中" };
                    load.start();
                    HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + ApplicateConst.DeleteRoomMember)
                        .AddParams("access_token", Applicate.Access_Token)
                        .AddParams("roomId", SelectedItem.FriendData.RoomId)
                        .AddParams("userId", Applicate.MyAccount.userId)
                        .AddErrorListener((code, msg) =>
                        {
                            HttpUtils.Instance.ShowTip(msg);
                        })
                        .Build().Execute((state, data) =>
                        {
                            load.stop();
                            if (state)
                            {
                                RemoveItemView(SelectedItem.FriendData.UserId);
                            }
                        });
                }
            }
        }
        #endregion

        #region 设置右键菜单
        public FriendItem BindContextMenu(FriendItem item)
        {

            var sendmsgitem = new MenuItem("发送消息", (sender, eve) =>
            {
                Messenger.Default.Send(true, GroupListLayout.SEND_GROUP_MSG);

            });
            //var detailitem = new MenuItem("群组详情", (sen, eve) => { Messenger.Default.Send(true, GroupListLayout.SHOW_GROUP_DETAIL); });
            string str = CurrIsLeader(Applicate.MyAccount.userId, item.FriendData.RoomId) ? "解散群组" : "退出群组";
            var blockitem = new MenuItem(str, (sender, eve) =>
            {
                Messenger.Default.Send(true, GroupListLayout.DELETE_GROUP_ITEM);
            });

            var cm = new ContextMenu();
            cm.MenuItems.Add(sendmsgitem);
            //cm.MenuItems.Add(detailitem);
            cm.MenuItems.Add(blockitem);
            item.ContextMenu = cm;//设置右键菜单
            return item;
        }
        #endregion

        #region 判断我在某个群里是否是群主
        private bool CurrIsLeader(string useruId, string roomid)
        {
            int role = new RoomMember() { userId = useruId, roomId = roomid }.GetRoleByUserId();
            return role == 1;
        }
        #endregion

        #region 双击群组开始聊天
        public void DoubleGroupItem(object sender, EventArgs e)
        {
            FriendItem item = sender as FriendItem;
            MainForm.SendMessageToFriend(item.FriendData);
        }

        #endregion

        #region 左键和右键选中事件
        public void MouseDownItem(object sender, MouseEventArgs e)
        {
            // 过滤重复点击项
            FriendItem temp = sender as FriendItem;
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
                MainForm.SelectGroup(SelectedItem.FriendData);
                MainForm.SelectIndex = MainTabIndex.GroupPage;//显示群组详情右侧面板
            }
        }

        #endregion

        #region +号点击
        private void btnPlus_Click(object sender, EventArgs e)
        {
            if (Applicate.URLDATA.data.isOpenRoomSearch == 0)
            {
                #region 打开搜索群功能
                var tmpset = Applicate.GetWindow<FrmGroupQuery>();
                var parent = Applicate.GetWindow<FrmMain>();
                if (tmpset == null)//单例打开好友添加窗口
                {
                    var query = new FrmGroupQuery();
                    query.Location = new Point(parent.Location.X + (parent.Width - query.Width) / 2, parent.Location.Y + (parent.Height - query.Height) / 2);//居中
                    query.Show();
                }
                else
                {
                    tmpset.Activate();
                }
                #endregion
            }
            else
            {
                #region 创建群
                FrmBuildGroups create = new FrmBuildGroups();
                var parent = Applicate.GetWindow<FrmMain>();
                create.Location = new Point(parent.Location.X + (parent.Width - create.Width) / 2, parent.Location.Y + (parent.Height - create.Height) / 2);//居中
                create.Show();
                #endregion
            }
        }
        #endregion

        #region 搜索文本改变时

        private string lastSearchText;

        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            TimerSearch.Stop();
            // 清空了搜索框
            if (string.IsNullOrEmpty(txtSearch.Text))
            {
                TimerSearch_Tick(null, null);
            }
            else
            {
                TimerSearch.Start();
            }
        }


        private void TimerSearch_Tick(object sender, EventArgs e)
        {
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
                // 恢复原列表
                LoadRoomList();
                return;
            }

            lastSearchText = currText;
            if (!string.IsNullOrEmpty(currText))
            {
                // 加载搜索数据
                LoadRoomList(currText);
                return;
            }
        }

        #endregion
    }
}