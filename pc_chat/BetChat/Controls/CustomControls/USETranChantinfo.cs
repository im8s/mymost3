using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.View;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class USETranChantinfo : UserControl
    {
        public USETranChantinfo()
        {
            InitializeComponent();
        }

        private MessageObject messageObject = new MessageObject();
        /// <summary>
        /// 保存整个好友实体类
        /// </summary>
        public MessageObject messageData
        {
            get
            {
                return messageObject;
            }
            set
            {
                messageObject = value;
                lab_name.Text = value.fromUserName;
                lab_time.Text = value.timeSend.StampToDatetime().ToString(@"yyyy/MM/dd HH:mm");
                string text="";
                switch(value.type)
                {
                    case kWCMessageType.Image://图片

                    
                    //   ImageLoader.Instance.DisplayAvatar(messageObject.FromId, lab_text);//设置头像
                        text = "[图片]";
                        break;
                    case kWCMessageType.Video://视频
                        text = "[视频]";
                        break;
                    case kWCMessageType.Voice://语音
                        text = "[语音]";
                        break;
                    case kWCMessageType.Audio:
                        text = "[音频]";
                        break;
                    case kWCMessageType.Text:
                        text = value.content;
                        break;
                }

              
               
                lab_text.Text = text;
                pic_head.Tag = Applicate.LocalConfigData.ImageFolderPath + value.FromId + ".jpg";
                ImageLoader.Instance.DisplayAvatar(messageObject.FromId, this.pic_head);//设置头像
            }
        }

        public string txtTime { get { return lab_time.Text; } set { lab_time.Text = value; } }
         public string txtText { get { return lab_text.Text; } set { lab_text.Text = value; } }
        private void lab_name_Click(object sender, EventArgs e)
        {

        }
        private int FontWidth(Font font, Control control, string str)
        {
            //此处为什么会报错？？？难道因为执行此方法在后，创建控件在先？？

            Graphics g = control.CreateGraphics();
            SizeF siF = g.MeasureString(str, font); return (int)siF.Width;


        }

        private void lab_text_Click(object sender, EventArgs e)
        {
           
            int textwindth = FontWidth(lab_text.Font, lab_text, txtText);
            if (textwindth > (this.Width - 56))
            {
                FrmSeeText seetext = new FrmSeeText();
                seetext.Getmsg =messageData;
                seetext.Longtext = seetext.Getmsg.content;
                seetext.Show();
            }
        }
    }
}
