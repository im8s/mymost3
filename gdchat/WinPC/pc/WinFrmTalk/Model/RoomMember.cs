using Newtonsoft.Json;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;
using WinFrmTalk.Model;

namespace WinFrmTalk
{


    #region RoomMember
    /// <summary>
    /// 群聊中群聊个人的RoomMember
    /// </summary>
    public class RoomMember
    {
        /// <summary>
        /// 实例化对象时，rommId永远不能为空
        /// </summary>
        public RoomMember()
        {
        }


        #region Public Member

        /// <summary>
        /// 数据库预留（自增长主键id修改数据类型int）
        /// </summary>
        [SugarColumn(IsNullable = false, IsPrimaryKey = true, IsIdentity = true)]
        public int Id { get; set; }

        /// <summary>
        /// 群组Id
        /// <para>非Jid，roomjid仅用于连接，roomid用于查询和接口和其他</para>
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public string roomId { get; set; }

        /// <summary>
        /// 用户Id
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string userId { get; set; }

        /// <summary>
        /// 用户入群时间
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int createTime { get; set; }

        /// <summary>
        /// 修改时间
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int modifyTime { get; set; }

        /// <summary>
        /// 用户昵称
        /// </summary>
        [JsonProperty("nickname")]
        [SugarColumn(IsNullable = true)]
        public string nickName { get; set; }

        /// <summary>
        /// 消息免打扰1 是 0 否
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int offlineNoPushMsg { get; set; }
        /// <summary>
        /// 此用户在群组中的身份
        /// <para>1=创建者 2=管理员 3=成员  4 隐身人</para>
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int role { get; set; }
        /// <summary>
        /// 是否屏蔽消息0屏蔽消息，1不屏蔽
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public int sub { get; set; }

        /// <summary>
        /// 禁言时间
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public long talkTime { get; set; }
        /// <summary>
        /// 群主对群内成员的备注名 仅群主可见
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string remarkName { get; set; }

        /// <summary>
        /// 群名片名称
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string cardName { get; set; }


        [SugarColumn(IsIgnore = true)]
        private string TabName
        {
            get { return GetTabName(); }
        }


        /// <summary>
        /// 数据库表名
        /// <para>RoomId为空时，返回值为"Member_Null"</para>
        /// </summary>
        private string GetTabName()
        {
            if (this.roomId == null)
                return "Member_Null";
            return "Member_" + this.roomId;
        }
        #endregion

        #region 创建数据库表
        private bool CreateMemberTab()
        {
            var db = DBSetting.SQLiteDBContext;
            db.MappingTables.RemoveAll(it => it.EntityName == "RoomMember");
            db.MappingTables.Add("RoomMember", TabName);

            if (TabName == "Member_Null")
                return false;

            if (db.Queryable<sqlite_master>().Where(s => s.Name == TabName && s.Type == "table").Any())     //表存在
                return true;

            //创建数据库表
            db.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(RoomMember));
            return true;
        }
        #endregion

