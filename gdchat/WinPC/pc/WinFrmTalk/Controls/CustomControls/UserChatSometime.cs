using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class UserChatSometime : UserControl
    {
        public UserChatSometime()
        {
            InitializeComponent();
            //MouseLeave Event
            lbltext.MouseLeave += Parent_MouseLeave;
            picdeleate.MouseLeave += Parent_MouseLeave;

            //MouseEnter Event
            lbltext.MouseEnter += Parent_MouseEnter;
            picdeleate.MouseEnter += Parent_MouseEnter;

            lbltext.MouseDown += Parent_MouseDown;
            picdeleate.MouseDown += Parent_MouseDown;

        }
        private bool isSelected;
        /// <summary>
        /// 常用语（截取长度后的数据）
        /// </summary>
        public  string Sometimetext
        {
            get { return lbltext.Text;  }
            set
            {
                //if(value.Length>=30)
                //{
                //    lbltext.Text = value.Substring(0,30)+"...";
                //}
                lbltext.Text = value;

            }
        }
       
      
        /// <summary>
        /// 是否选中
        /// </summary>
        public bool IsSelected
        {
            get { return isSelected; }
            set
            {
                isSelected = value;
                if (IsSelected)
                {
                    this.BackColor = ColorTranslator.FromHtml("#CAC8C6");
                }
                else
                {
                    this.BackColor = Color.Transparent;
                }
            }
        }
        private void FriendItem_MouseEnter(object sender, EventArgs e)
        {
            if (!IsSelected)
            {
                this.BackColor = ColorTranslator.FromHtml("#D8D8D9");//悬浮颜色
            }
        }

        private void FriendItem_MouseLeave(object sender, EventArgs e)
        {

            //非选中状态
            if (!IsSelected)
            {
                //离开时变回默认的颜色
                this.BackColor = Color.Transparent;
            }
        }
        private void Parent_MouseClick(object sender, MouseEventArgs e)
        {
            this.OnMouseClick(e);
        }

        private void Parent_MouseLeave(object sender, EventArgs e)
        {
            this.OnMouseLeave(e);
        }

        private void Parent_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }

        private void Parent_MouseDown(object sender, MouseEventArgs e)
        {
            this.OnMouseDown(e);
        }

        private void lbltext_TextChanged(object sender, EventArgs e)
        {
            EQControlManager.StrAddEllipsis(lbltext, lbltext.Font, this.Width - 40);
        }
    }
}
