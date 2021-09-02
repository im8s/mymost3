using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Drawing2D;
using WinFrmTalk.Model;
using WinFrmTalk.Dictionarys;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class UnReadNumPanel : UserControl
    {
        Action<string> mListen;     //传递msgId
        int readNum = 0;
        string msgId = "";
        public bool direction = true;// 向上

        public UnReadNumPanel()
        {
            InitializeComponent();
        }

        private void picClose_Click(object sender, EventArgs e)
        {
            this.SendToBack();
        }

        public void IsShowPanel(string msgId, int readNum, bool isShow, bool isUp = true)
        {
            this.readNum = readNum;
            this.msgId = msgId;
            this.direction = isUp;
            //未达到要显示角标的高度
            if (!isShow)
            {
                this.SendToBack();
                return;
            }

            if (readNum > 0)
            {
                //修改箭头方向
                if (isUp)
                    picIcon.Image = Properties.Resources.up;
                else
                    picIcon.Image = Properties.Resources.down;
                //修改角标的样式
                lblUnReadNum.Text = readNum + "条新消息";
                this.Visible = true;
                this.BringToFront();
            }
            else
                this.SendToBack();
        }

        private void UnReadNumPanel_Paint(object sender, PaintEventArgs e)
        {
            //绘制边框
            Pen pen1 = new Pen(Color.FromArgb(225,225,225), 1);
            e.Graphics.DrawRectangle(pen1, 0, 0, this.Width - 1, this.Height - 1);
        }

        private void panUp_Click(object sender, EventArgs e)
        {
            mListen(msgId);
            this.SendToBack();
        }

        private void UnReadNumPanel_Load(object sender, EventArgs e)
        {
            //子控件继承点击事件
            foreach (Control crl in panUp.Controls)
                crl.Click += (s, ev) =>
                {
                    panUp_Click(s, ev);
                };
        }

        public void AddListen(Action<string> action)
        {
            mListen = action;
        }
    }
}
