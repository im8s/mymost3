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
    public partial class ReplyPanel : UserControl
    {
        private MessageObject replyMsg;
        public MessageObject ReplyMsg
        {
            get { return replyMsg; }
            set
            {
                if (value == null)
                    value = new MessageObject();
                try
                {
                    lblName.Text = "回复: " + (string.IsNullOrEmpty(value.fromUserName) ?
                        "" :
                        value.fromUserName);
                    lblContent.Location = new Point(lblName.Location.X + lblName.Width + 10, lblContent.Location.Y);
                    replyMsg = value;

                }
                catch (Exception ex)
                {
                   LogUtils.Log("set====ReplyMsg ===Error" + ex.Message);
                }
            }
        }

        public ReplyPanel()
        {
            InitializeComponent();
        }

        private void lblClose_Click(object sender, EventArgs e)
        {
            if (((MouseEventArgs)e).Button == MouseButtons.Left)
            {
                ReplyMsg = new MessageObject();
                this.SendToBack();
                //this.Visible = false;
            }
        }

    }
}
