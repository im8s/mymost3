using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Channels;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    class GroupFileAdapter : IBaseAdapter
    {
        private List<RoomFileBean> datas;
        public FrmGroupFileList FrmGroupFile { get; set; }

        public void BindFriendData(List<RoomFileBean> data)
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
            RoomFileBean roomFile = GetDatas(index);

            GroupFileItem item = FrmGroupFile.NewGroupFileItem(roomFile);
            FrmGroupFile.mRoomId = item.roomJid;
            item.DownState = 0;
            return item;
        }

        public override int OnMeasureHeight(int index)
        {
            return 80;
        }
        public void InsertData(int index, RoomFileBean data)
        {
            datas.Insert(index, data);
        }
        public override void RemoveData(int index)
        {
            datas.RemoveAt(index);
        }
        public RoomFileBean GetDatas(int index)
        {
            return datas[index];
        }

        public int GetIndexBySharId(string Sharid)
        {

            for (int i = 0; i < GetItemCount(); i++)
            {
                if (datas[i].shareId.Equals(Sharid))
                {
                    return i;
                }
            }

            return -1;
        }
    }
}
