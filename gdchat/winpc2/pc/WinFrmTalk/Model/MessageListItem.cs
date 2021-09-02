using Newtonsoft.Json;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    #region 设置消息项的类型
    /// <summary>
    /// 设置消息项的类型
    /// </summary>
    public enum ItemType
    {

        /// <summary>
        /// 消息类型
        /// </summary>
        Message = 0,

        /// <summary>
        /// 群组 (或者群主)
        /// </summary>
        Group = 1,

        /// <summary>
        /// 用户 (或者管理员)
        /// </summary>
        User = 2,

        /// <summary>
        /// 好友请求消息列表项 (或者普通群成员)
        /// </summary>
        VerifyMsg = 3,

        /// <summary>
        /// 静音的项
        /// </summary>
        Mute = 4
    }
    #endregion
    /// <summary>
    /// 用于存储消息列表项的
    /// </summary>
    [SugarTable("MessageList")]
    public class MessageListItem
    {
        #region Private Member
        private int noReadCount;
        private string messageTitle;
        private ItemType messageItemType;
        private string messageItemContent;
        private long timeSend;
        private string _jid;
        private MessageObject msg;
        private string _id;
        private string _showTitle = "";
        private bool _isVisibility = true;
        private string message;
        private string avator;
        #endregion

        #region Public Member

        /// <summary>
        /// 头像路径
        /// </summary>
        public string Avator
        {
            get { return avator; }
            set { avator = value; }
        }

        /// <summary>
        /// 未读计数,
        /// </summary>
        public int UnReadCount
        {
            get { return noReadCount; }
            set
            {
                noReadCount = value;

            }
        }

        /// <summary>
        /// 昵称
        /// </summary>
        public string MessageTitle
        {
            get
            { return messageTitle; }
            set
            {
                messageTitle = value;

            }
        }

        /// <summary>
        /// 消息项类型
        /// </summary>
        public ItemType MessageItemType
        {
            get
            {
                return messageItemType;
            }

            set
            {
                messageItemType = value;

            }
        }

        /// <summary>
        /// 项内容 (或用于传递发送列表时为当前登录用户在对应会话群里的群昵称)
        /// </summary>
        public string MessageItemContent
        {
            get { return messageItemContent; }

            set
            {
                messageItemContent = value;

            }
        }

        /// <summary>
        /// 发送时间
        /// </summary>
        public long TimeSend
        {
            get { return timeSend; }
            set
            {
                timeSend = value;

            }
        }

        /// <summary>
        /// 一般用于存放UserId或房间Jid
        /// </summary>
        [Key]
        public string Jid
        {
            get
            {
                return _jid;
            }
            set
            {
                _jid = value;

            }
        }

        /// <summary>
        /// 一般存RoomID
        /// </summary>
        public string Id
        {
            get { return _id; }
            set { _id = value; }
        }

        /// <summary>
        /// 数据库存储的消息(仅存储)
        /// </summary>
        public string Message
        {
            get
            {
                if (Msg == null || string.IsNullOrEmpty(Msg.messageId))
                {
                    message = JsonConvert.SerializeObject(Msg);
                }
                return message;
            }
            set
            {
                Msg = new MessageObject();
                message = value;
                Msg = JsonConvert.DeserializeObject<MessageObject>(value);
            }
        }

        /// <summary>
        /// Json消息(此属性运行时操作,不参与数据库存储)
        /// </summary>
        public MessageObject Msg
        {
            get
            {
                return msg;
            }
            set
            {
                message = JsonConvert.SerializeObject(value);
                msg = value;
            }
        }

        /// <summary>
        /// 备注名
        /// </summary>
        public string ShowTitle
        {
            get
            {
                if (string.IsNullOrWhiteSpace(_showTitle))//如果为空显示真实昵称
                {
                    return MessageTitle;
                }
                else//如果不为空显示备注
                {
                    return _showTitle;
                }
            }
            set
            {
                if (value == null)
                {
                    return;
                }
                _showTitle = value;
            }
        }

        /// <summary>
        /// 是否显示
        /// </summary>
        public bool IsVisibility
        {
            get { return _isVisibility; }
            set
            {
                _isVisibility = value;
            }
        }
        #endregion

        /// <summary>
        /// 用于暂时存储数据的标签数据
        /// </summary>
        public string Tag { get; set; }

        #region Constructor
        public MessageListItem()
        {

        }
        #endregion

        #region 实现数据库操作的构造函数
        /// <summary>
        /// 有参构造函数
        /// </summary>
        /// <param name="ConnString">数据库连接字符串</param>
        public MessageListItem(string ConnString)
        {
            //DBContext = new SQLiteDBContextContext(ConnString);
        }
        #endregion

        #region 插入到数据库
        /// <summary>
        /// 插入到数据库
        /// </summary>
        public void Insert()
        {
            try
            {
                if (Jid == null || Jid == Guid.Empty.ToString("N"))
                {
                    Jid = Guid.NewGuid().ToString("N");
                }
                var res = DBSetting.SQLiteDBContext.Insertable(this).ExecuteCommand();
                ConsoleLog.Output("插入结果" + res);
            }
            catch (Exception ex)
            {
                ConsoleLog.Output(ex.Message);
            }
        }
        #endregion

        #region 更新到数据库
        /// <summary>
        /// 更新到数据库
        /// </summary>
        public void Update()
        {
            var res = DBSetting.SQLiteDBContext.Updateable(this);
            ConsoleLog.Output("Update RecentList --:" + res);
        }
        #endregion

        #region 克隆MessageListItem
        /// <summary>
        /// 克隆MessageListItem
        /// </summary>
        /// <param name="rthis">源Item</param>
        /// <returns>新Item</returns>
        public MessageListItem Clone()
        {
            return new MessageListItem
            {
                Id = this.Id,
                MessageItemContent = this.MessageItemContent,
                MessageItemType = this.MessageItemType,
                Msg = this.Msg,
                MessageTitle = this.MessageTitle,
                Jid = this.Jid,
                TimeSend = this.TimeSend,
                UnReadCount = this.UnReadCount,
                ShowTitle = this.ShowTitle,
                IsVisibility = this.IsVisibility,
                Avator = this.Avator
            };
        }
        #endregion  

        #region 删除
        /// <summary>
        /// 删除
        /// </summary>
        public void Delete()
        {
            var res = DBSetting.SQLiteDBContext.Deleteable(this);
            ConsoleLog.Output("Delete ----" + res);
        }
        #endregion

        #region 获取集合
        public List<MessageListItem> GetAllList()
        {
            return DBSetting.SQLiteDBContext.Queryable<MessageListItem>().OrderBy(m => m.TimeSend, OrderByType.Desc).ToList();
        }
        #endregion

        #region 序列化
        public string toJson()
        {
            return JsonConvert.SerializeObject(this);
        }
        #endregion

        #region 反序列化
        public MessageListItem toModel(string msgJson)
        {
            MessageListItem msgObj = JsonConvert.DeserializeObject<MessageListItem>(msgJson);
            return msgObj;
        }
        #endregion

    }
}
