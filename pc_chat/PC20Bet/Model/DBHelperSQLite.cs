using System;
using System.Data;
using System.Data.SQLite;

namespace WinFrmTalk
{
    public class DBHelperSQLite
    {

        // 定义一个静态变量来保存类的实例
        private static DBHelperSQLite MyDBHelper;

        // 定义私有构造函数，使外界不能创建该类实例
        private DBHelperSQLite() { }

        /// <summary>  
        /// 连接字符串  
        /// </summary>  
        private static readonly string connectionString =
            //"server=.;uid=sa;pwd=123456;database=platepark";
            //"server=.;database=platepark;Trusted_Connection=SSPI";
            //@"Data Source=USER-20180814UR\SQLEXPRESS;Initial Catalog=platepark;Persist Security Info=True;User ID=sa;Password=123456;MultipleActiveResultSets=true;Pooling=true;";
            //ConfigurationManager.AppSettings["connectionString"];
            "Data Source=mydb.db;Version=3;";

        private static SQLiteConnection Connection =>
            new SQLiteConnection(connectionString);

        /// <summary>
        /// 定义公有方法提供一个全局访问点,同时你也可以定义公有属性来提供全局访问点
        /// </summary>
        /// <returns></returns>
        public static DBHelperSQLite GetDBHelper()
        {
            if (MyDBHelper == null)
            {
                // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
                // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
                // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
                // 双重锁定只需要一句判断就可以了
                lock (Connection)
                {
                    // 如果类的实例不存在则创建，否则直接返回
                    if (MyDBHelper == null)
                    {
                        MyDBHelper = new DBHelperSQLite();
                    }
                }
            }

            return MyDBHelper;
        }

        #region ExecuteNonQuery命令
        /// <summary>  
        /// 对数据库执行增、删、改命令  
        /// </summary>  
        /// <param name="safeSql">T-Sql语句</param>  
        /// <returns>受影响的记录数</returns>  
        public int ExecuteNonQuery(string safeSql)
        {

            Connection.Open();
            SQLiteTransaction trans = Connection.BeginTransaction();
            try
            {
                SQLiteCommand cmd = new SQLiteCommand(safeSql, Connection)
                {
                    Transaction = trans
                };

                if (Connection.State != ConnectionState.Open)
                {
                    Connection.Open();
                }
                int result = cmd.ExecuteNonQuery();
                trans.Commit();
                return result;
            }
            catch
            {
                trans.Rollback();
                return 0;
            }
        }

        /// <summary>  
        /// 对数据库执行增、删、改命令  
        /// </summary>  
        /// <param name="sql">T-Sql语句</param>  
        /// <param name="values">参数数组</param>  
        /// <returns>受影响的记录数</returns>  
        public int ExecuteNonQuery(string sql, SQLiteParameter[] values)
        {

            Connection.Open();
            SQLiteTransaction trans = Connection.BeginTransaction();
            try
            {
                SQLiteCommand cmd = new SQLiteCommand(sql, Connection)
                {
                    Transaction = trans
                };
                cmd.Parameters.AddRange(values);
                if (Connection.State != ConnectionState.Open)
                {
                    Connection.Open();
                }
                int result = cmd.ExecuteNonQuery();
                trans.Commit();
                return result;
            }
            catch (SQLiteException)
            {
                trans.Rollback();
                return 0;
            }
        }
        #endregion

        #region ExecuteScalar命令
        /// <summary>  
        /// 查询结果集中第一行第一列的值  
        /// </summary>  
        /// <param name="safeSql">T-Sql语句</param>  
        /// <returns>第一行第一列的值</returns>  
        public int ExecuteScalar(string safeSql)
        {

            if (Connection.State != ConnectionState.Open)
                Connection.Open();
            SQLiteCommand cmd = new SQLiteCommand(safeSql, Connection);
            int result = Convert.ToInt32(cmd.ExecuteScalar());
            return result;
        }

