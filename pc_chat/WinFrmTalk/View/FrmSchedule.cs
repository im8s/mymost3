using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk.Helper.MVVM;
using WinFrmTalk.Model;
using static TestListView.XListView;

namespace WinFrmTalk.View
{
    public partial class FrmSchedule : FrmBase
    {
        List<string> FriendFromLst = new List<string>();

        const int TASK_CLEAR_ALL_MSG_RECORD = 1;

        int mTask = 0;

        bool mStop = false;

        public EventScrollHandler Compte { get; set; }

        public FrmSchedule()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标

            var parea = Applicate.GetWindow<FrmMain>();
            this.Location = new Point(parea.Location.X + (parea.Width - this.Width) / 2, parea.Location.Y + (parea.Height - this.Height) / 2);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            mStop = true;
            this.Close();
            this.Dispose();
        }


        /// <summary>
        /// 窗体居中打开
        /// </summary>
        private void CenterOpen()
        {
            mStop = false;
            var parea = Applicate.GetWindow<FrmMain>();
            this.Location = new Point(parea.Location.X + (parea.Width - this.Width) / 2, parea.Location.Y + (parea.Height - this.Height) / 2);
            this.Show();
        }

        public void ClearAllMsgRecord()
        {
            this.Text = "清除聊天记录";
            CenterOpen();
            mTask = TASK_CLEAR_ALL_MSG_RECORD;
            RefreshScheduleUi();

            Task.Factory.StartNew(() =>
            {
                Thread.Sleep(1000);
                List<Friend> listfriend = new Friend().QueryFriendAndRoom();

                for (int i = 0; i < listfriend.Count; i++)
                {


                    var item = listfriend[i];
                    Thread.Sleep(200);
                    if (mStop)
                    {
                        return;
                    }

                    UpdateProgress(i, listfriend.Count, "正在清除 " + item.NickName + " 的聊天记录");

                    var msg = new MessageObject() { FromId = Applicate.MyAccount.userId, ToId = item.UserId };
                    if (msg.DeleteTable() > 0)
                    {
                        if (Applicate.IsChatFriend(item.UserId))
                        {
                            Messenger.Default.Send(item.UserId, token: EQFrmInteraction.ClearFdMsgsSingle);
                        }
                        else
                        {
                            Messenger.Default.Send(item, token: MessageActions.UPDATE_FRIEND_LAST_CONTENT);
                        }
                    }
                }

                if (Compte != null)
                {
                    button1_Click(null, null);
                    try
                    {
                        Invoke(Compte);
                    }
                    catch
                    {

                    }
                }

            });
        }

        private void RefreshScheduleUi()
        {
            this.viewProgress1.SetProgress(0);
            if (mTask == TASK_CLEAR_ALL_MSG_RECORD)
            {
                this.label1.Text = "清除中";
                this.label2.Text = "清除中";
            }
        }


        private void UpdateProgress(int currt, int max, string text)
        {
            if (mStop)
            {
                return;
            }
            Invoke(new Action(() =>
            {
                if (mStop)
                {
                    return;
                }
                this.viewProgress1.SetProgress(currt, max);
                this.label2.Text = text;
                this.label1.Text = "清除中 " + (currt + 1) + " / " + max;

            }));
        }

        private void FrmSchedule_FormClosing(object sender, FormClosingEventArgs e)
        {
            mStop = true;
        }
    }
}
