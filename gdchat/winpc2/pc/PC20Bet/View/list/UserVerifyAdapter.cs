using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    public class UserVerifyAdapter : IBaseAdapter
    {
        private List<VerifingFriend> mDatas;

        public USEUserVerifyPage VerifyPager { get; set; }


        public override int GetItemCount()
        {
            if (mDatas != null)
            {
                return mDatas.Count;
            }

            return 0;
        }

        public override Control OnCreateControl(int index)
        {
            VerifingFriend friend = mDatas[index];

            VerifyItem item = new VerifyItem();
            item.DataContext = friend;
            item.Width = VerifyPager.GetListWidth();
            item.AcceptCommand = VerifyPager.AgreeVerifyFriend;
            item.AnswerCommand = VerifyPager.AnswerFriend;

            return item;
        }

        public override int OnMeasureHeight(int index)
        {
            return 72;
        }


        public void BindDatas(List<VerifingFriend> data)
        {
            mDatas = data;
        }


        public void InsertData(int index, VerifingFriend data)
        {
            mDatas.Insert(index, data);
        }

        public void RefreshData(int index, VerifingFriend data)
        {
            mDatas[index] = data;
        }

        public override void RemoveData(int index)
        {
            mDatas.RemoveAt(index);
        }

        public void MoveData(int fromIndex, int toIndex)
        {
            VerifingFriend temp = mDatas[fromIndex];

            if (fromIndex < toIndex)
            {
                int next = fromIndex + 1;
                while (next <= toIndex)
                {
                    // 移动数据
                    mDatas[next - 1] = mDatas[next];
                    next++;
                }
            }
            else
            {
                int next = fromIndex - 1;
                while (next >= toIndex)
                {
                    // 移动数据
                    mDatas[next + 1] = mDatas[next];
                    next--;
                }
            }

            mDatas[toIndex] = temp;
        }


        public int GetIndexByFriendId(string userId)
        {

            for (int i = 0; i < GetItemCount(); i++)
            {
                if (mDatas[i].userId.Equals(userId))
                {
                    return i;
                }
            }

            return -1;
        }
    }
}
