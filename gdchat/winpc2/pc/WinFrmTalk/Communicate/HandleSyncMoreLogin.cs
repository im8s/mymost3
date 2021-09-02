using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Timers;
using agsXMPP.protocol.client;
using Newtonsoft.Json;
using WinFrmTalk;
using WinFrmTalk.Communicate;
using WinFrmTalk.Model;

/// <summary>
/// 多点登录管理
/// </summary>
public class HandleSyncMoreLogin
{
    private const string TAG = "sync";
    private const string SYNC_LOGIN_PASSWORD = "sync_login_password";
    private const string SYNC_PAY_PASSWORD = "sync_pay_password";
    private const string SYNC_PRIVATE_SETTINGS = "sync_private_settings";
    private const string SYNC_LABEL = "sync_label";


 

  

    private static void CreateRoom(Friend friend, XmppManager coreService)
    {
        friend.Status = Friend.STATUS_FRIEND;
        friend.InsertAuto();
        long seconds = TimeUtils.CurrentTime() - friend.CreateTime;
        coreService.JoinRoom(friend.UserId, seconds);
        Messenger.Default.Send(friend, MessageActions.ROOM_UPDATE_INVITE);//刷新列表
    }

    private static void DeleteRoom(Friend friend, XmppManager coreService)
    {
       
    }


    private static void UpdateRoom(Friend friend)
    {
        //friend.status = Friend.STATUS_FRIEND;
        //friend.InsertAuto();
        //long seconds = TimeUtils.CurrentTime() - friend.createTime;
        //coreService.JoinRoom(friend.userId, seconds);
        //Messenger.Default.Send(friend, MessageActions.ROOM_UPDATE_INVITE);//刷新列表
    }



    
}
