using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using SqlSugar;
using System;
using System.Collections.Generic;

namespace WinFrmTalk.Model
{
    #region MessageObject
    /// <summary>
    /// 信息主体
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class MessageObject
    {
        #region Private Member

        //[JsonIgnore]
        /*以下数据存于本地数据库中*/
        private string _messageId;
        private kWCMessageType _type;
        //private double _timeSend;
        //private string _roomJid;
        //private string _fromUserId;
        //private string _fromUserName;
        //private string _toUserId;
        //private string _toUserName;
        //private int _isGroup;
        //private int _isRead;
        //private int _messageNo;
        //private int _isSend;
        //private string _content;
        //private string _fileName;
        //private double _location_y;
        //private double _location_x;
        //private int _isUpload;
        //private int _isDownload;
        //private int _timeLen;
        //private int _fileSize;
        //private string _objectId;
        //private int _readPersons;
        //private string _FromId;
        //private string _ToId;

        #endregion

        /// <summary>
        /// 数据表名前缀
        /// </summary>
        private static readonly string Prefex = "msg_";


        #region Constructor
        public MessageObject()
        {
            this.myUserId = Applicate.MyAccount.userId;
            //this.messageId = Guid.NewGuid().ToString("N");
        }
        #endregion

        #region Public Member

        /// <summary>
        /// 行号
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsIgnore = true)]
        public int rowIndex { get; set; }

        /// <summary>
        /// 标记该消息是否撤回中
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsIgnore = true)]
        public int isRecall { get; set; }

        /// <summary>
        /// 阅后即焚倒计时
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsIgnore = true)]
        public int ReadDelTime { get; set; }

        /// <summary>
        /// 我的UserId
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsIgnore = true)]
        public string myUserId { get; set; }

        /// <summary>
        /// 重发次数
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsIgnore = true)]
        public int reSendCount { get; set; }

        /// <summary>
        /// 是否加密
        /// </summary>
        [SugarColumn(IsIgnore = true)]
        public int isEncrypt { get; set; }

        /// <summary>
        /// 是否进行过刷新
        /// </summary>
        [SugarColumn(IsIgnore = true)]
        public bool isRefresh { get; set; }

        /// <summary>
        /// 是否正在上传或者下载
        /// </summary>
        [SugarColumn(IsIgnore = true)]
        public int isLoading { get; set; }

        /// <summary>
        /// 表名
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsIgnore = true)]
        private string TableName
        {
            get
            {
                if (string.IsNullOrEmpty(ChatJid))
                {
                    return Prefex + "Null";
                }

                return Prefex + ChatJid;
            }
        }

        /// <summary>
        /// 此条消息对应的UserId(如果是自己发送, jid就为ToUserId, 否则为FromUserId, 不能为自己的UserId)
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsIgnore = true)]
        public string ChatJid
        {
            get { return (this.myUserId == this.FromId) ? this.ToId : this.FromId; }
        }

        /// <summary>
        /// 消息的平台类型
        /// <para>
        /// 1为android 2为ios 3为web 4为mac 5为pc
        /// </para>
        /// <para>如果此属性>=0时，表示当前消息为多点登录时同账号设备间转发消息</para>
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsIgnore = true)]
        public int PlatformType { get; set; }


        /// <summary>
        /// 消息id
        /// </summary>
        [SugarColumn(IsPrimaryKey = true, IsNullable = false)]
        public string messageId
        {
            get { return _messageId; }
            set { _messageId = value; }
        }

        /// <summary>
        /// 消息类型
        /// </summary>
        [SugarColumn(IsNullable = false, ColumnDataType = "INTEGER")]
        public kWCMessageType type
        {
            get { return _type; }
            set
            {
                _type = value;
            }
        }

        /// <summary>
        /// 消息发送时间毫秒
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public double timeSend { get; set; }

        /// <summary>
        /// 群组才有的群组jid
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string roomJid { get; set; }

        /// <summary>
        /// 消息发送者id（系统通知时，为系统id）
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string fromUserId { get; set; }

        /// <summary>
        /// 消息发送者名称
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string fromUserName { get; set; }

        /// <summary>
        /// 消息接收人id
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string toUserId { get; set; }

        /// <summary>
        /// 消息接收人名称
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string toUserName { get; set; }

        /// <summary>
        /// 是否群组
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsNullable = true)]
        public int isGroup { get; set; }

        /// <summary>
        /// 是否自己已读，或是对方已读，二选一
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsNullable = true)]
        public int isRead { get; set; }

        /// <summary>
        /// 是否送达，是否发送成功
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsNullable = true)]
        public int isSend { get; set; }

        /// <summary>
        /// 消息内容
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string content { get; set; }

        /// <summary>
        /// 文件名称
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string fileName { get; set; }

        /// <summary>
        /// 位置消息用作纬度，图片消息用作高度
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public double location_y { get; set; }

        /// <summary>
        /// 位置消息用作经度，图片消息用作宽度
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public double location_x { get; set; }

        /// <summary>
        /// 是否上传
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsNullable = true)]
        public int isUpload { get; set; }

        /// <summary>
        /// 是否下载
        /// </summary>
        [JsonIgnore]
        [SugarColumn(IsNullable = true)]
        public int isDownload { get; set; }

        /// <summary>
        /// 文件播放时长单位秒
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int timeLen { get; set; }

        /// <summary>
        /// 文件大小单位字节
        /// <para>当消息类型为Remind类型时，该字段记录长度</para>
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public long fileSize { get; set; }

        /// <summary>
        /// 根据不同消息类型有不同的用处
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string objectId { get; set; }

        /// <summary>
        /// 消息已读人数
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int readPersons { get; set; }

        ///// <summary>
        ///// 消息阅读时间
        ///// </summary>
        //[SugarColumn(IsNullable = true)]
        //public int readTime { get; set; }

        /// <summary>
        /// xmpp协议中真正的发送人id
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string FromId { get; set; }

        /// <summary>
        /// xmpp协议中真正的接收人id
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string ToId { get; set; }

        /// <summary>
        /// 消息的过期时间
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public double deleteTime { get; set; }

        /// <summary>
        /// 是否阅后即焚
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int isReadDel { get; set; }

        /// <summary>
        /// 气泡宽度
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int BubbleWidth { get; set; }

        /// <summary>
        /// 气泡高度
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int BubbleHeight { get; set; }


        /// <summary>
        /// 是否免打扰消息 
        /// 此字段用于进行任务栏通知图标闪烁
        /// 1== 免打扰 0 == 需要进行通知栏闪烁
        /// </summary>
        [SugarColumn(IsIgnore = true)] // 不存数据库
        public int Nodisturb { get; set; }
        #endregion

        #region Public Methods

        #region 序列化
        /// <summary>
        /// 转当前对象为Json字符串
        /// </summary>
        /// <returns>Json字符串</returns>
        public string ToJson()
        {
            return JsonConvert.SerializeObject(this);//序列化
        }


        public string ToJson(bool transport)
        {
            Dictionary<string, object> param = new Dictionary<string, object>();

            param.Add("type", this.type);


            if (!string.IsNullOrEmpty(this.messageId))
            {
                param.Add("messageId", this.messageId);
            }

            if (timeSend != 0)
            {
                param.Add("timeSend", this.timeSend);
            }

            if (deleteTime != 0)
            {
                param.Add("deleteTime", this.deleteTime);
            }

            if (isReadDel != 0)
            {
                param.Add("isReadDel", this.isReadDel);
            }

            if (isEncrypt != 0)
            {
                param.Add("isEncrypt", this.isEncrypt);
            }

            if (!string.IsNullOrEmpty(this.fromUserId))
            {
                param.Add("fromUserId", this.fromUserId);
            }

            if (!string.IsNullOrEmpty(this.fromUserName))
            {
                param.Add("fromUserName", this.fromUserName);
            }

            if (!string.IsNullOrEmpty(this.toUserId))
            {
                param.Add("toUserId", this.toUserId);
            }

            if (!string.IsNullOrEmpty(this.toUserName))
            {
                param.Add("toUserName", this.toUserName);
            }

            if (!string.IsNullOrEmpty(this.content))
            {
                param.Add("content", this.content);
            }

            if (this.location_x != 0)
            {
                param.Add("location_x", this.location_x);
            }

            if (this.location_y != 0)
            {
                param.Add("location_y", this.location_y);
            }

            if (!string.IsNullOrEmpty(this.objectId))
            {
                param.Add("objectId", this.objectId);
            }

            if (this.fileSize != 0)
            {
                param.Add("fileSize", this.fileSize);
            }

            if (!string.IsNullOrEmpty(this.fileName))
            {
                param.Add("fileName", this.fileName);
            }

            if (this.timeLen != 0)
            {
                param.Add("timeLen", this.timeLen);
            }

            string json = JsonConvert.SerializeObject(param);
            return json;
        }

        #endregion

        #region 反序列化
        public MessageObject toModel(string MsgJson)
        {
            MessageObject msgObj = JsonConvert.DeserializeObject<MessageObject>(MsgJson);
            return msgObj;
        }
        #endregion

        #endregion



        #region 复制一个新消息
        /// <summary>
        /// 创建表
        /// </summary>
        public MessageObject CopyMessage()
        {
            MessageObject message = new MessageObject();
            message.type = this.type;
            message.messageId = messageId;
            message.fromUserId = fromUserId;
            message.fromUserName = fromUserName;
            message.toUserId = toUserId;
            message.toUserName = toUserName;
            message.content = content;
            message.FromId = FromId;
            message.ToId = ToId;
            message.fileName = fileName;
            message.fileSize = fileSize;
            message.timeSend = timeSend;
            message.timeLen = timeLen;
            message.objectId = objectId;
            message.isGroup = isGroup;
            message.location_x = location_x;
            message.location_y = location_y;
            message.isEncrypt = isEncrypt;
            message.isReadDel = isReadDel;
            message.deleteTime = deleteTime;
            return message;
        }
        #endregion


        #region 创建表
        /// <summary>
        /// 创建表
        /// </summary>
        public bool CreatMessageTable()
        {
            if (string.IsNullOrEmpty(ToId))
            {
                ToId = myUserId;
            }

            if (TableName == Prefex + "Null")
            {
                return false;
            }

            var db = DBSetting.SQLiteDBContext;
            db.MappingTables.RemoveAll(it => it.EntityName == "MessageObject");
            db.MappingTables.Add("MessageObject", TableName);

            //if (string.IsNullOrWhiteSpace(this.ToId) || string.IsNullOrWhiteSpace(this.FromId))
            //{
            //    return false;
            //}

            //创建数据库表
            try
            {
                if (!db.Queryable<sqlite_master>().Where(s => s.Name == TableName && s.Type == "table").Any())
                {
                    db.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(MessageObject));
                }

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
        #endregion

        /*********************Database Storage*********************/

        #region 更新对应UserId的消息昵称
        /// <summary>
        /// 更新对应UserId的消息昵称
        /// </summary>
        /// <param name="targetJid">对话名称</param>
        /// <param name="userId">需要修改的UserId</param>
        /// <param name="nickname">修改的昵称</param>
        public int UpdateNicknameByUserId(string targetJid, string userId, string nickname)
        {
            //StringBuilder strb = new StringBuilder();
            //strb.Append("update " + Prefex + targetJid);//拼接表名
            //strb.Append(string.Format(" set fromUserName = @nickname where fromUserId = @userid"));
            ////SQL参数
            //SQLiteParameter[] parameters = {
            //                    new SQLiteParameter("@nickname",DbType.String),
            //                    new SQLiteParameter("@userid",DbType.String)
            //                };
            //parameters[0].Value = nickname;
            //parameters[1].Value = userId;
            //int rows = dBHelperSQLite.ExecuteNonQuery(strb.ToString(), parameters);

            int rows = DBSetting.SQLiteDBContext.Updateable(this).
                UpdateColumns(it => new MessageObject() { fromUserName = nickname }).
                Where(m => m.fromUserId == userId).AS(this.TableName).ExecuteCommand();
            return rows;
        }
        #endregion

        #region 将当前消息存入数据库
        /// <summary>
        /// 将当前消息存入数据库
        /// <para>如果messageId已存在，则不会插入</para>
        /// </summary>
        public int InsertData()
        {
            if (string.IsNullOrEmpty(this.messageId))
                return 0;
            if (CreatMessageTable())
            {
                using (var db = DBSetting.SQLiteDBContext)
                {
                    //该msgId已存在
                    if (db.Queryable<MessageObject>().AS(this.TableName).Where(m => m.messageId == this.messageId).Any())
                    {
                        return 0;
                    }

                    var result = db.Insertable(this).AS(this.TableName).ExecuteCommand();
                    return result;
                }
            }
            return 0;
        }
        #endregion

        #region 将当前消息存入数据库
        /// <summary>
        /// 将当前消息存入数据库
        /// <para>如果messageId已存在，则不会插入</para>
        /// </summary>
        public int InsertReadData()
        {
            if (CreatMessageTable())
            {
                //该msgId已存在


                if (DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName)
                    .Where(m => m.fromUserId == this.fromUserId && m.content == this.content && m.type == m.type)
                    .Any())
                {
                    return 0;
                }

                //var result = DBSetting.SQLiteDBContext.Insertable(this).AS(this.TableName).ExecuteCommand();
                //return result;
                ////var result = DBSetting.SQLiteDBContext.Insertable(this).AS(this.TableName).ExecuteCommand();
                return InsertData();
            }
            return 0;
        }
        #endregion


        public bool IsExist()
        {
            if (CreatMessageTable())
            {
                //该msgId已存在
                return DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).Where(m => m.messageId == this.messageId).Any();
            }
            return false;
        }


        #region 修改消息类型
        /// <summary>
        /// 修改消息类型
        /// <para>必须先对messageId和type赋值</para>
        /// </summary>
        /// <param name="msgId">消息唯一Id</param>
        /// <param name="type">消息类型</param>
        /// <returns>是否成功</returns>
        public int UpdateMessageType()
        {
            if (CreatMessageTable())
            {
                int result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().UpdateColumns(it => new MessageObject() { type = this.type }).
                Where(m => m.messageId == this.messageId).AS(this.TableName).ExecuteCommand();
                return result;
            }
            return 0;
        }
        #endregion
        public int UpdateObject()
        {
            if (CreatMessageTable())
            {
                int result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().UpdateColumns(it => new MessageObject() { objectId = this.objectId }).
                Where(m => m.messageId == this.messageId).AS(this.TableName).ExecuteCommand();
                return result;
            }
            return 0;
        }
        public int UpdateFilename()
        {
            if (CreatMessageTable())
            {
                int result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().UpdateColumns(it => new MessageObject() { fileName = this.fileName }).
                Where(m => m.messageId == this.messageId).AS(this.TableName).ExecuteCommand();
                return result;
            }
            return 0;
        }
        #region 更新消息内容
        /// <summary>
        /// 更新消息内容
        /// <para>必须先对messageId和content赋值</para>
        /// </summary>
        /// <param name="content">内容</param>
        /// <param name="messageId">消息对应的Id</param>
        /// <returns>返回受影响行数</returns>
        public int UpdateMessageContent()
        {
            if (CreatMessageTable())
            {
                int result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().UpdateColumns(it => new MessageObject() { content = this.content }).
                Where(m => m.messageId == this.messageId).AS(this.TableName).ExecuteCommand();
                return result;
            }
            return 0;
        }
        /// <summary>
        /// 更新上传
        /// (liuhuan2019/6/1)
        /// </summary>
        /// <returns></returns>
        public int updatemessageupdate(int _upload)
        {
            if (CreatMessageTable())
            {
                int result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().UpdateColumns(it => new MessageObject() { isUpload = _upload }).
                Where(m => m.messageId == this.messageId).AS(this.TableName).ExecuteCommand();
                return result;
            }
            return 0;
        }

        internal bool IsMySend()
        {
            return Applicate.MyAccount.userId.Equals(FromId);
        }
        #endregion

        #region 更新送达
        /// <summary>
        /// 更新送达
        /// <para>-1为发送失败 0为发送中 1为送达</para>
        /// </summary>
        /// <param name="messageId">消息唯一Id</param>
        /// <param name="msgState">消息状态</param>
        /// <returns>返回受影响行数</returns>
        public int UpdateIsSend(int isSendState, string messageId = null)
        {
            if (CreatMessageTable())
            {
                if (!String.IsNullOrWhiteSpace(messageId))
                {
                    this.messageId = messageId;
                }

                int result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().UpdateColumns(it => new MessageObject() { isSend = isSendState }).
                                                                    Where(m => m.messageId == this.messageId).AS(this.TableName).ExecuteCommand();
                return result;
            }
            return 0;
        }
        #endregion

        #region 更新消息状态为已读
        /// <summary>
        /// 更新消息状态为已读
        /// <para>必须先对messageId赋值</para>
        /// </summary>
        /// <param name="messageId">消息唯一Id</param>
        /// <param name="msgState">消息状态</param>
        public int UpdateIsRead(string msgId)
        {
            if (CreatMessageTable())
            {
                this.isRead = 1;
                this.isSend = 1;

                int result = 0;

                if (isReadDel == 1)
                {
                    result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().UpdateColumns(it => new MessageObject()
                    { isRead = 1, type = kWCMessageType.Remind, content = "对方查看了您的这条阅后即焚消息", isSend = 1 }).
                    Where(m => m.messageId == msgId).AS(this.TableName).ExecuteCommand();
                }
                else
                {
                    result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().UpdateColumns(it => new MessageObject() { isRead = 1, isSend = 1 }).
                    Where(m => m.messageId == msgId).AS(this.TableName).ExecuteCommand();
                }

                return result;
            }
            return 0;
        }

        #endregion

        #region 获取某消息已读人数
        /// <summary>
        /// 获取某消息已读人数
        /// </summary>
        /// <param name="messageId">要查询的消息的id</param>
        /// <param name="msgState">消息状态</param>
        public List<MessageObject> GetReadPersonsList(string roomId, string messageId, int PageIndex)
        {

            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                            Where(m => m.type == kWCMessageType.IsRead && m.content == messageId).
                            OrderBy(it => it.timeSend, OrderByType.Desc).ToPageList(PageIndex, 20);
                return list;
            }
            return null;
        }

        #endregion

        #region 更新消息类型为提示，改变内容
        /// <summary>
        /// 更新消息状态为已读
        /// <para>必须先对messageId赋值</para>
        /// </summary>
        /// <param name="messageId">消息唯一Id</param>
        /// <param name="msgState">消息状态</param>
        public int UpdateChangeTip(string cont)
        {
            if (CreatMessageTable())
            {
                this.content = cont;

                int result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().UpdateColumns(it => new MessageObject() { type = kWCMessageType.Remind, content = cont }).
                Where(m => m.messageId == this.messageId).AS(this.TableName).ExecuteCommand();
                return result;
            }
            return 0;
        }
        #endregion

        #region 更新已读
        /// <summary>
        /// 更新已读
        /// <para>必须先对messageId赋值</para>
        /// </summary>
        /// <param name="messageId">消息唯一Id</param>
        /// <param name="msgState">消息状态</param>
        public int UpdateIsReadPersons(int person_num)
        {
            if (CreatMessageTable())
            {
                this.readPersons = person_num;

                // 修改原消息已读人数
                int result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().
                    UpdateColumns(it => new MessageObject() { isRead = 1, isSend = 1, readPersons = person_num }).
                    Where(m => m.messageId == messageId).AS(this.TableName).ExecuteCommand();

                return result;
            }

            return 0;
        }
        #endregion

        #region 更新已读人数
        /// <summary>
        /// 更新已读人数
        /// <para>必须先对messageId赋值</para>
        /// </summary>
        /// <param name="messageId">消息唯一Id</param>
        public int UpdateReadPersons()
        {
            if (CreatMessageTable())
            {
                // 修改原消息已读人数
                int result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().
                    UpdateColumns(it => new MessageObject() { isRead = 1, readPersons = this.readPersons }).
                    Where(m => m.messageId == messageId).AS(this.TableName).ExecuteCommand();

                return result;
            }

            return 0;
        }
        #endregion

        #region 更新撤回
        /// <summary>
        /// 更新撤回
        /// <para>必须先对messageId赋值</para>
        /// </summary>
        /// <param name="messageId">消息唯一Id</param>
        /// <param name="msgState">消息状态</param>
        public int UpdateIsReCall()
        {
            if (CreatMessageTable())
            {
                int result = DBSetting.SQLiteDBContext.Updateable<MessageObject>().
                UpdateColumns(it => new MessageObject() { type = (kWCMessageType)202, content = this.fromUserName + "撤回了一条信息" }).
                Where(m => m.messageId == this.messageId).AS(this.TableName).ExecuteCommand();
                return result;
            }
            return 0;
        }
        #endregion

        #region 更新整条消息
        /// <summary>
        /// 更新整条消息
        /// <para>必须先对messageId赋值</para>
        /// </summary>
        public int UpdateData()
        {
            if (CreatMessageTable())
            {
                var result = DBSetting.SQLiteDBContext.Updateable(this).
                    Where(m => m.messageId == this.messageId).
                    AS(this.TableName).ExecuteCommand();
                return result;
            }
            return 0;
        }
        #endregion

        #region 根据消息从数据库查询到朋友
        /// <summary>
        /// 根据消息从数据库查询到朋友
        /// </summary>
        /// <returns></returns>
        internal Friend GetFriend()
        {
            Friend friend = new Friend();
            friend.UserId = IsMySend() ? ToId : FromId;
            friend.IsGroup = GetGroup();
            friend.NickName = IsMySend() ? toUserName : fromUserName;
            friend.Content = friend.ToLastContentTip(type, content, fromUserId, fromUserName, toUserName);
            friend.LastMsgTime = this.timeSend;
            return friend.GetByUserId();
        }

        #endregion

        private int GetGroup()
        {
            if (type == kWCMessageType.kWCMessageTypeNone)
            {
                string userid = IsMySend() ? ToId : FromId;
                return userid.Length > 18 ? 1 : 0;
            }
            return isGroup;
        }

        #region 刷新朋友表最后一条消息
        /// <summary>
        /// 刷新朋友表最后一条消息，及未读数量
        /// <para>必须先对messageId赋值</para>
        /// 先对messageId赋值</para>
        /// </summary>
        /// <param name="messageId">消息唯一Id</param>
        /// <param name="msgState">消息状态</param>
        public int UpdateLastSend()
        {
            if (!IsVisibleMsg())
            {
                return 0;
            }


            Friend friend = GetFriend();

            this.Nodisturb = friend.Nodisturb;
            string cont = friend.ToLastContentTip(type, content, fromUserId, fromUserName, toUserName);
            if (isGroup == 1 && type == kWCMessageType.Text)
            {
                cont = fromUserName + " : " + cont;
            }

            if (isReadDel == 1)
            {
                cont = "[阅后即焚消息]";
            }

            // 在当前聊天界面  是否开启消息免打扰
            if (IsChatView() || friend.Nodisturb == 1)
            {
                friend.UpdateLastContent(cont, timeSend, 0); // 更新最后一条消息
            }
            else if (IsMySend() || string.Equals(fromUserId, myUserId))
            {
                friend.UpdateLastContent(cont, timeSend);// 更新最后一条消息
            }
            else
            {
                friend.InsertAuto();
                var cuss = friend.UpdateLastContent(cont, timeSend, friend.MsgNum + 1); // 更新最后一条消息
            }

            return 1;
        }

        private bool IsChatView()
        {
            return Applicate.IsChatFriend(ChatJid);
        }

        public bool IsVisibleMsg()
        {
            switch (type)
            {
                case kWCMessageType.RedPacket:
                case kWCMessageType.TRANSFER:
                    return Applicate.ENABLE_RED_PACKAGE;
                case kWCMessageType.TYPE_SECURE_LOST_KEY:
                    return Applicate.ENABLE_ASY_ENCRYPT;
                case kWCMessageType.kWCMessageTypeNone:
                case kWCMessageType.IsRead:
                case kWCMessageType.AudioChatAsk:
                case kWCMessageType.AudioChatReady:
                case kWCMessageType.AudioChatAccept:
                case kWCMessageType.VideoChatAsk:
                case kWCMessageType.VideoChatReady:
                case kWCMessageType.VideoChatAccept:
                case kWCMessageType.Typing:
                case kWCMessageType.AudioMeetingInvite:
                case kWCMessageType.VideoMeetingInvite:
                    return false;
                case kWCMessageType.AudioChatCancel:
                case kWCMessageType.AudioChatEnd:
                case kWCMessageType.VideoChatCancel:
                case kWCMessageType.VideoChatEnd:
                case kWCMessageType.Withdraw:
                case kWCMessageType.RoomIsVerify:
                    return true;
                default:
                    return type < kWCMessageType.AudioChatAsk;
            }

        }
        #endregion

        #region 根据messageId删除一条数据
        /// <summary>
        /// 根据messageId删除一条数据
        /// <para>必须先对messageId赋值</para>
        /// </summary>
        public int DeleteData()
        {
            if (CreatMessageTable())
            {
                int result = DBSetting.SQLiteDBContext.Deleteable<MessageObject>().AS(this.TableName).
                Where(m => m.messageId == this.messageId).ExecuteCommand();
                return result;
            }
            return 0;
        }
        #endregion

        #region 得到一个对象实体
        /// <summary>
        /// 得到一个对象实体
        /// <para>必须先对messageId赋值</para>
        /// </summary>
        public MessageObject GetMessageObject()
        {
            if (CreatMessageTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<MessageObject>().
                    AS(this.TableName).Single(m => m.messageId == this.messageId);
                return result == null ? new MessageObject() : result;
            }
            return new MessageObject();
        }
        #endregion

        #region 清空单个对象的聊天记录
        /// <summary>
        /// 清空单个对象的聊天记录
        /// <para>返回受影响行数</para>
        /// </summary>
        public int DeleteTable()
        {
            if (CreatMessageTable())
            {
                //string strSql = string.Format("delete from {0}", tab);
                //int rows = dBHelperSQLite.ExecuteNonQuery(strSql);
                int rows = DBSetting.SQLiteDBContext.Deleteable<MessageObject>().AS(TableName).ExecuteCommand();
                return rows;
            }
            return 0;
        }

        /// <summary>
        /// 清除某一个朋友的消息       
        /// </summary>
        public int DeleteMessageLow(double lowTime)
        {
            if (CreatMessageTable())
            {
                int rows = DBSetting.SQLiteDBContext.Deleteable<MessageObject>().AS(TableName)
                    .Where(m => m.timeSend < lowTime)
                    .ExecuteCommand();
                return rows;
            }
            return 0;
        }
        #endregion

        #region 获取和对应用户聊天记录的最后时间戳
        /// <summary>
        /// 获取和对应用户聊天记录的最后时间戳
        /// <para>查询没有记录则返回0</para>
        /// </summary>
        public double GetLastTimeStamp()
        {
            if (CreatMessageTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).Max(m => m.timeSend);
                return result <= 0 ? 0 : result;
            }
            return 0;
        }
        #endregion

        #region 分页获取数据列表（模糊查询）
        /// <summary>
        /// 分页获取数据列表（模糊查询）
        /// <para>按时间降序排序</para>
        /// </summary>
        /// <param name="type">获取对应类型的消息(小于零时获取全部)</param>
        /// <param name="PageIndex">第几页（0和1都是第一页）</param>
        /// <param name="PageSize">一页多少行消息（同一功能调用该方法请固定使用一个值）</param>
        /// <param name="content">消息内容</param>
        /// <returns></returns>
        public List<MessageObject> GetPageList(int type, string content, int PageIndex, int PageSize = 30)
        {
            var list = new List<MessageObject>();
            if (CreatMessageTable())
            {
                if (type < 0)
                {
                    list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                        Where(m => m.content.Contains(content)).OrderBy(it => it.timeSend, OrderByType.Desc).
                        ToPageList(PageIndex, PageSize);
                }
                else
                {
                    list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                        Where(m => m.type == (kWCMessageType)type && m.content.Contains(content)).
                        OrderBy(it => it.timeSend, OrderByType.Desc).ToPageList(PageIndex, PageSize);
                }
            }
            return list == null ? new List<MessageObject>() : list;
        }
        #endregion
        #region 分页获取历史聊天记录数据列表（模糊查询）
        /// <summary>
        /// 分页获取数据列表（模糊查询）
        /// <para>按时间降序排序</para>
        /// </summary>
        /// <param name="type">获取对应类型的消息(小于零时获取全部)</param>
        /// <param name="PageIndex">第几页（0和1都是第一页）</param>
        /// <param name="PageSize">一页多少行消息（同一功能调用该方法请固定使用一个值）</param>
        /// <param name="content">消息内容</param>
        /// <returns></returns>
        public List<MessageObject> GetPageHotrysList(int type, string content, int PageIndex, int PageSize = 30)
        {
            var list = new List<MessageObject>();
            if (CreatMessageTable())
            {
                if (type < 0)
                {
                    list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                        Where(m => m.content.Contains(content)).OrderBy(it => it.timeSend, OrderByType.Desc).
                        ToPageList(PageIndex, PageSize);
                }
                else
                {
                    list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                        Where(m => m.type == (kWCMessageType)type && m.content.Contains(content) && m.type == kWCMessageType.Text).
                        OrderBy(it => it.timeSend, OrderByType.Desc).ToPageList(PageIndex, PageSize);
                }
            }
            return list == null ? new List<MessageObject>() : list;
        }
        #endregion
        #region 分页获取数据列表（不筛选）
        /// <summary>
        /// 分页获取数据列表（不筛选）
        /// <para>按时间降序排序</para>
        /// </summary>
        /// <param name="pageNum">当前页，从1开始，0和1都是第一页</param>
        /// <param name="PageSize">页的行数</param>
        /// <returns></returns>
        public List<MessageObject> GetPageList(int pageNum, int PageSize = 30)
        {
            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                OrderBy(it => it.timeSend, OrderByType.Desc).ToPageList(pageNum, PageSize);
                return list == null ? new List<MessageObject>() : list;
            }
            return new List<MessageObject>();
        }
        #endregion

        #region 文件
        /// <summary>
        /// 文件
        /// </summary>
        /// <param name="pageNum"></param>
        /// <param name="PageSize"></param>
        /// <returns></returns>
        public List<MessageObject> GetFileList(int pageNum, int PageSize = 30)
        {
            if (CreatMessageTable())
            {

                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).Where(it => it.type == kWCMessageType.File).
                OrderBy(it => it.timeSend, OrderByType.Desc).ToPageList(pageNum, PageSize);
                return list == null ? new List<MessageObject>() : list;
            }
            return new List<MessageObject>();
        }
        #endregion

        #region 图片
        /// <summary>
        /// 视频及图片
        /// </summary>
        /// <param name="pageNum"></param>
        /// <param name="PageSize"></param>
        /// <returns></returns>
        public List<MessageObject> GetVideoImageList(int pageNum, int PageSize = 30)
        {
            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).Where(it => it.type == kWCMessageType.Image).
                OrderBy(it => it.timeSend, OrderByType.Desc).ToPageList(pageNum, PageSize);
                return list == null ? new List<MessageObject>() : list;
            }
            return new List<MessageObject>();
        }
        #endregion

        #region 视频
        /// <summary>
        /// 视频
        /// </summary>
        /// <param name="pageNum"></param>
        /// <param name="PageSize"></param>
        /// <returns></returns>
        public List<MessageObject> GetVidoList(int pageNum, int PageSize = 30)
        {
            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).Where(it => it.type == kWCMessageType.Video).
                OrderBy(it => it.timeSend, OrderByType.Desc).ToPageList(pageNum, PageSize);
                return list == null ? new List<MessageObject>() : list;
            }
            return new List<MessageObject>();
        }
        #endregion

        #region 获取最近一条消息
        /// <summary>
        /// 获取最后一条消息
        /// <para>按时间降序排序</para>
        /// </summary>
        /// <returns></returns>
        public MessageObject GetLastMessage()
        {
            if (CreatMessageTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                    Where(it => it.type != kWCMessageType.IsRead).
                    OrderBy(m => m.timeSend, OrderByType.Desc).First();
                return result != null ? result : new MessageObject();
            }
            return new MessageObject();
        }
        #endregion

        #region 获取最早的本地消息
        /// <summary>
        /// 获取最后一条消息
        /// <para>按时间降序排序</para>
        /// </summary>
        /// <returns></returns>
        public MessageObject GetFristMessage()
        {
            if (CreatMessageTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                    Where(it => it.type != kWCMessageType.IsRead).
                    OrderBy(m => m.timeSend, OrderByType.Asc).First();
                return result;
            }
            return null;
        }
        #endregion


        /// <summary>
        /// 消息内容解析
        /// </summary>
        /// <param name="jsonText"></param>
        /// <returns></returns>
        public List<MessageObject> SingleChat(Dictionary<string, object> jsonText)
        {
            List<MessageObject> listFriend = new List<MessageObject>();
            JArray friendArray = JArray.Parse(UIUtils.DecodeString(jsonText, "data"));
            if (friendArray != null)
            {
                foreach (var item in friendArray)
                {
                    string body = UIUtils.DecodeString(item, "body").Replace("&quot;", "\"");
                    LogUtils.Log(body);

                    var objResult = JsonConvert.DeserializeObject<Dictionary<string, object>>(body);
                    string type = "";
                    if (objResult.ContainsKey("isReadDel"))
                        type = objResult["isReadDel"].GetType().Name;
                    if (type.Equals("Boolean"))
                    {
                        objResult["isReadDel"] = (bool)objResult["isReadDel"] ? 1 : 0;
                        body = JsonConvert.SerializeObject(objResult);
                    }
                    listFriend.Add(JsonConvert.DeserializeObject<MessageObject>(body));
                }
            }
            return listFriend;
        }

        #region 批量插入数据
        /// <summary>
        /// 批量插入数据
        /// </summary>
        /// <param name="msgList"></param>
        /// <returns></returns>
        internal int InsertArrayData(List<MessageObject> msgList)
        {
            if (CreatMessageTable())
            {
                var result = DBSetting.SQLiteDBContext.Insertable(msgList.ToArray()).AS(this.TableName).ExecuteCommand();
                return result;
            }
            return 0;
        }
        #endregion

        #region 分页获取数据列表（过滤某些数据类型）
        /// <summary>
        /// 分页获取数据列表（不筛选）
        /// <para>按时间降序排序</para>
        /// </summary>
        /// <param name="pageNum">当前页，从1开始，0和1都是第一页</param>
        /// <param name="PageSize">页的行数</param>
        /// <returns></returns>
        public List<MessageObject> GetPageListNotHaveIsRead(int pageNum, int PageSize = 30)
        {
            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                Where(it => it.type != kWCMessageType.IsRead && it.type != kWCMessageType.Withdraw).
                    OrderBy(it => it.timeSend, OrderByType.Desc).ToPageList(pageNum, PageSize);
                return list == null ? new List<MessageObject>() : list;
            }
            return new List<MessageObject>();
        }
        #endregion
        #region 分页获取数据列表（过滤某些数据类型）
        /// <summary>
        /// 分页获取数据列表（不筛选）
        /// <para>按时间降序排序</para>
        /// </summary>
        /// <param name="pageNum">当前页，从1开始，0和1都是第一页</param>
        /// <param name="PageSize">页的行数</param>
        /// <returns></returns>
        public List<MessageObject> GetPageListHistory(int pageNum, int PageSize = 30)
        {
            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                Where(it => it.type != kWCMessageType.IsRead && it.type != kWCMessageType.Withdraw && it.type != kWCMessageType.Remind && it.type != kWCMessageType.Card && it.type < kWCMessageType.AudioChatAsk).
                    OrderBy(it => it.timeSend, OrderByType.Desc).ToPageList(pageNum, PageSize);
                return list == null ? new List<MessageObject>() : list;
            }
            return new List<MessageObject>();
        }
        #endregion
        #region 分页获取数据列表（过滤某些数据类型）
        /// <summary>
        /// 分页获取数据列表（不筛选）
        /// <para>按时间降序排序</para>
        /// </summary>
        /// <param name="pageNum">当前页，从1开始，0和1都是第一页</param>
        /// <param name="PageSize">页的行数</param>
        /// <returns></returns>
        public List<MessageObject> GetPageListNotHaveIsRead(double endTime, int PageSize = 30, double startTime = 0)
        {
            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                    Where(it => it.type != kWCMessageType.IsRead && it.type != kWCMessageType.Withdraw && it.timeSend < endTime && it.timeSend > startTime).
                    OrderBy(it => it.timeSend, OrderByType.Desc).ToPageList(1, PageSize);
                return list == null ? new List<MessageObject>() : list;
            }
            return new List<MessageObject>();
        }
        #endregion


        #region 分页获取数据列表（过滤某些数据类型）
        /// <summary>
        /// 分页获取数据列表（不筛选）
        /// <para>按时间降序排序</para>
        /// </summary>
        /// <param name="pageNum">当前页，从1开始，0和1都是第一页</param>
        /// <param name="PageSize">页的行数</param>
        /// <returns></returns>
        public List<MessageObject> LoadRecordMsg(int pagerIndex, int PageSize = 30)
        {
            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                    Where(it => it.type != kWCMessageType.IsRead).
                    Where(it => it.type != kWCMessageType.Withdraw).
                    OrderBy(it => it.timeSend, OrderByType.Desc)
                    .ToPageList(pagerIndex, PageSize);
                return list;
            }

            return null;
        }
        #endregion

        #region 分页获取数据列表（过滤某些数据类型）
        /// <summary>
        /// 分页获取数据列表（不筛选）
        /// <para>按时间降序排序</para>
        /// </summary>
        /// <param name="pageNum">当前页，从1开始，0和1都是第一页</param>
        /// <param name="PageSize">页的行数</param>
        /// <returns></returns>
        public List<MessageObject> LoadRecordMsg(double start, double end, int PageSize = 30)
        {
            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                    Where(it => it.timeSend >= start).
                    Where(it => it.timeSend < end).
                    Where(it => it.type != kWCMessageType.IsRead).
                    Where(it => it.type != kWCMessageType.Withdraw).
                    OrderBy(it => it.timeSend, OrderByType.Desc)
                    .ToPageList(1, PageSize);
                return list;
            }

            return null;
        }
        #endregion

        #region 分页获取数据列表（过滤某些数据类型）
        /// <summary>
        /// 分页获取数据列表（不筛选）
        /// <para>按时间降序排序</para>
        /// </summary>
        /// <param name="pageNum">当前页，从1开始，0和1都是第一页</param>
        /// <param name="PageSize">页的行数</param>
        /// <returns></returns>
        public List<MessageObject> LoadRecordMsg(double time, int PageSize)
        {
            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                    Where(it => it.timeSend < time).
                    Where(it => it.type != kWCMessageType.IsRead).
                    Where(it => it.type != kWCMessageType.Withdraw).
                    OrderBy(it => it.timeSend, OrderByType.Desc)
                    .ToPageList(1, PageSize);
                return list;
            }

            return null;
        }
        #endregion

        #region 按时间排序，按行号或者某一条记录
        /// <summary>
        /// 按时间排序，按行号或者某一条记录
        /// </summary>
        /// <returns></returns>
        public MessageObject GetMsgByRowIndex(int rowIndex)
        {
            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                    Where(it => it.type != kWCMessageType.IsRead).
                    OrderBy(it => it.timeSend, OrderByType.Desc).ToPageList(rowIndex - 1, 1);
                return list == null || list.Count == 0 ? new MessageObject() : list[0];
            }
            return new MessageObject();
        }
        #endregion

        public static List<MessageObject> DictionaryToList(Dictionary<string, MessageObject> msgsData)
        {
            List<MessageObject> msgsList = new List<MessageObject>();
            foreach (MessageObject msg in msgsData.Values)
                msgsList.Add(msg);
            return msgsList;
        }

        /// <summary>
        /// 获取聊天对象的userId
        /// </summary>
        /// <returns></returns>
        public string GetChatTargetId()
        {
            string userId = FromId.Equals(Applicate.MyAccount.userId) ? ToId : FromId;
            return userId;
        }
        #region 用于导出历史聊天记录的全部数据
        public List<MessageObject> LoadRecordMsg()
        {
            if (CreatMessageTable())
            {
                var list = DBSetting.SQLiteDBContext.Queryable<MessageObject>().AS(this.TableName).
                    Where(it => it.type != kWCMessageType.IsRead).
                    Where(it => it.type != kWCMessageType.Withdraw).
                    OrderBy(it => it.timeSend, OrderByType.Desc).ToList();

                return list;
            }

            return null;
        }
        #endregion
    }
    #endregion

}
