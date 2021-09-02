using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using RichTextBoxLinks;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;
using WinFrmTalk.View;

using WinFrmTalk.View.list;
using Timer = System.Windows.Forms.Timer;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class UserCollection : UserControl
    {
        #region 全局变量
        List<Collections> collectionlst = new List<Collections>();//全部集合
        CollectionAdapter mAdapter;//收藏适配
        MyColleagueAdapter myColleagueAdapter;//我的讲课适配
        public List<MessageObject> ListMessage = new List<MessageObject>();//选中讲课消息集合
        public UserLabelItem control;//选中我的讲课
        private UserCollectionItem CollectionItem;//选中我的收藏
        private static int emoji_count = 0;//emoji表情数量
        private bool isLoadCourseData; // 是否加载过数据了
        public const int minHeight = 50;//最小高度
        public static int BubbleWidth, BubbleHeight;//气泡宽度，气泡高度
        private Timer timer;
        private bool isLock;
        public bool fristSearch = true;
        #endregion
        public UserCollection()
        {
            InitializeComponent();
            mAdapter = new CollectionAdapter();//适配绑定（收藏）
            myColleagueAdapter = new MyColleagueAdapter();//适配绑定（我的讲课）
            myColleagueAdapter.SetMaengForm(this);
            // 更新收藏页
            Messenger.Default.Register<string>(this, MessageActions.UPDATE_COLLECT_LIST, (str) =>
            {
                //isLoadData = false;
            });

            // 更新我的讲课
            Messenger.Default.Register<string>(this, MessageActions.UPDATE_COURSE_LIST, (str) =>
            {
                isLoadCourseData = false;
                if ("我的讲课".Equals(lblTitle.Text))
                {
                    btnLecture_Click(this.btnLecture, null);
                }
            });
            timer = new Timer() { Interval = 500 };
            timer.Interval = 500;
            timer.Tick += SearchText;
        }

        public LodingUtils loding;//等待符

        /// <summary>
        /// 显示等待符
        /// </summary>
        /// <param name="control">等待符显示的父控件</param>
        public void ShowLodingDialog(Control control)
        {
            loding = new LodingUtils();
            loding.parent = control;
            loding.Title = "加载中";
            loding.start();
        }

        /// <summary>
        /// 停止等待符
        /// </summary>
        public void HideLodingDialog()
        {
            if (loding != null)
            {
                loding.stop();
            }
        }

        #region 加载全部数据
        /// <summary>
        /// 全部收藏数据
        /// </summary>
        public void WholeData()
        {
            ShowLodingDialog(myTabLayoutPanel1);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/collection/list")
               .AddParams("access_token", Applicate.Access_Token)
               .AddParams("userId", Applicate.MyAccount.userId)
               .Build().AddErrorListener((code, ss) =>
               {

               }).Execute((suss, data) =>
               {
                   if (suss)
                   {
                       lblTitle.Text = "全部收藏";

                       List<MessageObject> message = new List<MessageObject>();
                       JArray arr = JArray.Parse(UIUtils.DecodeString(data, "data"));
                       if (arr.Count <= 0)
                       {
                           HttpUtils.Instance.ShowTip("暂无收藏");
                       }
                       collectionlst = new List<Collections>();
                       foreach (var itemarr in arr)
                       {
                           Collections collections = new Collections();

                           collections.createTime = long.Parse(UIUtils.DecodeString(itemarr, "createTime"));
                           collections.emojiId = UIUtils.DecodeString(itemarr, "emojiId");
                           collections.type = UIUtils.DecodeString(itemarr, "type");
                           collections.msgId = UIUtils.DecodeString(itemarr, "msgId");
                           collections.collectType = UIUtils.DecodeInt(itemarr, "collectType");
                           if (!"5".Equals(collections.type))
                           {
                               collections.url = UIUtils.DecodeString(itemarr, "url");
                               collections.Filename = UIUtils.DecodeString(itemarr, "fileName");
                           }
                           else
                           {
                               collections.collectContent = UIUtils.DecodeString(itemarr, "collectContent");
                           }
                           collections.userId = UIUtils.DecodeString(itemarr, "userId");
                           collections.msg = UIUtils.DecodeString(itemarr, "msg");
                           collections.fileSize = UIUtils.DecodeString(itemarr, "fileSize");
                           collections.fileLength = UIUtils.DecodeString(itemarr, "fileLength");
                           collectionlst.Add(collections);
                       }
                       mAdapter.SetMaengForm(this);
                       mAdapter.BindDatas(collectionlst);
                       myTabLayoutPanel1.SetAdapter(mAdapter);
                       loding.stop();
                   }
               });
        }
        #endregion

        public static void Calc_PanelWidth(Control control)
        {
            if (!(control is RichTextBoxEx richContent))
                return;

            //临时建立一个容器装入内容
            RichTextBoxEx canv_Rich = control as RichTextBoxEx;
            //先取全部Text的值
            canv_Rich.Text = richContent.Text;
            //把code转为emoji
            canv_Rich.Rtf = GetLink(canv_Rich.Text);
            canv_Rich.Font = new Font(Applicate.SetFont, 10);//用来设置字体的，一定不能少，不然会变成默认的宋体了
            canv_Rich.BackColor = Color.WhiteSmoke;

            richContent.Rtf = canv_Rich.Rtf;
        }

        public static string GetLink(string msgText)
        {
            RichTextBoxEx richTextBox = new RichTextBoxEx();
            richTextBox.Text = msgText;
            richTextBox.BackColor = Color.WhiteSmoke;
            MatchCollection msg = Regex.Matches(msgText, @"^http://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            foreach (Match match in msg)
            {
                int str_index = richTextBox.Text.IndexOf(match.Value);
                richTextBox.SelectionStart = str_index;
                richTextBox.SelectionLength = match.Value.Length;
                richTextBox.SelectedText = "";
                richTextBox.InsertLink(match.Value);
            }

            //正则表达式

            //emajio表情
            msg = Regex.Matches(richTextBox.Text, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            emoji_count = msg.Count;
            int index = 0;
            string[] newStr = new string[msg.Count];
            foreach (Match item in msg)
            {
                newStr[index] = item.Groups[0].Value;
                index++;
            }
            //循环替换code为表情图片
            for (int i = 0; i < newStr.Length; i++)
            {

                //bool isMin = friends.userId == Applicate.MyAccount.userId;
                richTextBox.Rtf = richTextBox.Rtf.Replace(newStr[i], EnjoyCodeColor.GetEmojiRtfByCode(newStr[i], Color.WhiteSmoke));
            }
            string result = richTextBox.Rtf;
            richTextBox.Dispose();
            return result;
        }

        /// <summary>
        /// 我的收藏右键菜单
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void Item_MouseDown(object sender, MouseEventArgs e)
        {
            EQShowInfoPanelAlpha eQShowInfo = new EQShowInfoPanelAlpha();

            if (e.Button == MouseButtons.Right)
            {
                if (CollectionItem != null)
                {
                    CollectionItem.IsSelected = false;
                    CollectionItem.BagColor = Color.WhiteSmoke;
                    CollectionItem.ContextMenuStrip = null;
                }

                if (sender.GetType() != typeof(UserCollectionItem))
                {

                    this.CollectionItem = (UserCollectionItem)((((Control)sender).Parent).Parent);

                }

                if (sender is UserCollectionItem)
                {
                    this.CollectionItem = (UserCollectionItem)sender;
                }
                //for (int index =0; index > CollectionItem.Controls.Count; index++)
                //{
                //    Control pan_crl = CollectionItem.Controls[index];
                //    if (pan_crl is EQShowInfoPanelAlpha e_panelAlpha)
                //        eQShowInfo = e_panelAlpha;
                //}


                CollectionItem.IsSelected = true;
                CollectionItem.ContextMenuStrip = cmsCollection;
            }

            if (e.Button == MouseButtons.Left)
            {
                if (CollectionItem != null)
                {
                    CollectionItem.IsSelected = false;
                    CollectionItem.BagColor = Color.WhiteSmoke;
                    CollectionItem.ContextMenuStrip = null;
                }
            }
        }
        #region 收藏类型
        /// <summary>
        /// 全部
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnWhole_Click(object sender, EventArgs e)
        {
            myTabLayoutPanel1.ClearList();
            lblTitle.Text = "";
            lblTitle.Text = ((Control)sender).Text.Trim();
            mAdapter.SetMaengForm(this);
            mAdapter.BindDatas(collectionlst);
            myTabLayoutPanel1.SetAdapter(mAdapter);
        }
        /// <summary>
        /// 文本
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnText_Click(object sender, EventArgs e)
        {
            ShowLodingDialog(myTabLayoutPanel1);
            myTabLayoutPanel1.ClearList();
            lblTitle.Text = "";
            lblTitle.Text = ((Control)sender).Text.Trim();
            mAdapter.SetMaengForm(this);

            List<Collections> textcollection = new List<Collections>();

            for (int i = 0; i < collectionlst.Count; i++)
            {
                if (collectionlst[i].type == "5")
                {
                    textcollection.Add(collectionlst[i]);
                }
            }
            mAdapter.BindDatas(textcollection);
            myTabLayoutPanel1.SetAdapter(mAdapter);
            loding.stop();
        }
        /// <summary>
        /// 图片
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnImg_Click(object sender, EventArgs e)
        {
            ShowLodingDialog(myTabLayoutPanel1);
            myTabLayoutPanel1.ClearList();
            lblTitle.Text = "";
            lblTitle.Text = ((Control)sender).Text.Trim();
            mAdapter.SetMaengForm(this);
            List<Collections> imagecollection = new List<Collections>();

            for (int i = 0; i < collectionlst.Count; i++)
            {
                if (collectionlst[i].type == "1")
                {
                    imagecollection.Add(collectionlst[i]);
                }
            }
            mAdapter.BindDatas(imagecollection);
            myTabLayoutPanel1.SetAdapter(mAdapter);
            loding.stop();
        }

        /// <summary>
        /// 视频
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnVideo_Click(object sender, EventArgs e)
        {
            ShowLodingDialog(myTabLayoutPanel1);
            myTabLayoutPanel1.ClearList();
            lblTitle.Text = "";
            lblTitle.Text = ((Control)sender).Text.Trim();

            mAdapter.SetMaengForm(this);
            List<Collections> vidiocollection = new List<Collections>();
            for (int i = 0; i < collectionlst.Count; i++)
            {
                if (collectionlst[i].type == "2")
                {
                    vidiocollection.Add(collectionlst[i]);
                }
            }
            mAdapter.BindDatas(vidiocollection);
            myTabLayoutPanel1.SetAdapter(mAdapter);
            loding.stop();
        }
        #endregion

        #region 转发收藏
        private void tsmForward_Click(object sender, EventArgs e)
        {
            FrmFriendSelect frm = new FrmFriendSelect();
            frm.max_number = 1;
            frm.LoadFriendsData(1);
            frm.AddConfrmListener((dis) =>
            {
                HttpUtils.Instance.PopView(frm);
                foreach (var friend in dis)
                {
                    ForwardCollection(friend.Value, CollectionItem);
                }
            });
        }

        private void ForwardCollection(Friend friend, UserCollectionItem collection)
        {
            if (EQControlManager.JudgeIsBannedTalk(friend))
            {
                HttpUtils.Instance.ShowTip("禁言群无法转发消息");
                return;
            }


            MessageObject messageObjects = null;

            switch (CollectionItem.type)
            {
                //图片
                case "1":

                    string[] conString = CollectionItem.Tag.ToString().Split(',');
                    foreach (var msg in conString)
                    {
                        messageObjects = new MessageObject() { content = msg, type = kWCMessageType.Image };
                        ShiKuManager.SendForwardMessage(friend, messageObjects);

                        Messenger.Default.Send(messageObjects, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);

                        HttpUtils.Instance.ShowTip("转发成功");
                    }


                    if (!string.IsNullOrEmpty(CollectionItem.CollectContent))
                    {
                        messageObjects = new MessageObject() { content = CollectionItem.CollectContent, type = kWCMessageType.Image };
                        ShiKuManager.SendForwardMessage(friend, messageObjects);

                        Messenger.Default.Send(messageObjects, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);

                        HttpUtils.Instance.ShowTip("转发成功");
                    }

                    return;
                //视频
                case "2":
                    messageObjects = new MessageObject() { content = CollectionItem.Tag.ToString(), fileName = FileUtils.GetFileName(CollectionItem.Tag.ToString()), type = kWCMessageType.Video };
                    break;
                //文件
                case "3":
                    messageObjects = new MessageObject() { content = CollectionItem.Tag.ToString(), fileName = FileUtils.GetFileName(CollectionItem.Tag.ToString()), type = kWCMessageType.File };
                    break;

                //文本表情
                case "5":
                    messageObjects = new MessageObject() { content = CollectionItem.Tag.ToString(), type = kWCMessageType.Text };
                    break;

                case "4":    //表情
                case "6":       //语音
                case "7":         //SDK分享链接
                    break;
            }


            if (messageObjects != null)
            {
                ShiKuManager.SendForwardMessage(friend, messageObjects);

                Messenger.Default.Send(messageObjects, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);

                HttpUtils.Instance.ShowTip("转发成功");
            }

        }

        #endregion

        #region 删除收藏
        private void tsmDel_Click(object sender, EventArgs e)
        {

            bool result = HttpUtils.Instance.ShowPromptBox("确认删除");
            if (result && CollectionItem != null)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/emoji/delete")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("emojiId", CollectionItem.Name)
                    .Build().Execute((su, da) =>
                    {
                        if (su)
                        {
                            int index = mAdapter.GetMessageIdByIndex(CollectionItem.Name);
                            if (index > -1)
                            {
                                myTabLayoutPanel1.RemoveItem(index);
                                mAdapter.RemoveData(index);
                                HttpUtils.Instance.ShowTip("删除成功");
                            }


                            if (!"全部收藏".Equals(lblTitle.Text))
                            {
                                for (int i = collectionlst.Count - 1; i > -1; i--)
                                {
                                    if (collectionlst[i].emojiId == CollectionItem.Name)
                                    {
                                        collectionlst.RemoveAt(i);
                                        break;
                                    }
                                }
                            }
                        }
                    });
            }
        }

        #endregion

        #region 点击我的讲课
        private void btnLecture_Click(object sender, EventArgs e)
        {

            lblTitle.Text = ((Control)sender).Text.Trim();
            // 加载过数据就不在去加载了
            if (isLoadCourseData)
            {
                myTabLayoutPanel1.SetAdapter(myColleagueAdapter);
                return;
            }

            ShowLodingDialog(myTabLayoutPanel1);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/course/list")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("userId", Applicate.MyAccount.userId)
                .Build().ExecuteList<ColleaguesList>((suss, data) =>
                {
                    HideLodingDialog();
                    if (suss)
                    {
                        isLoadCourseData = true;
                        myColleagueAdapter.BindDatas(data.data);
                        myTabLayoutPanel1.SetAdapter(myColleagueAdapter);
                    }
                });
        }

        #endregion

        #region 修改我的讲课名称

        private void tsmEdit_Click(object sender, EventArgs e)
        {
            FrmMyColleagueEidt frm = new FrmMyColleagueEidt();
            frm.NameEdit = control.lblName.Text.Remove(0, 5);
            frm.ColleagueName((name) =>
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/course/update")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("courseId", control.Name)
                    .AddParams("courseName", name)
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            frm.Close();
                            HttpUtils.Instance.ShowTip("修改成功");
                            control.lblName.Text = "课件名称：" + UIUtils.LimitTextLength(name, 12,
                    true);
                        }
                    });

            });
            frm.ShowThis("修改课件", "课件名称");
        }

        #endregion

        #region 发送讲课
        private void tsmSendLecture_Click(object sender, EventArgs e)
        {
            FrmFriendSelect frm = new FrmFriendSelect();
            frm.max_number = 1;
            frm.LoadFriendsData(1);
            frm.AddConfrmListener((data) =>
            {
                if (data == null || data.Count == 0)
                {
                    HttpUtils.Instance.ShowTip("数据错误");
                    return;
                }

                Friend friend = null;
                foreach (var item in data.Values)
                {
                    friend = item;
                }

                if (friend == null || UIUtils.IsNull(ListMessage))
                {
                    HttpUtils.Instance.ShowTip("数据错误");
                    return;
                }
                else
                {
                    if (friend.IsGroup == 1)
                    {
                        RoomMember roomMember = new RoomMember { roomId = friend.RoomId, userId = Applicate.MyAccount.userId };

                        roomMember = roomMember.GetRommMember();
                        if (roomMember.role == 4)
                        {
                            HttpUtils.Instance.ShowTip("隐身人不能发送课件");
                            return;
                        }
                        if (roomMember.role == 3)
                        {
                            if (friend.AllowSpeakCourse != 1)
                            {
                                HttpUtils.Instance.ShowTip("已开启普通成员不能发送课件");
                                return;
                            }

                            //是否全体禁言
                            string all = LocalDataUtils.GetStringData(friend.UserId + "BANNED_TALK_ALL" + Applicate.MyAccount.userId, "0");
                            //管理员和群主除外
                            if (!"0".Equals(all))
                            {
                                // 全体禁言
                                HttpUtils.Instance.ShowTip("不能发送讲课到全体禁言群");
                                return;
                            }

                            string single = LocalDataUtils.GetStringData(friend.UserId + "BANNED_TALK" + Applicate.MyAccount.userId, "0");
                            //是否单个禁言
                            if (!"0".Equals(single))
                            {
                                HttpUtils.Instance.ShowTip("您已被禁止在此群发言");
                                return;
                            }
                        }

                    }
                }

                Task.Factory.StartNew(() =>
                {
                    SendCourseMessage(friend, ListMessage, 0);
                });
            });
        }

        private void SendCourseMessage(Friend friend, List<MessageObject> listMessage, int index)
        {
            Thread.Sleep(500);

            MessageObject mess = ShiKuManager.SendForwardMessage(friend, ListMessage[index]);
            Messenger.Default.Send(mess, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);

            if ((++index) < listMessage.Count)
            {
                SendCourseMessage(friend, listMessage, index);
            }
            else
            {
                HttpUtils.Instance.ShowTip("课件发送成功");
            }
        }

        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            if (!isLock)
            {

                isLock = true;
                timer.Stop();
                timer.Start();

            }
        }
        private void SearchText(object sender, EventArgs e)
        {
            SearchMeesageContent(txtSearch.Text);
        }
        private void SearchMeesageContent(string inputStr)
        {
            timer.Stop();

            if (!string.IsNullOrEmpty(inputStr))
            {
                this.myTabLayoutPanel1.SuspendLayout();
                this.SuspendLayout();


                if (loding != null)
                {
                    loding.stop();
                }

                loding = new LodingUtils { parent = this.myTabLayoutPanel1, Title = "加载中" };
                loding.start();

                if (!isLock)
                {
                    return;
                }
                timer.Stop();
                isLock = false;
                loding.stop();


                if (string.IsNullOrEmpty(inputStr))
                {
                    // 还原数据
                    RevertData();
                }
                else
                {
                    List<Collections> search = SearchNickName(inputStr);
                    fristSearch = false;
                    if (UIUtils.IsNull(search))
                    {
                        mAdapter.BindDatas(new List<Collections>());
                        myTabLayoutPanel1.SetAdapter(mAdapter);

                        return;
                    }



                    mAdapter.BindDatas(search);
                    myTabLayoutPanel1.SetAdapter(mAdapter);
                }

            }
            else
            {
                // tvwColleague.Visible = true;
                // leftList.Visible = false;
                isLock = false;
                //LoadFriendsData(is,true,true,true,true);
                //txtSearch.Focus();
                myTabLayoutPanel1.ClearList();
                mAdapter.BindDatas(collectionlst);
                myTabLayoutPanel1.SetAdapter(mAdapter);
            }


        }
        /// <summary>
        /// 还原数据
        /// </summary>
        private void RevertData()
        {
            myTabLayoutPanel1.ClearList();
            mAdapter.BindDatas(collectionlst);
            myTabLayoutPanel1.SetAdapter(mAdapter);
            //fristSearch = true;

            //List<Friend> select = mRightAdapter.GetFriendDatas();



            //foreach (var item in select)
            //{
            //    foreach (var friend in collectionlst)
            //    {
            //        if (item.UserId.Equals(friend.UserId))
            //        {
            //            friend.IsDevice = 1;
            //            break;
            //        }
            //    }
            //}
        }
        private List<Collections> SearchNickName(string text)
        {
            List<Collections> data = new List<Collections>();
            foreach (var item in collectionlst)
            {
                if (item.type == "3" && item.Filename != null)
                {
                    if (UIUtils.Contains(item.Filename, text))
                    {
                        data.Add(item);
                    }
                }
                else
                {
                    if (UIUtils.Contains(item.msg, text))
                    {
                        data.Add(item);
                    }
                }
                    
            }

            return data;
        }
        #endregion

        #region 右键删除我的讲课

        private void tsmDelete_Click(object sender, EventArgs e)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/course/delete")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("courseId", control.Name)
                .Build().Execute((suss, data) =>
                {
                    if (suss)
                    {
                        HttpUtils.Instance.ShowTip("删除成功");

                        int index = myColleagueAdapter.GetIndexByName(control.Name);
                        if (index > -1)
                        {
                            myTabLayoutPanel1.RemoveItem(index);
                            myColleagueAdapter.RemoveData(index);
                        }
                    }
                });
        }

        #endregion
    }
}
