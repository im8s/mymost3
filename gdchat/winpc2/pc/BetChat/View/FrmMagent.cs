using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;
using WinFrmTalk.Controls;
using Newtonsoft.Json;
using System.Threading;
using WinFrmTalk.Helper;
using WinFrmTalk.Helper.MVVM;
using WinFrmTalk.View.list;

namespace WinFrmTalk.View
{

    public partial class FrmMagent : FrmBase
    {
        #region 变量
        /// <summary>
        /// 当前选中的项
        /// </summary>
        private USEMange SelectItems;
        /// <summary>
        /// 上次选中的项
        /// </summary>
        private USEMange BeforeItem;

        /// <summary>
        /// 当前账号的角色
        /// </summary>
        public int Role;

        /// <summary>
        /// 群组roomId
        /// </summary>
        private string roomId;

        /// <summary>
        /// 当前用户的userid
        /// </summary>
        public string CurrentUserid = Applicate.MyAccount.userId;

        /// <summary>
        /// 等待符
        /// </summary>
        private LodingUtils loding;

        /// <summary>
        /// 禁言时间
        /// </summary>
        private long TalkTime = 0;
        /// <summary>
        /// friend类
        /// </summary>
        private Friend mfriend;

        /// <summary>
        /// 群成员list集合
        /// </summary>
        private List<RoomMember> memberLst = new List<RoomMember>();

        /// <summary>
        /// 控件list集合
        /// </summary>
       // private List<Control> member = new List<Control>();
        /// <summary>
        /// 当前的位置
        /// </summary>
       // private Point currentpoint = new Point();

        /// <summary>
        /// 刷新得时间
        /// </summary>
       // private int Refreshtime;
        #endregion
        public FrmMagent()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            refresh();//上拉刷新
            mAdapter = new MemberMangeListAdapter();
        }