        /// <summary>  
        /// 查询结果集中第一行第一列的值  
        /// </summary>  
        /// <param name="sql">T-Sql语句</param>  
        /// <param name="values">参数数组</param>  
        /// <returns>第一行第一列的值</returns>  
        public int ExecuteScalar(string sql, SQLiteParameter[] values)
        {

            if (Connection.State != ConnectionState.Open)
                Connection.Open();
            SQLiteCommand cmd = new SQLiteCommand(sql, Connection);
            cmd.Parameters.AddRange(values);
            int result = Convert.ToInt32(cmd.ExecuteScalar());
            return result;
        }
        #endregion

        #region ExecuteReader命令
        /// <summary>  
        /// 创建数据读取器  
        /// </summary>  
        /// <param name="safeSql">T-Sql语句</param>  
        /// <param name="Connection">数据库连接</param>  
        /// <returns>数据读取器对象</returns>  
        public SQLiteDataReader ExecuteReader(string safeSql)
        {
            if (Connection.State != ConnectionState.Open)
                Connection.Open();
            SQLiteCommand cmd = new SQLiteCommand(safeSql, Connection);
            SQLiteDataReader reader = cmd.ExecuteReader();
            return reader;
        }

        /// <summary>  
        /// 创建数据读取器  
        /// </summary>  
        /// <param name="sql">T-Sql语句</param>  
        /// <param name="values">参数数组</param>  
        /// <param name="Connection">数据库连接</param>  
        /// <returns>数据读取器</returns>  
        public SQLiteDataReader ExecuteReader(string sql, SQLiteParameter[] values)
        {
            if (Connection.State != ConnectionState.Open)
                Connection.Open();
            SQLiteCommand cmd = new SQLiteCommand(sql, Connection);
            cmd.Parameters.AddRange(values);
            SQLiteDataReader reader = cmd.ExecuteReader();
            return reader;
        }
        #endregion

        #region ExecuteDataTable命令
        /// <summary>  
        /// 执行指定数据库连接对象的命令,指定存储过程参数,返回DataTable  
        /// </summary>  
        /// <param name="type">命令类型(T-Sql语句或者存储过程)</param>  
        /// <param name="safeSql">T-Sql语句或者存储过程的名称</param>  
        /// <param name="values">参数数组</param>  
        /// <returns>结果集DataTable</returns>  
        public DataTable ExecuteDataTable(CommandType type, string safeSql, params SQLiteParameter[] values)
        {

            if (Connection.State != ConnectionState.Open)
                Connection.Open();
            DataSet ds = new DataSet();
            SQLiteCommand cmd = new SQLiteCommand(safeSql, Connection)
            {
                CommandType = type
            };
            SQLiteDataAdapter da = new SQLiteDataAdapter(cmd);
            da.Fill(ds);
            return ds.Tables[0];
        }

        /// <summary>  
        /// 执行指定数据库连接对象的命令,指定存储过程参数,返回DataTable  
        /// </summary>  
        /// <param name="safeSql">T-Sql语句</param>  
        /// <returns>结果集DataTable</returns>  
        public DataTable ExecuteDataTable(string safeSql)
        {

            if (Connection.State != ConnectionState.Open)
                Connection.Open();
            DataSet ds = new DataSet();
            SQLiteCommand cmd = new SQLiteCommand(safeSql, Connection);
            SQLiteDataAdapter da = new SQLiteDataAdapter(cmd);
            try
            {
                da.Fill(ds);
            }
            catch (SQLiteException)
            {

            }
            return ds.Tables[0];
        }

        /// <summary>  
        /// 执行指定数据库连接对象的命令,指定存储过程参数,返回DataTable  
        /// </summary>  
        /// <param name="sql">T-Sql语句</param>  
        /// <param name="values">参数数组</param>  
        /// <returns>结果集DataTable</returns>  
        public DataTable ExecuteDataTable(string sql, params SQLiteParameter[] values)
        {

            if (Connection.State != ConnectionState.Open)
                Connection.Open();
            DataSet ds = new DataSet();
            SQLiteCommand cmd = new SQLiteCommand(sql, Connection)
            {
                CommandTimeout = 0
            };
            cmd.Parameters.AddRange(values);
            SQLiteDataAdapter da = new SQLiteDataAdapter(cmd);
            da.Fill(ds);
            return ds.Tables[0];
        }
        #endregion

