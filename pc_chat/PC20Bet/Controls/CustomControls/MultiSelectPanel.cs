using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.Helper.MVVM;
using WinFrmTalk.Helper;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class MultiSelectPanel : UserControl
    {
        private List<MessageObject> _msgs;
        /// <summary>
        /// 多选的集合
        /// </summary>
        public List<MessageObject> List_Msgs
        {
            get { return _msgs; }
            set { _msgs = value; }
        }
        /// <summary>
        /// 当前的聊天对象
        /// </summary>
        public Friend FdTalking { get; set; }
        /// <summary>
        /// 消息列表面板
        /// </summary>
        public TableLayoutPanel showInfo_panel { get; set; }
        public MultiSelectPanel()
        {
            InitializeComponent();
        }

        #region 合并转发
        private void picCombineRelay_MouseDown(object sender, MouseEventArgs e)
        {
            if(e.Button == MouseButtons.Left && List_Msgs.Count > 0)
            {
                List<MessageObject> msglist = new List<MessageObject>(); 
                foreach (MessageObject msg in List_Msgs)
                {
                    if(msg.type!= kWCMessageType.History)
                    {
                        msglist.Add(msg);
                    }
                }
                List_Msgs = msglist;
                //重新排序
                List_Msgs.Sort((x, y) => {
                    if (x.timeSend < y.timeSend)
                        return -1;
                    else if (x.timeSend > y.timeSend)
                        return 1;
                    else
                        return 0;
                });

                //选择转发的好友
                var frmFriendSelect = new FrmFriendSelect();
                frmFriendSelect.LoadFriendsData(1);
                frmFriendSelect.AddConfrmListener((UserFriends) =>
                {
                    foreach (var friend in UserFriends.Values)
                    {
                        MessageObject msg = ShiKuManager.SendForwardMessage(friend, List_Msgs);
                        if (msg == null)
                            continue;

                        //如果转发对象包括当前聊天对象，给UI添加消息气泡
                        if (friend.UserId == FdTalking.UserId)
                        {
                            //添加消息气泡通知
                            Messenger.Default.Send(msg, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                        }
                    }

                    if (UserFriends.Keys.Count > 0)
                        //关闭多选界面
                        Messenger.Default.Send(FdTalking, token: EQFrmInteraction.MultiSelectEnd);
                });
            }
        }
        #endregion

        #region 逐条转发
        private void picOneRelay_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left && List_Msgs.Count > 0)
            {
                //重新排序
                List_Msgs.Sort((x, y) => {
                    if (x.timeSend < y.timeSend)
                        return -1;
                    else if (x.timeSend > y.timeSend)
                        return 1;
                    else
                        return 0;
                });

                //选择转发的好友
                var frmFriendSelect = new FrmFriendSelect();
                frmFriendSelect.LoadFriendsData(1);
                frmFriendSelect.AddConfrmListener((UserFriends) =>
                {
                    //循环发送不同的好友
                    foreach (var friend in UserFriends.Values)
                    {
                        foreach (MessageObject oMsg in List_Msgs)
                        {
                            MessageObject msg = ShiKuManager.SendForwardMessage(friend, oMsg);

                            //如果转发对象包括当前聊天对象，给UI添加消息气泡
                            if (friend.UserId == FdTalking.UserId)
                            {
                                //添加消息气泡通知
                                Messenger.Default.Send(msg, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                            }
                        }
                    }

                    if (UserFriends.Keys.Count > 0)
                        //关闭多选界面
                        Messenger.Default.Send(FdTalking, token: EQFrmInteraction.MultiSelectEnd);
                });
            }
        }
        #endregion

        private void picDelete_MouseDown(object sender, MouseEventArgs e)
        {
            //重新排序
            List_Msgs.Sort((x, y) => {
                if (x.timeSend < y.timeSend)
                    return -1;
                else if (x.timeSend > y.timeSend)
                    return 1;
                else
                    return 0;
            });

            //批量删除
            Messenger.Default.Send(List_Msgs, token: EQFrmInteraction.BatchDeleteMsg);

            if (List_Msgs.Count > 0)
                //关闭多选界面
                Messenger.Default.Send(FdTalking, token: EQFrmInteraction.MultiSelectEnd);
        }

        private void picCollect_Click(object sender, EventArgs e)
        {
            if (List_Msgs.Count > 0)
            {
                //重新排序
                List_Msgs.Sort((x, y) => {
                    if (x.timeSend < y.timeSend)
                        return -1;
                    else if (x.timeSend > y.timeSend)
                        return 1;
                    else
                        return 0;
                });
                //调用收藏
                //foreach (MessageObject msg in List_Msgs)
                //    CollectUtils.getHttpData(msg);
                //批量收藏
                CollectUtils.CollectMessage(List_Msgs);

                //关闭多选界面
                Messenger.Default.Send(FdTalking, token: EQFrmInteraction.MultiSelectEnd);
            }
        }
    }
}
