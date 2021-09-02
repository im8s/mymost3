using System;
using System.Collections.Generic;
using WinFrmTalk;
using WinFrmTalk.Model;

namespace WinFrmTalk.Dictionarys
{
    public class MessageObjectDataDictionary
    {
        /// <summary>
        /// 该对象是否为独立窗体的字典
        /// </summary>
        public int isSeparateChat { get; set; }
        /// <summary>
        /// 是否开启多选
        /// </summary>
        public bool isMultiSelect { get; set; }

        private List<MessageObject> _messageObjectData;
        /// <summary>
        /// 储存栈
        /// </summary>
        private List<MessageObject> messageObjectData
        {
            get
            {
                if (_messageObjectData == null)
                    return GetMsgList();
                else return _messageObjectData;
            }
            set => _messageObjectData = value;
        }
        private readonly object looker = new object();       //确保线程的同步，同一时间不能同时访问

        //防止外部创建实例
        //private MessageObjectDataDictionary() { }

        /// <summary>
        /// 通过key获取message，包括非空判断
        /// </summary>
        /// <param name="msgId"></param>
        /// <returns>没有值则返回新的对象</returns>
        public MessageObject GetMsg(string msgId)
        {
            if (messageObjectData.ContainsKey(msgId))
                return messageObjectData.GetMsgById(msgId);
            else
                return null;
        }

        /// <summary>
        /// 更新字典中的message
        /// </summary>
        /// <param name="messageObject"></param>
        /// <returns></returns>
        public MessageObject UpdateMsg(MessageObject messageObject)
        {
            if (messageObjectData.ContainsKey(messageObject.messageId))
            {
                MessageObject msg = GetMsg(messageObject.messageId);
                messageObject.rowIndex = msg.rowIndex;
                messageObjectData[messageObjectData.FindMsgIndex(messageObject.messageId)] = messageObject;
            }
            return messageObject;
        }

        /// <summary>
        /// 在末尾添加一个元素
        /// </summary>
        /// <param name="messageObject"></param>
        public void AddMsgData(MessageObject messageObject)
        {
            //该message已存在
            if (messageObjectData.ContainsKey(messageObject.messageId))
                return;
            messageObjectData.Add(messageObject);
        }

        public void RemoveMsgData(string msgId)
        {
            if (messageObjectData.Count < 1)
                return;
            if (messageObjectData.ContainsKey(msgId))
                messageObjectData.RemoveMsg(msgId);
        }

        #region 清空存储的数据
        /// <summary>
        /// 清空存储的数据
        /// </summary>
        public void RemoveAllData()
        {
            messageObjectData = new List<MessageObject>();
        }
        #endregion

        /// <summary>
        /// 获取列表第一条信息
        /// </summary>
        /// <returns></returns>
        public MessageObject GetFirstIndexMsg()
        {
            if (messageObjectData.Count < 1)
                return null;

            double minTime = double.MaxValue;

            string msgId = "";
            foreach (MessageObject msg in messageObjectData)
            {
                if (msg.type == kWCMessageType.labMoreMsg)
                    continue;

                if (msg.timeSend < minTime && msg.type != kWCMessageType.labMoreMsg)
                {
                    minTime = msg.timeSend;
                    msgId = msg.messageId;
                }
                //Console.WriteLine("rowIndex: " + msg.rowIndex);
            }


            if (messageObjectData.ContainsKey(msgId))
            {
                return messageObjectData.GetMsgById(msgId);
            }
            else
            {
                return null;
            }
            
        }

        /// <summary>
        /// 获取最后一条消息
        /// </summary>
        /// <returns></returns>
        public MessageObject GetLastIndexMsg()
        {
            if (messageObjectData.Count < 1)
                return null;

            double maxTime = -1;
            string msgId = "";
            foreach (MessageObject msg in messageObjectData)
            {
                if (msg.timeSend > maxTime)
                {
                    maxTime = msg.timeSend;
                    msgId = msg.messageId;
                }
            }
            return messageObjectData.ContainsKey(msgId) ? messageObjectData.GetMsgById(msgId) : null;
        }

        /// <summary>
        /// 定义公有方法提供一个全局访问点,同时你也可以定义公有属性来提供全局访问点
        /// </summary>
        /// <returns></returns>
        public List<MessageObject> GetMsgList()
        {
            // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
            // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
            // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
            // 双重锁定只需要一句判断就可以了
            if (_messageObjectData == null)
            {
                lock (looker)
                {
                    // 如果类的实例不存在则创建，否则直接返回
                    if (_messageObjectData == null)
                    {
                        _messageObjectData = new List<MessageObject>();
                    }
                }
            }
            return _messageObjectData;
        }

        /// <summary>
        /// 由于有多个聊天对象，所以不能用单例
        /// </summary>
        /// <returns></returns>
        //public Dictionary<string, MessageObject> GetMessageModelDataDictionary()
        //{
        //    if(messageObjectData == null)
        //        messageObjectData = new Dictionary<string, MessageObject>();

        //    return messageObjectData;
        //}
    }
}
