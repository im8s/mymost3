using Newtonsoft.Json;
using PBMessage;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Model
{
    class CourseMessage
    { 
        public string courseId { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string courseMessageId { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string createTime { get; set; }

        /// <summary>

        /// </summary>
        public string message { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string messageId { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string userId { get; set; }


        public MessageObject ToMessageObject() {

            string text = message.Replace("&quot;", "\"");

            var body = JsonConvert.DeserializeObject<ChatMessage>(text);

            return ShiKuManager.mSocketCore.ToMessageObject(body);
        }

    }
}
