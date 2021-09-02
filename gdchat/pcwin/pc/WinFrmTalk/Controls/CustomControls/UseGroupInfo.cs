using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.View;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class UseGroupInfo : UserControl
    {
        public UseGroupInfo()
        {
            InitializeComponent();

        }
        private int showMember = 0;
        List<Control> controlLst = new List<Control>();//加入面板中数据的集合
        List<PicChangeControl> member = new List<PicChangeControl>();
        int CurrentRole;
        //public RoomDetails room = new RoomDetails();
        private Friend _Room = new Friend();
        //private List<MembersItem> membersItems;
        private List<RoomMember> roomMemberList = new List<RoomMember>();
        List<MembersItem> memberlst = new List<MembersItem>();
        public Action<Friend> SendAction { get; set; }
        public Friend GroupInfo
        {
            get { return _Room; }
            set { _Room = value; }
        }
        string roomId;
        private void GroupInfo2_Load(object sender, EventArgs e)
        {

            RegistNotiy();
            //  LoadGroupData(roomId);

        }

        //请求服务器获取群数据

        #region 注册群控制消息
        private void RegistNotiy()
        {
            //按回执更新已读消息状态
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_ROOM_CHANGE_MESSAGE, item => Getmonitor(item));

        }
        #endregion
        /// <summary>
        /// 同步更新数据，当数据被更改时刷新UI
        /// </summary>
        /// <param name="msg">传入的消息</param>
        public void Getmonitor(MessageObject msg)
        {
            if (this.IsHandleCreated)
            {
                Invoke(new Action(() =>
                {
                    MainNotiy(msg);

                }));
            }
        }
      
        /// <summary>
        /// 消息监听 
        /// </summary>
        /// <param name="msg">传入的消息</param>
        public void MainNotiy(MessageObject msg)
        {

            switch (msg.type)
            {
                case kWCMessageType.RoomNameChange://改群名

                    lblTitle.Text= msg.content;
                    break;
                case kWCMessageType.RoomDismiss://解散
                    
                    break;
                case kWCMessageType.RoomExit://退群

                    if (!string.Equals(msg.ChatJid, GroupInfo.UserId))
                    {
                        return;
                    }

                    if (msg.toUserId == Applicate.MyAccount.userId)//我主动退群
                    {
                        if (msg.FromId == Applicate.MyAccount.userId)//打开的是当前界面，将它关闭
                        {
                          
                        }
                    }
                    else
                    {
                        //监听到有人退群，现在的处理是调一遍接口
                        Getmenberlist();
                    }
                    break;
               
                case kWCMessageType.RoomInvite://进群

                    if (string.Equals(msg.ChatJid, GroupInfo.UserId))
                    {
                        Getmenberlist();
                    }
                    break;
                case kWCMessageType.RoomMemberNameChange://改群内昵称

                   
                    break;
                case kWCMessageType.RoomUserRecommend://允许私聊
                    GroupInfo.AllowSendCard = Convert.ToInt32( msg.content);
                    break;

                case kWCMessageType.RoomInsideVisiblity://允许显示群成员
                    showMember= Convert.ToInt32(msg.content);
                    GroupInfo.ShowMember = showMember;
                    GroupInfo.UpdateShowMember(showMember);
                    if (showMember == 0)//不允许显示群成员
                    {
                        if (CurrentRole == 3 || CurrentRole == 4)//普通成员和隐身人
                        {
                            AdddataTopal(memberlst, 0);
                        }
                    }
                    else
                    {
                        AdddataTopal(memberlst, 1);//群主和管理员
                    }
                    break;
                
                case kWCMessageType.RoomManagerTransfer://群主转让
                  
                    break;
              
                case kWCMessageType.RoomAdmin:
                  
                    break;
                default:
                    return;
            }
        }
        /// <summary>
        ///显示群组信息
        /// </summary>
        public void DisplayGroup(Friend group)
        {
            group = group.GetByUserId();

            lblTitle.Text = group.NickName;
            int length = lblTitle.Text.Length;
            if (length > 58)
            {
                lblTitle.Text = lblTitle.Text.Substring(0, 59) + "...";
            }

            pic.isDrawRound = false;
            //ImageLoader.Instance.DisplayAvatar(group.roomId, pic);
            ImageLoader.Instance.DisplayGroupAvatar(group.UserId, group.RoomId, pic);
            this.GroupInfo = group;
            roomId = group.RoomId;

            //if (group.status !=2)
            //{
            //    lbldispose.Visible = true;
            //}
            //else
            //{


            Getmenberlist();

        }
         private void  Getmenberlist()
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/member/list") //获取群成员
            .AddParams("access_token", Applicate.Access_Token)
            .AddParams("roomId", roomId)
            .AddParams("pageSize","50")
            .Build().ExecuteJson<List<MembersItem>>((sccess, data) =>
            {
                if (sccess)
                {
                    if (data.Count > 15)
                    {
                        btnSeeMember.Visible = true;
                    }
                    else
                    {
                        btnSeeMember.Visible = false;
                    }

                    tabpal.Controls.Clear();
                    showmembertTopal(GroupInfo.ShowMember, data);
                    memberlst = data;
                    //AdddataTopal(data, GroupInfo.showMember);



                }
            });
        }
        public void showmembertTopal(int showmember, List<MembersItem> memberlsts)
        {
            for (int m = 0; m < memberlsts.Count; m++)
            {
                if (memberlsts[m].userId == Applicate.MyAccount.userId)
                {
                    CurrentRole = memberlsts[m].role;
                    break;
                }
            }
            if (CurrentRole == 3 || CurrentRole == 4)
            {
                if (showmember == 0)
                {
                    AdddataTopal(memberlsts, 0);//不显示群成员
                }
                else
                {
                    AdddataTopal(memberlsts, 1);//显示群成员
                }
            }
            else//管理员和群主
            {
                AdddataTopal(memberlsts, 1);//显示群成员
            }

        }

        /// <summary>
        /// <para>shshowMember是否显示群成员</para>
        ///<para>memberlsts 成员集合</para>
        /// </summary>
        /// <param name="memberlsts"></param>
        /// <param name="showMember"></param>
        private void AdddataTopal(List<MembersItem> memberlsts, int showMember)
        {
            controlLst.Clear();
            tabpal.Controls.Clear();

            int j = 0, k = 0;
           

            for (int i = 0; i < memberlsts.Count; i++)
            {

                USEpicAddName uSEpicAddName = new USEpicAddName();
                uSEpicAddName.pics.Size = new Size(35, 35);
                uSEpicAddName.Size = new Size(42, 58);
                uSEpicAddName.CurrentRole = CurrentRole;
                uSEpicAddName.lblName.Location = new Point(0, uSEpicAddName.pics.Size.Height + 10);
                uSEpicAddName.lblName.Font = new Font(Applicate.SetFont, 8F);
                uSEpicAddName.Tag = memberlsts[i].role;
                uSEpicAddName.NickName = memberlsts[i].nickname;
                uSEpicAddName.Userid = memberlsts[i].userId;
                ImageLoader.Instance.DisplayAvatar(memberlsts[i].userId, uSEpicAddName.pics);



                uSEpicAddName.Margin = new Padding(10, 8, 3, 3);

              
                    uSEpicAddName.pics.Click -= uSEpicAddName.pics_Click;
                    uSEpicAddName.pics.Click += Pics_Click;

                if (showMember == 0)//是否显示群成员
                {
                    if (memberlsts[i].role == 1 || memberlsts[i].userId == Applicate.MyAccount.userId)
                    {
                        controlLst.Add(uSEpicAddName);

                        tabpal.Controls.Add(controlLst[j]);
                        j++;
                    }
                    btnSeeMember.Visible = false;
                }
                else
                {
                    if (memberlsts[i].role == 4 && CurrentRole != 1 && memberlsts[i].userId != Applicate.MyAccount.userId)
                    {
                        continue;
                    }
                    controlLst.Add(uSEpicAddName);
                    tabpal.Controls.Add(controlLst[k]);
                    k++;
                }

            }

        }

      

        private void Pics_Click(object sender, EventArgs e)
        {
            if (GroupInfo.AllowSendCard == 0 && CurrentRole != 1)
            {
                
                HttpUtils.Instance.ShowTip("当前群组禁止普通成员私聊，不允许查看其他成员信息");
            }
            else
            {
                RoundPicBox pic = (RoundPicBox)sender;
                USEpicAddName uSEpicAddName = (USEpicAddName)pic.Parent;
                FrmFriendsBasic frmFriendsBasic = new FrmFriendsBasic();
                frmFriendsBasic.ShowUserInfoByRoom(uSEpicAddName.Userid, GroupInfo.UserId,CurrentRole);
                frmFriendsBasic.Show();
            }
              



        }


        private void btnSeeMember_Click(object sender, EventArgs e)
        {
            FrmMoreMember moreMember = new FrmMoreMember();

            moreMember.SetRoom(GroupInfo);
            moreMember.Show();
            moreMember.BringToFront();
            moreMember.LoadGroupMember();
        }

        internal void ChangeGroupName(string nickName)
        {
            GroupInfo.NickName = nickName;
            lblTitle.Text = nickName;
        }

        private void btnSend_Click(object sender, EventArgs e)
        {
            if (SendAction != null)
            {
                SendAction(GroupInfo);
            }
        }
        private int FontWidth(Font font, Control control, string str)
        {
            using (Graphics g = control.CreateGraphics())
            {
                SizeF siF = g.MeasureString(str, font); return (int)siF.Width;
            }
        }

        public void ChangeLine()
        {
            int wid = FontWidth(lblTitle.Font, lblTitle, lblTitle.Text);
            int line = wid / lblTitle.Width;
        }

      
    }
}
