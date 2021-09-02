using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Helper;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQaccounts : EQBaseControl
    {
        public EQaccounts(string strJson) : base(strJson)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleWidth = control.Width;
            BubbleHeight = control.Height;
        }
        Useaccounts useaccounts = new Useaccounts();
        public override Control ContentControl()
        {
            useaccounts.Cursor = Cursors.Hand;
            useaccounts.Tag = messageObject.messageId;
            bool isOneself = messageObject.fromUserId != Applicate.MyAccount.userId ? false : true;
            if (!isOneself)
            {
                useaccounts.panel_file.BackgroundImage = WinFrmTalk.Properties.Resources.oronge;
            }
            else
            {
                useaccounts.panel_file.BackgroundImage = WinFrmTalk.Properties.Resources.oronge_right;
            }
            useaccounts.money = "￥" + messageObject.content;
            useaccounts.titletext = "来自" + messageObject.fromUserName + "的转账";
            useaccounts.Click += Useaccounts_Click;
            foreach (Control crl in useaccounts.Controls)
            {
                crl.Click += Useaccounts_Click;
                if (crl.Controls.Count > 0)
                    foreach (Control item in crl.Controls)
                        item.Click += Useaccounts_Click;
            }
            Calc_PanelWidth(useaccounts);
            return useaccounts;
           
        }
        /// <summary>
        /// 点击事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Useaccounts_Click(object sender, EventArgs e)
        {
            MessageObject msg = this.messageObject;
            RedpaperUIUtils.GetTranfserinfo(messageObject.objectId,messageObject);
            var crl_msg = useaccounts.panel_file.Parent.Parent.Controls["lab_redPoint"];
            if (crl_msg != null && crl_msg is Label lab_redPoint && lab_redPoint.Image != null)
            {
                //去除红点
                DrawIsReceive(lab_redPoint, 1);
            }
            if (msg.isRead == 0)
                ShiKuManager.SendReadMessage(msg.GetFriend(), msg);
        }

        public EQaccounts(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }
    }
}
