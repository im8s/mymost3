using SqlSugar;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace WinFrmTalk
{
    /// <summary>
	/// tb_areas:实体类(属性说明自动提取数据库字段的描述信息)
	/// </summary>
	[Serializable]
    [SugarTable("tb_areas")]
    public partial class Areas
    {
        public Areas()
        {
            CreateAreasTable();
        }

        //UserDBContext DBContext;
        #region Model
        private int _id;
        private int _parent_id;
        private int _type;
        private string _name;
        private string _zip;

        /// <summary>
        /// 唯一ID
        /// </summary>
        [SugarColumn(IsNullable = false, IsPrimaryKey = true)]
        public int id
        {
            set { _id = value; }
            get { return _id; }
        }
        /// <summary>
        /// 父级地区ID
        /// </summary>
        public int parent_id
        {
            set { _parent_id = value; }
            get { return _parent_id; }
        }
        /// <summary>
        /// 
        /// </summary>
        public int type
        {
            set { _type = value; }
            get { return _type; }
        }
        /// <summary>
        /// 
        /// </summary>
        public string name
        {
            set { _name = value; }
            get { return _name; }
        }

        /// <summary>
        /// 
        /// </summary>
        public string zip
        {
            set { _zip = value; }
            get { return _zip; }
        }
        #endregion Model
        public override string ToString()
        {
            return name;
        }

        #region 创建数据库表
        /// <summary>
        /// 创建数据库表
        /// </summary>
        private void CreateAreasTable()
        {
            try
            {
                var result = DBSetting.SystemDBContext.Queryable<sqlite_master>().Where(s => s.Name == "tb_areas" && s.Type == "table");
                if (result != null && result.Count() > 0)     //表存在
                    return;

                //创建数据库表
                DBSetting.SystemDBContext.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(Areas));
            }
            catch (Exception ex)
            {
               LogUtils.Log(ex.Message);
            }
        }
        #endregion

        #region 获取子项位置列表
        /// <summary>
        /// 获取子项位置列表
        /// </summary>
        /// <returns></returns>
        public List<Areas> GetChildrenList()
        {
            try
            {
                //var result = (from area in Applicate.SystemDbContext.tbareas
                //              where area.parent_id == this.parent_id
                //             && area.type == this.type
                //              select area
                //              ).ToList();
                List<Areas> result = DBSetting.SystemDBContext.Queryable<Areas>().
                    Where(a => a.parent_id == this.parent_id && a.type == this.type).ToList();
                if (result == null)
                {
                    return new List<Areas>();
                }
                return result;
            }
            catch (Exception ex)
            {
               LogUtils.Log(ex.Message);
                return null;
            }
        }
        #endregion

        /// <summary>
        /// 得到一个对象实体
        /// </summary>
        public Areas GetModel()
        {
            var result = DBSetting.SystemDBContext.Queryable<Areas>().Single(it => it.id == this.id);
            if (result == null)
            {
                result = new Areas();
            }

            return result;
        }
    }
}
