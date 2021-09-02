using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Helper.MVVM
{
    /// <summary>
    /// 窗口之间交互的注册事件
    /// </summary>
    public static class EQFrmInteraction
    {
        /// <summary>
        /// 用于表情添加到发送框
        /// <para>因为文本框内的emoji为图片，发送的messgae.content为code，所以要注意转化</para>
        /// </summary>
        public static string AddEmojiToTxtSend { get; }

        /// <summary>
        /// 通知聊天列表的消息需要更新消息状态
        /// </summary>
        public static string DrawIsRead { get; }

        /// <summary>
        /// 通知聊天列表的消息需要发送图片
        /// </summary>
        public static string SendImageAddMsgTab { get; }

        /// <summary>
        /// 通知聊天列表需要清空UI并删除聊天记录
        /// </summary>
        public static string ClearFdMsgsSingle { get; }
        
        /// <summary>
        /// 多选操作结束
        /// </summary>
        public static string MultiSelectEnd { get; }

        /// <summary>
        /// 批量删除
        /// </summary>
        public static string BatchDeleteMsg { get; }

        /// <summary>
        /// 移除一条消息
        /// </summary>
        public static string RemoveMsgOfPanel { get; }

        /// <summary>
        /// 添加At对象到发送框
        /// </summary>
        public static string AddAtUserToTxtSend { get; }

        /// <summary>
        /// 重新上传图片并更新气泡
        /// </summary>
        public static string ResumeUploadImageMsg { get; }

        /// <summary>
        /// 重新上传视频并更新气泡
        /// </summary>
        public static string ResumeUploadVideoMsg { get; }

        static EQFrmInteraction()
        {
            AddEmojiToTxtSend = nameof(AddEmojiToTxtSend);
            DrawIsRead = nameof(DrawIsRead);
            SendImageAddMsgTab = nameof(SendImageAddMsgTab);
            ClearFdMsgsSingle = nameof(ClearFdMsgsSingle);
            MultiSelectEnd = nameof(MultiSelectEnd);
            BatchDeleteMsg = nameof(BatchDeleteMsg);
            RemoveMsgOfPanel = nameof(RemoveMsgOfPanel);
            AddAtUserToTxtSend = nameof(AddAtUserToTxtSend);
            ResumeUploadImageMsg = nameof(ResumeUploadImageMsg);
            ResumeUploadVideoMsg = nameof(ResumeUploadVideoMsg);
        }
    }

}
