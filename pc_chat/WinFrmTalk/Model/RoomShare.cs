using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace WinFrmTalk
{
    public class JsonRoomShare
    {
        #region 初始化引用类型
        public JsonRoomShare()
        {
            data = new List<RoomShare>();
        }
        #endregion


        /// <summary>
        /// 房间详情
        /// </summary>
        public List<RoomShare> data { get; set; }
    }
    [JsonObject(MemberSerialization.OptOut)]
    public class RoomShare 
    {
        public RoomShare()
        {

        }

        #region Private Properties
        private string _name;
        private string _nickname;
        private string _shareId;
        private long _size;
        private long _time;
        private int _type;
        private string _url;
        private string _userId;
        private string _filePath;
        private string _progress;
        private bool _allowDel;
        #endregion

        #region Public Properties
        /// <summary>
        /// 主键
        /// </summary>
        [Key]
        public string Id { get; set; }

        /// <summary>
        /// 房间Id
        /// </summary>
        public string roomId { get; set; }

        /// <summary>
        /// 文件名称
        /// </summary>
        public string name
        {
            get { return _name; }
            set { _name = value;  }
        }

        /// <summary>
        /// 上传的用户Id
        /// </summary>
        public string userId
        {
            get { return _userId; }
            set { _userId = value; }
        
        }

        /// <summary>
        /// 上传用户昵称
        /// </summary>
        public string nickname
        {
            get { return _nickname; }
            set { _nickname = value; }
        }

        /// <summary>
        /// 分享的Id
        /// </summary>
        public string shareId
        {
            get { return _shareId; }
            set { _shareId = value; }
        }

        /// <summary>
        /// 文件大小
        /// </summary>
        public long size
        {
            get { return _size; }
            set { _size = value; }
        }

        /// <summary>
        /// 时间
        /// </summary>
        public long time
        {
            get { return _time; }
            set { _time = value; }
        }

        /// <summary>
        /// 文件类型
        /// </summary>
        public int type
        {
            get { return _type; }
            set { _type = value; }
        }

        /// <summary>
        /// URL
        /// </summary>
        public string url
        {
            get { return _url; }
            set { _url = value; }
        }

        /// <summary>
        /// 文件路径
        /// </summary>
        public string filePath
        {
            get { return _filePath; }
            set { _filePath = value; }
        }
        
        [JsonIgnore]
        public string detial { get; set; }

        
        [JsonIgnore]
        public string progress
        {
            get
            {
                return _progress;
            }
            set
            {
                _progress = value;
            }
        }
        
        [JsonIgnore]
        /// <summary>
        /// 能否删除群文件操作
        /// </summary>
        public bool AllowDel
        {
            get
            {
                return _allowDel;
            }
            set
            {
                _allowDel = value;
            }
        }
        #endregion

        #region 序列化
        public string toJson()
        {
            return JsonConvert.SerializeObject(this);
        }
        #endregion

        #region 反序列化
        public RoomShare toModel(string roomJson)
        {
            RoomShare msgObj = JsonConvert.DeserializeObject<RoomShare>(roomJson);
            return msgObj;
        }
        #endregion

        #region 插入到数据库
        /// <summary>
        /// 插入到数据库
        /// </summary>
        public void Insert()
        {
            if (this.Id == null || this.Id == Guid.Empty.ToString("N"))
            {
                this.Id = Guid.NewGuid().ToString("N");
            }

            //DBSetting.dbContext.RoomShares.Add(this);
            //DBSetting.dbContext.SaveChanges();
            DBSetting.SQLiteDBContext.Insertable(this).ExecuteCommand();
        }
        #endregion

        #region 保存下载路径
        public void UpdateFilePath()
        {
            if (GetByShareId() == null)
            {
                Insert();
            }
            string id = GetByShareId().Id;
            //var result = (
            //        from share in DBSetting.dbContext.RoomShares
            //        where share.Id == id
            //        select share
            //        ).FirstOrDefault();
            //result.filePath = this.filePath;
            //DBSetting.dbContext.SaveChanges();
            DBSetting.SQLiteDBContext.Updateable<RoomShare>().UpdateColumns(it => new RoomShare() { filePath = this.filePath }).
                Where(s => s.Id == id).ExecuteCommand();
        }
        #endregion

        #region 根据roomId和ShareId获取对象
        public RoomShare GetByShareId()
        {
            //return DBSetting.dbContext.RoomShares.FirstOrDefault(d => d.roomId == this.roomId && d.shareId == this.shareId);
            return DBSetting.SQLiteDBContext.Queryable<RoomShare>().Single(r => r.roomId == this.roomId && r.shareId == this.shareId);
        }
        #endregion

        #region 根据roomId获取集合
        public List<RoomShare> GetListByRoomId()
        {
            //var result = (
            //        from share in DBSetting.dbContext.RoomShares
            //        where roomId == this.roomId
            //        select share
            //        );
            //return result.ToList();
            return DBSetting.SQLiteDBContext.Queryable<RoomShare>().Where(s => s.roomId == this.roomId).ToList();
        }
        #endregion
    }
}
