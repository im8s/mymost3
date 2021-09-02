using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;
using WinFrmTalk.Properties;

namespace WinFrmTalk.View.list
{
    public class LabelFrienfInfoAdapter : IBaseAdapter
    {
        List<Friend> friendlst = new List<Friend>();
        public UserLabel UserLabel { get; set; }

        public override int GetItemCount()
        {
            return friendlst.Count;
        }
       
        public override Control OnCreateControl(int index)
        {
            Friend friend = friendlst[index];
            FriendItem friendItem = new FriendItem();
            friendItem.Anchor = AnchorStyles.Right | AnchorStyles.Left | AnchorStyles.Top;
            friendItem.FriendData = friend;
            friendItem.DoubleClick += UserLabel.OnStartChat;

            PictureBox pic = new PictureBox();
            pic.SizeMode = PictureBoxSizeMode.StretchImage;
            pic.Image = Resources.CloseZh;
            pic.Anchor = AnchorStyles.Right;
            pic.Size = new Size(15, 15);
            pic.Location = new Point(211, (friendItem.Height - pic.Height) / 2);

            pic.MouseEnter += (sen, eve) =>
            {
                friendItem.BackColor = ColorTranslator.FromHtml("#D8D8D9");//悬浮颜色
            };
            pic.MouseLeave += (sen, eve) =>
            {
                friendItem.BackColor = Color.Transparent;
            };

            // 删除成员
            pic.MouseClick += (sen, eve) =>
            {
                UserLabel.OnDeleteLableFriend(friend);
            };

            return friendItem;
        }

        public override int OnMeasureHeight(int index)
        {
            return 50;
        }

        public override void RemoveData(int index)
        {
            friendlst.RemoveAt(index);
        }
        public void BindDatas(List<Friend> data)
        {
            friendlst = data;
        }
    }
}
