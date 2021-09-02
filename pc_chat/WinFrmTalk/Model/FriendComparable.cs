using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Model
{
    class FriendComparable : IComparer<Friend>
    {
        public int Compare(Friend from, Friend to)
        {
            long a = PinYinUtils.GetIntSpellCode(from.GetRemarkName());
            long b = PinYinUtils.GetIntSpellCode(to.GetRemarkName());

            if (a == b)
            {
                return 0;
            }
            else if (a > b)
            {
                return 1;
            }
            else
            {
                return -1;
            }
        }
    }
}
