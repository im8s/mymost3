using Newtonsoft.Json;
using System.Collections.Generic;
using System.IO;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQImageTextSingle : EQBaseControl
    {
        private string url = "";
        public EQImageTextSingle(string strJson) : base(strJson) { }

        public EQImageTextSingle(MessageObject messageObject) : base(messageObject) { }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleWidth = control.Width;
            BubbleHeight = control.Height;
        }

        public override Control ContentControl()
        {
            //解析json
            var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(messageObject.content);

            ImageTextSingle imageTextSingle = new ImageTextSingle();
            if (data.Count > 0)
            {
                url = data["url"].ToString();
                imageTextSingle.lblTitle.Text = data["title"].ToString();
                imageTextSingle.lblSub.Text = data["sub"].ToString();
                ImageLoader.Instance.Load(data["img"].ToString()).NoCache().Into((image, path) =>
                {
                    if (string.IsNullOrEmpty(path) || !File.Exists(path))
                        return;
                    imageTextSingle.picImg.BackgroundImage = image;
                });
            }

            //添加点击事件
            imageTextSingle.MouseClick += ImageTextSingle_MouseClick;
            foreach (Control crl in imageTextSingle.Controls)
                crl.MouseClick += ImageTextSingle_MouseClick;

            Calc_PanelWidth(imageTextSingle);
            return imageTextSingle;
        }

        private void ImageTextSingle_MouseClick(object sender, MouseEventArgs e)
        {
            if(e.Button == MouseButtons.Left)
            {
                if (!string.IsNullOrEmpty(url))
                    System.Diagnostics.Process.Start(url);
            }
        }
    }
}
