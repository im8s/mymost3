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
    public partial class Usereceiveredpaper : UserControl
    {

        public Usereceiveredpaper()
        {
            InitializeComponent();
        }
       public void getdata( string userid , string nickname,string money, string time)
        {
            lab_name.Text = nickname;
            lab_time.Text = time;
            lab_money.Text = money;
            this.Tag = userid;
        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {

        }
    }
}
