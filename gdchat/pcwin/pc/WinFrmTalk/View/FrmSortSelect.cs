using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.View.list;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class FrmSortSelect : FrmBase
    {
        public delegate void FrinedLeftHandler(UserItem item);

        public MyColleague myColleague = null;//我的同事所有信息
        private SelectedFriendAdapter mRightAdapter;
        private SelectFriendAdapter mLeftAdapter;
        private LodingUtils loding;//等待符控件全局
        public int max_number = 15;//最多选择多少好友
        public Dictionary<string, Friend> checkDatas = new Dictionary<string, Friend>();//选中好友
        private Action<Dictionary<string, Friend>> mListener;
        private Timer timer;
        private bool isLock;
        public bool fristSearch = true;
        private List<Friend> AllDataLst = new List<Friend>();//所有的好友集合数据
        private Dictionary<string, Friend> AllLst = new Dictionary<string, Friend>();
        public FrmSortSelect()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            mLeftAdapter = new SelectFriendAdapter();
            mLeftAdapter.frmSortSelect = this;
            mLeftAdapter.isSort = false;
            mRightAdapter = new SelectedFriendAdapter();
            mRightAdapter.frmSortSelect = this;
            mRightAdapter.isSort = false;
            BindDataToList();
            timer = new Timer() { Interval = 500 };
            timer.Interval = 500;
            timer.Tick += SearchText;
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="showrecent">是否显示最近消息列表</param>
        /// <param name="showfriend">是否显示好友列表</param>
        /// <param name="showgroup">是否显示群组列表</param>
        /// <param name="showrlabel">是否显示好友标签</param>
        /// <param name="showmycolleage">是否显示我的同事</param>
        public void LoadFriendsData(bool showrecent, bool showfriend, bool showgroup, bool showrlabel, bool showmycolleage)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/company/getByUserId")
                   .AddParams("access_token", Applicate.Access_Token)
                   .AddParams("userId", Applicate.MyAccount.userId)
                   .Build().Execute((suss, resultData) =>
                   {
                       if (suss)
                       {
                           myColleague = JsonConvert.DeserializeObject<MyColleague>(JsonConvert.SerializeObject(resultData));//数据泛型解析
                           loadTreedata(showrecent, showfriend, showgroup, showrlabel, showmycolleage);
                       }
                   });
        }
       
        /// <summary>
        /// 加载树的数据
        /// </summary>
        /// 并不是所有的树都需要显示
        public void loadTreedata(bool  showrecent,bool showfriend,bool showgroup, bool showrlabel,bool showmycolleage)
        {
            Friend f = new Friend { UserId = Applicate.MyAccount.userId };
            List<Friend> friendAllLst = new List<Friend>();
            bool state2 = true;
            #region 最近消息
            if (showrecent)
            {
                newNode tn1 = new newNode("最近消息");
                tn1.IsSon = false;
                tn1.Name = "最近消息";
                //  tn1.Tag = itemData.departments[0];
                tvwColleague.Nodes.Add(tn1);
                if (state2)
                {
                    tvwColleague.SelectedNode = tn1;//默认选中的节点
                                                    //Clicknode = tn1;
                                                    //lblNodeName.Text = itemData.departments[0].departName;
                    state2 = false;
                }

                List<Friend> friends = new List<Friend>();
                friends = f.GetRecentList();//获取最近消息列表

                foreach (Friend friend in friends)
                {
                    newNode tn2_1 = new newNode(friend.NickName);
                    tn2_1.Name = friend.NickName;
                    tn2_1.Tag = friend;
                    tn2_1.IsSon = true;
                    tn1.Nodes.Add(tn2_1);
                    //去重
                    if (!AllLst.ContainsKey(friend.UserId))
                    {
                        AllDataLst.Add(friend);
                        AllLst.Add(friend.UserId, friend);
                    }

                }
            }

            #endregion
            #region 所有的好友
            if (showfriend)
            {
                newNode tnfriend = new newNode("选择好友");
                tnfriend.Name = "选择好友";
                //  tn1.Tag = itemData.departments[0];
              
                tnfriend.IsSon = false;
                tvwColleague.Nodes.Add(tnfriend);
                if (state2)
                {
                    // tvwColleague.SelectedNode = tn1;//默认选中的节点
                    //Clicknode = tn1;
                    //lblNodeName.Text = itemData.departments[0].departName;
                    state2 = false;
                }
                friendAllLst = f.GetFriendsByIsGroup();//获取最近消息列表

                foreach (Friend friend in friendAllLst)
                {
                    newNode tn2_1 = new newNode(friend.NickName);
                    tn2_1.Name = friend.NickName;
                    tn2_1.Tag = friend;
                    tn2_1.IsSon = true;
                    tnfriend.Nodes.Add(tn2_1);
                   
                    if (!AllLst.ContainsKey(friend.UserId))
                    {
                        AllDataLst.Add(friend);
                        AllLst.Add(friend.UserId, friend);
                    }
                }
               // tnfriend.ExpandAll();
            }
               
            #endregion
            #region 群组
            if(showgroup)
            {
                newNode tnroom = new newNode("群组");
                tnroom.Name = "群组";
                //  tn1.Tag = itemData.departments[0];
                tnroom.IsSon = false;
                tvwColleague.Nodes.Add(tnroom);
                if (state2)
                {
                    // tvwColleague.SelectedNode = tn1;//默认选中的节点
                    //Clicknode = tn1;
                    //lblNodeName.Text = itemData.departments[0].departName;
                    state2 = false;
                }

                List<Friend> RoomLst = new List<Friend>();
                friendAllLst = f.GetGroupsList();//获取最近消息列表
                foreach (Friend friend in friendAllLst)
                {
                    newNode tn2_1 = new newNode(friend.NickName);
                    tn2_1.Name = friend.NickName;
                    tn2_1.Tag = friend;
                    tn2_1.IsSon = true;
                    tnroom.Nodes.Add(tn2_1);
                    if (!AllLst.ContainsKey(friend.UserId))
                    {
                        AllDataLst.Add(friend);
                        AllLst.Add(friend.UserId, friend);
                    }
                }
            }
           
            #endregion
            #region 好友标签
            if(showrlabel)
            {
                   newNode tnfriendLabel = new newNode("好友标签");
            tnfriendLabel.Name = "好友标签";
            //  tn1.Tag = itemData.departments[0];
            tnfriendLabel.IsSon = false;
            tvwColleague.Nodes.Add(tnfriendLabel);
            if (state2)
            {
                // tvwColleague.SelectedNode = tn1;//默认选中的节点
                //Clicknode = tn1;
                //lblNodeName.Text = itemData.departments[0].departName;
                state2 = false;
            }
            // 跟目录 ：好友标签，1级子目录：好友标签名称2级目录：好友

            FriendLabel friendLabel = new FriendLabel { userId = Applicate.MyAccount.userId };

            List<FriendLabel> LabelLst = new List<FriendLabel>();
            LabelLst = friendLabel.getUserId();//获取最近消息列表

            foreach (FriendLabel label in LabelLst)
            {
                newNode tn2_1 = new newNode(label.groupName);
                tn2_1.Name = label.groupName;
                tn2_1.IsSon = true;
                tn2_1.Tag = label.groupId;//标签id
                tn2_1.IsSon = false;
                tnfriendLabel.Nodes.Add(tn2_1);

                List<Friend> friendlst = label.GetFriendList();
                foreach (Friend friend in friendlst)
                {
                    newNode tnfriends = new newNode(friend.NickName);
                    tnfriends.Name = friend.NickName;
                    tnfriends.Tag = friend;
                    tnfriends.IsSon = true;
                    tn2_1.Nodes.Add(tnfriends);
                    if (!AllLst.ContainsKey(friend.UserId))
                    {
                        AllDataLst.Add(friend);
                        AllLst.Add(friend.UserId, friend);
                    }
                }
            }
            }
            #endregion
            #region 我的同事
            if(showmycolleage)
            {
                newNode tnmycolleage = new newNode("我的同事");
                tnmycolleage.Name = "我的同事";
                //  tn1.Tag = itemData.departments[0];
                tnmycolleage.IsSon = false;
                tvwColleague.Nodes.Add(tnmycolleage);


                if (myColleague.data == null)
                {
                    return;
                }
                foreach (ItemData itemData in myColleague.data)
                {
                    //公司层
                    newNode tncompany = new newNode(itemData.departments[0].departName);
                    tncompany.Name = itemData.departments[0].id;
                    tncompany.Tag = itemData.departments[0];
                    tncompany.IsSon = false;
                    tnmycolleage.Nodes.Add(tncompany);
                    if (state2)
                    {
                        //tvwColleague.SelectedNode = tn1;//默认选中的节点
                        //Clicknode = tn1;
                        //lblNodeName.Text = itemData.departments[0].departName;
                        state2 = false;
                    }
                    foreach (DepartmentsItem itemDataDepartment1 in itemData.departments)
                    {
                        //第一层部门层
                        newNode tnDepartment1 = new newNode();
                        if (itemDataDepartment1.parentId == itemData.departments[0].id)
                        {
                            tnDepartment1.Text = itemDataDepartment1.departName;
                            tnDepartment1.Name = itemDataDepartment1.id;
                            tnDepartment1.IsSon = false;
                            tnDepartment1.Tag = itemDataDepartment1;
                            tncompany.Expand();
                            tncompany.Nodes.Add(tnDepartment1);
                            //员工层
                            foreach (employeesItem employeesItem in itemDataDepartment1.employees)
                            {
                                newNode tn3 = new newNode(employeesItem.nickname);
                                tn3.IsSon = true;
                                tn3.IsmyColleage = true;
                                tn3.Tag = employeesItem;
                                tnDepartment1.Nodes.Add(tn3);
                                Friend friend = employeesToFriend(employeesItem);
                                if (!AllLst.ContainsKey(friend.UserId))
                                {
                                    AllDataLst.Add(friend);
                                    AllLst.Add(friend.UserId, friend);
                                }
                            }
                            //第二层员工层
                            foreach (DepartmentsItem itemDataDepartment2 in itemData.departments)
                            {
                                if (itemDataDepartment1.id == itemDataDepartment2.parentId)
                                {
                                    newNode tn2_1 = new newNode(itemDataDepartment2.departName);
                                    tn2_1.Name = itemDataDepartment2.id;
                                    tn2_1.Tag = itemDataDepartment2;
                                    tn2_1.IsSon = false;
                                    tnDepartment1.Nodes.Add(tn2_1);
                                    foreach (employeesItem employeesItem in itemDataDepartment1.employees)
                                    {
                                        newNode tn3 = new newNode(employeesItem.nickname);
                                        tn3.Tag = employeesItem;
                                        tn3.IsSon = true;
                                        tn3.IsmyColleage = true;
                                        tn2_1.Nodes.Add(tn3);
                                        Friend friend = employeesToFriend(employeesItem);
                                        if (!AllLst.ContainsKey(friend.UserId))
                                        {
                                            AllDataLst.Add(friend);
                                            AllLst.Add(friend.UserId, friend);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
          
        }

        #endregion
        public void OnSelectFriend(newNode item)
        {
            Friend f = new Friend();
            if (item.IsmyColleage)
            {
                //将同事的数据转换为friend
                employeesItem employeesItem = (employeesItem)item.Tag;
                f = employeesToFriend(employeesItem);
            }
            else
            {
                f = (Friend)item.Tag;
            }
            if (item.ischeck)
            {
                //取消选中

                //移除数据
                //选中的是同事则无法传friend

                ChangeCheckData(false, f);
                // 清除右边项
                int index = mRightAdapter.GetIndexById(f.UserId);
                if (index > -1)
                {
                    rightList.RemoveItem(index);
                    mRightAdapter.RemoveData(index);
                }
            }
            else
            {
                if (item.IsSon)
                {
                    if (checkDatas.Count >= max_number)
                    {
                        ShowTip("最多只能选择" + max_number + "个人");
                        return;
                    }

                    ChangeCheckData(true, f);
                    // 添加右边项


                }

                // 选中

            }
        }

        private void addtopanel(Friend friend)
        {
            int index = mRightAdapter.GetItemCount();
            mRightAdapter.InsertData(index, friend);
            rightList.InsertItem(index);
        }
        private Friend employeesToFriend(employeesItem employeesItem)
        {
            Friend f = new Friend
            {
                UserId = employeesItem.userId,
                NickName = employeesItem.nickname,
            };
            return f;
        }
        private void BindDataToList()
        {
            mRightAdapter.BindFriendData(new List<Friend>());
            rightList.SetAdapter(mRightAdapter);
        }

        public void OnUnSelectFriend(Friend friend)
        {
            newNode newNode = new newNode();
            newNode.Tag = friend;
            newNode.ischeck = true;
            // 查询左边项位置
            //int index = mLeftAdapter.GetIndexById(friend.UserId);
            //if (index > -1)
            //{
            //    var item = leftList.GetItemControl(index) as UserItem;
            OnSelectFriend(newNode);

        }

        /// <summary>
        /// 修改数据集合
        /// </summary>
        /// <param name="check"></param>
        /// <param name="friend"></param>
        public void ChangeCheckData(bool check, Friend friend)
        {
            if (check)
            {
                if (!checkDatas.ContainsKey(friend.UserId))
                {
                    checkDatas.Add(friend.UserId, friend);
                    addtopanel(friend);

                }
            }
            else
            {
                checkDatas.Remove(friend.UserId);


            }
            lblCount.Text = checkDatas.Count.ToString() + "/" + max_number + "人";
        }

        private void tvwColleague_NodeMouseClick(object sender, TreeNodeMouseClickEventArgs e)
        {
            newNode treeNode = (newNode)e.Node;
            if (treeNode.IsSon)
            {
                OnSelectFriend(treeNode);
            }
        }
        internal void AddConfrmListener(Action<Dictionary<string, Friend>> action)
        {
            mListener = action;
        }
        private void btnConfirm_Click(object sender, EventArgs e)
        {
            
            if(checkDatas==null|| checkDatas.Count<=0)
            {
                return;
            }
            if (!this.btnConfirm.Enabled)
            { return; }
            this.btnConfirm.Enabled = false;
            //我将业务放在线程里处理,若不让在线程里,this.btnConfirm.Enabled = false;不会有禁止效果,因为本次主线程没有完成。
            Task task = new Task(() =>
            {
                if (mListener != null)
                {
                    this.Close();
                    mListener(checkDatas);
                }
            }
            );
            task.Start();
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }
        /// <summary>
        /// 使用等待符
        /// </summary>
        private void ShowLodingDialog()
        {
            loding = new LodingUtils();
            loding.parent = tvwColleague;
            loding.Title = "加载中";
            loding.start();
        }
        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            if (!isLock)
            {
                tvwColleague.Visible = false;
                leftList.Visible = true;
                isLock = true;
                timer.Stop();
                timer.Start();
              //  ShowLodingDialog();
            }
        }
        private void SearchText(object sender, EventArgs e)
        {
            SearchMeesageContent(txtSearch.Text);
        }
        private void SearchMeesageContent(string inputStr)
        {
            timer.Stop();

            if (!string.IsNullOrEmpty(inputStr))
            {
                this.leftList.SuspendLayout();
                this.SuspendLayout();


                if (loding != null)
                {
                    loding.stop();
                }

                loding = new LodingUtils { parent = this.leftList, Title = "加载中" };
                loding.start();

                if (!isLock)
                {
                    return;
                }
                timer.Stop();
                isLock = false;
                loding.stop();


                if (string.IsNullOrEmpty(inputStr))
                {
                    // 还原数据
                    RevertData();
                }
                else
                {
                    List<Friend> search = SearchNickName(inputStr);
                    fristSearch = false;
                    if (UIUtils.IsNull(search))
                    {
                        mLeftAdapter.BindFriendData(new List<Friend>());
                        leftList.SetAdapter(mLeftAdapter);

                        return;
                    }

                    List<Friend> select = mRightAdapter.GetFriendDatas();
                    foreach (var item in select)
                    {
                        foreach (var friend in search)
                        {
                            if (item.UserId.Equals(friend.UserId))
                            {
                                friend.UserType = 1;
                                break;
                            }
                        }
                    }

                    mLeftAdapter.BindFriendData(search);
                    leftList.SetAdapter(mLeftAdapter);
                }

            }
            else
            {
                tvwColleague.Visible = true;
                leftList.Visible = false;
                isLock = false;
                //LoadFriendsData(is,true,true,true,true);
                //txtSearch.Focus();
            }


        }
        private List<Friend> SearchNickName(string text)
        {
            List<Friend> data = new List<Friend>();
            foreach (var item in AllDataLst)
            {
                if (UIUtils.Contains(item.NickName, text) || UIUtils.Contains(item.RemarkName, text))
                {
                    item.UserType = 0;
                    data.Add(item);
                }
            }

            return data;
        }
        /// <summary>
        /// 还原数据
        /// </summary>
        private void RevertData()
        {
            fristSearch = true;

            List<Friend> select = mRightAdapter.GetFriendDatas();

            foreach (var friend in AllDataLst)
            {
                friend.UserType = 0;
            }

            foreach (var item in select)
            {
                foreach (var friend in AllDataLst)
                {
                    if (item.UserId.Equals(friend.UserId))
                    {
                        friend.UserType = 1;
                        break;
                    }
                }
            }
        }
        public void OnSelectFriend(UserItem item)
        {
            if (item.CheckState)
            {
                // 取消选中
                item.CheckState = !item.CheckState;
                // 移除数据
                ChangeCheckData(false, item.Friend);
                // 清除右边项
                int index = mRightAdapter.GetIndexById(item.Friend.UserId);
                if (index > -1)
                {
                    rightList.RemoveItem(index);
                    mRightAdapter.RemoveData(index);
                }
            }
            else
            {
                if (checkDatas.Count >= max_number)
                {
                    ShowTip("最多只能选择" + max_number + "个人");
                    return;
                }
                // 选中
                item.CheckState = !item.CheckState;
                // 添加数据
                ChangeCheckData(true, item.Friend);
                // 添加右边项
                //int index = mRightAdapter.GetItemCount();
                //mRightAdapter.InsertData(index, item.Friend);
                //rightList.InsertItem(index);
            }
        }
    }
}

       

  