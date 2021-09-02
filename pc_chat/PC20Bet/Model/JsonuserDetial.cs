using WinFrmTalk.Model;

namespace WinFrmTalk
{
    #region 用户详细信息
    /// <summary>
    /// 用户详细信息  
    /// </summary>
    public class DataOfUserDetial
    {

        #region 初始化引用类型
        public DataOfUserDetial()
        {
            settings = new SettingsOfDetial();
        }
        #endregion


        /// <summary>
        /// 用户的UserId
        /// </summary>
        public string userId { get; set; }

        /// <summary>
        /// 区号
        /// </summary>
        public string areaCode { get; set; }

        /// <summary>
        /// 当前登录账号的电话
        /// </summary>
        public string Telephone { get; set; }

        /// <summary>
        /// 余额
        /// </summary>
        public double balance { get; set; }

      
        /// <summary>
        /// 昵称
        /// </summary>
        public string nickname { get; set; }

        /// <summary>
        /// 明文密码
        /// </summary>
        public string password { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public SettingsOfDetial settings { get; set; }


        /// <summary>
        /// 
        /// </summary>
        public string userKey { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int userType { get; set; }

        /// <summary>
        /// 是否开启消息加密 端到端加密版本此字段失效
        /// </summary>
        public int isEncrypt { get; set; }

        /// <summary>
        /// 是否发送正在输入消息
        /// </summary>
        public bool sendInput { get; set; }


        //最后离线时间2019-9-17 16:06:09
        public long OfflineTime { get; set; }


        public string dhPublicKey { get; set; }

        public string dhPrivateKey { get; set; }

        public string rsaPublicKey { get; set; }

        public string rsaPrivateKey { get; set; }
    }
    #endregion

    #region SettingsOfDetial
    /// <summary>
    /// 用户的设置
    /// </summary>
    public class SettingsOfDetial
    {
        /// <summary>
        /// 
        /// </summary>
        public int allowAtt { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int allowGreet { get; set; }

        /// <summary>
        /// 是否需要好友验证
        /// </summary>
        public int friendsVerify { get; set; }
    }
    #endregion

    #region LocOfDetial
    /// <summary>
    /// LocOfDetial
    /// </summary>
    public class LocOfDetial
    {
        /// <summary>
        /// 
        /// </summary>
        public string lat { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string lng { get; set; }

    }
    #endregion

    #region LoginLogOfDetial
    /// <summary>
    /// LoginLogOfDetial
    /// </summary>
    public class LoginLogOfDetial
    {
        /// <summary>
        /// 
        /// </summary>
        public int isFirstLogin { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string latitude { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int loginTime { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string longitude { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int offlineTime { get; set; }
    }
    #endregion
}
