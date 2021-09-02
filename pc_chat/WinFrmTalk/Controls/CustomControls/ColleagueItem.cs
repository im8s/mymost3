using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls;

namespace WinFrmTalk
{
    public partial class ColleagueItem : FriendItem
    {
        public ColleagueItem()
        {
            InitializeComponent();
            
        }
        /// <summary>
        /// 职位
        /// </summary>
        public string Position
        {
            get { return lblPosition.Text; }
            set { lblPosition.Text = value; }
        }
        /// <summary>
        /// 用户ID
        /// </summary>
        private string _UserID;
        private Action<ColleagueItem> MouseMenu;

        public string UserID
        {
            get { return _UserID; }
            set { _UserID = value; }

        }
        /// <summary>
        /// 创建者ID
        /// </summary>
        public int createUserId { get; set; }

        private void ColleagueItem_MouseDown(object sender, MouseEventArgs e)
        {

            if (MouseMenu != null)
            {
                this.MouseMenu(this);
            }

           LogUtils.Log(this.UserID);
        }

        internal void RightMenu(Action<ColleagueItem> p)
        {
            MouseMenu = p;
        }
    }
}
