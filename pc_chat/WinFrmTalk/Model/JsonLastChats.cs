using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    public class JsonLastChats
    {
        /// <summary>
        /// 
        /// </summary>
        public long currentTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public List<DataItem> data { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int resultCode { get; set; }
    }



    public class DataItem
    {
        /// <summary>
        /// 
        /// </summary>
        public string _id { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string jid { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int type { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string messageId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public long timeSend { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string content { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string userId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isRoom { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public bool isEncrypt { get; set; }


        public string from { get; set; }
        public string fromUserName { get; set; }
        public string to { get; set; }
        public string toUserName { get; set; }


        internal Friend ToFriend()
        {
            Friend friend = new Friend();

            friend.IsGroup = this.isRoom;
            friend.LastMsgTime = (int)this.timeSend;
            friend.Content = this.content;
            friend.UserId = isRoom ==1 ?jid:userId;
            friend.LastMsgType = type;

            return friend;


        }
    }
}