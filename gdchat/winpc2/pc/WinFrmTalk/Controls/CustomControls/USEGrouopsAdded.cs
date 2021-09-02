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
    public delegate void _CancelGroups(USEGrouopsAdded uSEGrouopsAdded);
    public partial class USEGrouopsAdded : UserControl
    {
        public event _CancelGroups CangroupsEvent;
        public USEGrouopsAdded()
        {
            InitializeComponent();
        }

        private void USEGrouopsAdded_Load(object sender, EventArgs e)
        {

        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
         
            
              if(CangroupsEvent !=null)
            {
                CangroupsEvent(this);
            }
               
        }

        private void picGroups_Load(object sender, EventArgs e)
        {

        }
    }
}
