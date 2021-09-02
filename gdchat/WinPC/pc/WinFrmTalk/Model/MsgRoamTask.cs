using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Model
{
    class MsgRoamTask
    {

        #region public member
        /// <summary>
        /// 唯一标识
        /// </summary>
        [SugarColumn(IsPrimaryKey = true, IsNullable = false)]
        public long taskId { get; set; }

        /// <summary>
        /// 字符串型型value
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string ownerId { get; set; }

        /// <summary>
        /// 当前任务属于哪个群组
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string userId { get; set; }

        /// <summary>
        /// 起始msgId
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string startMsgId { get; set; }

        /// <summary>
        /// 漫游开始时间
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public double startTime { get; set; }

        /// <summary>
        /// 漫游结束时间
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public double endTime { get; set; }

        /// <summary>
        /// 是否完成
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int isFinish { get; set; }

        #endregion


        #region 创建数据库表
        private bool CreateRoamTaskTable()
        {
            try
            {
                var result = DBSetting.SQLiteDBContext.Queryable<sqlite_master>().Where(s => s.Name == "MsgRoamTask" && s.Type == "table");
                if (result != null && result.Count() > 0)     //表存在
                {
                    return true;
                }
                //创建数据库表
                DBSetting.SQLiteDBContext.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(MsgRoamTask));
                return true;
            }
            catch (Exception ex)
            {
                LogUtils.Log(ex.Message);
                return false;
            }
        }
        #endregion


        #region 创建任务
        public int CreateTask()
        {
            if (CreateRoamTaskTable())
            {
                return DBSetting.SQLiteDBContext.Insertable(this).ExecuteCommand();

            }
            return 0;
        }
        #endregion


        #region 删除任务
        public int DeleteTask()
        {
            if (CreateRoamTaskTable())
            {
                int result = DBSetting.SQLiteDBContext.Deleteable<MsgRoamTask>()
                  .Where(m => m.ownerId == this.ownerId).
                  Where(m => m.userId == this.userId).
                  Where(m => m.taskId == this.taskId).
                  ExecuteCommand();
                return result;
            }

            return 0;
        }
        #endregion


        #region 删除任务
        public int DeleteTaskAll()
        {
            if (CreateRoamTaskTable())
            {
                int result = DBSetting.SQLiteDBContext.Deleteable<MsgRoamTask>()
                  .Where(m => m.ownerId == this.ownerId)
                  .Where(m => m.userId == this.userId)
                  .ExecuteCommand();
                return result;
            }

            return 0;
        }
        #endregion

        #region 修改任务的endTime
        public int UpdateTaskEndTime(double end)
        {
            if (CreateRoamTaskTable())
            {
                int result = DBSetting.SQLiteDBContext.Updateable<MsgRoamTask>()
                    .UpdateColumns(it => new MsgRoamTask() { endTime = end })
                    .Where(it => it.taskId == this.taskId)
                    .ExecuteCommand();
                return result;
            }

            return 0;
        }
        #endregion

        #region 查询最后一条任务
        /// <summary>
        /// 查询int类型的value
        /// </summary>
        /// <returns></returns>
        public MsgRoamTask QueryLastTask()
        {
            if (CreateRoamTaskTable())
            {
                var result = DBSetting.SQLiteDBContext.Queryable<MsgRoamTask>()
                    .Where(it => it.ownerId.Equals(this.ownerId))
                    .Where(it => it.userId.Equals(this.userId))
                    .OrderBy(m => m.taskId, OrderByType.Desc)
                    .First();
                return result;
            }

            return null;
        }

        #endregion
    }
}
