using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading;
using WinFrmTalk.Model;
using Newtonsoft.Json;

namespace WinFrmTalk.Controls
{
    public partial class Roomannounce : UserControl
    {

        private const int SPEED = 1;

        public Roomannounce()
        {
            InitializeComponent();

            this.Visible = true;
        }
        /// <summary>
        /// room
        /// </summary>
        public Friend RoomData { get; set; }

        public void LoadData(string notice)
        {
            Dictionary<string, object> result = JsonConvert.DeserializeObject<Dictionary<string, object>>(notice);
            FillListData(result);
            RegistNotiy();

        }

        /// <summary>
        /// 注册监听
        /// </summary>
        private void RegistNotiy()
        {

            Messenger.Default.Register<string>(this, MessageActions.Room_Deleate_ROOM_TIPS, item => RoomdeleateTips(item));
        }
        /// <summary>
        /// 监听到当前滚动的公告被删除掉了，公告栏就自动隐藏
        /// </summary>
        /// <param name="item"></param>
        private void RoomdeleateTips(string item)
        {
            if (item == lblText.Tag.ToString())
            {
                CloseNotice();
            }
            //正在滚动的noticeid等于删除掉的noticeid就将当前隐藏掉

        }

        /// <summary>
        /// 监听到有新公告
        /// </summary>
        /// <param name="msg"></param>
        public void MainNotiy(MessageObject msg)
        {

            switch (msg.type)
            {
                case kWCMessageType.RoomNotice://新公告
                case kWCMessageType.RoomNoticeEdit:
                    if (string.Equals(msg.ChatJid, RoomData.UserId))
                    {
                        this.Visible = true;
                        lblText.Text = "";
                        lbladdtext.Text = "";
                        timer1.Stop();
                        lblText.Text = msg.content.Replace("\r", " ").Replace("\n", " ");

                        txtwind();
                         
                        this.BringToFront();
                        this.Invalidate();
                    }
                    break;
            }
        }
        public void Getmonitor(MessageObject msg)
        {
            if (this.IsHandleCreated)
            {
                Invoke(new Action(() =>
                {
                    MainNotiy(msg);
                }));
            }
        }

        /// <summary>
        /// 鼠标手势
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void lblClose_MouseHover(object sender, EventArgs e)
        {
            Label lbl = (Label)sender;
            lbl.Cursor = Cursors.Hand;//手形光标
        }

        /// <summary>
        /// 从接口获取数据
        /// </summary>

        public void getdata()
        {

            if (UIUtils.IsNull(RoomData.RoomId))
            {
                return;
            }

            LogUtils.Log("getdata");
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/get") //获取群公告
           .AddParams("access_token", Applicate.Access_Token)
           .AddParams("roomId", RoomData.RoomId)
           .Build().Execute((sccess, room) =>
           {
               if (sccess)
               {
                   string norice = room["notice"].ToString();
                   var notic = JsonConvert.DeserializeObject<Dictionary<string, object>>(norice.ToString());
                   FillListData(notic);
               }
           });
        }
        /// <summary>
        /// 数据显示在界面
        /// </summary>
        /// <param name="room"></param>
        private void FillListData(Dictionary<string, object> notic)
        {
            timer1.Stop();
            lblText.Text = "";
            lbladdtext.Text = "";
            lblText.Text = UIUtils.DecodeString(notic, "text").Replace("\r", " ").Replace("\n", " ");
            lblText.Tag = UIUtils.DecodeString(notic, "id");
            lbladdtext.Tag = UIUtils.DecodeString(notic, "id");
            txtwind();
        }
        /// <summary>
        /// 将文本中的回车删除掉
        /// </summary>
        /// <param name="text"></param>
        /// <returns></returns>
        private string RemoveEnter(string text)
        {
            return text;
        }


        public void txtwind()
        {

            int txtwid = FontWidth(lblText.Font, lblText, lblText.Text);
            lblText.Width = txtwid + 60;
            lbladdtext.Width = txtwid + 60;
            if (txtwid <= panel1.Width)
            {
                timer1.Stop();
                Point p = new Point(3, 5);
                lblText.Location = p;

            }
            else
            {
                timer1.Enabled = true;
                timer1.Start();
                Point p = new Point();
                p.X = lblText.Size.Width + lblText.Location.X + 60;
                p.Y = lblText.Location.Y;
                lbladdtext.Location = p;

            }
        }
        /// <summary>
        /// 定时器
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void timer1_Tick(object sender, EventArgs e)
        {
            lbladdtext.Text = lblText.Text.Replace("\r", " ").Replace("\n", " ");
            int txtwid = FontWidth(lblText.Font, lblText, lblText.Text);



            Point p1 = lblText.Location;
            Point p2 = lbladdtext.Location;

            p1.X -= SPEED;
            p2.X -= SPEED;

            if (p1.X <= (-lblText.Width))
            {
                p1.X = p2.X + lblText.Width + 60;
            }

            if (p2.X <= (-lbladdtext.Width))
            {
                p2.X = p1.X + lblText.Width + 60;
            }

            lbladdtext.Location = p2;
            lblText.Location = p1;




        }
        /// <summary>
        /// 获取控件输入文字的长度
        /// </summary>
        /// <param name="font"></param>
        /// <param name="control"></param>
        /// <param name="str"></param>
        /// <returns></returns>
        private int FontWidth(Font font, Control control, string str)
        {
            using (Graphics g = control.CreateGraphics())
            {
                SizeF siF = g.MeasureString(str, font); return (int)siF.Width;
            }
        }

        private void lblClose_Click(object sender, EventArgs e)
        {
            CloseNotice();
        }



        public void CloseNotice()
        {
            Messenger.Default.Unregister(this);
            if (this.IsHandleCreated)
            {
                Invoke(new Action(() =>
                {
                    this.SendToBack();
                    //设置不弹出公告
                    if (RoomData != null && !string.IsNullOrEmpty(RoomData.UserId))
                        LocalDataUtils.SetBoolData(RoomData.UserId + "show_notice", false);
                    timer1.Stop();
                }));
            }
        }

        private void Roomannounce_Load(object sender, EventArgs e)
        {

        }
    }
}
