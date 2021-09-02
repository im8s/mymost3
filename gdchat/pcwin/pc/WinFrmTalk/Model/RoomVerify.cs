using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk
{

    /// <summary>
    /// 群验证主体
    /// </summary>
    public class RoomVerify
    {
        public string userIds { get; set; }
        public string userNames { get; set; }
        public string roomJid { get; set; }
        /// <summary>
        /// 0为别人邀请,else自己申请进群
        /// </summary>
        public string isInvite { get; set; }
        /// <summary>
        /// 进群验证
        /// </summary>
        public string reason { get; set; }

        #region 序列化
        public string toJson()
        {
            return JsonConvert.SerializeObject(this);
        }
        #endregion

        #region 反序列化
        public RoomVerify toModel(string roomJson)
        {
            RoomVerify msgObj = JsonConvert.DeserializeObject<RoomVerify>(roomJson);
            return msgObj;
        }
        #endregion
    }
}
