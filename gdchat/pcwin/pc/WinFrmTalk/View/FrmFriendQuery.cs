using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using WinFrmTalk.Controls;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    /// <summary>
    /// 查找好友界面
    /// </summary>
    public partial class FrmFriendQuery : FrmBase
    {

        public const int FROM_ADD_TYPE_QRCODE = 1;
        public const int FROM_ADD_TYPE_CARD = 2;
        public const int FROM_ADD_TYPE_GROUP = 3;
        public const int FROM_ADD_TYPE_PHONE = 4;
        public const int FROM_ADD_TYPE_NAME = 5;
        public const int FROM_ADD_TYPE_OTHER = 6;


        private delegate void ProcesMainString(string userid);

        public FrmFriendQuery()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            RegisterMessenger();
        }

        #region 注册广播&接收处理

        // 注册广播
        private void RegisterMessenger()
        {
            Messenger.Default.Register<string>(this, FriendListLayout.ADD_EXISTS_FRIEND, ChageFriendState);
            Messenger.Default.Register<Friend>(this, MessageActions.DELETE_FRIEND, ChageFriendState);
            Messenger.Default.Register<Friend>(this, MessageActions.ADD_BLACKLIST, ChageFriendState);
        }

        // 收到朋友状态改变通知
        private void ChageFriendState(Friend friend)
        {
            ChageFriendState(friend.UserId);
        }

        // 收到朋友状态改变通知
        private void ChageFriendState(string userId)
        {

            if (Thread.CurrentThread.IsBackground)
            {
                var main = new ProcesMainString(ChageFriendState);
                Invoke(main, userId);
                return;
            }


            AddFriendItem item = palFriendItem.GetQueryItemByVerifingFriend(userId);
            if (item != null)
            {
                ChangeBtnSatate(item, userId);
            }
        }

        // 改变按钮状态
        private void ChangeBtnSatate(AddFriendItem friendItem, string userid)
        {
            Friend friend = new Friend { UserId = userid }.GetByUserId();
            if (userid.Equals(Applicate.MyAccount.userId))
            {
                friendItem.btnAction.Visible = false;
                return;
            }

            if (string.IsNullOrEmpty(friend.UserId))
            {
                friendItem.friendData.Status = 0;
                friendItem.friendData.InsertAuto();
            }


            switch (friend.Status)
            {
                case Friend.STATUS_FRIEND://为好友时
                    friendItem.btnAction.Text = "发消息";

                    friendItem.btnAction.Visible = true;
                    friendItem.btnAction.Enabled = true;
                    friendItem.label1.Visible = false;

                    friendItem.Add((frienddata) =>
                    {
                        Messenger.Default.Send(friendItem.friendData, FrmMain.START_NEW_CHAT);//发消息
                        this.Close();
                    });//设置事件
                    break;
                case Friend.STATUS_19://拉黑了我
                    friendItem.btnAction.Text = "拉黑了我";
                    friendItem.btnAction.Enabled = false;
                    break;
                case Friend.STATUS_18://我拉黑了他
                    friendItem.btnAction.Text = "取消拉黑";
                    friendItem.Add((frienddata) =>
                    {
                        CancelBlock(frienddata);
                    });//设置事件
                    break;
                case Friend.STATUS_10://等待对方验证
                    friendItem.btnAction.Text = "等待验证";
                    friendItem.btnAction.Enabled = false;
                    break;
                default:
                    friendItem.btnAction.Text = "添加";
                    friendItem.Add((frienddata) =>
                    {
                        friendItem.btnAction.Enabled = false;
                        friendItem.btnAction.Text = "等待验证";
                        AttenFriend(frienddata, friendItem);
                    });//设置事件
                    break;
            }
        }

        #endregion

        #region 点击添加好友
        private void AttenFriend(Friend friend, AddFriendItem friendItem)
        {
            switch (friend.Status)
            {
                case -1://黑名单
                    break;
                case 0://陌生人
                case 1://单方关注,(大业说不为2都可以做添加好友操作)
                    RequestAttendFriend(friend, friendItem);
                    break;
                case 2:
                    break;
                case 8:
                    break;
                case 9:
                    break;
                default:
                    break;
            }
        }

        private void RequestAttendFriend(Friend friend, AddFriendItem friendItem)
        {

            string requesttype = "5";
            if (!friend.NickName.Contains(txtKeyWord.Text))
            {
                requesttype = "4";
            }

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + ApplicateConst.AddFriend)
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("toUserId", friend.UserId)
                .AddParams("fromAddType", requesttype)
                .NoErrorTip()
                .Build()
                .AddErrorListener((code, str) =>
                {
                    if (code == 100515)
                    {
                        friend.InsertAuto();

                        ShiKuManager.SendBecomeFriendMsg(friend);//发送508成为好友消息,,在此之后，需要设置按钮禁用并显示"已和xxx成为好友"
                        friendItem.btnAction.Visible = false;
                        friendItem.label1.Visible = true;
                    }
                    else if (code == 100514)
                    {
                        ShiKuManager.SendHelloFriendMsg(friend);//发送好友请求消息
                        friendItem.btnAction.Visible = false;
                        friendItem.label1.Text = "等待验证";
                        friendItem.label1.Visible = true;
                    }
                    else
                    {
                        friendItem.btnAction.Enabled = true;
                        friendItem.btnAction.Text = "添加";
                        ShowTip("该用户不允许此方式添加好友");
                    }

                })
                .ExecuteJson<Attention>((isSuccessed, result) =>
                {

                    if (isSuccessed)
                    {
                        friend.InsertAuto();

                        if (result.type == 2 || result.type == 4)//类型为2或4时均可直接成为好友
                        {
                            ShiKuManager.SendBecomeFriendMsg(friend);//发送508成为好友消息,,在此之后，需要设置按钮禁用并显示"已和xxx成为好友"
                            friendItem.btnAction.Visible = false;
                            friendItem.label1.Visible = true;
                        }
                        else
                        {
                            ShiKuManager.SendHelloFriendMsg(friend);//发送好友请求消息
                                                                    //等待验证
                            friendItem.btnAction.Enabled = false;
                            friendItem.btnAction.Text = "等待验证";
                            //friendItem.btnAction.Visible = false;
                            //friendItem.label1.Text = "等待验证";
                            //friendItem.label1.Visible = true;

                        }
                    }

                });

        }

        #endregion

        #region 取消黑名单
        private void CancelBlock(Friend toFriend)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + ApplicateConst.DeleteBlackItem)
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("toUserId", toFriend.UserId)
                .Build()
                .AddErrorListener((issuccess, info) =>
                {
                    Messenger.Default.Send("取消黑名单失败：" + info, FrmMain.NOTIFY_NOTICE);//主窗口提示错误
                })
                .Execute((issuccess, result) =>
                {
                    if (issuccess)//取消成功
                    {
                        ShiKuManager.SendCancelBlockFriendMsg(toFriend);//发送消息通知对应好友
                    }
                });
        }
        #endregion

        #region 点击查询好友
        // 按下回车后去查询
        private void txtKeyWord_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == '\r')
            {
                btnQuery_Click(sender, e);
            }
        }


        private bool showLoading;
        private LodingUtils load;

        private void HideLoding()
        {
            load.stop();
            showLoading = false;
        }
        private void ShowLoding()
        {
            showLoading = true;
            load = new LodingUtils { parent = this, Title = "加载中" };
            load.start();
        }

        // 点击查询
        private void btnQuery_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(txtKeyWord.Text) || !showLoading)
            {
                ShowLoding();

                palFriendItem.ClearTabel();
                List<Control> controls = new List<Control>();
                controls.Clear();
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "nearby/user")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("nickname", txtKeyWord.Text)
                    .Build().Execute((suss, data) =>
                    {
                        HideLoding();
                        if (suss)
                        {
                            JArray friendArray = JArray.Parse(data["data"].ToString());
                            if (friendArray.Count <= 0)
                            {
                                this.ShowTip("该用户不存在");
                            }
                            List<Control> list = new List<Control>();
                            foreach (var friend in friendArray)
                            {
                                var item = JsonConvert.DeserializeObject<Friend>(friend.ToString());
                                AddFriendItem friendItem = new AddFriendItem() { friendData = item };
                                ChangeBtnSatate(friendItem, item.UserId);
                                list.Add(friendItem);//更新UI
                            }

                            paging(list);
                        }
                    });
            }
        }
        /// <summary>
        /// 分页加载
        /// </summary>
        /// <param name="listcControl"></param>
        public void paging(List<Control> listcControl)
        {
            List<Control> views = new List<Control>();
            for (int i = 0; i < 20; i++)
            {
                //验证是否有该index
                if (i < listcControl.Count)
                    views.Add(listcControl[i]);
            }
            palFriendItem.AddViewsToPanel(views);
            palFriendItem.AddScollerBouttom((index) =>
            {
                views = new List<Control>();
                for (int i = 0; i < 10; i++)
                {
                    int num = i + ((index - (20 / 10) - 1) * 10) + 20;
                    if (num < listcControl.Count)
                        views.Add(listcControl[num]);
                }
                palFriendItem.AddViewsToPanel(views);
                LogUtils.Log(index.ToString());
            }, 20, 10);
        }
        #endregion

        #region 取消广播注册
        private void FrmFriendQuery_FormClosed(object sender, FormClosedEventArgs e)
        {
            Messenger.Default.Unregister(this);//反注册
        }
        #endregion




    }
}
