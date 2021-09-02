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
    public partial class UserCountry : UserControl
    {
        public UserCountry()
        {
            InitializeComponent();
        }
        private string _Contry;
        private int _AreaCode;


        public string  Contrys
        {
            set { _Contry = value; }
            get { return _Contry;  }
        }
        public int AreaC
        {
            set { _AreaCode = value; }
            get { return _AreaCode; }
        }
        private bool isSelected;
        /// <summary>
        /// 设置值
        /// </summary>
        /// <param name="Contry"></param>
        /// <param name="AreaCode"></param>
        public  void setdata(string Contry, string English, string AreaCode)
        {
            lblName.Text = Contry+"("+ English+")";
            lblAreaCode.Text = "+"+AreaCode;
            Contrys = Contry;
            AreaC = Convert.ToInt32( AreaCode);
        }
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

    }
}
