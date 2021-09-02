using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using WinFrmTalk.Model;
using WinFrmTalk.Properties;
using WinFrmTalk.View.list;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class UserLabel : UserControl
    {

        LabelAdapter labelAdapter;

        LabelFrienfInfoAdapter labelFrienfInfoAdapter;

        UserLabelItem mSelectItem;


        /// <summary>
        /// 发送消息动作
        /// </summary>
        public Action<Friend> SendAction { get; set; }


        public UserLabel()
        {
            InitializeComponent();
            labelAdapter = new LabelAdapter();
            labelFrienfInfoAdapter = new LabelFrienfInfoAdapter();

            labelAdapter.UserLabel = this;
            labelFrienfInfoAdapter.UserLabel = this;

            // 更新标签页
            Messenger.Default.Register<string>(this, MessageActions.UPDATE_LABLE_LIST, (str) =>
            {
                isLoadData = false;
            });

            Messenger.Default.Register<Friend>(this, MessageActions.UPDATE_FRIEND_REMARKS, (str) =>
            {
                isLoadData = false;
            });

            // 删除好友 禅道#8160
            Messenger.Default.Register<Friend>(this, MessageActions.DELETE_FRIEND, (str) =>
            {
                DataLoad();
            });

            // 被拉黑 禅道#8160
            Messenger.Default.Register<Friend>(this, MessageActions.ADD_BLACKLIST, (str) =>
            {
                DataLoad();
            });
        }

        // 标签点击事件
        public void OnMouseDownLable(object sender, MouseEventArgs e)
        {
            UserLabelItem item = (UserLabelItem)sender;

            if (item == mSelectItem)
            {
                return;
            }

            mSelectItem = item;
            List<Friend> friendlst = item.FriendLabel.GetFriendList();
            labelFrienfInfoAdapter.BindDatas(friendlst);
            pnlFriend.SetAdapter(labelFrienfInfoAdapter);
        }

        public void BindContextMenu(UserLabelItem item)
        {
            var addfriend = new MenuItem() { Text = "添加成员" };
            var updatename = new MenuItem { Text = "修改名称" };
            var delleble = new MenuItem { Text = "删除标签" };
            var alldel = new MenuItem { Text = "批量删除" };

            addfriend.Click += OnAddLableFriend;
            updatename.Click += OnUpdateLableName;
            delleble.Click += OnDeleteLable;
            alldel.Click += OnBatchDelete;

            //设置右键菜单
            var menuList = new ContextMenu();
            menuList.MenuItems.Add(addfriend);
            menuList.MenuItems.Add(updatename);
            menuList.MenuItems.Add(delleble);
            menuList.MenuItems.Add(alldel);
            item.ContextMenu = menuList;
        }

        private bool isLoadData;
        public void DataLableLoad()
        {
            if (!isLoadData)
            {
                DataLoad();
            }
        }

        /// <summary>
        /// 数据加载
        /// </summary>
        private void DataLoad()
        {
            LodingUtils loding = new LodingUtils();
            loding.parent = pnlLabel;
            loding.start();

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "friendGroup/list")
                .AddParams("access_token", Applicate.Access_Token)
                .Build().Execute((suss, data) =>
                {
                    if (suss)
                    {
                        isLoadData = true;
                        JArray array = JArray.Parse(UIUtils.DecodeString(data, "data"));
                        List<FriendLabel> flabellst = new List<FriendLabel>();
                        foreach (var item in array)
                        {
                            FriendLabel friendLabel = new FriendLabel();
                            friendLabel.groupId = UIUtils.DecodeString(item, "groupId");
                            friendLabel.groupName = UIUtils.DecodeString(item, "groupName");
                            friendLabel.userIdList = UIUtils.DecodeString(item, "userIdList");//解析的格式？？
                            friendLabel.userId = UIUtils.DecodeString(item, "userId");
                            flabellst.Add(friendLabel);
                        }

                        labelAdapter.BindDatas(flabellst);
                        pnlLabel.SetAdapter(labelAdapter);
                        new FriendLabel().SaveLableList(flabellst);

                    }

                    loding.stop();
                });
        }




        #region 标签右键菜单事件

        // 添加成员
        public void OnAddLableFriend(object sender, EventArgs e)
        {

            // 需要排除现有的数据
            List<RoomMember> excludes = mSelectItem.FriendLabel.GetRoomMemberList();

            FrmFriendSelect frm = new FrmFriendSelect();
            frm.LoadFriendsData(excludes);
            frm.AddConfrmListener((listFriend) =>
            {
                if (listFriend == null || listFriend.Count == 0)
                {
                    return;
                }
                //List<Friend> addfriend = new List<Friend>(); 
                string listUserID = string.Empty;
                foreach (var friend in listFriend.Values)
                {
                    //addfriend.Add(friend);
                    listUserID += friend.UserId + ",";
                }
                foreach (var item in excludes)
                {
                    listUserID += item.userId + ",";
                }

                listUserID = listUserID.Remove(listUserID.Length - 1, 1);


                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "friendGroup/updateGroupUserList")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("groupId", mSelectItem.FriendLabel.groupId)
                    .AddParams("userIdListStr", listUserID)
                    .Build().Execute((susee, datalist) =>
                    {
                        if (susee)
                        {
                            pnlFriend.ClearList();
                            DataLoad();
                            HttpUtils.Instance.ShowTip("添加成功");
                        }
                    });
            });
        }

        // 修改名称
        public void OnUpdateLableName(object sender, EventArgs e)
        {
            FrmMyColleagueEidt frm = new FrmMyColleagueEidt();
            frm.NameEdit = mSelectItem.FriendLabel.groupName;
            frm.ColleagueName((name) =>
            {
                name = name.TrimStart().Trim();

                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "friendGroup/update")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("groupId", mSelectItem.FriendLabel.groupId)
                    .AddParams("groupName", name)
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            string[] names = new string[2];
                            names = mSelectItem.lblName.Text.Split('(');
                            mSelectItem.lblName.Text = name + "(" + names[1];
                            mSelectItem.FriendLabel.groupName = name;
                            frm.Close();
                            HttpUtils.Instance.PopView(frm);
                            HttpUtils.Instance.ShowTip("修改成功");
                        }
                    });

            });
            frm.ShowThis("修改标签", "标签名称");
        }

        // 删除标签
        public void OnDeleteLable(object sender, EventArgs e)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "friendGroup/delete")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("groupId", mSelectItem.FriendLabel.groupId)
                .Build().Execute((suss, data) =>
                {
                    if (suss)
                    {
                        HttpUtils.Instance.ShowTip("删除标签成功");
                        pnlFriend.ClearList();
                        FriendLabel friendLabel = new FriendLabel { groupId = mSelectItem.FriendLabel.groupId };
                        friendLabel.DeleteByUserId();

                        DataLoad();
                    }
                });
        }

        // 批量删除
        public void OnBatchDelete(object sender, EventArgs e)
        {
            List<Friend> friendList = mSelectItem.FriendLabel.GetFriendList();

            FrmFriendSelect frm = new FrmFriendSelect();

            frm.LoadFriendsData(friendList);

            frm.AddConfrmListener((disFriend) =>
            {
                if (disFriend == null || disFriend.Count == 0)
                {
                    return;
                }

                string userstr = string.Empty;

                for (int i = friendList.Count - 1; i >= 0; i--)
                {
                    if (disFriend.ContainsKey(friendList[i].UserId))
                    {
                        friendList.RemoveAt(i);
                        continue;
                    }

                    userstr += friendList[i].UserId + ",";
                }

                if (friendList.Count > 0)
                {
                    userstr = userstr.Remove(userstr.Length - 1, 1);
                    Console.WriteLine(userstr);
                }

                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "friendGroup/updateGroupUserList")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("groupId", mSelectItem.FriendLabel.groupId)
                    .AddParams("userIdListStr", userstr)
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            HttpUtils.Instance.ShowTip("删除成功");
                            FriendLabel label = mSelectItem.FriendLabel;
                            label.userIdList = "[" + userstr + "]";
                            mSelectItem.FriendLabel = label;
                            labelFrienfInfoAdapter.BindDatas(friendList);
                            pnlFriend.SetAdapter(labelFrienfInfoAdapter);
                        }
                    });
            });
        }

        #endregion

        // 创建标签
        public void OnCreateLable(object sender, EventArgs eve)
        {

            FrmMyColleagueEidt frm = new FrmMyColleagueEidt();
            frm.ColleagueName((name) =>
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "friendGroup/add")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("groupName", name)
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            btnCreate.Enabled = false;
                            frm.Close();
                            frm.Dispose();
                            DataLoad();
                            FrmSortSelect select = new FrmSortSelect();
                            select.TopMost = true;//(如果加上这句代码，在好友选择器界面输入回车，会导致界面卡死，而且还不能关闭)
                            select.LoadFriendsData(false, true, false, false, false);
                            select.Focus();
                            select.Show();
                            // select.BringToFront();
                            //select.StartPosition = FormStartPosition.CenterParent;
                            select.FormClosed += Select_FormClosed;
                            //快速点击多次确定会创建多个标签
                            select.AddConfrmListener((disc) =>
                            {
                                string listUserID = String.Empty;
                                foreach (var friend in disc.Values)
                                {
                                    listUserID += friend.UserId + ",";
                                }
                                if (listUserID.Length > 0)
                                {
                                    listUserID = listUserID.Remove(listUserID.Length - 1, 1);
                                }

                                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "friendGroup/updateGroupUserList")
                                    .AddParams("access_token", Applicate.Access_Token)
                                    .AddParams("groupId", UIUtils.DecodeString(data, "groupId"))
                                    .AddParams("userIdListStr", listUserID)
                                    .Build().Execute((susee, datalist) =>
                                    {
                                        if (susee)
                                        {
                                            DataLoad();
                                            btnCreate.Enabled = true;
                                            HttpUtils.Instance.ShowTip("创建成功");
                                        }
                                    });
                            });
                        }
                        else
                        {

                            return;
                        }

                    });

            });
            frm.ShowThis("创建标签", "标签名称");
        }

        private void Select_FormClosed(object sender, FormClosedEventArgs e)
        {
            btnCreate.Enabled = true;
        }


        // 双击聊天
        public void OnStartChat(object sender, EventArgs eve)
        {
            FriendItem item = (FriendItem)sender;
            Messenger.Default.Send(item.FriendData, FrmMain.START_NEW_CHAT);//通知各页面收到消息
        }

        // 删除成员
        public void OnDeleteLableFriend(Friend friend)
        {
            string Useridstr = String.Empty;

            List<Friend> data = mSelectItem.FriendLabel.GetFriendList();

            foreach (var item in data)
            {
                if (!friend.UserId.Equals(item.UserId))
                {
                    Useridstr += item.UserId + ",";
                }
            }

            if (!string.IsNullOrEmpty(Useridstr))
            {
                Useridstr = Useridstr.Remove(Useridstr.Length - 1, 1);
            }

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "friendGroup/updateGroupUserList")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("groupId", mSelectItem.FriendLabel.groupId)
                .AddParams("userIdListStr", Useridstr)
                .Build().Execute((suss1, data1) =>
                {
                    if (suss1)
                    {
                        DataLoad();
                        HttpUtils.Instance.ShowTip("删除成功");
                    }
                });
        }
    }
}