        #region 获取群成员身份
        /// <summary>
        /// 获取群成员身份
        /// <para>必须先给对象的roomId和userId赋值</para>
        /// </summary>
        /// <returns></returns>
        public int GetRoleByUserId()
        {
            if (CreateMemberTab())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName).Single(m => m.roomId == this.roomId && m.userId == this.userId);
                return result == null ? 0 : result.role;
            }
            return 0;
        }
        #endregion

        #region 自动批量插入或更新成员
        /// <summary>
        /// 自动批量插入或更新成员
        /// <para>必须先给roomId赋值</para>
        /// </summary>
        /// <param name="members">成员</param>
        public void AutoInsertOrUpdate(List<RoomMember> members)
        {
            foreach (var tmpmem in members.ToArray())
            {
                tmpmem.InsertOrUpdate();
            }
        }
        #endregion

        #region 保存某个成员
        /// <summary>
        /// 保存或更新成员
        /// <para>必须先给roomId赋值</para>
        /// </summary>
        /// <param name="members">成员</param>
        public void InsertOrUpdate()
        {
            if (CreateMemberTab())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName).First(m => m.userId == this.userId && m.roomId == this.roomId);
                if (result == null)
                {
                    DBSetting.SQLiteDBContext.Insertable(this).AS(TabName).ExecuteCommand(); ;
                }
                else
                {
                    result.role = this.role;
                    result.nickName = this.nickName;
                    result.createTime = this.createTime;
                    //更新用户在群的信息
                    DBSetting.SQLiteDBContext.Updateable(result).AS(TabName).Where(m => m.userId == this.userId && m.roomId == this.roomId).ExecuteCommand();
                }
            }
        }
        #endregion

        #region 删除单个用户
        /// <summary>
        /// 删除单个用户
        /// <para>必须先给userId赋值</para>
        /// </summary>
        public int DeleteByUserId()
        {
            if (CreateMemberTab())
            {
                return DBSetting.SQLiteDBContext.Deleteable<RoomMember>().Where(m => m.userId == this.userId).AS(TabName).ExecuteCommand();
            }
            return 0;
        }
        #endregion

        #region 删除某群的所有成员
        /// <summary>
        /// 删除某群的所有成员
        /// </summary>
        /// <returns>受影响行数</returns>
        public int DeleteByRoomId()
        {
            if (CreateMemberTab())
            {
                return DBSetting.SQLiteDBContext.Deleteable<RoomMember>().AS(TabName).ExecuteCommand();
            }
            return 0;
        }
        #endregion

        #region 更新群权限
        /// <summary>
        /// 更新用户的群权限
        /// <para>必须先给对象的role赋值</para>
        /// </summary>
        /// <returns>受影响行数</returns>
        public int UpdateRole()
        {
            if (CreateMemberTab())
            {
                return DBSetting.SQLiteDBContext.Updateable<RoomMember>().
                UpdateColumns(it => new RoomMember() { role = this.role }).
                Where(m => m.userId == this.userId && m.roomId == this.roomId).
                AS(TabName).ExecuteCommand();//保存数据库
            }
            return 0;
        }
        #endregion

        #region 更新禁言时间
        /// <summary>
        /// 更新禁言时间
        /// <para>必须先给对象的roomId,userId和talkTime赋值</para>
        /// </summary>
        /// <param name="roomId">房间Id</param>
        /// <param name="talkTime">禁言的结束时间</param>
        /// <returns>受影响行数</returns>
        public int UpdateTalkTime()
        {
            if (CreateMemberTab())
            {
                return DBSetting.SQLiteDBContext.Updateable<RoomMember>().
                UpdateColumns(it => new RoomMember() { talkTime = this.talkTime }).
                Where(m => m.userId == this.userId && m.roomId == this.roomId).
                AS(TabName).ExecuteCommand();
            }
            return 0;
        }
        #endregion

        #region 获取对象
        /// <summary>
        /// 根据UserId和roomId获取对象
        /// <para>必须先给对象的roomId和userId赋值</para>
        /// </summary>
        /// <returns></returns>
        public RoomMember GetRommMember()
        {
            if (CreateMemberTab())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName).
                First(m => m.userId == this.userId && m.roomId == this.roomId);
                return result == null ? new RoomMember() : result;
            }
            return new RoomMember();
        }
        #endregion

        #region 获取对象
        /// <summary>
        /// 根据UserId和roomId获取对象
        /// <para>必须先给对象的roomId和userId赋值</para>
        /// </summary>
        /// <returns></returns>
        public List<RoomMember> GetRommMemberList()
        {
            if (CreateMemberTab())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName).
                Where(m => m.roomId == this.roomId)
                .OrderBy(it => it.createTime, OrderByType.Desc)
                .OrderBy(it => it.nickName, OrderByType.Desc)
                .ToList();

                return result;
            }

            return null;
        }
        #endregion


        #region 群头像成员拼合顺序
        /// <summary>
        /// 根据UserId和roomId获取对象
        /// <para>必须先给对象的roomId和userId赋值</para>
        /// </summary>
        /// <returns></returns>
        public List<RoomMember> GetRommMemberListByHead()
        {
            if (CreateMemberTab())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName).
                Where(m => m.roomId == this.roomId).
                Where(m => m.role != 4)
                .OrderBy(it => it.role, OrderByType.Asc)
                .OrderBy(it => it.createTime, OrderByType.Desc)
                .ToList();

                return result;
            }

            return null;
        }
        #endregion


        #region 根据群聊ID查询
        /// <summary>
        /// 根据群聊ID查询
        /// <para>必须先给对象的roomId赋值</para>
        /// </summary>
        public List<RoomMember> GetListByRoomId()
        {
            if (CreateMemberTab())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName).Where(m => m.roomId == this.roomId).ToList();
                return result == null ? new List<RoomMember>() : result;
            }
            return new List<RoomMember>();
        }
        #endregion


        #region 根据GroupId获取成员数量
        /// <summary>
        /// 根据GroupId获取成员数量
        /// <para>必须先给对象的roomId赋值</para>
        /// </summary>
        /// <returns></returns>
        public List<RoomMember> GetMemberList(int pageIndex, int pageSize)
        {
            if (CreateMemberTab())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName)
                    .Where(m => m.roomId == this.roomId)
                    .OrderBy(it => it.role, OrderByType.Asc)
                    .OrderBy(it => it.createTime, OrderByType.Asc)
                    .ToPageList(pageIndex, pageSize);
                return result;
            }

            return null;
        }

        internal void InsertRange(List<RoomMember> members)
        {
            if (CreateMemberTab())
            {
                int result = 0;
                try
                {
                    if (!UIUtils.IsNull(members))
                    {
                        result = DBSetting.SQLiteDBContext.Insertable(members).ExecuteCommand();
                    }
                }
                catch (Exception)
                {
                  
                }
            }
        }
        #endregion

        #region liuhuan
        /// 允许会议
        /// </summary>
        [SugarColumn(IsIgnore = true)]
        public int allowConference { get; set; }

        /// <summary>
        /// 
        /// </summary>
        [SugarColumn(IsIgnore = true)]
        public int allowHostUpdate { get; set; }

        /// <summary>
        /// 允许邀请朋友
        /// </summary>
        [SugarColumn(IsIgnore = true)]
        public int allowInviteFriend { get; set; }

        /// <summary>
        /// 
        /// </summary>
        [SugarColumn(IsIgnore = true)]
        public int allowSendCard { get; set; }
        /// <summary>
        /// 
        /// </summary>
        [SugarColumn(IsIgnore = true)]
        public int allowSpeakCourse { get; set; }
        /// <summary>
        /// 
        /// </summary>
        [SugarColumn(IsIgnore = true)]
        public int allowUploadFile { get; set; }

        /// <summary>
        /// 
        /// </summary>
        [SugarColumn(IsIgnore = true)]
        public string desc { get; set; }

        [SugarColumn(IsIgnore = true)]
        public int isAttritionNotice { get; set; }

        [SugarColumn(IsIgnore = true)]
        public int isLook { get; set; }

        [SugarColumn(IsIgnore = true)]
        public int isNeedVerify { get; set; }

        [SugarColumn(IsIgnore = true)]
        public string notice { get; set; }

        [SugarColumn(IsIgnore = true)]
        public List<GroupNotices> NoticeLst { set; get; }

        [SugarColumn(IsIgnore = true)]
        public int showMember { get; set; }

        [SugarColumn(IsIgnore = true)]
        public int showRead { get; set; }



        [SugarColumn(IsIgnore = true)]
        public string GroupName { get; set; }
        #endregion

        #region 更新成员昵称
        /// <summary>
        /// 更新成员昵称
        /// <para>必须先给对象的userId,roomId和nickName赋值</para>
        /// </summary>
        internal int UpdateMemberNickname()
        {
            if (CreateMemberTab())
            {
                var result = DBSetting.SQLiteDBContext.Updateable<RoomMember>().AS(TabName).
                UpdateColumns(it => new RoomMember() { nickName = this.nickName }).
                Where(m => m.userId == this.userId && m.roomId == this.roomId).ExecuteCommand();
                return result;
            }
            return 0;
        }
        #endregion

        #region 根据RoomId获取群成员数量
        /// <summary>
        /// 根据RoomId获取群成员数量
        /// <para>必须先给对象的roomId赋值</para>
        /// </summary>
        /// <param name="roomid">RoomId</param>
        /// <returns></returns>
        internal int GetCountByRoomId()
        {
            if (CreateMemberTab())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName).Where(m => m.roomId == this.roomId).Count();
                return result;
            }
            return 0;
        }
        #endregion

        #region 获取群主备注
        /// <summary>
        /// 获取群主备注
        /// </summary>
        /// <returns></returns>
        public string GetRemarkName()
        {
            if (CreateMemberTab())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName).Single(m => m.userId == this.userId);
                return result != null ? result.remarkName : "";
            }
            return "";
        }
        #endregion

        #region 获取群昵称
        /// <summary>
        /// 获取群昵称
        /// </summary>
        /// <returns></returns>
        public string GetNickName()
        {
            if (CreateMemberTab())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName).Single(m => m.userId == this.userId);
                return result != null ? result.nickName : "";
            }
            return "";
        }
        #endregion


        public void UpdateRoomUser(Dictionary<string, object> member)
        {
            if (member == null || member.Count == 0)
            {
                return;
            }

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

            // id
            userId = UIUtils.DecodeString(member, "userId");
            // 昵称
            nickName = UIUtils.DecodeString(member, "nickname");
            // 加入时间
            createTime = (int)UIUtils.DecodeLong(member, "createTime");
            // 1创建者，2管理员，3成员, 4, 隐身人，5，监控人隐身人和监控人：
            // 即群主设置某成员为这2个角色，则群员数量减1,其他人完全看不到他；隐身人和监控人的区别是，前者不可以说话，后者能说话。
            role = UIUtils.DecodeInt(member, "role");
            // 禁言时间
            talkTime = UIUtils.DecodeLong(member, "talkTime");
            // 0屏蔽消息，1不屏蔽
            sub = UIUtils.DecodeInt(member, "sub");



            if (CreateMemberTab())
            {
                if (!DBSetting.SQLiteDBContext.Queryable<RoomMember>().Where(m => m.roomId == roomId && m.userId == userId).AS(TabName).Any())
                {
                    DBSetting.SQLiteDBContext.Insertable(this).AS(TabName).ExecuteCommand(); ;
                }
                else
                {
                    //更新用户在群的信息
                    DBSetting.SQLiteDBContext.Updateable<RoomMember>().
                            UpdateColumns(f => new RoomMember()
                            {
                                nickName = this.nickName,
                                createTime = this.createTime,
                                role = this.role,
                                talkTime = this.talkTime,
                                sub = this.sub,
                            }).
                            Where(m => m.userId == userId && m.roomId == roomId).AS(TabName).ExecuteCommand();
                }
            }
        }

        public List<RoomMember> TransToMember(Dictionary<string, object> keyValues, string roomid)
        {
            NoticeLst = new List<GroupNotices>();
            //var Tipstext = "";
            if (keyValues.ContainsKey("allowConference"))
            {
                allowConference = Convert.ToInt32(keyValues["allowConference"].ToString());
            }
            if (keyValues.ContainsKey("allowHostUpdate"))
            {
                allowHostUpdate = Convert.ToInt32(keyValues["allowHostUpdate"].ToString());
            }
            if (keyValues.ContainsKey("allowInviteFriend"))
            {
                allowInviteFriend = Convert.ToInt32(keyValues["allowInviteFriend"].ToString());
            }
            if (keyValues.ContainsKey("allowSendCard"))
            {
                allowSendCard = Convert.ToInt32(keyValues["allowSendCard"].ToString());
            }
            if (keyValues.ContainsKey("notice"))
            {
                allowSpeakCourse = Convert.ToInt32(keyValues["allowSpeakCourse"].ToString());

            }
            if (keyValues.ContainsKey("allowUploadFile"))
            {
                allowUploadFile = Convert.ToInt32(keyValues["allowUploadFile"].ToString());

            }

            if (keyValues.ContainsKey("desc"))
            {
                desc = keyValues["desc"].ToString();

            }

            if (keyValues.ContainsKey("isAttritionNotice"))
            {
                isAttritionNotice = Convert.ToInt32(keyValues["isAttritionNotice"].ToString());

            }
            if (keyValues.ContainsKey("isLook"))
            {
                isLook = Convert.ToInt32(keyValues["isLook"].ToString());

            }
            if (keyValues.ContainsKey("isNeedVerify"))
            {
                isNeedVerify = Convert.ToInt32(keyValues["isNeedVerify"].ToString());

            }


            if (keyValues.ContainsKey("notice"))
            {
                notice = keyValues["notice"].ToString();
            }

            if (keyValues.ContainsKey("showMember"))
            {
                showMember = Convert.ToInt32(keyValues["showMember"].ToString());
            }

            if (keyValues.ContainsKey("name"))
            {
                GroupName = keyValues["name"].ToString();
            }

            talkTime = UIUtils.DecodeLong(keyValues, "talkTime");

            if (keyValues.ContainsKey("showRead"))
            {
                showRead = Convert.ToInt32(keyValues["showRead"]);
            }

            //  List<GroupNotices> GrouptipsLst = new List<GroupNotices>();
            if (keyValues.ContainsKey("notices"))
            {

                var notices = JsonConvert.DeserializeObject<List<object>>(keyValues["notices"].ToString());

                foreach (var item in notices)
                {

                    GroupNotices grouptips = new GroupNotices();
                    var notic = JsonConvert.DeserializeObject<Dictionary<string, object>>(item.ToString());
                    grouptips.text = UIUtils.DecodeString(notic, "text");
                    grouptips.NickName = UIUtils.DecodeString(notic, "nickname");
                    grouptips.Userid = UIUtils.DecodeString(notic, "userId");
                    grouptips.Roomid = UIUtils.DecodeString(notic, "roomId");
                    grouptips.Id = UIUtils.DecodeString(notic, "id");
                    grouptips.Time = UIUtils.DecodeInt(notic, "time");


                    NoticeLst.Add(grouptips);
                    //string content = UIUtils.DecodeString(notic,"text");
                    //string content = UIUtils.DecodeString(notic,"text");



                    //if(noticsLst.ContainsKey("text"))
                    //{

                    //    string str = noticsLst["text"].ToString(); //  ReplaceString();

                    //    var textlst = JsonConvert.DeserializeObject<Dictionary<string, string>>(str);

                    //    foreach (var textvalue in textlst)
                    //    {
                    //        var textitem = JsonConvert.DeserializeObject<Dictionary<string, object>>(textvalue.ToString());

                    //        if(textitem.ContainsKey("text"))
                    //        {
                    //            Tipstext = "";
                    //        }
                    //        else
                    //        {
                    //            Tipstext= UIUtils.DecodeString(textitem, "text").ToString();
                    //        }
                    //        NoticeLst.Add(Tipstext.ToString());
                    //    }
                    //}

                }
            }
            List<RoomMember> memberLst = new List<RoomMember>();
            if (keyValues.ContainsKey("members"))
            {
                var members = JsonConvert.DeserializeObject<List<object>>(keyValues["members"].ToString());
                RoomMember room = new RoomMember();
                room.roomId = roomId;
                foreach (var item in members)
                {
                    var member = JsonConvert.DeserializeObject<Dictionary<string, object>>(item.ToString());
                    RoomMember roomMember = new RoomMember();
                    roomMember.role = UIUtils.DecodeInt(member, "role");
                    roomMember.userId = UIUtils.DecodeString(member, "userId");
                    roomMember.createTime = UIUtils.DecodeInt(member, "createTime");
                    roomMember.modifyTime = UIUtils.DecodeInt(member, "modifyTime");
                    roomMember.nickName = UIUtils.DecodeString(member, "nickname");
                    roomMember.offlineNoPushMsg = UIUtils.DecodeInt(member, "offlineNoPushMsg");
                    roomMember.sub = UIUtils.DecodeInt(member, "sub");
                    roomMember.talkTime = UIUtils.DecodeLong(member, "talkTime");
                    roomMember.remarkName = UIUtils.DecodeString(member, "remarkName");
                    roomMember.cardName = UIUtils.DecodeString(member, "cardName");
                    roomMember.roomId = roomid;

                    memberLst.Add(roomMember);
                    roomMember.InsertOrUpdate();

                }
            }

            return memberLst;
        }

    }
    #endregion
}
