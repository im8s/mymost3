using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Model
{
    class RoomMemberDao
    {
        private RoomMemberDao()
        {
        }
        private static RoomMemberDao _instance;
        public static RoomMemberDao Instance => _instance ?? (_instance = new RoomMemberDao());

        const string Tab_Head = "Member_";

        #region 判断表是否存在
        private bool CreateMemberTab(string roomId)
        {
            if (UIUtils.IsNull(roomId))
            {
                return false;
            }

            string TabName = Tab_Head + roomId;

            var db = DBSetting.SQLiteDBContext;
            db.MappingTables.RemoveAll(it => it.EntityName == "RoomMember");
            db.MappingTables.Add("RoomMember", TabName);

            //表存在
            if (db.Queryable<sqlite_master>().Where(s => s.Name == TabName && s.Type == "table").Any())
            {
                return true;
            }
            //创建数据库表
            db.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(RoomMember));
            return true;
        }
        #endregion


        #region 获取群成员身份
        /// <summary>
        /// 获取群成员身份
        /// <para>必须先给对象的roomId和userId赋值</para>
        /// 
        /// </summary>
        /// <returns>1=创建者 2=管理员 3=成员  4 隐身人</returns>
        public int GetRoleByUserId(string roomId, string userId)
        {
            if (CreateMemberTab(roomId))
            {
                string TabName = Tab_Head + roomId;
                var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName).Single(m => m.userId == userId);

                return result == null ? 0 : result.role;
            }
            return 0;
        }
        #endregion


    }
}
