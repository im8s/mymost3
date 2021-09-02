using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk
{
    /// <summary>
    /// 群组成员列表
    /// </summary>
    public class JsonRoomMemberList : JsonBase
    {

        #region Constructor
        public JsonRoomMemberList()
        {
            data = new List<RoomMember>();
        }
        #endregion

        public List<RoomMember> data { get; set; }

    }
}
