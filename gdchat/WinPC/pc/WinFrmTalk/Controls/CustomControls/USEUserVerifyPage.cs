using System;
using System.Collections.Generic;
using System.Threading;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.View.list;

namespace WinFrmTalk
{

    /// <summary>
    /// 4-2, lzq, 好友验证页
    /// <para>
    /// 此类为 USEUserVerifyPage 的交互逻辑, 用于显示和处理好友验证消息
    /// <para>运行时: 加载时获取本地VerifingFriend列表内所有数据并形成列表</para>
    /// <para>处理所有好友验证消息</para>
    /// </para>
    /// </summary>
    public partial class USEUserVerifyPage : UserControl
    {

        #region Private Properties

        private delegate void ProcessMsg(MessageObject msg);
        private UserVerifyAdapter mAdapter;
        // 防止出现重复点击的问题

        #endregion

        #region Contructor
        public USEUserVerifyPage()
        {
            InitializeComponent();
            mAdapter = new UserVerifyAdapter();
            mAdapter.VerifyPager = this;
            mAdapter.BindDatas(new List<VerifingFriend>());
            xListView.SetAdapter(mAdapter);
            RegisterMessenger();
        }
        #endregion

        #region 加载事件
        private void USEUserVerifyPage_Load(object sender, EventArgs e)
        {
            LoadData();//加载
        }
        #endregion

