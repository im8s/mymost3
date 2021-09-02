using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Windows;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class USEpicAddName : UserControl
    {
        private string _NickName;
        private string _Userid;
        private string _roomjid;
        private int _currentRole;
        /// <summary>
        /// userid
        /// </summary>
        public string Userid
        {
            get { return _Userid; }
            set { _Userid = value; }
        }
        /// <summary>
        /// 群roojid
        /// </summary>
        public string roomjid
        {
            get { return _roomjid; }
            set { _roomjid = value; }
        }
        public int CurrentRole
        {
            get { return _currentRole; }
            set { _currentRole = value; }
        }

        /// <summary>
        /// 昵称
        /// </summary>
        public string NickName
        {
            get
            {

                return lblName.Text;
            }
            set
            {
                if(lblName!=null)
                {
                    int width = FontWidth(lblName.Font, lblName, value);
                    // int len = lblName.Width * lblName.Text.Length / width;
                    if ((width + lblName.Location.X) > (pics.Location.X + pics.Width))
                    {
                        lblName.Text = value.Substring(0, 3) + "..";
                        int width2 = FontWidth(lblName.Font, lblName, lblName.Text);
                        int x = (pics.Location.X + pics.Width - width2 + 6) / 2;
                        lblName.Location = new System.Drawing.Point(x, lblName.Location.Y);
                    }
                    else
                    {
                        lblName.Text = value;

                        int x = (pics.Location.X + pics.Width - width) / 2;
                        lblName.Location = new System.Drawing.Point(x, lblName.Location.Y);
                    }
                }
                else
                {
                    lblName.Text = value;
                }
              
            }
        }

        public USEpicAddName()
        {
            InitializeComponent();
        }

        /// <summary>
        ///获取文字的宽度
       
       
        /// </summary>
        /// <param name="font"></param>
        /// <param name="control"></param>
        /// <param name="str"></param>
        /// <returns></returns>
        private int FontWidth(Font font, Control control, string str)
        {
            Graphics g = control.CreateGraphics();
           SizeF siF = g.MeasureString(str, font); return (int)siF.Width;
         
        }
        private void USEpicAddName_Load(object sender, EventArgs e)
        {
            _NickName = lblName.Text;
           }

        /// <summary>
        /// 鼠标放在图像上显示卡片
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void pics_Click(object sender, EventArgs e)
        {
            FrmFriendsBasic frmFriendsBasic = new FrmFriendsBasic();
            frmFriendsBasic.ShowUserInfoByRoom(Userid,roomjid, CurrentRole);
          
           frmFriendsBasic.Show();
          
        }
        /// <summary>
        /// 手势
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pics_MouseHover(object sender, EventArgs e)
        {
            RoundPicBox pics = (RoundPicBox)sender;
            pics.Cursor = Cursors.Hand;
        }
    }
    }

