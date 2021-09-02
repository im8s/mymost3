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
using AxBetApp_ocxLib;
using BetApp_ocxLib;

namespace WinFrmTalk
{
    public partial class FrmBetMain : Form
    {
        public FrmMain MainForm { get; set; }
        private string GID = "";
        public FrmLogin LoginForm { get; set; }

        public FrmBetMain()
        {
            InitializeComponent();

            this.initAll();
        }

        #region 点击"登录主号"按钮，响应点击事件
        private void JumpToLogin()
        {
            //LogUtils.Save("=============================" + TimeUtils.FromatCurrtTime() + "=============================\r\n");
            //LogUtils.Save("=====登录账号:" + (lblContry.Text + txtTelephone.Text) + "======\r\n");
            //LogUtils.Save("=====用户名  :" + Applicate.MyAccount.nickname + "======\r\n");
            //LogUtils.Save("=====用户id  :" + Applicate.MyAccount.userId + "======\r\n");
            //LogUtils.Save("=====系统.net版本:" + UIUtils.GetDotNetVersion() + "======\r\n");
            //LogUtils.Save("=====程序版本:" + Applicate.APP_VERSION + "-" + Applicate.CURRET_VERSION + "======\r\n");

            //LocalDataUtils.SetStringData("last_login_service", UIUtils.GetServer());
            
            if (this.MainForm != null)
            {
                this.MainForm.Show();
                this.MainForm.BringToFront();
            }
            else
            {
                if(this.LoginForm == null)
                {
                    LoginForm = new FrmLogin();
                    LoginForm.BetMainForm = this;
                }

                LoginForm.Show();
            }
        }

        public void CloseAllForms()
        {
            if (this.MainForm != null)
            {
                this.MainForm.Close();
                this.MainForm = null;
            }

            if (this.LoginForm != null)
            {
                this.LoginForm.Close();
                this.LoginForm = null;
            }
        }
        #endregion

        private void onPBtnLoginClicked(object sender, EventArgs e)
        {
            JumpToLogin();
        }

        private void setGroupId(object sender, IBetWidgetEvents_setGroupIdEvent e)
        {
            GID = e.p_gid;

            notifyMemberInfo(GID);
        }

        private void msgSend(object sender, IBetWidgetEvents_msgSendEvent e)
        {
            if (this.MainForm != null)
            {
                this.MainForm.talkMsg(e.p_gid, e.p_strMsg);
            }
        }

        public void msgArrived(string gid, string uid, string strName, string strMsg)
        {
            if (this.GID == gid)
            {
                this.axBetWidget1.msgArrived(uid, strName, strMsg);
            }
        }
        
        public void notifyGroupInfo()
        {
            List<Friend> dataList = new Friend() { IsGroup = 1 }.GetGroupsList();//获取列表
            //int len = dataList.Count();

            GroupInfoListClass gilist = new GroupInfoListClass();
            
            foreach (var f in dataList)
            {
                GroupInfoClass gi = new GroupInfoClass();

                gi.setGId(f.UserId);
                gi.setName(f.NickName);
                gi.setType(0);

                gilist.append(gi);
            }
            
            this.axBetWidget1.notifyGroupInfo(gilist);
        }

        public void notifyGroupCreated(object arr)
        {
            this.axBetWidget1.notifyGroupCreated(arr);
        }

        public void notifyGroupDeleted(string gid)
        {
            this.axBetWidget1.notifyGroupDeleted(gid);
        }

        public void notifyMemberInfo(string gid)
        {
            Friend fd = new Friend() { UserId = gid }.GetFdByUserId();
            if (fd != null)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/member/list") //获取群成员
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("roomId", fd.RoomId)
                //.AddParams("pageSize", "50")
                .Build().ExecuteJson<List<MembersItem>>((sccess, data) =>
                {
                    if (sccess)
                    {
                        //List<MembersItem> dataList = new Friend() { IsGroup = 1 }.GetGroupsList();//获取列表
                        //int len = data.Count();

                        PlayerInfoListClass pilist = new PlayerInfoListClass();
                        
                        foreach (var f in data)
                        {
                            PlayerInfoClass pi = new PlayerInfoClass();

                            pi.setPId(f.userId);
                            pi.setName(f.nickname);
                            pi.setType(0);

                            pilist.append(pi);
                        }
                        
                        this.axBetWidget1.notifyMemberInfo(pilist);
                    }
                });
            }
        }

        public void notifyMemberJoin(object obj)
        {
            this.axBetWidget1.notifyMemberJoin(obj);
        }

        public void notifyMemberLeave(string pid)
        {
            this.axBetWidget1.notifyMemberLeave(pid);
        }

        private void initAll()
        {
            this.FormClosing += FrmBetMain_FormClosing;

            this.axBetWidget1.onPBtnLoginClicked += onPBtnLoginClicked;
            this.axBetWidget1.setGroupId += setGroupId;
            this.axBetWidget1.msgSend += msgSend;
        }

        private void FrmBetMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            CloseAllForms();
        }
    }
}
