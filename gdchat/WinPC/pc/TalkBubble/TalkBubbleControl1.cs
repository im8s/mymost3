using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Drawing.Drawing2D;
using System.Text.RegularExpressions;
using System.IO;
using System.Threading;

namespace TalkBubble
{
    public partial class TalkBubbleControl1: UserControl
    {
        //Control control = new Control();
        Panel Bubble_panel = new Panel();

        int user_order = 0;             //0为本人，1则非本人
        public int BubbleWidth, BubbleHeight;  //显示气泡的宽度和高度

        /// <summary>
        /// 初始化自定义控件
        /// </summary>
        /// <param name="user_order">0为本人，1则非本人</param>
        /// <param name="rtf">RichTextBox的RTF，不需要传空值便可</param>
        public TalkBubbleControl1(int user_order, int width, int height)
        {
            InitializeComponent();
            CheckForIllegalCrossThreadCalls = false;

            this.user_order = user_order;
            this.BubbleWidth = width;
            this.BubbleHeight = height;

            MakeTalBubble();

            Bubble_panel.Cursor = Cursors.Default;
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

        //生成对话气泡
        private void MakeTalBubble()
        {
            Panel conter_panel = new Panel();
            //气泡底色
            Color b_color = new Color();

            if (user_order == 0)
            {
                //control = GetControl(b_color);
                //Bubble_panel.Controls.Add(control);
                //Calc_PanelWidth(control);

                Bubble_panel.BackColor = b_color;
                Bubble_panel.Width = BubbleWidth;
                Bubble_panel.Height = BubbleHeight;
                Bubble_panel.Anchor = AnchorStyles.Top | AnchorStyles.Right;
                Bubble_panel.Location = new Point(10, 10);

                //使用线程进行绘图
                //Thread thread = new Thread(new ThreadStart(delegate
                //{
                    b_color = Color.FromArgb(234, 234, 234);
                    conter_panel.Cursor = Cursors.Default;
                    conter_panel.BackColor = b_color;
                    conter_panel.Width = BubbleWidth + 25;
                    conter_panel.Height = BubbleHeight + 10;
                    conter_panel.Location = new Point(5, 5);
                    conter_panel.SendToBack();
                    Bitmap localBitmap = new Bitmap(conter_panel.Width, conter_panel.Height);
                    Graphics bitmapGraphics = Graphics.FromImage(localBitmap);
                    bitmapGraphics.Clear(BackColor);
                    bitmapGraphics.SmoothingMode = SmoothingMode.AntiAlias;

                    Draw(conter_panel.ClientRectangle, bitmapGraphics, 18, true, 0, b_color, b_color);
                    conter_panel.BackgroundImage = localBitmap;
                    Action action = () =>
                    {
                        conter_panel.Controls.Add(Bubble_panel);
                    };
                    if (this.IsHandleCreated)
                    {
                        Invoke(action);
                    }
                //}));
                //thread.Start();

                this.Controls.Add(conter_panel);
            }
            else
            {
                b_color = Color.FromArgb(128, 203, 196);

                //Control control = GetControl(b_color);
                //Bubble_panel.Controls.Add(control);
                //Calc_PanelWidth(control);

                Bubble_panel.BackColor = b_color;
                Bubble_panel.Width = BubbleWidth;
                Bubble_panel.Height = BubbleHeight;
                Bubble_panel.Location = new Point(20, 10);

                conter_panel.BackColor = b_color;
                conter_panel.Width = BubbleWidth + 35;
                conter_panel.Height = BubbleHeight + 10;
                conter_panel.Location = new Point(5, 5);
                Bitmap localBitmap = new Bitmap(conter_panel.Width, conter_panel.Height);
                Graphics bitmapGraphics = Graphics.FromImage(localBitmap);
                bitmapGraphics.Clear(BackColor);
                bitmapGraphics.SmoothingMode = SmoothingMode.AntiAlias;
                Draw(conter_panel.ClientRectangle, bitmapGraphics, 18, true, 1, b_color, b_color);
                conter_panel.BackgroundImage = localBitmap;
                conter_panel.Controls.Add(Bubble_panel);

                this.Controls.Add(conter_panel);
            }
            //显示在最顶层
            //conter_panel.BringToFront();
            this.Size = new System.Drawing.Size(BubbleWidth + 34, BubbleHeight + 20);
        }

        



        //给RichTextBox添加图片
        private void AddPicToRich(RichTextBox richTextBox)
        {
            //if (richTextBox.ReadOnly)
            //    richTextBox.ReadOnly = false;
            ////清空剪切板，防止里面之前有内容
            //Clipboard.Clear();
            ////给剪切板设置图片对象
            //Bitmap bmp = new Bitmap(@"C:\Users\10976\Pictures\222.png");
            //Size size = new Size(30, 30);
            //bmp = new Bitmap(bmp, size);
            //Clipboard.SetImage(bmp);
            ////将图片粘贴到鼠标焦点位置(由于有选中2个字符，所以那2个字符会被图片覆盖)
            //richTextBox.Paste();
            //Clipboard.Clear();
        }

        private void TalkBubbleControl1_MouseMove(object sender, MouseEventArgs e)
        {
            int count = this.Controls.Count;
            for (int i = 0; i < count; i++)
            {
                if (this.Controls[0] != null)
                    this.Controls[0].Cursor = Cursors.Default;
            }
        }
        
    }
}
