using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.View.Common
{
    public partial class RecentLable : Label
    {
        private const string ATME_TEXT = "[有人@我]";
        private const string ATALL_TEXT = "[@全体成员]";

        public RecentLable()
        {
            InitializeComponent();
        }

        private int atme;
        public int AtMe
        {
            get
            {
                return atme;
            }
            set
            {
                atme = value;
                Invalidate();
            }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            //Console.WriteLine("OnPaint" + this.Text);
            this.Width = 155;
            if (this.Enabled && !string.IsNullOrEmpty(this.Text))
            {
                int offsetx = 0;
                if (AtMe == 1)
                {
                    using (Brush brush = new SolidBrush(System.Drawing.Color.Red))
                    {
                        e.Graphics.DrawString(ATME_TEXT, this.Font, brush, base.ClientRectangle);
                    }

                    SizeF size = e.Graphics.MeasureString(ATME_TEXT, this.Font);
                    offsetx = (int)size.Width;
                }
                else if (AtMe == 2)
                {
                    using (Brush brush = new SolidBrush(System.Drawing.Color.Red))
                    {
                        e.Graphics.DrawString(ATALL_TEXT, this.Font, brush, base.ClientRectangle);
                    }

                    SizeF size = e.Graphics.MeasureString(ATALL_TEXT, this.Font);
                    offsetx = (int)size.Width;
                }

                Color nearestColor = e.Graphics.GetNearestColor(base.Enabled ? this.ForeColor : SystemColors.Control);
                System.Drawing.Rectangle rectangle = e.ClipRectangle;

                rectangle.Location = new Point(e.ClipRectangle.Location.X + offsetx, e.ClipRectangle.Location.Y);
                using (Brush brush = new SolidBrush(nearestColor))
                {
                    e.Graphics.DrawString(Text, this.Font, brush, rectangle);
                }
            }
        }

    }
}
