using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.Controls
{
    public partial class UserReadPaper : UserControl
    {

        public UserReadPaper()
        {
            InitializeComponent();
        }
        /// <summary>
        /// 红包标题
        /// </summary>
        public string titletext
        {
            get { return lab_text.Text; }
            set { lab_text.Text = value; }
        }
       
    }
}
