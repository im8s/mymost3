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
    public partial class ChatItem : UserControl
    {
        public ChatItem()
        {
            InitializeComponent();
        

            #region 继承父类的方法
            this.lblName.Click += Parent_Click;
            this.lblDatime.Click += Parent_Click;
            this.pboxHead.Click += Parent_Click;
            this.lblName.MouseClick += Parent_MouseClick;
            this.lblDatime.MouseClick += Parent_MouseClick;
            this.pboxHead.MouseClick += Parent_MouseClick;
            #endregion
        }
        #region 属性
        //添加聊天人名字
        public string fileName
        {
            get
            {
                return lblName.Text;
            }
            set
            {
                lblName.Text = value;
            }
        }
      
        //时间
        public string Time
        {
            get
            {
                return lblDatime.Text;
            }
            set
            {
                lblDatime.Text = value;
            }
        }
        //头像
        public PictureBox GetInco()
        {
            return pboxHead;
        }
        #endregion
        private void Parent_Click(object sender, EventArgs e)
        {
            this.OnClick(e);
        }
        private void Parent_MouseClick(object sender, MouseEventArgs e)
        {
            this.OnMouseClick(e);
        }
      
    }
}
