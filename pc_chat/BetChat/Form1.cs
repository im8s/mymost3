using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using TalkBubble;
using Vlc.DotNet.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Dictionarys;
using WinFrmTalk;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    public partial class Form1 : Form
    {
        public int BubbleWidth, BubbleHeight;  //显示气泡的宽度和高度
        string ric_msg = "";            //文本框内容
        private Stopwatch stopWatch = new Stopwatch();  //记录压力测试时间
        private int[] nums = new int[1000];

        int climt, cset_x; //滚动位置最大值和固定的左右的位置
        bool cmouse_Press = false; //鼠标按下
        bool cmouse_Wheel = true; //鼠标滑轮事件
        Point cmouseOff; //存放当前鼠标位置
        EQShowInfoPanelAlpha MultiSelectPanel = new EQShowInfoPanelAlpha();       //透明panel用于捕捉多选点击事件
        static Control selectControl = null;        //contextMenuStrip的右键选中对象
        static Control crl_content = null;         //选中的聊天框内容控件
        static int rowIndex = 0;        //被点击的行
        static bool isOpenCellPaint = false;     //记录是否需要重绘单元格的事件，不作判断滚动界面时不停触发会卡顿

        //获取Configuration对象
        static Configuration config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
        //根据Key读取<add>元素的Value
        string userId = config.AppSettings.Settings["userID"].Value.ToString();
        bool isOneSelf = true;

        public Form1()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon.Handle);//加载icon图标
            btnSend.MouseClick += new MouseEventHandler(BtnSend_MouseClick);
            labSend.MouseClick += new MouseEventHandler(BtnSend_MouseClick);
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            #region 多选绘制底色
            //showInfo_Panel.Paint += (sen, ev) =>
            //{
            //    //重绘结束
            //    if (!isOpenCellPaint)
            //        this.showInfo_Panel.CellPaint -= new TableLayoutCellPaintEventHandler(showInfo_Panel_CellPaint);
            //};
            #endregion

            for (int i = 0; i < 100; i++)
                nums[i] = i + 1;

            //timer1.Enabled = true;
            //showInfo_Panel.AutoSize = true;
            Control.CheckForIllegalCrossThreadCalls = false;

            SetStyle(ControlStyles.DoubleBuffer | ControlStyles.OptimizedDoubleBuffer | ControlStyles.AllPaintingInWmPaint, true);
            UpdateStyles();

            //显示对话内容框鼠标事件
            showInfo_Panel.MouseWheel += new MouseEventHandler(c_OnMouseWheel);
            MultiSelectPanel.MouseWheel += new MouseEventHandler(c_OnMouseWheel);
            //滚动条位置定义
            cset_x = TakeScrollHard_panel.Location.X; //固定左右位置为当前位置
            climt = TakeScrollBar_panel.Height - TakeScrollHard_panel.Height; //滚动最大高度
            TakeScrollHard_panel.Location = new Point(cset_x, 0); //先将位置设置到最顶
        }

        #region 自定义滚动条
        private void cCalc_Scroll()
        {
            if ((showInfo_Panel.Height - Takeconter_panel.Height) <= 0)
            {
                cmouse_Wheel = false;
                showInfo_Panel.Top = 0;
                //MultiSelectPanel.Top = 0;
                TakeScrollHard_panel.Location = new Point(cset_x, 0);
            }
            else
            {
                cmouse_Wheel = true;
            }
        }

        //此鼠标滑轮事件与上面固定高度鼠标滑轮事件不同，容器高度不断变化
        private void c_OnMouseWheel(object sender, MouseEventArgs e)
        {
            int set_y = 0;

            cCalc_Scroll();
            if (cmouse_Wheel) //是否判断鼠标滑轮
            {
                if (e.Delta > 0) //滑轮向上
                {
                    set_y = TakeScrollHard_panel.Location.Y - 5; //每次移动5
                    if (set_y < 0) { set_y = 0; } //超范围
                }
                if (e.Delta < 0)  //滑轮向下
                {
                    set_y = TakeScrollHard_panel.Location.Y + 5; //每次移动5
                    if (set_y > climt) { set_y = climt; } //超范围
                }
                TakeScrollHard_panel.Location = new Point(cset_x, set_y); //滚动块的定位

                int p_set = Convert.ToInt32((Takeconter_panel.Height - showInfo_Panel.Height) * ((decimal)set_y / (decimal)climt));
                if (p_set > 0) p_set = 0;
                showInfo_Panel.Top = p_set;
                //MultiSelectPanel.Top = p_set;
            }
        }

        private void TakeScrollHard_panel_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left) //鼠标左键
            {
                cmouseOff.Y = e.Y;  //取当前位置
                cmouse_Press = true; //鼠标按下
            }
        }

        private void TakeScrollHard_panel_MouseUp(object sender, MouseEventArgs e)
        {
            cmouse_Press = false; //鼠标放开
        }
        private void TakeScrollHard_panel_MouseLeave(object sender, EventArgs e)
        {
            cmouse_Wheel = false; //滑轮不可用
        }

        private void TakeScrollHard_panel_MouseMove(object sender, MouseEventArgs e)
        {
            cCalc_Scroll();
            if (cmouse_Wheel)   //可以用滑轮
            {
                if (cmouse_Press) //鼠标按下状态
                {
                    int set_y = TakeScrollHard_panel.Top + e.Y - cmouseOff.Y; //计算当前纵向坐标
                    if (set_y < 0) { set_y = 0; } //超范围
                    else if (set_y > climt) { set_y = climt; } //超范围
                    else { TakeScrollHard_panel.Location = new Point(cset_x, set_y); } //滚动块的定位

                    int p_set = Convert.ToInt32((Takeconter_panel.Height - showInfo_Panel.Height) * ((decimal)set_y / (decimal)climt));
                    if (p_set > 0) p_set = 0;
                    showInfo_Panel.Top = p_set;
                    //MultiSelectPanel.Top = p_set;
                }
            }
        }


        private void TakeScrollBar_panel_MouseMove(object sender, MouseEventArgs e)
        {
            cCalc_Scroll();  //可以使用滑轮
        }
        

        private void TakeScrollBar_panel_MouseLeave(object sender, EventArgs e)
        {
            cmouse_Wheel = false; //不可使用滑轮
        }

        private void TakeScrollBar_panel_MouseUp(object sender, MouseEventArgs e)
        {
            cCalc_Scroll();
            if (cmouse_Wheel)
            {
                if (e.Button == MouseButtons.Left) //鼠标左键
                {
                    int set_y = e.Y; //当前纵坐标
                    if (set_y > climt) { set_y = climt; } //超范围
                    TakeScrollHard_panel.Location = new Point(cset_x, set_y); //滚动块定位
                    showInfo_Panel.Top = -set_y;//装内容的panel滚动显示
                    //MultiSelectPanel.Top = -set_y;
                    cmouse_Press = false; //鼠标为放开状态

                    int p_set = Convert.ToInt32((Takeconter_panel.Height - showInfo_Panel.Height) * ((decimal)set_y / (decimal)climt));
                    if (p_set > 0) p_set = 0;
                    showInfo_Panel.Top = p_set;
                    //MultiSelectPanel.Top = p_set;
                }
            }
        }
        #endregion

        #region 内存回收
        [DllImport("kernel32.dll", EntryPoint = "SetProcessWorkingSetSize")]
        public static extern int SetProcessWorkingSetSize(IntPtr process, int minSize, int maxSize);
        /// <summary> 
        /// 释放内存
        /// </summary> 
        public static void ClearMemory()
        {
            GC.Collect();
            GC.WaitForPendingFinalizers();
            if (Environment.OSVersion.Platform == PlatformID.Win32NT)
            {
                SetProcessWorkingSetSize(System.Diagnostics.Process.GetCurrentProcess().Handle, -1, -1);
            }
        }
        #endregion

        private void BtnSend_MouseClick(object sender, MouseEventArgs e)
        {
            if (string.IsNullOrEmpty(txtSend.Text))
                return;

            Color b_color = Color.FromArgb(234, 234, 234);
            //处理code变为emoji表情
            string emoji_rtf = GetEmoji(txtSend.Text, b_color);
            //添加对话框
            ric_msg = emoji_rtf;
            RichTextBoxEx richTextBox = GetControl(b_color);

            Calc_PanelWidth(richTextBox);
            richTextBox.BringToFront();
            richTextBox.Size = new Size(BubbleWidth, BubbleHeight);
            richTextBox.Anchor = AnchorStyles.Top | AnchorStyles.Left;
            richTextBox.Location = new Point(10, 10);

            TalkBubblePic talkBubblePic = new TalkBubblePic(1, BubbleWidth, BubbleHeight);

            Image image = talkBubblePic.MakeTalBubble();
            //image.Save("D:\\aaText.png");
            Panel image_panel = new Panel();
            image_panel.Controls.Add(richTextBox);
            image_panel.Location = new Point(this.Width - BubbleWidth - 50, 10);
            image_panel.Anchor = (AnchorStyles.Right);
            image_panel.SuspendLayout();
            image_panel.BackgroundImage = image;
            image_panel.BackgroundImageLayout = ImageLayout.Zoom;
            image_panel.Size = new Size(image.Width, image.Height + 5);
            image_panel.MouseWheel += new MouseEventHandler(c_OnMouseWheel);

            //清除格式并重绘
            //showInfo_Panel.ColumnStyles.Clear();
            //for (int i = 0; i < this.showInfo_Panel.ColumnCount; i++)
            //{
            //    this.showInfo_Panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));
            //}

            //showInfo_Panel.RowStyles.Clear();
            //for (int i = 0; i < showInfo_Panel.RowCount; i++)
            //{
            //    if(i == 0)
            //        this.showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 1));
            //    else
            //    this.showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, image_panel.Height + 5));
            //}

            //新增一行存放控件
            //int rowstyleCount = showInfo_Panel.RowStyles.Count;
            showInfo_Panel.RowStyles[0].Height = 10;
            showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
            showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, image_panel.Height + 5));
            showInfo_Panel.Controls.Add(image_panel, 0, showInfo_Panel.RowCount - 1);
            //talkBubbleControl.ResumeLayout();
            image_panel.ResumeLayout();
        }

        private string GetEmoji(string ric_text, Color bg_cloor)
        {
            RichTextBox richTextBox = new RichTextBox();
            richTextBox.Text = ric_text;
            //匹配符合规则的表情code
            MatchCollection match = Regex.Matches(richTextBox.Text, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            string[] newStr = new string[match.Count];
            //不用做记录的变量
            int index = 0;
            foreach (Match item in match)
            {
                newStr[index] = item.Groups[0].Value;
                index++;
            }

            //循环替换code为表情图片
            for (int i = 0; i < newStr.Length; i++)
            {
                //获取表情code在RichTextBox的位置
                index = richTextBox.Text.IndexOf(newStr[i]);
                //表情code去除[]
                string image_name = newStr[i].Replace("[", "").Replace("]", "");
                //给剪切板设置图片对象
                string path = string.Format(@"Res\Emoji\{0}.png", image_name);
                if (!File.Exists(path))
                    break;

                //获取RichTextBox控件中鼠标焦点的索引位置
                richTextBox.SelectionStart = index;
                //从鼠标焦点处开始选中几个字符
                richTextBox.SelectionLength = newStr[i].Length;
                //清空剪切板，防止里面之前有内容
                Clipboard.Clear();
                Bitmap bmp = new Bitmap(path);
                Bitmap newBmp = new Bitmap(25, 25);
                Graphics g = Graphics.FromImage(newBmp);
                g.Clear(bg_cloor);

                g.InterpolationMode = InterpolationMode.HighQualityBicubic;

                g.DrawImage(bmp, new Rectangle(0, 0, 25, 25), new Rectangle(0, 0, bmp.Width, bmp.Height), GraphicsUnit.Pixel);
                g.Dispose();
                Clipboard.SetImage(newBmp);
                //将图片粘贴到鼠标焦点位置(选中的字符都会被图片覆盖)
                richTextBox.Paste();
                Clipboard.Clear();
            }

            return richTextBox.Rtf;
        }

        //调整窗口大小
        private void Form1_Resize(object sender, EventArgs e)
        {
            //if(showInfo_Panel.Controls.Count > 0)
            //{
            //    foreach(Control control in showInfo_Panel.Controls)
            //    {
            //        if (string.Equals(control.GetType().Name, "Panel"))
            //        {
            //            ((Panel)control).AutoSize = false;
            //            control.Size = new Size(showInfo_Panel.Width - 10, control.Height);
            //        }
            //    }
            //}
        }


        #region 计算绘图尺寸
        /// <summary>
        /// 计算显示框高度和宽度，英文字体和中文以及标点、数字的宽度各不相同，需计算
        /// </summary>
        /// <param name="control">气泡内的控件</param>
        public void Calc_PanelWidth(Control control)
        {
            if (!string.Equals(control.GetType().Name, "RichTextBoxEx"))
                return;
            //临时建立一个容器装入内容
            RichTextBox canv_Rich = control as RichTextBox;
            //先取全部Rtf的值
            //canv_Rich.Rtf = mess;
            //再按照Txt判断文字
            //判断中文
            MatchCollection zh = Regex.Matches(canv_Rich.Text, @"[\u4e00-\u9fa5]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            //判断中文标点
            MatchCollection zhdot = Regex.Matches(canv_Rich.Text, @"[，。；？~！：‘“”’【】（）]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            //判断数字
            MatchCollection num = Regex.Matches(canv_Rich.Text, @"[1234567890]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            //其余为英文，并计算总宽度
            BubbleWidth = ((zh.Count + zhdot.Count) * 13) + (num.Count * 6) + (num.Count > 0 ? 10 : 0) + ((canv_Rich.Text.Length - zh.Count - zhdot.Count - num.Count) * 8);
            //接收数据内容中是否包含图像
            int indexPic = -1;
            indexPic = IndexOfEx(canv_Rich.Rtf, @"{\pict\");
            //判断emoji表情个数
            int emoji = IndexOfEx(canv_Rich.Rtf, @"\picw661\pich661\");
            //判断换行，默认含一行
            int newLine = IndexOfEx(canv_Rich.Rtf, "\\par\r\n");
            //自动换行数
            int autoLine = Convert.ToInt32(Math.Ceiling((double)BubbleWidth / (40 * 13))) - 1;
            //加上图像宽度
            BubbleWidth += (indexPic - emoji) * 55 + emoji * 25;
            //判断极值
            if (BubbleWidth > (40 * 13)) { BubbleWidth = 40 * 13; }
            if (BubbleWidth < 40) { BubbleWidth += 10; }
            //if (indexPic > 0) { BubbleHeight = 33; }
            //else { BubbleHeight = 25; }
            //计算高度
            BubbleHeight = (newLine + autoLine) * 23 + (indexPic - emoji) * 100 + emoji * 5;
        }
        #endregion

        /// <summary>
        /// 关键词在字符串的出现次数
        /// </summary>
        /// <param name="value">需要检索的字符串</param>
        /// <param name="keyword">关键词</param>
        /// <returns></returns>
        private int IndexOfEx(string value, string keyword)
        {
            //如果是图片，要对长宽进行处理

            int count = 0;
            if (!string.IsNullOrEmpty(value) && !string.IsNullOrEmpty(keyword))
                count = (value.Length - value.Replace(keyword, "").Length) / keyword.Length;
            return count;
        }

        public RichTextBoxEx GetControl(Color backColor)
        {
            RichTextBoxEx txtRichBox = new RichTextBoxEx(ric_msg);
            txtRichBox.WordWrap = true;
            txtRichBox.ReadOnly = true;
            txtRichBox.BackColor = backColor;
            txtRichBox.Location = new Point(15, 15);
            //txtRichBox.Dock = DockStyle.Fill;
            txtRichBox.BorderStyle = BorderStyle.None;
            txtRichBox.ScrollBars = RichTextBoxScrollBars.None;
            //txtRichBox.SelectionAlignment = HorizontalAlignment.Right;
            return txtRichBox;
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            //int CntControls = this.Controls.Count;
            //for (int i = 0; i < CntControls; i++)
            //{
            //    //if(this.Controls[0].Name)
            //    if (this.Controls[0] != null)
            //        Controls[0].Dispose();
            //}

            showInfo_Panel = (TableLayoutPanel)DisponseEx(showInfo_Panel);
            showInfo_Panel.RowStyles.Clear();
            showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 10));
            showInfo_Panel.Top = 0;
            showInfo_Panel.Height = 100;
            ClearMemory();
        }

        private Control DisponseEx(Control parContainer)
        {
            int count = parContainer.Controls.Count;
            for (int index = 0; index < count; index++)
            {
                // 如果是容器内部控件，则递归调用自己
                if (parContainer.Controls[0].HasChildren)
                {
                    DisponseEx(parContainer.Controls[0]);
                }
                parContainer.Controls[0].Dispose();
            }
            return parContainer;
        }

        private void btnSendTest_Click(object sender, EventArgs e)
        {
            //序列化和反序列化
            //MessageHandle messageHandel = new MessageHandle();
            //MessageObject messageModel = messageHandel.GetMessageRedBarJson();

            //isOneSelf = string.Equals(messageModel.fromUserId, userId);     //判断是否为本人发送的消息

            //KWTypeControlsDictionary kWTypeControls = new KWTypeControlsDictionary(messageModel);
            //EQBaseControl eqBase = kWTypeControls.GetObjectByType();
            //Panel talk_panel = eqBase.GetRecombinedPanel();
            ////talk_panel.Location = new Point(Message_panel.Width - talk_panel.Width - 10, 0);
            //if (isOneSelf)
            //    talk_panel.Anchor = (AnchorStyles.Right | AnchorStyles.Top);
            //else
            //    talk_panel.Anchor = (AnchorStyles.Left | AnchorStyles.Top);

            //if (showInfo_Panel.RowCount == 1)
            //{
            //    showInfo_Panel.RowStyles.Clear();
            //    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 10));
            //    //showInfo_Panel.RowStyles[0].Height = 10;
            //}

            ////添加发送时间
            //if (true)
            //{
            //    //Label lab_sendTime = eqBase.DrawSendTime(Convert.ToDateTime("1998-02-02"));
            //    Label lab_sendTime = eqBase.DrawSendTime(DateTime.Now);
            //    if (lab_sendTime != null)
            //    {
            //        showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
            //        showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, lab_sendTime.Height + 5));
            //        //lab_sendTime.Location = new Point(showInfo_Panel.Width - lab_sendTime.Width + 2, 3);
            //        lab_sendTime.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right;
            //        showInfo_Panel.Controls.Add(lab_sendTime, 0, showInfo_Panel.RowCount - 1);
            //    }
            //}

            ////多选复选框
            //LollipopCheckBox materialCheckBox = new LollipopCheckBox();
            //materialCheckBox.Text = "";
            //materialCheckBox.Size = new Size(20, 20);
            //materialCheckBox.Visible = false;

            ////添加聊天气泡
            //showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
            //showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, talk_panel.Height + 5));
            //showInfo_Panel.Controls.Add(materialCheckBox, 0, showInfo_Panel.RowCount - 1);
            //showInfo_Panel.Controls.Add(talk_panel, 1, showInfo_Panel.RowCount - 1);
            //talk_panel.Name = "talk_panel_" + showInfo_Panel.RowCount;

            ////添加到字典中储存
            //Dictionary<string, MessageObject> messageModelData = MessageObjectDataDictionary.GetMessageModelDataDictionary();
            //messageModel.rowIndex = showInfo_Panel.RowCount;
            //messageModelData.Add(messageModel.messageId, messageModel);
        }

        private void btnSendImage_Click(object sender, EventArgs e)
        {
            //序列化和反序列化
            //MessageHandle messageHandel = new MessageHandle();
            //string strJson = messageHandel.GetMessageImageJson();
            //MessageModel messageModel = messageHandel.GetMessageModel(strJson);
            //isOneSelf = string.Equals(messageModel.FromUserId, userId);

            //KWTypeControlsDictionary kWTypeControls = new KWTypeControlsDictionary(strJson);
            //EQBaseControl eqBase = kWTypeControls.GetObjectByType();
            //Panel talk_panel = eqBase.GetRecombinedPanel();
            ////talk_panel.Location = new Point(Message_panel.Width - talk_panel.Width - 10, 0);
            //if (isOneSelf)
            //    talk_panel.Anchor = (AnchorStyles.Right | AnchorStyles.Top);
            //else
            //    talk_panel.Anchor = (AnchorStyles.Left | AnchorStyles.Top);

            //if (showInfo_Panel.RowCount == 1)
            //{
            //    showInfo_Panel.RowStyles.Clear();
            //    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 10));
            //    //showInfo_Panel.RowStyles[0].Height = 10;
            //}

            //showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
            //showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, talk_panel.Height + 5));
            //showInfo_Panel.Controls.Add(talk_panel, 0, showInfo_Panel.RowCount - 1);
            //talk_panel.Name = "talk_panel_" + showInfo_Panel.RowCount;
        }

        private void btnGif_Click(object sender, EventArgs e)
        {
            string path = string.Format(@"Res\Gif\five.gif");
            if (!File.Exists(path))
                return;
            Panel panel = new Panel();
            panel.Size = new Size(90, 90);
            Bitmap animatedGif = new Bitmap(path);
            Graphics g = panel.CreateGraphics();
            // A Gif image's frame delays are contained in a byte array
            // in the image's PropertyTagFrameDelay Property Item's
            // value property.
            // Retrieve the byte array...
            int PropertyTagFrameDelay = 0x5100;
            PropertyItem propItem = animatedGif.GetPropertyItem(PropertyTagFrameDelay);
            byte[] bytes = propItem.Value;
            // Get the frame count for the Gif...
            FrameDimension frameDimension = new FrameDimension(animatedGif.FrameDimensionsList[0]);
            int frameCount = animatedGif.GetFrameCount(FrameDimension.Time);
            // Create an array of integers to contain the delays,
            // in hundredths of a second, between each frame in the Gif image.
            int[] delays = new int[frameCount + 1];
            int i = 0;
            for (i = 0; i <= frameCount - 1; i++)
            {
                delays[i] = BitConverter.ToInt32(bytes, i * 4);
            }

            for (i = 0; i <= animatedGif.GetFrameCount(frameDimension) - 1; i++)
            {
                animatedGif.SelectActiveFrame(frameDimension, i);
                g.DrawImage(animatedGif, new Point(0, 0));
                Application.DoEvents();
                Thread.Sleep(delays[i] * 10);
            }

            showInfo_Panel.RowStyles[0].Height = 10;
            showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
            showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, panel.Height + 5));
            showInfo_Panel.Controls.Add(panel, 0, showInfo_Panel.RowCount - 1);
        }

        #region 批量测试
        private void button1_Click(object sender, EventArgs e)
        {


            //Thread thread = new Thread(new ThreadStart(Thread1));
            //thread.Start();

            Task task = new Task(() =>
            {
                Thread1();
            });
            task.Start();

            //ClearMemory();
        }

        private void Thread1()
        {
            stopWatch.Restart();
            //Action action1 = () =>
            //{
            this.TakeScrollBar_panel.SuspendLayout();
            this.TakeScrollHard_panel.SuspendLayout();
            this.showInfo_Panel.SuspendLayout();
            this.SuspendLayout();

            int count = 0;
            while (count < 100)
            {
                //if (string.IsNullOrEmpty(txtSend.Text))
                //    return;
                count++;

                Action action = () =>
                {
                    #region aa
                    ////添加对话框
                    //ric_msg = txtSend.Rtf;
                    //Color b_color = Color.FromArgb(234, 234, 234);
                    //RichTextBoxEx richTextBox = GetControl(b_color);

                    //Calc_PanelWidth(richTextBox);
                    //richTextBox.BringToFront();
                    //richTextBox.Size = new Size(BubbleWidth, BubbleHeight);
                    //richTextBox.Anchor = AnchorStyles.Top | AnchorStyles.Left;
                    //richTextBox.Location = new Point(10, 10);

                    //TalkBubblePic talkBubblePic = new TalkBubblePic(0, BubbleWidth, BubbleHeight);

                    //Image image = talkBubblePic.MakeTalBubble();
                    ////image.Save("D:\\aaText.png");
                    //Panel image_panel = new Panel();
                    //image_panel.Controls.Add(richTextBox);
                    //image_panel.Location = new Point(this.Width - BubbleWidth - 50, 10);
                    //image_panel.Anchor = (AnchorStyles.Right);
                    //image_panel.SuspendLayout();
                    //image_panel.BackgroundImage = image;
                    //image_panel.BackgroundImageLayout = ImageLayout.Zoom;
                    //image_panel.Size = new Size(image.Width, image.Height + 5);


                    ////if(count == 1)
                    ////    showInfo_Panel.Controls.Clear();

                    ////showInfo_Panel.ColumnStyles.Clear();
                    ////for (int i = 0; i < this.showInfo_Panel.ColumnCount; i++)
                    ////{
                    ////    this.showInfo_Panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));
                    ////}

                    ////showInfo_Panel.RowStyles.Clear();
                    ////for (int i = 0; i < showInfo_Panel.RowCount; i++)
                    ////{
                    ////    this.showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, image_panel.Height + 5));
                    ////}

                    ////新增一行存放控件
                    ////int rowstyleCount = showInfo_Panel.RowStyles.Count;
                    //showInfo_Panel.RowStyles[0].Height = 10;
                    //showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
                    //showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, image_panel.Height + 5));
                    //showInfo_Panel.Controls.Add(image_panel, 0, showInfo_Panel.RowCount - 1);
                    ////talkBubbleControl.ResumeLayout();
                    //image_panel.ResumeLayout();
                    #endregion

                    //序列化和反序列化
                    MessageHandle messageHandel = new MessageHandle();
                    string strJson = new MessageHandle().GetMessageImageJson();
                    //MessageModel messageModel = messageHandel.GetMessageModel(strJson);

                    KWTypeControlsDictionary kWTypeControls = new KWTypeControlsDictionary(strJson);
                    EQBaseControl eqBase = kWTypeControls.GetObjectByType();
                    Panel talk_panel = eqBase.GetRecombinedPanel();
                    talk_panel.Name = "talk_panel_" + showInfo_Panel.RowCount;
                    //talk_panel.Location = new Point(Message_panel.Width - talk_panel.Width - 10, 0);
                    talk_panel.Anchor = (AnchorStyles.Right | AnchorStyles.Top);

                    if (showInfo_Panel.RowCount == 1)
                    {
                        showInfo_Panel.RowStyles.Clear();
                        showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 10));
                        //showInfo_Panel.RowStyles[0].Height = 10;
                    }

                    showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
                    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, talk_panel.Height + 5));
                    showInfo_Panel.Controls.Add(talk_panel, 0, showInfo_Panel.RowCount - 1);
                };
                Invoke(action);
                //showInfo_Panel.RowStyles[rowstyleCount].Height = talkPanel.Height;
            }
            this.TakeScrollBar_panel.ResumeLayout(true);
            this.TakeScrollHard_panel.ResumeLayout(true);
            this.showInfo_Panel.ResumeLayout(true);
            this.ResumeLayout(true);
            //};
            //Parallel.Invoke(action1);
            stopWatch.Stop();
            txtSend.Text = "Run " + stopWatch.ElapsedMilliseconds + " ms.";
        }
        #endregion

        private void menuItem_Delete_Click(object sender, EventArgs e)
        {
            //EQMenuStripControl.menuItem_Delete_Click(this.showInfo_Panel, rowIndex);
        }

        private void menuItem_Copy_Click(object sender, EventArgs e)
        {
            string content_type = "";
            if (string.Equals(crl_content.Name, "crl_content"))
            {
                content_type = crl_content.GetType().Name;
                switch (content_type)
                {
                    case "PictureBox":
                        //清空剪切板，防止里面之前有内容
                        Clipboard.Clear();
                        //给剪切板设置图片对象
                        PictureBox picBox = crl_content as PictureBox;
                        Image image = picBox.BackgroundImage;
                        //Bitmap bitmap = new Bitmap(image);
                        Clipboard.SetImage(image);
                        break;
                    case "RichTextBox":
                        //清空剪切板，防止里面之前有内容
                        Clipboard.Clear();
                        //给剪切板设置图片对象
                        RichTextBox richTextBox = crl_content as RichTextBox;
                        string content = richTextBox.Text;
                        Clipboard.SetText(content);
                        break;
                }
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
            showInfo_Panel.RowStyles.Insert(0, new RowStyle(SizeType.Absolute, 50));
            //Panel panel = new Panel();
            //panel.BackColor = Color.Blue;
            //panel.Size = new Size(200, 100);
            //showInfo_Panel.Controls.Add(panel, 0, 0);
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            // 返回与指定虚拟路径相对应的物理路径即绝对路径
            string filePath = Environment.CurrentDirectory + @"\Voice\";
            DirectoryInfo folder = new DirectoryInfo(filePath);
            //获取文件夹下所有的文件
            //FileInfo[] fileList = folder.GetFiles();
            //foreach (FileInfo file in fileList)
            //{
            //    ////判断文件的扩展名是否为 .gif
            //    //if (file.Extension == ".gif")
            //    //{
            //    file.Delete();  // 删除
            //    //}
            //}
        }

        private void menuItem_Recall_Click(object sender, EventArgs e)
        {
            //EQMenuStripControl.menuItem_Recall_Click(this.showInfo_Panel, rowIndex);
        }

        private void MultiSelectPanel_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                //计算当前点击的showInfo_panel的y坐标（相对本身为参照物，而不是窗体）
                float showInfo_panel_y = showInfo_Panel.Top >= 0 ? showInfo_Panel.Top : -showInfo_Panel.Top;
                float sum_height = 0;
                rowIndex = 0;
                //计算点击的坐标是第几行
                while (true)
                {
                    sum_height += showInfo_Panel.RowStyles[rowIndex].Height;
                    if (sum_height > (e.Y + showInfo_panel_y))
                        break;
                    rowIndex++;
                }

                //判断该行是否有复选框
                if (showInfo_Panel.GetControlFromPosition(0, rowIndex) == null)
                    return;
                if (!string.Equals(showInfo_Panel.GetControlFromPosition(0, rowIndex).GetType().Name, "MaterialCheckBox"))
                    return;

                //点击修改选中状态
                bool box_checked = ((LollipopCheckBox)showInfo_Panel.GetControlFromPosition(0, rowIndex)).Checked;
                ((LollipopCheckBox)showInfo_Panel.GetControlFromPosition(0, rowIndex)).Checked = box_checked == true ? false : true;

                #region 修改底色
                //isOpenCellPaint = true;     //需要重绘事件给单元格勾选改行后更换底色
                //if (isOpenCellPaint)
                //    this.showInfo_Panel.CellPaint += new TableLayoutCellPaintEventHandler(showInfo_Panel_CellPaint);

                ////触发重绘，修改底色
                ////showInfo_Panel.RowStyles[rowIndex].Height = showInfo_Panel.RowStyles[rowIndex].Height;
                //((MaterialCheckBox)showInfo_Panel.GetControlFromPosition(0, rowIndex)).Visible = false;
                //((MaterialCheckBox)showInfo_Panel.GetControlFromPosition(0, rowIndex)).Visible = true;
                //isOpenCellPaint = false;
                #endregion
            }
        }

        private void menuItem_MultiSelect_Click(object sender, EventArgs e)
        {
            showInfo_Panel.ColumnStyles[0].Width = 40;
            for (int index = 0; index < showInfo_Panel.Controls.Count; index++)
            {
                string type = showInfo_Panel.Controls[index].GetType().Name;
                if (string.Equals(type, "MaterialCheckBox"))
                    showInfo_Panel.Controls[index].Visible = true;
            }

            //设置透明panel用于捕捉多选点击事件的点击行
            MultiSelectPanel.Size = new Size(Takeconter_panel.Width - TakeScrollBar_panel.Width, showInfo_Panel.Height);
            MultiSelectPanel.MouseDown += MultiSelectPanel_MouseDown;
            Takeconter_panel.Controls.Add(MultiSelectPanel);
            MultiSelectPanel.BringToFront();
        }

        private void showInfo_Panel_CellPaint(object sender, TableLayoutCellPaintEventArgs e)
        {
            //点击的行非该重绘的行
            //if (rowIndex != e.Row)
            //    return;
            //判断该行是否有复选框
            if (showInfo_Panel.GetControlFromPosition(0, e.Row) == null)
                return;
            if (!string.Equals(showInfo_Panel.GetControlFromPosition(0, e.Row).GetType().Name, "MaterialCheckBox"))
                return;

            //该行的复选框勾选状态为true时才修改底色
            bool box_checked = ((LollipopCheckBox)showInfo_Panel.GetControlFromPosition(0, e.Row)).Checked;     //点击修改选中状态
            if (box_checked)
            {
                Graphics g = e.Graphics;
                Rectangle r = e.CellBounds;
                g.FillRectangle(Brushes.LightGray, r);
            }
            else
            {
                Graphics g = e.Graphics;
                Rectangle r = e.CellBounds;
                g.FillRectangle(Brushes.Transparent, r);
            }
        }

        private void button4_Click(object sender, EventArgs e)
        {
            //序列化和反序列化
            MessageHandle messageHandel = new MessageHandle();
            string strJson = messageHandel.GetMessageVoiceJson();
            MessageModel messageModel = messageHandel.GetMessageModel(strJson);

            isOneSelf = string.Equals(messageModel.FromUserId, userId);     //判断是否为本人发送的消息

            KWTypeControlsDictionary kWTypeControls = new KWTypeControlsDictionary(strJson);
            EQBaseControl eqBase = kWTypeControls.GetObjectByType();
            Panel talk_panel = eqBase.GetRecombinedPanel();
            //talk_panel.Location = new Point(Message_panel.Width - talk_panel.Width - 10, 0);
            if (isOneSelf)
                talk_panel.Anchor = (AnchorStyles.Right | AnchorStyles.Top);
            else
                talk_panel.Anchor = (AnchorStyles.Left | AnchorStyles.Top);

            if (showInfo_Panel.RowCount == 1)
            {
                showInfo_Panel.RowStyles.Clear();
                showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 10));
                //showInfo_Panel.RowStyles[0].Height = 10;
            }

            //添加发送时间
            if (true)
            {
                //Label lab_sendTime = eqBase.DrawSendTime(Convert.ToDateTime("1998-02-02"));
                Label lab_sendTime = eqBase.DrawSendTime(DateTime.Now);
                if (lab_sendTime != null)
                {
                    showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
                    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, lab_sendTime.Height + 5));
                    //lab_sendTime.Location = new Point(showInfo_Panel.Width - lab_sendTime.Width + 2, 3);
                    lab_sendTime.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right;
                    showInfo_Panel.Controls.Add(lab_sendTime, 0, showInfo_Panel.RowCount - 1);
                }
            }

            //多选复选框
            LollipopCheckBox materialCheckBox = new LollipopCheckBox();
            materialCheckBox.Text = "";
            materialCheckBox.Size = new Size(20, 20);
            materialCheckBox.Visible = false;

            //添加聊天气泡
            showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
            showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, talk_panel.Height + 5));
            showInfo_Panel.Controls.Add(materialCheckBox, 0, showInfo_Panel.RowCount - 1);
            showInfo_Panel.Controls.Add(talk_panel, 1, showInfo_Panel.RowCount - 1);
            talk_panel.Name = "talk_panel_" + showInfo_Panel.RowCount;

            //添加到字典中储存
            Dictionary<int, MessageModel> messageModelData = MessageModelDataDictionary.GetMessageModelDataDictionary();
            messageModelData.Add(showInfo_Panel.RowCount - 1, messageModel);
        }

        private void button5_Click(object sender, EventArgs e)
        {
            //序列化和反序列化
            MessageHandle messageHandel = new MessageHandle();
            string strJson = messageHandel.GetMessageImageJson();
            MessageModel messageModel = messageHandel.GetMessageModel(strJson);

            isOneSelf = string.Equals(messageModel.FromUserId, userId);     //判断是否为本人发送的消息

            KWTypeControlsDictionary kWTypeControls = new KWTypeControlsDictionary(strJson);
            EQBaseControl eqBase = kWTypeControls.GetObjectByType();
            Panel talk_panel = eqBase.GetRecombinedPanel();
            //talk_panel.Location = new Point(Message_panel.Width - talk_panel.Width - 10, 0);
            if (isOneSelf)
                talk_panel.Anchor = (AnchorStyles.Right | AnchorStyles.Top);
            else
                talk_panel.Anchor = (AnchorStyles.Left | AnchorStyles.Top);

            if (showInfo_Panel.RowCount == 1)
            {
                showInfo_Panel.RowStyles.Clear();
                showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 10));
                //showInfo_Panel.RowStyles[0].Height = 10;
            }

            //添加发送时间
            if (true)
            {
                //Label lab_sendTime = eqBase.DrawSendTime(Convert.ToDateTime("1998-02-02"));
                Label lab_sendTime = eqBase.DrawSendTime(DateTime.Now);
                if (lab_sendTime != null)
                {
                    showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
                    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, lab_sendTime.Height + 5));
                    //lab_sendTime.Location = new Point(showInfo_Panel.Width - lab_sendTime.Width + 2, 3);
                    lab_sendTime.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right;
                    showInfo_Panel.Controls.Add(lab_sendTime, 0, showInfo_Panel.RowCount - 1);
                }
            }

            //多选复选框
            LollipopCheckBox materialCheckBox = new LollipopCheckBox();
            materialCheckBox.Text = "";
            materialCheckBox.Size = new Size(20, 20);
            materialCheckBox.Visible = false;

            //添加聊天气泡
            showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
            showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, talk_panel.Height + 5));
            showInfo_Panel.Controls.Add(materialCheckBox, 0, showInfo_Panel.RowCount - 1);
            showInfo_Panel.Controls.Add(talk_panel, 1, showInfo_Panel.RowCount - 1);
            talk_panel.Name = "talk_panel_" + showInfo_Panel.RowCount;

            //添加到字典中储存
            Dictionary<int, MessageModel> messageModelData = MessageModelDataDictionary.GetMessageModelDataDictionary();
            messageModelData.Add(showInfo_Panel.RowCount - 1, messageModel);
        }

        private void button6_Click(object sender, EventArgs e)
        {
            //序列化和反序列化
            MessageHandle messageHandel = new MessageHandle();
            string strJson = messageHandel.GetMessageCardJson();
            MessageModel messageModel = messageHandel.GetMessageModel(strJson);

            isOneSelf = string.Equals(messageModel.FromUserId, userId);     //判断是否为本人发送的消息

            KWTypeControlsDictionary kWTypeControls = new KWTypeControlsDictionary(strJson);
            EQBaseControl eqBase = kWTypeControls.GetObjectByType();
            Panel talk_panel = eqBase.GetRecombinedPanel();
            //talk_panel.Location = new Point(Message_panel.Width - talk_panel.Width - 10, 0);
            if (isOneSelf)
                talk_panel.Anchor = (AnchorStyles.Right | AnchorStyles.Top);
            else
                talk_panel.Anchor = (AnchorStyles.Left | AnchorStyles.Top);

            if (showInfo_Panel.RowCount == 1)
            {
                showInfo_Panel.RowStyles.Clear();
                showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 10));
                //showInfo_Panel.RowStyles[0].Height = 10;
            }

            //添加发送时间
            if (true)
            {
                //Label lab_sendTime = eqBase.DrawSendTime(Convert.ToDateTime("1998-02-02"));
                Label lab_sendTime = eqBase.DrawSendTime(DateTime.Now);
                if (lab_sendTime != null)
                {
                    showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
                    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, lab_sendTime.Height + 5));
                    //lab_sendTime.Location = new Point(showInfo_Panel.Width - lab_sendTime.Width + 2, 3);
                    lab_sendTime.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right;
                    showInfo_Panel.Controls.Add(lab_sendTime, 0, showInfo_Panel.RowCount - 1);
                }
            }

            //多选复选框
            LollipopCheckBox materialCheckBox = new LollipopCheckBox();
            materialCheckBox.Text = "";
            materialCheckBox.Size = new Size(20, 20);
            materialCheckBox.Visible = false;

            //添加聊天气泡
            showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
            showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, talk_panel.Height + 5));
            showInfo_Panel.Controls.Add(materialCheckBox, 0, showInfo_Panel.RowCount - 1);
            showInfo_Panel.Controls.Add(talk_panel, 1, showInfo_Panel.RowCount - 1);
            talk_panel.Name = "talk_panel_" + showInfo_Panel.RowCount;

            //添加到字典中储存
            Dictionary<int, MessageModel> messageModelData = MessageModelDataDictionary.GetMessageModelDataDictionary();
            messageModelData.Add(showInfo_Panel.RowCount - 1, messageModel);
        }

        private void menuItem_Collect_Click(object sender, EventArgs e)
        {

        }

        private void showInfo_Panel_ControlAdded(object sender, ControlEventArgs e)
        {
            //设置滚动条是否可见
            if (showInfo_Panel.Height - Takeconter_panel.Height > 0)
            {
                TakeScrollBar_panel.Visible = true;
                TakeScrollHard_panel.Visible = true;
            }

            //不是添加聊天气泡的直接跳出
            if (!string.Equals(e.Control.GetType().Name, "Panel"))
                return;
            foreach (Control item in e.Control.Controls)
            {
                switch (item.Name)
                {
                    case "lab_msg": break;
                    case "lab_hand": break;
                    case "image_panel":
                        //item.MouseDown += Content_MouseDown;
                        foreach (Control crl in item.Controls)
                        {
                            if (string.Equals(crl.Name, "crl_content"))
                            {
                                crl.MouseDown += Content_MouseDown;
                                //crl.ContextMenuStrip = contentMenuStrip;
                            }
                        }
                        break;
                    case "crl_content":
                        item.MouseDown += Content_MouseDown;
                        //item.ContextMenuStrip = contentMenuStrip;
                        break;
                    default:
                        break;

                }
            }
        }

        //不同的控件鼠标点击事件也不同
        private void Content_MouseDown(object sender, MouseEventArgs e)
        {
            crl_content = sender as Control;
            string crl_type = crl_content.GetType().Name;

            if (e.Button == MouseButtons.Right)
            {
                //记录被选中的控件
                selectControl = crl_content.Parent;
                while (true)
                {
                    if (selectControl.Name.IndexOf("talk_panel") > -1)
                        break;
                    else
                        selectControl = selectControl.Parent;
                }
                rowIndex = showInfo_Panel.GetRow(selectControl);    //记录被选中行

                Dictionary<int, MessageModel> messageModelData = MessageModelDataDictionary.GetMessageModelDataDictionary();
                //获取菜单
                //switch (messageModelData[rowIndex].Type.ToString())
                //{
                //    case "Image":
                //        new MessageHandle().MenuItemVisible(ref contentMenuStrip, kWCMessageType.Image);
                //        break;
                //    case "Text":
                //        new MessageHandle().MenuItemVisible(ref contentMenuStrip, kWCMessageType.Text);
                //        break;
                //    case "Voice":

                //    //Remind类型没有右键菜单
                //    default:
                //        //设置全部为不可见
                //        foreach (ToolStripItem item in contentMenuStrip.Items)
                //            item.Visible = false;
                //        break;
                //}
                //设置可见度
                new KWTypeMenuStripDictionary().SettingMenuStripVisible(ref contentMenuStrip, messageModelData[rowIndex].Type);
                contentMenuStrip.RightToLeft = RightToLeft.No;
            }
        }
    }
}
