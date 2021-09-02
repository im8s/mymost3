using System;
using System.Collections.Generic;
using System.Configuration;
using System.Drawing;
using System.IO;
using System.Management;
using System.Windows.Forms;
using System.Windows.Media.Imaging;
using WinFrmTalk;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;

using SqlSugar;


namespace WinFrmTalk
{
    public static class Applicate
    {
        #region 固定配置变量
        // 服务器地址
       	//public const string APP_CONFIG = "http://im.ouchcloud.com:9000/config";
        public const string APP_CONFIG = "http://66.232.11.213:6092/config";
        // API_KEY值         
        public const string API_KEY = "";//a891a7a6-03af-475c-8ae1-7fb4b230e958

        // 软件版本号
        public const string APP_VERSION = "1.0.0";

        // 是否能切换服务器
        public const bool ToggleService = false;

        // 默认字体样式
        public const string SetFont = "微软雅黑";

        // 能否导出聊天记录
        public const bool IsInputChatList = true;

        // 判断是否已经打开音视频拨打界面或者接听界面
        public static bool IsOpenFrom = true;

        // 是否音视频版本包
        public const bool ENABLE_MEET = false;

        // 当前.net版本
        public const float CURRET_VERSION = 4.0f;

        // 是否客服模式
        public static bool ServiceMode = true;

        // 是否开启端到端加密 
        public const bool ENABLE_ASY_ENCRYPT = false;

        // 是否开启自动加群
        public const bool ENABLE_AUTO_JOINROOM = true;

        // 是否开启红包
        public const bool ENABLE_RED_PACKAGE = true;

        // 默认拉起漫游初始时间 秒
        public const long DEF_START_TIME = 1546315200;

        //刚刚登录时不接收修改密码通知，10秒后再接收通知(每次注册第一次登录，都会推送这个异常消息)
        public static bool MODIFY_PASSWORD_NOTIFY = false;
        #endregion

        #region 运行时缓存变量 

        private static JsonConfigData _URLDATA = new JsonConfigData();
        private static string access_Token;
        private static DataOfUserDetial myAccount = new DataOfUserDetial();

        /// <summary>
        /// URL对象
        /// </summary>
        public static JsonConfigData URLDATA
        {
            get { return _URLDATA; }
            set { _URLDATA = value; }
        }

        /// <summary>
        /// 应用程序接口访问令牌
        /// </summary>
        public static string Access_Token
        {
            get { return access_Token; }
            set { access_Token = value; }
        }

        /// <summary>
        /// 登陆后服务器返回的httpkey 用于接口验参
        /// </summary>
        public static string HTTP_KEY { get; set; }

        /// <summary>
        /// 当前的用户
        /// </summary>
        public static DataOfUserDetial MyAccount
        {
            get { return myAccount; }
            set { myAccount = value; }
        }


        private static Dictionary<string, string> _fdNames = new Dictionary<string, string>();

        /// <summary>
        /// 只记录好友的备注名
        /// key: userId, value: userName
        /// </summary>
        public static Dictionary<string, string> FdNames
        {
            get
            {
                if (_fdNames.Count < 1)
                {
                    var list = new Friend().GetAllFriends();
                    foreach (Friend fd in list)
                        _fdNames.Add(fd.UserId, string.IsNullOrWhiteSpace(fd.RemarkName) ? "" : fd.RemarkName);
                }

                return _fdNames;
            }
        }

        /// <summary>
        /// 默认的文本字体格式
        /// </summary>
        public static Font myFont = new Font(Applicate.SetFont, 10F);

        /// <summary>
        /// 用户是否通过密码验证
        /// true时Xmpp断线会重连
        /// false时Xmpp不会重连
        /// </summary>
        public static bool IsAccountVerified { get; set; }
        #endregion

        #region 登录后初始化账号数据
        /// <summary>
        /// 完成登录初始化账号数据，初始化并连接Xmpp
        /// <para> lzq-3.12 </para>
        /// </summary>
        /// <param name="item"></param>
        public static void InitAccountData(UserInfo user, string phone, string pwd, bool formLogin)
        {
            Applicate.Access_Token = user.access_token; //设置APIToken
            Applicate.IsAccountVerified = true; //记录为已登录
            Applicate.HTTP_KEY = user.httpKey;
            Applicate.MyAccount = new DataOfUserDetial()
            {
                userId = user.userId,
                nickname = user.nickname,
                Telephone = phone,
                password = pwd
            }; //赋值全局变量

            if (formLogin)
            {
                // 清除当前用户头像缓存，防止其他端修改pc不刷新问题
                ImageLoader.Instance.RefreshAvatar(Applicate.MyAccount.userId);
            }

            // 初始化用户设置 
            InitUserSetting(user.settings);

            // 设置最后离线时间
            CorrectOfflineTime(user.login);
        }

