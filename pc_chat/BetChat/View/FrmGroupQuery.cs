using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;
using WinFrmTalk.View.list;

namespace WinFrmTalk.View
{
    public partial class FrmGroupQuery : FrmBase
    {
        private GroupQueryAdapter mAdapter;
        public string SeracTex;//记录查询的值

        public delegate void ProcesOnClickItem(AddGroupItem item);

        public FrmGroupQuery()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            mAdapter = new GroupQueryAdapter();
            mAdapter.FrmGroupQuery = this;
            xListView1.FooterRefresh += LoadNextPageRoom;
        }


        /// <summary>
        /// 按下快捷键
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtKeyWord_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == '\r')
            {
                btnQuery_Click(sender, e);
            }
        }


        /// <summary>
        /// 查找
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnQuery_Click(object sender, EventArgs e)
        {
            string searchText = txtKeyWord.Text.TrimStart().Trim();
            if (UIUtils.IsNull(searchText))
            {
                xListView1.ClearList();
                ShowTip("输入为空");
                return;
            }

            SeracTex = searchText;
            mPagerIndex = 0;
            RequestQueryRoom();
        }


        // 分页加载群成员
        private void LoadNextPageRoom()
        {
            if (isLoading)
            {
                return;
            }


            mPagerIndex++;

            RequestQueryRoom();
        }

        int mPagerIndex = 0;
        bool isLoading = false;

        private void RequestQueryRoom()
        {
            LodingUtils loding = new LodingUtils();
            loding.parent = xListView1;
            loding.size = xListView1.Size;
            loding.start();
            isLoading = true;

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/list")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("pageSize", "20")
                .AddParams("pageIndex", mPagerIndex.ToString())
                .AddParams("roomName", SeracTex)
                .Build().ExecuteList<DownRoomBean>((sucess, list) =>
                {
                    loding.stop();
                    isLoading = false;
                    if (sucess)
                    {
                        if (list.data.Count <= 0)
                        {
                            if (mPagerIndex > 0)
                            {
                                this.ShowTip("没有更多的数据了");
                            }
                            else
                            {
                                this.ShowTip("暂无数据");
                            }

                            return;
                        }

                        if (mPagerIndex == 0)
                        {
                            mAdapter.BindFriendData(list.data);
                            xListView1.SetAdapter(mAdapter);
                        }
                        else
                        {
                            int index = mAdapter.AddRangeData(list.data);
                            xListView1.InsertRange(index);
                        }
                    }
                    else
                    {
                        this.ShowTip("暂无数据");
                    }

                });
        }


        #region 点击了发消息
        public void OnItemClickSend(AddGroupItem item)
        {
            //var item = sender as AddGroupItem;
            Messenger.Default.Send(item.DataContext, FrmMain.START_NEW_CHAT);//发消息


        }

        #endregion


        #region 点击了加入群组
        public void OnItemClickJoin(AddGroupItem item)
        {

            if (item.btnAdd.Text.Equals("发消息"))
            {
                OnItemClickSend(item);
                return;
            }

            if (ShowPromptBox("确定要加入群"))
            {
                var friend = item.DataContext;
                // 是否需要群主验证
                if (friend.IsNeedVerify == 1)
                {
                    // 先去获取群主，然后给群主发加群验证消息
                    RequestRoomCreate(friend.RoomId, item);
                }
                else
                {
                    RequestJoinRoom(friend, item);
                }
            }

        }

        #endregion


        #region 点击了加入群组
        public void RequestJoinRoom(Friend friend, AddGroupItem item)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/join")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("roomId", friend.RoomId)
                .AddParams("type", "2")
                .Build().Execute((sucess, result) =>
                {
                    if (sucess)
                    {

                        ShowTip("加群成功");
                        item.btnAdd.Text = "发消息";

                        //this.Close();
                    }
                });
        }
        #endregion

        #region 获取群主
        public void RequestRoomCreate(string roomId, AddGroupItem item)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/getRoom") //获取群详情
               .AddParams("access_token", Applicate.Access_Token)
               .AddParams("roomId", roomId)
               .AddParams("pageSize", "5")
               .Build()
               .Execute((sccess, roomlst) =>
               {
                   if (sccess)
                   {
                       string admins = UIUtils.DecodeString(roomlst, "members");
                       string roomJid = UIUtils.DecodeString(roomlst, "jid");

                       List<Member> members = JsonConvert.DeserializeObject<List<Member>>(admins);

                       foreach (var mem in members)
                       {
                           if (mem.role == 1)
                           {
                               SendJoinVerifyMessage(mem.ToFriend(), roomJid, item);
                               return;
                           }
                       }
                   }
               });
        }

        // 发送验证消息
        private void SendJoinVerifyMessage(Friend roomCreate, string roomJid, AddGroupItem item)
        {
            FrmROOMVerify frmROOMVerify = new FrmROOMVerify();
            frmROOMVerify.ShowDialog();

            if (frmROOMVerify.DialogResult == DialogResult.OK)
            {
                string Reson = frmROOMVerify.textReson.Text;//邀请好友的原因
                Friend friend = new Friend { UserId = Applicate.MyAccount.userId, NickName = Applicate.MyAccount.nickname };//邀请的好友
                friend = friend.GetByUserId();

                List<Friend> friendlst = new List<Friend>();//添加好友的集合
                friendlst.Add(friend);

                //获取群主
                ShiKuManager.SendRoomverification(roomCreate, friendlst, Reson, roomJid);//发消息

                item.btnAdd.Text = "等待验证";
                item.InvalidBtn();
                ShowTip("已发送入群申请，请等待群组确认");
            }
        }
        #endregion
    }
}
