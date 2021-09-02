using SqlSugar;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Windows.Input;

namespace WinFrmTalk.Model
{
    public class VerifingFriend
    {

        #region Public Member

        /// <summary>
        /// 验证中好友的UserId
        /// </summary>
        [Key]
        [SugarColumn(IsNullable = false, IsPrimaryKey = true, Length = 128)]
        public string userId { get; set; }

        /// <summary>
        /// 好友创建时间戳
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int createTime { get; set; } = 0;

        /// <summary>
        /// 最后一次聊天时间戳
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public double lastMsgTime { get; set; }

        /// <summary>
        /// 未读消息数量
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int msgNum { get; set; }

        /// <summary>
        /// 与该好友的状态（-1:黑名单；0：陌生人；1:单方关注；2:互为好友；8:系统号；9:非显示系统号）
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int status { get; set; }

        /// <summary>
        /// 好友昵称/名称
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string nickName { get; set; }

        /// <summary>
        /// 好友区号，例如86是中国
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int areaCode { get; set; }

        /// <summary>
        /// 区id
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int areaId { get; set; }

        /// <summary>
        /// 城市id
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int cityId { get; set; }

        /// <summary>
        /// 个人说明，个性签名
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string description { get; set; }

        /// <summary>
        /// 省份id
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int provinceId { get; set; }

        /// <summary>
        /// 性别
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int sex { get; set; }

        /// <summary>
        /// 手机号
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string telephone { get; set; }

        /// <summary>
        /// 备注名
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string remarkName { get; set; }

        /// <summary>
        /// 是否群组
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int isGroup { get; set; }

        /// <summary>
        /// 最后一条消息的类型
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int Type { get; set; }

        /// <summary>
        /// 房间的jid
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string roomJid { get; set; }

        /// <summary>
        /// 最近输入( 未发送的草稿)
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string lastInput { get; set; }

        /// <summary>
        /// 好友身份身份  1=游客（⽤用于后台浏览数据）；2=公众号 ；3=机器账号，由系统⾃自动⽣生成；4=客服账号;5=管理员；6=超级管理员；7=财务； 
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string role { get; set; }

        /// <summary>
        ///  群组⾥里里⾯面是否有@我的消息 
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int isAtMe { get; set; }

        /// <summary>
        /// 是否显示已读
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int showRead { get; set; }

        /// <summary>
        /// 是否显示群成员
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int showMember { get; set; }

        /// <summary>
        /// 允许普通群成员私聊
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int allowSendCard { get; set; }

        /// <summary>
        /// 允许普通群成员邀请好友
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int allowInviteFriend { get; set; }


        /// <summary>
        /// 允许普通群成员上传文件
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int allowUploadFile { get; set; }

        /// <summary>
        /// 允许普通群成员召开会议
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int allowConference { get; set; }

        /// <summary>
        /// 允许普通群成员发起讲课
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int allowSpeakCourse { get; set; }

        /// <summary>
        /// 此群组是否开始阅后即焚
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int isOpenReadDel { get; set; }

        /// <summary>
        /// 是否是设备（多点登录使用，辨识是我的设备还是用户）
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int isDevice { get; set; } = 0;




        /// <summary>   
        /// 状态
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public string StatusTag { get; set; }

        /*<para>-6:对方添加我方，我回话；-5:我方添加对方, 对方回话；</para>*/
        /// <summary>
        /// <para>验证状态：</para>
        /// <para> -4:对方添加自己为好友；-3:我方添加对方为好友；-2:对方拉黑自己；-1我方拉黑对方</para>
        /// <para>0:陌生人；1:互为好友；2:白名单；3:系统号；4:非显示系统号</para>
        /// </summary>
        /// 
        public int VerifyStatus { get; set; }

        /// <summary>
        /// 我的某一个设备是否在线（多点登录使用，标识我的某一个设备是否在线）
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int isOnLine { get; set; } = -1;

        /// <summary>
        /// 是否要转发给此用户（多点登录使用，是否要转发消息给此用户（当前账号的其他设备））
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int isSendRecipt { get; set; }

        /// <summary>
        /// 置顶时间
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int topTime { get; set; }

        /// <summary>
        /// 是否开启群主验证
        /// </summary>
        [SugarColumn(IsNullable = true)]
        public int isNeedVerify { get; set; }


        [SugarColumn(IsNullable = true)]
        public string Content { get; set; }

        #endregion

        #region 转Friend
        internal Friend ToFriend()
        {
            var friend = new Friend
            {
                UserId = this.userId,
                NickName = this.nickName,
                RemarkName = this.remarkName,
                Status = this.status,

            };
            return friend;
        }
        #endregion

