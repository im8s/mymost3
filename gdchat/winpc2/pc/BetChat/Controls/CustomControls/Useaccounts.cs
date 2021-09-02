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
    public partial class Useaccounts : UserControl
    {
        public Useaccounts()
        {
            InitializeComponent();
        }
        /// <summary>
        /// 转账金额
        /// </summary>
        public string money
        {
            get { return lab_money.Text; }
            set { lab_money.Text = value; }
        }
        /// <summary>
        /// 转账标题
        /// </summary>
        public string titletext
        {
            get { return lab_name.Text; }
            set { lab_name.Text = value; }
        }
    }
}