        /// <summary>
        ///  初始化用户设置
        /// </summary>
        public static void InitUserSetting(UserSettings settings)
        {
            // 是否开启多点登录
            MultiDeviceManager.Instance.IsEnable = settings.multipleDevices == 1;
            if (myAccount != null)
            {
                myAccount.isEncrypt = settings.isEncrypt;
                myAccount.sendInput = false;
            }
        }

        /// <summary>
        /// 设置离线时间，用于解决其他端查看了消息，PC还认为没有查看
        /// </summary>
        private static void CorrectOfflineTime(LoginInfo loginInfo)
        {
            string quitTime = LocalDataUtils.GetStringData(Applicate.QUIT_TIME);
            if (UIUtils.IsNull(quitTime))
            {
                if (loginInfo == null || loginInfo.offlineTime == 0)
                {
                    Applicate.MyAccount.OfflineTime = 1546315200;
                }
                else
                {
                    Applicate.MyAccount.OfflineTime = loginInfo.offlineTime;
                }
            }
            else
            {
                if (loginInfo == null || loginInfo.offlineTime == 0)
                {
                    Applicate.MyAccount.OfflineTime = Convert.ToInt64(quitTime) - 5;
                }
                else
                {
                    Applicate.MyAccount.OfflineTime = Math.Max(Convert.ToInt64(quitTime), loginInfo.offlineTime);
                }

            }
        }

        /// <summary>
        /// 用户离线key
        /// </summary>
        public static string QUIT_TIME
        {
            get { return "QUIT_TIME_" + MyAccount.userId; }
        }
        #endregion

        #region 本地化路径配置
        /// <summary>
        /// 本地配置数据(包括下载路径,头像地址)
        /// </summary>
        public static LocalConfig LocalConfigData { get; set; } =
            new LocalConfig
            {
                EmojiFolderPath = Environment.CurrentDirectory + "\\Res\\Emoji\\",
                GifFolderPath = Environment.CurrentDirectory + "\\Res\\Gif\\",
                VideoFolderPath = Environment.CurrentDirectory + "\\Downloads\\ShikuIM\\Audio\\",
                LocationFolderPath = Environment.CurrentDirectory + "\\Downloads\\ShikuIM\\Location\\",
                ImageFolderPath = Environment.CurrentDirectory + "\\Downloads\\ShikuIM\\Image\\",
                VoiceFolderPath = Environment.CurrentDirectory + "\\Downloads\\ShikuIM\\voice\\",
                FileFolderPath = Environment.CurrentDirectory + "\\Downloads\\ShikuIM\\File\\",
                CatchPath = Environment.CurrentDirectory + "\\Downloads\\ShikuIM\\",
                TempFilepath = Environment.CurrentDirectory + "\\Downloads\\ShikuIM\\temp\\",
                ChatDownloadPath = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile) +
                                   "\\Downloads\\ShikuIM" + "\\",
                ChatPath = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile) + "\\Downloads\\ShikuIM\\" +
                           "Chat" + "\\",

