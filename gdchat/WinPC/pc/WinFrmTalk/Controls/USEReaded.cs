using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{

    public partial class USEReaded : UserControl
    {
        public USEReaded()
        {
            InitializeComponent();
        }

        private MessageObject messageObject = new MessageObject();
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
                lab_ReaddTime.Text = "阅读时间：" + TimeUtils.FromatTime(Convert.ToInt32(value.timeSend)).ToString();//消息阅读时间
                pic_head.Tag = Applicate.LocalConfigData.ImageFolderPath + value.fromUserId + ".jpg";
                ImageLoader.Instance.DisplayAvatar(messageObject.fromUserId, this.pic_head);//设置头像

                //现在的时间减去阅读的时间

                lab_time.Text = DateStringFromNow(Helpers.StampToDatetime(value.timeSend));

            }
        }
        //时间的转换
        public static string DateStringFromNow(DateTime dateTime)
        {

            TimeSpan span = DateTime.Now - dateTime;
            if (span.TotalDays > 60)
            {
                return dateTime.ToShortDateString();
            }
            else if (span.TotalDays > 30)
            {
                return
                "1个月前";
            }
            else if (span.TotalDays > 14)
            {
                return
                "2周前";
            }
            else if (span.TotalDays > 7)
            {
                return
                "1周前";
            }
            else if (span.TotalDays > 1)
            {
                return
                string.Format("{0}天前", (int)Math.Floor(span.TotalDays));
            }
            else if (span.TotalHours > 1)
            {
                return
                string.Format("{0}小时前", (int)Math.Floor(span.TotalHours));
            }
            else if (span.TotalMinutes > 1)
            {
                return
                string.Format("{0}分钟前", (int)Math.Floor(span.TotalMinutes));
            }
            else if (span.TotalSeconds >= 1)
            {
                return
                string.Format("{0}秒前", (int)Math.Floor(span.TotalSeconds));
            }
            else
            {
                return
                "1秒前";
            }
        }


    }
}
