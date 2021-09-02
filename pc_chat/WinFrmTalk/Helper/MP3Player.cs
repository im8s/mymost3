using System.Runtime.InteropServices;

namespace WinFrmTalk.Helper
{
    public class MP3Player
    {
        //// 定义一个静态变量来保存类的实例
        //private static MP3Player myPlayer;

        //private MP3Player() { }

        //public static MP3Player GetMP3Player()
        //{
        //    if (myPlayer == null)
        //    {
        //        // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
        //        // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
        //        // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
        //        // 双重锁定只需要一句判断就可以了
        //        lock (Connection)
        //        {
        //            // 如果类的实例不存在则创建，否则直接返回
        //            if (myPlayer == null)
        //            {
        //                myPlayer = new MP3Player();
        //            }
        //        }
        //    }

        //    return myPlayer;
        //}

        /// <summary>   
        /// 文件地址   
        /// </summary>   
        public string FilePath;

        /// <summary>   
        /// 播放   
        /// </summary>   
        public void Play()
        {
            mciSendString("close all", "", 0, 0);
            mciSendString("open " + FilePath + " alias media", "", 0, 0);
            mciSendString("play media", "", 0, 0);
        }

        /// <summary>   
        /// 暂停   
        /// </summary>   
        public void Pause()
        {
            mciSendString("pause media", "", 0, 0);
        }

        /// <summary>   
        /// 停止   
        /// </summary>   
        public void Stop()
        {
            mciSendString("close media", "", 0, 0);
        }

        /// <summary>   
        /// API函数   
        /// </summary>   
        [DllImport("winmm.dll", EntryPoint = "mciSendString", CharSet = CharSet.Auto)]
        private static extern int mciSendString(
         string lpstrCommand,
         string lpstrReturnString,
         int uReturnLength,
         int hwndCallback
        );
    }

}

