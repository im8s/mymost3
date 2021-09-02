using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
using WinFrmTalk.Model;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using WinFrmTalk.Dictionarys;
using System;
using System.Runtime.InteropServices;
using WinFrmTalk.Helper.MVVM;
using TestListView;
using WinFrmTalk.Controls.CustomControls;

namespace WinFrmTalk.Controls
{

    public abstract class EQBaseControl : Panel
    {
        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.ExStyle |= 0x02000000;
                return cp;
            }
        }

        public const int minHeight = 50;
        public static int BubbleWidth, BubbleHeight;       //显示气泡的宽度和高度
        public static Color bg_color;       //背景颜色
        public bool is_have_bubble;      //是否应该含有气泡
        public MessageObject messageObject = null;
        public static Dictionary<kWCMessageType, EQBaseControl> typeControls;   //控件类字典
        public bool isOneSelf = true;           //是否为本人
        public bool isRemindMessage = false;    //是否为提醒消息类型
        public bool isHaveBorder = true;        //气泡背景是否有边框
        public bool isShowLabMsg = false;       //是否显示信息状态标签
        public bool isReadDel = false;          //是否启用阅后即焚
        public XListView xListView { get; set; }

        /*控件可修改扩展*/
        Label lab_msg = null;   //聊天信息状态（送达，已读，已读人数）
        public Label lab_redPoint = null;  //未读红点
        Label lab_readDeleted = null;   //阅后即焚
        public Label lab_name = null;  //用户昵称
        RoundPicBox lab_head = null;  //头像

        /// <summary>
        /// 初始化对象
        /// </summary>
        /// <param name="strJson_msg">聊天信息Json(相当于工厂设计模式中的金钱）</param>
        public EQBaseControl(string strJson)
        {
            //初始化宽高的数值
            BubbleWidth = 0;
            BubbleHeight = 0;

            messageObject = new MessageObject().toModel(strJson);
            //获取气泡背景颜色并记录该消息是否为本人
            bg_color = GetBgColor();
            is_have_bubble = IsHaveBubble();
        }

        /// <summary>
        /// 初始化对象
        /// </summary>
        /// <param name="strJson_msg">聊天信息Json(相当于工厂设计模式中的金钱）</param>
        public EQBaseControl(MessageObject messageObject)
        {
            //初始化宽高的数值
            BubbleWidth = 0;
            BubbleHeight = 0;

            this.messageObject = messageObject;
            bg_color = GetBgColor();
            is_have_bubble = IsHaveBubble();
        }

        #region 子类必须重写的方法
        /// <summary>
        /// 气泡内的消息框
        /// </summary>
        /// <returns></returns>
        public abstract Control ContentControl();

        /// <summary>
        /// 计算显示框高度和宽度,子类继承后将长度高度写入到父类中
        /// </summary>
        /// <param name="control">气泡内的控件</param>
        public abstract void Calc_PanelWidth(Control control);
        #endregion


        #region 鼠标点击监听
        public Action mouseDownListen;   //点击内容的鼠标事件
        /// <summary>
        /// 点击内容的鼠标事件
        /// </summary>
        /// <param name="mouseDownListen">鼠标监听</param>
        public virtual void AddMouseDownListen(Action mouseDownListen)
        {
            this.mouseDownListen = mouseDownListen;
        }
        #endregion

        //public static bool isShowSendTime = false;      //是否展示发送时间
        /// <summary>
        /// 添加发送时间布局
        /// </summary>
        /// <returns></returns>
        public virtual Label DrawSendTime(double stp_lastMsg)
        {
            if (messageObject.type == kWCMessageType.labMoreMsg)
                return null;
            DateTime dt_lastMsg = Helpers.StampToDatetime(stp_lastMsg);     //最后一条消息的时间
            DateTime dt_timeSend = Helpers.StampToDatetime(messageObject.timeSend);     //信息发送时间
            //判断两条信息的时间间隔
            TimeSpan timeSpan = dt_timeSend - dt_lastMsg;
            if (timeSpan.TotalMinutes < 3.1)     //如果间隔三分钟以下，则不进行绘制
                return null;
            DateTime dt_Now = DateTime.Now;     //当前时间
            int time_type = dt_timeSend.Date.Equals(dt_Now.Date) ? 0 : 1;      //时间类型（是否为当天的消息），是否需要显示年月日，0为短，1为长
            string time_format = time_type == 0 ? "HH:mm:ss" : "yyyy-MM-dd HH:mm:ss";
            string send_time = dt_timeSend.ToString(time_format);
            //string image_path = time_type == 0 ? @"Res\SendTimeBg\shortTimeBg.png" : @"Res\SendTimeBg\longTimeBg.png";
            int lab_width = time_type == 0 ? 60 : 125;
            //Bitmap bitmap = new Bitmap(image_path);

            Label lab_sendTime = new Label();
            lab_sendTime.Name = "lab_sendTime_" + messageObject.messageId;
            lab_sendTime.Text = send_time;
            //lab_sendTime.Image = bitmap;
            lab_sendTime.Size = new Size(lab_width, 20);
            //lab_sendTime.Location = new Point(5, 5);
            lab_sendTime.TextAlign = ContentAlignment.MiddleCenter;
            lab_sendTime.Font = new Font(Applicate.SetFont, 9F/*, FontStyle.Bold, GraphicsUnit.Point, 134*/);
            lab_sendTime.ForeColor = Color.FromArgb(128, 128, 128);
            lab_sendTime.Tag = time_format;
            return lab_sendTime;
        }


        public static bool isShowReadPersons = false;   //是否展示已读人数
        /// <summary>
        /// 添加已读人数布局
        /// </summary>
        public virtual void DrawReadPersons()
        {
            //如果是自己发送的消息，且发送状态（isSend）不为1，则不显示已读人数而是显示对应的状态
            if (messageObject.fromUserId == Applicate.MyAccount.userId && messageObject.isSend != 1)
            {
                EQControlManager.DrawIsSend(messageObject, lab_msg);
                return;
            }

            int persons_num = messageObject.readPersons;
            EQControlManager.DrawReadPerson(persons_num, lab_msg);
            lab_msg.TextAlign = ContentAlignment.MiddleCenter;
            lab_msg.Visible = isShowLabMsg; //默认不开启群已读
        }


        public static bool isShowUserName = false;      //是否展示昵称
        /// <summary>
        /// 添加用户名称布局（暂且不用）
        /// </summary>
        public virtual void DrawUserName(string user_name) { }


        #region 绘图（气泡）
        Panel Bubble_panel = new Panel();

        //生成对话气泡
        public Image MakeTalkBubble(bool isOneSelf, ref Size bg_size)
        {
            //调整背景色
            if (isOneSelf)
                bg_color = Color.FromArgb(139, 233, 219);
            else
                bg_color = Color.FromArgb(255, 255, 255);

            Panel conter_panel = new Panel();

            //气泡最小高度
            if (BubbleHeight < 25)
                BubbleHeight = 25;
            //计算长宽
            int width, height;
            if (isHaveBorder) { width = BubbleWidth + 25; height = BubbleHeight + 10; }
            else { width = BubbleWidth + 12; height = BubbleHeight + 3; }
            //记录长宽
            bg_size = new Size(width, height);

            //超过极限值会报参数无效的错误
            if (width > 2000 || height > 2000)
            {
                width = width > 2000 ? 2000 : width;
                height = height > 2000 ? 2000 : height;
            }

            //复用相同高度和宽度的气泡图片
            var bg_result = BubbleBgDictionary.GetBackground(width, height, isOneSelf);
            if (bg_result != null)
                return bg_result;

            Bitmap localBitmap = new Bitmap(width, height);
            Graphics bitmapGraphics = Graphics.FromImage(localBitmap);
            bitmapGraphics.Clear(Color.WhiteSmoke);
            bitmapGraphics.SmoothingMode = SmoothingMode.AntiAlias;

            //设定左右不同气泡的值
            int rectangle_x = 0;
            int rectangle_width = width;
            int rectangle_height = height;
            int orientation = 0;
            if (!isOneSelf)
            {
                rectangle_x = 0;
                rectangle_width = width + 10;
                rectangle_height = height;
                orientation = 1;
            }

            Rectangle rectangle = new Rectangle(rectangle_x, 0, rectangle_width, rectangle_height);
            Draw(rectangle, bitmapGraphics, 10, true, orientation, bg_color, bg_color);
            bitmapGraphics.Dispose();
            //localBitmap.Save(@"D:\test.png");
            BubbleBgDictionary.AddBackground(width, height, isOneSelf, localBitmap);
            return localBitmap;
        }

        //对话框绘图
        private void Draw(Rectangle rectangle, Graphics g, int _radius, bool cusp, int orientation, Color begin_color, Color end_color)
        {
            int span = 2;
            //抗锯齿
            g.SmoothingMode = SmoothingMode.AntiAlias;
            //渐变填充
            LinearGradientBrush myLinearGradientBrush = new LinearGradientBrush(rectangle, begin_color, end_color, LinearGradientMode.Vertical);
            //画尖角
            if (cusp)
            {
                if (orientation == 0)
                {
                    span = 10;
                    PointF p1 = new PointF(rectangle.Width - 12, rectangle.Y + 9);
                    PointF p2 = new PointF(rectangle.Width - 12, rectangle.Y + 25);
                    PointF p3 = new PointF(rectangle.Width, rectangle.Y + 17);
                    PointF[] ptsArray = { p1, p2, p3 };
                    g.FillPolygon(myLinearGradientBrush, ptsArray);
                    g.FillPath(myLinearGradientBrush, DrawRoundRect(rectangle.X, rectangle.Y, rectangle.Width - span, rectangle.Height - 1, _radius));
                }
                else if (orientation == 1)
                {
                    span = 10;
                    PointF p1 = new PointF(12, rectangle.Y + 9);
                    PointF p2 = new PointF(12, rectangle.Y + 25);
                    PointF p3 = new PointF(0, rectangle.Y + 17);
                    PointF[] ptsArray = { p1, p2, p3 };
                    g.FillPolygon(myLinearGradientBrush, ptsArray);
                    g.FillPath(myLinearGradientBrush, DrawRoundRect(rectangle.X + span, rectangle.Y, rectangle.Width - span, rectangle.Height - 1, _radius));
                }
                else
                {
                    g.FillPath(myLinearGradientBrush, DrawRoundRect(rectangle.X, rectangle.Y, rectangle.Width - span, rectangle.Height - 1, _radius));
                }
            }
        }
        //对话框圆角
        private static GraphicsPath DrawRoundRect(int x, int y, int width, int height, int radius)
        {
            //四边圆角
            GraphicsPath gp = new GraphicsPath();
            gp.AddArc(x, y, radius, radius, 180, 90);
            gp.AddArc(width - radius, y, radius, radius, 270, 90);
            gp.AddArc(width - radius, height - radius, radius, radius, 0, 90);
            gp.AddArc(x, height - radius, radius, radius, 90, 90);
            gp.CloseAllFigures();
            return gp;
        }
        private Color GetBgColor()
        {
            string userId = Applicate.MyAccount.userId;
            isOneSelf = string.Equals(this.messageObject.fromUserId, userId);
            if (isOneSelf)
                return Color.FromArgb(139, 233, 219);
            else
                return Color.FromArgb(255, 255, 255);
        }
        #endregion

        #region 绘制头像
        public virtual void SetHeaderImage()
        {
            lab_head = new RoundPicBox();
            lab_head.Name = "lab_head";
            lab_head.Size = new Size(35, 35);
            lab_head.Tag = messageObject.fromUserId;
            lab_head.Cursor = Cursors.Hand;
            ImageLoader.Instance.DisplayAvatar(messageObject.fromUserId, lab_head);

            //Bitmap bmp = new Bitmap(lab_head.BackgroundImage);
            //Bitmap icon_head = EQControlManager.GetIconByUserId(messageObject.fromUserId);
            //action_set_head.Invoke(icon_head);
            lab_head.MouseDown += (sender, e) =>
            {
                if (e.Button == MouseButtons.Left)
                {
                    if (sender is RoundPicBox lab_head && lab_head.Tag != null)
                    {
                        FrmFriendsBasic frmFriendsBasic = new FrmFriendsBasic();
                        if (messageObject.isGroup == 0)
                            frmFriendsBasic.ShowUserInfoById(lab_head.Tag.ToString());
                        else
                        {
                            string roomJid = Applicate.MyAccount.userId.Equals(messageObject.FromId) ? messageObject.ToId : messageObject.FromId;
                            Friend choose_target = new Friend() { UserId = roomJid }.GetFdByUserId();
                            int role = new RoomMember() { roomId = choose_target.RoomId, userId = Applicate.MyAccount.userId }.GetRoleByUserId();
                            if (xListView.Parent != null && xListView.Parent is ShowMsgPanel showMsgPanel)
                            {
                                //普通群成员
                                if (role != 1 && role != 2)
                                {
                                    //不允许群成员私聊
                                    if (showMsgPanel.IsRoomUserRecommend == 0)
                                        return;
                                }
                            }
                            frmFriendsBasic.ShowUserInfoByRoom(lab_head.Tag.ToString(), roomJid, role);
                        }
                    }
                }
                else if (e.Button == MouseButtons.Right)
                {
                    if (sender is RoundPicBox lab_head && lab_head.Parent != null)
                    {
                        string msgId = lab_head.Parent.Name.Replace("talk_panel_", "");
                        //MessageObject msg = MessageObjectDataDictionary.GetMsg(msgId);
                        MessageObject msg = this.messageObject;
                        if (msg == null)
                            return;
                        //如果右键对象不是自己，则允许@
                        if (msg.fromUserId == Applicate.MyAccount.userId)
                            return;
                        //如果不为群聊则不存在@
                        if (msg.isGroup == 0)
                            return;

                        //创建菜单项
                        ToolStripMenuItem tsmiAt = new ToolStripMenuItem();
                        tsmiAt.Name = "tsmiAt";
                        //tsmiAt.Size = new Size(180, 22);
                        tsmiAt.Text = "@" + msg.fromUserName;
                        tsmiAt.Click += (s, ev) =>
                        {
                            MessageObject at_msg = new MessageObject()
                            {
                                messageId = Guid.NewGuid().ToString("N"),   //唯一ID
                                objectId = msg.FromId.Equals(Applicate.MyAccount.userId) ? msg.ToId : msg.FromId,   //当前聊天对象
                                type = kWCMessageType.AtUserToTxtSend,
                                fromUserId = msg.fromUserId,
                                fromUserName = msg.fromUserName,
                                isGroup = 1,
                                content = "@" + msg.fromUserName + " "
                            };
                            Messenger.Default.Send(at_msg, token: EQFrmInteraction.AddAtUserToTxtSend);
                        };
                        //创建一个右键菜单
                        ContextMenuStripEx cmsAt = new ContextMenuStripEx();
                        cmsAt.AutoSize = true;
                        cmsAt.Items.Add(tsmiAt);
                        lab_head.ContextMenuStrip = cmsAt;
                    }
                }
            };
        }
        #endregion

        #region 绘制信息状态栏
        /// <summary>
        /// 已读
        /// </summary>
        /// <returns></returns>
        public virtual void DrawIsRead()
        {
            EQControlManager.DrawIsRead(lab_msg);
        }
        /// <summary>
        /// 送达
        /// </summary>
        /// <returns></returns>
        public virtual void DrawIsSend()
        {
            EQControlManager.DrawIsSend(messageObject, lab_msg);
        }

        public bool isShowRedPoint = false;      //该消息类型是否需要红点
        /// <summary>
        /// 已接收（重绘直接调用该方法便可）
        /// </summary>
        /// <returns></returns>
        public virtual void DrawIsReceive(Label lab_redPoint, int isRead)
        {
            if (!isShowRedPoint)
                return;

            //去除红点
            if (isRead == 1)
            {
                if (lab_redPoint.Image != null)
                    lab_redPoint.Image.Dispose();
                lab_redPoint.Image = null;
                return;
            }

            #region 绘制红点
            Image msg_image = Image.FromFile(@"Res\StateBg\new_tips.png");
            int newHeigh = 9;
            int newWidth = 9;
            Bitmap newMsgBg = new Bitmap(newWidth, newHeigh);
            Graphics g = Graphics.FromImage(newMsgBg);
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.CompositingQuality = CompositingQuality.HighQuality;
            g.DrawImage(msg_image, new Rectangle(0, 0, newWidth, newHeigh), new Rectangle(0, 0, msg_image.Width + 1, msg_image.Height + 1), GraphicsUnit.Pixel);
            g.Dispose();
            #endregion

            if (lab_redPoint.Image != null)
                lab_redPoint.Image.Dispose();
            lab_redPoint.Image = newMsgBg;
            //lab_redPoint.ImageList.ColorDepth = ColorDepth.Depth32Bit;
        }

        //阅后即焚计时器
        public Timer readDel_timer = new Timer();
        /// <summary>
        /// 绘制阅后即焚效果（文本）
        /// </summary>
        /// <returns></returns>
        public virtual void DrawisReadDel(Label lab_readDeleted, int second)
        {
            if (lab_readDeleted.Image == null)
            {
                #region 绘制阅后即焚
                //背景图
                Bitmap msg_image = new Bitmap(@"Res\StateBg\fire.png");
                int newHeigh = 20;
                int newWidth = 20;
                Bitmap newMsgBg = new Bitmap(newWidth + 1, newHeigh + 1);
                Graphics g = Graphics.FromImage(newMsgBg);
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.DrawImage(msg_image, new Rectangle(0, 0, newWidth, newHeigh), new Rectangle(0, 0, msg_image.Width, msg_image.Height), GraphicsUnit.Pixel);
                #endregion

                if (lab_readDeleted.Image != null)
                    lab_readDeleted.Image.Dispose();
                lab_readDeleted.Image = newMsgBg;
                lab_readDeleted.ImageAlign = ContentAlignment.MiddleLeft;
            }
            //倒计时
            lab_readDeleted.Text = second.ToString() + "s";
            lab_readDeleted.TextAlign = ContentAlignment.MiddleRight;

            //计时器销毁阅后即焚消息
            readDel_timer = new Timer();
            readDel_timer.Interval = 1000;
            readDel_timer.Enabled = true;
            readDel_timer.Start();
            readDel_timer.Tick += (sender, e) =>
            {
                string msgId = lab_readDeleted.Tag == null ? "" : lab_readDeleted.Tag.ToString();
                //修改倒计时
                //MessageObject msg = MessageObjectDataDictionary.GetMsg(msgId);
                MessageObject msg = this.messageObject;
                var chatTarget = ChatTargetDictionary.GetChatTargetDictionary();
                //停止计时
                if (msg == null || msg.isReadDel == 0 || !chatTarget.ContainsKey(msg.GetFriend().UserId))
                {
                    readDel_timer.Stop();
                    readDel_timer.Dispose();
                }
                else
                {
                    second--;
                    lab_readDeleted.Text = second.ToString() + "s";
                    if (msg != null)
                        msg.ReadDelTime = second;
                    //倒计时结束
                    if (second <= 0)
                    {
                        readDel_timer.Stop();
                        readDel_timer.Dispose();
                        Messenger.Default.Send<string>(msgId, token: EQFrmInteraction.RemoveMsgOfPanel);
                    }
                }
            };
        }

        /// <summary>
        /// 绘制阅后即焚效果（视频等）
        /// </summary>
        /// <returns></returns>
        public virtual void DrawisReadDel(Label lab_readDeleted)
        {
            if (!isReadDel)
                return;

            if (lab_readDeleted.Image == null)
            {
                #region 绘制阅后即焚
                //背景图
                Bitmap msg_image = new Bitmap(@"Res\StateBg\fire.png");
                int newHeigh = 20;
                int newWidth = 20;
                Bitmap newMsgBg = new Bitmap(newWidth + 1, newHeigh + 1);
                Graphics g = Graphics.FromImage(newMsgBg);
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.DrawImage(msg_image, new Rectangle(0, 0, newWidth, newHeigh), new Rectangle(0, 0, msg_image.Width, msg_image.Height), GraphicsUnit.Pixel);
                #endregion

                if (lab_readDeleted.Image != null)
                    lab_readDeleted.Image.Dispose();
                lab_readDeleted.Image = newMsgBg;
                lab_readDeleted.ImageAlign = ContentAlignment.MiddleLeft;
            }
        }

        /// <summary>
        /// 判断信息的当前状态
        /// </summary>
        public virtual void SetLabMsgState()
        {
            //如果是群聊消息，可能要显示已读人数
            if (messageObject.isGroup == 1)
            {
                DrawReadPersons();
                if (!isOneSelf)
                {
                    //不是所有接收的信息都需要红点
                    if (isShowRedPoint)
                        //如果是未读绘制红点
                        if (messageObject.isRead == 0)
                            DrawIsReceive(lab_redPoint, 0);
                }
            }
            else
            {
                //显示阅后即焚图标
                if (isReadDel)
                {
                    DrawisReadDel(lab_readDeleted);
                }
                //如果不是本人则没有已读和送达两个状态
                if (isOneSelf)
                {
                    //如果为已读，则绘制已读框并结束
                    if (messageObject.isRead == 1)
                    {
                        DrawIsRead();
                        return;
                    }
                    //未读不为1则检索发送状态
                    DrawIsSend();
                }
                else
                {
                    //如果显示阅后即焚，则不显示红点
                    if (!isReadDel)
                    {
                        //不是所有接收的信息都需要红点
                        if (isShowRedPoint)
                            //如果是未读绘制红点
                            if (messageObject.isRead == 0)
                                DrawIsReceive(lab_redPoint, 0);
                    }
                }
            }
        }
        #endregion

        #region 绘制聊天背景
        /// <summary>
        /// 是否应该有气泡（某些控件不需要背景）
        /// </summary>
        /// <param name="kw_type"></param>
        /// <returns></returns>
        private bool IsHaveBubble()
        {
            int[] kWCMessageType = new int[] { 2, 4, 5, 6, 28, 29, 85, 804 };      //不需要气泡
            if (((IList)kWCMessageType).Contains((int)messageObject.type))
                return false;
            return true;
        }

        /// <summary>
        /// 获取背景布局
        /// </summary>
        /// <returns></returns>
        public virtual Panel GetImagePanelBg()
        {
            Size bg_size = new Size();
            Image bg_bubble = MakeTalkBubble(isOneSelf, ref bg_size);
            Panel image_panel = new Panel();
            image_panel.Name = "image_panel";
            image_panel.BackgroundImage = bg_bubble;        //气泡作为panel的背景
            image_panel.BackgroundImageLayout = ImageLayout.Stretch;
            image_panel.Size = new Size(bg_size.Width + 2, bg_size.Height + 5);

            return image_panel;
        }
        #endregion

        #region 设置昵称
        private void SetUserName()
        {
            //群聊才显示昵称
            if (messageObject.isGroup == 0 || messageObject.fromUserId == Applicate.MyAccount.userId)
                return;

            //获取昵称
            string userName = "";
            if (Applicate.FdNames.ContainsKey(messageObject.fromUserId))
                userName = Applicate.FdNames[messageObject.fromUserId];
            userName = string.IsNullOrEmpty(userName) ? messageObject.fromUserName : userName;

            lab_name = new Label();
            lab_name.AutoSize = false;
            lab_name.Font = new Font(Applicate.SetFont, 9F);
            lab_name.ForeColor = Color.FromArgb(156, 156, 156);
            int width = (int)EQControlManager.GetStringTheSize(userName, new Font(Applicate.SetFont, 9F)).Width + 5;
            lab_name.Size = new Size(width, 18);
            lab_name.Text = userName;
            lab_name.Location = new Point(lab_head.Width + 17, 0);
        }
        #endregion

        #region RecombineControl
        /// <summary>
        /// 各个部件组成整个聊天消息框（内部调用，请勿直接外部调用）
        /// </summary>
        /// <param name="content">信息内容</param>
        public virtual EQBaseControl GetRecombinedPanel(Control content)
        {
            //内容
            content.Name = "crl_content";
            //content.ContextMenuStrip = Form1.contentMenuStrip;
            //头像
            SetHeaderImage();
            //初始化信息状态
            lab_msg = new Label();
            lab_msg.Name = "lab_msg";
            lab_msg.Location = new Point(0, 0);
            lab_msg.Size = new Size(30, 20);
            lab_msg.BackColor = Color.Transparent;
            //初始化红点控件
            lab_redPoint = new Label();
            lab_redPoint.Name = "lab_redPoint";
            lab_redPoint.Location = new Point(0, 0);
            lab_redPoint.Size = new Size(15, 15);
            lab_redPoint.BackColor = Color.Transparent;
            lab_redPoint.ImageAlign = ContentAlignment.MiddleCenter;
            //初始化阅后即焚控件
            lab_readDeleted = new Label();
            lab_readDeleted.Name = "lab_readDeleted";
            lab_readDeleted.Location = new Point(0, 0);
            lab_readDeleted.Size = new Size(isOneSelf ? 30 : 47, 20);
            lab_readDeleted.BackColor = Color.Transparent;
            lab_readDeleted.Tag = messageObject.messageId;
            //设置状态和红点控件的样式
            SetLabMsgState();
            //添加昵称
            SetUserName();

            //设定重组布局的坐标
            int content_x = 8;
            int content_y = 8;
            int lab_msg_x = 3;
            int lab_msg_y = 3;
            int lab_redPoint_x = 3;
            int lab_redPoint_y = 5;
            int lab_readDeleted_x = 5;
            int lab_readDeleted_y = 23;
            int image_panel_x = lab_msg_x + lab_msg.Width + 5;
            int image_panel_y = lab_msg_y - 2;
            int lab_head_x = 0;
            int lab_head_y = 2;
            //如果非本人
            if (!isOneSelf)
            {
                //在气泡内考虑到气泡三角需要往后移
                content_x = 18;
                lab_head_x = 3;
                //lab_head_y = 5;
                image_panel_x = lab_head_x + lab_head.Width + 5;
                image_panel_y = 0;
            }

            //Panel this = new Panel();
            //气泡
            if (is_have_bubble)
            {
                Panel image_panel = GetImagePanelBg();
                //把内容控件添加进去气泡
                image_panel.Controls.Add(content);
                content.Anchor = AnchorStyles.Top | AnchorStyles.Left;
                content.Location = isHaveBorder ? new Point(content_x, content_y) : new Point(isOneSelf ? 3 : 13, 3);
                content.MouseWheel += (sender, e) => { this.OnMouseWheel(e); };
                content.BringToFront();

                if (isOneSelf)
                {
                    lab_head_x = image_panel_x + image_panel.Width + 5;
                    //lab_head_y = image_panel_y + 3;

                    if (isReadDel)
                    {
                        //添加阅后即焚控件
                        lab_readDeleted.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                        lab_readDeleted.Location = new Point(lab_readDeleted_x, lab_readDeleted_y);
                        this.Controls.Add(lab_readDeleted);
                    }
                }
                else
                {
                    lab_msg_x = image_panel_x + image_panel.Width + 5;
                    lab_redPoint_x = image_panel_x + image_panel.Width + 5;
                    lab_redPoint_y = (image_panel.Height - lab_redPoint.Height) / 2;    //居中
                    //if (lab_redPoint_y < 24 && messageObject.isGroup == 1)
                    //    lab_redPoint_y = 23;
                    lab_readDeleted_x = image_panel_x + image_panel.Width + 3;
                    lab_readDeleted_y = (image_panel.Height - lab_readDeleted.Height) / 2;    //居中
                }

                //如果显示昵称，则往下挪
                if (lab_name != null && !string.IsNullOrEmpty(lab_name.Text))
                {
                    image_panel_y += lab_name.Height;
                    lab_msg_y += lab_name.Height;
                    lab_redPoint_y += lab_name.Height;
                }

                #region 组合控件
                //单聊中，对方的消息不会有状态
                if (!(messageObject.isGroup == 0 && messageObject.fromUserId != Applicate.MyAccount.userId))
                {
                    lab_msg.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                    lab_msg.Location = new Point(lab_msg_x, lab_msg_y);
                    this.Controls.Add(lab_msg);
                }

                //显示已读标识或者阅后即焚
                if (isReadDel)
                {
                    //添加阅后即焚控件
                    lab_readDeleted.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                    lab_readDeleted.Location = new Point(lab_readDeleted_x, lab_readDeleted_y);
                    this.Controls.Add(lab_readDeleted);
                }
                else
                {
                    //未读红点
                    if (isShowRedPoint)
                    {
                        // 修改禅道#7908
                        if (isShowLabMsg && messageObject.isGroup == 1)
                        {
                            lab_redPoint_y += 10;
                        }
                        //添加红点控件
                        lab_redPoint.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                        lab_redPoint.Location = new Point(lab_redPoint_x, lab_redPoint_y);
                        this.Controls.Add(lab_redPoint);
                    }
                }

                image_panel.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                image_panel.Location = new Point(image_panel_x, image_panel_y);
                this.Controls.Add(image_panel);
                lab_head.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                lab_head.Location = new Point(lab_head_x, lab_head_y);
                this.Controls.Add(lab_head);
                this.Size = new Size(image_panel.Width + lab_head.Width + (isReadDel ? lab_readDeleted.Width : lab_msg.Width) + 15,
                    image_panel.Height + 10 < minHeight ? minHeight : image_panel.Height + 10);
                if (lab_name != null && !string.IsNullOrEmpty(lab_name.Text))
                {
                    lab_name.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                    this.Controls.Add(lab_name);
                    this.Height += lab_name.Height;
                    if (this.Width < (lab_name.Location.X + lab_name.Width))
                        this.Width = lab_name.Location.X + lab_name.Width;
                }
                #endregion
            }
            else    //不需要气泡
            {
                int align = 5;  //气泡对齐
                if (isOneSelf)
                {
                    content_x = lab_msg_x + lab_msg.Width + 5;
                    content_y = lab_msg_y - 2;
                    lab_head_x = content_x + content.Width + 10 + align;
                    //lab_head_y = content_y + 6;

                    if (isReadDel)
                    {
                        //添加阅后即焚控件
                        lab_readDeleted.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                        lab_readDeleted.Location = new Point(lab_readDeleted_x, lab_readDeleted_y);
                        this.Controls.Add(lab_readDeleted);
                    }
                }
                else
                {
                    content_x = lab_head_x + lab_head.Width + 10 + align;
                    content_y = 0;
                    lab_msg_x = content_x + content.Width + 5;
                    lab_redPoint_x = content_x + content.Width + 5;
                    lab_redPoint_y = (content.Height - lab_msg.Height) / 2;    //居中
                    //if (lab_redPoint_y < 21)
                    //    lab_redPoint_y = 20;
                    lab_readDeleted_x = content_x + content.Width + 3;
                    lab_readDeleted_y = (content.Height - lab_msg.Height) / 2;    //居中
                }

                //如果显示昵称，则往下挪
                if (lab_name != null && !string.IsNullOrEmpty(lab_name.Text))
                {
                    content_y += lab_name.Height;
                    lab_msg_y += lab_name.Height;
                    lab_redPoint_y += lab_name.Height;
                }

                #region 组合控件
                //单聊中，对方的消息不会有状态
                if (!(messageObject.isGroup == 0 && messageObject.fromUserId != Applicate.MyAccount.userId))
                {
                    lab_msg.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                    lab_msg.Location = new Point(lab_msg_x, lab_msg_y);
                    this.Controls.Add(lab_msg);
                }

                //显示已读标识或者阅后即焚
                if (isReadDel)
                {
                    //添加阅后即焚控件
                    lab_readDeleted.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                    lab_readDeleted.Location = new Point(lab_readDeleted_x, lab_readDeleted_y);
                    this.Controls.Add(lab_readDeleted);
                }
                else
                {
                    if (isShowRedPoint)
                    {
                        //添加红点控件
                        lab_redPoint.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                        lab_redPoint.Location = new Point(lab_redPoint_x, lab_redPoint_y);
                        this.Controls.Add(lab_redPoint);
                    }
                }

                content.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                content.Location = new Point(content_x, content_y);
                this.Controls.Add(content);
                //content.Parent = this;
                lab_head.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                lab_head.Location = new Point(lab_head_x, lab_head_y);
                this.Controls.Add(lab_head);
                this.Size = new Size(content.Width + lab_head.Width + (isReadDel ? lab_readDeleted.Width : lab_msg.Width) + 20, //宽度
                    content.Height + 10 < minHeight ? minHeight : content.Height + 10);     //高度
                //气泡对齐
                this.Width += align;
                //添加昵称
                if (lab_name != null && !string.IsNullOrEmpty(lab_name.Text))
                {
                    lab_name.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                    this.Controls.Add(lab_name);
                    //如果content控件小于最小值，则需要判断是否需要累加群名高度
                    if (content.Height + 10 < minHeight)
                        //1.群名片加上内容超过最小高度  2.不超过
                        this.Height = (content.Height + 10 + lab_name.Height) > minHeight ? (content.Height + 10 + lab_name.Height) : minHeight;
                    else
                        this.Height += lab_name.Height;
                    //防止群员名显示不全
                    if (this.Width < (lab_name.Location.X + lab_name.Width))
                        this.Width = lab_name.Location.X + lab_name.Width;
                }
                #endregion
                //放置到Z轴最前面
                content.BringToFront();
            }
            return this;
        }

        /// <summary>
        /// 重组控件（动态获取子类后，调用内部重写方法后返回）
        /// </summary>
        /// <returns></returns>
        public virtual EQBaseControl GetRecombinedPanel()
        {
            //KWTypeControlsDictionary kWTypeControls = new KWTypeControlsDictionary(messageObject);
            //Control contentControl = kWTypeControls.GetObjectByType().ContentControl();
            Control contentControl = ContentControl();
            if (isRemindMessage)
            {
                this.Size = new Size(contentControl.Width + 10, contentControl.Height + 10);
                //panel.BackColor = bg_color;
                //contentControl.Location = new Point(0, 0);
                this.Controls.Add(contentControl);
                //isRemindMessage = false;
                ParentEvent();
                return this;
            }
            else if (messageObject.type == kWCMessageType.labMoreMsg)
            {
                this.BackColor = Color.Transparent;
                this.Controls.Add(contentControl);
                this.Size = new Size(contentControl.Width, BubbleHeight);
                ParentEvent();
                return this;
            }
            ParentEvent();
            return GetRecombinedPanel(contentControl);
        }
        #endregion

        #region 子控件继承父类方法
        private void ParentEvent()
        {
            foreach (Control item in this.Controls)
            {
                item.MouseDown += (sender, e) => { this.OnMouseDown(e); };
            }
        }
        #endregion
    }
}
