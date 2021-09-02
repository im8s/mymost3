using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Properties;

namespace WinFrmTalk
{
    public class RoundPicBox : PictureBox
    {
        /// <summary>
        /// 是否触发把头像改为圆
        /// </summary>
        public bool isDrawRound { get; set; }

        public RoundPicBox()
        {
            isDrawRound = true;
        }

        //int index = 0;      //避免循环调用
        //protected override void OnBackgroundImageChanged(EventArgs e)
        //{
            //this.BackgroundImageLayout = ImageLayout.Center;
            //this.BackColor = Color.Transparent;
            //if (this.BackgroundImage != null)
            //{
            //    //只有第一次加载头像换成圆形头像
            //    if (isDrawRound && index == 0)
            //    {
            //        index++;
            //        Bitmap bg_bmp = null;
            //        //避免重复绘制一个头像
            //        if (!string.IsNullOrEmpty(this.Tag == null ? "" : this.Tag.ToString()))
            //        {
            //            if (File.Exists(this.Tag.ToString()))
            //                bg_bmp = new Bitmap(this.Tag.ToString());
            //            else
            //                bg_bmp = new Bitmap(this.BackgroundImage);
            //        }
            //        else
            //            bg_bmp = (Bitmap)this.BackgroundImage;
            //        Bitmap bmp = BitmapUtils.GetRoundImage(bg_bmp);
            //        this.BackgroundImage = EQControlManager.ModifyBitmapSize(bmp, this.Width, this.Height);

            //        isDrawRound = false;
            //    }
            //    index = 0;
            //}
            //base.OnBackgroundImageChanged(e);
        //}
    }
}
