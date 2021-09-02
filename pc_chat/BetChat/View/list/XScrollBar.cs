using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TestListView
{
    public partial class XScrollBar : UserControl
    {

        public delegate void EventProgressHandler();
        public event EventProgressHandler ScrollChangeListener;

        private const int DEF_WIDTH = 10;


        public int currt_pro = 0;
        public int max_location = 0;

        public XScrollBar()
        {
            InitializeComponent();
        }

        private void XScrollBar_Load(object sender, EventArgs e)
        {
            this.Width = DEF_WIDTH;
            this.XSlider.Width = DEF_WIDTH;
            this.XSlider.Height = DEF_WIDTH * 4;
            currt_pro = 0;
            max_location = this.Height - this.XSlider.Height;
            LogUtils.Log("XScrollBar_Load"+ Height+","+ max_location);
        }

        private void XScrollBar_SizeChanged(object sender, EventArgs e)
        {
            max_location = this.Height - XSlider.Height;
            SetProgress(currt_pro);
        }


        private void XScrollBar_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Location.Y > XSlider.Location.Y)
            {
                SetProgress(currt_pro + 10);
                OnScrollChange();
            }
            else
            {
                SetProgress(currt_pro - 10);
                OnScrollChange();
            }

        }

        private void XScrollBar_MouseUp(object sender, MouseEventArgs e)
        {
            if (e.Location.Y > XSlider.Location.Y)
            {
                SetProgress(currt_pro + 10);
                OnScrollChange();
            }
            else
            {
                SetProgress(currt_pro - 10);
                OnScrollChange();
            }
        }


        bool isPrass = false;
        int inity = 0;

        public int Value { get {
                return currt_pro;
            } }

        private void XSlider_MouseDown(object sender, MouseEventArgs e)
        {
            inity = Cursor.Position.Y;
            isPrass = true;
        }

        private void XSlider_MouseMove(object sender, MouseEventArgs e)
        {

            if (isPrass)
            {
                inity = Cursor.Position.Y - inity;
                MovePanelLocation(XSlider.Location.Y + inity, true);
                inity = Cursor.Position.Y;
                OnScrollChange();
            }

        }

        private void XSlider_MouseUp(object sender, MouseEventArgs e)
        {
            isPrass = false;
        }

        // 移动到某一个位置
        private void MovePanelLocation(int location_y, bool isCalc = false)
        {
            if (location_y <= 0)
            {
                location_y = 0;
            }
            else if (location_y >= max_location)
            {
                location_y = max_location;
            }

            Point point = XSlider.Location;
            point.Y = location_y;
            XSlider.Location = point;

            if (isCalc)
            {
                currt_pro = Convert.ToInt32(location_y / (float)max_location * 100.0f);
            }
        }


        public void SetProgress(int pro)
        {
            if (max_location == 0)
            {
                max_location = this.Height - XSlider.Height;
            }

            currt_pro = pro;

            if (currt_pro <= 0)
            {
                currt_pro = 0;
            }
            else if (currt_pro >= 100)
            {
                currt_pro = 100;
            }


            int pos = Convert.ToInt32(currt_pro / 100.0 * max_location);

            MovePanelLocation(pos);
        }

        public void OnScrollChange()
        {
            if (ScrollChangeListener != null)
            {
                Invoke(ScrollChangeListener);
            }
            
        }
    }
}
