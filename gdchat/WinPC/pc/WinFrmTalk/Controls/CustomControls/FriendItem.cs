using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.Properties;

namespace WinFrmTalk.Controls
{
    // 好友列表项&群组列表项
    public partial class FriendItem : UserControl
    {

        #region Member

        private bool isSelected;
        private Friend frienddata = new Friend();

        private Image mImage;// 头像图片
        private int redCount;

        // 是否正在绘制
        private bool IsDrawing = false;

        /// <summary>
        /// 是否选中
        /// </summary>
        public bool IsSelected
        {
            get { return isSelected; }
            set
            {
                isSelected = value;
                if (IsSelected)
                {
                    this.BackColor = ColorTranslator.FromHtml("#CAC8C6");
                }
                else
                {
                    this.BackColor = Color.Transparent;
                }
            }
        }

        /// <summary>
        /// 保存整个好友实体类
        /// </summary>
        public Friend FriendData
        {
            get { return frienddata; }
            set
            {
                frienddata = value;
                redCount = frienddata.MsgNum;
                ChangeFriendName();
                LoadHeadImage();
            }
        }

        #endregion

        #region 构造方法
        public FriendItem()
        {
            InitializeComponent();


            #region 子控件事件传递
            //Click Event
            lab_name.Click += Parent_Click;
            pic_head.Click += Parent_Click;

            //Double Click Event
            lab_name.DoubleClick += Parent_DoubleClick;
            pic_head.DoubleClick += Parent_DoubleClick;

            //MouseClick Event
            lab_name.MouseClick += Parent_MouseClick;
            pic_head.MouseClick += Parent_MouseClick;

            //MouseLeave Event
            lab_name.MouseLeave += Parent_MouseLeave;
            pic_head.MouseLeave += Parent_MouseLeave;

            //MouseEnter Event
            lab_name.MouseEnter += Parent_MouseEnter;
            pic_head.MouseEnter += Parent_MouseEnter;

            //MouseEnter Event
            lab_name.MouseDown += Parent_MouseDown;
            pic_head.MouseDown += Parent_MouseDown;
            #endregion

            this.pic_head.BackgroundImageLayout = ImageLayout.Zoom;
        }
        #endregion

        #region Parent Event
        private void Parent_Click(object sender, EventArgs e)
        {
            this.OnClick(e);
        }

        private void Parent_DoubleClick(object sender, EventArgs e)
        {
            this.OnDoubleClick(e);
        }

        private void Parent_MouseClick(object sender, MouseEventArgs e)
        {
            this.OnMouseClick(e);
        }

        private void Parent_MouseLeave(object sender, EventArgs e)
        {
            this.OnMouseLeave(e);
        }

        private void Parent_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }

        private void Parent_MouseDown(object sender, MouseEventArgs e)
        {
            this.OnMouseDown(e);
        }

        private void FriendItem_MouseEnter(object sender, EventArgs e)
        {
            if (!IsSelected)
            {
                this.BackColor = ColorTranslator.FromHtml("#D8D8D9");//悬浮颜色
            }
        }

        private void FriendItem_MouseLeave(object sender, EventArgs e)
        {

            //非选中状态
            if (!IsSelected)
            {
                //离开时变回默认的颜色
                this.BackColor = Color.Transparent;
            }
        }

        #endregion

        #region 昵称显示回调_处理长名称
        private void lab_name_TextChanged(object sender, EventArgs e)
        {
            if (((Label)sender).Text.Length > 11)
            {
                ((Label)sender).Text = ((Label)sender).Text.ToString().Remove(9) + "...";
            }
        }
        #endregion

        #region 加载头像方法
        public void LoadHeadImage()
        {
            if (FriendData.IsGroup == 1)
            {
                ImageLoader.Instance.DisplayGroupAvatar(FriendData.UserId, FriendData.RoomId, pic_head, (bitmap) => {
                    mImage = BitmapUtils.ChangeSize(bitmap, pic_head.Width, pic_head.Height);
                    pic_head.BackgroundImage = mImage;
                    if (frienddata != null && frienddata.UserType == FriendType.NEWFRIEND_TYPE)
                    {
                        DrawUnRead(redCount);
                    }
                });
            }
            else
            {
                ImageLoader.Instance.DisplayAvatar(FriendData.UserId, (bitmap) =>
                {
                    mImage = BitmapUtils.ChangeSize(bitmap, pic_head.Width, pic_head.Height);
                    pic_head.BackgroundImage = mImage;
                    if (frienddata != null && frienddata.UserType == FriendType.NEWFRIEND_TYPE)
                    {
                        DrawUnRead(redCount);
                    }
                });
            }
        }

        #endregion

        #region 改变朋友名称

        public void ChangeFriendName()
        {
            lab_name.Text = frienddata.GetRemarkName();
        }
        #endregion

        #region 改变头像大小和位置适配红点
        /// <summary>
        /// 头像需要跟随红点改变位置和大小
        /// </summary>
        private void ModifyPicLocation()
        {
            if (redCount > 0)
            {
                pic_head.Size = new Size(45, 45);
                pic_head.Location = new Point(6, 0);
            }
            else
            {
                pic_head.Size = new Size(35, 35);
                pic_head.Location = new Point(6, 8);
            }
        }

        #endregion

        #region 画未读角标
        public void DrawUnRead(int unreadcount)
        {
            redCount = unreadcount;

            if (BitmapUtils.IsNull(mImage))
            {
                return;
            }

            if (redCount <= 0)
            {
                ModifyPicLocation();
                if (BitmapUtils.IsNull(mImage))
                {
                    LoadHeadImage();
                }
                else
                {
                    pic_head.isDrawRound = false;
                    pic_head.BackgroundImage = mImage;
                }
            }
            else
            {
                DrawUnReadCount();
            }
        }

        #endregion

        private void DrawUnReadCount()
        {
            ModifyPicLocation();

            //显示红点和数字
            if (redCount > 0 && !IsDrawing)
            {
                IsDrawing = true;
                int p_width = 20, p_heigh = 20;

                Bitmap bmpRedP = EQControlManager.DrawRoundPic(p_width, p_heigh, Color.Red);
                using (Graphics g = Graphics.FromImage(bmpRedP))
                {
                    //实线画刷
                    SolidBrush mysbrush1 = new SolidBrush(Color.DarkOrchid);
                    mysbrush1.Color = Color.FromArgb(250, Color.White);
                    //字体居中
                    PointF pointF;
                    //长度为0时只显示红点不显示数字

                    string str = redCount.ToString();

                    if (str.Length == 1)
                    {
                        pointF = new PointF(5, 3);
                    }
                    else if (str.Length == 2)
                    {
                        pointF = new PointF(2, 3);
                    }
                    else
                    {
                        pointF = new PointF(0, 3);
                    }

                    //写入未读数量
                    g.DrawString(str, new Font(Applicate.SetFont, 8F, FontStyle.Regular, GraphicsUnit.Point, ((byte)(134))), mysbrush1, pointF);
                    mysbrush1.Dispose();
                    g.Dispose();
                }

                Bitmap headImage = new Bitmap(mImage);
                //绘制红点
                Bitmap bmpBack = BitmapUtils.CombineRedPointToImg(bmpRedP, headImage);
                pic_head.isDrawRound = false;
                pic_head.BackgroundImage = bmpBack;
                IsDrawing = false;
            }
        }
    }
}
