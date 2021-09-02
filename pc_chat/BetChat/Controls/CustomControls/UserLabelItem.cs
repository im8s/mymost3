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
    public partial class UserLabelItem : UserControl
    {
        private bool isSelected;

        private FriendLabel _data;
        public FriendLabel FriendLabel
        {
            get { return _data; }
            set
            {
                _data = value;

                lblName.Text = UIUtils.LimitTextLength(FriendLabel.groupName, 13, true) + "(" + FriendLabel.GetFriendCount() + ")";
                string str = FriendLabel.GetFriendNames();
                lblFriend.Text = UIUtils.LimitTextLength(str, 13, true);
            }
        }

        public UserLabelItem()
        {
            InitializeComponent();
        }

        public bool IsSelected
        {
            get { return isSelected; }
            set
            {
                isSelected = value;
                if (IsSelected)
                {
                    this.BagColor = ColorTranslator.FromHtml("#DCDCDC");
                }
                else
                {
                    this.BagColor = Color.Transparent;
                }
            }
        }


        public Color BagColor
        {
            get { return this.BackColor; }
            set
            {
                this.BackColor = value;
                lblName.BackColor = value;
                lblFriend.BackColor = value;
            }
        }


        /// <summary>
        /// 鼠标悬浮
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void UserLabelItem_MouseEnter(object sender, EventArgs e)
        {
            if (!IsSelected)
            {
                this.BagColor = ColorTranslator.FromHtml("#DCDCDC");
            }
        }
        /// <summary>
        /// 鼠标离开
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void UserLabelItem_MouseLeave(object sender, EventArgs e)
        {
            if (!IsSelected)
            {
                this.BagColor = Color.Transparent;
            }
        }

        private void lblName_MouseDown(object sender, MouseEventArgs e)
        {
            this.OnMouseDown(e);
        }
    }
}
