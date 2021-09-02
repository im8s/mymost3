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

    public partial class USERemindMe : UserControl
    {
        public Action<string> myevent;

        public USERemindMe()
        {
            InitializeComponent();
        }
        private Friend _friend;
        /// <summary>
        /// 
        /// </summary>
        /// <param name="frienddata"> 其他页面传值</param>
        /// <param name="isup">判断上下, true为上，false为下</param>
        public void Changedata(Friend frienddata, bool isup)
        {
            _friend = frienddata;
            if (frienddata.IsAtMe == 1)
            {
                lblRemaidme.Text = "有人@我";
            }
            else if (frienddata.IsAtMe == 2)
            {
                lblRemaidme.Text = "@全体成员";
            }
            if (isup)
            {
                lblpic.Image = WinFrmTalk.Properties.Resources.up;//向上的图标
            }

            else
            {
                lblpic.Image = WinFrmTalk.Properties.Resources.down;//向下的图标
            }
            this.Visible = frienddata.IsAtMe > 0;//等于0隐藏
        }

        public void AddEvent(Action<string> myevent)
        {
            this.myevent = myevent;
        }

        private void USERemindMe_Paint(object sender, PaintEventArgs e)
        {
            //绘制边框
            Pen pen1 = new Pen(Color.FromArgb(225, 225, 225), 1);
            e.Graphics.DrawRectangle(pen1, 0, 0, this.Width - 1, this.Height - 1);
        }

        private void panRemind_Click(object sender, EventArgs e)
        {
            if (myevent != null)
            {
                string messageid = LocalDataUtils.GetStringData(_friend.UserId + "GROUP_AT_MESSAGEID" + Applicate.MyAccount.userId);
                myevent(messageid);
            }
            this.Visible = false;
        }

        private void USERemindMe_Load(object sender, EventArgs e)
        {
            //子控件继承点击事件
            foreach (Control crl in panRemind.Controls)
                crl.Click += (s, ev) =>
                {
                    panRemind_Click(s, ev);
                };
        }

        private void picClose_Click(object sender, EventArgs e)
        {
            //更新@状态
            _friend.UpdateAtMeState(0);
            this.Visible = false;
        }
    }
}
