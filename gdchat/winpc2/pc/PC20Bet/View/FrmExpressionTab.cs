using CCWin;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Helper;
using WinFrmTalk.Helper.MVVM;
using WinFrmTalk.Model;

namespace WinFrmTalk.View
{
    public enum ExpressionType
    {
        Emoji = 0,
        Gif = 1,
        Image = 2
    }

    public partial class FrmExpressionTab : FrmSuspension
    {
        //双缓冲
        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.ExStyle |= 0x02000000;
                return cp;
            }
        }

        public Action<ExpressionType, string> expressionAction;
        private static readonly object looker = new object();       //确保线程的同步，同一时间不能同时访问
        private static FrmExpressionTab frmExpressionTab;
        private Friend friend { get; set; }
        public void SetFriendTarget(Friend friend)
        {
            this.friend = friend;
        }

        private FrmExpressionTab()
        {
            InitializeComponent();
            //失去焦点不关闭，只隐藏
            this.IsClose = false;   
            this.IsVisible = true;
            this.Radius = 0;
        }

        /// <summary>
        /// 定义公有方法提供一个全局访问点,同时也可以定义公有属性来提供全局访问点
        /// </summary>
        /// <returns></returns>
        public static FrmExpressionTab GetExpressionTab()
        {
            // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
            // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
            // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
            // 双重锁定只需要一句判断就可以了
            if (frmExpressionTab == null)
            {
                lock (looker)
                {
                    // 如果类的实例不存在则创建，否则直接返回
                    if (frmExpressionTab == null)
                    {
                        frmExpressionTab = new FrmExpressionTab();
                    }
                }
            }
            return frmExpressionTab;
        }

        private void FrmExpressionTab_Load(object sender, EventArgs e)
        {
            tabExpression.SelectedIndex = 0;
            AddEmojiToTab();
        }

        #region 添加emoji表情
        private void AddEmojiToTab()
        {
            //EQControlManager.ClearTabel(flpEmoji);
            if (flpEmoji.Controls.Count > 0)
                return;

            //获取所有emoji表情路径
            string[] emojiPaths = Directory.GetFiles(Applicate.LocalConfigData.EmojiFolderPath, "*.png");
            //循环添加emoji表情
            foreach (string emojiPath in emojiPaths)
            {
                Bitmap emoji = new Bitmap(emojiPath);
                PictureBox picEmoji = new PictureBox();
                string name = emojiPath.Substring(emojiPath.LastIndexOf("\\") + 1);
                picEmoji.Name = name;
                picEmoji.Size = new Size(30, 30);
                picEmoji.BackgroundImage = emoji;
                picEmoji.BackgroundImageLayout = ImageLayout.Stretch;
                picEmoji.MouseDown += picEmoji_MouseDown;
                flpEmoji.Controls.Add(picEmoji);
            }
        }

        private void picEmoji_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                //向主界面的文本框发送emoji表情code
                string emoji_code = ((Control)sender).Name.Remove(((Control)sender).Name.LastIndexOf("."));
                //Messenger.Default.Send("[" + emoji_code + "]", token: EQFrmInteraction.AddEmojiToTxtSend);   //添加emoji表情通知
                expressionAction(ExpressionType.Emoji, "[" + emoji_code + "]");     //回调
                //this.Dispose();
            }
        }
        #endregion

        #region 添加Gif表情
        private void AddGifToTab()
        {
            //EQControlManager.ClearTabel(flpGifTab);
            if (flpGifTab.Controls.Count > 0)
                return;

            //获取所有gif表情路径
            string[] gifPaths = Directory.GetFiles(Applicate.LocalConfigData.GifFolderPath, "*.gif");
            //循环添加gif表情
            foreach (string gifPath in gifPaths)
            {
                Bitmap gif = new Bitmap(gifPath);
                PictureBox picgif = new PictureBox();
                string name = gifPath.Substring(gifPath.LastIndexOf("\\") + 1);
                picgif.Name = name;
                picgif.Size = new Size(63, 63);
                picgif.BackgroundImage = gif;
                picgif.BackgroundImageLayout = ImageLayout.Stretch;
                picgif.MouseDown += picGif_MouseDown;
                flpGifTab.Controls.Add(picgif);
            }
        }

        private void picGif_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                MessageObject msg = ShiKuManager.SendGifMessage(friend, ((Control)sender).Name, false);
                Messenger.Default.Send(msg, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);   //添加消息气泡通知
                ShiKuManager.mSocketCore.SendMessage(msg);
                //关闭表情窗体
                this.Hide();
            }
        }
        #endregion

        #region 添加自定义表情
        PictureBox select_picCustomize = null;
        private void AddCustomizeToTab()
        {
            EQControlManager.ClearTabel(flpCustomize);

            //从接口添加表情
            SetCustomizeList(0, 100);
        }

        private void picCustomize_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                string url = ((PictureBox)sender).Tag.ToString();

                ImageLoader.Instance.Load(url).Into((bit, path) =>
                {
                    int fileSize = Convert.ToInt32(new FileInfo(path).Length / 1024);
                    MessageObject msg = ShiKuManager.SendImageMessage(friend, url, path, fileSize, false);
                    Messenger.Default.Send(msg, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);   //添加消息气泡通知
                    ShiKuManager.mSocketCore.SendMessage(msg);
                    this.Hide();
                });
            }
            //右键被选中的控件
            if (e.Button == MouseButtons.Right && sender is PictureBox picCustomize)
                select_picCustomize = picCustomize;
        }

        private void SetCustomizeList(int pageIndex, int pagesize)
        {
            string userid = Applicate.MyAccount.userId;
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/emoji/list")
            .AddParams("access_token", Applicate.Access_Token)
            .AddParams("userId", userid)
            .AddParams("pageIndex", pageIndex.ToString())
            .AddParams("pageSize", pagesize.ToString())
            .Build().AddErrorListener((code, err) =>
            {

            })
            .Execute((sccess, reslut) =>
            {
                if (sccess)
                {
                    //将room解析
                    var customizes = JsonConvert.DeserializeObject<List<object>>(reslut["data"].ToString());

                    foreach (var item in customizes)
                    {
                        var customize = JsonConvert.DeserializeObject<Dictionary<string, object>>(item.ToString());
                        string url = customize["url"].ToString();
                        string emojiId = customize["emojiId"].ToString();
                        PictureBox picCustomize = new PictureBox();
                        picCustomize.Name = "cut_" + emojiId;
                        picCustomize.BackgroundImageLayout = ImageLayout.Stretch;
                        picCustomize.SizeMode = PictureBoxSizeMode.StretchImage;
                        picCustomize.Size = new Size(63, 63);
                        picCustomize.Tag = url;
                        picCustomize.MouseDown += picCustomize_MouseDown;
                        picCustomize.ContextMenuStrip = cmsCustomizeMenu;
                        ImageLoader.Instance.DisplayImage(url, picCustomize);
                        flpCustomize.Controls.Add(picCustomize);
                    }

                }
            });
        }
        #endregion

        private void tabExpression_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (tabExpression.SelectedIndex == 1)
                AddGifToTab();
            //if (tabExpression.SelectedIndex == 2)
            //    AddCustomizeToTab();
        }

        private void menuItem_deleted_Click(object sender, EventArgs e)
        {
            if (select_picCustomize == null)
                return;
            string emojiId = select_picCustomize.Name.Replace("cut_", "");
            ExpressionUlUtils.RemoveExpression(emojiId);
            flpCustomize.Controls.Remove(select_picCustomize);
            select_picCustomize = null;
        }
    }
}
