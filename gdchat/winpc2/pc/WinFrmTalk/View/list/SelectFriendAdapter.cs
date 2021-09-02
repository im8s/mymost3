using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Channels;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    class SelectFriendAdapter : IBaseAdapter
    {
        private List<Friend> datas;
        private bool _isSort = true;
        public FrmFriendSelect FrmFriend { get; set; }
        public FrmSortSelect frmSortSelect { get; set; }
        public bool isSort { get { return _isSort; } set { _isSort = value; } }

        public void BindFriendData(List<Friend> data)
        {
            datas = data;
        }

        public override int GetItemCount()
        {
            if (datas != null)
            {
                return datas.Count;
            }

            return 0;
        }

        public override Control OnCreateControl(int index)
        {
            Friend friend = GetDatas(index);

            UserItem item = new UserItem();
            item.Friend = friend;
            item.CheckState = friend.UserType == 1;
            if (isSort)
            {
                item.SelectedFriend += FrmFriend.OnSelectFriend;
            }
            else
            {
                item.SelectedFriend += frmSortSelect.OnSelectFriend;
            }
            //   item.SelectedFriend += FrmFriend.OnSelectFriend;
            return item;
        }

        public override int OnMeasureHeight(int index)
      {
            return 60;
        }


        public override void RemoveData(int index)
        {
            datas.RemoveAt(index);
        }

        public Friend GetDatas(int index)
        {
            return datas[index];
        }

        public int GetIndexById(string userId)
        {
            for (int i = 0; i < GetItemCount(); i++)
            {
                if (GetDatas(i).UserId.Equals(userId))
                {
                    return i;
                }
            }

            return -1;
        }

        internal List<Friend> GetDataFriends()
        {
            return datas;
        }

        internal List<Friend> SearchNickName(string text)
        {

            List<Friend> friends = new Friend().SearchFriendByName(text);
            return friends;
        }
    }
}
