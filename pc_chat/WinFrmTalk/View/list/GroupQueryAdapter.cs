using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    public class GroupQueryAdapter : IBaseAdapter
    {
        private List<DownRoom> datas;
        public FrmGroupQuery FrmGroupQuery { get; set; }
        public void BindFriendData(List<DownRoom> data)
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
            DownRoom room = datas[index];
            AddGroupItem item = new AddGroupItem();
    
            item.OnClickJoin = FrmGroupQuery.OnItemClickJoin;
            item.OnClickSend = FrmGroupQuery.OnItemClickSend;

            item.DataContext = room.ToRoom();
            return item;
        }

        public override int OnMeasureHeight(int index)
        {
            return 55;
        }

        public override void RemoveData(int index)
        {
            datas.RemoveAt(index);
        }

        public int AddRangeData(List<DownRoom> data)
        {
            int index = datas != null ? datas.Count : 0;
            datas.AddRange(data);
            return index;
        }
    }
}
