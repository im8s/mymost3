using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    public class RedReciviceAdapter : IBaseAdapter
    {
        public List<Receivers> mDatas;
        public string Roomjid { get; set; }
        public override int GetItemCount()
        {
            return mDatas.Count;
        }

        public override Control OnCreateControl(int index)
        {
            Usereceiveredpaper usereceiveredpaper = new Usereceiveredpaper();
            usereceiveredpaper.lab_money.Text = mDatas[index].money;
            usereceiveredpaper.lab_name.Text = mDatas[index].userName;
            usereceiveredpaper.lab_time.Text= TimeUtils.FromatTime(Convert.ToInt64(mDatas[index].time), "MM-dd");
            if(mDatas[index].reply!=null)
            {
                usereceiveredpaper.lblThanks.Text = mDatas[index].reply;
            }
            ImageLoader.Instance.DisplayAvatar(mDatas[index].userId, usereceiveredpaper.pic_head);
            if(Roomjid!=null|| Roomjid!="")
            {
                if (mDatas[index].userId == Applicate.MyAccount.userId)
                {
                    usereceiveredpaper.pic_head.Visible = true;
                    usereceiveredpaper.lab_me.Visible = true;
                }
            }
            return usereceiveredpaper;
        }

        public override int OnMeasureHeight(int index)
        {
            return 55;
        }

        public override void RemoveData(int index)
        {
            
        }
        public void BindDatas(List<Receivers> data)
        {
            mDatas = data;

        }
    }
}