        #region 实体类
        public VerifingFriend()
        {
            CreateVerifingTable();
        }
        #endregion

        #region 创建朋友验证数据库表
        /// <summary>
        /// 创建朋友验证数据库表
        /// </summary>
        private bool CreateVerifingTable()
        {
            try
            {
                var result = DBSetting.SQLiteDBContext.Queryable<sqlite_master>().Where(s => s.Name == "VerifingFriend" && s.Type == "table");
                if (result != null && result.Count() > 0)     //表存在
                {
                    return true;
                }

                DBSetting.SQLiteDBContext.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(VerifingFriend));
                return true;

            }
            catch (Exception)
            {
                return false;
            }
        }
        #endregion


        #region 按userId更新到数据库
        /// <summary>
        /// 按userId更新到数据库
        /// <para>必须先对userId赋值</para>
        /// </summary>
        public int UpdateByUserId()
        {
            return DBSetting.SQLiteDBContext.Updateable(this).Where(f => f.userId == this.userId).ExecuteCommand();
        }
        #endregion

        #region 删除
        /// <summary>
        /// 删除该好友的验证消息
        /// <para>必须先对userId赋值</para>
        /// </summary>
        public int DeleteData()
        {
            return DBSetting.SQLiteDBContext.Deleteable<VerifingFriend>().Where(v => v.userId == this.userId).ExecuteCommand();
        }
        #endregion

        #region 根据status删除
        /// <summary>
        /// 根据status删除
        /// <para>必须先对status赋值</para>
        /// </summary>
        public int DeleteByStatus()
        {
            return DBSetting.SQLiteDBContext.Deleteable<VerifingFriend>().Where(f => f.status == this.status).ExecuteCommand();
        }
        #endregion

        #region 根据status获得列表
        /// <summary>
        /// 根据status获得列表
        /// <para>必须先对status赋值</para>
        /// </summary>
        public List<VerifingFriend> GetListByStatus()
        {
            return DBSetting.SQLiteDBContext.Queryable<VerifingFriend>().Where(f => f.status == this.status).ToList();
        }
        #endregion

        #region 根据UserId获得对象
        /// <summary>
        /// 根据userId获得对象
        /// <para>必须先对userId赋值</para>
        /// </summary>
        /// <returns>查询的对象</returns>
        public VerifingFriend GetByUserId()
        {
            var result = DBSetting.SQLiteDBContext.Queryable<VerifingFriend>().First(f => f.userId == this.userId);
            return result == null ? new VerifingFriend() : result;
        }
        #endregion

        #region 根据UserName获取(支持模糊查询)
        /// <summary>
        /// 根据UserName获取(支持模糊查询)
        /// <para>必须先对nickName赋值</para>
        /// </summary>
        /// <returns>获取的集合</returns>
        public List<VerifingFriend> GetByUserName()
        {
            return DBSetting.SQLiteDBContext.Queryable<VerifingFriend>().Where(v => v.nickName.Contains(this.nickName)).ToList();
        }
        #endregion

        #region 添加新的对象
        /// <summary>
        /// 添加新的对象
        /// <para>必须先对userId赋值</para>
        /// </summary>
        /// <returns>受影响行数</returns>
        public bool InsertOrUpdate()
        {
            if (string.IsNullOrEmpty(userId))
            {
                return false;
            }

            if (CreateVerifingTable())
            {
                var result = 0;
                //如果已存在
                if (DBSetting.SQLiteDBContext.Queryable<VerifingFriend>().Where(v => v.userId == this.userId).Any())
                {
                    result = DBSetting.SQLiteDBContext.Updateable(this).ExecuteCommand();
                }
                else
                {
                    result = DBSetting.SQLiteDBContext.Insertable(this).ExecuteCommand();
                }

                return result == 1;
            }

            return false;
        }
        #endregion

        #region 获取好友验证列表
        /// <summary>
        /// 获取好友验证列表
        /// </summary>
        /// <returns></returns>
        public List<VerifingFriend> GetVerifingsList()
        {
            return DBSetting.SQLiteDBContext.Queryable<VerifingFriend>()
                .OrderBy(it => it.lastMsgTime, OrderByType.Desc).ToList();
        }
        #endregion  
        
        #region 获取好友验证列表
        /// <summary>
        /// 获取好友验证列表
        /// </summary>
        /// <returns></returns>
        public int GetVerifyStatus()
        {
            if (CreateVerifingTable())
            {
                var friend = DBSetting.SQLiteDBContext.Queryable<VerifingFriend>().Single(f => f.userId == this.userId);

                if (friend != null)
                {
                    return friend.VerifyStatus;
                }
            }

            return 0;
        }
        #endregion
    }
}
