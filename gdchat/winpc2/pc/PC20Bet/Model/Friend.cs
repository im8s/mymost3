using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using SqlSugar;
using System;
using System.Collections.Generic;

namespace WinFrmTalk.Model
{
    #region 朋友
    /// <summary>
    /// 接口返回的朋友
    /// </summary>
    public class JsonFriends : JsonBase
    {
        #region 构造函数
        public JsonFriends()
        {
            Data = new List<Friend>();
        }
        #endregion

        public List<Friend> Data { get; set; }
    }
    #endregion

    #region Friend
    /// <summary>
    /// Friend数据结构
    /// </summary>
    public class Friend
    {
        public const string ID_NEW_FRIEND = "10001";// 新朋友消息 ID
        public const string ID_BAN_LIST = "9999";// 黑名单列表
        public const string ID_SK_PAY = "1100";// 支付公众号，
        public const string ID_BLOG_MESSAGE = "10002";// 商务圈消息ID
        public const string ID_INTERVIEW_MESSAGE = "10004";// 面试中心ID（用于职位、初试、面试的推送）
        public const string ID_SYSTEM_NOTIFICATION = "10005";// 系统号，用于各种控制消息通知，
        public const string ID_SYSTEM = "10000";// 系统号，用于各种控制消息通知，

        #region Public Member

        /// <summary>
        /// 朋友id，如果是房间就是roomJid
        /// </summary>
        [SugarColumn(IsNullable = false, IsPrimaryKey = true, Length = 128)]
        public string UserId { get; set; }

        /// <summary>
        /// 好友创建时间戳
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int CreateTime { get; set; }

        /// <summary>
        /// 最后一次聊天时间戳
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public double LastMsgTime { get; set; }

        /// <summary>
        /// 未读消息数量
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int MsgNum { get; set; }

        internal void UpdateAttention()
        {
            if (CreateFriendTable())
            {
                DBSetting.SQLiteDBContext.Updateable<Friend>().UpdateColumns(it => new Friend()
                {
                    Status = this.Status,
                    NickName = this.NickName,
                    CreateTime = this.CreateTime,
                    RemarkName = this.RemarkName,
                    Sex = this.Sex,
                    //IsOpenReadDel = this.IsOpenReadDel, 服务器不行
                    //TopTime = this.TopTime,
                    //Nodisturb = this.Nodisturb,
                }).Where(it => it.UserId == this.UserId).ExecuteCommand();
            }
        }

        /// <summary>
        /// 与该好友的状态（-1:黑名单；0：陌生人；1:单方关注；2:互为好友；8:系统号；9:非显示系统号）
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int Status { get; set; }

        // -1:黑名单；0：陌生人；1:单方关注；2:互为好友；8:显示系统号；9:非显示系统号
        public const int STATUS_BLACKLIST = -1;// 黑名单
        public const int STATUS_UNKNOW = 0;// 陌生人(不可能出现在好友表，只可能在新朋友消息表)
        public const int STATUS_ATTENTION = 1;// 关注
        public const int STATUS_FRIEND = 2;// 好友
        public const int STATUS_SYSTEM = 8;// 显示系统号
        // 需要验证的
        public const int STATUS_10 = 10; //显示  等待验证
        public const int STATUS_11 = 11; //您好
        public const int STATUS_12 = 12; //已通过验证
        public const int STATUS_13 = 13; //验证被通过了
        public const int STATUS_14 = 14; //别人回话
        public const int STATUS_15 = 15; //回话
        public const int STATUS_16 = 16; //已删除了XXX
        public const int STATUS_17 = 17; //XXX删除了我
        public const int STATUS_18 = 18; //已拉黑了XXX
        public const int STATUS_19 = 19; //XXX拉黑了我
        public const int STATUS_20 = 20; //默认值什么都不显示
        // 不需要验证的
        public const int STATUS_21 = 21;//XXX 添加你为好友
        public const int STATUS_22 = 22;//你添加好友 XXX
        public const int STATUS_24 = 24;//XXX 已经取消了黑名单
        public const int STATUS_23 = 23;//对方把我加入了黑名单
        public const int STATUS_25 = 25;//通过手机联系人添加
        public const int STATUS_26 = 26;//被后台删除的好友，仅用于新的朋友页面显示，


        /// <summary>
        /// 好友昵称/名称
        /// <para>当对象为群时，该字段为群名称</para>
        /// </summary>

        [SugarColumn(IsNullable = true)]
        public string NickName { get; set; }

        /// <summary>
        ///通讯号
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string AccountId { get; set; }
        
        /// <summary>
        /// 消息免打扰
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int Nodisturb { get; set; }

        public string GetFriendInfoId()
        {
            if (!string.IsNullOrEmpty(AccountId))
            {
                return AccountId;
            }
            else
            {
                return UserId;
            }
        }

        /// <summary>
        /// 好友区号，例如86是中国
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string AreaCode { get; set; }

        /// <summary>
        /// 区id
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int AreaId { get; set; }

        /// <summary>
        /// 城市id
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int CityId { get; set; }

        /// <summary>
        /// 个人说明，个性签名
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string Description { get; set; }

        /// <summary>
        /// 省份id
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int ProvinceId { get; set; }

        /// <summary>
        /// 性别
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int Sex { get; set; }

        /// <summary>
        /// 手机号
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string Telephone { get; set; }

        /// <summary>
        /// 备注名
        /// <para>如果时单聊则为备注名，如果是群聊则为群名片</para>
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string RemarkName { get; set; }

        /// <summary>
        /// 最后一条聊天内容（用于处理是否在最近聊天列表中内容）
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string Content { get; set; }

        /// <summary>
        /// 是否群组
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int IsGroup { get; set; }

        /// <summary>
        /// 最后一条消息的类型
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int LastMsgType { get; set; }

        /// <summary>
        /// 房间的id
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string RoomId { get; set; }

        /// <summary>
        /// 最近输入( 未发送的草稿)
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string LastInput { get; set; }

        /// <summary>
        /// 好友身份身份  1=游客（⽤用于后台浏览数据）；2=公众号 ；3=机器账号，由系统⾃自动⽣生成；4=客服账号;5=管理员；6=超级管理员；7=财务； 
        /// </summary>
        [SugarColumn(IsNullable = true)]
        [JsonIgnore]
        public string Role { get; set; }

        /// <summary>
        ///  群组⾥里里⾯面是否有@我的消息 
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int IsAtMe { get; set; }

        /// <summary>
        /// 是否显示已读
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int ShowRead { get; set; }

        /// <summary>
        /// 是否显示群成员
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int ShowMember { get; set; }

        /// <summary>
        /// 允许普通群成员私聊
        /// 1 允许  0 不允许 2019年7月31日16:21:01
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int AllowSendCard { get; set; }

        /// <summary>
        /// 允许普通群成员邀请好友
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int AllowInviteFriend { get; set; }

