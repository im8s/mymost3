using agsXMPP;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.Properties;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class USEFriendInfo : UserControl
    {
        public USEFriendInfo()
        {
            InitializeComponent();
            //监听通知
            Messenger.Default.Register<Friend>(this, MessageActions.UPDATE_FRIEND_REMARKS, UpdateRemarks);
            Messenger.Default.Register<string>(this, MessageActions.UPDATE_DEVICE_STATE, (device) =>
            {
                if (IsHandleCreated && Friend != null)
                {
                    Invoke(new Action(() =>
                    {
                        if (string.Equals(Friend.UserId, device))
                        {
                            ChangeFriendLineState(MultiDeviceManager.Instance.IsDeviceLine(Friend.UserId));
                        }

                    }));
                }
            });



           
              
        }
        /// <summary>
        /// 更新好友备注
        /// </summary>
        /// <param name="friend"></param>
        private void UpdateRemarks(Friend friend)
        {
            if (Friend != null)
            {
                if (friend.UserId.Equals(this.Friend.UserId))
                {
                    Friend.NickName = friend.NickName;
                    Friend.RemarkName = friend.RemarkName;
                    lblRemarks.Text = friend.GetRemarkName();
                }
            }
        }


        /// <summary>
        /// 控件初始化方法
        /// </summary>
        /// <param name="item"></param>
        internal void DisplayFriend(Friend item)
        {
            txtRemarks.Text = "";
            txtRemarks.Visible = false;


            if (item != null && this.Friend != null)
            {
                if (item.UserId.Equals(Friend.UserId))
                {
                    return;
                }
            }

            this.Friend = item;
            if (Friend == null || string.IsNullOrEmpty(this.Friend.UserId))
            {
                return;
            }
            picHead.isDrawRound = true;

            ImageLoader.Instance.DisplayAvatar(item.UserId, picHead);

            ToDataByView(item);

            if (item.IsNormalUser())
            {
                ShowLableView(true);
                fillDataByView();
                //RequestOnlineState(item.UserId);
            }
            else
            {
                ShowLableView(false);
                ChangeFriendLineState(MultiDeviceManager.Instance.IsDeviceLine(item.UserId));
            }
        }

        private void ShowLableView(bool isUser)
        {
            skinLine2.Visible = isUser;
            label1.Visible = isUser;
            label2.Visible = isUser;
            label3.Visible = isUser;
            label4.Visible = isUser;
            label5.Visible = isUser;
        }

        #region 属性

        private Friend _friend;
        public Friend Friend
        {
            get { return _friend; }
            set { _friend = value; }
        }
        /// <summary>
        /// 昵称
        /// </summary>
        public string Nickname
        {
            get { return lblNickname.Text; }
            set { lblNickname.Text = value; }
        }
        ///// <summary>
        ///// 头像
        ///// </summary>
        //public Image Head
        //{
        //    get { return picHead.Image; }
        //    set { picHead.Image = value; }
        //}
        /// <summary>
        /// 备注
        /// </summary>
        public string Remarks
        {
            get { return lblRemarks.Text; }
            set { lblRemarks.Text = value; }
        }
        /// <summary>
        /// 性别
        /// </summary>
        public string Sex
        {
            get { return lblSex.Text; }
            set { lblSex.Text = value; }
        }
        /// <summary>
        /// 出生日期
        /// </summary>
        public string Birthday
        {
            get { return lblBirthday.Text; }
            set { lblBirthday.Text = value; }
        }
        /// <summary>
        /// 所在地
        /// </summary>
        public string LocationName
        {
            get { return lblLocation.Text; }
            set { lblLocation.Text = value; }
        }
        #endregion

        #region 修改备注
        /// <summary>
        /// 点击备注切换到可修改状态
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void lblRemarks_Click(object sender, EventArgs e)
        {
            txtRemarks.Text = "";
            if (lblRemarks.Text != "点击添加备注")
            {
                txtRemarks.Text = lblRemarks.Text;
                txtRemarks.Visible = true;
                txtRemarks.Focus();
            }
            else
            {
                txtRemarks.Visible = true;
                txtRemarks.Focus();
            }
        }
        /// <summary>
        /// 回车修改备注
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtRemarks_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == '\r')
            {
                txtRemarks_Leave(sender, e);
            }
        }
        /// <summary>
        /// 修改备注
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtRemarks_Leave(object sender, EventArgs e)
        {
            if (Friend != null)
            {
                if (Friend.RemarkName != txtRemarks.Text && txtRemarks.Visible)
                {
                    string url = Applicate.URLDATA.data.apiUrl + "friends/remark";
                    HttpUtils.Instance.Get().Url(url)
                        .AddParams("access_token", Applicate.Access_Token)
                        .AddParams("toUserId", Friend.UserId)
                        .AddParams("remarkName", txtRemarks.Text)
                        .Build().Execute((suss, data) =>
                        {
                            if (suss)
                            {
                                Friend.RemarkName = txtRemarks.Text;
                                Friend.UpdateRemarkName();
                                Messenger.Default.Send(Friend, MessageActions.UPDATE_FRIEND_REMARKS);
                                lblRemarks.Text = (txtRemarks.Text == "" ? "点击添加备注" : txtRemarks.Text);
                                txtRemarks.Text = "";
                            }
                        });
                }
                txtRemarks.Visible = false;
            }
        }
        #endregion

        #region 数据获取与绑定
        private void fillDataByView()
        {
            //  从网络获取
            string url = Applicate.URLDATA.data.apiUrl + "user/get";
            HttpUtils.Instance.Get().Url(url)
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("userId", Friend.UserId)
                .Build().Execute((suu, data) =>
                {
                    if (suu)
                    {
                        bool isupdate = false;
                        Friend jsonFriend = JsonConvert.DeserializeObject<Friend>(JsonConvert.SerializeObject(data));//使用Friend解析出来
                        if (data.ContainsKey("friends"))
                        {
                            Dictionary<string, object> dic = JsonConvert.DeserializeObject<Dictionary<string, object>>(UIUtils.DecodeString(data, "friends"));//使用字典解析出来
                            jsonFriend.RemarkName = UIUtils.DecodeString(dic, "remarkName");
                            jsonFriend.Status = UIUtils.DecodeInt(dic, "status");

                            // 备注发生改变
                            if (!jsonFriend.RemarkName.Equals(Friend.RemarkName))
                            {
                                jsonFriend.UpdateRemarkName();
                                isupdate = true;
                            }
                        }

                        lblAccount.Text = UIUtils.DecodeString(data, "account");//通讯号

                        if (jsonFriend.UserType == 1)
                        {
                            jsonFriend.UserType = 0;
                        }


                        // 昵称发生改变
                        if (!jsonFriend.NickName.Equals(Friend.NickName))
                        {
                            Friend.NickName = jsonFriend.NickName;
                            Friend.UpdateNickName();
                            isupdate = true;
                        }

                        int isline = UIUtils.DecodeInt(data, "onlinestate");
                        ChangeFriendLineState(isline == 1);

                        Friend = jsonFriend;

                        if (isupdate)
                        {
                            Messenger.Default.Send(Friend, MessageActions.UPDATE_FRIEND_REMARKS);
                        }


                        Friend.AccountId = lblAccount.Text;
                        if (!UIUtils.IsNull(Friend.AccountId))
                        {
                            Friend.UpdateAccountId(Friend.AccountId);
                        }

                        ToDataByView(Friend);
                    }
                });
        }
        /// <summary>
        /// 绑定数据到控件上
        /// </summary>
        /// <param name="friend"></param>
        private void ToDataByView(Friend friend)
        {
            lblNickname.Text = string.IsNullOrEmpty(friend.NickName) ? "" : friend.NickName;
            if (!friend.IsNormalUser())
            {
                Sex = "";
                Birthday = "";
                LocationName = "";
                lblAccount.Text = "";
                lblRemarks.Text = "";
                return;
            }


            lblRemarks.Text = string.IsNullOrEmpty(friend.RemarkName) ? "点击添加备注" : friend.RemarkName;
            Sex = friend.Sex == 1 ? "男" : "女";

            if (friend.Birthday!= null && friend.Birthday.ToString().Length >= 10)
            {
                friend.Birthday = friend.Birthday / 1000;
            }
            Birthday = TimeUtils.FromatTime(friend.Birthday, "yyyy/MM/dd");

            Areas areas = new Areas();
            areas.id = friend.CityId;
            areas = areas.GetModel();

            LocationName = areas.name;
            areas.id = areas.parent_id;
            areas = areas.GetModel();
            LocationName = areas.name + lblLocation.Text;
        }
        #endregion
        /// <summary>
        /// 个人在线状态
        /// </summary>
        /// <param name="isLine">是否在线</param>
        private void ChangeFriendLineState(bool isLine)
        {
            Statebrg2 = ColorTranslator.FromHtml(isLine ? "#0AD007" : "#BBBBBB");
            // 触发重绘
            ImageLoader.Instance.DisplayAvatar(Friend.UserId, picHead);
        }

        /// <summary>
        /// 获取好友在线状态
        /// </summary>
        /// <param name="userId"></param>
        private void RequestOnlineState(string userId)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/getOnLine") //获取群详情
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("userId", userId)
                .Build().Execute((success, result) =>
                {
                    if (success)
                    {
                        if (UIUtils.DecodeString(result, "data").Equals("1"))
                        {
                            ChangeFriendLineState(true);
                        }
                    }
                });
        }

        #region 发消息
        /// <summary>
        /// 发送消息动作
        /// </summary>
        public Action<Friend> SendAction { get; set; }
        /// <summary>
        /// 发送消息
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>

        private void btnSend_Click(object sender, EventArgs e)
        {
            SendAction?.Invoke(this.Friend);
        }
        #endregion
        /// <summary>
        /// 点击第一次出现图像，点击第二次出现默认
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void picHead_Click(object sender, EventArgs e)
        {
            if (!Friend.IsNormalUser())
            {
                FrmLookImage frm = new FrmLookImage();

                frm.ShowImage(Friend.UserId);
            }
            else
            {
                string headUrl = ImageLoader.Instance.GetHeadUrl(Friend.UserId, false);
                FrmLookImage frm = new FrmLookImage();
                frm.ShowImage(headUrl);
            }


        }

        private Color Statebrg2 = Color.White;
        private void picHead_Paint(object sender, PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.CompositingQuality = CompositingQuality.HighQuality;
            g.DrawEllipse(new Pen(Statebrg2), new Rectangle(picHead.Width - 14, picHead.Height - 14, 12, 12));
            Brush b = new SolidBrush(Statebrg2);
            g.FillEllipse(b, new Rectangle(picHead.Width - 14, picHead.Height - 14, 12, 12));
        }
    }
}
