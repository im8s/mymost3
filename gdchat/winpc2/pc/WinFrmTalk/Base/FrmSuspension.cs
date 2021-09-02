using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk
{
    /// <summary>
    /// 悬浮窗
    /// </summary>
    public partial class FrmSuspension : Form
    {
        public FrmSuspension()
        {
            InitializeComponent();
            IsClose = true;
            Is_DropShadow = true;
            IsVisible = false;
            Radius = 12;
            //置顶
            //this.TopMost = true;
        }

        #region 失去焦点则关闭窗口
        /// <summary>
        /// 窗体失去焦点时是否关闭
        /// </summary>
        public bool IsClose { get; internal set; }
        /// <summary>
        /// 窗体失去焦点时是否隐藏
        /// </summary>
        public bool IsVisible { get; set; }
        private void FrmExpressionTab_Deactivate(object sender, EventArgs e)
        {
            if (IsClose)
            {
                this.Dispose();
                this.Close();
            }
            else if (IsVisible)
            {
                this.Hide();
            }
        }
        #endregion

        #region 窗体圆角的实现
        /// <summary>
        /// 圆角大小
        /// </summary>
        public int Radius { get; internal set; }
        private void FrmExpressionTab_Resize(object sender, EventArgs e)
        {
            if (this.WindowState == FormWindowState.Normal && Radius != 0)
            {
                SetWindowRegion();
            }
            else
            {
                this.Region = null;
            }
        }
        public void SetWindowRegion()
        {
            System.Drawing.Drawing2D.GraphicsPath FormPath; FormPath = new System.Drawing.Drawing2D.GraphicsPath();
            Rectangle rect = new Rectangle(0, 0, this.Width, this.Height);
            FormPath = GetRoundedRectPath(rect, Radius);
            this.Region = new Region(FormPath);
        }
        /// <summary>        
        ///         
        /// </summary>        
        /// <param name="rect">窗体大小</param>       
        /// <param name="radius">圆角大小</param>        
        /// <returns></returns>        
        private GraphicsPath GetRoundedRectPath(Rectangle rect, int radius)
        {
            int diameter = radius;
            Rectangle arcRect = new Rectangle(rect.Location, new Size(diameter, diameter));
            GraphicsPath path = new GraphicsPath();
            path.AddArc(arcRect, 180, 90);
            //左上角                      
            arcRect.X = rect.Right - diameter;
            //右上角            
            path.AddArc(arcRect, 270, 90);
            arcRect.Y = rect.Bottom - diameter;
            // 右下角            
            path.AddArc(arcRect, 0, 90);
            arcRect.X = rect.Left;
            // 左下角         
            path.AddArc(arcRect, 90, 90);
            path.CloseFigure();
            return path;
        }
        #endregion

        #region 窗体阴影
        /// <summary>
        /// 是否绘制阴影
        /// </summary>
        public bool Is_DropShadow { get; internal set; }
        private const int CS_DropShadow = 0x00020000;   //阴影

        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                if (Is_DropShadow)
                    cp.ClassStyle |= CS_DropShadow;
                return cp;
            }
        }
        #endregion
    }
}
