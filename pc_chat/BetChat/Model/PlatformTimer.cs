using System.Timers;


namespace WinFrmTalk
{
    public class PlatformTimer : Timer
    {

        /// <summary>
        /// 平台名称
        /// </summary>
        public string PlatformName { get; set; }


        #region Contructor
        public PlatformTimer() : base()
        {
            this.AutoReset = true;
        }


        public PlatformTimer(double interval) : base(interval)
        {

        }
        #endregion

    }
}
