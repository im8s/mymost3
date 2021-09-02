using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Dictionarys;
using WinFrmTalk;
using WinFrmTalk.Model;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Helper;

namespace WinFrmTalk.Controls
{
    public class EQMenuStripControl
    {
        /// <summary>
        /// 右键菜单撤回事件
        /// </summary>
        internal static void menuItem_Recall_Click(TableLayoutPanelEx showInfo_Panel, MessageObject msg, string userId)
        {
            if (msg.GetFriend().UserId != userId)
                return;
            Action action = new Action(() =>
            {
                MessageObjectDataDictionary targetMsgData = ChatTargetDictionary.GetMsgData(userId);
                //验证该撤回消息是否在当前聊天列表
                var result = targetMsgData.GetMsg(msg.messageId);
                if (result == null || showInfo_Panel.RowStyles.Count < 1)
                    return;
                //remind消息没有撤回
                if (result.type == kWCMessageType.Remind)
                    return;

                result.isRecall = 1;   //记录该消息在撤回
                showInfo_Panel.SuspendLayout();
                msg = targetMsgData.UpdateMsg(msg);

                //KWTypeControlsDictionary kWTypeControls = new KWTypeControlsDictionary(msg);
                //EQBaseControl eqBase = kWTypeControls.GetObjectByType();
                EQBaseControl eqBase = KWTypeControlsDictionary.GetObjectByType(msg);
                EQBaseControl talk_panel = eqBase.GetRecombinedPanel();
                talk_panel.Name = "talk_panel" + msg.messageId;

                //移除聊天气泡换成消息提醒
                //showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, talk_panel.Height + 5));
                float item_height = showInfo_Panel.RowStyles[msg.rowIndex].Height;
                //showInfo_Panel.RowStyles[msg.rowIndex].Height = talk_panel.Height;
                //提示消息居中显示
                talk_panel.Anchor = AnchorStyles.None;
                //循环释放控件（复选框和聊天气泡）
                for (int col_index = 0; col_index < showInfo_Panel.ColumnCount; col_index++)
                {
                    var item = showInfo_Panel.GetControlFromPosition(col_index, msg.rowIndex);
                    if (item != null)
                    {
                        showInfo_Panel.Controls.Remove(item);
                        item.Dispose();
                    }
                }
                ////删除该行旧的样式
                //showInfo_Panel.RowStyles.RemoveAt(msg.rowIndex);
                ////添加该行新的样式
                //showInfo_Panel.RowStyles.Insert(msg.rowIndex, new RowStyle(SizeType.Absolute, talk_panel.Height));
                showInfo_Panel.RowStyles[msg.rowIndex].Height = talk_panel.Height;

                showInfo_Panel.Controls.Add(talk_panel, 1, msg.rowIndex);
                showInfo_Panel.ResumeLayout();
            });
            if (showInfo_Panel.IsHandleCreated)
                showInfo_Panel.Invoke(action);
        }

        /// <summary>
        /// 右键菜单删除事件
        /// </summary>
        internal static void menuItem_Delete_Click(TableLayoutPanelEx showInfo_Panel, string messageId, ref double lastMsgTime, string userId)
        {
            MessageObjectDataDictionary targetMsgData = ChatTargetDictionary.GetMsgData(userId);
            var msg = targetMsgData.GetMsg(messageId);

            bool isLastMsg = false;
            MessageObject lastMsg = targetMsgData.GetLastIndexMsg();
            //如果是最后一条消息，需要通知最近聊天列表更新最后一条消息
            if (lastMsg != null && lastMsg.rowIndex == msg.rowIndex)
            //if (msg != null && msg.rowIndex == showInfo_Panel.RowCount - 1)
            {
                isLastMsg = true;
            }
            //调用接口从服务端删除
            CollectUtils.DelServerMessages(msg, isLastMsg);

            ////从服务器删除自己不可见
            //HttpUtils.Instance.InitHttp(showInfo_Panel);
            //HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "tigase/deleteMsg"). //删除群组
            //    AddParams("access_token", Applicate.Access_Token).
            //    AddParams("type", isGroup == 0 ? "1" : "2").    //1 单聊  2 群聊
            //    AddParams("delete", "1").   //1： 删除属于自己的消息记录 2：撤回 删除整条消息记录
            //    AddParams("messageId", messageId).
            //    Build().ExecuteJson<object>((sccess, obj) =>   //返回值说明： text：加密后的内容
            //    {
            //        //删除成功
            //        if (sccess)
            //        {
            //            int result = msg.DeleteData();
            //        }
            //    });

            int rowIndex = msg.rowIndex;
            showInfo_Panel.SuspendLayout();
            //移除复选框
            if(showInfo_Panel.GetControlFromPosition(0, rowIndex) is CheckBoxEx checkBox)
            {
                showInfo_Panel.Controls.Remove(checkBox);
                checkBox.Dispose();
            }
            //移除气泡控件
            var item = showInfo_Panel.GetControlFromPosition(1, rowIndex);
            showInfo_Panel.Controls.Remove(item);
            item.Dispose();
            showInfo_Panel.RowStyles[rowIndex].Height = 0;
            showInfo_Panel.ResumeLayout();
            //从字典移除
            targetMsgData.RemoveMsgData(messageId);

            //更新列表最后一条消息的时间
            if (isLastMsg)
            {
                lastMsg = targetMsgData.GetLastIndexMsg();
                lastMsgTime = lastMsg == null ? 0 : lastMsg.timeSend;
            }              
        }
    }
}
