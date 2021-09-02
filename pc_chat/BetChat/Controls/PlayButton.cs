using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Drawing2D;

namespace WinFrmTalk.Controls
{
    public partial class PlayButton : UserControl
    {
        public PlayButton()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
        }
        private bool IsAdd = true;  //表示增亮或者减暗
        private int EllipseSize = 40;   //发光区域
        private int StartColorA = 0;    //透明度
        private bool isActive = true;
        /// <summary>
        /// 是否激活发光
        /// </summary>
        public bool IsActive
        {
            get { return isActive; }
            set { isActive = value; }
        }
        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            EllipseSize = this.Width;
            Graphics g = e.Graphics;
            g.SmoothingMode = SmoothingMode.HighQuality;

            //画外圆
            g.FillEllipse(new SolidBrush(Color.White), this.Width / 2 - 4, this.Height / 2 - 4, 8, 8);
            g.FillEllipse(new SolidBrush(Color.Gray), (float)(this.Width / 2 - 2), (float)(this.Height / 2 - 2), 4, 4);
            GraphicsPath path = new GraphicsPath();
            path.AddEllipse(this.Width / 2 - EllipseSize / 2, this.Height / 2 - EllipseSize / 2, EllipseSize, EllipseSize);
            PathGradientBrush pthGrBrush = new PathGradientBrush(path);
            pthGrBrush.SetSigmaBellShape(1, 1);
            pthGrBrush.CenterColor = Color.FromArgb(StartColorA, 255, 255, 255);
            Color[] colorsTwo = { Color.FromArgb(0, 255, 255, 255) };
            pthGrBrush.SurroundColors = colorsTwo;
            g.FillEllipse(pthGrBrush, this.Width / 2 - EllipseSize / 2, this.Height / 2 - EllipseSize / 2, EllipseSize, EllipseSize);
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (!isActive)
            {
                this.Invalidate();
                return;
            }
            if (IsAdd)
            {
                StartColorA += 10;
            }
            else
            {
                StartColorA -= 10;
            }
            if (StartColorA >= 255) { IsAdd = false; StartColorA = 255; }
            else if (StartColorA <= 0) { IsAdd = true; StartColorA = 0; }
            this.Invalidate();
        }

        private void PlayButton_SizeChanged(object sender, EventArgs e)
        {
            this.Height = this.Width;
        }
        protected override void OnMouseMove(MouseEventArgs e)
        {
            if (e.X >= 0 & e.X <= this.Width & e.Y >= this.Height / 2 - 4 & e.Y <= this.Height / 2 + 4)
                this.Cursor = Cursors.Hand;
            else
                this.Cursor = Cursors.Default;

            base.OnMouseMove(e);
        }
        protected override void OnMouseDown(MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                isActive = false;
                StartColorA = 0;
            }
            base.OnMouseDown(e);
        }
        protected override void OnMouseUp(MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                isActive = true;
            }
            base.OnMouseUp(e);
        }
    }
}
