using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;
using System.Drawing.Drawing2D;

namespace WinFrmTalk.Controls.CustomControls
{
    public delegate void _DeleteGroups(USEGroupCard usegropcard, bool  isAdd);
  

    public partial class USEGroupCard : UserControl
    {
        public  event _DeleteGroups groupsEvent;
        //private bool _isCancel;
        //private Friend _BindsClass;
        private Image _GroupsImg;
        public Image GroupsImg
        {
            get { return _GroupsImg; }
            set { _GroupsImg = value; }
        }

        public bool  isCancel
        {
            get;
            set;
        }
        public  Friend  BindClass
        {
            get;set;
        }
       
            public USEGroupCard()
        {
            InitializeComponent();
        }
       
        private void checkBox1_Paint(object sender, PaintEventArgs e)
        {
            Graphics grp = e.Graphics;
            Rectangle rec = chkSelect.ClientRectangle;

        }

        

        private void USEGroupCard_MouseDown(object sender, MouseEventArgs e)
        {
            isCancel = true;
            //添加到的位置？
            if (groupsEvent !=null)
            {
                if (chkSelects.Checked)
                {
                    chkSelects.Checked = false;
                    groupsEvent(this, true);

                }
                //删除的位置？
                else
                {
                    chkSelects.Checked = true;
                  //  groupsEvent(this,  true);
                }
            }
            this.BackColor = Color.DarkGray;
           
        }

      

        private void USEGroupCard_MouseLeave(object sender, EventArgs e)
        {
            this.BackColor = Color.White;
        }
        
      

        private void USEGroupCard_MouseEnter(object sender, EventArgs e)
        {
            this.BackColor = Color.Gray;
        }



        private void chkSelect_CheckedChanged(object sender, EventArgs e)
        {
            if (chkSelects.Checked)
            {
              //  chkSelect.Checked = false;
              if(isCancel)
                {
                    groupsEvent(this, true);
                }
               
            }
            else
            {
                if (isCancel)
                {
                    groupsEvent(this, false);
                }
            }
        }

        private void pic_Load(object sender, EventArgs e)
        {

        }

        private void pictureBox1_Paint(object sender, PaintEventArgs e)
        {
           // pictureBox1.Parent = panel1;
            //panel1.BackColor = Color.Transparent;
            GraphicsPath path = new GraphicsPath();
            int h = pics.ClientRectangle.Width > pics.ClientRectangle.Height ? pics.Height : pics.Width;
            path.AddEllipse(pics.ClientRectangle.X, pics.ClientRectangle.Y, h-2, h-2);
            Region reg = new Region(path);
            this.pics.Region = reg;

           pics.BackgroundImage = GroupsImg;
            reg.Dispose();
            path.Dispose();
        }

        private void USEGroupCard_Load(object sender, EventArgs e)
        {

        }

        private void pics_Click(object sender, EventArgs e)
        {

        }
    }
}
