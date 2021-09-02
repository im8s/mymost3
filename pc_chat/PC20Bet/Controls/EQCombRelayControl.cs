using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;
using WinFrmTalk.View;

namespace WinFrmTalk.Controls
{
    public class EQCombRelayControl : EQBaseControl
    {
        public EQCombRelayControl(string strJson) : base(strJson)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
            isHaveBorder = false;
        }

        public EQCombRelayControl(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
            isHaveBorder = false;
        }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleHeight = control.Height;
            BubbleWidth = control.Width;
        }

        public override Control ContentControl()
        {
            string content = "";

            CombRelayPanel combRelayPanel = new CombRelayPanel();
            combRelayPanel.Tag = messageObject.content;
            combRelayPanel.Cursor = Cursors.Hand;
            var list_msg = JsonConvert.DeserializeObject<List<object>>(messageObject.content);
            foreach (var str_msg in list_msg)
            {
                var msg = new MessageObject().toModel(str_msg.ToString());
                string msg_txt = msg.type == kWCMessageType.Text ? msg.content : new Friend().ToLastContentTip(msg.type, msg.content);
                content += msg.fromUserName + "：" + msg_txt + "\n";
            }

            //赋值
            combRelayPanel.lblName.Text = messageObject.objectId;
            combRelayPanel.lblContent.Text = content;
            Calc_PanelWidth(combRelayPanel);

            //修改底色
            bg_color = Color.White;

            //鼠标点击事件
            combRelayPanel.MouseDown += (sender, e) =>
            {
                if (e.Button == MouseButtons.Left)
                {
                    FrmHistoryMsg frmHistoryMsg = new FrmHistoryMsg() { content = combRelayPanel.Tag != null ? combRelayPanel.Tag.ToString() : "", FromLocal = false };
                    frmHistoryMsg.TitleText = (combRelayPanel.lblName.Text).ToString();

                    frmHistoryMsg.Show();

                    //发送已读通知
                    string msgId = combRelayPanel.Parent.Name.Replace("talk_panel_", "");
                    //MessageObject msg = MessageObjectDataDictionary.GetMsg(msgId);
                    MessageObject msg = this.messageObject;
                    if (msg != null)
                    {
                        ShiKuManager.SendReadMessage(msg.GetFriend(), msg);
                        //更新红点
                        var crl_msg = combRelayPanel.Parent.Controls["lab_redPoint"];
                        if (crl_msg != null && crl_msg is Label lab_redPoint && lab_redPoint.Image != null)
                        {
                            //去除红点
                            DrawIsReceive(lab_redPoint, 1);
                        }
                    }
                }
            };
            return combRelayPanel;
        }
    }
}
