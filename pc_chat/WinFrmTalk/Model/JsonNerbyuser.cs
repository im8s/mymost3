using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using WinFrmTalk.Model;

namespace WinFrmTalk
{

    /// <summary>
    /// 附近的人
    /// </summary>
    public class JsonNerbyuser : JsonBase
    {
        public JsonNerbyuser()
        {
            data = new List<DataOfRtnNerbyuser>();
        }

        /// <summary>
        /// 返回的用户列表
        /// </summary>
        public List<DataOfRtnNerbyuser> data { get; set; }
    }

    #region Data
    public class DataOfRtnNerbyuser
    {
        private bool isSendRequest;

        #region 构造函数实例化引用类型
        public DataOfRtnNerbyuser()
        {
            loginLog = new LoginLog();
            settings = new Settings();
            loc = new Loc();
        }
        #endregion
        [Key]
        public string id { get; set; }

        /// <summary>
        /// 是否已经发送好友验证请求
        /// </summary>
        [JsonIgnore]
        public bool IsSendedRequest
        {
            get { return isSendRequest; }
            set
            {
                isSendRequest = value;
            }
        }


        /// <summary>
        /// 
        /// </summary>
        public int active { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string appId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string areaCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int areaId { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int attCount { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string balance { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public long birthday { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int cityId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string companyId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int countryId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public long createTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string description { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int fansCount { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int friendsCount { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string idcard { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string idcardUrl { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isAuth { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isPasuse { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int level { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public Loc loc { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public LoginLog loginLog { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int modifyTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string name { get; set; }
        /// <summary>
        /// 测试大号
        /// </summary>
        public string nickname { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int num { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int offlineNoPushMsg { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int onlinestate { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string password { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string phone { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int provinceId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public Settings settings { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int sex { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int status { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string telephone { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string totalConsume { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string totalRecharge { get; set; }

        /// <summary>
        /// 
        /// </summary>
        private string _userId;

        public string userId
        {
            get { return _userId; }
            set { _userId = value; }
        }



        /// <summary>
        /// 
        /// </summary>
        public string userKey { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int userType { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int vip { get; set; }



        #region 转为Friend
        /// <summary>
        /// 转为Friend
        /// </summary>
        /// <returns></returns>
        public Friend ToFriend()
        {
            var tmp = new Friend
            {
                UserId = this.userId,
                NickName = this.nickname,
            };
            return tmp;
        }
        #endregion

    }
    #endregion


    #region 设置
    public class Settings
    {
        /// <summary>
        /// 允许关注
        /// </summary>
        public int allowAtt { get; set; }

        /// <summary>
        /// 允许打招呼
        /// </summary>
        public int allowGreet { get; set; }

        /// <summary>
        /// 加好友需验证
        /// </summary>
        public int friendsVerify { get; set; }

        /// <summary>
        /// 是否开启客服模式
        /// </summary>
        public int openService { get; set; }

    }
    #endregion

    #region Loc
    public class Loc
    {
        /// <summary>
        /// 
        /// </summary>
        public double lat { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double lng { get; set; }
    }
    #endregion

    #region LoginLog
    public class LoginLog
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
        public long loginTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string longitude { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int offlineTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string serial { get; set; }
    }
    #endregion

}
