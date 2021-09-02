using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.View
{
    public partial class FrmMaxLookImage : FrmBase
    {
        public FrmMaxLookImage()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
        }
        #region 全局变量
        public string FileName { get; private set; }
        public string Url;
        public Point mousePoint = new Point();
        private bool isMove = false;
        private int zoomStep = 50;
        #endregion
        public void Pictbix_Image(string image_path)
        {
            Url = image_path;
            FileName = FileUtils.GetFileName(image_path);
            // 从内存加载
            Bitmap bitmap = ImageCacheManager.Instance.GetCacheImage(image_path);
            if (bitmap != null)
            {
                pictureBox1.Image = bitmap;
                return;
            }
            // 从本地加载
            string filePath = Applicate.LocalConfigData.ImageFolderPath + FileName;
            bitmap = FileUtils.FileToBitmap(filePath);
            if (bitmap != null)
            {
                pictureBox1.Image = bitmap;
                return;
            }
            //等待符
            LodingUtils loding = new LodingUtils();
            loding.parent = pictureBox1;
            loding.size = pictureBox1.Size;
            loding.start();
            ImageLoader.Instance.Load(image_path).Into((img, str) =>
            {
                ResumeLayout();
                pictureBox1.Image = img;
                loding.stop();
            });


        }
        private void FrmMaxLookImage_Load(object sender, EventArgs e)
        {
            pictureBox1.BackgroundImageLayout = ImageLayout.Zoom;
            pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
             this.WindowState = FormWindowState.Maximized;
            pictureBox1.MouseWheel += new MouseEventHandler(picxbox_MouseWheel);
            pictureBox1.Location = new Point((panel1.Width - pictureBox1.Width) / 2, (panel1.Height - pictureBox1.Height) / 2);
            this.ControlBox = false;
        }

        private void picxbox_MouseWheel(object sender, MouseEventArgs e)
        {
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
                //缩放比例
                pictureBox1.Width += zoomStep;
                pictureBox1.Height += zoomStep;
                //去除黑色背景
                PropertyInfo pInfo = pictureBox1.GetType().GetProperty("ImageRectangle", BindingFlags.Instance |
                 BindingFlags.NonPublic);
                Rectangle rect = (Rectangle)pInfo.GetValue(pictureBox1, null);
                pictureBox1.Width = rect.Width;
                pictureBox1.Height = rect.Height;
            }
            if (e.Delta < 0)
            {
                if (pictureBox1.Width < 150 || pictureBox1.Height < 150)
                {
                    return;
                }
                pictureBox1.Width -= zoomStep;
                pictureBox1.Height -= zoomStep;
                PropertyInfo pInfo = pictureBox1.GetType().GetProperty("ImageRectangle", BindingFlags.Instance |
                 BindingFlags.NonPublic);
                Rectangle rect = (Rectangle)pInfo.GetValue(pictureBox1, null);
                pictureBox1.Width = rect.Width;
                pictureBox1.Height = rect.Height;
            }
            //移动的位移
            vx = (int)((double)x * (ow - pictureBox1.Width) / ow);
            vy = (int)((double)y * (oh - pictureBox1.Height) / oh);
            pictureBox1.Location = new Point(pictureBox1.Location.X + vx, pictureBox1.Location.Y + vy);
        }

        private void FrmMaxLookImage_KeyDown(object sender, KeyEventArgs e)
        {

        }
        private void FrmMaxLookImage_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)27)
            {
                this.Close();
            }
        }
        #region 鼠标滚轮实现放大与缩小

        #endregion
        //按下
        private void pictureBox1_MouseDown(object sender, MouseEventArgs e)
        {
            pictureBox1.Focus();
            if (e.Button == MouseButtons.Left)
            {
                //记录当前位置
                mousePoint.X = Cursor.Position.X;
                mousePoint.Y = Cursor.Position.Y;
                isMove = true;
                pictureBox1.Focus();
            }
        }
        //移动
        private void pictureBox1_MouseMove(object sender, MouseEventArgs e)
        {
            if (isMove)
            {
                int x, y;
                int movex, movey;
                //移动距离
                movex = Cursor.Position.X - mousePoint.X;
                movey = Cursor.Position.Y - mousePoint.Y;
                x = pictureBox1.Location.X + movex;
                y = pictureBox1.Location.Y + movey;
                pictureBox1.Location = new Point(x, y);
                //记录当前位置
                mousePoint.X = Cursor.Position.X;
                mousePoint.Y = Cursor.Position.Y;
            }
        }

        private void panel1_MouseDown(object sender, MouseEventArgs e)
        {
            panel1.Focus();
            if (e.Button == MouseButtons.Left)
            {
                //记录当前位置
                mousePoint.X = Cursor.Position.X;
                mousePoint.Y = Cursor.Position.Y;
                isMove = true;

            }
        }

        private void panel1_MouseMove(object sender, MouseEventArgs e)
        {
            panel1.Focus();
            if (isMove)
            {
                int x, y;
                int movex, movey;
                //移动距离
                movex = Cursor.Position.X - mousePoint.X;
                movey = Cursor.Position.Y - mousePoint.Y;
                x = pictureBox1.Location.X + movex;
                y = pictureBox1.Location.Y + movey;
                pictureBox1.Location = new Point(x, y);
                //记录当前位置
                mousePoint.X = Cursor.Position.X;
                mousePoint.Y = Cursor.Position.Y;
            }
        }

        private void pictureBox1_MouseUp(object sender, MouseEventArgs e)
        {
            isMove = false;
            Cursor = Cursors.Default;
        }

        private void panel1_MouseUp(object sender, MouseEventArgs e)
        {
            isMove = false;
            Cursor = Cursors.Default;
        }

        private void pictureBox1_MouseLeave(object sender, EventArgs e)
        {
            isMove = false;
            Cursor = Cursors.Default;
        }

        private void pictureBox1_MouseEnter(object sender, EventArgs e)
        {

            Cursor = Cursors.SizeAll;
            pictureBox1.MouseWheel += new MouseEventHandler(picxbox_MouseWheel);
        }
    }
}
