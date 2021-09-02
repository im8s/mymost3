using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Web.UI;
using Vlc.DotNet.Core.Interops.Signatures;
using WinFrmTalk;

namespace WinFrmTalk
{
    public class LodingUtils
    {
        /// <summary>
        /// 等待符大小控制
        /// </summary>
        private Size _size = new Size(30,30);

        public Size size
        {
            get
            {
                return _size;
            }
            set
            {
                if (value.Height > 200 || value.Width > 200)
                {
                   LogUtils.Log("等待符超过最大值200，");
                    _size = new Size(30,30);
                    return;
                }
                if (value.Height < 30 || value.Width < 30)
                {
                   LogUtils.Log("等待符小于最小值30，");
                    _size = new Size(30,30);
                    return;
                }

                if (value.Height == 0 || value.Width == 0)
                {
                    _size = new Size(30, 30);
                    return;
                }

                _size = value;
            }
        }

        //public Size size = new Size(30,30);//整个控件大小
        public string Title;//等待符上的文字
        public Color BgColor = Color.Transparent;//等待符背景色
        private USELoding loding;//全局Control对象
        public System.Windows.Forms.Control parent { get; set; }//父容器

        /// <summary>
        /// 打开等待符
        /// </summary>
        public void start()
        {
            if (loding != null)
                stop();

            if (parent == null)
            {
                parent = HttpUtils.Instance.GetControl();
                //窗口
                FrmLoading frm = new FrmLoading();
                //实例化控件
                loding = new USELoding();
                //控件颜色
                loding.BgColor = this.BgColor;
                //弹出窗体大小
                frm.Size = new Size(150, 150);
                //设置等待符内的大小
                loding.LoadSize = _size;
                //弹出窗体等待符内的文字
                loding.Title = Title;
                //控制整个控件大小位置
                loding.ControlThis();
                //设置等待符控件的位置
                loding.Location = new Point((frm.Size.Width - loding.Size.Width) / 2, (frm.Size.Height - loding.Size.Height) / 2);
                //弹出窗体位置
                frm.Location = new Point(parent.Location.X + (parent.Width - frm.Width) / 2, parent.Location.Y + (parent.Height - frm.Height) / 2);//居中
                frm.Controls.Add(loding);
                frm.Show();
            }
            else
            {
                // 控件
                loding = new USELoding();
                loding.Name = "loding";
                //控件颜色
                loding.BgColor = this.BgColor;
                //设置等待符内的大小
                loding.LoadSize = _size;
                //弹出窗体等待符内的文字
                loding.Title = Title;
                loding.Parent = parent;
                //控制整个控件大小位置
                loding.ControlThis();
                parent.Controls.Add(loding);
                loding.BringToFront();
                //控制控件在父容器的位置
                loding.Location = new Point((parent.Size.Width - loding.Size.Width) / 2, (parent.Size.Height - loding.Size.Height) / 2);
            }

            Title = "";
        }

        /// <summary>
        /// 关闭等待符
        /// </summary>
        public void stop()
        {
            if (loding != null)
            {
                loding.Dispose();
                loding = null;
                Helpers.ClearMemory();
            }
        }
    }
}

