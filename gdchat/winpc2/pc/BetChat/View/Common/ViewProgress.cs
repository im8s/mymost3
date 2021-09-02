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
    public partial class ViewProgress : UserControl
    {

        SolidBrush mProPaint = new SolidBrush(SystemColors.Desktop);
        int mpro = 50;
        float max = 100.0f;
        public ViewProgress()
        {
            InitializeComponent();
        }

        private void ViewProgress_Paint(object sender, PaintEventArgs e)
        {
            var width = Convert.ToInt32(mpro / max * Width);
            var rect = new Rectangle(0, 0, width, Height);
            e.Graphics.FillRectangle(mProPaint, rect);
        }


        public Color ProColor
        {
            set
            {
                mProPaint.Color = value;
            }
        }


        public void SetProgress(int pro)
        {
            mpro = pro;
            Invalidate();
        }

        internal void SetProgress(int currt, int max)
        {
            this.max = max;
            this.mpro = currt;
            Invalidate();
        }
    }
}