        /// <summary>
        /// 允许普通群成员上传文件
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int AllowUploadFile { get; set; }

        /// <summary>
        /// 允许普通群成员召开会议
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int AllowConference { get; set; }

        /// <summary>
        /// 获取好友备注名，如果没有备注则显示昵称
        /// </summary>
        /// <returns></returns>
        internal string GetRemarkName()
        {
            if (string.IsNullOrEmpty(RemarkName))
            {
                return NickName;
            }

            return RemarkName;
        }


        /// <summary>
        /// 允许普通群成员发起讲课
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int AllowSpeakCourse { get; set; }


        /// <summary>
        /// 此群组是否开始阅后即焚
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int IsOpenReadDel { get; set; }

        /// <summary>
        /// 是否是设备（多点登录使用，辨识是我的设备还是用户）
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int UserType { get; set; }
        // 我的设备 == 1
        // 公众号 == 2
        // 黑名单&新的朋友 == 3

        /// <summary>
        /// 我的某一个设备是否在线（多点登录使用，标识我的某一个设备是否在线）
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int IsOnLine { get; set; }

        /// <summary>
        /// 是否要转发给此用户（多点登录使用，是否要转发消息给此用户（当前账号的其他设备））
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int IsSendRecipt { get; set; }

        /// <summary>
        /// 置顶时间
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int TopTime { get; set; }

        /// <summary>
        /// 是否开启群主验证
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int IsNeedVerify { get; set; }

        /// <summary>
        /// 出生如期
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public long Birthday { get; set; }

        /// <summary>
        /// 漫游的开始时间
        /// </summary>
        public double DownloadRoamStartTime { get; set; }

        /// <summary>
        /// 漫游的结束时间
        /// </summary>
        public double DownloadRoamEndTime { get; set; }

        /// <summary>
        /// 上次漫游离线消息的结束时间
        /// </summary>
        public double OfflineEndTime { get; set; }

        /// <summary>
        /// 群组是否已经解散
        /// </summary>
        public int IsDismiss { get; set; }

        /// <summary>
        /// 是否刚刚清除聊天记录
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int IsClearMsg { get; set; }
        #endregion

        #region Consturtor
        public Friend()
        {

        }
        #endregion

        #region 实现数据库操作的构造函数
        /// <summary>
        /// 有参构造函数
        /// </summary>
        /// <param name="ConnString">数据库连接字符串</param>
        public Friend(string ConnString)
        {
            //DBContext = new DBSetting.SQLiteDBContextContext(ConnString);
        }
        #endregion

        #region 创建数据库表
        /// <summary>
        /// 创建数据库表
        /// </summary>
        public bool CreateFriendTable()
        {
            try
            {
                var result = DBSetting.SQLiteDBContext.Queryable<sqlite_master>().Where(s => s.Name == "Friend" && s.Type == "table");
                if (result != null && result.Count() > 0)     //表存在
                {
                    return true;
                }
                //创建数据库表
                DBSetting.SQLiteDBContext.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(Friend));
                return true;
            }
            catch (Exception ex)
            {
                LogUtils.Log(ex.Message);
                return false;
            }
        }
        #endregion

