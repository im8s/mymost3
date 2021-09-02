using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;
using WinFrmTalk.View;

namespace WinFrmTalk.Controls
{
    public class EQLocationControl : EQBaseControl
    {
        public EQLocationControl(string strJson) : base(strJson)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public EQLocationControl(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleHeight = control.Height;
            BubbleWidth = control.Width;
        }

        Panel panel_location = new Panel();
        public override Control ContentControl()
        {
            panel_location.Cursor = Cursors.Hand;
            panel_location.Tag = messageObject.messageId;
            try
            {
                //地图
                PictureBox pic_image = new PictureBox();
                pic_image.Size = new Size(200, 70);
                pic_image.SizeMode = PictureBoxSizeMode.StretchImage;
                ImageLoader.Instance.DisplayImage(messageObject.content, pic_image);
                //ImageLoader.Instance.Load()
                //    .Loading()
                //    .Error(() => {
                //    });
                //    .Into();
                               
                //增加地点名称布局
                Label lab_name = new Label();
                lab_name.BackColor = Color.White;
                lab_name.Text = messageObject.objectId;
                lab_name.TextAlign = ContentAlignment.MiddleCenter;

                //组合控件
                panel_location.Size = new Size(pic_image.Width, pic_image.Height + 22);
                pic_image.Dock = DockStyle.Top;
                panel_location.Controls.Add(pic_image);
                lab_name.Size = new Size(lab_name.Width, 22);
                lab_name.Dock = DockStyle.Bottom;
                panel_location.Controls.Add(lab_name);

                //子控件响应父控件的点击事件
                foreach(Control item in panel_location.Controls)
                {
                    item.Click += PanelLocation_Click;
                }
                panel_location.Click += PanelLocation_Click;

                Calc_PanelWidth(panel_location);
            }
            catch (Exception e)
            {
                throw e;
            }
            return panel_location;
        }

        private void PanelLocation_Click(object sender, EventArgs e)
        {
            //MessageObject msg = MessageObjectDataDictionary.GetMsg(panel_location.Tag != null ? panel_location.Tag.ToString() : "");
            MessageObject msg = this.messageObject;
            Friend friend = new Friend()
            {
                UserId = msg.fromUserId,
                IsGroup = msg.isGroup,
                NickName = msg.fromUserName
            };
            if (msg.isRead == 0)
                ShiKuManager.SendReadMessage(friend, msg);

            //打开地图
            FrmBrowser frmBrowser = new FrmBrowser();
            frmBrowser.BrowserShow(msg);

            //更新UI
            var crl_msg = panel_location.Parent.Controls["lab_redPoint"];
            if (crl_msg != null && crl_msg is Label lab_redPoint && lab_redPoint.Image != null)
            {
                //去除红点
                DrawIsReceive(lab_redPoint, 1);
            }
        }

    }
}
