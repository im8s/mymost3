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
    class SelectedFriendAdapter : IBaseAdapter
    {
        private List<Friend> datas;
        private bool _issort = true;
        public FrmFriendSelect FrmFriend { get; set; }
        public FrmSortSelect frmSortSelect { get; set; }
        public bool isSort { get { return _issort; } set { _issort = value; }}
    
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
            UserSelectItem item = new UserSelectItem();
            item.Margin = new Padding(0);
            item.Friend = friend;
            if(isSort)
            {
                item.SelectedFriend += FrmFriend.OnUnSelectFriend;
            }
            else
            {
                item.SelectedFriend += frmSortSelect.OnUnSelectFriend;
            }
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

        public void InsertData(int index, Friend data)
        {
            datas.Insert(index, data);
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

        internal List<Friend> GetFriendDatas()
        {
            return datas;
        }
    }
}
