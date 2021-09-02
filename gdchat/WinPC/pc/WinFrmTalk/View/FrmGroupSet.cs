using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View
{
    public partial class FrmGroupSet : FrmBase
    {
      

        Dictionary<string, Friend> Selectdata = new Dictionary<string, Friend>();
        public FrmGroupSet()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon.Handle);//加载icon图标
        }
        string roomid = "";
       
        internal void SetRoomId(string id)
        {
            roomid = id;
        }


        internal void SetRoomData(Friend friend)
        {
          
        }

        private void FrmGroupSet_Load(object sender, EventArgs e)
        {
            //roomannounce1.Roomid = roomid;

            //roomannounce1. LoadData();

        }

        private void useGroutsetTest1_Load(object sender, EventArgs e)
        {

        }
    }
}