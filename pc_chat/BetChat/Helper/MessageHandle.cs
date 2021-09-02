using CCWin.SkinControl;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    public class MessageHandle
    {
        #region 反序列化
        public MessageModel GetMessageModel(string strJson)
        {
            MessageModel msgObj = JsonConvert.DeserializeObject<MessageModel>(strJson);
            return msgObj;
        }
        #endregion

        #region 序列化
        public string GetMessageJson()
        {
            MessageModel messageModel = new MessageModel();
            messageModel.MessageId = "60f89c0aff3f4d459ca6a20ac9e27660";
            messageModel.FromUserId = "10005154";
            messageModel.FromUserName = "zas3";
            messageModel.Content = "23333";
            messageModel.TimeSend = 1545633778;
            messageModel.Type = (kWCMessageType)Enum.ToObject(typeof(kWCMessageType), 1);
            messageModel.ToUserId = "10009349";
            messageModel.IsSend = 1;
            messageModel.IsRead = 0;
            messageModel.IsReceive = 0;

            return JsonConvert.SerializeObject(messageModel);
        }
        #endregion

        #region 序列化(图片)
        public string GetMessageImageJson()
        {
            MessageModel messageModel = new MessageModel();
            messageModel.MessageId = "cd8bb35f62db4f0fac139f32a35289f1";
            messageModel.FromUserId = "10009183";
            messageModel.FromUserName = "test04";
            messageModel.Content = @"http://47.91.232.3:8089/u/9183/10009183/201901/o/619c35f9320c42f693575c2c8baa7c53.jpg";
            messageModel.TimeSend = 1547447013;
            messageModel.Type = (kWCMessageType)Enum.ToObject(typeof(kWCMessageType), 2);
            messageModel.ToUserId = "10009349";
            messageModel.FileName = @"/storage/emulated/0/Android/data/com.sk.weichat/cache/luban_disk_cache/1547447013340117.jpg";
            messageModel.FileSize = 110106;
            messageModel.IsSend = 1;
            messageModel.IsRead = 1;
            messageModel.IsReceive = 0;

            return JsonConvert.SerializeObject(messageModel);
        }
        #endregion

        #region 序列化(Gif)
        public string GetMessageGifJson()
        {
            MessageModel messageModel = new MessageModel();
            messageModel.MessageId = "60f89c0aff3f4d459ca6a20ac9e27660";
            messageModel.FromUserId = "10005154";
            messageModel.FromUserName = "zas3";
            messageModel.Content = @"sixteen.gif";
            messageModel.TimeSend = 1545633778;
            messageModel.Type = (kWCMessageType)Enum.ToObject(typeof(kWCMessageType), 5);
            messageModel.ToUserId = "10009349";

            return JsonConvert.SerializeObject(messageModel);
        }
        #endregion

        #region 序列化(Voice)
        public string GetMessageVoiceJson()
        {
            MessageModel messageModel = new MessageModel();
            messageModel.MessageId = "8f2c8b79b2834ff1ac33e96f558f4090";
            messageModel.FromUserId = "10005154";
            messageModel.FromUserName = "zas3";
            messageModel.Content = @"http://47.91.232.3:8089/u/7332/10017332/201902/3b3f1611f0eb4896a640cc39f1a6356b.amr";
            messageModel.TimeSend = 1545633778;
            messageModel.Type = (kWCMessageType)Enum.ToObject(typeof(kWCMessageType), 3);
            messageModel.ToUserId = "10009349";
            messageModel.FileSize = 4518;
            messageModel.FileName = "/storage/emulated/0/Android/data/com.sk.weichat/files/10017332/Music/3b3f1611f0eb4896a640cc39f1a6356b.amr";
            messageModel.TimeLen = 3;
            messageModel.IsSend = 1;
            messageModel.IsRead = 1;
            messageModel.IsReceive = 0;

            return JsonConvert.SerializeObject(messageModel);
        }
        #endregion

        #region 序列化(File)
        public string GetMessageFileJson()
        {
            MessageModel messageModel = new MessageModel();
            messageModel.MessageId = "8f2c8b79b2834ff1ac33e96f558f4090";
            messageModel.FromUserId = "10009349";
            messageModel.FromUserName = "Michael";
            messageModel.Content = @"http://47.91.232.3:8089/u/9183/10009183/201901/7597fd723f3341808c34f00d36ef14ae.amr";
            messageModel.TimeSend = 1550117959;
            messageModel.Type = (kWCMessageType)Enum.ToObject(typeof(kWCMessageType), 9);
            messageModel.ToUserId = "10009183";
            messageModel.FileSize = 16;
            messageModel.FilePath = @"C:\Users\Administrator\Downloads\ShikuIM\Chat\3fa3fb6a1c3241349f14ff0c3b27dfce.amr";
            messageModel.FileName = "3fa3fb6a1c3241349f14ff0c3b27dfce.amr";
            messageModel.IsSend = 1;
            messageModel.IsRead = 1;
            messageModel.IsReceive = 0;

            return JsonConvert.SerializeObject(messageModel);
        }
        #endregion

        #region 序列化(Card)
        public string GetMessageCardJson()
        {
            MessageModel messageModel = new MessageModel();
            messageModel.MessageId = "035af09657e64270bc66b3c67c21e381";
            messageModel.FromUserId = "10009349";
            messageModel.FromUserName = "Michael";
            messageModel.Content = @"Zar3";
            messageModel.TimeSend = 1550117959;
            messageModel.Type = (kWCMessageType)Enum.ToObject(typeof(kWCMessageType), 8);
            messageModel.ToUserId = "10009349";
            messageModel.FileName = "3fa3fb6a1c3241349f14ff0c3b27dfce.amr";
            messageModel.ObjectId = "10005154";
            messageModel.IsSend = 1;
            messageModel.IsRead = 0;
            messageModel.IsReceive = 0;

            return JsonConvert.SerializeObject(messageModel);
        }
        #endregion

        #region 序列化(Video)
        public string GetMessageVideoJson()
        {
            MessageModel messageModel = new MessageModel();
            messageModel.MessageId = "f7d2e8ab7b0b4ca5997dacdf8d8e45aa";
            messageModel.FromUserId = "10005154";
            messageModel.FromUserName = "test04";
            messageModel.Content = @"http://47.91.232.3:8089/u/9183/10009183/201902/881ff7568aca40f88828b2e6b4101751.mp4";
            messageModel.TimeSend = 1550117959;
            messageModel.Type = (kWCMessageType)Enum.ToObject(typeof(kWCMessageType), 6);
            messageModel.ToUserId = "10009349";
            messageModel.FileName = "881ff7568aca40f88828b2e6b4101751.mp4";
            messageModel.IsSend = 1;
            messageModel.IsRead = 0;
            messageModel.IsReceive = 0;

            return JsonConvert.SerializeObject(messageModel);
        }
        #endregion

        #region 序列化(Location)
        public string GetMessageLocationJson()
        {
            MessageModel messageModel = new MessageModel();
            messageModel.MessageId = "0c661fa4150d415fab15b4189116123b";
            messageModel.FromUserId = "10005154";
            messageModel.FromUserName = "test04";
            messageModel.Content = @"http://47.91.232.3:8089/u/9183/10009183/201902/o/f40910e6091b4a40aefaca9098539560.jpg";
            messageModel.TimeSend = 1550117959;
            messageModel.Type = (kWCMessageType)Enum.ToObject(typeof(kWCMessageType), 4);
            messageModel.ToUserId = "10009349";
            messageModel.FileName = "f40910e6091b4a40aefaca9098539560.jpg";
            messageModel.ObjectId = "中国广东省深圳市龙岗区五和大道";
            messageModel.IsSend = 1;
            messageModel.IsRead = 0;
            messageModel.IsReceive = 0;

            return JsonConvert.SerializeObject(messageModel);
        }
        #endregion

        #region 序列化(Remind)
        public string GetMessageRemindJson()
        {
            MessageModel messageModel = new MessageModel();
            messageModel.MessageId = "0c661fa4150d415fab15b4189116123b";
            messageModel.FromUserId = "10009183";
            messageModel.FromUserName = "test04";
            messageModel.Content = @"山中恶犬撤回了一条信息";
            messageModel.TimeSend = 1550117959;
            messageModel.Type = (kWCMessageType)Enum.ToObject(typeof(kWCMessageType), 202);
            messageModel.ToUserId = "10009349";
            messageModel.FileSize = 148;
            messageModel.IsSend = 1;
            messageModel.IsRead = 0;
            messageModel.IsReceive = 0;

            return JsonConvert.SerializeObject(messageModel);
        }
        #endregion

        #region 序列化(Remind)
        public MessageObject GetMessageRedBarJson()
        {
            MessageObject messageModel = new MessageObject();
            messageModel.messageId = Guid.NewGuid().ToString("N");
            messageModel.fromUserId = "10009183";
            messageModel.fromUserName = "test04";
            messageModel.content = @"发出红包，请在手机上查看";
            messageModel.timeSend = 1550117959;
            messageModel.type = (kWCMessageType)28;
            messageModel.toUserId = "10009349";
            messageModel.fileSize = 0;
            messageModel.isSend = 1;
            messageModel.isRead = 0;

            return messageModel;
        }
        #endregion

        #region 判断对是聊天气泡鼠标右键的事件有哪些
        public void MenuItemVisible(ref SkinContextMenuStrip contextMenuScript, kWCMessageType kw_type)
        {
            //设置可见度
            new KWTypeMenuStripDictionary().SettingMenuStripVisible(ref contextMenuScript, kw_type);
        }


        #endregion


    }
}