        private MemberMangeListAdapter mAdapter;
        private void RegistNotiy()
        {
            //按回执更新已读消息状态
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_ROOM_CHANGE_MESSAGE, item => Getmonitor(item));
            //Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_ROOM_CHANGE_MESSAGE, item => Getmonitor(item));
        }

        /// <summary>
        /// 监听
        /// </summary>
        /// <param name="msg"></param>
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

        #region 监听新消息刷新界面
        /// <summary>
        /// 监听到有新消息时
        /// </summary>
        /// <param name="msg"></param>
        public void MainNotiy(MessageObject msg)
        {
            bool readed = "1".Equals(msg.content);
            bool islook = "0".Equals(msg.content);
            int show = (readed == true) ? 1 : 0;
            USEMange use = new USEMange();
            switch (msg.type)
            {

                case kWCMessageType.RoomReadVisiblity://显示阅读人数
                                                      //更新界面的选中按钮
                    checkReaded.Checked = readed;
                    mfriend.UserId = msg.objectId;
                    mfriend.ShowRead = show;
                    mfriend.UpdateShowRead();
                    break;
                case kWCMessageType.RoomIsVerify://群验证

                    checkInviteSure.Checked = readed;//更新数据库
                    mfriend.UserId = msg.objectId;//设置RoomJid

                    mfriend.IsNeedVerify = show;
                    mfriend.UpdateNeedVerify();//群邀请确认
                    break;
                case kWCMessageType.RoomAdmin://管理员
                    //1.设置和取消管理员（当前账号）
                    //2.某个成员被取消设置成了管理员
                    if (msg.content == "0")//取消管理员
                    {
                        if (msg.toUserId.Equals(msg.myUserId))//自己被取消
                        {
                            Role = 3;
                            Applicate.userlst.Remove(mfriend.UserId);
                            this.Close();
                            this.Dispose();
                        }
                        else//别人被取消管理员
                        {
                            int i = mAdapter.GetIndexByFriendId(msg.toUserId);
                            if (i > -1)
                            {

                                //判断是否被创建
                                if (palMember.DataCreated(i))
                                {
                                    use = palMember.GetItemControl(i) as USEMange;
                                    use.Tag = 3.ToString();//刷新ui
                                }
                                else
                                {
                                    mAdapter.GetDatas(i).role = 3;//更新数据源
                                }
                            }

                        }
                    }
                    else
                    {
                        if (msg.toUserId.Equals(msg.myUserId))//
                        {
                            Role = 2;
                        }
                        else//别人被设置为管理员
                        {
                            int i = mAdapter.GetIndexByFriendId(msg.toUserId);
                            if (i > -1)
                            {

                                //判断是否被创建
                                if (palMember.DataCreated(i))
                                {
                                    use = palMember.GetItemControl(i) as USEMange;
                                    use.Tag = 2.ToString();//刷新ui
                                }
                                else
                                {
                                    mAdapter.GetDatas(i).role = 2;//更新数据源
                                }
                            }
                        }
                    }
                    break;
                case kWCMessageType.RoomIsPublic://公开群
                    if (msg.roomJid == mfriend.UserId)
                    {
                        checkRoomPublic.Checked = islook;
                    }

                    break;
                case kWCMessageType.RoomInsideVisiblity://显示群内成员

                    checkShowMember.Checked = readed;
                    mfriend.UpdateShowMember(show);//更新数据库

                    break;
                case kWCMessageType.RoomUserRecommend://是否允许发送名片

                    checkPrive.Checked = readed;


                    //  mfriend.updatere(show);//更新数据库

                    break;
                case kWCMessageType.RoomMemberBan://禁言成员
                    break;
                case kWCMessageType.RoomDismiss://解散
                    Applicate.userlst.Remove(mfriend.UserId);
                    this.Close();
                    break;
                case kWCMessageType.RoomAllBanned://群组全员禁言 
                    checktalktime.Checked = readed;
                    break;
                case kWCMessageType.RoomAllowMemberInvite://是否允许群内普通成员邀请陌生人
                    checkAllowmembertoInvi.Checked = readed;
                    break;

                case kWCMessageType.RoomManagerTransfer://转让群主

                    //   msg.content = UIUtils.QuotationName(msg.toUserName) + "已成为新群主";
                    if (msg.content == "0")//
                    {
                        if (msg.toUserId.Equals(msg.myUserId))//自己成为群主
                        {
                            Role = 1;

                        }
                        else//别人成为群主
                        {

                            int i = mAdapter.GetIndexByFriendId(msg.toUserId);
                            if (i > -1)
                            {

                                //判断是否被创建
                                if (palMember.DataCreated(i))
                                {
                                    use = palMember.GetItemControl(i) as USEMange;
                                    use.Tag = 1.ToString();//刷新ui
                                }
                                else
                                {
                                    mAdapter.GetDatas(i).role = 1;//更新数据源
                                }
                            }

                        }
                    }
                    RoomMember oldgroomhoste = new RoomMember { roomId = roomId, userId = msg.fromUserId };//旧群主
                    oldgroomhoste = oldgroomhoste.GetRommMember();
                    oldgroomhoste.role = 3;
                    oldgroomhoste.UpdateRole();
                    RoomMember newgroomhoste = new RoomMember { roomId = roomId, userId = msg.toUserId };//新群主
                    newgroomhoste = newgroomhoste.GetRommMember();
                    newgroomhoste.role = 1;
                    newgroomhoste.UpdateRole();
                    break;

                case kWCMessageType.RoomAllowConference://是否允许群会议
                    checkConference.Checked = readed;
                    mfriend.UpdateAllowConference(show);
                    break;
                case kWCMessageType.RoomAllowSpeakCourse://是否允许群成员开课

                    checkclass.Checked = readed;
                    mfriend.UpdateAllowSpeakCourse(show);
                    break;
                case kWCMessageType.RoomAllowUploadFile://是否允许普通成员上传文件

                    checkupload.Checked = readed;

                    mfriend.UpdateAllowUploadFile(show);
                    break;
                case kWCMessageType.RoomExit://退群
                    if (msg.toUserId == Applicate.MyAccount.userId)
                    {

                    }
                    else
                    { //某群员退出了群聊
                      // msg.type = kWCMessageType.Remind;

                        // LoadGroupData();
                        //谁退出了群
                        string ExiteUserid = msg.toUserId;//退群者的userid
                        for (int i = 0; i < memberLst.Count; i++)
                        {
                            //从列表中移除
                            if (memberLst[i].userId == ExiteUserid)
                            {
                                palMember.RemoveItem(i);
                                mAdapter.RemoveData(i);
                                //member.Remove(member[i]);
                                memberLst.Remove(memberLst[i]);
                                break;
                            }
                        }
                    }
                    break;
                case kWCMessageType.RoomInvite:
                    //在管理界面时有人加进来了
                    string addMemberUserid = msg.toUserId;//加入者userid
                    USEMange men = new USEMange();
                    men.friendData = new Friend();
                    men.friendData.UserId = addMemberUserid;


                    Friend f = new Friend
                    {
                        //  nickName = memberLst[i].nickName,
                        UserId = men.friendData.UserId
                    };
                    bool a = f.ExistsFriend();//判断是否为好友
                    if (!a)
                    {
                        f.NickName = msg.toUserName;
                        men.friendData = f;
                    }
                    else
                    {
                        men.friendData = f.GetByUserId();
                    }

                    // men.friendItem1.friendData = men.friendItem1.friendData.GetByUserId();//获取friend对象



                    if (msg.toUserName == men.friendData.NickName)
                    {
                        men.lblName.Text = null;
                    }
                    else
                    {
                        men.lblName.Text = msg.toUserName;
                    }
                    if (men.friendData.NickName.Length > 5)
                    {
                        men.friendData.NickName = men.friendData.NickName.Substring(0, 4) + "...";
                    }
                    ImageLoader.Instance.DisplayAvatar(f.UserId, men.pic_head);

                    men.MouseDown += USEGrouops_MouseDown;

                    men.Click += FriendItem1_Click;
                    men.Tag = 3;

                    RoomMember roomMember = new RoomMember();
                    roomMember.userId = men.friendData.UserId;
                    roomMember.nickName = men.friendData.NickName;
                    roomMember.role = 3;
                    // member.Add(men);
                    memberLst.Add(roomMember);
                    palMember.InsertItem(memberLst.Count);
                    break;
                //修改昵称
                case kWCMessageType.RoomMemberNameChange:
                    //先移除再添加

                    int index = mAdapter.GetIndexByFriendId(msg.toUserId);
                    if (index > -1)
                    {

                        //判断是否被创建
                        if (palMember.DataCreated(index))
                        {
                            use = palMember.GetItemControl(index) as USEMange;
                            use.lblName.Text = msg.content;//刷新ui
                        }
                        else
                        {
                            mAdapter.GetDatas(index).GroupName = msg.content;//更新数据源
                        }
                    }
                    //  use = (USEMange)mAdapter.OnCreateControl(mAdapter.GetIndexByFriendId(msg.toUserId))
                    //  use.lblName.Text = msg.content;
                    break;
                case kWCMessageType.RoomNameChange://修改群名称
                    string groupname = msg.content;
                    lblName.Text = groupname;
                    break;
            }
        }
        #endregion

        #region
        /// <summary>
        /// 
        /// </summary>
        /// <param name="userId">控件绑定的userid</param>
        /// <returns></returns>
        //根据userid找到当前的控件
        //public Control getmemberfromlst(string userId)
        //{
        //    foreach (Control control in member)
        //    {
        //        if (control is USEMange item)
        //        {
        //            if (item.friendData.userId == userId)
        //                return item;
        //        }
        //    }
        //    return null;
        //}
        #endregion


        #region 加载数据
        /// <summary>
        /// 加载数据
        /// </summary>
        public void LoadData()
        {
            ShowLodingDialog(palMember);
            RegistNotiy();
            MeangeLoadData(true, false);
            this.Show();
        }
        #endregion
        /// <summary>
        /// 等待符
        /// </summary>
        private void ShowLodingDialog(Control con)
        {
            loding = new LodingUtils();
            loding.parent = con;
            loding.Title = "加载中";
            loding.start();
        }
        #region 从接口获取数据
        /// <summary>
        /// 从接口获取数据
        /// </summary>
        /// <param name="first">是否是此界面第一次从接口获取数据</param>
        /// <param name="isfill"></param>
        private void MeangeLoadData(bool first, bool isfill)
        {
            HttpUtils.Instance.InitHttp(this);
            //将数据保存
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/get") //获取群详情
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("roomId", roomId)
                  .Build().AddErrorListener((code, err) =>
                  {
                      loding.stop();
                      //  MessageBox.Show(err);
                  })
               .Execute((sccess, room) =>
                 {
                     //infoCard14.FunctionInfo = GroupName+"AGG";
                     if (sccess)
                     {
                         // LogUtils.Log("data:  " + room.members.Count);

                         FillListData(room, first, isfill);
                         loding.stop();
                         // GetData(room);
                     }
                     else
                     {

                     }
                 });
        }
        #endregion


        #region 
        //获取接口的数据并且 显示出来
        /// <summary>
        /// 
        /// </summary>
        /// <param name = "keys" ></ param >
        /// < param name="first">是否是第一次加载</param>
        /// <param name = "isfill" > 是否需要显示刷新等待符 </ param >
        private void FillListData(Dictionary<string, object> keys, bool first, bool isfill)
        {
            RoomMember roomMember = new RoomMember();

            memberLst = roomMember.TransToMember(keys, roomId);
            //member.Clear();
            for (int i = 0; i < memberLst.Count; i++)
            {
                if (memberLst[i].userId == Applicate.MyAccount.userId)
                {
                    Role = memberLst[i].role;
                    break;
                }
            }
            if (first)
            {
                if ((TimeUtils.CurrentIntTime() - roomMember.talkTime) >= 0)
                {
                    checktalktime.Checked = false;
                }
                else
                {
                    checktalktime.Checked = true;
                }

                //允许普通群成员邀请好友
                if (roomMember.allowInviteFriend == 0)
                {
                    checkAllowmembertoInvi.Checked = false;
                }
                else
                {
                    checkAllowmembertoInvi.Checked = true;
                }
                //允许普通群成员召开会议
                if (roomMember.allowConference == 0)
                {
                    checkConference.Checked = false;
                }
                else
                {
                    checkConference.Checked = true;
                }
                //允许显示群成员
                if (roomMember.showMember == 0)
                {
                    checkShowMember.Checked = false;
                }
                else
                {
                    checkShowMember.Checked = true; ;
                }
                //允许普通群成员私聊
                if (roomMember.allowSendCard == 0)
                {
                    checkPrive.Checked = false;
                }
                else
                {
                    checkPrive.Checked = true;
                }
                //群组成员通知
                if (roomMember.isAttritionNotice == 0)
                {
                    checkMemberNotice.Checked = false;
                }
                else
                {
                    checkMemberNotice.Checked = true;
                }
                //公开群
                if (roomMember.isLook == 0)
                {
                    checkRoomPublic.Checked = true;
                }
                else
                {
                    checkRoomPublic.Checked = false;
                }
                //允许普通成员发起讲课
                if (roomMember.allowSpeakCourse == 0)
                {
                    checkclass.Checked = false;
                }
                else
                {
                    checkclass.Checked = true;
                }
                //允许普通成员上传文件
                if (roomMember.allowUploadFile == 0)
                {
                    checkupload.Checked = false;
                }
                else
                {
                    checkupload.Checked = true;
                }
                //显示已读
                if (roomMember.showRead == 0)
                {
                    checkReaded.Checked = false;
                }
                else
                {
                    checkReaded.Checked = true;
                }
                //群验证
                if (roomMember.isNeedVerify == 0)
                {
                    checkInviteSure.Checked = false;
                }
                else
                {
                    checkInviteSure.Checked = true;

                }
                //音视频

                ImageLoader.Instance.DisplayGroupAvatar(mfriend.UserId, roomId, pics);

                //ImageLoader.Instance.DisplayAvatar(roomId, pics);//群图像

                lblName.Text = roomMember.GroupName.ToString();//群名称
            }
            // ShowLodingDialog(palMember);

            putdata(memberLst, isfill);


            //  loding.stop();

            if (Role == 1)
            {
                menuiteminvisible.Visible = true;

            }
            else
            {
                MenuItemTran.Visible = false;
                MenuItemMeange.Visible = false;
                menuiteminvisible.Visible = false;
            }

            checkReaded.Click += checkchange;//已读
            checkInviteSure.Click += checkchange;//群验证
            checkPrive.Click += checkchange;//普通成员邀请好友
            checkMemberNotice.Click += checkchange;//减员通知
            checkConference.Click += checkchange;//发起会议
            checkShowMember.Click += checkchange;//显示群成员
            checkRoomPublic.Click += checkchange;//私密群
            checkupload.Click += checkchange;//普通成员上传文件
            checkclass.Click += checkchange;//讲课

            checkAllowmembertoInvi.Click += checkchange;//普通成员邀请好友
            checktalktime.Click += Checktalktime_CheckedChanged;//全体禁言

            this.Show();
        }
        #endregion
        /// <summary>
        ///  成员信息显示在面板中
        /// </summary>
        /// <param name="memberLst">群成员列表</param>
        /// <param name="isfill">是否需要显示刷新等待符</param>
        private void putdata(List<RoomMember> memberLst, bool isfill)
        {

            // ShowLodingDialog(palMember);
            mAdapter.SetMaengForm(this);
            mAdapter.BindDatas(memberLst);
            palMember.SetAdapter(mAdapter);
            //loding.stop();
        }
        /// <summary>
        /// 鼠标离开事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void Use_MouseLeave(object sender, EventArgs e)
        {
            USEMange usemange = (USEMange)sender;
            // use.BackColor = Color.Transparent;
            if (!usemange.IsSelected)
            {
                usemange.BackColor = Color.Transparent;

            }
        }

        USEMange use = new USEMange();

        /// <summary>
        /// 鼠标悬停事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void USEMange_MouseEnter(object sender, EventArgs e)
        {
            USEMange usemange = (USEMange)sender;

            if (!usemange.IsSelected)
            {
                if (use != null)
                {
                    use.BackColor = Color.Transparent;
                }
                usemange.BackColor = ColorTranslator.FromHtml("#D8D8D9");//悬浮颜色
                use = usemange;
            }
        }

        #region 显示数据
        /// <summary>
        /// 将数据放入控件上并给显示出来
        /// </summary>
        /// <param name="firstNum"></param>
        /// <param name="firstNum">第一次加载的个数</param>
        /// <param name="ScollNum">每次滚动加载的个数</param>
        /// <param name="isfill">  是否需要显示刷新等待符</param>

        //private void pageload(int firstNum, int ScollNum, bool isfill)
        //{
        //    List<Control> firstControl = new List<Control>();
        //    for (int i = 0; i < firstNum; i++)
        //    {
        //        if (i < member.Count)
        //        {
        //            firstControl.Add(member[i]);
        //        }
        //    }
        //    //第一次加载得个数
        //    palMember.AddViewsToPanel(firstControl, false);
        //    //分页加载，触发监听
        //    palMember.AddScollerBouttom((index) =>
        //    {
        //        firstControl = new List<Control>();
        //        for (int i = 0; i < ScollNum; i++)
        //        {
        //            int num = i + ((index - (firstNum / ScollNum) - 1) * ScollNum) + firstNum;
        //            if (num < member.Count)
        //                firstControl.Add(member[num]);
        //        }
        //        palMember.AddViewsToPanel(firstControl, false);
        //       LogUtils.Log(index);
        //    }, 20, 10);
        //    if (isfill)//需要刷新
        //    {
        //        panel4.Visible = false;
        //        palMember.Location = currentpoint;
        //    }
        //    else
        //    {

        //    }
        //}
        //#endregion


        #region 是否开启全体禁言
        /// <summary>
        /// 是否开启全体禁言
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Checktalktime_CheckedChanged(object sender, EventArgs e)
        {
            if (checktalktime.Checked)
            {
                TalkTime = Convert.ToInt64(TimeUtils.CurrentTimeDouble() + 24 * 60 * 60 * 15);
            }
            else
            {
                TalkTime = 0;
            }
            ShowLodingDialog(panel2);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //获取群详情
            .AddParams("access_token", Applicate.Access_Token)
            .AddParams("roomId", roomId)
            .AddParams("talkTime", TalkTime.ToString())
              .Build().AddErrorListener((code, err) =>
              {
                  loding.stop();

              })
               .ExecuteJson<object>((sccess, data) =>
                {
                    if (sccess)
                    {
                        loding.stop();
                    }
                    else
                    {

                    }
                });
        }
        #endregion
        //清除右键选中
        public void FriendItem1_Click(object sender, EventArgs e)
        {
            if (BeforeItem != null)
            {
                BeforeItem.IsSelected = false;
            }
        }



        /// <summary>
        /// 获取文字宽度
        /// </summary>
        /// <param name="font"></param>
        /// <param name="control"></param>
        /// <param name="str"></param>
        /// <returns></returns>
        private int FontWidth(Font font, Control control, string str)
        {
            using (Graphics g = control.CreateGraphics())
            {
                SizeF siF = g.MeasureString(str, font); return (int)siF.Width;
            }
        }

        #region 绑定右键菜单
        /// <summary>
        /// 绑定右键菜单
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void USEGrouops_MouseDown(object sender, MouseEventArgs e)
        {
            USEMange uSEMange = (USEMange)sender;

            if (BeforeItem != null)
            {
                BeforeItem.IsSelected = false;
            }
            if (e.Button == MouseButtons.Right)
            {

                uSEMange.ContextMenuStrip = menuDel;


                uSEMange.IsSelected = true;
                SelectItems = uSEMange;

                BeforeItem = uSEMange;


                //1.群主,管理员不能被禁言
                //2.管理员不能对自己指定管理员
                //3.管理员可以被取消
                //4.取消禁言
                //群主被取消之后就是普通成员
                if (Role == 1)
                {
                    if (SelectItems.Tag.ToString() == "1")
                    {
                        MenuItemMeange.Visible = false;
                        MenuItemTalk.Visible = false;
                        MenuItemRemove.Visible = false;
                        menuiteminvisible.Visible = false;
                        MenuItemTran.Visible = false;
                    }

                    else
                    {
                        MenuItemMeange.Visible = true;
                        MenuItemTalk.Visible = true;
                        MenuItemRemove.Visible = true;
                        menuiteminvisible.Visible = true;
                        MenuItemTran.Visible = true;

                        if (SelectItems.Tag.ToString() == "2")
                        {
                            MenuItemTalk.Visible = false;

                            MenuItemMeange.Text = "取消管理员";
                            menuiteminvisible.Visible = false;
                        }
                        else if (SelectItems.Tag.ToString() == "4")
                        {
                            MenuItemTalk.Visible = false;
                            menuiteminvisible.Text = "取消指定隐身人";
                        }
                        else
                        {

                            MenuItemMeange.Text = "指定管理员";
                            menuiteminvisible.Visible = true;
                            menuiteminvisible.Text = "指定隐身人";
                        }
                    }

                }
                else
                {
                    if (SelectItems.Tag.ToString() == "1")
                    {
                        MenuItemTran.Visible = false;
                    }
                    else
                    {
                        MenuItemTran.Visible = true;
                    }
                    if (Role == 2)
                    {
                        MenuItemTran.Visible = false;
                        MenuItemMeange.Visible = false;
                        if (SelectItems.Tag.ToString() == "1" || SelectItems.Tag.ToString() == "2")
                        {
                            MenuItemTalk.Visible = false;
                            MenuItemRemove.Visible = false;

                        }
                        else
                        {
                            MenuItemTalk.Visible = true;
                            MenuItemRemove.Visible = true; ;
                        }
                    }
                    else
                    {
                        MenuItemTran.Visible = false;
                        MenuItemMeange.Visible = false;
                        MenuItemInfo.Visible = true;
                        MenuItemTalk.Visible = false;
                        MenuItemRemove.Visible = false; ;
                    }
                }

            }
            if (e.Button == MouseButtons.Left)
            {
                uSEMange.ContextMenuStrip = null;

            }

        }
        #endregion

        #region 移除成员
        /// <summary>
        /// 移除成员
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void TsmFromTomove(object sender, EventArgs e)
        {
            ShowLodingDialog(palMember);//显示等待符


            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/member/delete") //获取群详情
         .AddParams("access_token", Applicate.Access_Token)
         .AddParams("roomId", roomId)
       .AddParams("userId", SelectItems.friendData.UserId)

         .Build().AddErrorListener((code, err) =>
         {
             loding.stop();
             //  MessageBox.Show(err);

         })
      .Execute((sccess, room) =>
      {
          if (sccess)
          {
              //通知管理员变更或者指定

              // Messenger.Default.Send(SelectItems.friendItem1, MessageActions.Room_UPDATE_ROOM_DELETE);
              loding.stop();
              for (int i = 0; i < memberLst.Count; i++)
              {
                  if (memberLst[i].userId == SelectItems.friendData.UserId)
                  {
                      palMember.RemoveItem(i);

                      //   member.Remove(member[i]);
                      memberLst.Remove(memberLst[i]);
                      break;
                  }
              }
          }
          else
          {

          }

      });
        }
        #endregion

        /// <summary>
        /// 设置friend
        /// </summary>
        /// <param name="friend"></param>
        internal void SetRoomData(Friend friend)
        {

            mfriend = friend;
            roomId = friend.RoomId;
        }

        /// <summary>
        ///   查看详情
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void TSMseeinfo_Click(object sender, EventArgs e)
        {

            FrmFriendsBasic frmFriendsBasic = new FrmFriendsBasic();
            string userid = SelectItems.friendData.UserId;
            frmFriendsBasic.ShowUserInfoById(userid);
        }


        #region  转让群主
        //转让群主
        //群主转让之后，这时我的角色

        /// <summary>
        /// 1.转让群主成功之后我的身份变为普通成员，此时的右键菜单只能查看成员信息
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void TSMtransfer_Click(object sender, EventArgs e)
        {
            string beforeRole = SelectItems.Tag.ToString(); //选中时的角色
            ShowLodingDialog(palMember);
            ToolStripMenuItem toolStripMenuItem = (ToolStripMenuItem)sender;
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/transfer") //获取群详情
           .AddParams("access_token", Applicate.Access_Token)
           .AddParams("roomId", roomId)
         .AddParams("toUserId", SelectItems.friendData.UserId)
           .Build().AddErrorListener((code, err) =>
           {
               loding.stop();
               //MessageBox.Show(err);
               //角色保持不变
               Role = 1;
               SelectItems.Tag = beforeRole;
           })
           .Execute((sccess, data) =>
           {
               if (sccess)
               {
                   //通知群主转让
                   toolStripMenuItem.Visible = false;
                   SelectItems.Tag = "1";
                   Role = 3;
                   //更新群主的角色
                   RoomMember oldgroomhoste = new RoomMember { roomId = roomId, userId = Applicate.MyAccount.userId };//旧群主
                   oldgroomhoste = oldgroomhoste.GetRommMember();
                   oldgroomhoste.role = 3;
                   oldgroomhoste.UpdateRole();
                   RoomMember newgroomhoste = new RoomMember { roomId = roomId, userId = SelectItems.friendData.UserId };//新群主
                   newgroomhoste = newgroomhoste.GetRommMember();
                   newgroomhoste.role = 1;
                   newgroomhoste.UpdateRole();

                   Applicate.userlst.Remove(mfriend.UserId);
                   loding.stop();
                   this.Dispose();
                   this.Close();
                   //Messenger.Default.Send(SelectItems.friendItem1, MessageActions.Room_UPDATE_ROOM_DELETE);

               }
               else
               {

               }
           });
        }
        #endregion



        #region 设置管理员(指定/取消)
        /// <summary>
        ///1.如果当前的成员不是管理员为指定管理员，反之取消管理员
        ///2.管理员可以多次设置
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void TSMAdmin_Click(object sender, EventArgs e)
        {
            string beforeRole = SelectItems.Tag.ToString(); //选中时的角色


            ToolStripMenuItem toolStripMenuItem = (ToolStripMenuItem)sender;
            string type = "0";
            string menultemtext = toolStripMenuItem.Text;
            //刷新当前的角色
            if (toolStripMenuItem.Text == "指定管理员")
            {
                toolStripMenuItem.Text = "取消管理员";
                SelectItems.Tag = "2";
                type = "2";


                // MenuItemMeange

            }
            else if (toolStripMenuItem.Text == "取消管理员")
            {
                toolStripMenuItem.Text = "指定管理员";
                SelectItems.Tag = "3";
                type = "3";

            }


            ShowLodingDialog(palMember);


            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/set/admin") //获取群详情
         .AddParams("access_token", Applicate.Access_Token)
         .AddParams("roomId", roomId)
       .AddParams("touserId", SelectItems.friendData.UserId)
       .AddParams("type", type)
         .Build().AddErrorListener((code, err) =>
         {
             loding.stop();
             //MessageBox.Show(err);
             SelectItems.Tag = beforeRole;
             toolStripMenuItem.Text = menultemtext;
         })
      .Execute((sccess, room) =>
            {
                if (sccess)
                {
                    //通知管理员变更或者指定

                    // Messenger.Default.Send(SelectItems.friendItem1, MessageActions.Room_UPDATE_ROOM_DELETE);
                    loding.stop();
                }
                else
                {

                }

            });
        }
        #endregion
        ///右键菜单刷新之后立即刷新

        #region 成员禁言
        /// <summary>
        /// 成员禁言（禁言的时间）
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void MemberNoTalk(object sender, EventArgs e)
        {

            ToolStripMenuItem menuitem = (ToolStripMenuItem)sender;
            string tag = menuitem.Tag.ToString();
            double SettalkTime = 0;//设置禁言时间
            int daysends = 24 * 60 * 60;
            switch (tag)
            {
                case "1":
                    SettalkTime = 0;//不禁言
                    break;
                case "2":
                    SettalkTime = daysends / 48;//禁言30分钟
                    break;
                case "3":
                    SettalkTime = daysends / 24;//禁言1小时
                    break;
                case "4":
                    SettalkTime = daysends;//禁言1天
                    break;
                case "5":
                    SettalkTime = daysends * 3;//禁言3天
                    break;

            }
            long talkTime = Convert.ToInt64(TimeUtils.CurrentTimeDouble() + SettalkTime);//禁言结束的时间
            ShowLodingDialog(palMember);//显示等待符
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/member/update") //获取群详情
        .AddParams("access_token", Applicate.Access_Token)
        .AddParams("roomId", roomId)
        .AddParams("userId", SelectItems.friendData.UserId)
        .AddParams("talkTime", talkTime.ToString())
        .Build().AddErrorListener((code, err) =>
        {
           loding.stop();
           //   MessageBox.Show(err);
        })
       .ExecuteJson<object>((sccess, data) =>
        {
            if (sccess)
            {
                loding.stop();
            }
            else
            {

            }

        });
        }
        #endregion

        #region 更新群设置信息
        /// <summary>
        ///   更新群设置信息
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void checkchange(object sender, EventArgs e)
        {
            USEToggle SelectInfo = (USEToggle)sender; string tag = SelectInfo.Tag.ToString();
            int dataValue = SelectInfo.Checked ? 1 : 0;
            int islock = SelectInfo.Checked ? 0 : 1;

            switch (tag)
            {
                case "1"://显示已读人数
                    updateReaded(dataValue);
                    break;
                case "2"://群组邀请确认
                    UpdateinviteSure(dataValue);
                    break;
                case "3"://群组成员通知
                    updateMemberNotic(dataValue);
                    break;
                case "4"://允许私聊
                    updateallowSendCard(dataValue);
                    break;
                case "5"://允许显示群成员
                    updateshowmember(dataValue);
                    break;
                case "6":
                    updateConfence(dataValue);//会议
                    break;
                case "7":
                    TalkTime = Convert.ToInt32(TimeUtils.CurrentTimeDouble() + 24 * 60 * 60 * 15);
                    break;
                case "8":
                    updateRoomLook(islock);
                    break;
                case "9"://音视频

                    LocalDataUtils.SetBoolData(roomId + "autio_video" + CurrentUserid, SelectInfo.Checked);
                    break;
                case "10"://上传群文件
                    updateuploadFile(dataValue);
                    break;
                case "11"://讲课
                    updateSpeakCourse(dataValue);
                    break;
                case "12"://群成员邀请好友
                    updateAllowInvite(dataValue);
                    break;
            }

        }

        /// <summary>
        ///  群验证
        /// </summary>
        /// <param name="isNeedVerify">是否开启群验证</param>
        private void UpdateinviteSure(int isNeedVerify)
        {
            // 显示等待符
            ShowLodingDialog(panel2);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //更新群
   .AddParams("access_token", Applicate.Access_Token)
   .AddParams("roomId", roomId)
   .AddParams("isNeedVerify", isNeedVerify.ToString())
   .Build().AddErrorListener((code, err) =>
   {

   })
  .Execute((sccess, data) =>
  {
      if (sccess)
      {
          loding.stop();
          mfriend.IsNeedVerify = isNeedVerify;
          mfriend.UpdateNeedVerify();
      }
      else
      {


      }

  });

        }
        #endregion


        #region 是否开启讲课 
        /// <summary>
        ///   讲课
        /// </summary>
        /// <param name="allowSpeakCourse">是否开启讲课 1.允许 0.不允许</param>
        private void updateSpeakCourse(int allowSpeakCourse)
        {
            ShowLodingDialog(panel2);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //获取群详情
   .AddParams("access_token", Applicate.Access_Token)
   .AddParams("roomId", roomId)
 .AddParams("allowSpeakCourse", allowSpeakCourse.ToString())
   .Build().AddErrorListener((code, err) =>
   {
       loding.stop();
       // MessageBox.Show(err);

   })
  .Execute((sccess, data) =>
   {
       if (sccess)
       {
           loding.stop();
           mfriend.UpdateAllowSpeakCourse(allowSpeakCourse);
       }
       else
       {


       }

   });
        }
        #endregion



        #region 允许普通成员上传文件
        /// <summary>
        ///   允许普通成员上传文件
        /// </summary>
        /// <param name="allowUploadFile">允许普通成员上传文件 1.允许 0.不允许</param>
        private void updateuploadFile(int allowUploadFile)
        {
            ShowLodingDialog(panel2);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //获取群详情
   .AddParams("access_token", Applicate.Access_Token)
   .AddParams("roomId", roomId)
 .AddParams("allowUploadFile", allowUploadFile.ToString())
  .Build().AddErrorListener((code, err) =>
  {
      loding.stop();


  })
   .Execute((sccess, data) =>
   {
       if (sccess)
       {
           loding.stop();

           mfriend.UpdateAllowUploadFile(allowUploadFile);
       }
       else
       {


       }

   });
        }
        #endregion


        #region 显示消息已读
        /// <summary>
        /// 显示消息已读
        /// </summary>
        /// <param name="Readed">是否显示消息已读 1.显示 0.不显示</param>
        public void updateReaded(int Readed)
        {
            ShowLodingDialog(panel2);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //获取群详情
     .AddParams("access_token", Applicate.Access_Token)
     .AddParams("roomId", roomId)
   .AddParams("showRead", Readed.ToString())
   .Build().AddErrorListener((code, err) =>
   {
       loding.stop();

   })
     .Execute((sccess, data) =>
     {
         if (sccess)
         {
             loding.stop();
             mfriend.ShowRead = Readed;
             mfriend.UpdateShowRead();
         }
         else
         {

         }

     });
        }
        #endregion

        #region
        /// <summary>
        ///  允许成员召开会议
        /// </summary>
        /// <param name="allowConference">是否允许召开会议 1.允许 0.不允许</param>
        public void updateConfence(int allowConference)
        {
            ShowLodingDialog(panel2);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //获取群详情
     .AddParams("access_token", Applicate.Access_Token)
     .AddParams("roomId", roomId)
   .AddParams("allowConference", allowConference.ToString())
     .Build().AddErrorListener((code, err) =>
     {
         loding.stop();
     })
   .Execute((sccess, data) =>
     {
         if (sccess)
         {
             loding.stop();
             mfriend.UpdateAllowConference(allowConference);
         }
         else
         {

         }

     });
        }
        #endregion


        #region 允许成员邀请好友
        /// <summary>
        /// 允许成员邀请好友
        /// </summary>
        /// <param name="allowInviteFriend">是否允许邀请好友 1.允许 0.不允许</param>
        public void updateAllowInvite(int allowInviteFriend)
        {
            ShowLodingDialog(panel2);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //获取群详情
     .AddParams("access_token", Applicate.Access_Token)
     .AddParams("roomId", roomId)
   .AddParams("allowInviteFriend", allowInviteFriend.ToString())
    .Build().AddErrorListener((code, err) =>
    {
        loding.stop();
    })
     .Execute((sccess, data) =>
     {
         if (sccess)
         {
             loding.stop();
             mfriend.UpdateAllowInviteFriend(allowInviteFriend);
         }
         else
         {

         }

     });
        }
        #endregion

        #region 允许私聊
        /// <summary>
        ///   允许私聊
        /// </summary>
        /// <param name="allowSendCard">是否允许好友私聊 1.允许 0.不允许</param>
        public void updateallowSendCard(int allowSendCard)
        {
            ShowLodingDialog(panel2);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //获取群详情
     .AddParams("access_token", Applicate.Access_Token)
     .AddParams("roomId", roomId)
   .AddParams("allowSendCard", allowSendCard.ToString())
    .Build().AddErrorListener((code, err) =>
    {
        loding.stop();

        // MessageBox.Show("设置允许私聊失败");
        //  checkPrive.CheckedChanged -= checkchange;
        // checkPrive.Checked = checkState(Readed);
        // checkPrive.CheckedChanged += checkchange;

    })
     .Execute((sccess, data) =>
     {
         if (sccess)
         {
             mfriend.UpdateAllowSendCard(allowSendCard);
             loding.stop();
         }
         else
         {

         }

     });
        }
        #endregion

        #region 群是否公开
        /// <summary>
        ///   群是否公开
        /// </summary>
        /// <param name="isLook">是否公开群1.公开0.不公开</param>
        public void updateRoomLook(int isLook)
        {
            ShowLodingDialog(panel2);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //获取群详情
     .AddParams("access_token", Applicate.Access_Token)
     .AddParams("roomId", roomId)
   .AddParams("isLook", isLook.ToString())
    .Build().AddErrorListener((code, err) =>
    {
        loding.stop();

        // MessageBox.Show(err);

        //// checkRoomPublic.CheckedChanged -= checkchange;
        //// checkRoomPublic.Checked = checkState(Readed);
        //// checkRoomPublic.CheckedChanged += checkchange;

    })
     .Execute((sccess, data) =>
     {
         if (sccess)
         {
             loding.stop();
             mfriend.UpdateAllowSendCard(isLook);
         }
         else
         {

         }
     });
        }
        #endregion


        #region
        /// <summary>
        /// 显示群成员
        /// </summary>
        /// <param name="showMember">是否显示群成员1.显示0.不显示</param>
        private void updateshowmember(int showMember)
        {
            ShowLodingDialog(panel2);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //获取群详情
     .AddParams("access_token", Applicate.Access_Token)
     .AddParams("roomId", roomId)
   .AddParams("showMember", showMember.ToString())
    .Build().AddErrorListener((code, err) =>
    {
        loding.stop();
        //  MessageBox.Show(err,"提示");
        //  checkShowMember.CheckedChanged -= checkchange;
        // checkShowMember.Checked = checkState(Readed);
        //  checkShowMember.CheckedChanged += checkchange;

    })
     .Execute((sccess, data) =>
    {
        if (sccess)
        {
            loding.stop();
            mfriend.UpdateShowMember(showMember);
        }
        else
        {

        }

    });
        }
        #endregion
        /// <summary>
        /// 减员通知
        /// </summary>
        /// <param name="isAttritionNotice"></param>
        private void updateMemberNotic(int isAttritionNotice)
        {
            ShowLodingDialog(panel2);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //获取群详情
    .AddParams("access_token", Applicate.Access_Token)
    .AddParams("roomId", roomId)
  .AddParams("isAttritionNotice", isAttritionNotice.ToString())
   .Build().AddErrorListener((code, err) =>
   {
       loding.stop();
   })
    .Execute((sccess, data) =>
    {
        if (sccess)
        {
            loding.stop();

        }
        else
        {

        }
    });
        }

        #region 设置隐身人
        /// <summary>
        /// 指定隐身人
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void menuiteminvisible_Click(object sender, EventArgs e)
        {
            string beforeRole = SelectItems.Tag.ToString(); //选中时的角色


            ToolStripMenuItem toolStripMenuItem = (ToolStripMenuItem)sender;
            string type = "0";
            string menultemtext = toolStripMenuItem.Text;
            //刷新当前的角色
            if (toolStripMenuItem.Text == "指定隐身人")
            {
                toolStripMenuItem.Text = "取消指定隐身人";
                SelectItems.Tag = "4";
                type = "4";

            }
            else if (toolStripMenuItem.Text == "取消指定隐身人")
            {
                toolStripMenuItem.Text = "指定隐身人";
                SelectItems.Tag = "-1";
                type = "-1";

            }

            /*  if (myevent != null)
              {
                  myevent(toolStripMenuItem,toolStripMenuItem.Text);
              }*/
            ShowLodingDialog(panel2);


            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/setInvisibleGuardian") //设置隐身人
         .AddParams("access_token", Applicate.Access_Token)
         .AddParams("roomId", roomId)
       .AddParams("touserId", SelectItems.friendData.UserId)
       .AddParams("type", type)
        .Build().Execute((sccess, room) =>
     {
         if (sccess)
         {
             //通知管理员变更或者指定
             RoomMember roomMember = new RoomMember { roomId = roomId, userId = SelectItems.friendData.UserId };
             roomMember = roomMember.GetRommMember();
             if (type == "4")
             {
                 roomMember.role = 4;
             }
             else if (type == "-1")
             {
                 roomMember.role = 3;
             }
             roomMember.UpdateRole();
             // Messenger.Default.Send(SelectItems.friendItem1, MessageActions.Room_UPDATE_ROOM_DELETE);

             //是否需要发广播通知非群主的界面刷新
             loding.stop();
         }
         else
         {

         }

     });
        }
        #endregion


        #region 上拉刷新
        /// <summary>
        /// 
        /// </summary>
        public void refresh()
        {
            //1.获取滚动到最顶部的事件//2.刷新清空列表重新加载//3.加载完成移除第一行（获取到的是整个接口的数据 ，但是仍然是分页加载）
            //palMember.AddScollerTop(() =>
            //{
            //    //上次刷新的时间和当前刷新的时间之间的间隔为5，Refreshtime第一次刷新
            //    if (TimeUtils.CurrentIntTime() - Refreshtime > 5 || (Refreshtime == 0))
            //    {
            //        member.Clear();
            //        palMember.ClearTabel();
            //        Point p = new Point();
            //        p = palMember.Location;
            //        currentpoint = palMember.Location;
            //        panel4.Visible = true;
            //        p.Y = p.Y + 80;
            //        palMember.Location = p;//等待符面板显示，成员面板下移

            //        //memsize.Height -= 80;
            //        //  palMember.Size = memsize;
            //        ShowLodingDialog(panel4);


            //        Refreshtime = TimeUtils.CurrentIntTime();

            //        MeangeLoadData(false, true);//重新加载数据，等待框面板隐藏，成员面板上移
            //    }


            //});

        }
        #endregion

        #region 关闭窗口反注册
        private void FrmMagent_FormClosed(object sender, FormClosedEventArgs e)
        {
            Applicate.userlst.Remove(mfriend.UserId);
            Messenger.Default.Unregister(this);
        }



        #endregion

        private void panel2_Paint(object sender, PaintEventArgs e)
        {

        }

        private void lblnewsSend_Click(object sender, EventArgs e)
        {
            cmsnewssendway.Show(lblnewsSend, lblnewsSend.Width - cmsnewssendway.Width, lblnewsSend.Height);
        }
    }
}
#endregion