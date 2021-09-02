using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk
{
    public class MessageModel
    {
        private string _messageId;
        private string _fromUserName;
        private string _fromUserId;
        private string _toUserId;
        private string _content;
        private long _timeSend;
        private int timeLen;
        private int _fileSize;
        private string _fileName;
        private string _filePath;
        /*以下数据存于本地数据库中*/
        private long _readTime;     // 已读时间
        private string _readPersons;    //已读人数
        private int _reSendCount;
        private int _messageState;  //信息状态
        private bool _isDownload;   //是否已下载
        private int _sendRead;      
        private int _isSend;        //是否已送达
        private int _isRead;        //是否已被对方阅读
        private int _isReceive;     //是否下载成功
        private int _isUpload;      //是否上传完成
        private long _timeReceive;  //收到回执的时间，接收后赋当前机器时间
        private int _isShowTime;
        private int _sendCount;
        private string _fromId;
        private string _objectId;
        private kWCMessageType _type;

        public string MessageId { get => _messageId; set => _messageId = value; }
        public string FromUserName { get => _fromUserName; set => _fromUserName = value; }
        public string FromUserId { get => _fromUserId; set => _fromUserId = value; }
        public string ToUserId { get => _toUserId; set => _toUserId = value; }
        public string Content { get => _content; set => _content = value; }
        public long TimeSend { get => _timeSend; set => _timeSend = value; }
        public kWCMessageType Type { get => _type; set => _type = value; }
        public int TimeLen { get => timeLen; set => timeLen = value; }
        public long ReadTime { get => _readTime; set => _readTime = value; }
        public string ReadPersons { get => _readPersons; set => _readPersons = value; }
        public int ReSendCount { get => _reSendCount; set => _reSendCount = value; }
        public int MessageState { get => _messageState; set => _messageState = value; }
        public bool IsDownload { get => _isDownload; set => _isDownload = value; }
        public int SendRead { get => _sendRead; set => _sendRead = value; }
        public int IsSend { get => _isSend; set => _isSend = value; }
        public int IsRead { get => _isRead; set => _isRead = value; }
        public int IsReceive { get => _isReceive; set => _isReceive = value; }
        public int IsUpload { get => _isUpload; set => _isUpload = value; }
        public long TimeReceive { get => _timeReceive; set => _timeReceive = value; }
        public int IsShowTime { get => _isShowTime; set => _isShowTime = value; }
        public int SendCount { get => _sendCount; set => _sendCount = value; }
        public string FromId { get => _fromId; set => _fromId = value; }
        public string ObjectId { get => _objectId; set => _objectId = value; }
        public int FileSize { get => _fileSize; set => _fileSize = value; }
        public string FileName { get => _fileName; set => _fileName = value; }
        public string FilePath { get => _filePath; set => _filePath = value; }
    }
}
