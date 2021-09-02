using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.Dictionarys
{
    internal  class EnjoyCodeColor
    {
        private static Dictionary<string, string> emojiDataNotMine ;   //储存栈
        private static Dictionary<string, string> emojiDataIsMine;  //储存栈
        private static readonly object looker = new object();       //确保线程的同步，同一时间不能同时访问

        //防止外部创建实例
        private EnjoyCodeColor() { }

        //public static string GetEmojiCode(string emoji_rtf)
        //{
        //    GetEmojiCodeDataDictionary();
        //    if (emojiDataNotMine.ContainsKey(emoji_rtf))
        //        return emojiDataNotMine[emoji_rtf];
        //    else
        //        return "";
        //}

        public static string GetEmojiRtfByCode(string emojiCode,Color color)
        {
            //去除中括号
            emojiCode = emojiCode.Replace("[", "").Replace("]", "");
            //初始化字典
            GetEmojiDataNotMine(color);
            GetEmojiDataIsMine(color);

            string emojiRtf = "";
         
                if (emojiDataIsMine.ContainsKey(emojiCode))
                {
                    emojiRtf = emojiDataIsMine[emojiCode];
                    if (string.IsNullOrEmpty(emojiRtf))
                    {
                        string path = Applicate.LocalConfigData.EmojiFolderPath + emojiCode + ".png";
                        //添加白色底色的emoji
                        emojiRtf = GetRtfByImgPath(path, color);
                        //添加到字典
                        emojiDataIsMine[emojiCode] = emojiRtf;
                    }
                }
           
            return emojiRtf;
            
        }

        /// <summary>
        /// 定义公有方法提供一个全局访问点,同时你也可以定义公有属性来提供全局访问点
        /// </summary>
        /// <returns></returns>
        public static Dictionary<string, string> GetEmojiDataNotMine( Color color)
        {
            
            // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
            // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
            // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
            // 双重锁定只需要一句判断就可以了
            if (emojiDataNotMine == null)
            {
                lock (looker)
                {
                    // 如果类的实例不存在则创建，否则直接返回
                    if (emojiDataNotMine == null)
                    {
                        emojiDataNotMine = new Dictionary<string, string>();
                    }
                }
            }
          
            if (emojiDataNotMine.Count < 1)
                AddEmojiData(color);
            return emojiDataNotMine;
        }

        /// <summary>
        /// 定义公有方法提供一个全局访问点,同时你也可以定义公有属性来提供全局访问点
        /// </summary>
        /// <returns></returns>
        public static Dictionary<string, string> GetEmojiDataIsMine( Color color)
        {
           
            // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
            // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
            // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
            // 双重锁定只需要一句判断就可以了
            if (emojiDataIsMine == null)
            {
                lock (looker)
                {
                    // 如果类的实例不存在则创建，否则直接返回
                    if (emojiDataIsMine == null)
                    {
                        emojiDataIsMine = new Dictionary<string, string>();
                    }
                }
            }
            if (emojiDataIsMine.Count < 1)
                AddEmojiData(color);
            return emojiDataIsMine;
        }

        private static void AddEmojiData(Color color)
        {
            emojiDataNotMine = new Dictionary<string, string>();
            emojiDataIsMine = new Dictionary<string, string>();

            //获取所有emoji表情路径
            string[] emojiPaths = System.IO.Directory.GetFiles(Applicate.LocalConfigData.EmojiFolderPath, "*.png");

            foreach (string path in emojiPaths)
            {
                //获得emojiCode
                string emojiCode = FileUtils.GetFileName(path).Replace(".png", "");
                //添加白色底色的emoji
                string emojiRtf = GetRtfByImgPath(path, color);
                //添加到字典
                emojiDataNotMine.Add(emojiCode, emojiRtf);

                //添加绿色底色的emoji
                emojiRtf = GetRtfByImgPath(path, color);
                //添加到字典
                emojiDataIsMine.Add(emojiCode, emojiRtf);
            }
        }

        private static string subRtf(string emoji_rtf)
        {
            //rtf1–> RTF版本
            //ansi–> 字符集
            //ansicpg936–> 简体中文
            //deff0–> 默认字体0
            //deflang1033–> 美国英语
            //deflangfe2052–> 中国汉语
            //fonttb–> 字体列表
            //f0->字体0
            //fcharset134->GB2312国标码
            //‘cb\’ce\’cc\’e5–> 宋体
            int startIndex = emoji_rtf.IndexOf("\\viewkind4\\uc1\\pard\\lang2052\\f0\\fs18") + "\\viewkind4\\uc1\\pard\\lang2052\\f0\\fs18".Length;
            emoji_rtf = emoji_rtf.Substring(startIndex);
            int endIndex = emoji_rtf.IndexOf("\\par");
            emoji_rtf = emoji_rtf.Substring(0, endIndex);
            return emoji_rtf;
        }

        private static string GetRtfByImgPath(string path, Color color)
        {
            using (RichTextBox richTextBox = new RichTextBox())
            {
                //清空剪切板，防止里面之前有内容
                //Clipboard.Clear();
                Bitmap bmp = new Bitmap(path);
                Bitmap newBmp = new Bitmap(25, 25);
                Graphics g = Graphics.FromImage(newBmp);
                g.Clear(color);

                g.DrawImage(bmp, new Rectangle(0, 0, 25, 25), new Rectangle(0, 0, bmp.Width, bmp.Height), GraphicsUnit.Pixel);
                g.Dispose();
                Clipboard.SetDataObject(newBmp, false);
                //将图片粘贴到鼠标焦点位置(选中的字符都会被图片覆盖)
                richTextBox.Paste();
                //Clipboard.Clear();

                //获取emoji的rtf
                string emojiRtf = subRtf(richTextBox.Rtf);
                return emojiRtf;
            }
        }
    }
}
