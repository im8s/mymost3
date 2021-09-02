using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;

namespace WinFrmTalk.Helper
{
    class TeachUlUtils
    {/// <summary>
     /// 讲课录制
     /// </summary>
     /// <param name="CourseName">课件名称</param>
     /// <param name="msg"></param>
     /// <param name="CreateTime">创建时间</param>
        internal static void CourseMade(string CourseName, double TimeSendStart, double TimeSendEnd, MessageObjectDataDictionary targetMsgData)
        {
            List<MessageObject> datas = new List<MessageObject>();


            var msglist = targetMsgData.GetMsgList();

            //获取messageobject的集合
            foreach (var item in msglist)
            {
                if (item.timeSend >= TimeSendStart && item.timeSend <= TimeSendEnd)
                    datas.Add(item);
            }


            StringBuilder sb = new StringBuilder();
            //拼接messageid
            for (int i = 0; i < datas.Count; i++)
            {
                //过滤掉消息，留下自己的语音和文字消息
                if (datas[i].IsMySend())
                {
                    //讲课录制支持文字、语音、图片、视频、文件五种类型
                    var type = datas[i].type;
                    if (type == kWCMessageType.Text || datas[i].type == kWCMessageType.Voice || datas[i].type == kWCMessageType.Image || datas[i].type == kWCMessageType.Video || datas[i].type == kWCMessageType.File)
                    {
                        sb.Append(datas[i].messageId);
                        sb.Append(",");
                    }
                }
            }

            if (sb.Length == 0)
            {
                HttpUtils.Instance.ShowTip("没有可以录制的数据");
                return;
            }
            //截取掉最后一个逗号
            sb.Remove(sb.Length - 1, 1);

            string roomJid = "";
            if (datas[0].isGroup == 1)
            {
                roomJid = datas[0].toUserId;
            }
            else
            {
                roomJid = "0";
            }


            //添加课件
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/course/add")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("courseName", CourseName)
                .AddParams("roomJid", roomJid)
                .AddParams("createTime", TimeUtils.CurrentIntTime().ToString())
                .AddParams("messageIds", sb.ToString())
                .AddParams("userId", Applicate.MyAccount.userId)
                .Build().ExecuteJson<object>((sccess, obj) =>
                {
                    if (sccess)
                    { //返回值说明： text：加密后的内容
                      //123
                        Messenger.Default.Send("1", MessageActions.UPDATE_COURSE_LIST);
                        HttpUtils.Instance.ShowTip("录制成功");
                    }
                });
        }
    }
}
