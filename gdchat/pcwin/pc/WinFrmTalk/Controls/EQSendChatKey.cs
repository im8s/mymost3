using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQSendChatKey : EQBaseControl
    {
        public EQSendChatKey(string strJson) : base(strJson)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }


        public EQSendChatKey(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleWidth = control.Width;
            BubbleHeight = control.Height;
        }

        public override Control ContentControl()
        {
            var sendchatkey = new UseSendChatKey();
            Calc_PanelWidth(sendchatkey);
            sendchatkey.BindData(messageObject);
            sendchatkey.BindEvent(OnSendChatKey);
            return sendchatkey;
        }


        private void OnSendChatKey(MessageObject message)
        {
            ShiKuManager.SendRequestChatKeyMessage(message.GetFriend());
        }
    }
}