        #region 分页获取好友
        /// <summary>
        /// 分页获取好友（按名字排序）
        /// </summary>
        /// <param name="pageIndex">0和1都是第一页</param>
        /// <param name="pageSize">一页多少条数据</param>
        /// <returns></returns>
        public List<Friend> GetByPage(int pageIndex = 0, int pageSize = 30)
        {
            if (CreateFriendTable())
            {
                List<Friend> Lists = DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.IsGroup == this.IsGroup).
                    OrderBy(it => it.NickName).ToPageList(pageIndex, pageSize);
                return Lists ?? new List<Friend>();
            }
            return new List<Friend>();
        }
        #endregion

        #region 插入到数据库
        /// <summary>
        /// 插入到数据库
        /// </summary>
        public bool InsertAuto()
        {
            if (CreateFriendTable())
            {
                var friend = DBSetting.SQLiteDBContext.Queryable<Friend>().Single(f => f.UserId == this.UserId);
                int result = 0;
                if (friend == null)
                {
                    result = DBSetting.SQLiteDBContext.Insertable(this).ExecuteCommand();
                }
                else
                {
                    result = DBSetting.SQLiteDBContext.Updateable(this).ExecuteCommand();//更新
                }
                return result > 0 ? true : false;
            }
            return false;
        }
        #endregion

        #region 判断是否存在朋友，没有就插入
        /// <summary>
        /// 插入到数据库
        /// </summary>
        public bool InsertRange(List<Friend> friends)
        {
            if (CreateFriendTable())
            {
                int result = 0;
                try
                {
                    if (!UIUtils.IsNull(friends))
                    {
                        result = DBSetting.SQLiteDBContext.Insertable(friends).ExecuteCommand();
                    }
                }
                catch (Exception)
                {
                    foreach (var item in friends)
                    {
                        item.InsertData();
                    }

                }

                return result > 0;
            }
            return false;

        }

        public bool InsertData()
        {
            if (CreateFriendTable())
            {
                int result = 0;
                if (!UIUtils.IsNull(this.UserId))
                {
                    try
                    {
                        result = DBSetting.SQLiteDBContext.Insertable(this).ExecuteCommand();
                    }
                    catch (Exception)
                    {
                        return false;
                    }
                }

                return result > 0;
            }

            return false;
        }

        public bool InsertNonFriend()
        {
            if (CreateFriendTable())
            {
                var friend = DBSetting.SQLiteDBContext.Queryable<Friend>().Single(f => f.UserId == this.UserId);
                int result = 0;
                if (friend == null)
                {
                    result = DBSetting.SQLiteDBContext.Insertable(this).ExecuteCommand();
                }
                return result > 0;
            }
            return false;
        }
        #endregion

        #region 更新到数据库
        /// <summary>
        /// 更新到数据库
        /// </summary>
        public int Update()
        {
            if (CreateFriendTable())
            {
                try
                {
                    //DBSetting.SQLiteDBContext.Updateable(this).ExecuteCommand();     //默认主键为筛选条件
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().Where(f => f.UserId == UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 更新好友关系
        /// <summary>
        /// 更新好友关系
        /// </summary>
        /// <param name="UserId">好友Id</param>
        /// <param name="state">状态
        /// <para>好友状态-2黑名单(对方拉黑我方) -1://黑名单(我方拉黑对方)；0：陌生人；1:单方关注；2:互为好友</para>
        /// </param>
        public void UpdateFriendState(string UserId, int state)
        {
            try
            {
                this.UserId = UserId;
                UpdateFriendState(state);
            }
            catch (Exception ex)
            {
                ConsoleLog.Output(ex.Message);
            }
        }
        #endregion

        #region 更新好友关系

        public int GetFriendState(string UserId)
        {
            if (CreateFriendTable())
            {
                var friend = DBSetting.SQLiteDBContext.Queryable<Friend>().Single(f => f.UserId == this.UserId);

                if (friend != null)
                {
                    return friend.Status;
                }
            }

            return 0;
        }
        #endregion

        #region 更新好友关系
        /// <summary>
        /// 更新好友关系
        /// <para>好友状态-2黑名单(对方拉黑我方) -1://黑名单(我方拉黑对方)；0：陌生人；1:单方关注；2:互为好友</para>
        /// </summary>
        /// <param name="UserId">好友Id</param>
        /// <param name="state">状态
        /// </param>
        public int UpdateFriendState(int state)
        {
            if (CreateFriendTable())
            {
                try
                {
                    this.Status = state;
                    //"Update Friend set status = " + state + " where userId=" + UserId;
                    return DBSetting.SQLiteDBContext.Updateable<Friend>()
                        .UpdateColumns(it => new Friend() { Status = state }).
                        Where(it => it.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 更新好友关系
        /// <summary>
        /// 和一个用户成为好友
        /// </summary>
        public int BecomeFriend(kWCMessageType type)
        {
            if (CreateFriendTable())
            {
                this.LastMsgType = (int)type;
                this.Status = Friend.STATUS_FRIEND;
                this.Content = "你们已经成为好友，快来聊天吧";
                this.LastMsgTime = TimeUtils.CurrentIntTime();
                this.MsgNum = 1;


                var friend = DBSetting.SQLiteDBContext.Queryable<Friend>().Single(f => f.UserId == this.UserId);

                if (friend != null)
                {
                    DBSetting.SQLiteDBContext.Updateable<Friend>()
                    .UpdateColumns(it => new Friend()
                    {
                        Status = this.Status,
                        Content = this.Content,
                        LastMsgTime = this.LastMsgTime,
                        MsgNum = this.MsgNum,
                        LastMsgType = this.LastMsgType
                    }).
                    Where(it => it.UserId == this.UserId).ExecuteCommand();

                    return 1;
                }
                else
                {
                    InsertAuto();
                }
            }
            return 0;
        }
        #endregion

        internal int UpdateOfflineTime()
        {
            if (CreateFriendTable())
            {
                try
                {
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().UpdateColumns(it => new Friend()
                    {
                        OfflineEndTime = this.OfflineEndTime
                    }).Where(it => it.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }


        internal int UpdateClearMessageState(int isClear)
        {
            if (CreateFriendTable())
            {
                try
                {
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().UpdateColumns(it => new Friend()
                    {
                        IsClearMsg = isClear,
                    }).Where(it => it.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        
        internal int UpdateDownTime(double startTime, double endTime)
        {
            if (CreateFriendTable())
            {
                try
                {
                    this.DownloadRoamStartTime = startTime;
                    this.DownloadRoamEndTime = endTime;

                    return DBSetting.SQLiteDBContext.Updateable<Friend>().UpdateColumns(it => new Friend()
                    {
                        DownloadRoamStartTime = startTime,
                        DownloadRoamEndTime = endTime,
                    }).Where(it => it.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }

            return 0;
        }

        #region 更新好友最后一条聊天内容
        /// <summary>
        /// 更新好友最后一条聊天内容
        /// </summary>
        /// <param name="UserId">好友Id</param>
        /// <param name="content">最后的聊天内容
        /// </param>
        public int UpdateFriendLastContent(string con, int type, double time)
        {
            if (CreateFriendTable())
            {
                try
                {
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().UpdateColumns(it => new Friend()
                    {
                        Content = con,
                        LastMsgTime = time,
                        LastMsgType = type

                    }).Where(it => it.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion
        
        public string ToLastContentTip(kWCMessageType type, string con, string from, string fromUserName, string toUserName)
        {
            switch (type)
            {
                case kWCMessageType.Withdraw:
                    if (Applicate.MyAccount.Equals(from))
                    {
                        return "你撤回了一条消息";
                    }
                    else
                    {
                        return fromUserName + "撤回了一条消息";
                    }
                case kWCMessageType.TYPE_83:
                    if (Applicate.MyAccount.Equals(from))
                    {
                        return "你领取了" + toUserName + "的红包";
                    }
                    else
                    {
                        return fromUserName + "领取了你的红包";
                    }
                case kWCMessageType.TYPE_TRANSFER_RECEIVE:
                    if (Applicate.MyAccount.Equals(from))
                    {
                        return "我已领取对方转账";
                    }
                    else
                    {
                        return "转账已被对方领取";
                    }
                case kWCMessageType.RoomNotice:

                    if (!UIUtils.IsNull(con))
                    {
                        con = con.Replace("\r\n", "");
                        con = con.Replace("\n", "");
                    }

                    return UIUtils.QuotationName(fromUserName) + "发布了新公告" + UIUtils.QuotationName(con);
                case kWCMessageType.RoomAdmin:

                    if (con == "0")//取消管理员
                    {
                        return fromUserName + "取消管理员" + toUserName;
                    }
                    else if (con == "1")//设置管理员8
                    {
                        return fromUserName + "设置:" + toUserName + "为管理员";
                    }
                    else
                    {
                        return con;
                    }
                default:
                    return ToLastContentTip(type, con);
            }
        }

        public string ToLastContentTip(kWCMessageType type, string con)
        {
            if (!UIUtils.IsNull(con))
            {
                con = con.Replace("\r\n", "");
                con = con.Replace("\n", "");
            }

            switch (type)
            {
                case kWCMessageType.CUSTOM_EMOT:
                case kWCMessageType.EMOT_PACKAGE:
                case kWCMessageType.Image:
                    return "[图片]";
                case kWCMessageType.Voice:
                    return "[语音]";
                case kWCMessageType.Location:
                    return "[位置]";
                case kWCMessageType.Gif:
                    return "[动画]";
                case kWCMessageType.Video:
                    return "[视频]";
                case kWCMessageType.Audio:
                    return "[视频]";
                case kWCMessageType.Card:
                    return "[名片]";
                case kWCMessageType.File:
                    return "[文件]";
                case kWCMessageType.RedPacket:
                    return "[红包]";
                case kWCMessageType.ImageTextSingle:
                    return "[单条图文]";
                case kWCMessageType.ImageTextMany:
                    return "[多条图文]";
                case kWCMessageType.Link:
                case kWCMessageType.SDKLink:
                    return "[链接]";
                case kWCMessageType.PokeMessage:
                    return "[戳一戳]";
                case kWCMessageType.History:
                    return "[聊天记录]";
                case kWCMessageType.AudioChatEnd:
                case kWCMessageType.VideoChatEnd:
                    return "[通话结束]";
                case kWCMessageType.VideoChatCancel:
                case kWCMessageType.AudioChatCancel:
                    return "[通话取消]";
                case kWCMessageType.RedBack:
                    return "红包已过期,余额已退回零钱";
                case kWCMessageType.TYPE_SECURE_LOST_KEY:
                    return "[请求群组通讯密钥]";
                default:
                    return con;
            }
        }

        #region 更新到数据库
        /// <summary>
        /// 更新到数据库
        /// </summary>
        public int UpdateDetial()
        {
            if (CreateFriendTable())
            {
                try
                {
                    //DBSetting.SQLiteDBContext.Updateable(this).ExecuteCommand();     //默认主键为筛选条件
                    return DBSetting.SQLiteDBContext.Updateable(this).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 转DataOfUserDetial
        //public DataOfUserDetial ToDataOfUserDetial()
        //{
        //    return new DataOfUserDetial()
        //    {
        //        active = this.active,
        //        areaCode = this.areaCode,
        //        areaId = this.areaId,
        //        attCount = this.attCount,
        //        balance = this.balance,
        //        birthday = this.birthday,
        //        cityId = this.cityId,
        //        companyId = this.companyId,
        //        countryId = this.countryId,
        //        createTime = this.createTime,
        //        description = this.description,
        //        fansCount = this.fansCount,
        //        friendsCount = this.friendsCount,
        //        idcard = this.idcard,
        //        idcardUrl = this.idcardUrl,
        //        isAuth = this.isAuth,
        //        level = this.level,
        //        modifyTime = this.modifyTime,
        //        name = this.name,
        //        nickname = this.toNickname,
        //        num = this.num,
        //        offlineNoPushMsg = this.offlineNoPushMsg,
        //        onlinestate = this.onlinestate,
        //        password = this.password,
        //        phone = this.phone,
        //        provinceId = this.provinceId,
        //        sex = this.sex,
        //        status = this.status,
        //        Telephone = this.telephone,
        //        totalConsume = this.totalConsume,
        //        totalRecharge = this.totalRecharge,
        //        userId = this.userId,
        //        userKey = this.userKey,
        //        userType = this.userType,
        //        vip = this.vip,
        //        remarkName = this.remarkName,
        //    };
        //}
        #endregion
            
        #region 根据status批量删除
        /// <summary>
        /// 根据status批量删除
        /// </summary>
        public int DeleteByStatus()
        {
            if (CreateFriendTable())
            {
                try
                {
                    //var result = (
                    //    from friend in DBSetting.AccountDbContext.Friends
                    //    where friend.status == this.status
                    //    select friend);
                    //if (result != null)
                    //{
                    //    DBSetting.AccountDbContext.Friends.RemoveRange(result);
                    //    DBSetting.AccountDbContext.SaveChanges();
                    //}
                    return DBSetting.SQLiteDBContext.Deleteable<Friend>().Where(f => f.Status == this.Status).ExecuteCommand();
                }
                catch (Exception e)
                {
                    ConsoleLog.Output(e.Message);
                }
            }
            return 0;
        }
        #endregion
        
        #region 根据userId批量删除
        /// <summary>
        /// 根据userId批量删除
        /// </summary>
        public int DeleteByUserId()
        {
            if (CreateFriendTable())
            {
                try
                {
                    //var result = (
                    //    from friend in DBSetting.AccountDbContext.Friends
                    //    where friend.status == this.status
                    //    select friend);
                    //if (result != null)
                    //{
                    //    DBSetting.AccountDbContext.Friends.RemoveRange(result);
                    //    DBSetting.AccountDbContext.SaveChanges();
                    //}
                    return DBSetting.SQLiteDBContext.Deleteable<Friend>().Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception e)
                {
                    ConsoleLog.Output(e.Message);
                }
            }
            return 0;
        }


        /// <summary>
        /// 修改@我的消息状态， 2 == @全体成员 1 == @我
        /// </summary>
        /// <param name="atme"></param>
        internal void UpdateAtMeState(int atme)
        {
            this.IsAtMe = atme;
            if (CreateFriendTable())
            {
                try
                {
                    DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { IsAtMe = atme }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }

        }
        #endregion

        #region 根据status批量删除
        /// <summary>
        /// 根据status批量删除
        /// <paramref name="status">状态值</paramref>
        /// </summary>
        public int DeleteByStatus(int status)
        {
            if (CreateFriendTable())
            {
                try
                {
                    //var result = (
                    //    from friend in DBSetting.AccountDbContext.Friends
                    //    where friend.status == status
                    //    select friend).ToList();
                    //if (result != null)
                    //{
                    //    DBSetting.AccountDbContext.Friends.RemoveRange(result);
                    //    DBSetting.AccountDbContext.SaveChanges();
                    //}
                    return DBSetting.SQLiteDBContext.Deleteable<Friend>().Where(f => f.Status == status).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 序列化
        public string ToJson()
        {
            return JsonConvert.SerializeObject(this);
        }


        #endregion
        
        /// <summary>
        /// 更新某个朋友的消息置顶
        /// </summary>
        /// <param name="time"></param>
        internal void UpdateTopTime(int time)
        {
            if (CreateFriendTable())
            {
                try
                {
                    DBSetting.SQLiteDBContext.Updateable<Friend>().
                       UpdateColumns(f => new Friend() { TopTime = time }).
                       Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
        }

        /// <summary>
        /// 更新消息免打扰
        /// </summary>
        /// <param name="time"></param>
        internal void UpdateNodisturb()
        {
            if (CreateFriendTable())
            {
                DBSetting.SQLiteDBContext.Updateable<Friend>().
                      UpdateColumns(f => new Friend() { Nodisturb = Nodisturb }).
                      Where(f => f.UserId == this.UserId).ExecuteCommand();
            }
        }

        /// <summary>
        /// 更新阅后即焚
        /// </summary>
        /// <param name="time"></param>
        internal void UpdateReadDel()
        {
            if (CreateFriendTable())
            {
                DBSetting.SQLiteDBContext.Updateable<Friend>().
                      UpdateColumns(f => new Friend() { IsOpenReadDel = IsOpenReadDel }).
                      Where(f => f.UserId == this.UserId).ExecuteCommand();
            }
        }
        
        #region 反序列化
        public Friend ToModel(string strJson)
        {
            Friend msgObj = JsonConvert.DeserializeObject<Friend>(strJson);
            return msgObj;
        }
        #endregion

        #region 根据status获得列表
        /// <summary>
        /// 根据status获得列表
        /// </summary>
        public List<Friend> GetListByStatus()
        {
            if (CreateFriendTable())
            {
                return DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.Status == this.Status && f.IsGroup == this.IsGroup).ToList();
            }
            return new List<Friend>();
        }
        #endregion

        #region 根据userId从本地数据库获得对象
        /// <summary>
        /// 根据userId获得本地数据库对象
        /// </summary>
        /// <returns></returns>
        public Friend GetByUserId()
        {
            if (CreateFriendTable())
            {
                //var result = DBSetting.dbContext.Friends.FirstOrDefault(f => f.userId == this.userId);=
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Single(f => f.UserId == this.UserId && f.IsGroup == IsGroup);
                return result == null ? this : result;
            }
            return this;
        }
        #endregion

        #region 根据roomId从本地数据库获得对象
        /// <summary>
        /// 根据userId获得本地数据库对象
        /// </summary>
        /// <returns></returns>
        public Friend GetFriendByRoomId(string roomId)
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Single(f => f.RoomId == roomId);
                return result;

            }
            return this;
        }
        #endregion

        #region 根据userId从本地数据库获得对象
        /// <summary>
        /// 根据userId获得本地数据库对象
        /// </summary>
        /// <returns></returns>
        public Friend GetFdByUserId()
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Single(f => f.UserId == this.UserId);

                if (IsGroup == 1)
                {
                    return result;
                }

                return result == null ? this : result;
            }
            return this;
        }
        #endregion

        #region 是否存在数据库中
        /// <summary>
        /// 是否存在数据库中
        /// </summary>
        /// <param name="userId">需要查询的UserId</param>
        /// <returns>表示是否存在</returns>
        public bool ExistsLocal(string userId)
        {
            if (CreateFriendTable())
            {
                return DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.UserId == userId).Any();
            }
            return false;
        }
        #endregion

        #region 是否存在我方黑名单中
        /// <summary>
        /// 是否存在我方黑名单中
        /// </summary>
        /// <param name="userId">需要查询的UserId</param>
        /// <returns>是否存在值</returns>
        public bool ExistsBlackList(string userId)
        {
            if (CreateFriendTable())
            {
                //int count = DBSetting.dbContext.Friends.Count(f => f.userId == userId && f.status == -1);
                return DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.UserId == userId && f.Status == -1).Any();
            }
            return false;
        }
        #endregion

        #region 与该好友是否为好友
        /// <summary>
        /// 与该好友是否为好友
        /// </summary>
        /// <param name="userId">需要查询的UserId</param>
        /// <returns>是否存在</returns>
        public bool ExistsFriend()
        {
            if (CreateFriendTable())
            {
                return DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.UserId == UserId && f.Status == 2).Any();
            }
            return false;
        }
        #endregion

        #region 根据UserName获取(支持模糊查询)
        public List<Friend> GetByUserName(string str_like)
        {
            if (CreateFriendTable())
            {
                //模糊查询
                List<IConditionalModel> conModels = new List<IConditionalModel>();
                //conModels.Add(new ConditionalModel() { FieldName = "Name", ConditionalType = ConditionalType.Equal, FieldValue = "s" });
                conModels.Add(new ConditionalModel() { FieldName = "isGroup", ConditionalType = ConditionalType.Equal, FieldValue = this.IsGroup.ToString() });
                conModels.Add(new ConditionalModel() { FieldName = "Name", ConditionalType = ConditionalType.Like, FieldValue = str_like });
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Where(conModels).OrderBy(it => it.NickName).ToList();
                return result == null ? new List<Friend>() : result;
            }
            return new List<Friend>();
        }
        #endregion

        #region 获取最近聊天列表
        /// <summary>
        /// 获取最近聊天列表
        /// </summary>
        /// <returns></returns>
        public List<Friend> GetRecentList()
        {
            if (CreateFriendTable())
            {
                return DBSetting.SQLiteDBContext.Queryable<Friend>()
                    .Where(f => f.Content != null && f.Status == 2)
                    .OrderBy(f => f.TopTime, OrderByType.Desc)
                    .OrderBy(it => it.LastMsgTime, OrderByType.Desc)
                    .ToPageList(0, 100);
            }
            return new List<Friend>();
        }

        public List<Friend> GetRecordSortList()
        {
            if (CreateFriendTable())
            {
                return DBSetting.SQLiteDBContext.Queryable<Friend>()
                    .Where(f => f.Status == 2 && f.UserType <= FriendType.USER_TYPE_NEW)
                    .OrderBy(f => f.TopTime, OrderByType.Desc)
                    .OrderBy(it => it.LastMsgTime, OrderByType.Desc)
                    .ToList();
            }
            return new List<Friend>();
        }

        /// <summary>
        /// 获取最近群聊列表
        /// </summary>
        /// <returns></returns>
        public List<Friend> GetRecentGroupList()
        {
            if (CreateFriendTable())
            {
                return DBSetting.SQLiteDBContext.Queryable<Friend>()
                    .Where(f => f.Content != null && f.Status == 2)
                    .Where(f => f.IsGroup == 1).ToList();
            }
            return new List<Friend>();
        }

        #endregion

        #region 获取好友列表
        /// <summary>
        /// 获取好友列表
        /// <para>status == 2</para>
        /// </summary>
        /// <returns></returns>
        public List<Friend> GetFriendsList()
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>()
                    .Where(f => f.Status == 2 && f.IsGroup == this.IsGroup)
                    .OrderBy(f => f.UserType, OrderByType.Desc)
                    .ToList();

                if (result != null && result.Count > 7)
                {
                    result.Sort(6, result.Count - 6, new FriendComparable());
                }
                return result == null ? new List<Friend>() : result;
            }
            return new List<Friend>();
        }
        #endregion

        #region 获取好友列表
        /// <summary>
        /// 获取好友列表
        /// <para>status == 2</para>
        /// </summary>
        /// <returns></returns>
        public List<Friend> SearchFriendsByName(string name, int isGroup = 0)
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>()
                    .Where(f => f.NickName.Contains(name) || f.RemarkName.Contains(name))
                    .Where(f => f.Status == 2 && f.IsGroup == this.IsGroup).ToList();

                return result == null ? new List<Friend>() : result;
            }
            return new List<Friend>();
        }
        #endregion

        #region 获取群组列表
        /// <summary>
        /// 获取群组列表
        /// <para>status == 2</para>
        /// </summary>
        /// <returns></returns>
        public List<Friend> GetGroupsList()
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>()
                       .Where(f => f.Status == 2 && f.IsGroup == 1)
                       .ToList();

                if (result != null && result.Count > 0)
                {
                    result.Sort(new FriendComparable());
                }
                return result == null ? new List<Friend>() : result;
            }
            return new List<Friend>();
        }
        #endregion


        #region 获取好友或者群组集合
        /// <summary>
        /// 获取好友或者群组集合
        /// </summary>
        /// <param name="isGroup">0为好友，1为群组</param>
        /// <para name="Sort">是否需要通过好友最后一次发送消息事件排序，0否，1是</para>
        /// <returns></returns>
        public List<Friend> GetFriendsByIsGroup(int Sort = 0)
        {
            if (CreateFriendTable())
            {
                if (Sort == 0)
                {
                    var result = DBSetting.SQLiteDBContext.Queryable<Friend>()
                            .Where(f => f.Status == 2 && f.IsGroup == IsGroup)
                        .Where(f => !f.UserId.Equals(Friend.ID_SYSTEM))
                        .Where(f => f.UserType <= FriendType.USER_TYPE_NEW)
                        .ToList();

                    return result == null ? new List<Friend>() : result;
                }

                if (Sort == 1)
                {
                    var result = DBSetting.SQLiteDBContext.Queryable<Friend>()
                        .Where(f => f.Status == 2 && f.IsGroup == IsGroup)
                        .Where(f => f.UserType <= FriendType.USER_TYPE_NEW)
                        .Where(f => !f.UserId.Equals(Friend.ID_SYSTEM))
                        .OrderBy(f => f.TopTime, OrderByType.Desc)
                        .OrderBy(it => it.LastMsgTime, OrderByType.Desc).ToList();
                    return result == null ? new List<Friend>() : result;

                }
            }
            return new List<Friend>();
        }
        #endregion

        #region 获取好友和群组集合
        /// <summary>
        /// 获取好友和群组集合
        /// <para>好友状态为2</para>
        /// </summary>
        /// <returns></returns>
        public List<Friend> GetAllFriends()
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.Status == 2 && f.UserType <= FriendType.USER_TYPE_NEW).ToList();
                return result == null ? new List<Friend>() : result;
            }
            return new List<Friend>();
        }
        #endregion
        
        #region 获取黑名单列表
        /// <summary>
        /// 获取黑名单列表
        /// </summary>
        /// <returns></returns>
        public List<Friend> GetBlacksList()
        {
            //List<Friend> result = (
            //from friend in DBSetting.dbContext.Friends
            //where friend.status == -1
            //select friend
            //).ToList();

            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.Status == -1 && f.IsGroup == this.IsGroup).ToList();
                return result == null ? new List<Friend>() : result;
            }
            return new List<Friend>();
        }
        #endregion

        #region 检查用户是否在获取黑名单列表
        /// <summary>
        /// 检查用户是否在黑名单列表
        /// </summary>
        /// <returns></returns>
        public int IsBlackUser(string userid)
        {
            //var result = (
            //    from fri in DBSetting.dbContext.Friends
            //    where fri.status == -1 && fri.userId == userid
            //    select fri
            //).FirstOrDefault()
            UpdateAccountId(Applicate.MyAccount.userId);
            UpdateAccountId(userid);

            if (CreateFriendTable())
            {
                //用户存在于好友列表且在黑名单则为1
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.Status == -1 && f.UserId == userid);
                return result == null ? 0 : result.Count();
            }
            return 0;

        }
        #endregion

        #region 获取黑名单好友
        /// <summary>
        /// 获取黑名单好友
        /// </summary>
        /// <returns></returns>
        public Friend GetBlackUser(string userid)
        {
            //var result = (
            //    from fri in DBSetting.dbContext.Friends
            //    where fri.status == -1 && fri.userId == userid
            //    select fri
            //).FirstOrDefault();

            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Single(f => f.Status == -1 && f.UserId == UserId);
                return result == null ? new Friend() : result;
            }
            return new Friend();
        }
        #endregion

        #region 获取所有用户列表
        /// <summary>
        /// 获取所有用户列表，如果结果为空返回新的实体类
        /// </summary>
        /// <returns></returns>
        public List<Friend> GetAllList()
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().ToList();
                return result == null ? new List<Friend>() : result;
            }
            return new List<Friend>();
        }


        public List<Friend> QueryFriendAndRoom()
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>()
                            .Where(f => f.Status == 2 && f.UserType <= FriendType.USER_TYPE_NEW)
                            .ToList();
                return result;
            }

            return null;
        }

        public bool IsNormalUser()
        {
            return UserType == FriendType.USER_TYPE;
        }

        #endregion
        
        #region 获取所有好友列表
        /// <summary>
        /// 获取所有用户列表，如果结果为空返回新的实体类
        /// </summary>
        /// <returns></returns>
        public List<Friend> GetAllListByGroup(int isgroup)
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.IsGroup == isgroup).ToList();
                return result == null ? new List<Friend>() : result;
            }
            return new List<Friend>();
        }
        #endregion
        
        #region 获取所有好友列表
        /// <summary>
        /// 获取所有用户列表，如果结果为空返回新的实体类
        /// </summary>
        /// <returns></returns>
        public int GetTopFriendCount(int top)
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.TopTime > top).ToList();
                return result == null ? 0 : result.Count;
            }

            return 0;
        }
        #endregion

        #region 获取最近消息列表时间排序
        /// <summary>
        /// 获取所有用户列表，如果结果为空返回新的实体类
        /// </summary>
        /// <returns></returns>
        public int GetLastTimeFriendCount(double time)
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>()
                   .Where(f => f.LastMsgTime > time || f.TopTime > 0)
                      .Where(f => f.Content != null && f.Status == 2).ToList();
                return result == null ? -1 : result.Count;
            }

            return -1;
        }
        #endregion
        
        #region 更新备注
        /// <summary>
        /// 更新好友备注
        /// <para>必须先对userId和remarkName赋值</para>
        /// </summary>
        /// <param name="UserId">用户ID</param>
        /// <param name="remarkName">新备注名</param>
        /// <returns>受影响行数</returns>
        public int UpdateRemarkName()
        {
            if (CreateFriendTable())
            {
                try
                {
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { RemarkName = this.RemarkName }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 修改群昵称
        /// <summary>
        /// 修改群昵称
        /// <para>必须先对userId和nickName赋值</para>
        /// </summary>
        /// <param name="UserId">用户ID</param>
        /// <param name="nickName">新昵称</param>
        /// <returns>受影响行数</returns>
        public int UpdateNickName()
        {
            if (CreateFriendTable())
            {
                try
                {
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { NickName = this.NickName }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 更新群邀请验证 

        /// <summary>
        /// 更新群邀请验证
        /// <para>必须先对userId和isNeedVerify赋值</para>
        /// </summary>
        /// <param name="UserId">用户ID</param>
        /// <param name="isNeedVerify">验证</param>
        /// <returns>受影响行数</returns>
        public int UpdateNeedVerify()
        {
            if (CreateFriendTable())
            {
                try
                {
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { IsNeedVerify = this.IsNeedVerify }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 更新群已读人数

        /// <summary>
        /// 更新群已读人数
        /// <para>必须先对userId和showRead赋值</para>
        /// </summary>
        /// <param name="UserId">用户ID</param>
        /// <param name="showRead">群已读</param>
        /// <returns>受影响行数</returns>
        public int UpdateShowRead()
        {
            if (CreateFriendTable())
            {
                try
                {
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { ShowRead = this.ShowRead }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion
        
        #region 更新群成员显示

        /// <summary>
        /// 更新群成员显示
        /// <para>必须先对userId和showManber赋值</para>
        /// </summary>
        /// <param name="UserId">用户ID</param>
        /// <param name="showMember">群成员显示</param>
        /// <returns>受影响行数</returns>
        public int UpdateShowMember(int show)
        {
            if (CreateFriendTable())
            {
                try
                {
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { ShowMember = show }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 更新群私聊
        public int UpdateAllowSendCard(int allow)
        {
            if (CreateFriendTable())
            {
                try
                {
                    this.AllowSendCard = allow;
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { AllowSendCard = allow }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        internal void UpdateAccountId(string accountid)
        {
            if (CreateFriendTable())
            {
                DBSetting.SQLiteDBContext.Updateable<Friend>().
                     UpdateColumns(f => new Friend() { AccountId = accountid }).
                     Where(f => f.UserId == this.UserId).ExecuteCommand();
            }
        }
        
        #region 更新群主开启了普通成员邀请功能
        public int UpdateAllowInviteFriend(int invite)
        {
            if (CreateFriendTable())
            {
                try
                {
                    this.AllowInviteFriend = invite;
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { AllowInviteFriend = invite }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 普通成员上传群共享
        public int UpdateAllowUploadFile(int invite)
        {
            if (CreateFriendTable())
            {
                try
                {
                    this.AllowUploadFile = invite;
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { AllowUploadFile = invite }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 更改群会议
        public int UpdateAllowConference(int invite)
        {
            if (CreateFriendTable())
            {
                try
                {
                    this.AllowConference = invite;
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { AllowConference = invite }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 更改群课件
        public int UpdateAllowSpeakCourse(int invite)
        {
            if (CreateFriendTable())
            {
                try
                {
                    this.AllowSpeakCourse = invite;
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { AllowSpeakCourse = invite }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion
        
        public int UpdateClearContent()
        {
            if (CreateFriendTable())
            {
                try
                {
                    this.Content = null;
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { Content = null }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }

        public int UpdateLastContent(string str, double timeSend)
        {
            if (CreateFriendTable())
            {
                try
                {
                    this.Content = str;
                    this.LastMsgTime = timeSend;
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { Content = str, LastMsgTime = timeSend }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        
        public int UpdateLastContent(string str, double timeSend, int unredcount)
        {
            if (CreateFriendTable())
            {
                try
                {
                    this.Content = str;
                    this.LastMsgTime = timeSend;
                    this.MsgNum = unredcount;
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { Content = str, LastMsgTime = timeSend, MsgNum = unredcount }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }

        // 更新未读数量
        public int UpdateRedNum(int num)
        {
            if (CreateFriendTable())
            {
                try
                {
                    this.MsgNum = num;
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend() { MsgNum = num }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }

            return 0;
        }

        public int GetNuRedNum()
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Single(f => f.UserId == this.UserId);
                return result == null ? 0 : result.MsgNum;
            }

            return 0;
        }
        
        public List<Friend> SearchFriendByName(string text)
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>()
                            .Where(f => f.NickName.Contains(text) || f.RemarkName.Contains(text))
                            .Where(f => f.Status == 2 && f.UserType <= FriendType.USER_TYPE_NEW)
                            .ToList();
                return result;
            }

            return null;
        }
        
        #region 好友总数
        /// <summary>
        /// 好友总数
        /// </summary>
        /// <returns></returns>
        internal int FriendsCount()
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.IsGroup == 0);
                return result == null ? 0 : result.Count();
            }
            return 0;
        }
        #endregion
        
        /// <summary>
        /// 数据下载接口 数据转成friend
        /// </summary>
        /// <param name="jsonText"></param>
        /// <returns></returns>
        public List<Friend> AttentionToFriends(Dictionary<string, object> jsonText)
        {
            List<Friend> listFriend = new List<Friend>();
            JArray friendArray = JArray.Parse(UIUtils.DecodeString(jsonText, "data"));
            foreach (var item in friendArray)
            {
                Friend friend = new Friend()
                {
                    UserId = item["toUserId"].ToString(),
                    LastMsgTime = Convert.ToInt32(item["lastMsgTime"]),
                    MsgNum = Convert.ToInt32(item["msgNum"]),
                    Status = Convert.ToInt32(item["status"]),
                    NickName = item["toNickname"].ToString(),
                    CreateTime = Convert.ToInt32(item["createTime"]),
                    RemarkName = item["remarkName"] == null ? "" : item["remarkName"].ToString(),
                    Sex = Convert.ToInt32(item["sex"]),
                    IsOpenReadDel = UIUtils.DecodeInt(item, "isOpenSnapchat"),
                    TopTime = UIUtils.DecodeInt(item, "openTopChatTime"),
                    Nodisturb = UIUtils.DecodeInt(item, "offlineNoPushMsg"),
                };

                friend.TopTime = UIUtils.DecodeInt(item, "openTopChatTime");
                if (friend.TopTime == 1)
                {
                    friend.TopTime = TimeUtils.CurrentIntTime();
                }

                // 公众号 #8134
                if (UIUtils.DecodeInt(item, "toUserType") == 2)
                {
                    friend.UserType = FriendType.PUBLICIZE_TYPE;
                }

                // 我被对方拉黑 isBeenBlack == 1
                if (1 == Convert.ToInt32(item["isBeenBlack"]))
                {
                    // 修改禅道 #8125
                    friend.Status = Friend.STATUS_19;
                }

                listFriend.Add(friend);
            }

            return listFriend;
        }
        
        /// <summary>
        /// 群组信息接口数据 转成 friend 
        /// </summary>
        /// <param name="result"></param>
        public void TransToMember(Dictionary<string, object> keyValues)
        {
            //是否显示群已读
            ShowRead = UIUtils.DecodeInt(keyValues, "showRead");
            // 显示群成员
            ShowMember = UIUtils.DecodeInt(keyValues, "showMember");
            // 允许普通群成员私聊
            AllowSendCard = UIUtils.DecodeInt(keyValues, "allowSendCard");
            //允许普通群成员邀请好友
            AllowInviteFriend = UIUtils.DecodeInt(keyValues, "allowInviteFriend");
            //允许普通群成员上传文件
            AllowUploadFile = UIUtils.DecodeInt(keyValues, "allowUploadFile");
            //允许普通群成员召开会议
            AllowConference = UIUtils.DecodeInt(keyValues, "allowConference");
            //允许普通群成员发起讲课
            AllowSpeakCourse = UIUtils.DecodeInt(keyValues, "allowSpeakCourse");
            //是否开启群主验证
            IsNeedVerify = UIUtils.DecodeInt(keyValues, "isNeedVerify");

            UpdateRoomSetting();
            
            // 获取禁言状态
            long talkTime = UIUtils.DecodeLong(keyValues, "talkTime");
            talkTime = talkTime > 0 ? 1 : 0;
            LocalDataUtils.SetStringData(UserId + "BANNED_TALK_ALL" + Applicate.MyAccount.userId, talkTime.ToString());

            // 设置群聊消息过期时间
            string outtime = UIUtils.DecodeString(keyValues, "chatRecordTimeOut");
            LocalDataUtils.SetStringData(UserId + "chatRecordTimeOut" + Applicate.MyAccount.userId, outtime);

            //"allowHostUpdate": 1,  // 是否允许群主修改群属性
            //"chatRecordTimeOut":      消息保存天数
            //"createTime": 1554106810, 创建时间
            //"isAttritionNotice": 1,群组减员通知
            //"isLook": 1, // 是否公开群组
            //"modifyTime": 1554116921, // 最后一次发言时间
            //"talkTime": 0, // 禁言时间

            //"videoMeetingNo": "355228" // 群会议地址
            //"call": "305228",// 群会议地址

            //"areaId": 440307,
            //"category": 0,
            //"cityId": 440300,
            //"countryId": 1,
            //"provinceId": 440000,
            //"latitude": 22.608988,
            //"longitude": 114.066209,

            //"s": 1,// 群组状态 -1 锁定 1 正常

            //"name": "飞飞",
            //"desc": "1",
            //"subject": "",

            //"userSize": 6,
            //"maxUserSize": 1000,

            //"nickname": "2007",
            //"userId": 10009572,

            //"id": "5ca1c9b90c03d0640281ad58",
            //"jid": "d0495fea6ce34adea87a0fe8764bdd24",


            // 更新自己在群里面的数据
            string roomByme = UIUtils.DecodeString(keyValues, "member");
            if (!UIUtils.IsNull(roomByme))
            {
                var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(roomByme);
                RoomMember user = new RoomMember
                {
                    roomId = this.RoomId
                };
                user.UpdateRoomUser(data);
            }

            // 更新管理员和群主在群里界面的数据
            string admins = UIUtils.DecodeString(keyValues, "members");
            if (!UIUtils.IsNull(admins))
            {
                var mems = JsonConvert.DeserializeObject<List<object>>(admins);
                foreach (var item in mems)
                {
                    var mem = JsonConvert.DeserializeObject<Dictionary<string, object>>(item.ObjToString());
                    RoomMember member = new RoomMember
                    {
                        roomId = this.RoomId
                    };
                    member.UpdateRoomUser(mem);
                }
            }

            //"notice": {
            //"id": "5ca495d60c03d02d76821ad1",
            //"nickname": "2007",
            //"roomId": "5ca1c9b90c03d0640281ad58",
            //"text": "11111",
            //"time": 1554290134,
            //"userId": 10009572
            //},

            string notice = UIUtils.DecodeString(keyValues, "notice");
            if (!UIUtils.IsNull(notice))
            {
                var noticeData = JsonConvert.DeserializeObject<Dictionary<string, object>>(notice);
                int time = UIUtils.DecodeInt(noticeData, "time");
                if (TimeUtils.CurrentTime() - time < 60 * 60 * 24 * 15)
                {
                    LocalDataUtils.SetBoolData(UserId + "show_notice", true);
                }
            }

            //"member": {
            //"active": 1554106810,
            //"call": "305228",
            //"createTime": 1554106810,
            //"modifyTime": 0,
            //"nickname": "2007",
            //"offlineNoPushMsg": 0,
            //"role": 1,
            //"sub": 1,
            //"talkTime": 0,
            //"userId": 10009572,
            //"videoMeetingNo": "355228"
            //},

            //"members": [
            //{
            //"active": 1554106810,
            //"call": "305228",
            //"createTime": 1554106810,
            //"modifyTime": 0,
            //"nickname": "2007",
            //"offlineNoPushMsg": 0,
            //"role": 1,
            //"sub": 1,
            //"talkTime": 0,
            //"userId": 10009572,
            //"videoMeetingNo": "355228"
            //}
            //],

            //"notice": {
            //"id": "5ca495d60c03d02d76821ad1",
            //"nickname": "2007",
            //"roomId": "5ca1c9b90c03d0640281ad58",
            //"text": "11111",
            //"time": 1554290134,
            //"userId": 10009572
            //},
        }
        
        #region 更改群设置
        public int UpdateRoomSetting()
        {
            if (CreateFriendTable())
            {
                try
                {
                    return DBSetting.SQLiteDBContext.Updateable<Friend>().
                        UpdateColumns(f => new Friend()
                        {
                            ShowRead = this.ShowRead,
                            ShowMember = this.ShowMember,
                            AllowSendCard = this.AllowSendCard,
                            AllowInviteFriend = this.AllowInviteFriend,
                            AllowUploadFile = this.AllowUploadFile,
                            AllowConference = this.AllowConference,
                            AllowSpeakCourse = this.AllowSpeakCourse,
                            IsNeedVerify = this.IsNeedVerify,
                            TopTime = this.TopTime,
                            IsOpenReadDel = this.IsOpenReadDel,
                            Nodisturb = this.Nodisturb
                        }).
                        Where(f => f.UserId == this.UserId).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 判断本地是否存在好友

        public bool IsExistFriend(bool isGroup)
        {
            if (CreateFriendTable())
            {
                try
                {
                    if (isGroup)
                    {
                        var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.IsGroup == 1).ToList();
                        return !UIUtils.IsNull(result);
                    }
                    else
                    {
                        var result = DBSetting.SQLiteDBContext.Queryable<Friend>().Where(f => f.IsGroup != 1).ToList();
                        return !UIUtils.IsNull(result);
                    }
                }
                catch (Exception)
                {
                    return false;
                }
            }
            return false;
        }

        public int RemoveAllFriend()
        {
            if (CreateFriendTable())
            {
                try
                {
                    return DBSetting.SQLiteDBContext.Deleteable<Friend>().Where(f => f.IsGroup != 1).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }

        public int RemoveAllGroup()
        {
            if (CreateFriendTable())
            {
                try
                {
                    return DBSetting.SQLiteDBContext.Deleteable<Friend>().Where(f => f.IsGroup == 1).ExecuteCommand();
                }
                catch (Exception ex)
                {
                    ConsoleLog.Output(ex.Message);
                }
            }
            return 0;
        }
        #endregion

        #region 修改状态为已解散
        public int SetDismiss()
        {
            if (CreateFriendTable())
            {
                var result = DBSetting.SQLiteDBContext.Updateable<Friend>().UpdateColumns(f => new Friend { IsDismiss = 1 }).
                    Where(f => f.UserId == this.UserId).ExecuteCommand();
                return result;
            }

            return 0;
        }

        // 是否是用户
        internal bool IsDevice()
        {
            return UserType == FriendType.DEVICE_TYPE;
        }
        #endregion
    }
    #endregion
    
    public class FriendType
    {
        // 用户好友
        public const int USER_TYPE = 0;
        // 用户好友
        public const int USER_TYPE_NEW = 1;
        // 公众号 
        public const int PUBLICIZE_TYPE = 2;
        // 我的设备
        public const int DEVICE_TYPE = 3;
        // 黑名单和新的朋友
        public const int NEWFRIEND_TYPE = 4;
    }
    
}
