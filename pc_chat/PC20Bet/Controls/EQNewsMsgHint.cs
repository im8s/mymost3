using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.Controls
{
    public class EQNewsMsgHint : Panel
    {
        public EQNewsMsgHint()
        {
            this.Height = 20;
            this.Width = 290;
            this.BackColor = Color.Transparent;

            //分割线
            Label lblLine = new Label();
            lblLine.AutoSize = false;
            lblLine.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right;
            lblLine.BackColor = Color.FromArgb(156, 156, 156);
            lblLine.Location = new Point(0, 9);
            lblLine.Height = 1;
            lblLine.Width = this.Width;

            //文本提示
            Label lblText = new Label();
            lblText.AutoSize = false;
            lblText.Size = new Size(90, 20);
            lblText.Text = "以下为最新消息";
            lblText.Font = Applicate.myFont;
            lblText.ForeColor = Color.FromArgb(156, 156, 156);
            lblText.Location = new Point(100, 0);
            lblText.TextAlign = ContentAlignment.MiddleCenter;

            //添加控件
            this.Controls.Add(lblLine);
            this.Controls.Add(lblText);
            lblText.BringToFront();
        }
    }
}
