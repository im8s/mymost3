using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Net;
using System.Text;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    /// <summary>
    /// API帮助类
    /// </summary>
    internal static class APIHelper
    {
        #region 验证手机号
        /// <summary>
        /// 验证手机号
        /// </summary>
        /// <param name="telephone"></param>
        /// <param name="areaCode"></param>
        /// <returns></returns>
        internal static void TelephoneVerifyAsync(string telephone, string areaCode, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "verify/telephone";
            //传参
            /////////////用户令牌
            string para = "telephone=" + telephone + "&areaCode=" + (string.IsNullOrWhiteSpace(areaCode) ? "86" : areaCode);
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 验证手机号
        /// <summary>
        /// 验证手机号
        /// </summary>
        /// <param name="telephone"></param>
        /// <param name="areaCode"></param>
        /// <returns></returns>
        internal static void TelephoneVerify(string telephone, string areaCode, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "verify/telephone";
            //传参
            /////////////用户令牌
            string para = "telephone=" + telephone + "&areaCode=" + (string.IsNullOrWhiteSpace(areaCode) ? "86" : areaCode);
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 上传头像
        /// <summary>
        /// 上传头像
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="filePath"></param>
        /// <returns></returns>
        public static WebClient UploadAvatorAsync(string uploadUrl, byte[] bytes, List<Action<DownloadString>> actions)
        {
            WebClient webClient = new WebClient();
            webClient.Headers.Add("Content-Type", "multipart/form-data; boundary=---------------------------7d5b915500cee");
            webClient.UploadDataAsync(new Uri(uploadUrl), bytes);
            return webClient;
        }
        #endregion

        #region 用户注册
        /// <summary>
        /// 用户注册
        /// </summary>
        /// <param name="telephone"></param>
        /// <param name="password"></param>
        /// <param name="nickname"></param>
        /// <param name="sex"></param>
        /// <returns></returns>
        internal static void RegisterAccountAsync(string telephone, string areaCode, string password, string nickname, int sex, long birthday, int countryId, int provinceId, int cityId, int areaId, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "user/register";
            //传参
            /////////////用户令牌RSelectedCountryCode
            string para = "access_token=" + Applicate.Access_Token + "&telephone=" + telephone + "&areaCode=" + areaCode + "&password=" + Helpers.MD5create(password) + "&nickname=" + nickname + "&sex=" + sex
                + "&birthday=" + birthday + "&countryId=" + countryId + "&provinceId=" + provinceId + "&cityId=" + cityId + "&areaId=" + areaId + "&userType=1";
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 接口退出群聊
        /// <summary>
        /// 退出群聊
        /// </summary>
        /// <param name="roomId">需要退出的 群聊ID</param>
        /// <returns>是否成功</returns>
        internal static void ExitRoomAsync(string roomId, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/member/delete";
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId + "&userId=" + Applicate.MyAccount.userId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 获取群聊详情
        /// <summary>
        /// 获取群聊详情
        /// </summary>
        /// <param name="roomId">对应的RoomId</param>
        /// <returns></returns>
        internal static void GetRoomDetialByRoomIdAsync(string roomId, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/get";
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        /* -------------------将接口返回的群组数据存入群组数据库
                    var s = Encoding.UTF8.GetString(res.Result);
                    var roomDetail = JsonConvert.DeserializeObject<JsonRoom>(Encoding.UTF8.GetString(res.Result));
                    if (roomDetail.resultCode == 1)
                    {
                        new DataofMember { groupid = roomDetail.data.id
                        }.DeleteByRoomId();//删除群成员
                        if (roomDetail.data.members.Count > 0)//如果群成员不为空,则存入数据库
                        {
                            roomDetail.data.members[0].AutoInsertRange(roomDetail.data.members, roomDetail.data.id);
                        }
                        if (roomDetail.data.notice != null)//更新群公告
                        {
                            roomDetail.data.notice.AutoInsertRange(roomDetail.data.notices);//更新公告
                        }
                        roomDetail.data.AutoInsert();
                    }
                */

        #region 修改群允许普通成员邀请好友
        /// <summary>
        /// 
        /// </summary>
        /// <param name="roomid"></param>
        /// <param name="allowInviteFriend"></param>
        /// <param name="actions"></param>
        /// <returns></returns>
        internal static void UpdateAllowInviteFriendAsync(string roomid, string allowInviteFriend, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "room/update";
            //传参
            /////////////用户令牌
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&allowInviteFriend=" + allowInviteFriend;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 修改群允许普通成员上传文件
        internal static void UpdateAllowUploadFileAsync(string roomid, string allowUploadFile, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "room/update";
            //传参
            /////////////用户令牌
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&allowUploadFile=" + allowUploadFile;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 修改群允许普通成员发起会议
        internal static void UpdateAllowConferenceAsync(string roomid, string allowConference, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "room/update";
            //传参
            /////////////用户令牌
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&allowConference=" + allowConference;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 修改群允许普通成员发起讲课
        internal static void UpdateAllowSpeakCourseAsync(string roomid, string allowSpeakCourse, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "room/update";
            //传参
            /////////////用户令牌
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&allowSpeakCourse=" + allowSpeakCourse;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 获取成员详情
        internal static void GetMemberDetialAsync(string roomId, string userId, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/member/get";
            //拼接参数
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId + "&userId=" + userId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 加入群聊
        /// <summary>
        /// 接口加群
        /// </summary>
        /// <param name="RoomId">群组的RoomId(非Jid)</param>
        /// <returns></returns>
        internal static void GroupJoinAsync(string RoomId, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/join";
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + RoomId;//type (1自己房间 2加入的房间)
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 修改群名称
        internal static void SetRoomNameAsync(string roomid, string roomname, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "room/update";
            //传参
            /////////////用户令牌
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&roomName=" + roomname;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 修改群允许发送名片
        internal static void UpdateAllowSendCardAsync(string roomid, string allowSendCard, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "room/update";
            //传参
            /////////////用户令牌
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&allowSendCard=" + allowSendCard;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        //#region 修改群描述
        ///// <summary>
        ///// 修改群描述
        ///// </summary>
        ///// <param name="roomid">群组ID(非jid)</param>
        ///// <param name="desc">群组描述</param>
        ///// <returns></returns>
        //internal static void UpdateGroupChatDescAsync(string roomid, string desc, List<Action<DownloadString>> actions)
        //{
        //    //声明URL和需要传的参数
        //    string url = Applicate.URLDATA.data.apiUrl + "room/update";
        //    //传参
        //    /////////////用户令牌
        //    string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&desc=" + desc;
        //    HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        //}
        //#endregion

        //#region 修改群公告
        //internal static void UpdateGroupChatNoticeAsync(string roomid, string notice, List<Action<DownloadString>> actions)
        //{
        //    //声明URL和需要传的参数
        //    string url = Applicate.URLDATA.data.apiUrl + "room/update";
        //    //传参
        //    /////////////用户令牌
        //    string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&notice=" + notice;
        //    HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        //}
        //#endregion

        //#region 修改群公告
        //internal static void SetGroupChatNoticeAsync(string roomid, string notice, List<Action<DownloadString>> actions)
        //{
        //    //声明URL和需要传的参数
        //    string url = Applicate.URLDATA.data.apiUrl + "room/update";
        //    //传参
        //    /////////////用户令牌
        //    string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&notice=" + notice;
        //    HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        //}
        //#endregion

        //#region 修改显示群成员
        ///// <summary>
        ///// 修改显示群成员
        ///// </summary>
        ///// <param name="roomid">RoomId</param>
        ///// <param name="showMember">ShowMember</param>
        ///// <returns></returns>
        //internal static void SetShowMemberAsync(string roomid, string showMember, List<Action<DownloadString>> actions)
        //{
        //    //声明URL和需要传的参数
        //    string url = Applicate.URLDATA.data.apiUrl + "room/update";
        //    //传参
        //    /////////////用户令牌
        //    string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&showMember=" + showMember;
        //    HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        //}
        //#endregion

        //#region 修改群验证
        //internal static void SetNeedVerifyAsync(string roomid, string isNeedVerify, List<Action<DownloadString>> actions)
        //{
        //    //声明URL和需要传的参数
        //    string url = Applicate.URLDATA.data.apiUrl + "room/update";
        //    //传参
        //    /////////////用户令牌
        //    string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&isNeedVerify=" + isNeedVerify;
        //    HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        //}
        //#endregion

        //#region 修改公开群
        //internal static void SetPublicRoomAsync(string roomid, string isLook, List<Action<DownloadString>> actions)
        //{
        //    //声明URL和需要传的参数
        //    string url = Applicate.URLDATA.data.apiUrl + "room/update";
        //    //传参
        //    /////////////用户令牌
        //    string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomid + "&isLook=" + isLook;
        //    HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        //}
        //#endregion

        //#region 获取群聊成员列表
        ///// <summary>
        ///// 获取群聊成员列表
        ///// </summary>
        ///// <param name="roomId">房间ID</param>
        ///// <param name="keyword">关键词</param>
        ///// <returns>RtnRoomMemberList</returns>
        //public static void GetRoomMemberAsync(string roomId, string keyword, List<Action<DownloadString>> actions)
        //{
        //    string url = Applicate.URLDATA.data.apiUrl + "room/member/list";
        //    string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId;
        //    //可选参数
        //    if (!string.IsNullOrWhiteSpace(keyword))
        //    {
        //        para = para + "&keyword=" + keyword;
        //    }
        //    /*
        //    client.UploadDataCompleted += (sen, res) =>
        //    {
        //        if (res.Error == null)
        //        {
        //            var memberList = JsonConvert.DeserializeObject<JsonRoomMemberList>(Encoding.UTF8.GetString(res.Result));
        //            new DataofMember() { groupid = roomId }.DeleteByRoomId();
        //            if (memberList.data.Count > 0)//如果不为空则自动插入
        //            {
        //                memberList.data[0].AutoInsertRange(memberList.data, roomId);
        //                new Room().UpdateMemberSize(roomId, memberList.data.Count);//更新群人数
        //            }
        //        }
        //    };*/
        //    HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        //}
        //#endregion

        //#region 获取我加入的群聊
        ///// <summary>
        ///// 获取我加入的群聊
        ///// </summary>
        //internal static HttpClient GetMyRoomsAsync(List<Action<DownloadString>> actions)
        //{
        //    //room/list
        //    string url = Applicate.URLDATA.data.apiUrl + "room/list/his";
        //    //参数
        //    //string para = "access_token=" + Applicate.Access_Token + "&type=0&pageSize=10000&Userid";//0=所有；1=自己的房间；2=加入的房间（默认为0）
        //    string para = "access_token=db3a9f45fae94b278703c0acd214cd92&type=0&pageSize=10000&Userid";
        //    var parabytes = Encoding.UTF8.GetBytes(para);
        //    var client = new HttpClient();
        //    client.Headers.Add("ContentLength", parabytes.Length.ToString());
        //    client.UploadDataAsync(new Uri(url), parabytes);//异步执行
        //    return client;
        //}
        //#endregion

        //#region 获取群聊
        ///// <summary>
        ///// 获取群聊
        //internal static HttpClient GetAllRoomsAsync(List<Action<DownloadString>> actions)
        //{
        //    //    /room/list
        //    string url = Applicate.URLDATA.data.apiUrl + "room/list";
        //    //参数
        //    string para = "access_token=" + Applicate.Access_Token + "&pageSize=50"; //+ "&type=0&pageSize=10000&Userid"; //;//0=所有；1=自己的房间；2=加入的房间（默认为0）
        //    var parabytes = Encoding.UTF8.GetBytes(para);
        //    var client = new HttpClient();
        //    client.Headers.Add("ContentLength", parabytes.Length.ToString());
        //    client.UploadDataAsync(new Uri(url), parabytes);//异步执行
        //    return client;//返回HttpClient
        //}
        //#endregion

        //#region 删除群聊成员(仅管理员和群主操作)
        ///// <summary>
        ///// 删除群聊成员(仅管理员和群主操作)
        ///// </summary>
        ///// <param name="RoomId">目标RoomID</param>
        ///// <param name="userId">目标UserID</param>
        //internal static HttpClient DeleteRoomMemberAsync(string RoomId, string userId, List<Action<DownloadString>> actions)
        //{
        //    //此处为先调用接口再调用Xmpp
        //    string url = Applicate.URLDATA.data.apiUrl + "room/member/delete";//初始化URL
        //    string para = "access_token=" + Applicate.Access_Token + "&roomId=" + RoomId + "&userId=" + userId;
        //    var parabytes = Encoding.UTF8.GetBytes(para);
        //    var client = new HttpClient();
        //    client.Headers.Add("ContentLength", parabytes.Length.ToString());
        //    client.UploadDataAsync(new Uri(url), parabytes);//异步执行
        //    return client;//如果Code为1则成功返回true，0则失败返回false
        //}
        //#endregion

        //#region 获取用户详细信息
        ///// <summary>
        ///// 获取用户详细信息
        ///// </summary>
        ///// <param name="userId">用户的ID</param>
        ///// <returns>返回的用户</returns>
        //internal static HttpClient GetUserDetialAsync(string userId, List<Action<DownloadString>> actions)
        //{
        //    string url = Applicate.URLDATA.data.apiUrl + "user/get";//定义Url
        //    string para = "access_token=" + Applicate.Access_Token + "&userId=" + userId;//定义参数
        //    var parabytes = Encoding.UTF8.GetBytes(para);
        //    var client = new HttpClient();
        //    client.Headers.Add("ContentLength", parabytes.Length.ToString());
        //    client.UploadDataCompleted += (sen, res) =>
        //    {
        //        if (res.Error == null)
        //        {
        //            var user = JsonConvert.DeserializeObject<JsonuserDetial>(Encoding.UTF8.GetString(res.Result));
        //            var detial = new Friend();
        //            if (!string.IsNullOrWhiteSpace(user.data.userId))
        //            {
        //                detial = user.data.ToDataOfFriend();//转DataofFriend
        //                detial.InsertAuto();//保存或更新数据库
        //            }
        //        }
        //        else
        //        {
        //            //网络错误
        //        }
        //    };
        //    client.UploadDataAsync(new Uri(url), parabytes);//异步执行
        //    return client;
        //}
        //#endregion

        #region 异步获取头像

        /// <summary>
        /// 异步获取头像
        /// </summary>
        /// <param name="userId">对应的UserId</param>
        /// <param name="fileName">本地图片保存路径</param>
        /// <param name="isThumbnail">是否为缩略图</param>
        /// <returns></returns>
        public static void GetAvatorAsync(string userId, string fileName, bool isThumbnail, List<Action<DownloadFile>> actions)
        {
            string url = Applicate.URLDATA.data.downloadAvatarUrl + "avatar/" + ((isThumbnail) ? ("t") : ("o")) + "/" + Convert.ToInt32(userId) % 10000 + "/" + userId + ".jpg";
            HttpDownloader.DownloadFile(new List<DownloadFile> {
                new DownloadFile { Url = url, Type = DownLoadFileType.Image,
                LocalUrl = Applicate.LocalConfigData.GetAvatorPath(userId) } }, actions);
        }
        #endregion

        #region 添加关注(同意添加好友请求)
        /// <summary>
        /// 添加关注(同意添加好友请求)
        /// </summary>
        /// <param name="toUserId">需要同意的UserId</param>
        /// <returns>状态值</returns>
        internal static void AttentionAddAsync(string toUserId, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "friends/attention/add";
            var para = "access_token=" + Applicate.Access_Token + "&toUserId=" + toUserId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 删除群聊
        /// <summary>
        /// 删除群聊
        /// </summary>
        /// <param name="roomId">群聊Id</param>
        /// <returns>是否成功</returns>
        internal static void DeleteRoomAsync(string roomId, List<Action<DownloadString>> actions)
        {
            //声明Url
            string url = Applicate.URLDATA.data.apiUrl + "room/delete";
            //定义参数
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 接口退出
        /// <summary>
        /// 接口退出
        /// </summary>
        public static void UserLogout(List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "user/outtime";
            string para = "?access_token=" + Applicate.Access_Token + "&userId=" + Applicate.MyAccount.userId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 获取附近的人
        /// <summary>
        /// 获取附近的人(查找好友)
        /// </summary>
        /// <param name="nickname">查询昵称</param>
        /// <param name="pageIndex">页码 = 1</param>
        /// <param name="pageSize">页大小 = 50</param>
        /// <param name="longitude">经度 = 0</param>
        /// <param name="latitude">纬度 = 0</param>
        /// <param name="sex">性别 = ""</param>
        /// <param name="minAge">最小年龄 = 0</param>
        /// <param name="maxAge">最大年龄 = 1000</param>
        /// <param name="acticve">最后出现时间 = 18000</param>
        /// <returns>返回附近的好友集合</returns>
        internal static void GetNerbyFriendsAsync(string nickname, int pageIndex, int pageSize, double longitude, double latitude, string sex, int minAge, int maxAge, int acticve, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "nearby/user";
            /////////////用户令牌
            string para = "access_token=" + Applicate.Access_Token + "&nickname=" + nickname +
                //////////////////经度////////////////////////////纬度//////////////////性别////////////////////最小年龄////////////////////最大年龄
                "&longitude=" + longitude + "&latitude=" + latitude + "&sex" + sex + "&minAge=" + minAge + "&maxAge=" + maxAge
                ///////////////最后出现时间////////////////页码///////////////////////////////页大小
                + "&acticve=" + acticve + "&pageIndex=" + pageIndex + "&pageSize=" + pageSize;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 获取好友列表
        /// <summary>
        /// 获取好友列表
        /// </summary>
        /// <param name="currUser">当前用户123</param>
        /// <param name="pageIndex">当前页码 = 1</param>
        /// <param name="pageSize">每页显示的数量 = 1000</param>
        /// <returns>查找到的好友集合</returns>
        internal static void GetFriendsAsync(int pageIndex, int pageSize, List<Action<DownloadString>> actions)
        {
            //然后声明对应的URL和POST提交参数
            string url = Applicate.URLDATA.data.apiUrl + "friends/list";
            string para = "access_token=db3a9f45fae94b278703c0acd214cd92&pageIndex=1&pageSize=1000&userId=10009349";
            //string para = "access_token=" + Applicate.Access_Token + "&pageIndex=" + pageIndex + "&pageSize=" + pageSize + "&userId=" + Applicate.UserId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 更改用户资料
        /// <summary>
        /// 更改用户资料
        /// </summary>
        /// <param name="editedUser">编辑过的用户对象</param>
        /// <returns>是否成功</returns>
        internal static void UpdateUserDetialAsync(DataOfUserDetial editedUser, List<Action<DownloadString>> actions)
        {
           
        }
        #endregion

        #region 创建群聊
        //internal static void CreateGroupAsync(Room room, List<Action<DownloadString>> actions)
        //{
        //    string url = Applicate.URLDATA.data.apiUrl + "room/add";
        //    string para = "access_token=" + Applicate.Access_Token + "&jid=" + room.jid + "&name=" + room.name + "&desc=" + room.desc;//showRead=0
        //    HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        //}
        #endregion

        #region 创建群聊
        //internal static void CreateGroupAsynctemp(Room room, List<Action<DownloadString>> actions)
        //{
        //    string url = Applicate.URLDATA.data.apiUrl + "room/add";
        //    string para = "access_token=" + Applicate.Access_Token + "&jid=" + room.jid + "&name=" + room.name + "&desc=" + room.desc;//showRead=0
        //    HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        //}
        #endregion

        #region 创建带成员的群组
        /// <summary>
        /// 创建带成员的群组
        /// </summary>
        /// <param name="room"></param>
        /// <param name="members"></param>
        /// <returns></returns>
        //internal static void CreateGroupWithMembersAsync(Room room, List<string> members, List<Action<DownloadString>> actions)
        //{
        //    string url = Applicate.URLDATA.data.apiUrl + "room/add";
        //    StringBuilder para = new StringBuilder();
        //    para.Append("access_token=" + Applicate.Access_Token);
        //    para.Append("&name=" + room.name);
        //    para.Append("&jid=" + room.jid);
        //    para.Append("&desc=" + room.desc);
        //    para.Append("&text=" + JsonConvert.SerializeObject(members));
        //    HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para.ToString() }, actions);
        //}
        #endregion

        #region 更新群组
        /// <summary>
        /// 更新群组
        /// </summary>
        /// <param name="roomId"></param>
        /// <param name="member"></param>
        /// <returns></returns>
        internal static void UpdateCreateGroupAsync(string roomId, List<string> member, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/member/update";
            string para = "access_token=" + Applicate.Access_Token + "&text=" + JsonConvert.SerializeObject(member) + "&roomId=" + roomId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 设置或取消管理员操作
        /// <summary>
        /// 设置或取消管理员操作
        /// </summary>
        /// <param name="roomId">对应的房间Id</param>
        /// <param name="userId">用户Id</param>
        /// <param name="isAdmin">对应的用户字段</param>
        /// <returns>返回的Json对象</returns>
        internal static void SetRoomAdminAsync(string roomId, string userId, int isAdmin, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/set/admin";
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId + "&touserId=" + userId + "&type=" + isAdmin;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 转让群组
        /// <summary>
        /// 
        /// </summary>
        /// <param name="roomId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        internal static void RoomTransferAsync(string roomId, string userId, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/transfer";
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId + "&toUserId=" + userId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 成员禁言
        /// <summary>
        /// 成员禁言
        /// </summary>
        /// <param name="roomId"></param>
        /// <param name="userId"></param>
        /// <param name="talkTime"></param>
        /// <returns></returns>
        internal static void SetMemberTalkTimeAsync(string roomId, string userId, string talkTime, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/member/update";
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId + "&userId=" + userId + "&talkTime=" + talkTime;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 全部禁言
        /// <summary>
        /// 
        /// </summary>
        /// <param name="roomId"></param>
        /// <param name="userId"></param>
        /// <param name="talkTime">开启群禁言的时候传15天的时间戳，关闭的时候传0</param>
        /// <returns></returns>
        internal static void SetRoomTalkTimeAsync(string roomId, string roomName, string talkTime, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/update";
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId + "&roomName=" + roomName + "&talkTime=" + talkTime;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 拉黑
        /// <summary>
        /// 拉黑
        /// </summary>
        internal static void BlockFriendAsync(string userId, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "friends/blacklist/add";
            //传参
            string para = "access_token=" + Applicate.Access_Token + "&toUserId=" + userId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 获取黑名单用户列表 
        /// <summary>
        /// 获取黑名单用户列表
        /// </summary>JsonFriends
        internal static void GetBlackListAsync(List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "friends/blacklist";
            //传参
            /////////////用户令牌
            string para = "access_token=" + Applicate.Access_Token;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 取消拉黑
        /// <summary>
        /// 取消拉黑
        /// </summary>
        internal static void CancelBlockfriendAsync(string userId, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "friends/blacklist/delete";
            //传参
            string para = "access_token=" + Applicate.Access_Token + "&toUserId=" + userId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 删除好友
        /// <summary>
        /// 删除好友
        /// </summary>
        internal static void DeleteFriendAsync(string userId, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "friends/delete";
            //传参
            string para = "access_token=" + Applicate.Access_Token + "&toUserId=" + userId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 修改好友备注
        /// <summary>
        /// 修改好友备注
        /// </summary>
        internal static void RemarkFriendAsync(string userId, string remarkName, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "friends/remark";
            //传参
            /////////////用户令牌
            string para = "access_token=" + Applicate.Access_Token + "&toUserId=" + userId + "&remarkName=" + remarkName;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 删除/撤回消息
        /// <summary>
        /// 删除/撤回消息
        /// </summary>
        /// <param name="messageId">要删除的消息Id</param>
        /// <param name="type">聊天类型 1 单聊  2 群聊</param>
        /// <param name="delete">1： 删除属于自己的消息记录 2：撤回 删除整条消息记录</param>
        /// <returns>是否成功</returns>
        internal static void DeleteMessageAsync(string messageId, int type, int delete, List<Action<DownloadString>> actions)
        {
            //声明URL和需要传的参数
            string url = Applicate.URLDATA.data.apiUrl + "tigase/deleteMsg";
            /////////////用户令牌
            string para = "access_token=" + Applicate.Access_Token + "&type=" + type + "&delete=" + delete + "&messageId=" + messageId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 用户隐私设置修改
        /// <summary>
        /// 用户隐私设置修改
        /// </summary>
        /// <param name="allowAtt">允许关注（0=不允许；1=允许）</param>
        /// <param name="allowGreet">允许打招呼（0=不允许；1=允许）</param>
        /// <param name="friendsVerify">加好友验证状态（0=不验证；1=需验证）</param>
        /// <returns></returns>
        internal static void SetConcealAsync(Settings setting, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "user/settings/update";//定义Url
            StringBuilder para = new StringBuilder("access_token=" + Applicate.Access_Token);
            if (setting.allowAtt == 0 || setting.allowAtt == 1)
            {
                para.Append("&allowAtt=" + setting.allowAtt);
            }
            if (setting.allowGreet == 0 || setting.allowGreet == 1)
            {
                para.Append("&allowGreet=" + setting.allowGreet);
            }
            if (setting.friendsVerify == 0 || setting.friendsVerify == 1)
            {
                para.Append("&friendsVerify=" + setting.friendsVerify);
            }
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para.ToString() }, actions);
        }
        #endregion

        #region 用户隐私设置查询
        /// <summary>
        /// 用户隐私设置查询
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        internal static void GetConcealAsync(string userId, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "user/settings";//定义Url
            string para = "access_token=" + Applicate.Access_Token + "&userId=" + userId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 修改密码
        /// <summary>
        /// 修改密码
        /// </summary>
        /// <param name="oldPassword">旧密码</param>
        /// <param name="newPassword">新密码</param>
        internal static void ResetPasswordAsync(string oldPassword, string newPassword, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "user/password/update";//定义Url
            string para = "access_token=" + Applicate.Access_Token + "&oldPassword=" + oldPassword + "&newPassword=" + newPassword;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 获取聊天记录
        /// <summary>
        /// 获取聊天记录
        /// <para>请求对应Jid用户的聊天记录, endTime为本地当前用户最早的消息时间</para>
        /// </summary>
        /// <param name="isGroupMessage">是否为群聊消息</param>
        /// <param name="jid">用户(或群组)Jid</param>
        /// <param name="endTime" >本地消息最早一条消息时间</param>
        /// <param name="pageIndex">当前页码 值为0</param>
        /// <param name="pageSize">每页显示的数量(推荐 100)</param>
        /// <param name="actions" >回调函数集合</param>
        internal static void GetMessageAsync(string jid, long endTime, int pageIndex, int pageSize, List<Action<DownloadString>> actions)
        {
            //然后声明对应的URL和POST提交参数
            string url = Applicate.URLDATA.data.apiUrl + "tigase" + ((jid.Length > 10) ? ("/shiku_muc_msgs") : ("/shiku_msgs"));
            //拼接参数
            StringBuilder para = new StringBuilder();
            para.Append("access_token=" + Applicate.Access_Token);
            para = (jid.Length > 10) ? (para.Append("&roomId=" + jid)) : (para.Append("&receiver=" + jid));//判断不同的
            para.Append("&pageSize=" + pageSize + "&startTime=1262275200000" + "&endTime=" + endTime + "&pageIndex=" + pageIndex);
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para.ToString() }, actions);
        }
        #endregion

        #region 获取上次聊天列表
        /// <summary>
        /// 获取上次聊天列表
        /// </summary>
        /// <param name="syncTime">上次离线时间</param>
        /// <param name="pageSize">每页数量(推荐100)</param>
        /// <param name="pageIndex">当前页码(默认传0)</param>
        /// <returns></returns>
        internal static void GetLastChatListAsync(string syncTime, int pageSize, int pageIndex, List<Action<DownloadString>> actions)
        {
            //然后声明对应的URL和POST提交参数
            string url = Applicate.URLDATA.data.apiUrl + "tigase/getLastChatList";
            //拼接参数
            StringBuilder para = new StringBuilder();
            para.Append("access_token=" + Applicate.Access_Token);
            para.Append("&startTime=" + syncTime);
            para.Append("&pageSize=" + pageSize + "&pageIndex=" + pageIndex);
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para.ToString() }, actions);
        }
        #endregion

        #region 查询群共享
        /// <summary>
        /// 查询群共享
        /// </summary>
        /// <param name="roomId">RoomId</param>
        /// <param name="pageIndex">当前页索引 = 0</param>
        /// <param name="pageSize">页大小 = 0</param>
        /// <param name="time">时间 = 0</param>
        /// <param name="actions"></param>
        internal static void GetRoomSharesAsync(string roomId, int pageIndex, int pageSize, long time, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/share/find";
            //拼接参数
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId + "&pageIndex=" + pageIndex + "&pageSize=" + pageSize;
            //if (pageSize != 0)
            //    para+= "&pageIndex=" + pageIndex + "&pageSize=" + pageSize;
            //if (time != 0)
            //    para += "&time=" + time.ToString();
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para.ToString() }, actions);
        }
        #endregion

        #region 添加群共享
        internal static void AddRoomSharesAsync(RoomShare share, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/add/share";
            //拼接参数
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + share.roomId + "&type=" + share.type + "&size=" + share.size + "&userId=" + share.userId + "&url=" + share.url + "&name=" + share.name;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 删除群共享
        internal static void DelRoomSharesAsync(RoomShare share, string userId, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/share/delete";
            //拼接参数
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + share.roomId + "&shareId=" + share.shareId + "&userId=" + userId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 获取群共享详情
        internal static void GetShareDetailAsync(string roomId, string shareId, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/share/get";
            //拼接参数
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId + "&shareId=" + shareId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 更新群内昵称
        internal static void UpdateGroupNickNameAsync(string roomId, string userId, string nickname, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/member/update";
            //拼接参数
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId + "&userId=" + userId + "&nickname=" + nickname;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 消息免打扰
        /// <summary>
        /// 设置群组消息免打扰
        /// </summary>
        /// <param name="roomId"></param>
        /// <param name="userId"></param>
        /// <param name="offlineNoPushMsg"></param>
        /// <returns></returns>
        internal static void DoNotDisturbGroupAsync(string roomId, string userId, string offlineNoPushMsg, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/member/setOfflineNoPushMsg";
            //拼接参数
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId + "&userId=" + userId + "&offlineNoPushMsg=" + offlineNoPushMsg;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 显示群聊消息已读人数
        internal static void SetGroupShowReadAsync(string roomId, string showRead, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "room/update";
            //拼接参数
            string para = "access_token=" + Applicate.Access_Token + "&roomId=" + roomId + "&showRead=" + showRead;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

        #region 获取标识列表
        /// <summary>
        /// 获取标识列表
        /// </summary>
        /// <param name="userId">对应</param>
        /// <returns></returns>
        internal static void GetIdCodeListAsync(string userId, List<Action<DownloadString>> actions)
        {
            string url = Applicate.URLDATA.data.apiUrl + "label/getUserLabels";
            string para = "access_token=" + Applicate.Access_Token + "&userId=" + userId;
            HttpDownloader.DownloadString(new DownloadString { Url = url, Type = DownLoadFileType.String, HttpParas = para }, actions);
        }
        #endregion

    }
}
