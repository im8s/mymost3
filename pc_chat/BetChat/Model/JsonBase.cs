using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk
{
    /// <summary>
    /// 此类用于接口接收对应json数据中的ResultCode
    /// </summary>
    public class JsonBase
    {
        /// <summary>
        /// 当前时间
        /// </summary>
        public long currentTime { get; set; }

        /// <summary>
        /// 返回的详细信息
        /// </summary>
        public string resultMsg { get; set; }

        /// <summary>
        /// 返回的结果代码
        /// 接口调用成功：此时接口返回JSON对象中resultCode值为1，resultMsg为接口提示消息，data为数据节点，例如评论、赞、商务圈消息等。
        /// 接口调用失败：此时接口返回JSON对象中resultCode值为非1值，resultMsg为错误消息。
        /// //如果好友关注返回的东西的话, 就是 1.关注成功，等待验证2.关注成功，已互为好友   3.关注失败， 重复关注      4.关注失败， 已互为好友
        /// </summary>
        public int resultCode { get; set; }
    }
}
