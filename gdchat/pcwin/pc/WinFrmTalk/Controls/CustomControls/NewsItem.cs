using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Threading;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.Properties;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class NewsItem : UserControl
    {

        #region Private Member
        private Friend frienddata = new Friend();
        private bool isSelected = false;
        // 缓存的圆形头像
        private Bitmap mRoundImage = null;
        // 当前显示的红点数量
        private int mCurrtUnreadNum = 0;
        // 是否显示未读数量
        private bool UnreadVisible = false;
        #endregion

        #region 对外暴露的方法

        /// <summary>
        /// 保存整个好友实体类
        /// </summary>
        public Friend FriendData
        {
            get
            {
                return frienddata;
            }
            set
            {
                frienddata = value;

                // 刷新背景颜色
                RefreshItemBgColor();

                // 刷新免打扰标志位
                RefreshDisturb();

                // 刷新昵称
                RefreshNickName();

                // 刷新内容
                RefreshContent();

                // 刷新时间
                RefreshMessageTime();

                // 刷新@我
                lab_content.AtMe = frienddata.IsAtMe;

                // 不再去刷新头像和未读
            }
        }


        /// <summary>
        /// 是否选中
        /// </summary>
        public bool IsSelected
        {
            get { return isSelected; }
            set
            {
                isSelected = value;

                RefreshItemBgColor();
            }
        }


        // 刷新昵称
        public void RefreshNickName()
        {
            lab_name.Text = FriendData.GetRemarkName();
        }

        // 刷新消息免打扰
        public void RefreshDisturb()
        {
            lab_readNum.Visible = FriendData.Nodisturb == 1;
        }

        // 刷新最后一条消息内容
        public void RefreshContent()
        {
            lab_content.Text = GetFriendLastContent(FriendData);
        }

        // 刷新最后一条消息内容
        public void RefreshMessageTime()
        {
            lab_time.Text = TimeUtils.ChatLastTime(FriendData.LastMsgTime);
        }

        // 刷新头像
        //public void RefreshFriendImage()
        //{
        //    this.Invoke(new Action(SafeLoadImage));
        //}

        public void RefreshFriendImage()
        {
            //Console.WriteLine("RefreshFriendImage:" + pic_head.IsHandleCreated + " ,  " + FriendData.GetRemarkName() + " , " + Thread.CurrentThread.IsBackground);
            //string userid = FriendData.IsGroup == 1 ? FriendData.RoomId : FriendData.UserId;
            //ImageLoader.Instance.DisplayAvatar(userid, this.pic_head, (bitmap) =>
            //{
            //    pic_head.BackgroundImage = bitmap;
            //    mRoundImage = bitmap;
            //    RefreshUnreadNum();
            //});


            if (FriendData == null)
            {
                return;
            }

            if (FriendData.IsGroup == 1)
            {
                ImageLoader.Instance.DisplayGroupAvatar(FriendData.UserId, FriendData.RoomId, pic_head, (bitmap) =>
                {
                    mRoundImage = BitmapUtils.ChangeSize(bitmap, pic_head.Width, pic_head.Height);
                    pic_head.BackgroundImage = mRoundImage;
                    RefreshUnreadNum();
                });
            }
            else
            {
                ImageLoader.Instance.DisplayAvatar(FriendData.UserId, (bitmap) =>
                {
                    mRoundImage = BitmapUtils.ChangeSize(bitmap, pic_head.Width, pic_head.Height);
                    //bitmap;// BitmapUtils.ChangeSize(bitmap, pic_head.Width, pic_head.Height);
                    pic_head.BackgroundImage = mRoundImage;
                    RefreshUnreadNum();
                });
            }
        }


        // 刷新未读角标
        public void RefreshUnreadNum()
        {
            Console.WriteLine("RefreshUnreadNum:" + pic_head.IsHandleCreated + " ,  " + FriendData.GetRemarkName() + " , " + Thread.CurrentThread.IsBackground);
            // 超过99 不去绘制
            if (FriendData.MsgNum >= mCurrtUnreadNum && mCurrtUnreadNum >= 100)
            {
                return;
            }

            // 未读数量未发生改变不要去绘制
            if (FriendData.MsgNum == mCurrtUnreadNum)
            {
                return;
            }

            // 缓存头像为空时不去绘制
            if (BitmapUtils.IsNull(mRoundImage))
            {
                return;
            }

            mCurrtUnreadNum = FriendData.MsgNum;


            // 改变头像位置
            UnreadVisible = mCurrtUnreadNum > 0;

            ChangeHeadImageSize();

            // 绘制红点
            if (UnreadVisible)
            {
                DrawUnReadCount(mCurrtUnreadNum);
            }
            else
            {
                pic_head.BackgroundImage = mRoundImage;
            }
        }

        // 刷新置顶和选中
        private void RefreshItemBgColor()
        {

            if (IsSelected)
            {
                this.BackColor = ColorTranslator.FromHtml("#CAC8C6");
                this.lab_readNum.ForeColor = Color.FromArgb(230, 229, 229);
            }
            else
            {
                if (FriendData.TopTime == 0)//如果为置顶 , 默认颜色为选中颜色
                {
                    this.BackColor = Color.Transparent;
                    this.lab_readNum.ForeColor = Color.FromArgb(202, 200, 198);

                }
                else
                {//设置为置顶颜色
                    this.BackColor = Color.FromArgb(220, 220, 220);
                    this.lab_readNum.ForeColor = Color.FromArgb(202, 200, 198);
                }
            }
        }

        // 清除at我的角标
        public void ClearAtmeTip()
        {
            frienddata.IsAtMe = 0;
            frienddata.UpdateAtMeState(0);
            this.lab_content.AtMe = 0;
        }


        #endregion

        public NewsItem()
        {
            InitializeComponent();

            #region 继承父级的方法
            //Click Event
            lab_name.Click += Parent_Click;
            lab_content.Click += Parent_Click;
            lab_readNum.Click += Parent_Click;
            lab_time.Click += Parent_Click;
            pic_head.Click += Parent_Click;

            //Double Click Event
            lab_name.DoubleClick += Parent_DoubleClick;
            lab_content.DoubleClick += Parent_DoubleClick;
            lab_readNum.DoubleClick += Parent_DoubleClick;
            lab_time.DoubleClick += Parent_DoubleClick;
            pic_head.DoubleClick += Parent_DoubleClick;

            //MouseClick Event
            lab_name.MouseClick += Parent_MouseClick;
            lab_content.MouseClick += Parent_MouseClick;
            lab_readNum.MouseClick += Parent_MouseClick;
            lab_time.MouseClick += Parent_MouseClick;
            pic_head.MouseClick += Parent_MouseClick;

            //MouseLeave Event
            lab_name.MouseLeave += Parent_MouseLeave;
            lab_content.MouseLeave += Parent_MouseLeave;
            lab_readNum.MouseLeave += Parent_MouseLeave;
            lab_time.MouseLeave += Parent_MouseLeave;
            pic_head.MouseLeave += Parent_MouseLeave;

            //MouseEnter Event
            lab_name.MouseEnter += Parent_MouseEnter;
            lab_content.MouseEnter += Parent_MouseEnter;
            lab_readNum.MouseEnter += Parent_MouseEnter;
            lab_time.MouseEnter += Parent_MouseEnter;
            pic_head.MouseEnter += Parent_MouseEnter;

            //MouseEnter Event
            lab_name.MouseDown += Parent_MouseDown;
            lab_content.MouseDown += Parent_MouseDown;
            lab_readNum.MouseDown += Parent_MouseDown;
            lab_time.MouseDown += Parent_MouseDown;
            pic_head.MouseDown += Parent_MouseDown;
            #endregion
        }

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

        #endregion

        #region 鼠标移入移出事件
        private void NewsItem_MouseEnter(object sender, EventArgs e)
        {
            //非选中状态
            if (!IsSelected && frienddata.TopTime == 0)
            {
                this.BackColor = ColorTranslator.FromHtml("#D8D8D9");//悬浮颜色
            }
        }

        private void NewsItem_MouseLeave(object sender, EventArgs e)
        {
            //非选中状态
            if (!IsSelected && frienddata.TopTime == 0)
            {
                this.BackColor = Color.Transparent;//离开时变回默认的颜色
            }
        }

        #endregion

        #region 昵称和最后一条消息内容裁剪事件

        private void lab_name_TextChanged(object sender, EventArgs e)
        {
            EQControlManager.StrAddEllipsis((Label)sender, ((Label)sender).Font);
        }

        private void lab_content_TextChanged(object sender, EventArgs e)
        {
            EQControlManager.StrAddEllipsis((Label)sender, ((Label)sender).Font);
        }

        #endregion

        #region 未读数量绘制逻辑
        /// <summary>
        /// 头像需要跟随红点改变位置和大小
        /// </summary>
        private void ChangeHeadImageSize()
        {
            if (UnreadVisible)
            {
                pic_head.Size = new Size(45, 45);
                pic_head.Location = new Point(6, 5);
            }
            else
            {
                pic_head.Size = new Size(35, 35);
                pic_head.Location = new Point(6, 12);
            }
        }


        /// <summary>
        /// 绘制未读数量
        /// </summary>
        /// <param name="unreadcount"></param>
        //private void DrawUnReadCount(int unreadcount) {

        //    this.Invoke(new Action(()=> {
        //        SafeDrawUnReadCount(unreadcount);
        //    }));
        //}


        private void DrawUnReadCount(int unreadcount)
        {

            //if (!pic_head.IsHandleCreated)
            //{
            //    //this.Invoke(new Action(() =>{
            //    //    DrawUnReadCount(unreadcount);
            //    //}));
            //    return;
            //}

            Console.WriteLine("DrawUnReadCount:" + pic_head.IsHandleCreated + " ,  " + FriendData.GetRemarkName() + " , " + Thread.CurrentThread.IsBackground);

            if (!UnreadVisible)
            {
                return;
            }

            int p_width = 20, p_heigh = 20;
            //if (lab_readNum.Text.Trim().Length == 0) { p_width = 10; p_heigh = 10; }
            Bitmap bmpRedP = EQControlManager.DrawRoundPic(p_width, p_heigh, Color.Red);
            using (Graphics g = Graphics.FromImage(bmpRedP))
            {
                //实线画刷
                SolidBrush mysbrush1 = new SolidBrush(Color.DarkOrchid);
                mysbrush1.Color = Color.FromArgb(250, Color.White);
                //字体居中
                PointF pointF;
                //长度为0时只显示红点不显示数字
                if (unreadcount.ToString().Length != 0)
                {
                    if (unreadcount.ToString().Length == 1)
                    {
                        pointF = new PointF(5, 3);
                    }
                    else if (unreadcount.ToString().Length == 2)
                    {
                        pointF = new PointF(2, 2.5f);
                    }
                    else
                    {
                        pointF = new PointF(-1, 2.5f);
                    }
                    //写入未读数量
                    string text = unreadcount < 100 ? unreadcount.ToString() : "99+";
                    g.DrawString(text, new Font(Applicate.SetFont, 8F, FontStyle.Regular, GraphicsUnit.Point, ((byte)(134))), mysbrush1, pointF);
                    mysbrush1.Dispose();
                    g.Dispose();
                }
            }

            //绘制红点
            Bitmap bmpBack = BitmapUtils.CombineRedPointToImg(bmpRedP, mRoundImage);
            pic_head.BackgroundImage = bmpBack;
        }


        /// <summary>
        /// 在头像上绘制红点
        /// </summary>
        /// <param name="foreImage">前景图</param>
        /// <param name="backImage">背景图</param>
        /// <returns></returns>
        private Bitmap CombineRedPointToImg(Image foreImage, Image backImage)
        {
            Bitmap bitmap = new Bitmap(45, 45);
            Graphics g = Graphics.FromImage(bitmap);
            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.CompositingQuality = CompositingQuality.HighQuality;
            g.DrawImage(backImage, new Rectangle(0, 8, 35, 35), 0, 0, backImage.Width, backImage.Height, GraphicsUnit.Pixel);
            g.DrawImage(foreImage, new Rectangle(23, 0, foreImage.Width, foreImage.Height), 0, 0, foreImage.Width, foreImage.Height, GraphicsUnit.Pixel);

            return bitmap;
        }


        #endregion

        private void NewsItem_Load(object sender, System.EventArgs e)
        {
            if (frienddata != null)
            {
                RefreshFriendImage();
            }
        }


        #region 取出friend的最后一条消息
        public string GetFriendLastContent(Friend friend)
        {

            return friend.Content;
        }

        #endregion

    }
}
