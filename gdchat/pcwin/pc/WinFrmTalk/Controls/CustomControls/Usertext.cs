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
    public partial class Usertext : UserControl
    {
        public Usertext()
        {
            InitializeComponent();
        }
        /// <summary>
        /// 原本的长度
        /// </summary>
        public string chatText { get; set; }
        public string sometext
        {
            get { return lbltext.Text; }
            set
            {
                //if(value.Length>=25)
                //{
                //    lbltext.Text = value.Substring(0, 25)+"...";
                //}
                lbltext.Text = value;
            }
        }


      private bool isSelected;
        /// <summary>
        /// 设置值
        /// </summary>
        /// <param name="Contry"></param>
        /// <param name="AreaCode"></param>
        //public void setdata(string Contry, string English, string AreaCode)
        //{
        //    lblName.Text = Contry + "(" + English + ")";
        //    lblAreaCode.Text = "+" + AreaCode;
        //    Contrys = Contry;
        //    AreaC = Convert.ToInt32(AreaCode);
        //}
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

        private void lbltext_TextChanged(object sender, EventArgs e)
        {
            EQControlManager.StrAddEllipsis(lbltext, lbltext.Font, this.Width - 10);
        }
    }
}
