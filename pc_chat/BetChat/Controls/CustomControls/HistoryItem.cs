using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class HistoryItem : UserControl
    {
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
               // lab_time.Text = TimeUtils.ChatLastTime(value.timeSend);
              lab_time.Text = value.timeSend.StampToDatetime().ToString(@"yyyy/MM/dd HH:mm");
                pic_head.Tag = Applicate.LocalConfigData.ImageFolderPath + value.FromId + ".jpg";


                ImageLoader.Instance.DisplayAvatar(messageObject.FromId, this.pic_head);//设置头像
            }
        }

        public string txtTime { get { return lab_time.Text; } set { lab_time.Text = value; } }

        public HistoryItem()
        {
            InitializeComponent();
        }
    }
}
