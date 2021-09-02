using Newtonsoft.Json;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace WinFrmTalk
{

    /// <summary>
	/// user实体类(属性说明自动提取数据库字段的描述信息)
	/// </summary>
    [SugarTable("User")]
    public partial class LocalUser
    {
        #region Model
        private string _id;
        private string _userid;
        private string _telephone;
        private string _password;
        private long lastLoginTime;
        private int passwordLength;
        private double lastExitTime;

        /// <summary>
        /// 用户唯一ID
        /// </summary>
        [SugarColumn(IsPrimaryKey = true, IsNullable = false)]
        public string id
        {
            set { _id = value; }
            get { return _id; }
        }


        /// <summary>
        /// 上次退出时间
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public double LastExitTime
        {
            get { return lastExitTime; }
            set { lastExitTime = value; }
        }

        /// <summary>
        /// 本地用户UserId
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string UserId
        {
            set { _userid = value; }
            get { return _userid; }
        }

        /// <summary>
        /// 本地用户电话
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string Telephone
        {
            set { _telephone = value; }
            get { return _telephone; }
        }

        /// <summary>
        /// 本地用户密码
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string Password
        {
            set { _password = value; }
            get { return _password; }
        }

        /// <summary>
        /// 登录时间
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public long LastLoginTime
        {
            set { lastLoginTime = value; }
            get { return lastLoginTime; }
        }

        /// <summary>
        /// 密码长度
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int PasswordLength
        {
            set { passwordLength = value; }
            get { return passwordLength; }
        }

        #endregion


        //#region 实现数据库操作的构造函数
        ///// <summary>
        ///// 有参构造函数
        ///// </summary>
        //public LocalUser()
        //{
        //    //CreateUserTable();
        //}
        //#endregion

        //#region 创建数据库表
        //private void CreateUserTable()
        //{
        //    try
        //    {
        //        var result = DBSetting.SystemDBContext.Queryable<sqlite_master>().Where(s => s.Name == "User" && s.Type == "table");
        //        if (result != null && result.Count() > 0)     //表存在
        //            return;

        //        //创建数据库表
        //        DBSetting.SystemDBContext.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(LocalUser));
        //    }
        //    catch (Exception ex)
        //    {
        //       LogUtils.Log(ex.Message);
        //    }
        //}
        //#endregion

        //#region 插入或更新到数据库
        ///// <summary>
        ///// 插入或更新到数据库
        ///// </summary>
        //public int InsertOrUpdatePassword()
        //{
        //    if (this.id == null || this.id == Guid.Empty.ToString("N"))
        //    {
        //        this.id = Guid.NewGuid().ToString("N");
        //    }
        //    var item = DBSetting.SystemDBContext.Queryable<LocalUser>().First(l => l.Telephone == this.Telephone);
        //    if (item != null)//如果数据库存在项
        //    {
        //        return UpdatePwd(this.Telephone, this.Password, this.PasswordLength);//更新密码
        //    }
        //    else
        //    {
        //        return DBSetting.SystemDBContext.Insertable<LocalUser>(this).ExecuteCommand();//插入
        //    }
        //}
        //#endregion

        //#region 更新到数据库
        ///// <summary>
        ///// 更新到数据库
        ///// </summary>
        //public int Update()
        //{
        //    return DBSetting.SystemDBContext.Updateable(this).ExecuteCommand();
        //}
        //#endregion

        //#region 根据时间获取本地用户
        ///// <summary>
        ///// 根据时间获取本地用户
        ///// </summary>
        ///// <returns>最后登录的用户</returns>
        //internal LocalUser GetLastUserByTime()
        //{
        //    var result = DBSetting.SystemDBContext.Queryable<LocalUser>().OrderBy(l => l.LastLoginTime, SqlSugar.OrderByType.Asc).First();
        //    return result == null ? new LocalUser() : result;
        //}
        //#endregion

        //#region 更新到数据库
        ///// <summary>
        ///// 更新到数据库
        ///// </summary>
        //public int UpdatePwd(string phoneNumber, string password, int pwdLength)
        //{
        //    this.Password = password;
        //    this.PasswordLength = pwdLength;
        //    return DBSetting.SystemDBContext.Updateable<LocalUser>().
        //        UpdateColumns(it => new LocalUser() { Password = password, passwordLength = pwdLength}).
        //        Where(it => it.Telephone == phoneNumber).ExecuteCommand();     //单列可以用 it=>it.XId
        //}
        //#endregion

        //#region 获取上次的离线时间
        ///// <summary>
        ///// 获取上次的离线时间
        ///// </summary>
        ///// <param name="userId">用户ID</param>
        ///// <returns></returns>
        //internal double GetLastExitTime(string userId)
        //{
        //    double exitTime = 0;
        //    //if (DBSetting.SystemDbContext.user.Count(u => u.UserId == userId) > 0)//如果存在则查出
        //    //{
        //    //    var tmp = (from users in DBSetting.SystemDbContext.user
        //    //               where users.UserId == userId
        //    //               select users
        //    //                 ).FirstOrDefault(); //获取
        //    //    if (tmp != null)
        //    //    {
        //    //        exitTime = tmp.LastExitTime;
        //    //    }
        //    //}
        //    var item = DBSetting.SystemDBContext.Queryable<LocalUser>().Single(u => u.UserId == userId);
        //    exitTime = item == null ? 0 : item.LastExitTime;
        //    return exitTime;
        //}
        //#endregion

        //#region 更新上次离线时间
        ///// <summary>
        ///// 更新上次离线时间
        ///// </summary>
        ///// <param name="userId">对应的用户</param>
        ///// <param name="lastexittime">上次离线时间</param>
        //internal void UpdateLastExitTime(string userId, double lastexittime)
        //{
        //    try
        //    {
        //        var user = DBSetting.SystemDBContext.Queryable<LocalUser>().Single(u => u.UserId == userId);
        //        if (user != null)
        //        {
        //            ConsoleLog.Output("用户" + userId + "退出时间为:" + Helpers.StampToDatetime(LastExitTime).ToShortDateString());
        //            user.LastExitTime = lastexittime;//更新离线时间
        //            DBSetting.SystemDBContext.Updateable(user).ExecuteCommand();
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //       LogUtils.Log(ex.Message);
        //    }
        //}
        //#endregion

        //#region 删除
        ///// <summary>
        ///// 删除
        ///// </summary>
        //public int Delete(string userId)
        //{
        //    return DBSetting.SystemDBContext.Deleteable<LocalUser>().Where(new LocalUser() { UserId = userId }).ExecuteCommand();
        //}
        //#endregion

        //#region 序列化
        //public string toJson()
        //{
        //    return JsonConvert.SerializeObject(this);
        //}
        //#endregion

        //#region 反序列化
        //public LocalUser toModel(string strJson)
        //{
        //    LocalUser msgObj = JsonConvert.DeserializeObject<LocalUser>(strJson);
        //    return msgObj;
        //}
        //#endregion

        //#region 获取集合
        ///// <summary>
        ///// 获取集合
        ///// </summary>
        //public List<LocalUser> GetAllList()
        //{
        //    var result = new List<LocalUser>();
        //    //result = (
        //    //    from user in DBSetting.SystemDbContext.user
        //    //    select user
        //    //).ToList();
        //    result = DBSetting.SystemDBContext.Queryable<LocalUser>().ToList();
        //    return result;
        //}
        //#endregion

        //#region 获取对象
        //public LocalUser GetModel()
        //{
        //    var result = DBSetting.SystemDBContext.Queryable<LocalUser>().Single(u => u.UserId == this.UserId);
        //    return result == null ? new LocalUser() : result;
        //}
        //#endregion

        //#region 根据telephone获取对象
        //public LocalUser GetModelByPhone(string phoneNumber)
        //{
        //    var result = DBSetting.SystemDBContext.Queryable<LocalUser>().First(u => u.Telephone == phoneNumber);
        //    return result == null ? new LocalUser() : result;
        //}
        //#endregion


    }
}
