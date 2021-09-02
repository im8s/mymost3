using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;
using WinFrmTalk.Model.DrawModel;

namespace WinFrmTalk.View
{
    public partial class FrmEditImage : FrmBase
    {
        #region 全局变量
        //BufferedGraphics graphBuffer;
        private const double zoomStep = 1.2;//放大倍数
        OperateObject LastOperate = new OperateObject();    //最近的一条绘图记录
        List<OperateObject> OperateList = new List<OperateObject>();
        Point mouseDownPoint = new Point(); //记录拖拽过程鼠标位置
        bool isMove = false;    //判断鼠标在picturebox上移动时，是否处于拖拽过程(鼠标左键是否按下)
        bool isDraw = false;    //判断鼠标是否在点击绘画之后，点击（左键）图片
        private DrawStyle drawStyle = DrawStyle.None;    //绘制的类型
        private List<Point> _linePointList;     //绘制画笔过程中记录的坐标点
        ImageCroppingBox imageCroppingBox = null;
        Point EndPoint = new Point(0, 0);
        Size minSize = new Size();
        //定义全局变量接收传递过来的数据
        public Image Image { get; set; }
        public string filePath { get; set; }
        public Action<Image> action_ok = null;
        private List<Point> LinePointList
        {
            get
            {
                if (_linePointList == null)
                {
                    _linePointList = new List<Point>(100);
                }
                return _linePointList;
            }
        }
        #endregion

        public FrmEditImage()
        {
            InitializeComponent();

            //双重缓冲
            //DoubleBuffered = true;
            //SetStyle(ControlStyles.OptimizedDoubleBuffer |
            //    ControlStyles.ResizeRedraw |
            //    ControlStyles.AllPaintingInWmPaint, true);

        }

        private void FrmEditImage_Load(object sender, EventArgs e)
        {
            pictureBox1.MouseWheel += new MouseEventHandler(pictureBox1_MouseWheel);
            pictureBox1.SizeMode = PictureBoxSizeMode.AutoSize;
            //Rectangle rec = new Rectangle(150, 150, 200, 200);
            //Image =MaSaiKeGraphics(Image, 8, rec);
            pictureBox1.Image = Image;
            //如果大图片则需要变化窗口的大小
            if(Image.Width > pictureBox1.Width || Image.Height > pictureBox1.Height)
            {
                int dw = Image.Width - panel1.Width;
                int dh = Image.Height - panel1.Height;
                this.Size = new Size(this.Width + dw, this.Height + dh);
                int new_width = Image.Width > this.MinimumSize.Width ? Image.Width : this.MinimumSize.Width;
                int new_height = Image.Height > (this.MinimumSize.Height - panel1.Location.Y) ? Image.Height : (this.MinimumSize.Height - panel1.Location.Y);
                panel1.Size = new Size(new_width, new_height);
                pictureBox1.Size = Image.Size;
            }

            //去除黑色背景
            RemoveBlackBg();
            minSize = pictureBox1.Size;

            //graphBuffer = (new BufferedGraphicsContext()).Allocate(pictureBox1.CreateGraphics(), pictureBox1.DisplayRectangle);
        }

        #region 工具栏
        private void PobxMagnify_Click(object sender, EventArgs e)
        {
            if (((MouseEventArgs)e).Button != MouseButtons.Left)
                return;

            //超过最大缩放比例
            if (Math.Ceiling((double)pictureBox1.Width / 395) >= 20)
                return;

            pictureBox1.Size = new Size(pictureBox1.Width + 150, pictureBox1.Height + 150);
            pictureBox1.Location = new Point((panel1.Width - pictureBox1.Width) / 2, (panel1.Height - pictureBox1.Height) / 2);
        }

        private void PboxShrink_Click(object sender, EventArgs e)
        {
            if (((MouseEventArgs)e).Button != MouseButtons.Left)
                return;
            // 缩小到最小值
            if (pictureBox1.Width <= minSize.Width || pictureBox1.Height <= minSize.Height)
            {
                return;
            }
            pictureBox1.Size = new Size(pictureBox1.Width - 150, pictureBox1.Height - 150);
            pictureBox1.Location = new Point((panel1.Width - pictureBox1.Width) / 2, (panel1.Height - pictureBox1.Height) / 2);
        }

