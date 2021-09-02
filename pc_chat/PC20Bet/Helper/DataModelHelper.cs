using WinFrmTalk.Model;

namespace WinFrmTalk
{
    public static class DataModelHelper
    {
        #region DataOfFriends 转 MessageListItem
        /// <summary>
        /// <see cref="DataOfFriends"/>转<see cref="MessageListItem"/>
        /// </summary>
        /// <param name="friend"></param>
        /// <returns></returns>
        public static MessageListItem ToMsgListItem(this Friend friend)
        {
            MessageListItem tmpitem = new MessageListItem();
            try
            {
                tmpitem = new MessageListItem()//实例化一个消息项
                {
                    MessageTitle = friend.NickName,
                    Jid = friend.IsGroup == 0 ? friend.UserId : friend.UserId,  //设置UserId(Jid)                    ShowTitle = friend.remarkName//备注名
                };
            }
            catch (System.Exception ex)
            {
                ConsoleLog.Output("ToMsgListItem=-" + ex.Message);
            }
            return tmpitem;
        }
        #endregion

        #region DataOfUserDetial 转 DataOfFriends
        /// <summary>
        /// <see cref="DataOfUserDetial"/>转<see cref="DataOfFriends"/>
        /// </summary>
        /// <param name="friend"></param>
        /// <returns></returns>
        public static Friend ToDataOfFriend(this DataOfUserDetial friend)
        {
            return new Friend()//实例化DataOfFriend
            {
                AreaId = friend.areaId,
                CityId = friend.cityId,
                CreateTime = friend.createTime,
                Description = friend.description,
                ProvinceId = friend.provinceId,
                Sex = friend.sex,
                Status = friend.status,
                Telephone = friend.Telephone
            };
        }
        #endregion



        #region Room转MessageListItem
        /// <summary>
        /// Room转MessageListItem
        /// </summary>
        /// <param name="room"></param>
        /// <returns></returns>
        //public static MessageListItem ToMsgItem(this Room room)
        //{
        //    MessageListItem item = new MessageListItem()
        //    {
        //        Id = room.id,
        //        ShowTitle = room.name,
        //        MessageTitle = room.name,
        //        MessageItemType = ItemType.Group,
        //        Jid = room.jid,
        //        Avator = Applicate.LocalConfigData.GetDisplayAvatorPath(room.jid)
        //    };
        //    return item;
        //}
        #endregion

    }
}
