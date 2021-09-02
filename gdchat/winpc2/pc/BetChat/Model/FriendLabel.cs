using Newtonsoft.Json.Linq;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    /// <summary>
    /// 好友标签表
    /// 2019-4-23 17:33:50
    /// </summary>
    public class FriendLabel
    {

        /// <summary>
        /// 标签id
        /// </summary>
        [SugarColumn(IsNullable = false, IsPrimaryKey = true, Length = 128)]
        public string groupId { get; set; }

        /// <summary>
        /// 标签名称
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string groupName { get; set; }



        /// <summary>
        /// 创建者ID
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string userId { get; set; }

        /// <summary>
        /// 标签好友集
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string userIdList { get; set; }


        public int friendCount;

        public string[] friends;

        public int GetFriendCount()
        {
            List<Friend> list = GetFriendList();
            if (list != null)
            {
                return list.Count;
            }

            return 0;
        }

        internal string GetFriendNames()
        {
            List<Friend> friends = GetFriendList();

            if (!UIUtils.IsNull(friends))
            {

                string str = string.Empty;

                foreach (var item in friends)
                {
                    str += item.GetRemarkName() + ",";

                    if (str.Length >= 15)
                    {
                        return str;
                    }
                }

                return str;
            }

            return "";
        }

        public List<Friend> GetFriendList()
        {
            if (userIdList == null || userIdList.Length < 2)
            {
                return null;
            }

            JArray array = JArray.Parse(userIdList);

            List<Friend> friendlst = new List<Friend>();
            for (int i = 0; i < array.Count; i++)
            {
                string userid = array[i].ToString();
                Friend friend = new Friend() { UserId = userid }.GetByUserId();
                friendlst.Add(friend);
            }

            return friendlst;
        }

        public List<RoomMember> GetRoomMemberList()
        {
            if (userIdList == null || userIdList.Length < 2)
            {
                return null;
            }

            JArray array = JArray.Parse(userIdList);

            List<RoomMember> friendlst = new List<RoomMember>();
            for (int i = 0; i < array.Count; i++)
            {
                string userid = array[i].ToString();
                RoomMember friend = new RoomMember() { userId = userid };
                friendlst.Add(friend);
            }

            return friendlst;
        }

        #region 创建数据库表
        /// <summary>
        /// 创建数据库表
        /// </summary>
        private bool CreateLabelTable()
        {
            try
            {
                var db = DBSetting.SQLiteDBContext;
                var result = db.Queryable<sqlite_master>().Where(s => s.Name == "FriendLabel" && s.Type == "table");
                if (result != null && result.Count() > 0)     //表存在
                {
                    return true;
                }
                //创建数据库表
                db.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(FriendLabel));
                return true;
            }
            catch (Exception ex)
            {
                LogUtils.Log(ex.Message);
                return false;
            }
        }
        #endregion



        #region 插入到数据库
        /// <summary>
        /// 插入到数据库
        /// </summary>
        public bool InsertAuto()
        {
            if (CreateLabelTable())
            {
                var db = DBSetting.SQLiteDBContext;
                var friend = db.Queryable<FriendLabel>().Single(f => f.groupId == this.groupId);
                int result = 0;
                if (friend == null)
                {
                    result = db.Insertable(this).ExecuteCommand();
                }
                else
                {
                    result = db.Updateable(this).ExecuteCommand();//更新
                }
                return result > 0 ? true : false;
            }
            return false;
        }
        #endregion

        #region 从数据库删除
        /// <summary>
        /// 根据userId批量删除
        /// </summary>
        public int DeleteByUserId()
        {
            if (CreateLabelTable())
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
                    return DBSetting.SQLiteDBContext.Deleteable<FriendLabel>().Where(f => f.groupId == this.groupId).ExecuteCommand();
                }
                catch (Exception e)
                {
                    ConsoleLog.Output(e.Message);
                }
            }
            return 0;
        }
        #endregion
       
      



        #region 根据Userid查询
        /// <summary>
        /// 根据Userid查询
        /// </summary>
        public List<FriendLabel> queryUserId()
        {
            if (CreateLabelTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<FriendLabel>().Where(f => f.userIdList.Contains(this.userIdList)).ToList();
                return result == null ? new List<FriendLabel>() : result;
            }

            return new List<FriendLabel>();
        }
        #endregion
        /// <summary>
        /// 创建的标签
        /// </summary>
        /// <returns></returns>
        public List<FriendLabel> getUserId()
        {
            if (CreateLabelTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<FriendLabel>().Where(f => f.userId.Contains(this.userId)).ToList();
                return result == null ? new List<FriendLabel>() : result;
            }

            return new List<FriendLabel>();
        }


        #region 下载好友标签到数据库
        public void SaveLableList(List<FriendLabel> data)
        {
            foreach (var item in data)
            {
                if (!item.InsertAuto())
                {
                    LogUtils.Log("好友标签更新失败" + item.groupName);
                }
            }
        }

        #endregion

        #region 下载好友标签到数据库

        public void DownLable(Action binding)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "friendGroup/list")
                .AddParams("access_token", Applicate.Access_Token).Build().Execute((sus, data) =>
                {
                    if (sus)
                    {
                        if (CreateLabelTable())
                        {
                            DBSetting.SQLiteDBContext.Deleteable<FriendLabel>().ExecuteCommand();
                        }


                        JArray arrlist = JArray.Parse(UIUtils.DecodeString(data, "data"));
                        foreach (var arr in arrlist)
                        {
                            FriendLabel lable = new FriendLabel() { groupId = UIUtils.DecodeString(arr, "groupId"), groupName = UIUtils.DecodeString(arr, "groupName"), userId = UIUtils.DecodeString(arr, "userId"), userIdList = UIUtils.DecodeString(arr, "userIdList") };

                            bool state = lable.InsertAuto();
                            if (state)
                            {
                                LogUtils.Log("好友标签下载更新成功");
                            }

                            if (!state)
                            {
                                LogUtils.Log(lable.groupId);
                                LogUtils.Log("好友标签下载更新失败");
                            }
                            if (binding != null)
                            {
                                binding();
                            }
                        }
                    }
                });
        }

        #endregion

    }
}
