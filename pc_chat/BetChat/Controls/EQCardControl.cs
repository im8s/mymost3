using System;
using System.Drawing;
using System.Windows.Forms;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQCardControl : EQBaseControl
    {
        public EQCardControl(string strJson) : base(strJson)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public EQCardControl(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleWidth = control.Width;
            BubbleHeight = control.Height;
        }

        CardPanel panel_card;
        public override Control ContentControl()
        {
            panel_card = new CardPanel();
            panel_card.BackColor = bg_color;
            panel_card.Tag = messageObject.messageId;
            panel_card.lab_content.Text = messageObject.content;

            //修改名片头像
            panel_card.lab_icon.BackgroundImageLayout = ImageLayout.Stretch;
            ImageLoader.Instance.DisplayAvatar(messageObject.objectId, panel_card.lab_icon);

            //设置气泡大小
            Calc_PanelWidth(panel_card);

            //鼠标点击事件
            panel_card.Click += PanelCard_Click;

            foreach (Control crl in panel_card.Controls)
            {
                crl.Click += PanelCard_Click;
                if(crl.Controls.Count > 0)
                    foreach(Control item in crl.Controls)
                        item.Click += PanelCard_Click;
            }
            return panel_card;
        }

        private void PanelCard_Click(object sender, EventArgs e)
        {
            //MessageObject msg = MessageObjectDataDictionary.GetMsg(panel_card.Tag != null ? panel_card.Tag.ToString() : "");
            MessageObject msg = this.messageObject;
            //string userId = msg.GetChatTargetId();
            if (msg.isRead == 0)
                ShiKuManager.SendReadMessage(msg.GetFriend(), msg);

            //更新UI
            var crl_msg = panel_card.Parent.Parent.Controls["lab_redPoint"];
            if (crl_msg != null && crl_msg is Label lab_redPoint && lab_redPoint.Image != null)
            {
                //去除红点
                DrawIsReceive(lab_redPoint, 1);
            }

            //显示名片
            FrmFriendsBasic frmFriendsBasic = new FrmFriendsBasic();
            frmFriendsBasic.ShowUserInfoById(msg.objectId);
        }
    }
}
