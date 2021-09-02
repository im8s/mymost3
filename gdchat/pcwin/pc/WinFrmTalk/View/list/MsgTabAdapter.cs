using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using TestListView;
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Helper;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    public class MsgTabAdapter : IBaseAdapter
    {
        public const int row_insert = 20;     //更多聊天记录，一次加载多少行
        public XListView xListView { get; set; }
        public ShowMsgPanel showMsgPanel { get => (ShowMsgPanel)xListView.Parent; }
        private Friend _choose_target;
        public Friend choose_target
        {
            get { if (_choose_target == null) return new Friend(); else return _choose_target; }
            set => _choose_target = value;
        }
        /// <summary>
        /// 当前聊天对象的消息字典
        /// </summary>
        public MessageObjectDataDictionary TargetMsgData
        {
            get
            {
                if (choose_target == null || string.IsNullOrEmpty(choose_target.UserId))
                    return new MessageObjectDataDictionary();
                else
                    return ChatTargetDictionary.GetMsgData(choose_target.UserId);
            }
        }
        //private Dictionary<string, MessageObject> targetData { get; set; }
        public List<MessageObject> msgList
        {
            get
            {
                //var _msgList = TargetMsgData.GetMessageModelDataDictionary().Select(m => m.Value).ToList();
                //按时间排序
                //_msgList.Sort((x, y) =>
                //{
                //    if (x.timeSend < y.timeSend)
                //        return -1;
                //    else if (x.timeSend > y.timeSend)
                //        return 1;
                //    else
                //        return 0;
                //});
                var _msgList = TargetMsgData.GetMsgList();
                return _msgList;
            }
        }

        /// <summary>
        /// 排除lab消息之后的第一条索引
        /// </summary>
        public int FirstMsgIndex => msgList != null && msgList.Count > 0 ? (msgList[0].type == kWCMessageType.labMoreMsg ? 1 : 0) : 0;

        #region private mabers
        private string _labMoreMsg_msgId;
        private string labMoreMsg_msgId
        {
            get
            {
                string msgId = string.IsNullOrEmpty(_labMoreMsg_msgId) ? Guid.NewGuid().ToString("N") : _labMoreMsg_msgId;
                _labMoreMsg_msgId = msgId;
                return msgId;
            }
        }
        #endregion

        public MsgTabAdapter()
        {
            this.interval = 10;     //设置行间距
        }

        #region 继承的方法
        public override int GetItemCount()
        {
            if (msgList != null)
                return msgList.Count;
            return 0;
        }

        public override Control OnCreateControl(int index)
        {
            MessageObject msg = new MessageObject();
            if (msgList.Count > 0)
                msg = msgList[index];
            if (string.IsNullOrEmpty(msg.messageId))
                return null;

            bool isOneSelf = string.Equals(msg.fromUserId, Applicate.MyAccount.userId);     //判断是否为本人发送的消息
            EQBaseControl eqBase = KWTypeControlsDictionary.GetObjectByType(msg);
            eqBase.xListView = xListView;       //绑定列表控件，方便刷新

            //是否显示群已读人数
            if (choose_target.IsGroup == 1)
                eqBase.isShowLabMsg = choose_target.ShowRead == 1 ? true : false;
            //是否显示阅后即焚
            if (choose_target.IsGroup == 0)
                eqBase.isReadDel = msg.isReadDel == 1 ? true : false;
            //含有阅后即焚消息
            if (eqBase.isReadDel)
                showMsgPanel.isHaveReadDel = 1;

            #region 添加时间控件
            //获取上一个控件的时间
            double last_timeSend = GetLastTimeSend(index);
            Label lab_sendTime = eqBase.DrawSendTime(last_timeSend);
            #endregion

            #region 气泡在面板的位置
            int listViewWidth = xListView.ItemGroupWidth;
            //获取气泡控件
            EQBaseControl talk_panel = eqBase.GetRecombinedPanel();
            talk_panel.Name = "talk_panel_" + msg.messageId;
            //talk_panel.Location = new Point(Message_panel.Width - talk_panel.Width - 10, 0);
            if (talk_panel is EQRemindControl)
            {
                talk_panel.Anchor = AnchorStyles.None;
                talk_panel.Location = new Point((listViewWidth - talk_panel.Width) / 2, lab_sendTime != null ? 25 : 5);
            }
            else if (talk_panel is EQLblMoreMsg)
            {
                talk_panel.Anchor = AnchorStyles.None;
                talk_panel.Location = new Point((listViewWidth - talk_panel.Width) / 2, 5);
                if (talk_panel.Controls["labMoreMsg"] != null)
                    talk_panel.Controls["labMoreMsg"].Click += (sender, e) => showMsgPanel.LoadMsg();
            }
            else
            {
                if (isOneSelf)
                {
                    talk_panel.Anchor = AnchorStyles.Right | AnchorStyles.Top;
                    talk_panel.Location = new Point(listViewWidth - talk_panel.Width - 20, lab_sendTime != null ? 25 : 5);
                }
                else
                {
                    talk_panel.Anchor = AnchorStyles.Left | AnchorStyles.Top;
                    talk_panel.Location = new Point(TargetMsgData.isMultiSelect ? 30 + 22 : 30, lab_sendTime != null ? 25 : 5);
                }
            }
            #endregion

            #region 是否添加邀请入群点击事件
            //如果为RoomIsVerify则需要点击事件，确认进群
            if (msg.type == kWCMessageType.RoomIsVerify)
            {
                talk_panel.MouseDown += (sender, e) =>
                {
                    if (e.Button == MouseButtons.Left)
                    {
                        if (choose_target.IsGroup != 1)
                            return;

                        FrmInviteToGroup frmInviteToGroup = new FrmInviteToGroup();
                        frmInviteToGroup.AcceptMessage = msg;
                        frmInviteToGroup.Getfriend = choose_target;
                        frmInviteToGroup.Show();
                    }
                };
            }
            #endregion

            //添加已读人数点击事件
            SetReadPerson_Click(msg, talk_panel);

            Panel panel = new Panel();
            panel.Name = "panel_" + msg.messageId;
            panel.Size = new Size(listViewWidth, talk_panel.Height + talk_panel.Location.Y);
            panel.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right;

            #region 透明多选遮罩层
            EQShowInfoPanelAlpha panelAlpha = new EQShowInfoPanelAlpha();
            //panelAlpha.Size = panel.Size;
            panelAlpha.Location = new Point(0, 0);
            //panelAlpha.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right | AnchorStyles.Bottom;
            panelAlpha.Dock = DockStyle.Fill;
            panelAlpha.Visible = TargetMsgData.isMultiSelect;
            panelAlpha.Click += (sender, e) =>
            {
                //已开启多选
                if (TargetMsgData.isMultiSelect)
                {
                    var result = ((Control)sender).Parent.Controls.Find("checkBox", true);
                    if (result.Length > 0 && result[0] is CheckBoxEx checkBox)
                        checkBox.Checked = !checkBox.Checked;
                }
            };
            #endregion

            //组合控件
            panel.Controls.Add(panelAlpha);
            panel.Controls.Add(talk_panel);
            if (lab_sendTime != null)
            {
                panel.Controls.Add(lab_sendTime);
                //panel.Height += 20;
                lab_sendTime.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right;
                lab_sendTime.Location = new Point((listViewWidth - lab_sendTime.Width) / 2, 3);
            }

            //添加多选复选框
            if (EQControlManager.JudgeIsBubleMsg(msg.type))
            {
                CheckBoxEx checkBox = new CheckBoxEx();
                checkBox.Name = "checkBox";
                checkBox.Text = "";
                checkBox.Size = new Size(20, 20);
                checkBox.Visible = TargetMsgData.isMultiSelect;
                checkBox.Location = new Point(15, 15);

                checkBox.CheckedChanged += (sender, e) =>
                {
                    bool cheked = ((CheckBoxEx)sender).Checked;
                    if (cheked)
                        showMsgPanel.multiSelectPanel.List_Msgs.Add(msg);
                    else
                        showMsgPanel.multiSelectPanel.List_Msgs.Remove(msg);

                };

                //checkBox.Dock = DockStyle.Left;
                panel.Controls.Add(checkBox);
            }

            //不显示红点的，和非阅后即焚才直接发送已读
            if (msg.isRead != 1 && !talk_panel.isShowRedPoint && msg.isReadDel == 0)
            {
                //只对别人的消息发送已读
                if (msg.fromUserId != Applicate.MyAccount.userId)
                {
                    if (!Applicate.GetWindow<FrmMain>().IsActivate)
                    {
                        showMsgPanel.DeactivateMsgList.Add(msg);
                    }
                    else
                    {
                        ShiKuManager.SendReadMessage(choose_target, msg);
                    }
                }
            }
            return panel;
        }

        public override int OnMeasureHeight(int index)
        {
            int crl_height = 0;
            MessageObject msg = new MessageObject();
            if (msgList.Count > 0)
                msg = msgList[index];
            if (string.IsNullOrEmpty(msg.messageId))
                return 0;

            //是否需要加上时间控件的高度
            int labTimeSend_Height = 0;
            if (isHaveLabTimeSend(index, msg))
                labTimeSend_Height = 20;

            //是否含有群名称
            int groupNickName_height = 0;
            if (msg.isGroup == 1 && !msg.fromUserId.Equals(Applicate.MyAccount.userId))
                groupNickName_height = 19;

            switch (msg.type)
            {
                case kWCMessageType.Text:
                    if (msg.isReadDel == 1 && !msg.FromId.Equals(Applicate.MyAccount.userId))
                    {
                        msg.BubbleWidth = 59;
                        msg.BubbleHeight = 25;
                        msg.UpdateData();
                    }
                    else
                    {
                        if (msg.BubbleHeight <= 0)
                            EQControlManager.CalculateWidthAndHeight_Text(msg);
                    }
                    crl_height = msg.BubbleHeight + 19;
                    break;
                case kWCMessageType.CUSTOM_EMOT:
                case kWCMessageType.EMOT_PACKAGE:
                case kWCMessageType.Image:
                    if (msg.BubbleHeight > 0)
                        crl_height = msg.BubbleHeight;
                    else
                        crl_height = EQControlManager.CalculateWidthAndHeight_Image(msg).Height;
                    break;
                case kWCMessageType.Gif:
                    crl_height = 124;
                    break;
                case kWCMessageType.TYPE_SECURE_LOST_KEY:
                    crl_height = 130;
                    break;
                case kWCMessageType.File:
                    crl_height = 97;
                    break;
                case kWCMessageType.Card:
                    crl_height = 97;
                    break;
                case kWCMessageType.Location:
                    crl_height = 96;
                    break;
                case kWCMessageType.Link:
                    crl_height = 96;
                    break;
                case kWCMessageType.Video:
                    crl_height = msg.BubbleHeight > 0 ? msg.BubbleHeight + 4 : 204;
                    break;
                case kWCMessageType.History:
                    crl_height = 124;
                    break;
                case kWCMessageType.Voice:
                    crl_height = 44;
                    break;
                case kWCMessageType.Remind:
                    groupNickName_height = 0;
                    if (msg.BubbleHeight > 0)
                        crl_height = msg.BubbleHeight + 4;
                    else
                        crl_height = EQControlManager.CalculateWidthAndHeight_Remind(msg).Height + 4;
                    break;
                case kWCMessageType.labMoreMsg:
                    crl_height = 45;
                    break;
                case kWCMessageType.Replay:
                    //if (msg.BubbleHeight <= 0)
                    //{
                    Dictionary<string, Size> dic = EQControlManager.CalculateWidthAndHeight_Reply(msg);
                    if (msg.isReadDel == 1 && !msg.FromId.Equals(Applicate.MyAccount.userId))
                    {
                        Size ri_size = new Size(59, 25);
                        Size re_size = dic["replyTextBox"];
                        int ri_width = ri_size.Width, ri_height = ri_size.Height;
                        int re_width = re_size.Width, re_height = re_size.Height;
                        msg.BubbleWidth = (ri_width > re_width ? ri_width : re_width) + 5;
                        msg.BubbleHeight = re_height + 11 + ri_height + 5;
                    }
                    //}
                    crl_height = msg.BubbleHeight + 25;
                    break;
                case kWCMessageType.ImageTextSingle:
                    crl_height = 220;
                    break;
                case kWCMessageType.ImageTextMany:
                    JArray jSONArray = JArray.Parse(msg.content);
                    crl_height = (jSONArray.Count - 1) * 80 + 150 + 20;
                    break;
                case kWCMessageType.RedPacket:
                case kWCMessageType.TRANSFER:
                    crl_height = 137;
                    break;
                default:
                    groupNickName_height = 0;
                    if (msg.BubbleHeight > 0)
                        crl_height = msg.BubbleHeight + 4;
                    else
                        crl_height = EQControlManager.CalculateWidthAndHeight_Remind(msg).Height + 4;
                    break; ;
            }

            int total_height = 0;
            //文本和图片的最小高度为45
            if ((crl_height + groupNickName_height) < 45 && (msg.type == kWCMessageType.Text 
                || msg.type == kWCMessageType.Image 
                || msg.type == kWCMessageType.CUSTOM_EMOT
                || msg.type == kWCMessageType.EMOT_PACKAGE
               ))
                total_height = 45 + labTimeSend_Height;
            else
                total_height = crl_height + labTimeSend_Height + groupNickName_height;

            return total_height;

        }

        public void BindData(List<MessageObject> msgList)
        {
            int index = 0;
            foreach (var msg in msgList)
            {
                if (!msg.IsVisibleMsg())
                    continue;
                this.msgList.Insert(FirstMsgIndex + index, msg);
                index++;
            }
        }

        public override void RemoveData(int index)
        {
            xListView.RemoveItem(index);
            if (msgList.Count > 0)
            {
                MessageObject msg = msgList[index];
                TargetMsgData.RemoveMsgData(msg.messageId);
            }
        }
        #endregion

        /// <summary>
        /// 不能继续向上翻页和点击加载更多聊天记录
        /// </summary>
        public void NotCanAddMoreMsg()
        {
            //从集合中移除
            int index = msgList.FindIndex(m => m.messageId == labMoreMsg_msgId);
            if (index > -1)
                xListView.RemoveItem(index);
            TargetMsgData.RemoveMsgData(labMoreMsg_msgId);
            //RemoveData(index);
        }

        /// <summary>
        /// 能继续向上翻页和点击加载更多聊天记录
        /// </summary>
        public void CanAddMoreMsg(bool isInsert = true)
        {
            //避免重复添加
            if (msgList.Count > 0 && msgList[0].type == kWCMessageType.labMoreMsg)
                return;
            MessageObject lab_msg = new MessageObject()
            {
                type = kWCMessageType.labMoreMsg,
                timeSend = 946656000,   //2000-1-1 0:0:0
                messageId = labMoreMsg_msgId,
                content = "显示更多的消息记录"
            };
            msgList.Insert(0, lab_msg);
            int index = msgList.FindIndex(m => m.messageId == labMoreMsg_msgId);
            if (index > -1 && isInsert)
                xListView.InsertItem(index);
        }

        #region 加载本地聊天记录
        public List<MessageObject> LoadObjectLocalMsg()
        {
            #region 获取timeSend
            double endSend = TimeUtils.CurrentTimeDouble();
            if (TargetMsgData.GetFirstIndexMsg() != null)
                endSend = TargetMsgData.GetFirstIndexMsg().timeSend;
            double startTime = 0;
            if (choose_target.OfflineEndTime > 0)
                startTime = choose_target.OfflineEndTime;
            #endregion
            //获取固定数量的聊天消息
            List<MessageObject> msgList = new MessageObject()
            {
                FromId = choose_target.UserId
            }.GetPageListNotHaveIsRead(endSend, row_insert, startTime);
            //保存需要移除的msg集合
            List<MessageObject> removeList = new List<MessageObject>();
            for (int index = msgList.Count - 1; index > -1; index--)
            {
                var msg = msgList[index];
                if (msg == null || string.IsNullOrEmpty(msg.messageId))
                    continue;
                //循环移除重复msg
                if (TargetMsgData.GetMsg(msg.messageId) != null || !msg.IsVisibleMsg())
                    msgList.Remove(msg);
            }
            //数量足够显示加载更多
            //if (msgList.Count == row_insert)
            //    isHaveMoreLocalMsg = true;
            //重新排序（两条数据以上）
            if (msgList.Count > 1)
                msgList.Sort((x, y) =>
                {
                    if (x.timeSend < y.timeSend)
                        return -1;
                    else if (x.timeSend > y.timeSend)
                        return 1;
                    else
                        return 0;
                });
            return msgList;
        }
        #endregion

        #region 时间控件
        /// <summary>
        /// 获取上一条消息的时间
        /// </summary>
        /// <param name="index">在集合中的索引</param>
        /// <returns></returns>
        private double GetLastTimeSend(int index)
        {
            int last_index = index - 1;
            double last_timeSend = 0;   //上一条消息的发送时间
            if (last_index > -1 && last_index < msgList.Count)
            {
                MessageObject last_msg = msgList[last_index];
                last_timeSend = last_msg.timeSend;
            }
            return last_timeSend;
        }

        private bool isHaveLabTimeSend(int index, MessageObject msg)
        {
            if (msg.type == kWCMessageType.labMoreMsg)
                return false;

            //获取上一个控件的时间
            double last_timeSend = GetLastTimeSend(index);
            DateTime dt_lastMsg = Helpers.StampToDatetime(last_timeSend);     //最后一条消息的时间
            DateTime dt_timeSend = Helpers.StampToDatetime(msg.timeSend);     //信息发送时间
            //判断两条信息的时间间隔
            TimeSpan timeSpan = dt_timeSend - dt_lastMsg;
            if (timeSpan.TotalMinutes > 3.1)     //如果间隔三分钟以下，则不进行绘制
                return true;

            return false;
        }
        #endregion

        #region 如果该消息为群信息，且打开了群已读设置
        private void SetReadPerson_Click(MessageObject messageObject, EQBaseControl talk_panel)
        {
            if (messageObject.isGroup == 1)
            {
                var crls = talk_panel.Controls.Find("lab_msg", true);
                Control lab_msg = crls.Length > 0 ? crls[0] : null;
                if (lab_msg != null)
                {
                    lab_msg.MouseDown += (sender, e) =>
                    {
                        //弹出已读人数显示框

                        if (messageObject.isSend == XmppReceiptManager.RECEIPT_ERR)
                        {
                            // 修改禅道#7702
                            return;
                        }

                        if (string.Equals(messageObject.myUserId, messageObject.fromUserId) && messageObject.isSend == 0)
                        {
                            // 修改禅道8187
                            return;
                        }

                        if (choose_target.ShowRead == 1 && e.Button == MouseButtons.Left)
                        {
                            var frmReaded = new FrmReadedList();
                            frmReaded.Show();

                            frmReaded.GetFriend = choose_target;
                            frmReaded.DesMessage(messageObject);
                        }
                    };
                }
            }
        }
        #endregion
    }
}
