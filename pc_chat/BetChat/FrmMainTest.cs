using System;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    public partial class FrmMainTest : FrmBase
    {
        private static Friend choose_target;       //选择的联系人
        public FrmMainTest()
        {
            InitializeComponent();
        }

        private void FrmMainTest_Load(object sender, EventArgs e)
        {
            #region 测试用（已登录）
            //ShiKuManager.InitialXmpp();
            //ShiKuManager.xmpp.XmppCon.Open();
            //panel_friendTab.WrapContents = false;   //设置不换行绘制
            #endregion

            choose_target = new Friend();
            choose_target.UserId = "10017332";
            choose_target.NickName = "Aahhb";
            choose_target.RemarkName = "Aahhb";
            choose_target.IsGroup = 0;
            sendMsgPanel1.SetChooseFriend(choose_target);
        }

        private void btnSetFd_Click(object sender, EventArgs e)
        {
            choose_target = new Friend();
            choose_target.UserId = "10017332";
            choose_target.NickName = "Aahhb";
            choose_target.RemarkName = "Aahhb";
            choose_target.IsGroup = 0;
            sendMsgPanel1.SetChooseFriend(choose_target);

        }
    }
}
