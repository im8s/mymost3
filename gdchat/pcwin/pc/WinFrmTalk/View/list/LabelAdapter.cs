using Newtonsoft.Json.Linq;
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
    public class LabelAdapter : IBaseAdapter
    {
        List<FriendLabel> friendLabels;
        public UserLabel UserLabel { get; set; }

        public override int GetItemCount()
        {
            if (friendLabels == null)
            {
                return 0;
            }

            return friendLabels.Count;
        }


        public override Control OnCreateControl(int index)
        {
            FriendLabel data = friendLabels[index];
            UserLabelItem item = new UserLabelItem();
            item.FriendLabel = data;
            UserLabel.BindContextMenu(item);
            item.MouseDown += UserLabel.OnMouseDownLable;

            return item;
        }

        public override int OnMeasureHeight(int index)
        {
            return 65;
        }

        public override void RemoveData(int index)
        {
            friendLabels.RemoveAt(index);
        }
        public void BindDatas(List<FriendLabel> data)
        {
            friendLabels = data;
        }
    }
}
