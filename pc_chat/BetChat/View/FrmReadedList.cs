using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.View.list;

namespace WinFrmTalk.View
{
    public partial class FrmReadedList : FrmBase
    {

        GroupReadAdapter mAdapter;

        public Friend GetFriend { get; set; }

        public FrmReadedList()
        {
            InitializeComponent();

            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            this.Text = "已读列表";
            mAdapter = new GroupReadAdapter();
        }


        public void DesMessage(MessageObject msg)
        {
            List<MessageObject> msgLst = new List<MessageObject>();

            msgLst = msg.GetReadPersonsList(GetFriend.RoomId, msg.messageId, 0);
            mAdapter.BindDatas(msgLst);
            xListView1.SetAdapter(mAdapter);
        }
    }
}
