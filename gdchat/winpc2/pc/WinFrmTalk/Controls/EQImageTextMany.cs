using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.IO;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQImageTextMany : EQBaseControl
    {
        public EQImageTextMany(string strJson) : base(strJson) { }

        public EQImageTextMany(MessageObject messageObject) : base(messageObject) { }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleWidth = control.Width;
            BubbleHeight = control.Height;
        }

        public override Control ContentControl()
        {
            ImageTextMany imageTextMany = new ImageTextMany();
            imageTextMany.SetImageText(messageObject.content);
            Calc_PanelWidth(imageTextMany);
            return imageTextMany;
        }
    }
}
