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
    public partial class USeCheckData : UserControl
    {
        
        //功能名称（如“群组名称”，“群组描述”）
        public string FunctionName
        {
            get { return lblfeatures.Text; }
            set { lblfeatures.Text = value; }
        }
        public USeCheckData()
        {
            InitializeComponent();
        }
       
        private void InfoCard_Load(object sender, EventArgs e)
        {
            
        }
        
        private void panel1_MouseHover(object sender, EventArgs e)
        {
            this.BackColor = ColorTranslator.FromHtml("#D8D8D9");//悬浮颜色
        }

        private void panel1_MouseLeave(object sender, EventArgs e)
        {
            this.BackColor = Color.White;
        }
      
    }
}
