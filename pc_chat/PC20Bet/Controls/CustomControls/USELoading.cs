using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk
{
    public partial class USELoading : UserControl
    {
        public USELoading()
        {
            InitializeComponent(); this.SetStyle(ControlStyles.SupportsTransparentBackColor, true);
            //this.BackColor = Color.FromArgb(100, 100, 100, 100);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            //e.Graphics.DrawString("test", new Font("Tahoma", 8.25f), Brushes.Red, new PointF(20, 20));
        }

        internal void ShowCenter(Form father)
        {
            
            int centx = (int)((father.Width - this.Width) * 0.5f);
            int centy = (int)((father.Height - this.Height) * 0.5f);

            Console.WriteLine(father.Width + ",  " + this.Width+" ,  "+centx);
            this.Location = new Point(centx,centy);
            //this.BackColor = Color.FromArgb(0, 0, 0, 0);
            father.Controls.Add(this);

            this.BringToFront();
        }

      
    }
}
