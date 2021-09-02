using System;
using System.Collections.Generic;

namespace WinFrmTalk.Model
{
    public class AttentionFriends : JsonBase
    {
        #region 构造函数
        public AttentionFriends()
        {
            data = new List<AttentionFriend>();
        }
        #endregion

        public List<AttentionFriend> data { get; set; }

    }

    public class AttentionFriend
    {

        /// <summary>
        /// 
        /// </summary>
        public int blacklist { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double chatRecordTimeOut { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int createTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isBeenBlack { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double lastTalkTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double modifyTime { get; set; }

        /// <summary>
        /// 置顶
        /// </summary>
        public int openTopChatTime { get; set; }

        /// <summary>
        /// 阅后即焚
        /// </summary>
        public int isOpenSnapchat { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int msgNum { get; set; }
        /// <summary>
        /// 消息免打扰
        /// </summary>
        public int offlineNoPushMsg { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int status { get; set; }
        /// <summary>
        /// 视酷厂家(找我聊哦)
        /// </summary>
        public string toNickname { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string toUserId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string remarkName { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int toUserType { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string userId { get; set; }


        public Friend ToFriend()
        {

            Friend friend = new Friend
            {
                UserId = this.toUserId,
                NickName = this.toNickname,
                Status = this.blacklist == 0 ? status : -1,
                IsGroup = 0,
                RemarkName = this.remarkName
            };

            if (toUserType == 2)
            {
                friend.Status = 8;// 公众号
            }

            if (isBeenBlack == 1)
            {
                friend.Status = -1;// 黑名单
            }
            return friend;
        }

        internal int ToFriendStatus()
        {
            if (toUserType == 2)
            {
                return Friend.STATUS_SYSTEM;
            }

            if (isBeenBlack == 1)
            {
                return Friend.STATUS_23;
            }

            if (blacklist == 1)
            {
                return Friend.STATUS_18;
            }

            return status;
        }
    }
}
