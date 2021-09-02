using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQLblMoreMsg : EQBaseControl
    {
        public EQLblMoreMsg(string strJson) : base(strJson) { }

        public EQLblMoreMsg(MessageObject messageObject) : base(messageObject) { }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleWidth = control.Width;
            BubbleHeight = 45;
        }

        public override Control ContentControl()
        {
            Label labMoreMsg = null;
            labMoreMsg = new Label();
            labMoreMsg.Name = "labMoreMsg";
            labMoreMsg.AutoSize = true;
            labMoreMsg.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right;
            labMoreMsg.Font = new Font(Applicate.SetFont, 9F, FontStyle.Bold, GraphicsUnit.Point, 134);
            labMoreMsg.ForeColor = Color.FromArgb(78, 169, 233);
            labMoreMsg.Text = messageObject.content;
            labMoreMsg.TextAlign = ContentAlignment.MiddleCenter;
            labMoreMsg.Padding = new Padding(0, 10, 0, 0);    //上边距10
            labMoreMsg.Cursor = Cursors.Hand;

            Calc_PanelWidth(labMoreMsg);
            return labMoreMsg;
        }
    }
}
