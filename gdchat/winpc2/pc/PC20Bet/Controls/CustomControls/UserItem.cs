using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;
using static WinFrmTalk.FrmFriendSelect;
using WinFrmTalk.Properties;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class UserItem : UserControl
    {

        private Friend _friend;

        public Friend Friend
        {
            get
            {
                return _friend;
            }
            set
            {
                _friend = value;

                SetName();
                SetHeadImage();
            }
        }

        public event FrinedLeftHandler SelectedFriend;

        /// <summary>
        /// 好友昵称
        /// </summary>
        private void SetName()
        {
            lab_name.Text = Friend.GetRemarkName();
        }


        /// <summary>
        /// 好友头像
        /// </summary>
        private void SetHeadImage()
        {
            if (Friend.IsGroup == 1)
            {
                ImageLoader.Instance.DisplayGroupAvatar(Friend.UserId, Friend.RoomId, pic_head, (bitmap) => {
                    pic_head.BackgroundImage = BitmapUtils.ChangeSize(bitmap, pic_head.Width, pic_head.Height);
                });
            }
            else
            {
                if ("allRoomMember".Equals(Friend.UserId))
                {
                    Bitmap bitmap = BitmapUtils.GetRoundImage(Resources.avatar_default);
                    pic_head.BackgroundImage = BitmapUtils.ChangeSize(bitmap, pic_head.Width, pic_head.Width);
                }
                else
                {
                    ImageLoader.Instance.DisplayAvatar(Friend.UserId, pic_head);
                }
                
            }
        }


        /// <summary>
        /// 是否勾选
        /// </summary>
        public bool CheckState
        {
            get { return chb.Checked; }
            set
            {
                chb.Checked = value;
                Friend.UserType = chb.Checked ? 1 : 0;
            }
        }


        public UserItem()
        {
            InitializeComponent();

            #region 继承父类的方法
            lab_name.MouseEnter += Parent_MouseEnter;
            pic_head.MouseEnter += Parent_MouseEnter;

            lab_name.MouseLeave += Parent_MouseLeave;
            pic_head.MouseLeave += Parent_MouseLeave;
            #endregion

            this.Click += OnItemClick;
        }

        #region Parent Event
        private void Parent_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }
        private void Parent_MouseLeave(object sender, EventArgs e)
        {
            this.OnMouseLeave(e);
        }

        private void OnItemClick(object sender, EventArgs e)
        {
            //CheckState = !CheckState;
            SelectedFriend?.Invoke(this);
        }
        #endregion


        #region 事件由父级处理
        private void lab_name_Click(object sender, EventArgs e)
        {
            this.OnClick(e);
        }

        private void pic_head_Click(object sender, EventArgs e)
        {
            this.OnClick(e);
        }

        private void lab_name_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }

        private void chb_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }

        private void pic_head_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }
        #endregion

        private void UserItem_MouseEnter(object sender, EventArgs e)
        {
            //如果选中状态，背景色不改变
            if (CheckState)
                return;

            this.BackColor = Color.WhiteSmoke;
        }

        private void UserItem_MouseLeave(object sender, EventArgs e)
        {
            //如果选中状态，背景色不改变
            if (CheckState)
                return;

            //离开时变回默认的颜色
            this.BackColor = Color.White;
        }

        private void chb_CheckedChanged(object sender, EventArgs e)
        {
            //已选中
            if (CheckState)
                this.BackColor = Color.Gainsboro;
            else
                this.BackColor = Color.White;

            //如果不为空则执行
            //if (!isNoEvent)
            //{
            //    SelectedFriend?.Invoke(Friend, CheckState);
            //}
            //else
            //{
            //    isNoEvent = false;
            //}

        }


    }
}
