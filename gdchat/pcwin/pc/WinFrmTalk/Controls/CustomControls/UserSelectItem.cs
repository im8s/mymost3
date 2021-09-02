 using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Drawing2D;
using WinFrmTalk.Helper;
using WinFrmTalk.Properties;
using WinFrmTalk.Model;
using static WinFrmTalk.FrmFriendSelect;

namespace WinFrmTalk
{
    public partial class UserSelectItem : UserControl
    {
        public UserSelectItem()
        {
            InitializeComponent();
        }


        private Friend _friend;

        public Friend Friend {

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

        public event FrinedSelectHandler SelectedFriend;

        /// <summary>
        /// 好友昵称
        /// </summary>
        private void SetName() {

            lblNickname.Text = Friend.GetRemarkName();
        }


        /// <summary>
        /// 好友头像
        /// </summary>
        private void SetHeadImage()
        {
            if (Friend.IsGroup == 1)
            {
                ImageLoader.Instance.DisplayGroupAvatar(Friend.UserId, Friend.RoomId, picHead, (bitmap) => {
                    picHead.BackgroundImage = BitmapUtils.ChangeSize(bitmap, picHead.Width, picHead.Height);
                });
            }
            else
            {
                ImageLoader.Instance.DisplayAvatar(Friend.UserId, picHead);
            }

            //ImageLoader.Instance.DisplayAvatar(Friend.UserId, picHead);
        }

        /// <summary>
        /// 悬浮背景色
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uscFriendShow_MouseEnter(object sender, EventArgs e)
        {
            this.BackColor=Color.Gainsboro;
        }
        /// <summary>
        /// 鼠标离开后背景色
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void uscFriendShow_MouseLeave(object sender, EventArgs e)
        {
            this.BackColor = Color.WhiteSmoke;
        }
       // private Action<int> mSelectedListener;
      
        /// <summary>
        /// 图片绘制成圆形
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void USEFriendClose_Load(object sender, EventArgs e)
        {
            GraphicsPath gp = new GraphicsPath();

            gp.AddEllipse(picHead.ClientRectangle);

            Region region = new Region(gp);

            picHead.Region = region;

            gp.Dispose();

            region.Dispose();
        }

       

        /// <summary>
        /// 按钮悬浮
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pictureBox1_MouseEnter(object sender, EventArgs e)
        {
            pictureBox1.Image = Resources.CloseZh;
            this.BackColor = Color.Gainsboro;
        }
        /// <summary>
        /// 按钮离开
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pictureBox1_MouseLeave(object sender, EventArgs e)
        {
            pictureBox1.Image = Resources.CloseZh;
            this.BackColor = Color.White;
        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {
            SelectedFriend?.Invoke(Friend);
        }
    }
}
