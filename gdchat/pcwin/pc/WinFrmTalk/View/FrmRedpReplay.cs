using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.View
{
    public partial class FrmRedpReplay : FrmBase
    {
       public  string RedPaperId { get; set; }
        public string ReplayText { get; set; }
        public FrmRedpReplay()
        {
            InitializeComponent();
        }
        /// <summary>
        /// 确定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnsure_Click(object sender, EventArgs e)
        {
            
            string text = txtthanks.Text.Trim();
           
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "redPacket/reply")
               .AddParams("access_token", Applicate.Access_Token)
               .AddParams("id", RedPaperId)
                 .AddParams("reply", text)
               .Build().Execute((sccess, data) =>
               {
                   if (sccess)
                   {
                       //string code = UIUtils.DecodeString(data, "resultCode");

                       //if (UIUtils.IsNull(code))
                       //{

                       //}
                       ReplayText = text;
                       this.DialogResult = DialogResult.OK;
                       this.Close();

                   }
               });
        }
    }
}
