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
    public partial class FilePanelRight : UserControl
    {
        public FilePanelRight()
        {
            InitializeComponent();
        }

        private void lab_fileName_TextChanged(object sender, EventArgs e)
        {
            ((Label)sender).Text = ((Label)sender).Text.Length > 19 ? ((Label)sender).Text.Remove(17) + "..." : ((Label)sender).Text;
        }
    }
}
