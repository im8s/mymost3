using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PBMessage;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    public class MyColleagueAdapter : IBaseAdapter
    {

        List<MyColleagues> myColleagues = new List<MyColleagues>();

        private UserCollection UserCollection;
        public override int GetItemCount()
        {
            return myColleagues.Count;
        }
        public void SetMaengForm(UserCollection collection)
        {
            this.UserCollection = collection;
        }
        //private UserLabelItem control;//选中我的讲课
        public override Control OnCreateControl(int index)
        {
            UserLabelItem item = new UserLabelItem();
            item.Name = myColleagues[index].courseId;
            item.lblName.Text =
                "课件名称：" + UIUtils.LimitTextLength(myColleagues[index].courseName, 12,
                    true);
            item.lblName.Name = myColleagues[index].courseName;

            long time = 0;
            if (myColleagues[index].createTime.Length > 10)
            {
                string sss = myColleagues[index].createTime.Substring(0, 10);
                time = long.Parse(sss);
            }
            else
            {
                time = long.Parse(myColleagues[index].createTime);
            }

            item.lblFriend.Text = "录制时间：" + TimeUtils.FromatTime(time, "yy/MM/dd");
            item.Tag += myColleagues[index].messageIds.ToString();
            //  item.Anchor = AnchorStyles.Left | AnchorStyles.Right;
            item.MouseDown += (sen, eve) =>
            {
                //获取讲课详情
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/course/get")
                    .AddParams("courseId", item.Name)
                    .AddParams("access_token", Applicate.Access_Token)
                    .Build().ExecuteJson<List<CourseMessage>>((state, jsonArray) =>
                    {
                        if (state)
                        {
                            Friend friend = null;
                            UserCollection.ListMessage = new List<MessageObject>();

                            foreach (var arrItme in jsonArray)
                            {
                                MessageObject msg = arrItme.ToMessageObject();

                                if (friend == null)
                                {
                                    friend = msg.GetFriend();
                                }

                                if (msg.isEncrypt == 1)
                                {
                                    DES.DecryptMessage(msg);
                                }

                                UserCollection.ListMessage.Add(msg);
                            }

                            if (eve.Button == MouseButtons.Right)
                            {
                                if (UserCollection.control != null)
                                {
                                    UserCollection.control.IsSelected = false;
                                    UserCollection.control.BagColor = Color.WhiteSmoke;
                                    UserCollection.control.ContextMenuStrip = null;
                                }

                                UserCollection.control = item;
                                UserCollection.control.IsSelected = true;

                                item.ContextMenuStrip = UserCollection.cmsLecture;
                            }

                            if (eve.Button == MouseButtons.Left)
                            {
                                if (UserCollection.control != null)
                                {
                                    UserCollection.control.IsSelected = false;
                                    UserCollection.control.BagColor = Color.WhiteSmoke;
                                    UserCollection.control.ContextMenuStrip = null;
                                }

                                UserCollection.control = item;
                                UserCollection.control.IsSelected = true;

                                // FrmHistoryChat frm = FrmHistoryChat.CreateInstrance();
                                //frm.ShowMessageList(UserCollection.ListMessage, UserCollection.control.lblName.Text);
                                FrmHistoryMsg frmHistoryMsg = new FrmHistoryMsg() { messages = UserCollection.ListMessage, FromLocal = false };

                                frmHistoryMsg.TitleText = "我的课件";

                                frmHistoryMsg.Show();
                            }
                        }
                    });
            };

            return item;
        }


        public override int OnMeasureHeight(int index)
        {
            return 80;
        }

        public override void RemoveData(int index)
        {
            myColleagues.RemoveAt(index);
        }
        public void BindDatas(List<MyColleagues> data)
        {

            myColleagues = data;
        }

        internal int GetIndexByName(string name)
        {
            for (int i = 0; i < myColleagues.Count; i++)
            {
                if (myColleagues[i].courseId.Equals(name))
                {

                    return i;
                }
            }
            return -1;
        }

        public MessageObject ChatToMessageObject(ChatMessage message)
        {
            MessageObject chat = new MessageObject();
            chat.fromUserId = message.fromUserId;
            chat.fromUserName = message.fromUserName;
            chat.toUserId = message.toUserId;
            chat.toUserName = message.toUserName;
            chat.timeSend = message.timeSend / 1000.0f;
            chat.deleteTime = message.deleteTime / 1000.0f;
            chat.type = (kWCMessageType)message.type;
            chat.isEncrypt = message.encryptType;
            // 兼容老版本
            if (message.encryptType == 0 && message.isEncrypt)
            {
                chat.isEncrypt = 1;
            }
            chat.isReadDel = message.isReadDel ? 1 : 0;
            chat.content = message.content;
            chat.objectId = message.objectId;
            chat.fileName = message.fileName;
            chat.fileSize = message.fileSize;
            chat.timeLen = Convert.ToInt32(message.fileTime);
            chat.location_x = message.location_x;
            chat.location_y = message.location_y;

            MessageHead head = message.messageHead;
            chat.isGroup = head.chatType - 1;
            chat.FromId = message.fromUserId;
            chat.ToId = head.to;
            chat.messageId = head.messageId;

            return chat;
        }
    }
}
