using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;


namespace WinFrmTalk.View
{
    public partial class FrmBuildGroups : FrmBase
    {
        public static string CloseWindow { get; } = nameof(CloseWindow);
        Dictionary<string, Friend> Selectdata = new Dictionary<string, Friend>();
        
        public Dictionary<string, Friend> friendsList = new Dictionary<string, Friend>();
        // List<Friend> friendsList = new List<Friend>();
        public string Roomid;

        //建群需要传的参数Roomjid,被邀请成员列表，群组名，群组描述
        private List<MembersItem> membersItems;

        public FrmBuildGroups()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            //txtGroupName.ImeMode = ImeMode.NoControl;
            txtGroupDis.ImeMode = ImeMode.NoControl;
            this.TitleNeed = false;
        }

        private void RegisterMessenger()
        {
            //Messenger.Default.Register<bool>(this, CloseWindow, para => App.Current.Dispatcher.Invoke(() => { this.Close(); }));//注册关闭窗口消息
        }

        private void FrmBuildGroups_Load(object sender, EventArgs e)
        {
            // Random random = new Random();
        }

        //需要对输入的参数进行限制
        private void btnInviteFrds_Click(object sender, EventArgs e)
        {
            string name = txtGroupName.Text;
            string roomdesc = txtGroupDis.Text;

            if (name == "" && roomdesc == "")
            {
                ShowTip("群组名称和群描述不能为空");
            }
            else if (roomdesc == "")
            {
                ShowTip("群描述不能为空");
            }
            else if (name == "")
            {
                ShowTip("群名称不能为空");
            }
            else
            {
                // 去选择好友
                Friend friend = new Friend();
                friend.NickName = name;
                friend.Description = roomdesc;

                FrmFriendSelect frmFriendSelect = new FrmFriendSelect();
                frmFriendSelect.max_number = 300;
                
                frmFriendSelect.StartPosition = FormStartPosition.CenterScreen;
                frmFriendSelect.LoadFriendsData();
                this.Close();
                frmFriendSelect.AddConfrmListener((Selectdata) =>
                {
                    List<string> datas = new List<string>();
                    foreach (var item in Selectdata.Keys)
                    {
                        datas.Add(item);
                    }

                    string ss = Newtonsoft.Json.JsonConvert.SerializeObject(datas);
                    // xmpp 建群
                    string jid = ShiKuManager.mSocketCore.CreateGroup(friend.NickName, friend.Description);
                    if (!string.IsNullOrEmpty(jid))
                    {
                        friend.UserId = jid;
                        HttpCreateRoom(friend, ss, Selectdata);
                    }
                });
            }
        }

        private void HttpCreateRoom(Friend friend, string userIds, Dictionary<string, Friend> select)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/add")//新建群组
            .AddParams("jid", friend.UserId)
            .AddParams("access_token", Applicate.Access_Token)
            .AddParams("desc", friend.Description)
            .AddParams("name", friend.NickName)
            //.AddParams("text", userIds) 先建群在去邀请，否则会丢失一些群成员进群的消息
            .AddParams("showRead", "0")
            .AddParams("cityId", "440300")
            .AddParams("countryId", "1")
            .AddParams("provinceId", "440000")
            .AddParams("areaId", "440307")
            .AddParams("longitude", "114.066307")
            .AddParams("latitude", "22.609084")

             .Build().Execute((sccess, data) =>
             {
                 if (sccess)
                 {
                     string roomId = UIUtils.DecodeString(data, "id");
                     HttpUtils.Instance.ShowTip("创建成功");

                     InviteToGroup(roomId, userIds);
                     SaveRoomUsers(roomId, select);
                 }
                 else
                 {
                     MessageBox.Show(data.ToString());
                 }
             });
        }

        private void getMemberFromDB(String Roomid)
        {
            RoomMember member = new RoomMember();
            HttpUtils.Instance.InitHttp(this);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/get") //获取群详情
              .AddParams("access_token", Applicate.Access_Token)
              .AddParams("roomId", Roomid)
              .Build().ExecuteJson<RoomDetails>((sccess, room) =>
                {
                    //infoCard14.FunctionInfo = GroupName+"AGG";

                    if (sccess)
                    {
                        LogUtils.Log("data:  " + room.members.Count);
                        membersItems = room.members;
                        //  FillListData(room.members);
                        // FillRoomDtat(room);

                        //rooms = room;
                    }
                    else
                    {

                    }
                });
        }

        private void txtGroupName_KeyPress(object sender, KeyPressEventArgs e)
        {
            TextBox textBoxSender = (TextBox)sender;
            
            //回车，换行，空格不在第一行
            if (textBoxSender.Text.Length <= 0)
            { 
                //小数点不能在第一位
                if ((int)e.KeyChar == 10 || (int)e.KeyChar == 13 || (int)e.KeyChar == 32)
                {
                    e.Handled = true;
                }
                else
                {
                    //小数点    
                    e.Handled = false;
                    /* float fOriginalAndInput;
                      float fOriginal;
                      bool bCovOriginalAndInput = false, bCovOriginal = false;
                      bCovOriginal = float.TryParse(textBoxSender.Text, out fOriginal);
                      bCovOriginalAndInput = float.TryParse(textBoxSender.Text + e.KeyChar.ToString(), out fOriginalAndInput);
                      if (bCovOriginalAndInput == false)
                      { //输入小数点时，如果输入框内容加上输入的内容不是浮点数
                          if (bCovOriginal == true)
                          {//输入框内容是浮点数，则此次不输入，限制输入小数点的个数，不做处理
                              //  eKeyPress.Handled = true;
                          }
                          else
                          {
                              e.Handled = false;
                          }
                      }*/
                }
            }
        }
        
        /// <summary>
        ///  邀请入群
        /// </summary>
        /// <param name="roomId"></param>
        /// <param name="userids"></param>
        private void InviteToGroup(string roomId, string userids)
        {
            HttpUtils.Instance.InitHttp(this);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/member/update") //获取群详情
            .AddParams("access_token", Applicate.Access_Token)
            .AddParams("roomId", roomId)
            .AddParams("text", userids)
            .Build().Execute(null);
        }

        /// <summary>
        /// 保存群成员
        /// </summary>
        /// <param name="_roomId"></param>
        /// <param name="select"></param>
        private void SaveRoomUsers(string _roomId, Dictionary<string, Friend> select)
        {
            List<RoomMember> memberList = new List<RoomMember>();

            foreach (KeyValuePair<string, Friend> a in select)
            {
                RoomMember roomMembers = new RoomMember();
                roomMembers.roomId = _roomId;
                roomMembers.userId = a.Key;
                roomMembers.nickName = a.Value.NickName;
                roomMembers.role = 3;
                roomMembers.talkTime = 0;
                roomMembers.sub = 1;
                roomMembers.offlineNoPushMsg = 0;
                roomMembers.remarkName = a.Value.NickName;

                memberList.Add(roomMembers);
            }

            RoomMember roomMember = new RoomMember() { roomId = _roomId };
            roomMember.AutoInsertOrUpdate(memberList);
        }

        private void FrmBuildGroups_FormClosed(object sender, FormClosedEventArgs e)
        {
            Messenger.Default.Unregister(this);//反注册
        }

        private void txtGroupName_TextChanged(object sender, EventArgs e)
        {
            //  lbltips.Visible = false;
        }
    }
}
