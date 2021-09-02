using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View
{
    public partial class FrmReplay : FrmSuspension
    {
        public FrmReplay()
        {
            InitializeComponent();
        }

        public Usertext mSelectItem;
        public Action<string> Sometimetext;
        public List<CommonText> commonTextlst = new List<CommonText>();
        private void FrmReplay_Load(object sender, EventArgs e)
        {

        }
        internal void loadData(MouseEventArgs e)
        {

           // HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "CustomerService/commonText/getByUserId")
           //.AddParams("access_token", Applicate.Access_Token)
           // .AddParams("pageIndex", "0")
           //  .AddParams("pageSize", "10")
           ////  .AddParams("companyId", "0")//等待修改调用传值userid
           //.Build().Execute((susee, datalist) =>
           //{
           //    if (susee)
           //    {
           //        JArray array = JArray.Parse(UIUtils.DecodeString(datalist, "data"));
           //        foreach (var item in array)
           //        {
           //            //commonTex commonTex = new commonTex();
           //            commonTex.content= UIUtils.DecodeString(item, "content");
           //            commonTextlst.Add(commonTex);

           //            Usertext usertext = new Usertext();

           //            usertext.sometext = commonTex.content;
           //            if(this.Height<=260)
           //            {
           //                palcommonTex.Height += 80;
           //                this.Height += 80;
           //            }
                     
           //            palcommonTex.Controls.Add(usertext);
                      
           //        }
           //          ///将数据绑定在列表中
           //         // HttpUtils.Instance.ShowTip("添加成功");
           //    }
           //});
            CommonText commonText = new CommonText();

            commonTextlst = commonText.GetListByCreateid();
            for (int i = 0; i < commonTextlst.Count; i++)
            {
                Usertext usertext = new Usertext();
                usertext.Anchor = AnchorStyles.Left | AnchorStyles.Right | AnchorStyles.Top;
                usertext.MouseDown += onmousedown;
                usertext. chatText = commonTextlst[i].content;
                usertext.sometext = commonTextlst[i].content;
                if (this.Height <= 260)
                {
                    palcommonTex.Height += 45;
                    this.Height += 45;
                }

                palcommonTex.Controls.Add(usertext);

            }
            this.StartPosition = FormStartPosition.Manual;
            //获取鼠标点击表情时的坐标
            Point ms = Control.MousePosition;
            //设置弹出窗起始坐标
            int location_x = ms.X - e.X - 8;
            int location_y = ms.Y - this.Height - e.Y - 5;
            this.Location = new Point(location_x, location_y);
            this.Show();//显示的位置
                       
        }

       

        private void  onmousedown(object sender, MouseEventArgs e)
        {
            Usertext item = (Usertext)sender;

            if (item == mSelectItem)
            {
                return;
            }
            mSelectItem = item;
           
            Sometimetext?.Invoke(mSelectItem.chatText);
        }
        private void btnadd_Click(object sender, EventArgs e)
        {
            FrmChatsometimes frmChatsometimes = new FrmChatsometimes();
            frmChatsometimes. getdata();
            frmChatsometimes.Show();
        }
    }
}
