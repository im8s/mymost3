using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk.Model;

public class Member
{
    /// <summary>
    /// 
    /// </summary>
    public int active { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string call { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public int createTime { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public int modifyTime { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string nickname { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public int offlineNoPushMsg { get; set; }
    /// <summary>
    /// 置顶
    /// </summary>
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

    internal Friend ToFriend()
    {
        return new Friend() { UserId = userId, NickName = nickname };
    }
}

public class MembersItem
{
    /// <summary>
    /// 
    /// </summary>
    public long active { get; set; }
    /// <summary>
    ///  最后一次互动时间
    /// </summary>
    public string call { get; set; }
    /// <summary>
    /// 创建时间
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
    /// <summary>
    /// 成员角色：1=创建者 2=管理员 3=成员
    /// <para>附加：如果为预览成员的话,,则为</para>
    /// </summary>
    public int role { get; set; }
    /// <summary>
    /// 订阅群信息：0=否 1=是
    /// </summary>
    public int sub { get; set; }
    /// <summary>
    /// 大于当前时间时禁止发言 
    /// </summary>
    public long talkTime { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string userId { get; set; }
    /// <summary>
    /// 视频会议标识符
    /// </summary>
    public string videoMeetingNo { get; set; }
}

public class Notice
{
    /// <summary>
    /// 
    /// </summary>
    public int time { get; set; }
}

public class RoomDetails
{
    /// <summary>
    /// 允许会议
    /// </summary>
    public int allowConference { get; set; }

    /// <summary>
    /// 
    /// </summary>
    public int allowHostUpdate { get; set; }

    /// <summary>
    /// 允许邀请朋友
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
    public int createTime { get; set; }
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
    public List<MembersItem> members { get; set; }
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
    public Notice notice { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public List<string> notices { get; set; }
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

    public int userId { get; set; }
    /// <summary>
    /// 
    /// </summary>

    public int userSize { get; set; }
    /// <summary>
    /// 视频会议标识符
    /// </summary>
    public string videoMeetingNo { get; set; }


}
