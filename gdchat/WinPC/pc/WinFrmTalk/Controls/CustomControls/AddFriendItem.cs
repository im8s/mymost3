using System;
using System.Drawing;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    public partial class AddFriendItem : UserControl
    {
        public AddFriendItem()
        {
            InitializeComponent();
        }

        public Friend friendData
        {
            get { return friendItem.FriendData; }
            set
            {
                if (value != null)
                {
                    friendItem.FriendData = value;
                }
                else
                {
                    friendItem.FriendData = new Friend();
                }
            }
        }

        /// <summary>
        /// 悬浮颜色
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnAdd_MouseEnter(object sender, EventArgs e)
        {
            friendItem.BackColor = ColorTranslator.FromHtml("#D8D8D9");
        }
        /// <summary>
        /// 离开颜色
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnAdd_MouseLeave(object sender, EventArgs e)
        {
            friendItem.BackColor = Color.Transparent;
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            if (friend != null)
            {
                friend(friendData);
            }
        }
        private Action<Friend> friend;
        internal void Add(Action<Friend> AddFriend)
        {
            friend = AddFriend;
        }

        private void friendItem_MouseEnter(object sender, EventArgs e)
        {
            label1.BackColor = ColorTranslator.FromHtml("#D8D8D9");
        }

        private void friendItem_MouseLeave(object sender, EventArgs e)
        {
            label1.BackColor = Color.Transparent;
        }
    }
}
