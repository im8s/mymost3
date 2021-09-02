using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Model
{
    /// <summary>
    /// liuhuan 2019/4/1
    /// </summary>
    public class GroupNotices
    {
        //id
        public string Id { get; set; }
        /// <summary>
        /// 昵称
        /// </summary>
        public string NickName { get; set; }
        /// <summary>
        /// roomid
        /// </summary>
        public string Roomid { get; set; }
        /// <summary>
        /// 公告内容
        /// </summary>
        public string text { get; set; }
        /// <summary>
        ///userid
        /// </summary>
        public string Userid { get; set; }
        /// <summary>
        /// 时间
        /// </summary>
        public long Time { get; set; }

    }

    public class Collections
    {
        /// <summary>
        /// 创建时间
        /// </summary>
        public long createTime { get; set; }
        /// <summary>
        /// 收集类型
        /// </summary>
        public int collectType { get; set; }
        /// <summary>
        /// jid
        /// </summary>
        public string emojiId { get; set; }
        /// <summary>
        /// 文件长度
        /// </summary>
        public string fileLength { get; set; }
        /// <summary>
        /// 文件大小
        /// </summary>
        public string fileSize { get; set; }
        /// <summary>
        /// msg
        /// </summary>
        public string msg { get; set; }
        /// <summary>
        /// messageid
        /// </summary>
        public string msgId { get; set; }
        /// <summary>
        /// roomjid
        /// </summary>
        public string roomJid { get; set; }
        /// <summary>
        /// 类型
        /// </summary>
        public string type { get; set; }
        /// <summary>
        /// userid
        /// </summary>
        public string userId { get; set; }
        /// <summary>
        /// url
        /// </summary>
        public string url { set; get; }
        public string collectContent { set; get; }
        public string Filename { set; get; }
    }


    public class ColleaguesList
    {
        public ColleaguesList()
        {
            data = new List<MyColleagues>();
        }

        public List<MyColleagues> data { get; set; }
    }

    public class MyColleagues
    {
        /// <summary>
        /// 消息id
        /// </summary>
        public object messageIds { get; set; }
        /// <summary>
        /// 课件名称
        /// </summary>
        public string courseName { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        public string createTime { get; set; }
        /// <summary>
        /// 课件id
        /// </summary>
        public string courseId { get; set; }

    }
    public class commonTex
    {
        /// <summary>
        /// 用户id
        /// </summary>
        public string userid { get; set; }
        /// <summary>
        /// 文本
        /// </summary>
        public string content { get; set; }
        /// <summary>
        /// id
        /// </summary>
        public string id { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        public long createTime { get; set; }
        /// <summary>
        /// 修改者userid
        /// </summary>
        public int modifyUserId { get; set; }

    }
    public class Redpackges
    {
        /// <summary>
        ///红包的数量
        /// </summary>
        public string count { get; set; }
        /// <summary>
        /// 提示语
        /// </summary>
        public string greetings { get; set; }
        /// <summary>
        /// 红包id
        /// </summary>
        public string id { get; set; }
        /// <summary>
        /// 金额
        /// </summary>
        public string money { get; set; }
        /// <summary>
        /// 过期时间
        /// </summary>
        public string outTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string over { get; set; }
        /// <summary>
        /// 已经领取的个数
        /// </summary>
        public string receiveCount { get; set; }
        /// <summary>
        /// roomjid
        /// </summary>
        public string roomJid { get; set; }
        /// <summary>
        /// 发送时间
        /// </summary>
        public string sendTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string status { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string userId { get; set; }
        public string toUserId { get; set; }
        /// <summary>
        /// 红包类型
        /// </summary>
        public string type { get; set; }
        /// <summary>
        /// 领取人的userid集合
        /// </summary>
        public List<string> userIds
        {
            get; set;
        }
        /// <summary>
        /// 发红包人的昵称
        /// </summary>
        public string userName { get; set; }

    }
    /// <summary>
    /// 红包领取人的信息
    /// </summary>
    public class Receivers
    {
        /// <summary>
        /// id
        /// </summary>
        public string id { get; set; }
        /// <summary>
        /// 金额
        /// </summary>
        public string money { get; set; }
        /// <summary>
        /// 红包id
        /// </summary>
        public string redId { get; set; }
        /// <summary>
        /// 发送者名称
        /// </summary>
        public string sendName { get; set; }
        /// <summary>
        /// 领取时间
        /// </summary>
        public string time { get; set; }
        /// <summary>
        /// 领取人userid
        /// </summary>
        public string userId { get; set; }

        /// <summary>
        /// 领取人名称
        /// </summary>
        public string userName { get; set; }
        public string reply { get; set; }
    }

    public class TransferInfo
    {
        /// <summary>
        /// 
        /// </summary>
        public int createTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string id { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double money { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int outTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int receiptTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string remark { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int status { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int toUserId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int userId { get; set; }
        /// <summary>
        /// 美团外卖
        /// </summary>
        public string userName { get; set; }
    }

    public class Root
    {
        /// <summary>
        /// 
        /// </summary>
        public int currentTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public TransferInfo data { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int resultCode { get; set; }
    }

    public class HaveReceived
    {
        public string id { get; set; }
        public string transferid { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double money { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int Time { get; set; }
        public int createTime { get; set; }
        public int receiptTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int userId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int sendId { get; set; }
        /// <summary>
        /// 美团外卖
        /// </summary>
        public string sendName { get; set; }
        public string userName { get; set; }
    }

    public class HaveReceivedRoot
    {
        /// <summary>
        /// 
        /// </summary>
        public int currentTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public HaveReceived data { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int resultCode { get; set; }
        /// <summary>
        /// 该转账已完成或退款
        /// </summary>
        public string resultMsg { get; set; }
    }

}

