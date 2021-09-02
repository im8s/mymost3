using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Model
{
    /// <summary>
    /// 本地配置
    /// </summary>
    public class LocalConfigure
    {
        #region public member
        /// <summary>
        /// 该key是否存在
        /// </summary>
        [SugarColumn(IsIgnore = true)]
        public bool isHave { get; set; }

        /// <summary>
        /// 唯一标识
        /// </summary>
        [SugarColumn(IsPrimaryKey = true, IsNullable = false)]
        public string AppKey { get; set; }

        /// <summary>
        /// 数值型value
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int ValueInt { get; set; }

        /// <summary>
        /// 字符串型型value
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string ValueStr { get; set; }

        /// <summary>
        /// 长整形value
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public long ValueLong { get; set; }
        #endregion

        #region 创建数据库表
        private bool CreateLCTable()
        {
            try
            {
                var result = DBSetting.SystemDBContext.Queryable<sqlite_master>().Where(s => s.Name == "LocalConfigure" && s.Type == "table");
                if (result != null && result.Count() > 0)     //表存在
                {
                    return true;
                }
                //创建数据库表
                DBSetting.SystemDBContext.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(LocalConfigure));
                return true;
            }
            catch (Exception ex)
            {
               LogUtils.Log(ex.Message);
                return false;
            }
        }
        #endregion

        #region 插入数据
        public int InsertLCData()
        {
            if (CreateLCTable())
            {
                if (!DBSetting.SystemDBContext.Queryable<LocalConfigure>().Where(l => l.AppKey == this.AppKey).Any())
                    return DBSetting.SystemDBContext.Insertable(this).ExecuteCommand();
                else
                    return DBSetting.SystemDBContext.Updateable(this).ExecuteCommand();
            }
            return 0;
        }
        #endregion

        #region 查询数据
        /// <summary>
        /// 查询int类型的value
        /// </summary>
        /// <returns></returns>
        public int QueryIntValueByKey()
        {
            if(CreateLCTable())
            {
                var result = DBSetting.SystemDBContext.Queryable<LocalConfigure>().Single(lc => lc.AppKey == this.AppKey);
                this.isHave = result == null ? false : true;
                return result == null ? 0 : result.ValueInt;
            }
            return 0;
        }
        /// <summary>
        /// 查询string类型的value
        /// </summary>
        /// <returns></returns>
        public string QueryStrValueByKey()
        {
            if (CreateLCTable())
            {
                var result = DBSetting.SystemDBContext.Queryable<LocalConfigure>().Single(lc => lc.AppKey == this.AppKey);
                this.isHave = result == null ? false : true;
                return result == null ? "" : result.ValueStr;
            }
            return "";
        }

        /// <summary>
        /// 查询long类型的value
        /// </summary>
        /// <returns></returns>
        public long QueryLongValueByKey()
        {
            if (CreateLCTable())
            {
                var result = DBSetting.SystemDBContext.Queryable<LocalConfigure>().Single(lc => lc.AppKey == this.AppKey);
                this.isHave = result == null ? false : true;
                return result == null ? 0 : result.ValueLong;
            }
            return 0;
        }
        #endregion
    }
}
