using Newtonsoft.Json.Linq;
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
    public partial class FrmChatsometimes : FrmBase
    {
        List<CommonText> commonTextlst = new List<CommonText>();
        UserChatSometime mSelectItem;//当前选中的项目
        private LodingUtils loding;//等待符

        private void ShowLodingDialog(Control control)
        {
            loding = new LodingUtils { };


            loding.parent = control;
            loding.Title = "加载中";
            loding.start();
        }
        public FrmChatsometimes()
        {
            InitializeComponent();
        }
        /// <summary>
        /// 查询常用语
        /// </summary>
        public void getdata()
        {
            //HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "/CustomerService/commonText/getByUserId")
            // .AddParams("access_token", Applicate.Access_Token)
            //   .AddParams("pageIndex", "0")
            //        .AddParams("pageSize", "10")
            // .Build().Execute((susee, datalist) =>
            // {
            //     if (susee)
            //     {
                    
            //             JArray array = JArray.Parse(UIUtils.DecodeString(datalist, "data"));
            //             foreach (var item in array)
            //             {

            //             CommonText commonText = new CommonText();
            //             commonText.content = UIUtils.DecodeString(item, "content");
            //             commonText.contentid =   UIUtils.DecodeString(item, "id");
            //             commonText.createtime = UIUtils.DecodeDouble(item, "createTime");

            //             commonText.createUserId = UIUtils.DecodeString(item, "createUserId");
            //             commonText.modifyUserId = UIUtils.DecodeString(item, "modifyUserId");
            //             commonText.InsertAuto();
            //             UserChatSometime usertext = new UserChatSometime();
            //                 usertext.Tag = UIUtils.DecodeString(item, "id");
            //                 usertext.MouseDown += Usertext_MouseDown;
            //                 usertext.picdeleate.Click += Picdeleate_Click;

            //                 usertext.Sometimetext = commonText.content;
            //                 if (this.Height <= 500)
            //                 {
            //                 this.Height += 60;
            //                 pnlcommmtext.Height += 60;
                                
            //                 }

            //                 pnlcommmtext.Controls.Add(usertext);

            //             }
            //             ///将数据绑定在列表中
            //             // HttpUtils.Instance.ShowTip("添加成功");
            //         }
            //     ///将数据绑定在列表中
            //     // HttpUtils.Instance.ShowTip("添加成功");
                 

            // });
            CommonText commonText = new CommonText();

            commonTextlst= commonText.GetListByCreateid();
            for (int i = 0; i < commonTextlst.Count; i++)
            {
                UserChatSometime usertext = new UserChatSometime();
                usertext.Tag = commonTextlst[i].contentid;
                usertext.MouseDown += Usertext_MouseDown;
                usertext.picdeleate.Click += Picdeleate_Click;
                usertext.Sometimetext = commonTextlst[i].content;
                //usertext.Sometimetext = commonTextlst[i].content;
                if (this.Height <= 500)
                {
                    this.Height += 60;
                    pnlcommmtext.Height += 60;

                }

                pnlcommmtext.Controls.Add(usertext);

            }

        }
        /// <summary>
        /// 添加常用语
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnset_Click(object sender, EventArgs e)
        {
            if (txtsometime.Text == "")
            {
                HttpUtils.Instance.ShowTip("输入为空");
                return;
            }
            ShowLodingDialog(pnlcommmtext);//等待符
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "CustomerService/commonText/add")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("companyId","0")
                  .AddParams("createUserId", Applicate.MyAccount.userId)
                  .AddParams("content", txtsometime.Text)
                .Build().Execute((susee, datalist) =>
                {
                    if (susee)
                    {
                        loding.stop();
                        //JArray array = JArray.Parse(UIUtils.DecodeString(datalist, "datalist"));
                        //foreach (var item in array)
                        //{
                        txtsometime.Text = "";//清空输入框
                        CommonText commonTex = new CommonText();
                        // UIUtils.LimitTextLength(UIUtils.DecodeString(datalist, "content"), 25, true);
                        commonTex.content = UIUtils.DecodeString(datalist, "content");

                        commonTex.contentid = UIUtils.DecodeString(datalist, "id");
                        commonTex.createtime = UIUtils.DecodeDouble(datalist, "createTime");
                        commonTex.createUserId = UIUtils.DecodeString(datalist, "createUserId");
                        commonTex.modifyUserId = UIUtils.DecodeString(datalist, "modifyUserId");
                        commonTex.InsertAuto();

                        UserChatSometime usertext = new UserChatSometime();
                        usertext.Tag = UIUtils.DecodeString(datalist, "id");
                        usertext.MouseDown += Usertext_MouseDown;
                        usertext.picdeleate.Click += Picdeleate_Click;
                        usertext.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;

                        usertext.Sometimetext = commonTex.content;

                        if ( this.Height <= 500)
                            {
                            if(pnlcommmtext.Controls.Count==0)
                            {

                            }
                            else
                            {
                                pnlcommmtext.Height += 60;
                                this.Height +=60;
                            }
                              
                            }

                            pnlcommmtext.Controls.Add(usertext);

                        }
                        ///将数据绑定在列表中
                        HttpUtils.Instance.ShowTip("添加成功");
                    //}
                });
        }
        private int FontWidth(Font font, Control control, string str)
        {
            //此处为什么会报错？？？难道因为执行此方法在后，创建控件在先？？

            Graphics g = control.CreateGraphics();
            SizeF siF = g.MeasureString(str, font); return (int)siF.Width;

        }

        private void Usertext_MouseDown(object sender, MouseEventArgs e)
        {
            UserChatSometime item = (UserChatSometime)sender;

            if (item == mSelectItem)
            {
                return;
            }

            mSelectItem = item;
        }

        /// <summary>
        /// 删除常用语
        /// </summary>
        private void Picdeleate_Click(object sender, EventArgs e)
        {
            OnDeleteLableFriend();
        }

       
        public void OnDeleteLableFriend()
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "CustomerService/commonText/delete")
              .AddParams("access_token", Applicate.Access_Token)
              .AddParams("commonTextId", mSelectItem.Tag.ToString())//常用语文本id
              .Build().Execute((susee, datalist) =>
              {
                  if (susee)
                  {
                    if(!IsVerticalScrollBarVisible(pnlcommmtext))
                      {
                          pnlcommmtext.Height -= 48;
                          this.Height -= 48;
                      }
                      

                      pnlcommmtext.Controls.Remove(mSelectItem);
                      CommonText commonTex = new CommonText();
                      // commonTex.content = UIUtils.DecodeString(datalist, "content");

                      commonTex.contentid = mSelectItem.Tag.ToString();
                 int x =     commonTex.DeleteByUserId();

                      HttpUtils.Instance.ShowTip("删除成功");
                  }
              });
        }
        private const int WS_HSCROLL = 0x100000;
        private const int WS_VSCROLL = 0x200000;
        private const int GWL_STYLE = (-16);

        [System.Runtime.InteropServices.DllImport("user32", CharSet = System.Runtime.InteropServices.CharSet.Auto)]
        private static extern int GetWindowLong(IntPtr hwnd, int nIndex);

        internal static bool IsVerticalScrollBarVisible(Control ctrl)
        {
            if (!ctrl.IsHandleCreated)
                return false;

            return (GetWindowLong(ctrl.Handle, GWL_STYLE) & WS_VSCROLL) != 0;
        }

        private void txtsometime_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (txtsometime.Text.Length <= 0)
            { //空格不能在第一位
                if ((int)e.KeyChar == 32)
                {
                    e.Handled = true;
                }
            }
            if (e.KeyChar == '\r')
            {
                e.Handled = true;
            }
        }
    }
}
