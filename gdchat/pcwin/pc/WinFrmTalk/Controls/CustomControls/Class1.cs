using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;


namespace WinFrmTalk.Controls.CustomControls
{
   public class USEpanel:Panel
    {
        private UserControl _userControl;
        private int _PageNum;
        private Size _userCrlSize;
        private Point _LastCtl;
        Button btn = new Button();

        //往panel添加的用户控件
        public UserControl userControl
        {
            get { return _userControl; }
            set { _userControl = value; }
        }
        //分页显示，每页显示的个数
        public int PageNum
        {
            get { return _PageNum; }
            set { _PageNum = value; }
        }
            //用户控件的大小
         public Size UserCrlSize
        {
            get { return _userCrlSize; }
            set { _userCrlSize = value; }
        }
        public Point LastCtl
        {
            get { return _LastCtl; }
            set { _LastCtl = value; }
        }
        public USEpanel()
        {
            this.MouseWheel += this_MouseWheel;
           

        }
        private void this_MouseWheel(object sender, System.Windows.Forms.MouseEventArgs e)
        {
          

            if (e.Delta > 0)
            {
                if (this.VerticalScroll.Value == 0)
                {
                    this.VerticalScroll.Value = 0;
                }
                else
                {
                    if ( this.VerticalScroll.Value- this.VerticalScroll.Minimum < 5)
                    {
                        this.VerticalScroll.Value = this.VerticalScroll.Minimum;
                    }
                    else
                    {
                        this.VerticalScroll.Value -= 5;
                    }
                    
                }

            }
            else
            {
                
                if (this.VerticalScroll.Maximum - this.VerticalScroll.Value < 5)
                {
                    this.VerticalScroll.Value = this.VerticalScroll.Maximum;
                }
                else
                {
                    this.VerticalScroll.Value = this.VerticalScroll.Value + 5;
                }
            }
            if (this.VerticalScroll.Value == 0)
            {
                this.Location = new Point(9, 37);

            }
            int count = 0;
            if (this.VerticalScroll.Value == 0 && e.Delta > 0)
            {
               if(count ==0)
                {
                    btn.Visible = true;

                    btn.Size = new Size(140, 19);
                    btn.Location = new Point( (this.Parent.Width - btn.Width) / 2, 5);
                    // btn.Location = new Point(81, 12);
                    btn.BackColor = Color.Transparent;
                    btn.FlatStyle = FlatStyle.Flat;
                    btn.FlatAppearance.BorderSize = 0;
                    btn.Visible = true;
                    btn.Text = "刷新中";
                    this.Parent.Controls.Add(btn);
                    btn.Click += Btn_Click;
                    count++;
                }

                else
                {
                    btn.Visible = true;
                }
               
            }
            //一到底就开始自动加入新的数据
            //比较 this.VerticalScroll.Maximum前后是否有变化

            else if (this.VerticalScroll.Value == (-this.AutoScrollPosition.Y))
            {
                btn.Visible = false;
               
                int x = this.VerticalScroll.Maximum;
               
                for (int i = 0; i < PageNum; i++)
                {
                    USEGroupCard uSEGrouops = new USEGroupCard();

                    uSEGrouops.Size =UserCrlSize;
                    //获取上一个
                    uSEGrouops.GroupsImg = WinFrmTalk.Properties.Resources.Logo;
                    uSEGrouops.chkSelects.Visible = false;
                    uSEGrouops.lblNames.Text = i.ToString();
                    uSEGrouops.Location = new Point(0, userControl.Height * i +this.Height);
                   // userControl.Text ="a"+ i.ToString();
                    this.Controls.Add(uSEGrouops);
                }
            }
            
            else
            {
                btn.Visible = false;
            }
            this.Refresh();
            this.Invalidate();
            this.Update();
            //throw new NotImplementedException();
        }
        private void Btn_Click(object sender, EventArgs e)
        {
            btn.Text = "";
          //  btn.Controls.Add()
            //throw new NotImplementedException();
        }
    }
}
