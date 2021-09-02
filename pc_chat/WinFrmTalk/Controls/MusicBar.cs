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
    public partial class MusicBar : UserControl
    {
        public MusicBar()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
        }
        public delegate void ValueChanged(MusicBar sender, double Value);
        public event ValueChanged OnValueChanged;
        Point oldPoint = new Point();
        Point picoldPoint = new Point();
        bool isMove = false;
        private double maxValue = 100;
        public double MaxValue
        {
            get { return this.maxValue; }
            set
            {
                if (value <= 0)
                    this.maxValue = double.MaxValue;
                else
                    this.maxValue = value;
            }
        }
        private double value = 0;
        public double Value
        {
            get { return this.value; }
            set
            {
                if (this.value > MaxValue)
                    this.value = MaxValue;
                else
                    this.value = value;
                this.Invalidate();
            }
        }
        private int barWidth = 4;
        public int BarWidth
        {
            get { return this.barWidth; }
            set
            {
                this.barWidth = value;
            }
        }
        private Rectangle barRect;
        protected override void OnPaint(PaintEventArgs e)
        {
            barRect = new Rectangle(this.PlayButton.Width / 2 - 3, (this.Height / 2 - BarWidth / 2), (this.Width - (this.PlayButton.Width / 2) * 2), BarWidth);
            //画底部进度条
            Graphics g = e.Graphics;
            g.SmoothingMode = SmoothingMode.HighQuality;
            GraphicsPath gPath = new GraphicsPath();
            gPath.AddRectangle(new RectangleF(barRect.X, barRect.Y, barRect.Width + 3, barRect.Height));
            g.FillPath(new SolidBrush(Color.FromArgb(130, 0, 0, 0)), gPath);
            g.DrawLine(new Pen(Color.FromArgb(150, 0, 0, 0), 0.3f), barRect.X, barRect.Y, barRect.Width + this.PlayButton.Width / 2, barRect.Y);
            g.DrawLine(new Pen(Color.FromArgb(90, 255, 255, 255), 0.5f), new PointF(barRect.X, barRect.Y + barRect.Height), new PointF(barRect.Width + this.PlayButton.Width / 2, barRect.Y + barRect.Height));
            //g.DrawLine(new Pen(Color.FromArgb(105, 0, 0, 0), 0.3f), barRect.X, barRect.Y, barRect.X, barRect.Y + barRect.Height - 1);
            //g.DrawLine(new Pen(Color.FromArgb(105, 0, 0, 0), 0.3f), barRect.X + barRect.Width, barRect.Y, barRect.X + barRect.Width, barRect.Y + barRect.Height - 1);
            //画播放进度条
            if (!isMove)
            {
                this.PlayButton.Location = new Point(Convert.ToInt32((Value / MaxValue) * (barRect.Width - 3)), this.PlayButton.Location.Y);
            }
            //画前端不变色进度条
            barRect.Width = this.PlayButton.Location.X >= 15 ? this.PlayButton.Location.X - 15 : this.PlayButton.Location.X;
            barRect.X = barRect.X;
            gPath = new GraphicsPath();
            gPath.AddRectangle(barRect);
            g.FillPath(new SolidBrush(Color.FromArgb(255, 102, 204, 255)), gPath);
            //画后端变色进度条
            int lgbWidth = 15;
            int lgbLocationX = barRect.Width;
            if (this.PlayButton.Location.X < 15)
            {
                lgbWidth = this.PlayButton.Location.X <= 0 ? 1 : this.PlayButton.Location.X;
                lgbLocationX = 0;
            }
            gPath = new GraphicsPath();
            gPath.AddRectangle(new RectangleF((float)(barRect.X + lgbLocationX - 0.45), barRect.Y, lgbWidth, BarWidth));
            LinearGradientBrush lgbBrush = new LinearGradientBrush(new RectangleF((float)(barRect.X + lgbLocationX - 0.45), barRect.Y, lgbWidth, BarWidth), Color.Black, Color.White, LinearGradientMode.Horizontal);

            ColorBlend cb = new ColorBlend();
            float[] Pos = { 0f, 1f };
            cb.Positions = Pos;
            cb.Colors = new Color[] { Color.FromArgb(255, 102, 204, 255), Color.FromArgb(255, 255, 255, 255) };
            lgbBrush.InterpolationColors = cb;

            g.FillPath(lgbBrush, gPath);
        }
        private void PlayButton_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (!(e.X >= this.PlayButton.Width / 2 - 4 & e.X <= this.PlayButton.Width / 2 + 4 & e.Y >= this.PlayButton.Height / 2 - 4 & e.Y <= this.PlayButton.Height / 2 + 4))
                {
                    this.PlayButton.Location = new Point(e.X - this.PlayButton.Width / 2 + this.PlayButton.Location.X, this.PlayButton.Location.Y);
                    Value = MaxValue * (this.PlayButton.Location.X / ((float)(this.Width - (this.PlayButton.Width / 2) * 2) - 3));
                    if (OnValueChanged != null)
                    {
                        OnValueChanged(this, value);
                    }
                }
                else
                {
                    isMove = true;
                    oldPoint = MousePosition;
                    picoldPoint = this.PlayButton.Location;
                }
            }
        }

        private void PlayButton_MouseMove(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left & isMove)
            {
                if (picoldPoint.X + (MousePosition.X - oldPoint.X) < 0 | picoldPoint.X + (MousePosition.X - oldPoint.X) + PlayButton.Width > this.Width - 3)
                {
                    this.PlayButton.Location = new Point(picoldPoint.X + (MousePosition.X - oldPoint.X) < 0 ? 0 : (this.Width - (this.PlayButton.Width / 2) * 2) - 3, picoldPoint.Y);
                    this.Invalidate();
                    return;
                }
                this.PlayButton.Location = new Point(picoldPoint.X + (MousePosition.X - oldPoint.X), picoldPoint.Y);
                this.Invalidate();
            }
        }

        private void PlayButton_MouseUp(object sender, MouseEventArgs e)
        {
            if (!isMove)
            {
                return;
            }
            isMove = false;
            Value = MaxValue * (this.PlayButton.Location.X / ((float)(this.Width - (this.PlayButton.Width / 2) * 2) - 3));
            if (OnValueChanged != null)
            {
                OnValueChanged(this, value);
            }
            this.Invalidate();
        }

        private void MusicBar_MouseDown(object sender, MouseEventArgs e)
        {
            barRect = new Rectangle(this.PlayButton.Width / 2 - 3, (this.Height / 2 - BarWidth / 2), (this.Width - (this.PlayButton.Width / 2) * 2), (BarWidth + (this.Height / 2 - BarWidth / 2)));
            if (e.X >= barRect.X & e.X <= barRect.Width & e.Y >= barRect.Y & e.Y <= barRect.Height)
            {
                this.PlayButton.Location = new Point(e.X - this.PlayButton.Width / 2, this.PlayButton.Location.Y);
                Value = MaxValue * (this.PlayButton.Location.X / ((float)(this.Width - (this.PlayButton.Width / 2) * 2) - 3));
                if (OnValueChanged != null)
                {
                    OnValueChanged(this, value);
                }
            }
        }

        private void MusicBar_MouseMove(object sender, MouseEventArgs e)
        {
            barRect = new Rectangle(this.PlayButton.Width / 2 - 3, (this.Height / 2 - BarWidth / 2), (this.Width - (this.PlayButton.Width / 2) * 2), (BarWidth + (this.Height / 2 - BarWidth / 2)));
            if (e.X >= barRect.X & e.X <= barRect.Width & e.Y >= barRect.Y & e.Y <= barRect.Height)
                this.Cursor = Cursors.Hand;
            else
                this.Cursor = Cursors.Default;
        }
        protected override void OnResize(EventArgs e)
        {
            base.OnResize(e);
            this.Height = 25;
        }
    }
}
