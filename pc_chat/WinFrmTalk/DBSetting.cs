using SqlSugar;
using System;
using System.Collections.Generic;
using System.IO;

namespace WinFrmTalk
{
    public static class DBSetting
    {
        #region 数据库连接
        private static string SQLiteDBConnectionStr
        {
            get
            {
                string path = string.Format(@"{0}\db\{1}.db", Environment.CurrentDirectory, Applicate.MyAccount.userId);
                if (!File.Exists(path))
                {
                    File.Create(path).Dispose();
                }
                return "Data Source=" + path + ";Version=3";
            }
        }
        public static SqlSugarClient SQLiteDBContext
        {
            get
            {
                return new SqlSugarClient(
                    new ConnectionConfig()
                    {
                        ConnectionString = SQLiteDBConnectionStr,
                        DbType = SqlSugar.DbType.Sqlite,//设置数据库类型
                        IsAutoCloseConnection = true,//自动释放数据务，如果存在事务，在事务结束后释放
                        InitKeyType = InitKeyType.Attribute, //从实体特性中读取主键自增列信息
                    });
            }
        }

        private static string SystemDBConnectionStr
        {
            get
            {
                string path = string.Format(@"{0}\db\shiku.db", Environment.CurrentDirectory);
                if (!File.Exists(path))
                {
                    File.Create(path).Dispose();
                }
                return "Data Source=" + path + ";Version=3";
            }
        }
        public static SqlSugarClient SystemDBContext
        {
            get
            {
                return new SqlSugarClient(
                    new ConnectionConfig()
                    {
                        ConnectionString = SystemDBConnectionStr,
                        DbType = SqlSugar.DbType.Sqlite,//设置数据库类型
                        IsAutoCloseConnection = true,//自动释放数据务，如果存在事务，在事务结束后释放
                        InitKeyType = InitKeyType.Attribute //初始化主键和自增列信息到ORM的方式，从数据库表中读取主键自增列信息
                        //InitKeyType = InitKeyType.Attribute //从实体特性中读取主键自增列信息
                    });
            }
        }

        private static string ConstantDBConnectionStr
        {
            get
            {
                string path = string.Format(@"{0}\db\constant.db", Environment.CurrentDirectory);
                if (!File.Exists(path))
                {
                    File.Create(path).Dispose();
                }
                return "Data Source=" + path + ";Version=3";
            }
        }
        public static SqlSugarClient ConstantDBContext
        {
            get
            {
                return new SqlSugarClient(
                    new ConnectionConfig()
                    {
                        ConnectionString = ConstantDBConnectionStr,
                        DbType = SqlSugar.DbType.Sqlite,//设置数据库类型
                        IsAutoCloseConnection = true,//自动释放数据务，如果存在事务，在事务结束后释放
                        InitKeyType = InitKeyType.Attribute //从实体特性中读取主键自增列信息
                    });
            }
        }
        #endregion
    }
}
