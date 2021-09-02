using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk.Model;

namespace WinFrmTalk.Model
{

    /// <summary>
    /// 国际化时
    /// </summary>
    [SugarTable("SMS_country")]
    public class Country 
    {
        
        #region Private Member
        private int _id;
        private string _enName;
        private string _country;
        private int _prefix;
        private double _price;
        #endregion

        #region
        public void CreateCountryTable()
        {
            var result = DBSetting.ConstantDBContext.Queryable<sqlite_master>().Where(s => s.Name == "Country" && s.Type == "table");
            if (result != null && result.Count() > 0)     //表存在
                return;
            DBSetting.SystemDBContext.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(Friend));
        }
        #endregion

        #region Public Member

        /// <summary>
        /// ID
        /// </summary>
        [SugarColumn(IsPrimaryKey = true, IsNullable = false)]
        public int id
        {
            get { return _id; }
            set { _id = value;  }
        }

        /// <summary>
        /// 英语名称
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string enName
        {
            get { return _enName; }
            set { _enName = value; }
        }

        /// <summary>
        /// 中文名称
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string country
        {
            get { return _country; }
            set { _country = value; }
        }


        /// <summary>
        /// 区号
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int prefix
        {
            get { return _prefix; }
            set { _prefix = value;  }
        }

        /// <summary>
        /// Price ？
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public double price
        {
            get { return _price; }
            set { _price = value; }
        }

        #endregion

        #region Public Method

        public List<Country> GetCountries()
        {
            //ConstantDBContext.DBAutoConnect();
            //var countries = new List<Country>();
            //DBSetting.ConstantDBContext
            //countries = (from country in DBSetting.ConstantDBContext.Countrys
            //             where country.id > 0
            //             orderby country.country ascending
            //             select country).ToList();
            var countries = DBSetting.ConstantDBContext.Queryable<Country>().Where(c => c.id > 0).OrderBy(c => c.prefix).ToList();
            return countries;
        }
        #endregion



    }
}
