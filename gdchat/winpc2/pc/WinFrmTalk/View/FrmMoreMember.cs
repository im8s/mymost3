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
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;
using System.Threading;
using WinFrmTalk.View.list;

namespace WinFrmTalk.View
{
    public delegate void DelData();

    public partial class FrmMoreMember : FrmBase
    {
        //  int pageindex = 0;

        MemberLstAdapter mAdapter;


        public List<MembersItem> membersItems = new List<MembersItem>();
        List<RoomMember> RoomMemberLst = new List<RoomMember>();

        public Friend RoleHoste = new Friend();//群主
        private string roomid; // 当前roomid
        public Friend mfriend; // 当前群组信息

        public int Role { get; set; }// 当前登录账号在群组中的角色

        // 是否正在删除群成员
        public bool issum { get; set; }

        private LodingUtils loding;//等待符


        public FrmMoreMember()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标

            mAdapter = new MemberLstAdapter();

            palGroupMenber.FooterRefresh += LoadNextPageMenber;

            RegisterRoomChangeMsg();
        }


        public void SetRoom(Friend friend)
        {
            roomid = friend.RoomId;
            mfriend = friend;
        }

        //注册群控制消息监听
        private void RegisterRoomChangeMsg()
        {
            //注册群控制消息监听
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_ROOM_CHANGE_MESSAGE, item => Getmonitor(item));
        }

        public void LoadGroupMember()
        {
            GetMeanger();
            LoadHttpRoomData(false);
        }
        public List<RoomMember> MeangeLst = new List<RoomMember>();
        private void GetMeanger()
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/getRoom") //获取群详情
               .AddParams("access_token", Applicate.Access_Token)
               .AddParams("roomId", roomid)
               .Build()
               .Execute((success, result) =>
               {
                   string mendata = UIUtils.DecodeString(result, "members");
                   List<RoomMember> members = JsonConvert.DeserializeObject<List<RoomMember>>(mendata);
                   if (members == null || members.Count < 50)
                   {
                       isLoading = true;
                   }

                   MeangeLst = members;
               });
        }

        // 加载第一页群成员数据
        private void LoadHttpRoomData(bool isload)
        {
            // 显示等待框
            ShowLodingDialog(palGroupMenber);
            // 设置为正在加载中
            isLoading = true;
            //获取群管理成员
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/get")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("roomId", roomid)
                .AddParams("pageIndex", "0")
                .AddParams("pageSize", "50")
                .Build()
                .Execute((sccess, room) =>
                {
                    isLoading = false;
                    if (sccess)
                    {
                        // 当前用户在群的信息

                        string member = UIUtils.DecodeString(room, "member");
                        var currtaccount = JsonConvert.DeserializeObject<RoomMember>(member);
                        Role = currtaccount.role;
                        Console.WriteLine("获取我在群组中的身份： " + this.Role);

                        // 群成员信息
                        string mendata = UIUtils.DecodeString(room, "members");
                        List<RoomMember> members = JsonConvert.DeserializeObject<List<RoomMember>>(mendata);
                        if (members == null || members.Count < 50)
                        {
                            isLoading = true;
                        }
                        DataFilter(members, false);

                        btnAdd.BackgroundImage = WinFrmTalk.Properties.Resources.Add_01;
                        btnAdd.Click += BtnAdd_Click1;
                    }

                    loding.stop();
                });
        }

        // 分页加载群成员
        private void LoadNextPageMenber()
        {
            if (isLoading)
            {
                return;
            }

            isLoading = true;
            ShowLodingDialog(palGroupMenber);
            // 分页获取群成员
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/member/getMemberListByPage")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("roomId", roomid)
                .AddParams("joinTime", GetLastTime())
                .AddParams("pageSize", "50")
                .Build()
                .ExecuteJson<List<RoomMember>>((sccess, datas) =>
                {
                    isLoading = false;
                    if (sccess)
                    {
                        if (datas.Count < 50)
                        {
                            isLoading = true;
                        }
                        DataFilter(datas, true);
                    }

                    loding.stop();
                });
        }


        // 把数据显示到控件上
        private void DataFilter(List<RoomMember> data, bool append)
        {
            if (UIUtils.IsNull(data))
            {
                return;
            }
            List<RoomMember> templst = new List<RoomMember>();
            int x = data.Count;
            for (int i = x - 1; i > -1; i--)
            {
                data[i].roomId = roomid;
                data[i].InsertOrUpdate();
                templst.Add(data[i]);

                // 我不是群主，隐身人不可见
                if (data[i].role == 4 && Role != 1)
                {
                    templst.Remove(data[i]);
                }

                // 删除群成员的时候把自己挑出去
                if (issum && data[i].userId.Equals(Applicate.MyAccount.userId))
                {
                    templst.Remove(data[i]);
                }
                if ((data[i].role == 1 || data[i].role == 2))
                {
                    templst.Remove(data[i]);
                }

            }
            data = templst;

            if (append || issum)
            {
                RoomMemberLst.AddRange(data);
            }
            else
            {
                MeangeLst.AddRange(data);
                RoomMemberLst = MeangeLst;
            }
            BindListView(append, data.Count);
        }


        private void BindListView(bool append, int appendSize)
        {
            mAdapter.SetMenberForm(this);

            // 分析，从服务器获取的数据一定不重复
            //List<RoomMember> members = RoomMemberLst.Distinct(new Comparer()).ToList();
            //RoomMemberLst = members;

            if (append)
            {
                palGroupMenber.InsertRange(RoomMemberLst.Count - appendSize - 1);
            }
            else
            {
                mAdapter.BindDatas(RoomMemberLst);
                palGroupMenber.SetAdapter(mAdapter);
            }
        }

        private string GetLastTime()
        {

            if (UIUtils.IsNull(RoomMemberLst))
            {
                return "";

            }

            return RoomMemberLst[RoomMemberLst.Count - 1].createTime.ToString();
        }

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


        // 处理群控制消息
        public void MainNotiy(MessageObject msg)
        {
            UseRoleMember rolemember = new UseRoleMember();

            switch (msg.type)
            {
                case kWCMessageType.RoomManagerTransfer://转让群主
                    //新群主影响了两个地方1.列表中的角色2.如果当前界面删除时候角色被转换(可能是管理员)
                    string Newuserid = msg.toUserId;//新群主的userid
                    string OldUserid = msg.fromUserId;
                    RoomMember roomhoste = new RoomMember();
                    RoomMember roomperson = new RoomMember();
                    for (int i = 0; i < RoomMemberLst.Count; i++)
                    {
                        //将新群主的位置跟原群主的位置进行交换
                        if (RoomMemberLst[i].userId == OldUserid)
                        {
                            //转让群主，1.新群主，原群主成为普通成员
                            //RoomMemberLst[i].role = 1;//新角色

                            roomhoste = RoomMemberLst[i];

                            palGroupMenber.RemoveItem(i);

                            RoomMemberLst.Remove(RoomMemberLst[i]);


                            UseRoleMember useRoleMember = new UseRoleMember();
                            useRoleMember.friendData = new Friend { UserId = Newuserid, NickName = msg.toUserName };

                            useRoleMember.CurrentRole = "群主";

                            //  MemberList.Insert(i, useRoleMember);
                            RoomMemberLst.Insert(i, roomhoste);
                            palGroupMenber.InsertItem(i);

                        }
                        if (RoomMemberLst[i].userId == Newuserid)
                        {
                            //转让群主，1.新群主，原群主成为普通成员
                            //RoomMemberLst[i].role = 1;//新角色

                            roomperson = RoomMemberLst[i];

                            palGroupMenber.RemoveItem(i);
                            // MemberList.Remove(MemberList[i]);
                            RoomMemberLst.Remove(RoomMemberLst[i]);


                            UseRoleMember useRoleMember = new UseRoleMember();
                            useRoleMember.friendData = new Friend { UserId = OldUserid, NickName = msg.fromUserName };
                            useRoleMember.CurrentRole = "普通成员";

                            //  MemberList.Insert(i, useRoleMember);
                            RoomMemberLst.Insert(i, roomperson);
                            palGroupMenber.InsertItem(i);
                            break;

                        }
                    }

                    break;
                case kWCMessageType.RoomAdmin://管理员

                    // 通知聊天记录页刷新
                    string Roletext = "";
                    int j = mAdapter.GetIndexByFriendId(msg.toUserId);
                    if (j > -1)
                    {
                        if (msg.content == "0")//取消管理员
                        {
                            Roletext = "普通成员";

                        }
                        else if (msg.content == "1")//设置管理员
                        {
                            Roletext = "管理员";

                        }
                        rolemember = palGroupMenber.GetItemControl(j) as UseRoleMember;

                        if (palGroupMenber.DataCreated(j))
                        {
                            rolemember = palGroupMenber.GetItemControl(j) as UseRoleMember;
                            rolemember.CurrentRole = Roletext;
                        }
                        else
                        {
                            mAdapter.GetDatas(j).role = 2;//更新数据源
                        }
                    }

                    // rolemember = (UseRoleMember)mAdapter.OnCreateControl(mAdapter.GetIndexByFriendId(msg.toUserId));
                    // if (msg.content == "0")//取消管理员
                    // {
                    //     Roletext = "普通成员";

                    // }
                    // else if (msg.content == "1")//设置管理员
                    // {
                    //     Roletext = "管理员";

                    // }
                    // rolemember.CurrentRole = Roletext;
                    //mAdapter.


                    break;
                case kWCMessageType.RoomExit://退群
                    if (msg.toUserId == Applicate.MyAccount.userId)
                    {
                        //多点登陆时
                    }
                    else
                    { //某群员退出了群聊
                      // msg.type = kWCMessageType.Remind;

                        // LoadGroupData();
                        //谁退出了群
                        int i = mAdapter.GetIndexByFriendId(msg.toUserId);
                        if (i > -1)
                        {

                            rolemember = palGroupMenber.GetItemControl(i) as UseRoleMember;


                            palGroupMenber.RemoveItem(mAdapter.GetIndexByFriendId(msg.toUserId));
                            mAdapter.RemoveData(i);
                        }

                        // RoomMemberLst.Remove(RoomMemberLst[i]);

                    }
                    break;

                case kWCMessageType.RoomDismiss://群解散
                    this.Close();
                    break;
                case kWCMessageType.RoomAllowMemberInvite://允许普通好友邀请好友
                    mfriend.AllowInviteFriend = Convert.ToInt32(msg.content);
                    mfriend.UpdateAllowInviteFriend(Convert.ToInt32(msg.content));
                    break;
                case kWCMessageType.RoomIsVerify://群邀请确认
                    mfriend.IsNeedVerify = Convert.ToInt32(msg.content);
                    mfriend.UpdateNeedVerify();
                    break;
                case kWCMessageType.RoomInvite:
                    //在管理界面时有人加进来了

                    string addMemberUserid = msg.toUserId;//加入者userid
                    UseRoleMember men = new UseRoleMember();
                    men.friendData = new Friend();
                    men.friendData.UserId = addMemberUserid;
                    men.friendData = men.friendData.GetByUserId();//获取friend对象

                    if (men.friendData.NickName.Length > 5)
                    {
                        men.friendData.NickName = men.friendData.NickName.Substring(0, 4) + "...";
                    }

                    ImageLoader.Instance.DisplayAvatar(men.friendData.UserId, men.pic_head);

                    men.Tag = 3;
                    RoomMember roomMember = new RoomMember();
                    roomMember.userId = men.friendData.UserId;
                    roomMember.nickName = men.friendData.NickName;
                    roomMember.role = 3;
                    men.CurrentRole = " 普通成员";
                    //  MemberList.Add(men);
                    RoomMemberLst.Add(roomMember);
                    palGroupMenber.InsertItem(RoomMemberLst.Count - 1);

                    break;
                case kWCMessageType.RoomUserRecommend:
                    mfriend.AllowSendCard = Convert.ToInt32(msg.content);
                    mfriend.UpdateAllowSendCard(Convert.ToInt32(msg.content));
                    break;

                default:
                    return;
            }
        }




        /// <summary>
        /// 使用等待符
        /// </summary>
        private void ShowLodingDialog(Control con)
        {
            loding = new LodingUtils();
            loding.parent = con;
            loding.Title = "加载中";
            loding.start();
        }


        private void BtnAdd_Click1(object sender, EventArgs e)
        {
            if (Role == 4)
            {
                ShowPromptBox("隐身人不允许邀请好友");
            }
            else if (Role == 3 && mfriend.AllowInviteFriend == 0)
            {
                ShowPromptBox("普通成员不允许邀请好友");
            }
            else
            {
                InviteTogroup();//邀请好友
            }
        }

        // 邀请好友
        private void InviteTogroup()
        {
            List<string> datas = new List<string>();
            FrmFriendSelect frmSelect = new FrmFriendSelect();
            frmSelect.StartPosition = FormStartPosition.CenterScreen;
            frmSelect.LoadFriendsData(RoomMemberLst);//分页问题会导致加过的好友仍然在好友选择器中
            frmSelect.AddConfrmListener((Selectdata) =>
            {
                foreach (var item in Selectdata.Keys)
                {
                    datas.Add(item);
                }
               // ShowLodingDialog(palGroupMenber);
                string ss = Newtonsoft.Json.JsonConvert.SerializeObject(datas);

                if (mfriend.IsNeedVerify == 0 || Role == 1)
                {
                    HttpUtils.Instance.InitHttp(this);
                    HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/member/update") //删除群成员

                  .AddParams("access_token", Applicate.Access_Token)
                  .AddParams("roomId", roomid)
                  .AddParams("text", ss)
                    .Build().AddErrorListener((code, err) =>
                    {
                        loding.stop();


                    })
                 .Execute((sccess, data) =>
                 {
                     if (sccess)
                     {
                         //将添加的好友保存到数据库中
                         loding.stop();
                         Messenger.Default.Send(roomid, MessageActions.Room_UPDATE_ROOM_ADD);

                         //data.Update();
                         RoomMember roomMember = new RoomMember();
                         roomMember.roomId = roomid;

                         List<RoomMember> memberList = new List<RoomMember>();

                         foreach (KeyValuePair<string, Friend> a in Selectdata)
                         {
                             RoomMember roomMembers = new RoomMember();
                             roomMembers.roomId = roomid;
                             roomMembers.userId = a.Key;
                             roomMembers.nickName = a.Value.NickName;
                             roomMembers.role = 3;
                             roomMembers.talkTime = 0;
                             roomMembers.sub = 1;
                             roomMembers.offlineNoPushMsg = 0;
                             // roomMembers.remarkName = a.Value.nickName;
                             memberList.Add(roomMembers);
                         }

                         roomMember.AutoInsertOrUpdate(memberList);
                         //同直接
                     }
                     else
                     {

                     }
                 });
                }//开启了群验证
                else
                {
                    FrmROOMVerify frmROOMVerify = new FrmROOMVerify();
                    frmROOMVerify.ShowDialog();
                    List<Friend> friendlst = new List<Friend>();//添加好友的集合
                    if (frmROOMVerify.DialogResult == DialogResult.OK)
                    {
                        string Reson = frmROOMVerify.textReson.Text;//邀请好友的原因
                        foreach (var item in Selectdata.Values)
                        {
                            friendlst.Add(item);
                        }
                        //获取群主
                        ShiKuManager.SendRoomverification(RoleHoste, friendlst, Reson, mfriend.UserId);//发消息
                    }

                }

            });
        }


        // 查看其他群成员信息
        public void Pic_head_Click(object sender, EventArgs e)
        {

            if (mfriend.AllowSendCard == 0 && Role != 1)
            {
                HttpUtils.Instance.ShowTip("当前群组禁止普通成员私聊，不允许查看其他成员信息");
            }
            else
            {
                RoundPicBox pic = (RoundPicBox)sender;
                UseRoleMember uSEpicAddName = (UseRoleMember)pic.Parent;
                FrmFriendsBasic frmFriendsBasic = new FrmFriendsBasic();
                frmFriendsBasic.ShowUserInfoByRoom(uSEpicAddName.friendData.UserId, mfriend.UserId, Role);
                frmFriendsBasic.Show();
            }
        }

        #region 添加自定义控件集合
        #endregion

        public void USEGrouops_Click(object sender, EventArgs e)
        {

            UseRoleMember uSEGrouops = (UseRoleMember)sender;

            string nickname = uSEGrouops.friendData.NickName;
            string selecuserid = uSEGrouops.friendData.UserId;
            if (ShowPromptBox("确定要将" + "“" + nickname + "”" + "移除?"))
            {
                ShowLodingDialog(palGroupMenber);

                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/member/delete") //获取群详情
             .AddParams("access_token", Applicate.Access_Token)
             .AddParams("roomId", roomid)
           .AddParams("userId", selecuserid)
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
                  //1.删除搜索列表中的数据，2.删除搜索之前（大列表）的数据
                  RoomMember Updateroommember = new RoomMember { roomId = roomid, userId = selecuserid };
                  List<string> userids = new List<string>();
                  for (int i = 0; i < result.Count; i++)
                  {
                      if (!userids.Contains(result[i].userId))
                      {
                          userids.Add(RoomMemberLst[i].userId);
                          for (int j = 0; j < RoomMemberLst.Count; j++)
                          {
                              if (result[i].userId == RoomMemberLst[j].userId)
                              {
                                  RoomMemberLst.RemoveAt(j);
                              }
                          }
                          RoomMemberLst.Remove(Updateroommember);
                      }

                  }

                  Updateroommember = Updateroommember.GetRommMember();

                  Updateroommember.DeleteByUserId();
                  int index = mAdapter.GetIndexByFriendId(selecuserid);

                  palGroupMenber.RemoveItem(index);
                  mAdapter.RemoveData(index);

              }
              else
              {

              }

          });
            }
        }

        //鼠标事件
        private void USEGrouops_MouseEnter(object sender, EventArgs e)
        {
            FriendItem friendItem = (FriendItem)sender;
            friendItem.Parent.BackColor = Color.LightGray;
            // throw new NotImplementedException();
        }


        List<RoomMember> result = new List<RoomMember>();
        private string lastSearchText;
        ///群成员搜索
        private void searchControl1_TextChanged(object sender, EventArgs e)
        {

            result = new List<RoomMember>();


            string currText = searchControl1.Text;

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
                BindListView(false, 0);
                return;
            }

            lastSearchText = currText;
            if (!string.IsNullOrEmpty(currText))
            {
                // 加载搜索数据

                for (int i = 0; i < RoomMemberLst.Count; i++)
                {
                    if (RoomMemberLst[i].nickName.Contains(searchControl1.Text.Trim()) ||
                        RoomMemberLst[i].nickName.Contains(searchControl1.Text.Trim().ToUpper()) ||
                        RoomMemberLst[i].nickName.Contains(searchControl1.Text.Trim().ToLower()))
                    {
                        result.Add(RoomMemberLst[i]);
                    }

                }
                mAdapter.SetMenberForm(this);
                mAdapter.BindDatas(result);
                palGroupMenber.SetAdapter(mAdapter);
                //  loding.stop();
            }


        }
        /// <summary> 
        /// 汉字转化为拼音
        /// </summary> 
        /// <param name="str">汉字</param> 
        /// <returns>全拼</returns> 
        public static string GetPinyin(string str)
        {
            string r = string.Empty;
            foreach (char obj in str)
            {
                try
                {
                    //ChineseChar chineseChar = new ChineseChar(obj);
                    //string t = chineseChar.Pinyins[0].ToString();
                    //r += t.Substring(0, t.Length - 1);
                }
                catch
                {
                    r += obj.ToString();
                }
            }
            return r;
        }


        private void palGroupMenber_Load(object sender, EventArgs e)
        {

        }

        //  Point currentpoint = new Point();
        //  private int Refreshtime;
        private bool isLoading;

        public void refresh()
        {

            //palGroupMenber.AddScollerTop(() =>
            //    {

            //      if(TimeUtils.CurrentIntTime()- Refreshtime>5 ||(Refreshtime==0))
            //        {
            //            Point p = new Point();
            //            p = palGroupMenber.Location;
            //            currentpoint = palGroupMenber.Location;
            //            palLoading.Visible = true;
            //            p.Y = p.Y + 80;
            //            palGroupMenber.Location = p;

            //            ShowLodingDialog(palLoading);
            //            palGroupMenber.ClearTabel();
            //            Refreshtime = TimeUtils.CurrentIntTime();

            //            LoadHttpRoomData(true);//当此方法完成后再执行下面的

            //        }

            //    });

        }
        /// <summary>
        /// 关闭窗体
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>

        private void FrmMoreMember_FormClosed(object sender, FormClosedEventArgs e)
        {
            Applicate.Membersuseridlst.Remove(mfriend.UserId);
            Messenger.Default.Unregister(this);//反注册
        }


        public class Comparer : IEqualityComparer<RoomMember>
        {
            public bool Equals(RoomMember x, RoomMember y)
            {
                //这里定义比较的逻辑
                return x.userId == y.userId && x.roomId == y.roomId;
            }

            public int GetHashCode(RoomMember obj)
            {
                //返回字段的HashCode，只有HashCode相同才会去比较
                return obj.userId.GetHashCode();
            }
        }
    }
}

