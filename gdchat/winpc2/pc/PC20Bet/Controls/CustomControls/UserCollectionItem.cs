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
    public partial class UserCollectionItem : UserControl
    {
        /// <summary>
        /// 类型
        /// </summary>
        public string type { get; set; }
        public string CollectContent { get; set; }
        public UserCollectionItem()
        {
            InitializeComponent();
        }

        public string Time
        {
            get { return lblTime.Text; }
            set { lblTime.Text = value; }
        }
      
        public Color BagColor
        {
            get { return this.BackColor; }
            set
            {
                this.BackColor = value;
                lblTime.BackColor = value;
                lblComeFrom.BackColor = value;
               
            
        }
        }
        private bool isSelected;
        public bool IsSelected
        {
            get { return isSelected; }
            set
            {
                isSelected = value;
                if (IsSelected)
                {
                  //  this.BagColor = ColorTranslator.FromHtml("#CAC8C6");
                   
                    //if(panel.Controls.Count!=0)
                    //{
                  

                }
                else
                {
                    this.BagColor = Color.Transparent;
                }
            }
        }
        public string ComeFrom
        {

            get
            {
                return lblComeFrom.Text;
            }

            set
            {
                lblComeFrom.Text = value;
            }
        }

        private void lblTime_MouseDown(object sender, MouseEventArgs e)
        {
            this.OnMouseDown(e);
        }
    }
}
