using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using AxBetApp_ocxLib;

namespace WinFrmTalk
{
    public partial class FrmBetMain : Form
    {
        public FrmBetMain()
        {
            InitializeComponent();
        }

        #region 点击"登录主号"按钮，响应点击事件
        private void JumpToLogin(object sender, EventArgs e)
        {
            //LogUtils.Save("=============================" + TimeUtils.FromatCurrtTime() + "=============================\r\n");
            //LogUtils.Save("=====登录账号:" + (lblContry.Text + txtTelephone.Text) + "======\r\n");
            //LogUtils.Save("=====用户名  :" + Applicate.MyAccount.nickname + "======\r\n");
            //LogUtils.Save("=====用户id  :" + Applicate.MyAccount.userId + "======\r\n");
            //LogUtils.Save("=====系统.net版本:" + UIUtils.GetDotNetVersion() + "======\r\n");
            //LogUtils.Save("=====程序版本:" + Applicate.APP_VERSION + "-" + Applicate.CURRET_VERSION + "======\r\n");

            //LocalDataUtils.SetStringData("last_login_service", UIUtils.GetServer());

            //if(frmLogin is null)
                frmLogin = new FrmLogin();

            frmLogin.Show();
        }
        #endregion

        private void sendMsg(object sender, IBetWidgetEvents_sendMsgEvent e)
        {

        }
    }
}