        private void PboxEllipse_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (drawStyle != DrawStyle.Ellipse)
                {
                    drawStyle = DrawStyle.Ellipse;
                    //pboxEllipse.BorderStyle = BorderStyle.FixedSingle;
                }
                else
                {
                    drawStyle = DrawStyle.None;
                    //pboxEllipse.BorderStyle = BorderStyle.None;
                }
            }
        }

        private void PboxRectangle_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (drawStyle != DrawStyle.Rectangle)
                {
                    drawStyle = DrawStyle.Rectangle;
                }
                else
                {
                    drawStyle = DrawStyle.None;
                }
            }
        }

        private void PboxArrows_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (drawStyle != DrawStyle.Arrow)
                {
                    drawStyle = DrawStyle.Arrow;
                }
                else
                {
                    drawStyle = DrawStyle.None;
                }
            }
        }

        private void PboxPen_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (drawStyle != DrawStyle.Line)
                    drawStyle = DrawStyle.Line;
                else
                    drawStyle = DrawStyle.None;
            }
        }

        private void PboxMosaic_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (drawStyle != DrawStyle.Mosaic)
                    drawStyle = DrawStyle.Mosaic;
                else
                    drawStyle = DrawStyle.None;
            }
        }

        private void PboxText_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (drawStyle != DrawStyle.Text)
                    drawStyle = DrawStyle.Text;
                else
                    drawStyle = DrawStyle.Text;
            }
        }

        private void PboxTailor_MouseClick(object sender, MouseEventArgs e)
        {
            //记录操作的类型
            drawStyle = DrawStyle.Tailor;

            //调整pictureBox
            pictureBox1.Visible = false;
            pictureBox1.Size = pictureBox1.Image.Size;

            imageCroppingBox = new ImageCroppingBox();
            imageCroppingBox.Image = pictureBox1.Image;
            imageCroppingBox.Size = Image.Size;
            imageCroppingBox.Location = pictureBox1.Location;
            imageCroppingBox.SelectedRectangle = pictureBox1.ClientRectangle;
           panel1.Controls.Add(imageCroppingBox);
            imageCroppingBox.BringToFront();
           
        }

        private void PboxWithdraw_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            //移除最后一次的绘画记录
            if (OperateList.Count > 0)
            {
                bool isTailor = OperateList[OperateList.Count - 1].OperateType == OperateType.Tailor;
                OperateList.RemoveAt(OperateList.Count - 1);
                pictureBox1.Controls.Clear();
                Bitmap bmp = new Bitmap(this.Image, pictureBox1.Width, pictureBox1.Height);
                using (Graphics g = Graphics.FromImage(bmp))
                {
                    g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    g.SmoothingMode = SmoothingMode.HighQuality;
                    g.CompositingQuality = CompositingQuality.HighQuality;
                    g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                    //重新绘画一遍
                    foreach (var item in OperateList)
                    {
                        if (item.OperateType == OperateType.Tailor)
                        {
                            //isHave_tailor = true;
                            g.DrawImage(bmp,
                                new Rectangle(Point.Empty, bmp.Size),
                                (Rectangle)item.Data,
                                GraphicsUnit.Pixel);
                        }
                        else
                            DrawOperate(item, bmp, g);
                    }
                }
                if(isTailor)
                    pictureBox1.Size = bmp.Size;
                pictureBox1.Image = bmp;
                pictureBox1.Invalidate();
            }
        }

        private void PboxRelay_MouseClick(object sender, MouseEventArgs e)
        {
            FrmFriendSelect frmFriendSelect = new FrmFriendSelect();
            frmFriendSelect.LoadFriendsData(1);
            frmFriendSelect.AddConfrmListener((UserFriends) =>
            {
                filePath = Applicate.LocalConfigData.ImageFolderPath + Guid.NewGuid().ToString("N") + ".png";
                pictureBox1.Image.MySave(filePath, ImageFormat.Png);
                //上传图片
                UploadEngine.Instance.From(filePath).
                    //上传完成
                    UploadFile((success, url) =>
                    {
                        if (success)
                        {
                            int fileSize = Convert.ToInt32(new FileInfo(filePath).Length);
                            foreach (Friend fd in UserFriends.Values)
                                ShiKuManager.SendImageMessage(fd, url, filePath, fileSize);
                        }
                    });
            });
        }

        private void PboxSave_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            //选择文件夹路径
            FolderBrowserDialog dialog = new FolderBrowserDialog
            {
                Description = "保存图片.."
            };
            if (dialog.ShowDialog() == DialogResult.OK)
            {
                //文件的本地路径
                string localPath = dialog.SelectedPath;
                filePath = localPath + "\\" + Guid.NewGuid().ToString("N") + ".png";
                pictureBox1.Image.MySave(filePath, ImageFormat.Png);
            }
        }

        private void PboxCancel_MouseClick(object sender, MouseEventArgs e)
        {
            if (drawStyle == DrawStyle.Tailor)
            {
                panel1.Controls.Remove(imageCroppingBox);
                imageCroppingBox = new ImageCroppingBox();
                pictureBox1.Visible = true;
                drawStyle = DrawStyle.None;
            }
            else
            {
                this.Close();
                this.Dispose();
            }
        }

        private void PboxOK_MouseClick(object sender, MouseEventArgs e)
        {
            if (drawStyle == DrawStyle.Tailor)
            {
                Rectangle rec = new Rectangle();
                Image image = imageCroppingBox.GetSelectedImage(ref rec);
                pictureBox1.Size = image.Size;
                minSize = pictureBox1.Size;
                pictureBox1.Image = image;
                panel1.Controls.Remove(imageCroppingBox);
                imageCroppingBox = new ImageCroppingBox();
                pictureBox1.Visible = true;

                //添加绘画记录
                LastOperate = new OperateObject(OperateType.Tailor, Color.Red, rec, 2);
                OperateList.Add(LastOperate);
                drawStyle = DrawStyle.None;
            }
            else
            {
                filePath = Applicate.LocalConfigData.ImageFolderPath + Guid.NewGuid().ToString("N") + ".png";
                pictureBox1.Image.MySave(filePath, ImageFormat.Png);
                action_ok?.Invoke(pictureBox1.Image);
                this.Close();
                this.Dispose();
            }
        }
        #endregion

        #region 鼠标事件
        //鼠标滚轮
        private void pictureBox1_MouseWheel(object sender, MouseEventArgs e)
        {
            //取消绘制
            drawStyle = DrawStyle.None;
            LastOperate = new OperateObject(OperateType.None, Color.Red, null);

            Cursor = Cursors.SizeAll;//设置鼠标光标
            int x = e.Location.X;
            int y = e.Location.Y;
            //图片宽度与高度
            int ow = pictureBox1.Width;
            int oh = pictureBox1.Height;
            int vx, vy;
            //放大
            if (e.Delta > 0)
            {
                //超过最大缩放比例
                if (Math.Ceiling((double)pictureBox1.Width / 395) >= 20)
                    return;
                //缩放比例
                //pictureBox1.Width = (int)(pictureBox1.Width * zoomStep);
                //pictureBox1.Height = (int)(pictureBox1.Height * zoomStep);
                pictureBox1.Size = new Size((int)Math.Ceiling(pictureBox1.Width * zoomStep), (int)Math.Ceiling(pictureBox1.Height * zoomStep));
                //去除黑色背景
                RemoveBlackBg();
            }
            if (e.Delta < 0)
            {
                // 缩小到最小值
                if (pictureBox1.Width <= minSize.Width || pictureBox1.Height <= minSize.Height)
                {
                    return;
                }
                //pictureBox1.Width = (int)(pictureBox1.Width / zoomStep);
                //pictureBox1.Height = (int)(pictureBox1.Height / zoomStep);
                pictureBox1.Size = new Size((int)Math.Ceiling(pictureBox1.Width / zoomStep), (int)Math.Ceiling(pictureBox1.Height / zoomStep));
                //去除黑色背景
                RemoveBlackBg();
            }
            //移动的位移
            vx = (int)((double)x * (ow - pictureBox1.Width) / ow);
            vy = (int)((double)y * (oh - pictureBox1.Height) / oh);
            pictureBox1.Location = new Point(pictureBox1.Location.X + vx, pictureBox1.Location.Y + vy);
        }

        //图片按下
        private void pictureBox1_MouseDown(object sender, MouseEventArgs e)
        {
            pictureBox1.Focus();
            if (e.Button == MouseButtons.Left)
            {
                if (drawStyle != DrawStyle.None)
                {
                    isDraw = true;
                    mouseDownPoint = e.Location;
                    EndPoint = e.Location;

                    //添加绘画记录
                    OperateType operateType = OperateObject.DrawStyleToOperateType(drawStyle);
                    if (drawStyle == DrawStyle.Mosaic)
                        LastOperate = new OperateObject(operateType, Color.Red, null, 25);
                    else
                        LastOperate = new OperateObject(operateType, Color.Red, null, 2);
                    OperateList.Add(LastOperate);
                }
                else
                {
                    //鼠标当前位置
                    mouseDownPoint.X = Cursor.Position.X;
                    mouseDownPoint.Y = Cursor.Position.Y;
                    isMove = true;
                    pictureBox1.Focus();
                }
            }
        }
        private void pictureBox1_MouseUp(object sender, MouseEventArgs e)
        {
            isMove = false;
            Cursor = Cursors.Default;
            if (isDraw)
            {
                //原图是当前控件的多少倍
                double times = pictureBox1.Image.Width / (double)pictureBox1.Width;
                //获取最后一条绘画记录
                if (OperateList.Count < 1)
                    return;

                OperateObject operate = OperateList[OperateList.Count - 1];
                Bitmap bmp = new Bitmap(pictureBox1.Image, pictureBox1.Width, pictureBox1.Height);
                Graphics g = Graphics.FromImage(bmp);
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.SmoothingMode = SmoothingMode.HighQuality;
                g.CompositingQuality = CompositingQuality.HighQuality;
                g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                switch (drawStyle)
                {
                    case DrawStyle.Ellipse:
                    case DrawStyle.Rectangle:
                        EndPoint = e.Location;
                        operate.Data = MakeRectangle(mouseDownPoint, EndPoint);
                        break;
                    case DrawStyle.Arrow:
                        operate.Data = new Point[] { mouseDownPoint, e.Location };
                        break;
                    case DrawStyle.Line:
                        LinePointList.Add(e.Location);
                        if (LinePointList.Count < 2)
                            return;
                        operate.Data = LinePointList.ToArray();
                        LinePointList.Clear();
                        break;
                    case DrawStyle.Text:
                        operate.Data = new DrawText()
                        {
                            Location = e.Location
                        };
                        break;
                    case DrawStyle.Mosaic:
                        LinePointList.Add(e.Location);
                        if (LinePointList.Count < 2)
                            return;
                        operate.Data = LinePointList.ToArray();
                        LinePointList.Clear();
                        break;
                }
                DrawOperate(operate, bmp, g);
                if (drawStyle != DrawStyle.Text)
                    g.Dispose();
                pictureBox1.Image = bmp;
                pictureBox1.Invalidate();
                //Console.WriteLine(operate.Data);
                isDraw = false;
            }
            //drawStyle = DrawStyle.None;
        }

        //移动
        private void pictureBox1_MouseMove(object sender, MouseEventArgs e)
        {
            if (isMove)
            {
                int x, y;
                int moveX, moveY;
                //计算移动距离
                moveX = Cursor.Position.X - mouseDownPoint.X;
                moveY = Cursor.Position.Y - mouseDownPoint.Y;
                x = pictureBox1.Location.X + moveX;
                y = pictureBox1.Location.Y + moveY;
                pictureBox1.Location = new Point(x, y);
                mouseDownPoint.X = Cursor.Position.X;
                mouseDownPoint.Y = Cursor.Position.Y;

            }
            if (isDraw)
            {
                //获取最后一条绘画记录
                if (OperateList.Count < 1 || LastOperate.OperateType == OperateType.None || LastOperate.OperateType == OperateType.DrawText)
                    return;
                // 初始化画板，在内存中建立一块虚拟画布
                Bitmap bmp = new Bitmap(pictureBox1.Image, pictureBox1.ClientSize.Width, pictureBox1.ClientSize.Height);
                //Point clear_startPoint = new Point(mouseDownPoint.X - 10, mouseDownPoint.Y - 10);
                //Rectangle rec = MakeRectangle(clear_startPoint, EndPoint);    //计算重画区域
                //rec.Height += 20;
                //rec.Width += 20;                //区域增大些
                pictureBox1.Invalidate();       //擦除上次鼠标移动时画的图形，r1为擦除区域
                pictureBox1.Update();           //立即重画，即擦除
                using (Graphics g = Graphics.FromImage(bmp))
                //using (Graphics g = pictureBox1.CreateGraphics())
                {
                    g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    g.SmoothingMode = SmoothingMode.HighQuality;
                    g.CompositingQuality = CompositingQuality.HighQuality;
                    g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                    switch (drawStyle)
                    {
                        case DrawStyle.Line:
                            LinePointList.Add(e.Location);
                            if (LinePointList.Count < 2)
                                return;
                            LastOperate.Data = LinePointList.ToArray();
                            break;
                        case DrawStyle.Mosaic:
                            LinePointList.Add(e.Location);
                            if (LinePointList.Count < 2)
                                return;
                            LastOperate.Data = LinePointList.ToArray();
                            break;
                        case DrawStyle.Ellipse:
                        case DrawStyle.Rectangle:
                            //计算椭圆新位置
                            EndPoint = e.Location;
                            LastOperate.Data = MakeRectangle(mouseDownPoint, EndPoint);
                            break;
                        case DrawStyle.Arrow:
                            EndPoint = e.Location;
                            LastOperate.Data = new Point[] { mouseDownPoint, EndPoint };
                            break;
                    }
                    DrawOperate(LastOperate, bmp, g);
                    if (drawStyle != DrawStyle.Text)
                        g.Dispose();
                    pictureBox1.CreateGraphics().DrawImage(bmp, new Rectangle(0, 0, pictureBox1.ClientSize.Width, pictureBox1.ClientSize.Height));
                    //Graphics diaplayGraphic = this.graphBuffer.Graphics;
                    ////diaplayGraphic.Clear(pictureBox1.BackColor);
                    //diaplayGraphic.DrawImage(bmp, new Rectangle(0, 0, pictureBox1.ClientSize.Width, pictureBox1.ClientSize.Height));
                    //this.graphBuffer.Render();
                }
            }
        }

        private void pictureBox1_MouseLeave(object sender, EventArgs e)
        {
            pictureBox1.MouseWheel += null;
            isMove = false;
            Cursor = Cursors.Default;
        }

        private void panel1_MouseMove(object sender, MouseEventArgs e)
        {
            panel1.Focus(); //鼠标不在picturebox上时焦点给别的控件，此时无法缩放   
            if (isMove)
            {
                int x, y;   //新的 pictureBox1.Location(x,y)
                int moveX, moveY; //X方向，Y方向移动大小。
                moveX = Cursor.Position.X - mouseDownPoint.X;
                moveY = Cursor.Position.Y - mouseDownPoint.Y;
                x = pictureBox1.Location.X + moveX;
                y = pictureBox1.Location.Y + moveY;
                pictureBox1.Location = new Point(x, y);
                mouseDownPoint.X = Cursor.Position.X;
                mouseDownPoint.Y = Cursor.Position.Y;
            }
        }

        private void panel1_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                //鼠标当前位置
                mouseDownPoint.X = Cursor.Position.X;
                mouseDownPoint.Y = Cursor.Position.Y;
                isMove = true;
                pictureBox1.Focus();
            }
        }

        private void panel1_MouseUp(object sender, MouseEventArgs e)
        {
            isMove = false;
            Cursor = Cursors.Default;
        }
        #endregion
        
        private static Rectangle ImageBoundsToRect(Rectangle bounds)
        {
            Rectangle rect = bounds;
            int x = 0;
            int y = 0;

            x = Math.Min(rect.X, rect.Right);
            y = Math.Min(rect.Y, rect.Bottom);

            rect.X = x;
            rect.Y = y;
            rect.Width = Math.Max(1, Math.Abs(rect.Width));
            rect.Height = Math.Max(1, Math.Abs(rect.Height));
            return rect;
        }

        private void PictureBox1_SizeChanged(object sender, EventArgs e)
        {
            //pictureBox1.Image = EQControlManager.ModifyBitmapSize(new Bitmap(pictureBox1.Image), pictureBox1.Width, pictureBox1.Height);
            //Bitmap image = new Bitmap(pictureBox1.Image, pictureBox1.Size);
            //pictureBox1.Image = image;
            //调整位置
            int location_x = panel1.Width <= pictureBox1.Width ? 0 : (((double)panel1.Width - pictureBox1.Width) / 2).GetCeiling();
            int location_y = panel1.Height <= pictureBox1.Height ? 0 : (((double)panel1.Height - pictureBox1.Height) / 2).GetCeiling();
            pictureBox1.Location = new Point(location_x, location_y);
            Console.WriteLine(pictureBox1.Image.Size);
        }

        private Rectangle MakeRectangle(Point p1, Point p2)
        {
            int top, left, bottom, right;
            top = p1.Y <= p2.Y ? p1.Y : p2.Y;//计算矩形左上角点的y坐标
            left = p1.X <= p2.X ? p1.X : p2.X;//计算矩形左上角点的x坐标
            bottom = p1.Y > p2.Y ? p1.Y : p2.Y;//计算矩形右下角点的y坐标
            right = p1.X > p2.X ? p1.X : p2.X;//计算矩形右下角点的x坐标
            return (new Rectangle(left, top, right - left, bottom - top));//返回矩形
        }

        private void RemoveBlackBg()
        {
            PropertyInfo pInfo = pictureBox1.GetType().GetProperty("ImageRectangle", BindingFlags.Instance |
                    BindingFlags.NonPublic);
            Rectangle rect = (Rectangle)pInfo.GetValue(pictureBox1, null);
            //pictureBox1.Width = rect.Width;
            //pictureBox1.Height = rect.Height;
            pictureBox1.Size = new Size(rect.Width, rect.Height);
        }

        private void DrawOperate(OperateObject operate, Bitmap bmp, Graphics g)
        {
            Pen pen = new Pen(operate.Color, operate.Width);
            OperateType operateType = operate.OperateType;
            switch (operateType)
            {
                case OperateType.DrawArrow:
                    Point[] points = operate.Data as Point[];
                    pen.EndCap = LineCap.ArrowAnchor;
                    pen.EndCap = LineCap.Custom;
                    pen.CustomEndCap = new AdjustableArrowCap(8, 8, true);
                    g.DrawLine(pen, points[0], points[1]);
                    break;
                case OperateType.DrawEllipse:
                    g.DrawEllipse(pen, (Rectangle)operate.Data);
                    break;
                case OperateType.DrawRectangle:
                    g.DrawRectangle(pen, (Rectangle)operate.Data);
                    break;
                case OperateType.DrawLine:
                    g.DrawLines(pen, operate.Data as Point[]);
                    break;
                case OperateType.DrawText:
                    AddTextByPanel(operate, bmp, g);
                    break;
                case OperateType.DrawMosaic:
                    TextureBrush mosaic_brush = new TextureBrush(new Bitmap(System.Environment.CurrentDirectory + @"\Resource\mosaic.png"));    //(纹理刷)
                    Pen mosaic_pen = new Pen(mosaic_brush, operate.Width);
                    g.DrawLines(mosaic_pen, operate.Data as Point[]);      
                    break;
            }
        }

        private void FrmEditImage_SizeChanged(object sender, EventArgs e)
        {
            panel2.Top = 30;
        }

        private void AddTextByPanel(OperateObject operate, Bitmap bmp, Graphics g)
        {
            DrawText drawText = (DrawText)operate.Data;
            string content = drawText.Content;
            int pan_width = pictureBox1.Width - drawText.Location.X;
            int pan_height = pictureBox1.Height - drawText.Location.Y;
            int maxHeight = pictureBox1.Height - drawText.Location.Y;   //panel的最大高度
            Point point = drawText.Location;
            //如果content不为空，则代表室重绘（撤销操作）
            if (!string.IsNullOrEmpty(content))
            {
                //绘制文本到图片上
                g.DrawString(content, Applicate.myFont, new SolidBrush(Color.Red), point);
            }
            else
            {
                PanelEx panel = new PanelEx()
                {
                    Width = pan_width,
                    Height = pan_height,
                    BorderColor = Color.Red,
                    BorderSize = 1,
                    Location = new Point(point.X - 5, point.Y - 5),
                    BackColor = Color.Transparent,
                    Parent = pictureBox1,
                    MaximumSize = new Size(pan_width, maxHeight)
                };
                //int maxWidth = panel.Width - 10 > 0 ? panel.Width - 10 : panel.Width;   //label的最大宽度（控制自动换行）
                //Label lblText = DrawLblText(maxWidth, panel);
                ////如果content不为空，则代表室重绘（撤销操作）
                //if (!string.IsNullOrEmpty(content))
                //{
                //    lblText.Text = content;
                //}
                ////鼠标点击新建的，内容肯定为null
                //else if(drawText.LabText == null)
                //{
                //    GetTxtTheDrawText(operate, panel.Size, g);
                //    txtDrawText.Parent = panel;
                //    operate.Data = new DrawText() { LabText = lblText, Location = point };
                //}
                GetTxtTheDrawText(operate, panel.Size, bmp, g);
                txtDrawText.Parent = panel;
                pictureBox1.Controls.Add(panel);
                if (txtDrawText != null && !txtDrawText.IsDisposed)
                    txtDrawText.Focus();
            }
        }

        private TransTextBox txtDrawText = null;
        private void GetTxtTheDrawText(OperateObject operate, Size size, Bitmap bmp, Graphics g)
        {
                int width = size.Width - 10 > 0 ? size.Width - 10 : size.Width;
                int height = size.Height - 10 > 0 ? size.Height - 10 : size.Height;
                txtDrawText = new TransTextBox()
                {
                    Name = "txtText",
                    BorderStyle = BorderStyle.None,
                    Font = Applicate.myFont,
                    ForeColor = Color.Red,
                    ImeMode = ImeMode.On,
                    Location = new Point(5, 5),
                    Multiline = true,
                    Size = new Size(width, height)
                };
            //失去焦点,结束文本编辑
            txtDrawText.LostFocus += (sender, e) =>
            {
                //获取到相同父容器中的textBox
                if (txtDrawText.Parent is Panel panel)
                {
                    //if (string.IsNullOrEmpty(txtDrawText.Text))
                    //{
                    //    pictureBox1.Controls.Remove(panel);
                    //    return;
                    //}
                    //var crl = panel.Controls["lblText"];
                    //if (crl is Label lblText)
                    //{
                    //    lblText.Visible = true;
                    //    lblText.Text = txtDrawText.Text;
                    //}
                    //txtDrawText.Clear();
                    //panel.Controls.Remove(txtDrawText);
                    string content = txtDrawText.Text;
                    if (!string.IsNullOrEmpty(content))
                    {
                        DrawText drawText = (DrawText)operate.Data;
                        drawText.Content = content;
                        //Rectangle rec = new Rectangle(new Point(drawText.Location.X + 5, drawText.Location.Y + 5), txtDrawText.ClientRectangle.Size);
                        Rectangle rec = new Rectangle(drawText.Location, txtDrawText.ClientRectangle.Size);
                        //绘制文本到图片上
                        g.DrawString(content, Applicate.myFont, new SolidBrush(Color.Red), rec);
                        pictureBox1.Image = bmp;
                        pictureBox1.Invalidate();
                    }
                    else
                        OperateList.Remove(operate);
                    //g.Dispose();
                    txtDrawText.Clear();
                    panel.Controls.Remove(txtDrawText);
                    pictureBox1.Controls.Remove(panel);
                }
                g.Dispose();
            };
        }

        private Label DrawLblText(int maxWidth, Panel panel)
        {
            var result = panel.Controls["lblText"];
            if (result != null && result is Label label)
                return label;
            else
            {
                Label lblText = new Label()
                {
                    Name = "lblText",
                    AutoSize = true,
                    BackColor = Color.Transparent,
                    ForeColor = Color.Red,
                    Location = new Point(5, 5),
                    //Text = content,
                    Parent = panel,
                    MaximumSize = new Size(maxWidth, 0)
                };
                lblText.DoubleClick += (sender, e) =>
                {
                    txtDrawText.Text = lblText.Text;
                    txtDrawText.Parent = lblText.Parent;
                    txtDrawText.Focus();
                    lblText.Visible = false;
                    BringToFront();
                };
                lblText.SizeChanged += (sender, e) =>
                {
                    //if (lblText.Height > panel.Height)
                    //    panel.Height = lblText.Height;
                    panel.Size = new Size(lblText.Size.Width + 10, lblText.Size.Height + 10);
                };
                return lblText;
            }
        }
    }
}