        #region 注册消息
        private void RegisterMessenger()
        {
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_VERIFY_MESSAGE, ReceiveVerifyMessage);
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_VERIFY_RECEPIT, ReceiptVerifyMessage);
            Messenger.Default.Register<Friend>(this, MessageActions.UPDATE_FRIEND_REMARKS, UpdateRemarks);

        }
        #endregion

        #region 收到验证消息
        private void ReceiveVerifyMessage(MessageObject msg)
        {
            if (Thread.CurrentThread.IsBackground)
            {
                this.Invoke(new ProcessMsg(ReceiveVerifyMessage), msg);
            }
            else
            {
                ProcessVerifyMsg(msg);
            }
        }
        #endregion

        #region 收到好友验证回执
        private void ReceiptVerifyMessage(MessageObject msg)
        {
            if (Thread.CurrentThread.IsBackground)
            {
                this.Invoke(new ProcessMsg(ProcessVerifyReceipt), msg);
            }
            else
            {
                ProcessVerifyReceipt(msg);
            }
        }
        #endregion


        #region 处理好友验证消息
        /// <summary>
        /// 处理好友验证消息
        /// </summary>
        /// <param name="msg"></param>
        private void ProcessVerifyMsg(MessageObject msg)
        {

            if (msg.fromUserId.Equals(Applicate.MyAccount.userId))
            {
                return;
            }

            var model = new VerifingFriend()
            {
                userId = msg.fromUserId,//UserId
                nickName = msg.fromUserName,//昵称
                Type = Convert.ToInt32(msg.type),//消息类型
                lastMsgTime = Convert.ToInt32(msg.timeSend),
            };

            switch (msg.type)
            {
                case kWCMessageType.FriendRequest:
                    model.VerifyStatus = -4;//对方添加己方
                    model.StatusTag = "通过验证";
                    model.Content = msg.content;//消息内容
                    break;
                case kWCMessageType.RequestAgree:
                    model.VerifyStatus = 1;
                    model.StatusTag = "已添加";
                    model.Content = "验证被 " + msg.fromUserName + " 通过了";
                    break;
                case kWCMessageType.RequestRefuse://对方回话
                    model.VerifyStatus = model.GetVerifyStatus();
                    if (model.VerifyStatus == -3)
                    {
                        model.VerifyStatus = 5;
                    }
                    else
                    {
                        model.StatusTag = "通过验证";
                    }
                    model.Content = msg.fromUserName + " : " + msg.content;//回话内容
                    break;
                case kWCMessageType.DeleteFriend:
                    model.Content = msg.fromUserName + " 已删除了我";
                    model.StatusTag = "被删除";
                    model.VerifyStatus = 0;
                    break;
                case kWCMessageType.BlackFriend:
                    model.VerifyStatus = 0;
                    model.StatusTag = "被拉黑";
                    model.Content = msg.fromUserName + " 拉黑了我";
                    break;
                case kWCMessageType.RequestFriendDirectly:
                    model.VerifyStatus = 1;//互为好友
                    model.Content = msg.fromUserName + " 添加你为好友";//消息内容
                    model.StatusTag = "已添加";
                    break;
                case kWCMessageType.CancelBlackFriend:
                    model.VerifyStatus = 1;//互为好友
                    model.Content = msg.fromUserName + " 取消了黑名单";
                    model.StatusTag = "已添加";
                    break;
                default:
                    break;
            }

            model.lastMsgTime = msg.timeSend;
            model.InsertOrUpdate();//验证对象存入数据库
            RefreshViewItem(model, false);
        }
        #endregion

        #region 处理好友验证回执
        /// <summary>
        /// 处理好友验证回执
        /// </summary>
        /// <param name="msg"></param>
        private void ProcessVerifyReceipt(MessageObject msg)
        {

            if (msg.toUserId.Equals(Applicate.MyAccount.userId))
            {
                return;
            }

            var model = new VerifingFriend()
            {
                userId = msg.toUserId,//UserId
                nickName = msg.toUserName,//昵称
                lastMsgTime = Convert.ToInt32(msg.timeSend),
            };

            switch (msg.type)
            {
                case kWCMessageType.FriendRequest://打招呼回执
                    model.VerifyStatus = -3;
                    model.Content = "等待验证中...";
                    model.StatusTag = "等待验证";
                    break;
                case kWCMessageType.RequestAgree://通过验证回执
                    model.VerifyStatus = 1;
                    model.Content = "我已通过对" + msg.toUserName + "的验证";
                    model.StatusTag = "已添加";
                    break;
                case kWCMessageType.RequestRefuse://回话
                    Messenger.Default.Send("回话给" + msg.toUserName + "成功", FrmMain.NOTIFY_NOTICE);//提示
                    model.VerifyStatus = model.GetVerifyStatus();
                    model.StatusTag = model.VerifyStatus == -4 ? "通过验证" : "已回话";
                    model.Content = "我 : " + msg.content;
                    break;
                case kWCMessageType.DeleteFriend:
                    model.Content = "已删除好友 " + msg.toUserName;
                    model.nickName = msg.toUserName;//此处为接收者Name
                    model.StatusTag = "已删除";
                    model.VerifyStatus = -1;
                    break;
                case kWCMessageType.BlackFriend:
                    model.Content = "已将好友 " + msg.toUserName + " 拉黑";
                    model.StatusTag = "已拉黑";
                    model.nickName = msg.toUserName;//此处为接收者Name
                    model.VerifyStatus = -1;
                    break;
                case kWCMessageType.RequestFriendDirectly://直接添加好友
                    model.VerifyStatus = 1;
                    model.Content = "已添加好友" + msg.toUserName;
                    model.StatusTag = "已添加";
                    break;
                case kWCMessageType.PhoneContactToFriend://对方通过手机联系人添加我为好友
                    model.VerifyStatus = 1;
                    model.Content = msg.toUserName + "通过手机联系人添加我为好友";
                    model.StatusTag = "已添加";
                    break;
                case kWCMessageType.CancelBlackFriend:
                    var tuser = new Friend() { UserId = msg.toUserId }.GetByUserId();
                    model.Content = "已将 " + tuser.NickName + " 移出黑名单";
                    model.StatusTag = "已添加";
                    model.VerifyStatus = 1;//互为好友
                    break;
                default:
                    break;
            }

            model.lastMsgTime = msg.timeSend;
            model.InsertOrUpdate();//存入数据库
            RefreshViewItem(model, true);//更新UI
        }
        #endregion

        #region 通过对方验证
        /// <summary>
        /// 通过对方验证
        /// </summary>
        /// <param name="vfriend"></param>
        public void AgreeVerifyFriend(VerifingFriend vfriend)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + ApplicateConst.AddFriend)
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("toUserId", vfriend.userId)
                .NoErrorTip()
                .AddErrorListener((resCode, info) =>
                {
                    switch (resCode)
                    {
                        case 1:
                        case 2:
                            ShiKuManager.SendAgreeFriendMsg(new Friend
                            {
                                UserId = vfriend.userId,
                                NickName = vfriend.nickName
                            });//发送Xmpp消息(通过验证)
                            break;
                        case 3:
                            MessageBox.Show("已经添加该好友, 不能重复添加", "提示", MessageBoxButtons.OK);
                            break;
                        case 1100801:
                            MessageBox.Show("对方拒绝被添加", "提示", MessageBoxButtons.OK);
                            break;
                        case 1100802:
                            MessageBox.Show("你已经被对方拉黑, 不能添加对方", "提示", MessageBoxButtons.OK);
                            break;
                        case 100514:
                            ShiKuManager.SendAgreeFriendMsg(new Friend
                            {
                                UserId = vfriend.userId,
                                NickName = vfriend.nickName
                            });
                            HttpUtils.Instance.ShowTip("添加成功");

                            break;
                        default:
                            break;
                    }


                }).Build().Execute((isSuccessed, result) =>
                {
                    //此处 isSuccessed 只能获取到ResultCode为1的情况(因Http调用框架导致)，此前有遇到ResultCode为2的情况，考虑业务逻辑的完善，此处添加了异常处理回调函数
                    if (isSuccessed)
                    {
                        ShiKuManager.SendAgreeFriendMsg(new Friend
                        {
                            UserId = vfriend.userId,
                            NickName = vfriend.nickName
                        });//发送Xmpp消息(通过验证)
                    }
                    else
                    {
                        HttpUtils.Instance.ShowTip("服务器请求出错");
                    }

                });
        }
        #endregion

        #region 向用户回话
        public void AnswerFriend(VerifingFriend vfriend, string content)
        {
            var toitem = new Friend
            {
                UserId = vfriend.userId,
                NickName = vfriend.nickName,
            };
            ShiKuManager.SendAnswerBack(content, toitem);
            //设置回话内容


            int index = mAdapter.GetIndexByFriendId(vfriend.userId);
            if (index > -1 && xListView.DataCreated(index))
            {
                VerifyItem item = xListView.GetItemControl(index) as VerifyItem;
                vfriend.Content = "我：" + content;
                item.DataContext = vfriend;//重新设置验证对象
            }
        }
        #endregion


        #region 加载数据
        public void LoadData()
        {
            List<VerifingFriend> list = new VerifingFriend() { }.GetVerifingsList();//查询所有验证消息
            this.SuspendLayout();

            mAdapter.VerifyPager = this;
            mAdapter.BindDatas(list);
            xListView.SetAdapter(mAdapter);


            this.ResumeLayout();
        }
        #endregion


        #region 获取宽度
        public int GetListWidth()
        {
            return xListView.Width;
        }
        #endregion



        #region 刷新名称
        public void UpdateRemarks(Friend friend)
        {

            VerifingFriend verifing = new VerifingFriend() { userId = friend.UserId }.GetByUserId();
            if (verifing != null && !friend.NickName.Equals(verifing.nickName))
            {
                verifing.nickName = friend.NickName;
                verifing.UpdateByUserId();

                int index = mAdapter.GetIndexByFriendId(friend.UserId);
                if (index > -1)
                {
                    mAdapter.RefreshData(index, verifing);
                    xListView.RefreshItem(index);
                }
            }

           
        }
        #endregion


        // 根据消息刷新
        private void RefreshViewItem(VerifingFriend vfriend, bool isMysend)
        {
            int index = mAdapter.GetIndexByFriendId(vfriend.userId);
            if (index == -1)
            {
                // 插入到第一行
                mAdapter.InsertData(0, vfriend);
                xListView.InsertItem(0);
            }
            else
            {

                mAdapter.RefreshData(index, vfriend);
                xListView.RefreshItem(index);

                xListView.MoveItem(index, 0);
                mAdapter.MoveData(index, 0);
            }
        }
    }
}
