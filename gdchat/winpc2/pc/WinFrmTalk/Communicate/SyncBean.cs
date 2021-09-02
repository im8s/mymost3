using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Communicate
{
    public class SyncBean
    {
        public string tag { get; set; }
        public string userId { get; set; }
        public string friendId { get; set; }
        public long operationTime { get; set; }
    }


    public class SyncBeanList
    {
        public SyncBeanList()
        {
            data = new List<SyncBean>();
        }

        public List<SyncBean> data { get; set; }
    }
}
