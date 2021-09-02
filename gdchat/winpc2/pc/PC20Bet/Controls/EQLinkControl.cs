using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;
using WinFrmTalk.View;

namespace WinFrmTalk.Controls
{
    public class EQLinkControl : EQBaseControl
    {
        private string title = "";
        private string link_url = "";
        private string img_url = "";

        public EQLinkControl(string strJson) : base(strJson)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public EQLinkControl(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleHeight = control.Height;
            BubbleWidth = control.Width;
        }

        private void LinkJsonToModel()
        {
            Dictionary<string, string> keyValues = JsonConvert.DeserializeObject<Dictionary<string, string>>(messageObject.content);
            this.link_url = keyValues["url"];
            this.img_url = keyValues["img"];
            this.title = keyValues["title"];
            messageObject.objectId = link_url;
        }

        Panel panel_link = new Panel();
        public override Control ContentControl()
        {
            LinkJsonToModel();
            panel_link.Cursor = Cursors.Hand;
            panel_link.Tag = messageObject.messageId;
            try
            {
                //地图
                PictureBox pic_image = new PictureBox();
                pic_image.Size = new Size(200, 70);
                pic_image.SizeMode = PictureBoxSizeMode.StretchImage;
                ImageLoader.Instance.DisplayImage(img_url, pic_image);
                //ImageLoader.Instance.Load()
                //    .Loading()
                //    .Error(() => {
                //    });
                //    .Into();

                //增加地点名称布局
                Label lab_name = new Label();
                lab_name.BackColor = Color.White;
                lab_name.Text = title;
                lab_name.TextAlign = ContentAlignment.MiddleCenter;

                //组合控件
                panel_link.Size = new Size(pic_image.Width, pic_image.Height + 22);
                pic_image.Dock = DockStyle.Top;
                panel_link.Controls.Add(pic_image);
                lab_name.Size = new Size(lab_name.Width, 22);
                lab_name.Dock = DockStyle.Bottom;
                panel_link.Controls.Add(lab_name);

                //子控件响应父控件的点击事件
                foreach (Control item in panel_link.Controls)
                {
                    item.Click += PanelLocation_Click;
                }
                panel_link.Click += PanelLocation_Click;

                Calc_PanelWidth(panel_link);
            }
            catch (Exception e)
            {
                throw e;
            }
            return panel_link;
        }

        private void PanelLocation_Click(object sender, EventArgs e)
        {
            //MessageObject msg = MessageObjectDataDictionary.GetMsg(panel_link.Tag != null ? panel_link.Tag.ToString() : "");
            MessageObject msg = this.messageObject;
            if (msg.isRead == 0)
                ShiKuManager.SendReadMessage(msg.GetFriend(), msg);

            MessageObject myMsg = new MessageObject();
            myMsg = msg;
            myMsg.content = msg.objectId;

            //打开地图
            FrmBrowser frmBrowser = new FrmBrowser();
            frmBrowser.BrowserShow(myMsg);

            //更新UI
            var crl_msg = panel_link.Parent.Controls["lab_redPoint"];
            if (crl_msg != null && crl_msg is Label lab_redPoint && lab_redPoint.Image != null)
            {
                //去除红点
                DrawIsReceive(lab_redPoint, 1);
            }
        }

    }
}
