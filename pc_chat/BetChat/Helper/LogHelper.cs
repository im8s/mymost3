using log4net;

[assembly: log4net.Config.XmlConfigurator(Watch = true)]
namespace WinFrmTalk
{
    public static class LogHelper
    {
        public static ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        #region 记录异常
        /// <summary>
        /// 记录异常
        /// </summary>
        /// <param name="message"></param>
        /// <param name="stackTrace"></param>
        public static void LogException(string message, string stackTrace)
        {
            log.Debug(string.Format("Exception occured: {0}, stack trace: {1}", message, stackTrace));
        }
        #endregion

        #region 记录日志
        /// <summary>
        /// 记录日志
        /// </summary>
        /// <param name="info"></param>
        public static void LogInfo(string info)
        {
            log.Info(info);
        }
        #endregion

    }
}