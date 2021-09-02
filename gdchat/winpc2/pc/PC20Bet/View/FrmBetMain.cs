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

namespace WinFrmTalk
{
    public partial class FrmBetMain : Form
    {
        public FrmMain MainForm { get; set; }
        private string GID = "";
        private bool QuitFlag = false;
       
        public FrmBetMain()
        {
            InitializeComponent();

            this.initAll();
        }

        private void FrmBetMainClosing(object sender, FormClosingEventArgs e)
        {
            QuitFlag = true;

            if (this.MainForm != null)
            {
                this.MainForm.Close();
            }
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
                frmLogin = new FrmLogin();
                frmLogin.BetMainForm = this;

                frmLogin.Show();
            }
        }

        public void JumpMainUI()
        {
            frmLogin = null;
            MainForm = new FrmMain(this);

            MainForm.Show();
            MainForm.MainLoadData();

            notifyGroupsInfo();
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
            if (!QuitFlag && this.GID == gid)
            {
                this.axBetWidget1.msgArrived(uid, strName, strMsg);
            }
        }
        
        public void notifyGroupsInfo()
        {
            List<Friend> dataList = new Friend() { IsGroup = 1 }.GetGroupsList();//获取列表
            int len = dataList.Count();

            string[] gids = new string[len];
            string[] names = new string[len];

            int i = 0;
            foreach (var f in dataList)
            {
                gids[i] = f.UserId;
                names[i] = f.NickName;

                ++i;
            }

            this.axBetWidget1.notifyGroupsInfo(gids, names);
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
                        int len = data.Count();

                        string[] pids = new string[len];
                        string[] names = new string[len];

                        int i = 0;
                        foreach (var f in data)
                        {
                            pids[i] = f.userId;
                            names[i] = f.nickname;

                            ++i;
                        }

                        this.axBetWidget1.notifyMemberInfo(pids, names);
                    }
                });
            }
        }

        private void initAll()
        {
            this.FormClosing += FrmBetMainClosing;

            this.axBetWidget1.onPBtnLoginClicked += onPBtnLoginClicked;
            this.axBetWidget1.setGroupId += setGroupId;
            this.axBetWidget1.msgSend += msgSend;
        }
    }
}

