using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk.Model;

namespace WinFrmTalk.Helper
{
    public class CollectUtils
    {


        private static string collmsgId = null;

        #region http收藏消息

        /// <summary>
        /// 单条收藏
        /// </summary>
        /// <param name="msg"></param>  
        internal static void CollectMessage(MessageObject msg)
        {
            if (msg == null || UIUtils.IsNull(msg.messageId))
            {
                LogUtils.Log("收藏数据为空");
                return;
            }

            if (msg.messageId.Equals(collmsgId))
            {
                Console.WriteLine("快速点击收藏");
                return;
            }

            collmsgId = msg.messageId;

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/emoji/add") //收藏
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("emoji", toCollectParams(msg))
                .NoErrorTip()
                 .Build().AddErrorListener((code, err) =>
                 {
                     if (code == 0)
                     {
                         HttpUtils.Instance.ShowTip("不能重复收藏消息");
                     }
                     collmsgId = null;
                 })
                .Execute((sccess, room) =>
                {

                    collmsgId = null;
                    if (sccess)
                    {
                        if (msg.type == kWCMessageType.Gif)
                        {
                            HttpUtils.Instance.ShowTip("存表情成功");
                        }
                        else
                        {
                            HttpUtils.Instance.ShowTip("收藏成功");
                            // 更新收藏页
                            Messenger.Default.Send("1", MessageActions.UPDATE_COLLECT_LIST);
                        }

                    }
                });
        }

        /// <summary>
        /// 批量收藏
        /// </summary>
        /// <param name="msglst"></param>
        internal static void CollectMessage(List<MessageObject> msgList)
        {
            if (msgList == null || UIUtils.IsNull(msgList))
            {
                LogUtils.Log("收藏数据为空");
                return;
            }

            for (int index = msgList.Count - 1; index > -1; index--)
            {
                MessageObject msg = msgList[index];
                if (msg.isReadDel == 1)
                    msgList.Remove(msg);
            }

            //收藏
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/emoji/add")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("emoji", toCollectParams(msgList))
                .Build()
                .Execute((sccess, room) =>
                {
                    if (sccess)
                    {
                        HttpUtils.Instance.ShowTip("全部收藏成功");
                        Messenger.Default.Send("1", MessageActions.UPDATE_COLLECT_LIST);
                    }
                });
        }


        // 多条收藏字符串拼接
        private static string toCollectParams(List<MessageObject> msgs)
        {
            JArray jSONArray = new JArray();
            foreach (var datas in msgs)
            {
                JObject data = new JObject();
                if (!(datas.type == kWCMessageType.Video || datas.type == kWCMessageType.Text || datas.type == kWCMessageType.Image || datas.type == kWCMessageType.File || datas.type == kWCMessageType.Voice))
                {
                    continue;
                }
                
                if(datas.type == kWCMessageType.Gif)
                {
                    data.Add("url", datas.content);
                }
                else
                {
                    data.Add("msgId", datas.messageId);
                }
                data.Add("msg", datas.content);
                data.Add("type", GetType(datas.type));

                if (datas.isGroup == 1)
                {
                    data.Add("roomJid", datas.toUserId);
                }

                jSONArray.Add(data);
            }
            return jSONArray.ToString();
        }


        // 单条收藏字符串拼接
        private static string toCollectParams(MessageObject datas)
        {
           if(!isgift)
            {
                datas.type = messageType;
            }
            JArray jSONArray = new JArray();
            JObject data = new JObject();
            data.Add("msgId", datas.messageId);
            data.Add("msg", datas.content);
            if (!isgift)
            {
                data.Add("type", 6);
            }
            else
            {
                data.Add("type", GetType(datas.type));
            }
            
            if (datas.isGroup == 1)
            {
                data.Add("roomJid", datas.toUserId);
            }
            jSONArray.Add(data);
            return jSONArray.ToString();
        }


        // 将消息类型转换为收藏类型
        private static string GetType(kWCMessageType type)
        {
            int value = 0;
            switch (type)
            {
                case kWCMessageType.CUSTOM_EMOT:
                case kWCMessageType.EMOT_PACKAGE:
                case kWCMessageType.Image:
                    value = 1;
                    break;
                case kWCMessageType.Video:
                    value = 2;
                    break;
                case kWCMessageType.File:
                    value = 3;
                    break;
                case kWCMessageType.Voice:
                    value = 4;
                    break;
                case kWCMessageType.Text:
                    value = 5;
                    break;
                case kWCMessageType.Gif:
                    value = 6;
                    break;
                case kWCMessageType.SDKLink:
                    value = 7;
                    break;
            }
            return value.ToString();
        }

