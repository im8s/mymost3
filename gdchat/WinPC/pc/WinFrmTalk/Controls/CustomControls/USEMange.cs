using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class USEMange : UserControl
    {
        private bool isSelected;

        /// <summary>
        /// 是否选中 
        /// </summary>
        public bool IsSelected
        {
            get { return isSelected; }
            set
            {
                isSelected = value;
                if (IsSelected)
                {
                    this.BackColor = ColorTranslator.FromHtml("#CAC8C6");
                }
                else
                {
                    this.BackColor = Color.Transparent;
                }
            }
        }
        public USEMange()
        {
            InitializeComponent();
        }

        private Friend frienddata;
        
        /// <summary>
        /// 保存整个好友实体类
        /// </summary>
        public Friend friendData
        {
            get { return frienddata; }
            set
            {
                frienddata = value;
                lab_name.Text = frienddata.NickName;
              //  ImageLoader.Instance.DisplayAvatar(frienddata.userId, this.pic_head);//设置头像
            }
        }
        public string  GroupInName
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
        private void lab_name_TextChanged(object sender, EventArgs e)
        {
            if (((Label)sender).Text.Length > 10)
            {
                ((Label)sender).Text = ((Label)sender).Text.ToString().Remove(10) + "...";
            }
        }

        #region 事件由父级处理
        private void lab_name_Click(object sender, EventArgs e)
        {
            this.OnClick(e);
        }
        private void lab_name_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }
        private void lblName_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }
        private void pic_head_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }
        #endregion

     
        private void lblName_TextChanged(object sender, EventArgs e)
        {
            if (((Label)sender).Text.Length > 7)
            {
                ((Label)sender).Text = ((Label)sender).Text.ToString().Remove(6) + "...";
            }
        }
    
        private void USEMange_MouseEnter(object sender, EventArgs e)
        {
            //if (!IsSelected)
            //{
            //    this.BackColor = ColorTranslator.FromHtml("#D8D8D9");//悬浮颜色
            //    use = this;
            //}
        }
        /// <summary>
        /// 鼠标离开事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void USEMange_MouseLeave(object sender, EventArgs e)
        {
           //if (!IsSelected)
           // {
           //     use.BackColor = Color.Transparent;
           //     this.BackColor = Color.Transparent;//悬浮颜色
               
           //}
        }

        private void pic_head_Click(object sender, EventArgs e)
        {

        }

        private void pic_head_MouseDown(object sender, MouseEventArgs e)
        {
            this.OnMouseDown(e);
        }

        private void lab_name_MouseDown(object sender, MouseEventArgs e)
        {
            this.OnMouseDown(e);
        }

        private void lblName_MouseDown(object sender, MouseEventArgs e)
        {
            this.OnMouseDown(e);
        }
    }
}
