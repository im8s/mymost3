using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.Controls.CustomControls
{
    public enum CheckStyle
    {
        style1, style2, style3
    }
    public partial class USEToggle : UserControl
    {
        bool isCheck = false;
        CheckStyle _checkStyle = new CheckStyle();
        public USEToggle()
        {
            InitializeComponent();
            this.SetStyle(ControlStyles.AllPaintingInWmPaint, true);

            this.SetStyle(ControlStyles.DoubleBuffer, true);

            this.SetStyle(ControlStyles.ResizeRedraw, true);

            this.SetStyle(ControlStyles.Selectable, true);

            this.SetStyle(ControlStyles.SupportsTransparentBackColor, true);

            this.SetStyle(ControlStyles.UserPaint, true);

            this.BackColor = Color.Transparent;
            this.Cursor = Cursors.Hand;

            this.Size = new Size(87, 27);
        }
        /// <summary>

        /// 是否选中

        /// </summary>

        public bool Checked

        {

            set { isCheck = value; this.Invalidate(); }

            get { return isCheck; }

        }

        public CheckStyle checkStyle

        {
            get { return _checkStyle; }
            set { _checkStyle = value; }
        }

        protected override void OnPaint(PaintEventArgs e)

        {

            Bitmap bitMapOn = null;

            Bitmap bitMapOff = null;



            if (checkStyle == CheckStyle.style1)

            {

                bitMapOn = global::WinFrmTalk.Properties.Resources.on32;

                 bitMapOff = global::WinFrmTalk.Properties.Resources.off32;
            }

            //else if (checkStyle == CheckStyle.style2)

            //{

            //    bitMapOn = global::myAlarmSystem.Properties.Resources.btncheckon2;

            //    bitMapOff = global::myAlarmSystem.Properties.Resources.btncheckoff2;

            //}

            //else if (checkStyle == CheckStyle.style3)

            //{

            //    bitMapOn = global::myAlarmSystem.Properties.Resources.btncheckon3;

            //    bitMapOff = global::myAlarmSystem.Properties.Resources.btncheckoff3;

            //}

            //else if (checkStyle == CheckStyle.style4)

            //{

            //    bitMapOn = global::myAlarmSystem.Properties.Resources.btncheckon4;

            //    bitMapOff = global::myAlarmSystem.Properties.Resources.btncheckoff4;

            //}

            //else if (checkStyle == CheckStyle.style5)

            //{

            //    bitMapOn = global::myAlarmSystem.Properties.Resources.btncheckon5;

            //    bitMapOff = global::myAlarmSystem.Properties.Resources.btncheckoff5;

            //}

            //else if (checkStyle == CheckStyle.style6)

            //{

            //    bitMapOn = global::myAlarmSystem.Properties.Resources.btncheckon6;

            //    bitMapOff = global::myAlarmSystem.Properties.Resources.btncheckoff6;

            //}



            Graphics g = e.Graphics;

            Rectangle rec = new Rectangle(0, 0, this.Size.Width, this.Size.Height);



            if (isCheck)

            {

                g.DrawImage(bitMapOn, rec);

            }

            else

            {

                g.DrawImage(bitMapOff, rec);

            }

        }

        private void UserControl1_Click(object sender, EventArgs e)
        {
            isCheck
         = !isCheck;

            this.Invalidate();
        }

        private void USEToggle_Click(object sender, EventArgs e)
        {
            isCheck= !isCheck;

            this.Invalidate();
        }
    }
}

