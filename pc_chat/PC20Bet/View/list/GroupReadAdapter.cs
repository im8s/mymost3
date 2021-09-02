using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    public class GroupReadAdapter : IBaseAdapter
    {
        List<MessageObject> mDatas = new List<MessageObject>();
        public override int GetItemCount()
        {
            return mDatas.Count;
        }

        public override Control OnCreateControl(int index)
        {
            var useRoleMember = new USEReaded();
            useRoleMember.messageData = mDatas[index];
            //var useRoleMember = new NewsItem();
            return useRoleMember;
        }

        public override int OnMeasureHeight(int index)
        {
            return 60;
        }

        public override void RemoveData(int index)
        {
            mDatas.Remove(mDatas[index]);
        }
        public void BindDatas(List<MessageObject> data)
        {
            mDatas = data;
        }
    }
}
