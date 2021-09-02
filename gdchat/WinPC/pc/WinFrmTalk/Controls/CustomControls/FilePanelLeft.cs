using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk
{
    public partial class FilePanelLeft : UserControl
    {
        /// <summary>
        ///记录文件是否正在下载
        /// </summary>
        public bool isDownloading { get; set; }
        public FilePanelLeft()
        {
            InitializeComponent();
        }

        private void FilePanel_Load(object sender, EventArgs e)
        {
            this.Size = new Size(panel_file.Width + 2, panel_file.Height + 2);
        }

        //private int CAN_CHANGED = 1;
        private void lab_fileName_TextChanged(object sender, EventArgs e)
        {

            var control = (Label)sender;
            //获取行文字所占的大小
            SizeF sizeF = EQControlManager.GetStringTheSize(control.Text, new Font("宋体", 10F));
            //替换省略号
            string lable_str = control.Text;
            if (sizeF.Width > lab_fileName.Width)
            {
                while (sizeF.Width >= lab_fileName.Width - 20)
                {
                    lable_str = lable_str.Remove(lable_str.Length - 1);
                    sizeF = EQControlManager.GetStringTheSize(lable_str, new Font("宋体", 10F));
                }
            control.Text = lable_str + "...";
            }
            //control.Text = control.Text.Length > 18 ? control.Text.Remove(16) + "..." : ((Label)sender).Text;
        }
    }
}
