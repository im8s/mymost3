using System;
using System.Drawing;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk
{

    /// <summary>
    /// 
    /// </summary>
    public partial class FriendListItem : UserControl
    {

        private bool isSelected;


        /// <summary>
        /// 当前项是否选中
        /// </summary>
        public bool IsSelected
        {
            get { return isSelected; }
            set
            {
                isSelected = value;
                if (value)
                {
                    this.BackColor = Color.Silver;
                }
                else
                {
                    this.BackColor = Color.Transparent;
                }
            }
        }

        /// <summary>
        /// 当前的朋友
        /// </summary>
        public Friend CurrentFriend { get; set; }

        public FriendListItem()
        {
            InitializeComponent();
        }

        private void FriendListItem_MouseEnter(object sender, EventArgs e)
        {
            if (!IsSelected)
            {
                this.BackColor = Color.Silver;
            }
            else
            {
                this.BackColor = Color.DimGray;
            }
        }

        private void FriendListItem_MouseLeave(object sender, EventArgs e)
        {
            if (!IsSelected)
            {
                this.BackColor = Color.Transparent;
            }
            else
            {
                this.BackColor = Color.DimGray;
            }
        }

        private void FriendListItem_Load(object sender, EventArgs e)
        {
            ImageLoader.Instance.DisplayAvatar(CurrentFriend.userId, pbAvator);//设置头像
        }

        private void FriendListItem_Click(object sender, EventArgs e)
        {
            if (!IsSelected)
            {
                this.BackColor = Color.DimGray;
            }
        }
    }
}
