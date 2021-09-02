using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk
{
    public partial class USELoding : UserControl
    {
        public USELoding()
        {
            InitializeComponent();
            picLoad.Parent = this;
        }

        public Color BgColor;
        

        /// <summary>
        /// 文字
        /// </summary>
        public string Title
        {
            get
            {
                return lblTitle.Text;
            }
            set
            {
                lblTitle.Text = value;
            }
        }

        public Font LabelFont
        {
            get
            {
                return lblTitle.Font;
            }
            set
            {
                lblTitle.Font = value;
            }
        }
        /// <summary>
        /// 该控件大小
        /// </summary>
        public Size LoadSize;
        /// <summary>
        /// 等待符大小
        /// </summary>
        public void PictureBoxSize()
        {
            picLoad.Size = LoadSize;
        }

        public void ControlColor()
        {
            this.BackColor = BgColor;
            picLoad.BackColor = BgColor;
            lblTitle.BackColor = BgColor;
        }

        /// <summary>
        /// 整个控件大小,根据PictureBox控件大小而变
        /// </summary>
        public void ControlSize()
        {
            if (!string.IsNullOrEmpty(Title))
            {
                this.Size = new Size(Convert.ToInt32(EQControlManager.GetStringTheSize(Title, lblTitle.Font).Width)+20,LoadSize.Height + 20);
                return;
            }
            this.Size = new Size(LoadSize.Width + 20, LoadSize.Height + 20);
        }
        public void LabelSize()
        {
            lblTitle.Size = new Size(this.Width, 20);
        }

        /// <summary>
        /// PictureBox位置
        /// </summary>
        public void PictureBoxLocation()
        {
            if (!string.IsNullOrEmpty(Title))
            {
                picLoad.Location = new Point((this.Width - picLoad.Width) / 2, (this.Height - lblTitle.Height - picLoad.Height) / 2);
            }
            else
            {
                lblTitle.Visible = false;
                picLoad.Location = new Point((this.Width - picLoad.Width)/2, (this.Height - picLoad.Height) / 2);
            }
        }
        /// <summary>
        /// Label位置
        /// </summary>
        public void LabelLocation()
        {
            lblTitle.Location = new Point(0, picLoad.Location.Y + picLoad.Height);
        }

        internal void ControlThis()
        {
            //控件颜色方法
            this.ControlColor();
            //设置等待符内的pic大小
            this.PictureBoxSize();
            //设置这个控件大小
            this.ControlSize();
            //设置文字控件大小
            this.LabelSize();
            //设置等待符内的pic位置
            this.PictureBoxLocation();
            //设置文字位置
            this.LabelLocation();
            //设置等待符控件的位置
        }
    }
}
