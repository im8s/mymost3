using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Channels;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    class BlackListAdapter : IBaseAdapter
    {
        private List<Friend> datas;

        public BlockListPage BlockList { get; set; }

        public void BindFriendData(List<Friend> data)
        {
            datas = data;
        }

        public void AppendRange(List<Friend> data)
        {
            if (data == null)
            {
                datas = data;
            }
            else
            {
                datas.AddRange(data);
            }
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
            BlackItem item = new BlackItem();
            item.Anchor = AnchorStyles.Right | AnchorStyles.Left | AnchorStyles.Top;
            item.Width = BlockList.GetListWidth();
            item.DataContext = friend;
            item.CancelBlockCommand = BlockList.CancelBlock;
            return item;
        }

        public override int OnMeasureHeight(int index)
        {
            return 72;
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
    }
}
