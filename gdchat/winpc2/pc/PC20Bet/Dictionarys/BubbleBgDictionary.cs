using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Dictionarys
{
    public class BubbleBgDictionary
    {
        private static Dictionary<string, Image> _bubbleBgDictionary;
        /// <summary>
        /// 储存栈
        /// </summary>
        private static Dictionary<string, Image> bubbleBgDictionary
        {
            get
            {
                if (_bubbleBgDictionary == null)
                    return GetBubbleBgDictionary();
                else return _bubbleBgDictionary;
            }
            set => _bubbleBgDictionary = value;
        }
        private static readonly object looker = new object();       //确保线程的同步，同一时间不能同时访问

        private BubbleBgDictionary() { }

        /// <summary>
        /// string: width_height
        /// </summary>
        /// <returns></returns>
        public static Dictionary<string, Image> GetBubbleBgDictionary()
        {
            // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
            // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
            // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
            // 双重锁定只需要一句判断就可以了
            if (_bubbleBgDictionary == null)
            {
                lock (looker)
                {
                    // 如果类的实例不存在则创建，否则直接返回
                    if (_bubbleBgDictionary == null)
                    {
                        _bubbleBgDictionary = new Dictionary<string, Image>();
                    }
                }
            }
            return _bubbleBgDictionary;
        }

        public static Image GetBackground(int width, int height, bool isOneself)
        {
            string key = string.Format(@"{0}_{1}_{2}", width, height, isOneself);
            if (bubbleBgDictionary.ContainsKey(key))
                return BitmapUtils.IsNull(bubbleBgDictionary[key]) ? null : bubbleBgDictionary[key];
            return null;
        }

        public static Image GetBackground(string key)
        {
            if (bubbleBgDictionary.ContainsKey(key))
                return BitmapUtils.IsNull(bubbleBgDictionary[key]) ? null : bubbleBgDictionary[key];
            return null;
        }

        public static void AddBackground(int width, int height, bool isOneself, Image image)
        {
            string key = string.Format(@"{0}_{1}_{2}", width, height, isOneself);
            if (!bubbleBgDictionary.ContainsKey(key))
                bubbleBgDictionary.Add(key, image);
        }

        public static void AddBackground(string key, Image image)
        {
            if (!bubbleBgDictionary.ContainsKey(key))
                bubbleBgDictionary.Add(key, image);
            else
                bubbleBgDictionary[key] = image;
        }

        public static void RemoveAllBg()
        {
            bubbleBgDictionary = new Dictionary<string, Image>();
        }
    }
}
