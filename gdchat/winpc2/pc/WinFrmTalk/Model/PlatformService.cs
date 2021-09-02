using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk
{

    /// <summary>
    /// 平台服务管理
    /// </summary>
    public class PlatformService
    {
        /// <summary>
        /// 单例对象
        /// </summary>
        private static PlatformService instance = null;

        /// <summary>
        /// 平台集合
        /// </summary>
        public Dictionary<string, Platform> PlatformList { get; set; }

        #region Public Methods

        /// <summary>
        /// 单例获取
        /// </summary>
        /// <returns></returns>
        public static PlatformService GetInstance()
        {
            if (instance == null)
            {
                instance = new PlatformService();
            }
            return instance;
        }

        /// <summary>
        /// 根据平台名称获取平台对象
        /// </summary>
        /// <param name="platFormName">平台名称</param>
        /// <returns></returns>
        public Platform GetPlatformByName(string platFormName)
        {
            try
            {
                var item = PlatformList[platFormName];
                return item;//直接返回
            }
            catch (System.Exception ex)
            {
                ConsoleLog.Output("PlatFormService.GetPlatformByName" + ex.Message);
                return null;
            }
        }

        /// <summary>
        /// 创建新的平台
        /// </summary>
        /// <param name="platformName">平台名称</param>
        /// <param name=""></param>
        /// <returns></returns>
        public Platform CreateNewPlatform(string platformName, PlatformTimer timer = null)
        {
            var plat = new Platform();
            plat.IsOnline = false;
            plat.IsSendRecipt = true;
            plat.PlatformName = platformName.ToLower();
            if (timer != null)
            {
                plat.Timer = timer;
            }
            PlatformList.Add(plat.PlatformName, plat);//添加到集合
            return plat;
        }

        /// <summary>
        /// 更新平台在线状态
        /// </summary>
        /// <param name="platformname">平台名称</param>
        /// <param name="isOnline">是否在线</param>
        public void UpdatePlatformOnlineStatus(string platformname, bool isOnline = false)
        {
            var tmpPlat = GetPlatformByName(platformname);
            if (tmpPlat != null)
            {
                tmpPlat.IsOnline = isOnline;
                if (isOnline)
                {
                    tmpPlat.Timer.Stop();
                    tmpPlat.Timer.Start();//重新循环发送200消息
                }
                else
                {
                    tmpPlat.Timer.Stop();//停止
                }
                tmpPlat.IsSendRecipt = true;//已经发送回执
            }
        }


        #endregion

        #region Contructor
        private PlatformService()
        {
            PlatformList = new Dictionary<string, Platform>();
        }
        #endregion


    }
}
