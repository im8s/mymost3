using System.ComponentModel.DataAnnotations;

namespace WinFrmTalk
{

    public class UserSettings
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
        /// 
        /// </summary>
        public string chatRecordTimeOut { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double chatSyncTimeLen { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int closeTelephoneFind { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int friendsVerify { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isEncrypt { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isTyping { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isUseGoogleMap { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isVibration { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int multipleDevices { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int openService { get; set; }
    }

    public class LoginInfo
    {
        /// <summary>
        /// 
        /// </summary>
        public int isFirstLogin { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double latitude { get; set; }
        /// <summary>
        /// 

        /// 
        /// </summary>
        public double longitude { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int offlineTime { get; set; }

        /// <summary>
        /// </summary>
        public int loginTime { get; set; }

    }

    public class UserInfo
    {
        /// <summary>
        /// 
        /// </summary>
        public long birthday { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public UserSettings settings { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int friendCount { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int offlineNoPushMsg { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int sex { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int multipleDevices { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public LoginInfo login { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string userId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string myInviteCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string access_token { get; set; }


        public string httpKey { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string nickname { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isupdate { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int expires_in { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int payPassword { get; set; }
    }
}
