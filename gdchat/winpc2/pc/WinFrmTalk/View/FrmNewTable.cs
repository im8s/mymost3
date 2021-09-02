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
using WinFrmTalk.View.list;

namespace WinFrmTalk.View
{
    public partial class FrmNewTable : FrmBase
    {
        public FrmNewTable()
        {
            InitializeComponent();
        }

        private void FrmNewTable_Load(object sender, EventArgs e)
        {

        }

        private void btnSend_Click(object sender, EventArgs e)
        {

        }

        private void FrmNewTable_FormClosed(object sender, FormClosedEventArgs e)
        {
            //获取用户
            Friend targetFd = this.showMsgPanel.ChooseTarget.GetFdByUserId();
            if (targetFd == null || targetFd.Status != 2)
                return;
            //获取当前对象的字典
            var targetData = ChatTargetDictionary.GetMsgData(targetFd.UserId);
            //获取最后一条消息用作更新列表
            MessageObject lastMsg = targetData.GetLastIndexMsg();
            //移除数据和对象
            //targetData.RemoveAllData();
            showMsgPanel.SetChooseFriend(new Friend());
            ChatTargetDictionary.RemoveItem(targetFd.UserId);

            if (lastMsg == null)
                lastMsg = ShiKuManager.GetMessageObject(targetFd);
            //更新最近消息列表
            Messenger.Default.Send(lastMsg, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
        }
    }
}
