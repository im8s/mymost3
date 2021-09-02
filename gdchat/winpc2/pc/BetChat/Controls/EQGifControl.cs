using System;
using System.Drawing;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQGifControl : EQBaseControl
    {
        public EQGifControl(string strJson) : base(strJson)
        {
            isShowRedPoint = false;
            isRemindMessage = false;
        }

        public EQGifControl(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = false;
            isRemindMessage = false;
        }

        //不需要气泡
        public override void Calc_PanelWidth(Control control)
        {
            throw new NotImplementedException();
        }

        public override Control ContentControl()
        {
            PictureBox picBoxGif = new PictureBox();
            //截取本地路径
            string path = @"Res\Gif\";
            if (messageObject.content.LastIndexOf("\\") > -1)
                path = path + messageObject.content.Substring(messageObject.content.LastIndexOf("\\") + 1);
            else
                path = path + messageObject.content;
            if (!System.IO.File.Exists(path))
                return picBoxGif;
            Bitmap bitmapGif = new Bitmap(path);
            int pic_width = 120;
            int pic_height = 120;
            picBoxGif.Size = new Size(pic_width, pic_height);
            picBoxGif.Image = bitmapGif;
            picBoxGif.SizeMode = PictureBoxSizeMode.Zoom;

            return picBoxGif;
        }
    }
}
