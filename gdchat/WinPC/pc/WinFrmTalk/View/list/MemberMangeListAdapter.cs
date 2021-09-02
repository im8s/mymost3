using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    public class MemberMangeListAdapter : IBaseAdapter
    {
        private List<RoomMember> mDatas;//成员集合

        FrmMagent mageng;

        public override int GetItemCount()
        {
            return mDatas.Count;
        }


        public void SetMaengForm(FrmMagent mageng)
        {
            this.mageng = mageng;
        }


        public void BindDatas(List<RoomMember> data)
        {

            mDatas = data;
        }
        
        public override Control OnCreateControl(int i)
        {
            RoomMember data = mDatas[i];
            USEMange uSEMange = new USEMange();
            uSEMange.MouseEnter += mageng.USEMange_MouseEnter;
            uSEMange.MouseLeave += mageng.Use_MouseLeave;

            //显示好友名称
            Friend f = new Friend
            {
                //  nickName = memberLst[i].nickName,
                UserId = mDatas[i].userId
            };

            bool a = f.ExistsFriend();//判断是否为好友
            if (!a)
            {
                if (f.UserId == Applicate.MyAccount.userId)
                {
                    f.NickName = Applicate.MyAccount.nickname;
                }
                else
                {
                    f.NickName = mDatas[i].nickName;
                }

                uSEMange.friendData = f;
            }
            else
            {
                uSEMange.friendData = f.GetByUserId();
            }
            
        
            if (data.userId == mageng.CurrentUserid)
            {
                mageng. Role = data.role;
            }
            //被设置成为了隐身人

            //好友昵称与群昵称一致时不现实，不一致就显示群昵称
            if (data.nickName == uSEMange.friendData.NickName)
            {
                uSEMange.lblName.Text = null;
            }
            else
            {
                uSEMange.lblName.Text = data.nickName;
            }
            uSEMange.Tag = data.role.ToString();

            // uSEMange.Size = new Size(288, 50);
            ImageLoader.Instance.DisplayAvatar(data.userId, uSEMange.pic_head);
            //  uSEMange.IsSelected = false;
            uSEMange.MouseDown += mageng. USEGrouops_MouseDown;


            uSEMange.Click += mageng.FriendItem1_Click;



            return uSEMange;
        }

        public RoomMember GetDatas(int index)
        {

            return mDatas[index];
        }

        public int GetIndexByFriendId(string userId)
        {

            for (int i = 0; i < GetItemCount(); i++)
            {
                if (GetDatas(i).userId.Equals(userId))
                {
                    return i;
                }
            }

            return -1;
        }

        public override int OnMeasureHeight(int index)
        {
            return 50;
        }

        public override void RemoveData(int index)
        {
            mDatas.RemoveAt(index);
        }
        
        
    }
}