                UserAvatorFolderPath = Environment.CurrentDirectory + "\\Downloads\\ShikuIM" + "\\" + "avator" + "\\",
                //UserAvatorFolderPath = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile) + "\\Downloads\\ShikuIM" + "\\" + "avator" + "\\",
                MessageDatabasePath = Environment.CurrentDirectory + "\\db\\" + Applicate.MyAccount.userId + ".db",
                ConstantDatabasePath = Environment.CurrentDirectory + "\\db\\constant.db",
                CacheFolderPath = Environment.CurrentDirectory + "\\Downloads\\ShikuIM\\cache\\",
                RoomFileFolderPath = Environment.CurrentDirectory + "\\Downloads\\ShikuIM\\roomFile\\"
            };

        /// <summary>
        /// 二维码基础Url
        /// </summary>
        public static string QRCodeBase { get; }
            = "http://shiku.co/im-download.html?action=group&amp;shikuId=";

        /// <summary>
        /// 百度地图Url
        /// </summary>
        public static string MapApiUrl { get; } = "http://api.map.baidu.com/marker?";

        #endregion

        #region 本地化路径配置
        public static ConfigData GetDefConfig()
        {
            ConfigData data = new ConfigData();
            
            return data;
        }

        #endregion

        #region 获取已打开的窗口

        /// <summary>
        /// 获取已打开的窗口
        /// </summary>
        /// <typeparam name="T">窗口对象</typeparam>
        /// <returns></returns>
        public static T GetWindow<T>()
        {
            //T form = default(T);
            try
            {
                foreach (var tmpform in Application.OpenForms)
                {
                    if (tmpform is T)
                    {
                        return (T)tmpform;
                    }
                }
            }
            catch (Exception ex)
            {
                LogUtils.Log("Get form error =========++++=+=+=+=+=+=+=+===" + ex.Message);
            }

            return default(T);
        }
        #endregion

        #region 判断当前对象是否正在聊天
        /// <summary>
        /// 判断当前对象是否正在聊天
        /// </summary>
        /// <returns></returns>
        public static bool IsChatFriend(string userId)
        {
            Dictionary<string, MessageObjectDataDictionary> data = ChatTargetDictionary.GetChatTargetDictionary();
            return data.ContainsKey(userId);
        }

        #endregion

        #region liuhuan 2019/5/31 防止多次点击同一个窗体的变量
        public static bool isopen = true;
        public static List<string> userlst = new List<string>();//群管理用
        public static List<string> tipsuseridlst = new List<string>();
        public static bool Tipsisopen = true;//群公告
        public static List<string> Filesuseridlst = new List<string>();//群文件
        public static bool Fileisopen = true;//
        public static List<string> Membersuseridlst = new List<string>();//群成员
        public static bool Memberisopen = true;//群成员 
        public static bool imageisopen = true;//图片查看
        public static List<string> imagelist = new List<string>();//图片集合
        #endregion

        #region
        /// <summary>
        /// 过滤消息中的图标符号，替换成"[表情]"，防止出现空白的问题
        /// </summary>
        /// <param name="content"></param>
        /// <returns></returns>
        public static string getFilterContent(string content)
        {
            if (isSystemWin10)
            {
                return content;
            }

            //如果是其他的系统版本，就直接替换掉
            char[] contentArr = content.ToCharArray();
            for (int i = 0; i < contentArr.Length; i++)
            {
                int t = (int)contentArr[i];
                if (!(t >= 0 && t < 128)
                    && !(contentArr[i] >= 0x4e00 && contentArr[i] <= 0x9fbb)
                    && !(contentArr[i] == 0x3002)
                    && !(contentArr[i] == 0xFF1F)
                    && !(contentArr[i] == 0xFF01)
                    && !(contentArr[i] == 0xFF0C)
                    && !(contentArr[i] == 0xFF1B)
                    && !(contentArr[i] == 0xFF1A)
                    && !(contentArr[i] == 0x300C)
                    && !(contentArr[i] == 0x300D)
                    && !(contentArr[i] == 0x300E)
                    && !(contentArr[i] == 0x300F)
                    && !(contentArr[i] == 0x2018)
                    && !(contentArr[i] == 0x2019)
                    && !(contentArr[i] == 0x201C)
                    && !(contentArr[i] == 0x201D)
                    && !(contentArr[i] == 0xFF08)
                    && !(contentArr[i] == 0x3014)
                    && !(contentArr[i] == 0x3015)
                    && !(contentArr[i] == 0x3010)
                    && !(contentArr[i] == 0x3011)
                    && !(contentArr[i] == 0x2014)
                    && !(contentArr[i] == 0x2026)
                    && !(contentArr[i] == 0x2013)
                    && !(contentArr[i] == 0xFF0E)
                    && !(contentArr[i] == 0x300A)
                    && !(contentArr[i] == 0x300B)
                    && !(contentArr[i] == 0x3008)
                    && !(contentArr[i] == 0x3009))
                {
                    contentArr[i] = '$';
                }
            }
            string contents = new string(contentArr);
            if (contents.Contains("$"))
            {
                contents = contents.Replace("$", "");
                contents += "[表情]";
            }
            return contents;
        }

        public static bool isSystemWin10 = false;

        public static void initSystemVersion()
        {
            using (ManagementObjectSearcher win32OperatingSystem = new ManagementObjectSearcher("select * from Win32_OperatingSystem"))
            {
                foreach (ManagementObject obj in win32OperatingSystem.Get())
                {
                    string Version = obj["Version"].ToString();
                    string Caption = obj["Caption"].ToString();
                    if (Version.Contains("10") && Caption.Contains("10"))
                    {
                        isSystemWin10 = true;
                    }
                    break;
                }
            }
        }

        #endregion
    }
}