        #endregion


        #region http收藏表情
       static  bool isgift = true;
       static kWCMessageType messageType = new kWCMessageType();
        /// <summary>
        /// 收藏表情
        /// </summary>
        /// <param name="msg"></param>
        internal static void CollectExpression(MessageObject msg)
        {
            if (msg == null || UIUtils.IsNull(msg.messageId))
            {
                LogUtils.Log("收藏表情为空");
                return;
            }
            #region 取出当前message中有用的数据，如果直接赋值会导致改变了原先的数据类型
            MessageObject msgs = new MessageObject();

            msgs.messageId = msg.messageId;

            msgs.content = msg.content;
            msgs.roomJid = msg.roomJid;
          if(msg.type != kWCMessageType.Gif)
            {
                isgift = false;
                messageType = msg.type;
                msgs.type = kWCMessageType.Gif; // 存表情要用这个
            }

            
            #endregion
            CollectMessage(msgs);

        }
        #endregion


        #region http收藏链接
        /// <summary>
        /// 收藏链接
        /// </summary>
        /// <param name="url"></param>
        /// <param name="roomJid"></param>
        internal static void CollectLink(string url, string roomJid)
        {

            MessageObject message = new MessageObject();
            message.type = kWCMessageType.SDKLink;
            message.content = url;

            if (!UIUtils.IsNull(roomJid))
            {
                message.isGroup = 1;
                message.toUserId = roomJid;
            }
            message.messageId = Guid.NewGuid().ToString("N");

            CollectMessage(message);
        }

        #endregion


        /// <summary>
        /// 单条服务器删除
        /// </summary>
        /// <param name="msg"></param>
        internal static void DelServerMessages(MessageObject msg, bool isLastMsg)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "tigase/deleteMsg"). //删除群组
                AddParams("access_token", Applicate.Access_Token).
                AddParams("type", msg.isGroup == 0 ? "1" : "2").    //1 单聊  2 群聊
                AddParams("delete", "1").   //1： 删除属于自己的消息记录 2：撤回 删除整条消息记录
                AddParams("messageId", msg.messageId).
                AddParams("roomJid", msg.toUserId).
                Build().ExecuteJson<object>((sccess, obj) =>   //返回值说明： text：加密后的内容
                {
                    //删除成功
                    if (sccess)
                    {
                        int result = msg.DeleteData();
                        HttpUtils.Instance.ShowTip("删除成功");
                        //通知最近聊天列表更新
                        if (isLastMsg)
                            Messenger.Default.Send(msg.GetFriend(), token: MessageActions.UPDATE_FRIEND_LAST_CONTENT);
                    }
                });
        }

        /// <summary>
        /// 多选服务器删除
        /// </summary>
        /// <param name="list_msgs"></param>
        internal static void DelServerMessages(List<MessageObject> list_msgs, bool isLastMsg)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "tigase/deleteMsg"). //删除群组
                AddParams("access_token", Applicate.Access_Token).
                AddParams("type", list_msgs[0].isGroup == 0 ? "1" : "2").    //1 单聊  2 群聊
                AddParams("delete", "1").   //1： 删除属于自己的消息记录 2：撤回 删除整条消息记录
                AddParams("messageId", UIUtils.AppendMessageIds(list_msgs)).
                AddParams("roomJid", list_msgs[0].toUserId).
                Build().ExecuteJson<object>((sccess, obj) =>   //返回值说明： text：加密后的内容
                {
                    //删除成功
                    if (sccess)
                    {
                        // 从数据库中移除
                        foreach (var item in list_msgs)
                        {
                            item.DeleteData();
                        }

                        //通知最近聊天列表更新
                        if (isLastMsg)
                        {
                            Messenger.Default.Send(list_msgs[list_msgs.Count - 1].GetFriend(), token: MessageActions.UPDATE_FRIEND_LAST_CONTENT);
                        }

                        HttpUtils.Instance.ShowTip("全部删除成功");
                    }
                });
        }
    }
}

