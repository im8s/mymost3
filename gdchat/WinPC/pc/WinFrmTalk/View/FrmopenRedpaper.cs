using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.View
{
    public partial class FrmopenRedpaper : FrmSuspension
    {
        public string messageid;
        public List<Receivers> acceoptlst
        {
            get; set;
        }
        public Redpackges reapackgeinfo
        {
            get; set;
        }
        /// <summary>
        /// 赋值
        /// </summary>
        /// <param name="fromname"></param>
        /// <param name="content"></param>
        /// <param name="money"></param>
        internal void getdata(string fromname, string content, string money, string userid, string id)
        {
            messageid = id;
            this.lab_froamname.Text = fromname;
            this.lab_text.Text = content;
            this.lab_money.Text = money;
            ImageLoader.Instance.DisplayAvatar(userid, pic_head);
        }
        public FrmopenRedpaper()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标

        }
        public void GetRedPacket(string id)
        {

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "redPacket/getRedPacket")
            .AddParams("access_token", Applicate.Access_Token)
            .AddParams("id", id)
            .Build().Execute((sccess, data) =>
            {
                if (sccess)
                {
                    string code = UIUtils.DecodeString(data, "resultCode");

                    if (UIUtils.IsNull(code))
                    {

                    }
                    else
                    {
                        // 已领完
                        string resultdata = UIUtils.DecodeString(data, "data");
                        var list = JsonConvert.DeserializeObject<Dictionary<string, object>>(resultdata);

                        string packet = UIUtils.DecodeString(list, "packet");
                        Redpackges reapackges = JsonConvert.DeserializeObject<Redpackges>(packet);
                        reapackgeinfo = reapackges;
                        this.IsClose = true;
                        this.Close();
                        Frmreceivemony frmreceivemony = new Frmreceivemony();
                        frmreceivemony.receivelst = acceoptlst;
                        frmreceivemony.reapackgeinfo = reapackgeinfo;
                        frmreceivemony.BringToFront();
                        frmreceivemony.Show();
                        frmreceivemony.BindTodata();

                        ImageLoader.Instance.DisplayAvatar(reapackgeinfo.userId, frmreceivemony.pic_head);

                    }

                }
                else
                {

                }
            });
        }
        /// <summary>
        /// 查看领取详情
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void lab_seeinfo_Click(object sender, EventArgs e)
        {
            GetRedPacket(messageid);

        }

        private void FrmopenRedpaper_Load(object sender, EventArgs e)
        {

        }

        private void FrmExpressionTab_Resize(object sender, EventArgs e)
        {
            if (this.WindowState == FormWindowState.Normal && Radius != 0)
            {
                SetWindowRegion();
            }
            else
            {
                this.Region = null;
            }
        }

        /// <summary>        
        ///         
        /// </summary>        
        /// <param name="rect">窗体大小</param>       
        /// <param name="radius">圆角大小</param>        
        /// <returns></returns>        
        private GraphicsPath GetRoundedRectPath(Rectangle rect, int radius)
        {
            int diameter = radius;
            Rectangle arcRect = new Rectangle(rect.Location, new Size(diameter, diameter));
            GraphicsPath path = new GraphicsPath();
            path.AddArc(arcRect, 180, 90);
            //左上角                      
            arcRect.X = rect.Right - diameter;
            //右上角            
            path.AddArc(arcRect, 270, 90);
            arcRect.Y = rect.Bottom - diameter;
            // 右下角            
            path.AddArc(arcRect, 0, 90);
            arcRect.X = rect.Left;
            // 左下角         
            path.AddArc(arcRect, 90, 90);
            path.CloseFigure();
            return path;
        }
    }
}
