using System.Collections.Generic;
using WinFrmTalk;

namespace WinFrmTalk.Dictionarys
{
    internal class MessageModelDataDictionary
    {
        private static Dictionary<int, MessageModel> messageModelData;       //储存栈
        private static readonly object looker = new object();       //确保线程的同步，同一时间不能同时访问

        //防止外部创建实例
        private MessageModelDataDictionary() { }

        /// <summary>
        /// 定义公有方法提供一个全局访问点,同时你也可以定义公有属性来提供全局访问点
        /// </summary>
        /// <returns></returns>
        public static Dictionary<int, MessageModel> GetMessageModelDataDictionary()
        {
            // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
            // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
            // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
            // 双重锁定只需要一句判断就可以了
            if (messageModelData == null)
            {
                lock (looker)
                {
                    // 如果类的实例不存在则创建，否则直接返回
                    if (messageModelData == null)
                    {
                        messageModelData = new Dictionary<int, MessageModel>();
                    }
                }
            }
            return messageModelData;
        }
    }
}
