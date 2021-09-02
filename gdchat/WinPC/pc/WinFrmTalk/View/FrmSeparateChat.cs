using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;

namespace WinFrmTalk.View
{
    public partial class FrmSeparateChat : FrmBase
    {
        public FrmSeparateChat()
        {
            InitializeComponent();
            this.FormClosed += FrmSeparateChat_FormClosed;
        }

        private void FrmSeparateChat_Load(object sender, EventArgs e)
        {
            //更新UI 我退出了某一个群组(主动离开)messageObject
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_ROOM_DELETE, item => 
            {
                if (sendMsgPanel.choose_target.UserId.Equals(item.ChatJid))
                    Close();
            });
            // 好友删除
            Messenger.Default.Register<Friend>(this, MessageActions.DELETE_FRIEND, item =>
            {
                if (sendMsgPanel.choose_target.UserId.Equals(item.UserId))
                    Close();
            });
            // 被加入黑名单
            Messenger.Default.Register<Friend>(this, MessageActions.ADD_BLACKLIST, item =>
            {
                if (sendMsgPanel.choose_target.UserId.Equals(item.UserId))
                    Close();
            });
        }

        private void FrmSeparateChat_FormClosed(object sender, FormClosedEventArgs e)
        {
            //获取用户
            Friend targetFd = this.sendMsgPanel.choose_target;
            //获取当前对象的字典
            var targetData = ChatTargetDictionary.GetMsgData(targetFd.UserId);
            //获取最后一条消息用作更新列表
            MessageObject lastMsg = targetData.GetLastIndexMsg();
            //移除数据和对象
            targetData.RemoveAllData();
            ChatTargetDictionary.RemoveItem(targetFd.UserId);

            //更新最近消息列表
            Messenger.Default.Send(lastMsg, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
        }
    }
}
