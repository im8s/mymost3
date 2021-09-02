using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk
{
    public class MyColleague
    {
        /// <summary>
        /// 
        /// </summary>
        public string currentTime { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public List<ItemData> data { get; set; }

        /// <summary>
        /// 返回状态
        /// </summary>
        public int resultCode { get; set; }
    }
    /// <summary>
    /// 部门层
    /// </summary>
    public class DepartmentsItem
    {
        /// <summary>
        /// 公司id，表示该部门所属的公司
        /// </summary>
        public string companyId { get; set; }
        /// <summary>
        /// 创建时间戳
        /// </summary>
        public int createTime { get; set; }
        /// <summary>
        /// 创建者UserId
        /// </summary>
        public int createUserId { get; set; }
        /// <summary>
        /// 部门名称
        /// </summary>
        public string departName { get; set; }
        /// <summary>
        /// 部门总人数
        /// </summary>
        public int empNum { get; set; }
        /// <summary>
        /// 部门员工列表
        /// </summary>
        public List<employeesItem> employees { get; set; }
        /// <summary>
        /// 部门id
        /// </summary>
        public string id { get; set; }
        /// <summary>
        /// 表示上一级的部门ID
        /// </summary>
        public string parentId { get; set; }

        /// <summary>
        /// //类型值  0:普通部门  1:根部门  2:分公司    5:默认加入的部门  6.客服部门
        /// </summary>
        public int type { get; set; }

    }
    /// <summary>
    /// 公司层
    /// </summary>
    public class ItemData
    {
        /// <summary>
        ///公司名称
        /// </summary>
        public string companyName { get; set; }
        /// <summary>
        /// 公司创建时间戳
        /// </summary>
        public int createTime { get; set; }
        /// <summary>
        /// 创建者UserId
        /// </summary>
        public int createUserId { get; set; }
        /// <summary>
        /// 删除时间
        /// </summary>
        public int deleteTime { get; set; }
        /// <summary>
        /// 删除者UserId
        /// </summary>
        public int deleteUserId { get; set; }
        /// <summary>
        /// 公司部门列表
        /// </summary>
        public List<DepartmentsItem> departments { get; set; }
        /// <summary>
        /// 公司员工总数
        /// </summary>
        public int empNum { get; set; }
        /// <summary>
        /// 公司ID
        /// </summary>
        public string id { get; set; }
        /// <summary>
        /// 公司公告（通知）
        /// </summary>
        public string noticeContent { get; set; }
        /// <summary>
        /// 公告时间
        /// </summary>
        public int noticeTime { get; set; }
        /// <summary>
        /// 根部门Id,可能有多个
        /// </summary>
        public List<string> rootDpartId { get; set; }
        /// <summary>
        /// 类型值 5:默认加入的公司
        /// </summary>
        public int type { get; set; }
    }
    /// <summary>
    /// 员工层
    /// </summary>
    public class employeesItem
    {
        /// <summary>
        /// 当前会话人数
        /// </summary>
        public int chatNum { get; set; }
        /// <summary>
        /// 公司id，表示员工所属公司
        /// </summary>
        public string companyId { get; set; }
        /// <summary>
        /// 部门Id,表示员工所属部门   
        /// </summary>
        public string departmentId { get; set; }
        /// <summary>
        /// 员工id
        /// </summary>
        public string id { get; set; }
        /// <summary>
        /// 是否为客服
        /// </summary>
        public int isCustomer { get; set; }
        /// <summary>
        /// 是否暂停，0暂停，1正常
        /// </summary>
        public int isPause { get; set; }
        /// <summary>
        /// 用户昵称，和用户表一致
        /// </summary>
        public string nickname { get; set; }
        /// <summary>
        /// 操作类型 1、建立会话操作， 2、结束会话操作
        /// </summary>
        public int operationType { get; set; }
        /// <summary>
        /// 职位（头衔），如：经理、总监等
        /// </summary>
        public string position { get; set; }
        /// <summary>
        /// 员工角色：0：普通员工     1：部门管理者    2：管理员    3：公司创建者(超管)
        /// </summary>
        public int role { get; set; }
        /// <summary>
        /// 用户id,用于和用户表关联
        /// </summary>
        public string userId { get; set; }
    }
}
