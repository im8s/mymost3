using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;
using WinFrmTalk.Properties;

namespace WinFrmTalk.View.list
{
    public class ChatSometimesAdapter : IBaseAdapter
    {
        List<string> textlst = new List<string>();

        public override bool Equals(object obj)
        {
            return base.Equals(obj);
        }

        public override int GetHashCode()
        {
            return base.GetHashCode();
        }

        public override int GetItemCount()
        {
            throw new NotImplementedException();
        }

        public override Control OnCreateControl(int index)
        {
            UserChatSometime userChatSometime = new UserChatSometime();



            userChatSometime.Sometimetext = textlst[index];//文本值
            // 删除当前
            userChatSometime.picdeleate.MouseClick += (sen, eve) =>
            {
               // UserLabel.OnDeleteLableFriend(friend);
            };

            return userChatSometime;
        }

        public override int OnMeasureHeight(int index)
        {
            throw new NotImplementedException();
        }

        public override void RemoveData(int index)
        {
            throw new NotImplementedException();
        }

        public override string ToString()
        {
            return base.ToString();
        }
    }
}
