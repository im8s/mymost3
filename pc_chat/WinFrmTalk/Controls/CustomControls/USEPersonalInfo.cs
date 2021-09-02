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
    public partial class USEPersonalInfo : UserControl
    {
        public USEPersonalInfo()
        {
            InitializeComponent();
            picChangeControl1.PersonPic =new Bitmap(@"C:\Users\Temp\Desktop\01.jpg", true);
        }
    }
}
