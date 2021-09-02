using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    public class MemberLstAdapter : IBaseAdapter
    {
        private List<RoomMember> mDatas;//成员集合
        FrmMoreMember frmMoreMember;
        public override int GetItemCount()
        {
            return mDatas.Count;
        }
        public void SetMenberForm(FrmMoreMember moreMember)
        {
            this.frmMoreMember = moreMember;
        }
        public void BindDatas(List<RoomMember> data)
        {

            mDatas = data;
        }


        public override Control OnCreateControl(int index)
        {
            
            UseRoleMember uSEGrouops = new UseRoleMember();
          
            // uSEGrouops.Size = new Size(320, 60);
            uSEGrouops.BackColor = Color.White;
            string tiptext = string.Empty;
            if (mDatas[index].role.ToString() == "1")
            {
                tiptext = "群主";
            }
            else if (mDatas[index].role.ToString() == "2")
            {
                tiptext = "管理员";
            }
            else if (mDatas[index].role.ToString() == "4")
            {
                tiptext = "隐身人";
            }
            else
            {
                tiptext = "普通成员";
            }
            //ImageLoader.Instance.DisplayAvatar(frienddata.userId, this.pic_head);//设置头像
            if (mDatas[index].role == 1)
            {
                frmMoreMember.RoleHoste.UserId = mDatas[index].userId;
                if (frmMoreMember.RoleHoste.ExistsFriend())
                {
                    frmMoreMember.RoleHoste = frmMoreMember.RoleHoste.GetByUserId();
                }
                else
                {
                    frmMoreMember.RoleHoste.NickName = mDatas[index].nickName;
                }
            }
            uSEGrouops.roomjid = frmMoreMember.mfriend.UserId;
            Friend f = new Friend
            {
                UserId = mDatas[index].userId
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
                    f.NickName = mDatas[index].nickName;
                }

                uSEGrouops.friendData = f;
            }
            else
            {
                uSEGrouops.friendData = f.GetByUserId();
            }
            //不允许私聊
            if (frmMoreMember.mfriend.AllowSendCard == 0 && frmMoreMember. Role != 1)
            {
                uSEGrouops.pic_head.Click -= uSEGrouops.pic_head_Click;
                uSEGrouops.pic_head.Click += frmMoreMember. Pic_head_Click;
            }
            if (frmMoreMember.issum)
            {
                //if (mDatas[index].userId == Applicate.MyAccount.userId)
                //{
                //    return null;
                //}
                uSEGrouops.Click += frmMoreMember.USEGrouops_Click;
            }
            else
            {
                frmMoreMember.btnAdd.Visible = true;
            }
            
            uSEGrouops.CurrentRole = tiptext;

            ImageLoader.Instance.DisplayGroupManager(f.UserId, uSEGrouops.pic_head, mDatas[index].role);//设置头像);

            //if (frmMoreMember.Role == 4 && frmMoreMember. Role != 1)
            //{
            //    return null;//此时的uSEGrouops应该需要返回到下一个
            //}

            return uSEGrouops;
        }
       
        public override int OnMeasureHeight(int index)
        {
            return 50;
        }

        public override void RemoveData(int index)
        {
            mDatas.RemoveAt(index);
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
        public RoomMember GetDatas(int index)
        {

            return mDatas[index];
        }

    }
}
