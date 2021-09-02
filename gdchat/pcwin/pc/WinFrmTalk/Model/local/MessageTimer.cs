using System.Timers;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    /// <summary>
    /// 重发消息专用Timer
    /// </summary>
    public class MessageTimer : Timer
    {
        #region 无参构造函数
        /// <summary>
        /// 无参构造函数
        /// </summary>
        public MessageTimer() : base()
        {
            this.Interval = 2000;//默认为20秒发送时间
            ReSendCount = 0;
        }
        #endregion

        #region 构造函数
        /// <summary>
        /// 可以设置Interval的构造函数
        /// </summary>
        public MessageTimer(double interval) : base(interval)
        {
            ReSendCount = 0;
        }
        #endregion

        /// <summary>
        /// Xmpp消息
        /// </summary>
        public MessageObject TmpMsg { get; set; }

        /// <summary>
        /// 对应的MessageId
        /// </summary>
        public string MessageId { get; set; } = "";

        /// <summary>
        /// 重发次数
        /// </summary>
        public int ReSendCount { get; set; }

    }
}
