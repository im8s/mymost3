using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.View.list;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class UserLiveChat : UserControl
    {
        public LiveChatAdapter mAdapter;
        public List<MessageObject> messageObjectLst = new List<MessageObject>();
        Friend fdSend = new Friend();
        public UserLiveChat()
        {
            InitializeComponent();
            mAdapter = new LiveChatAdapter();
        }
        /// <summary>
        /// 绑定数据
        /// </summary>
        public void setdata()
        {
            mAdapter.BindDatas(messageObjectLst);
            ChatList.SetAdapter(mAdapter);
        }
        public void SetChooseFriend(Friend friend, int readNum = 0, string msgId = "", int isSeparateChat = 0)
        {
            try
            {
                //避免因为错误退出，界面挂起没恢复
                this.ResumeLayout();
                ChatList.panel1.ResumeLayout();
                fdSend = friend;
                //setdata();

            }
            catch
            {

            }
        }

        /// <summary>
        ///发送文字
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnSend_Click(object sender, EventArgs e)
        {
            string text = txtSend.Text;

            if (!string.IsNullOrEmpty(text))
            {
                MessageObject txt_msg = null;
                txt_msg = ShiKuManager.SendTextMessage(fdSend, text.TrimEnd(), false);

                JudgeMsgIsAddToPanel(txt_msg);          //添加消息气泡
                ShiKuManager.SendMessage(txt_msg); //指定发送的UserId
            }
        }

        private void JudgeMsgIsAddToPanel(MessageObject txt_msg)
        {
            //if (this.IsHandleCreated)
            //    Invoke(new Action(() =>
            //    {
            //        try
            //        {
                        setdata();  
                        mAdapter.InsertData(0, txt_msg);
                       int a= mAdapter.GetItemCount();
                        messageObjectLst.Add(txt_msg);
                         
                        ChatList.InsertItem(messageObjectLst.Count-1);
    //                }
    //                catch (Exception ex)
    //                {
    //                    LogHelper.log.Error("----直播聊天生成消息出错，方法（JudgeMsgIsAddToPanel） : " + ex.Message, ex);
    //                }
    //            }));
                }

        private void UserLiveChat_Load(object sender, EventArgs e)
        {
            
        }
    }
}
