using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Model
{
    class DownRoomBean
    {
        public DownRoomBean()
        {
            data = new List<DownRoom>();
        }

        public List<DownRoom> data { get; set; }

        public List<Friend> ToRoomFriends()
        {
            if (UIUtils.IsNull(data))
            {
                return null;
            }

            List<Friend> rooms = new List<Friend>();

            foreach (DownRoom room in data)
            {
                Friend friend = new Friend();
                friend.UserId = room.jid;
                friend.ShowRead = room.showRead;
                friend.AllowUploadFile = room.allowUploadFile;//允许普通群成员上传文件
                friend.AllowSpeakCourse = room.allowSpeakCourse;//允许普通群成员发起讲课
                friend.AllowConference = room.allowSpeakCourse;
                friend.AllowConference = room.allowConference;//允许普通群成员召开会议
                friend.AllowInviteFriend = room.allowInviteFriend;//允许普通群成员邀请好友
                friend.ShowMember = room.showMember;
                friend.AllowSendCard = room.allowSendCard;//允许普通群成员私聊
                //  开启了全体禁言，本地朋友表丢失此字段 room.talkTime > 0
                friend.CreateTime = (int)room.createTime;
                friend.NickName = room.name;
                friend.RoomId = room.id;
                friend.Status = 2;
                friend.IsGroup = 1;
                friend.Description = room.desc;
                friend.IsNeedVerify = room.isNeedVerify;

                if (room.member != null)
                {
                    friend.Nodisturb = room.member.offlineNoPushMsg;
                    friend.TopTime = room.member.openTopChatTime;
                }

                rooms.Add(friend);
            }

            return rooms;
        }
    }

    public class Member
    {
        /// <summary>
        /// 
        /// </summary>
        public int active { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public long createTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public long modifyTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string nickname { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int offlineNoPushMsg { get; set; }

        public int openTopChatTime { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int role { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int sub { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public long talkTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string userId { get; set; }
    }


    public class DownRoom
    {
        /// <summary>
        /// 
        /// </summary>
        public int allowConference { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int allowHostUpdate { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int allowInviteFriend { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int allowSendCard { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int allowSpeakCourse { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int allowUploadFile { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int areaId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string call { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int category { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double chatRecordTimeOut { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int cityId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int countryId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double createTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string desc { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string id { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isAttritionNotice { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isLook { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int isNeedVerify { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string jid { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double latitude { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public double longitude { get; set; }



        /// <summary>
        /// 
        /// </summary>
        public int maxUserSize { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public Member member { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int modifyTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string name { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string nickname { get; set; }


        /// <summary>
        /// 
        /// </summary>
        public int provinceId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int s { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int showMember { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int showRead { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string subject { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public long talkTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string userId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int userSize { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string videoMeetingNo { get; set; }


        public Friend ToRoom()
        {
            Friend friend = new Friend();
            friend.UserId = this.jid;
            friend.ShowRead = this.showRead;
            friend.AllowUploadFile = this.allowUploadFile;//允许普通群成员上传文件
            friend.AllowSpeakCourse = this.allowSpeakCourse;//允许普通群成员发起讲课
            friend.AllowConference = this.allowSpeakCourse;
            friend.AllowConference = this.allowConference;//允许普通群成员召开会议
            friend.AllowInviteFriend = this.allowInviteFriend;//允许普通群成员邀请好友
            friend.ShowMember = this.showMember;
            friend.AllowSendCard = this.allowSendCard;//允许普通群成员私聊

            // this.talkTime > 0 开启了全体禁言，本地朋友表丢失此字段
            friend.CreateTime = (int)this.createTime;
            friend.NickName = this.name;
            friend.RoomId = id;
            friend.Status = 2;
            friend.IsGroup = 1;
            friend.Description = this.desc;
            friend.IsNeedVerify = this.isNeedVerify;


            if (member != null)
            {
                friend.Nodisturb = member.offlineNoPushMsg;
                friend.TopTime = member.openTopChatTime;

            }

            return friend;

        }

        internal RoomMember ToMeMember(string roomId)
        {
            if (member == null || string.IsNullOrEmpty(member.userId))
            {
                return null;
            }

            RoomMember roomMembers = new RoomMember();
            roomMembers.roomId = roomId;
            roomMembers.userId = member.userId;
            roomMembers.nickName = member.nickname;
            roomMembers.role = member.role;
            roomMembers.createTime = Convert.ToInt32(member.createTime);
            return roomMembers;
        }
    }
}