        #region GetDataSet命令
        /// <summary>  
        /// 取出数据  
        /// </summary>  
        /// <param name="safeSql">sql语句</param>  
        /// <param name="tabName">DataTable别名</param>  
        /// <param name="values"></param>  
        /// <returns></returns>  
        public DataSet GetDataSet(string safeSql, string tabName, params SQLiteParameter[] values)
        {

            if (Connection.State != ConnectionState.Open)
                Connection.Open();
            DataSet ds = new DataSet();
            SQLiteCommand cmd = new SQLiteCommand(safeSql, Connection);

            if (values != null)
                cmd.Parameters.AddRange(values);

            SQLiteDataAdapter da = new SQLiteDataAdapter(cmd);
            try
            {
                da.Fill(ds, tabName);
            }
            catch (SQLiteException)
            {

            }
            return ds;
        }
        #endregion

        #region ExecureData 命令
        /// <summary>  
        /// 批量修改数据  
        /// </summary>  
        /// <param name="ds">修改过的DataSet</param>  
        /// <param name="strTblName">表名</param>  
        /// <returns></returns>  
        public int ExecureData(DataSet ds, string strTblName)
        {
            try
            {
                //创建一个数据库连接  
                if (Connection.State != ConnectionState.Open)
                    Connection.Open();

                //创建一个用于填充DataSet的对象  
                SQLiteCommand myCommand = new SQLiteCommand("SELECT * FROM " + strTblName, Connection);
                SQLiteDataAdapter myAdapter = new SQLiteDataAdapter
                {
                    //获取SQL语句，用于在数据库中选择记录  
                    SelectCommand = myCommand
                };

                //自动生成单表命令，用于将对DataSet所做的更改与数据库更改相对应  
                SQLiteCommandBuilder myCommandBuilder = new SQLiteCommandBuilder(myAdapter);

                return myAdapter.Update(ds, strTblName);  //更新ds数据  

            }
            catch (SQLiteException err)
            {
                throw err;
            }
        }
        #endregion

        /// <summary>
        /// 执行一条计算查询结果语句，返回查询结果（object）。
        /// </summary>
        /// <param name="SQLString">计算查询结果语句</param>
        /// <returns>查询结果（object）</returns>
        public T GetSingle<T>(string safeSql, params SQLiteParameter[] values)
        {
            try
            {
                if (Connection.State != ConnectionState.Open)
                    Connection.Open();
                SQLiteCommand cmd = new SQLiteCommand(safeSql, Connection);
                if (values != null)
                    cmd.Parameters.AddRange(values);
                object obj = cmd.ExecuteScalar();
                cmd.Parameters.Clear();
                if ((Object.Equals(obj, null)) || (Object.Equals(obj, System.DBNull.Value)))
                {
                    return default;
                }
                else
                {
                    if (obj is T res)
                    {
                        return res;
                    }
                    else
                    {
                        return default;
                    }
                }
            }
            catch (SQLiteException e)
            {
                throw e;
            }
        }


        public bool GetTable(string TabName)
        {
            try
            {
                    string strSql = string.Format("SELECT COUNT(*) as tab FROM sqlite_master where type='table' and name='{0}'", TabName);
                //using (SQLiteCommand cmd = new SQLiteCommand(strSql, connection))
                //{
                try
                {
                    Connection.Open();
                    DataTable dt = ExecuteDataTable(strSql);
                    int count = -1;
                    int.TryParse(dt.Rows[0]["tab"].ToString(), out count);
                    //打印
                    //ConsoleLog.Output(strSql);
                    return count > 0;
                }
                catch (System.Data.SQLite.SQLiteException E)
                {
                    Connection.Close();
                    throw new Exception(E.Message);
                }
                    //}
            }
            catch (Exception)
            {
                //ConsoleLog.Output(ex.Message);
                return false;
            }
        }
    }
}
