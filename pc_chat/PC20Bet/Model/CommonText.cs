using System;
using SqlSugar;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Windows.Input;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Model
{
    /// <summary>
    /// 常用文本
    /// </summary>
   public  class CommonText
    {
        /// <summary>
        /// 文本id（主键)
        /// </summary>
        [Key]
        [SugarColumn(IsNullable = false, IsPrimaryKey = true, Length = 128)]
        public string contentid { get; set; }
        /// <summary>
        ///常用语
        /// </summary>
        [SugarColumn(IsNullable = false)]
        public string content { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public double createtime { get; set; }

        /// <summary>
        /// 修改者id
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string modifyUserId { get; set; }
        
       [SugarColumn(IsNullable = true)]
        public string createUserId { get; set; }
        /// <summary>
        /// 创建数据库表
        /// </summary>
        /// <returns></returns>
        public  bool  CreateCommonText()
        {
            try
            {
                var result = DBSetting.SQLiteDBContext.Queryable<sqlite_master>().Where(s => s.Name == "CommonText" && s.Type == "table");
                if (result != null && result.Count() > 0)     //表存在
                {
                    return true;
                }
                //创建数据库表
                DBSetting.SQLiteDBContext.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(CommonText));
                return true;
            }
            catch (Exception ex)
            {
                LogUtils.Log(ex.Message);
                return false;
            }
        }

        #region 插入到数据库
        /// <summary>
        /// 插入到数据库
        /// </summary>
        public bool InsertAuto()
        {
            if (CreateCommonText())
            {
                var friend = DBSetting.SQLiteDBContext.Queryable<CommonText>().Single(f => f.contentid == this.contentid);
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


        #region 根据contentid批量删除
        /// <summary>
        /// 根据userId批量删除
        /// </summary>
        public int DeleteByUserId()
        {
            if (CreateCommonText())
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
                    return DBSetting.SQLiteDBContext.Deleteable<CommonText>().Where(f => f.contentid == this.contentid).ExecuteCommand();
                }
                catch (Exception e)
                {
                    ConsoleLog.Output(e.Message);
                }
            }
            return 0;
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
            if (CreateCommonText())
            {
                return DBSetting.SQLiteDBContext.Queryable<CommonText>().Where(f => f.contentid == contentid).Any();
            }
            return false;
        }
        #endregion
        #region 
        /// <summary>
       
        /// </summary>
        public List<CommonText> GetListByCreateid()
        {
            if (CreateCommonText())
            {
                //var result = DBSetting.SQLiteDBContext.Queryable<RoomMember>().AS(TabName).Where(m => m.roomId == this.roomId).ToList();
                //return result == null ? new List<RoomMember>() : result;
                var result = DBSetting.SQLiteDBContext.Queryable<CommonText>()
                    .ToList();
                return result == null ? new List<CommonText>() : result;
            }
            return new List<CommonText>();
        }
        #endregion
    }
}
