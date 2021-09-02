using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Drawing2D;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class SearchTextBox : UserControl
    {
        public SearchTextBox()
        {
            InitializeComponent();
        }
        public string Context
        {
            get
            {
                return txtSearch.Text;
            }
            set
            {
                txtSearch.Text = value;
            }
        }
        private void txtSearch_MouseDown(object sender, MouseEventArgs e)
        {
          
        }

        private void txtSearch_Enter(object sender, EventArgs e)
        {
            this.BackColor = ColorTranslator.FromHtml("#E8E8E8");
            this.txtSearch.BackColor = ColorTranslator.FromHtml("#E8E8E8");
        }

        private void txtSearch_Leave(object sender, EventArgs e)
        {
            this.BackColor = Color.FromArgb(232, 232, 232);
            this.txtSearch.BackColor = Color.FromArgb(232, 232, 232);
        }
    }
}
