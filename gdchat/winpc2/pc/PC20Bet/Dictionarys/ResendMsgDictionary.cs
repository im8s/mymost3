using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk.Model;

namespace WinFrmTalk.Dictionarys
{
    public class ResendMsgDictionary
    {
        private static Dictionary<string, MessageObject> ResendMsgData;       //储存栈
        private static readonly object looker = new object();       //确保线程的同步，同一时间不能同时访问

        //防止外部创建实例
        private ResendMsgDictionary() { }

        /// <summary>
        /// 通过key获取message，包括非空判断
        /// </summary>
        /// <param name="msgId"></param>
        /// <returns>没有值则返回新的对象</returns>
        public static MessageObject GetResendMsg(string msgId)
        {
            GetResendMsgData();
            if (ResendMsgData.ContainsKey(msgId))
                return ResendMsgData[msgId];
            else
                return null;
        }

        /// <summary>
        /// 在重发列表中移除该信息
        /// </summary>
        /// <param name="msgId"></param>
        public static void RemoveReSendMsg(string msgId)
        {
            if (ResendMsgData.ContainsKey(msgId))
                ResendMsgData.Remove(msgId);
        }

        /// <summary>
        /// 定义公有方法提供一个全局访问点,同时你也可以定义公有属性来提供全局访问点
        /// </summary>
        /// <returns></returns>
        public static Dictionary<string, MessageObject> GetResendMsgData()
        {
            // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
            // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
            // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
            // 双重锁定只需要一句判断就可以了
            if (ResendMsgData == null)
            {
                lock (looker)
                {
                    // 如果类的实例不存在则创建，否则直接返回
                    if (ResendMsgData == null)
                    {
                        ResendMsgData = new Dictionary<string, MessageObject>();
                    }
                }
            }
            return ResendMsgData;
        }
    }
}
