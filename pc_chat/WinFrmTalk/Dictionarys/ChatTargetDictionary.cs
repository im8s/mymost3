using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Dictionarys
{
    public class ChatTargetDictionary
    {
        private static Dictionary<string, MessageObjectDataDictionary> chatTargetDictionary;       //储存栈
        private static readonly object looker = new object();       //确保线程的同步，同一时间不能同时访问

        private ChatTargetDictionary() { }

        /// <summary>
        /// 定义公有方法提供一个全局访问点,同时你也可以定义公有属性来提供全局访问点
        /// </summary>
        /// <returns></returns>
        public static Dictionary<string, MessageObjectDataDictionary> GetChatTargetDictionary()
        {
            // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
            // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
            // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
            // 双重锁定只需要一句判断就可以了
            if (chatTargetDictionary == null)
            {
                lock (looker)
                {
                    // 如果类的实例不存在则创建，否则直接返回
                    if (chatTargetDictionary == null)
                    {
                        chatTargetDictionary = new Dictionary<string, MessageObjectDataDictionary>();
                    }
                }
            }
            return chatTargetDictionary;
        }

        public static MessageObjectDataDictionary GetMsgData(string userId)
        {
            GetChatTargetDictionary();

            if (!chatTargetDictionary.ContainsKey(userId))
            {
                chatTargetDictionary.Add(userId, new MessageObjectDataDictionary());
            }
            return chatTargetDictionary[userId];
        }

        public static void RemoveItem(string userId)
        {
            if (!string.IsNullOrEmpty(userId) && chatTargetDictionary.ContainsKey(userId))
                chatTargetDictionary.Remove(userId);
        }
    }
}
