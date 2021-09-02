using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.View;

namespace WinFrmTalk.View
{
    public partial class SelfInfo : Form
    {
        public SelfInfo()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            SetingName settingname = new SetingName();
            settingname.ShowDialog();

        }
    }
}
