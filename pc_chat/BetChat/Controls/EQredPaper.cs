using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Helper;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQredPaper : EQBaseControl
    {
        public EQredPaper(string strJson) : base(strJson)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleWidth = control.Width;
            BubbleHeight = control.Height;
            // throw new NotImplementedException();
        }

        UserReadPaper redPaper = new UserReadPaper();

        public override Control ContentControl()
        {
            redPaper.Cursor = Cursors.Hand;
            bool isOneself = messageObject.fromUserId != Applicate.MyAccount.userId ? false : true;
            if (!isOneself)
            {
                redPaper.panel_file.BackgroundImage = WinFrmTalk.Properties.Resources.read;
            }
            else
            {
                redPaper.panel_file.BackgroundImage = WinFrmTalk.Properties.Resources.read_right;
            }
            redPaper.Tag = messageObject.messageId;
            redPaper.titletext = messageObject.content;
            redPaper.Click += RedPaper_Click;
            foreach (Control crl in redPaper.Controls)
            {
                crl.Click += RedPaper_Click;
                if (crl.Controls.Count > 0)
                    foreach (Control item in crl.Controls)
                        item.Click += RedPaper_Click;
            }
            Calc_PanelWidth(redPaper);
            return redPaper;
        }

        /// <summary>
        /// 点击事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void RedPaper_Click(object sender, EventArgs e)
        {
            MessageObject msg = this.messageObject;


            RedpaperUIUtils.GetRedPacket(messageObject.objectId, msg, this);
            //口令红包红点消失
            DisposeRedPoint(msg);

        }

        public EQredPaper(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }
        /// <summary>
        /// 红点消失
        /// </summary>
        /// <param name="msg"></param>

        public void DisposeRedPoint(MessageObject msg)
        {
            var crl_msg = redPaper.panel_file.Parent.Parent.Controls["lab_redPoint"];
            //口令红包领取前红点不消失
            if (crl_msg != null && crl_msg is Label lab_redPoint && lab_redPoint.Image != null && msg.fileName != "3")
            {
                //去除红点
                DrawIsReceive(lab_redPoint, 1);
                if (msg.isRead == 0)
                    ShiKuManager.SendReadMessage(msg.GetFriend(), msg);
            }

        }
        public void DisposeRedPoint(MessageObject msg, int type = 0)
        {
            var crl_msg = redPaper.panel_file.Parent.Parent.Controls["lab_redPoint"];
            //口令红包领取前红点不消失
            if (crl_msg != null && crl_msg is Label lab_redPoint && lab_redPoint.Image != null)
            {
                //去除红点
                DrawIsReceive(lab_redPoint, 1);
            }
            if (msg.isRead == 0)
                ShiKuManager.SendReadMessage(msg.GetFriend(), msg);
        }
    }
}
