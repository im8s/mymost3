using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.View.list;
using WinFrmTalk.Dictionarys;
using System.IO;
using WinFrmTalk.Helper;
using System.Threading.Tasks;
using System.Threading;
using System.Drawing.Imaging;
using System.Text.RegularExpressions;
using System.Drawing.Drawing2D;
using WinFrmTalk.Helper.MVVM;
using Newtonsoft.Json.Linq;
using WinFrmTalk.View;
using RichTextBoxLinks;
using System.Collections.Specialized;
using WinFrmTalk.socket;
using Microsoft.Office.Core;
using System.Diagnostics;
using Newtonsoft.Json;
namespace WinFrmTalk.Controls.CustomControls
{
    public partial class ShowMsgPanel : UserControl, IShowMsgPanel
    {
        #region 非启用状态不改变背景色
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int wndproc);
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

        public const int GWL_STYLE = -16;
        public const int WS_DISABLED = 0x8000000;

        public static void SetControlEnabled(Control c, bool enabled)
        {
            if (enabled)
            { SetWindowLong(c.Handle, GWL_STYLE, (~WS_DISABLED) & GetWindowLong(c.Handle, GWL_STYLE)); }
            else
            { SetWindowLong(c.Handle, GWL_STYLE, WS_DISABLED | GetWindowLong(c.Handle, GWL_STYLE)); }
        }
        #endregion

        #region private member
        private List<string> fileCollect = new List<string>();  //拖拽的文件
        public MsgTabAdapter msgTabAdapter = new MsgTabAdapter();        //适配器
        Control crl_content = null;         //选中的聊天框内容控件
        Control selectControl = null;       //contextMenuStrip的右键选中对象
        int rowIndex = 0;                   //被点击的行的绑定的集合的索引号
        private double lastMsgTime = 0;     //最后一条消息的时间戳
        private int emoji_num = 0;          //当前文本框有多少个emoji表情
        private List<string> emoji_codes = new List<string>();   //记录文本框中的emojiCode
        private int readNum = 0;            //未读数量计数
        private string readMsgId = "";      //未读信息的第一条id
        private bool isDownloadRoaming = false;     //是否正在拉取漫游，避免选择聊天对象还未拉取到最新消息就已经生成气泡
        private bool isOpenOnlineStatus = false;    //是否显示在线状态
        private DownMsgRecord msgRecord;    //漫游接口的对象
        private int page_index = 1;         //当前的翻页页数
        private bool isFirstLoad = false;   //是否切换聊天对象后，第一次加载聊天记录
        private Dictionary<string, string> SrcImages { get; set; }
        /// <summary>
        /// 失去焦点时添加的msg集合
        /// </summary>
        public List<MessageObject> DeactivateMsgList = new List<MessageObject>();
        //List<string> _ImageList = new List<string>();//图片集合（用于文件拖拽时添加以及删除时）
        //List<string> _ImageList2 = new List<string>();//删除图片暂存时用
        private static Microsoft.Office.Interop.PowerPoint.Presentation PpointFile;
        //private static Microsoft.Office.Interop.PowerPoint.ApplicationClass myWordApp = new Microsoft.Office.Interop.PowerPoint.ApplicationClass();

        // 红包
        private string RedCommand;
        private string RedId;
        private string Redopen;
        public List<List<string>> CommandLst = new List<List<string>>();
        Stopwatch stopwatch = new Stopwatch();
        /// <summary>
        /// 最后一条查看的信息，用于新消息未读数量功能
        /// </summary>
        private string LastReadMsgId { get; set; }
        /// <summary>
        /// 未读消息数量，用于新消息未读数量功能
        /// </summary>
        private int UnReadMsgNum { get; set; }
        #endregion

        #region public member
        public int isHaveReadDel = 0;      //本次聊天列表是否含有阅后即焚消息
        public int IsRoomUserRecommend => ChooseTarget.AllowSendCard;     //是否允许群成员私聊
        //选择的联系人
        public Friend ChooseTarget
        {
            get => msgTabAdapter.choose_target;
            set => msgTabAdapter.choose_target = value;
        }
        public int isSeparateChat = 0;      //记录是否为独立聊天窗体
        #endregion

        #region 草稿回显
        private void DraftShow(Friend friend)
        {
            if (ChooseTarget != null)
            {
                //旧聊天对象储存在数据库的草稿
                string old_draft = LocalDataUtils.GetStringData(Applicate.MyAccount.userId + "_DRAFT_" + ChooseTarget.UserId);
                //旧聊天对象当前的草稿
                string new_draft = txtSend.Rtf;
                //需要保存草稿的对象
                LocalDataUtils.SetStringData(Applicate.MyAccount.userId + "_DRAFT_" + ChooseTarget.UserId, txtSend.Rtf);

                //用正则表达式，获取图片rtf
                MatchCollection matchs = Regex.Matches(txtSend.Rtf, @"{\\pict[a-z0-9\\\s]*}", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                foreach (Match match in matchs)
                {
                    txtSend.Rtf = txtSend.Rtf.Replace(match.Value, "[图片]");
                }

                //{
                //MessageObject message = new MessageObject()
                //{
                //    FromId = Applicate.MyAccount.userId,
                //    ToId = ChooseTarget.UserId,
                //    toUserId = ChooseTarget.UserId,
                //    fromUserId = Applicate.MyAccount.userId,
                //    fromUserName = Applicate.MyAccount.nickname,
                //    toUserName = ChooseTarget.NickName,
                //    isGroup = ChooseTarget.IsGroup
                //};

                // 防止草稿反复刷新列表的问题
                if (!old_draft.Equals(new_draft))
                {
                    //最近消息列表的回显
                    if (!string.IsNullOrEmpty(txtSend.Text))
                        ChooseTarget.UpdateLastContent("草稿:" + txtSend.Text, TimeUtils.CurrentTimeDouble());
                    //Messenger.Default.Send(message, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
                    //如果新的聊天对象是空的，代表是删除聊天最近聊天项触发，所以不发通知
                    if (friend != null && !string.IsNullOrEmpty(friend.UserId))
                        Messenger.Default.Send(ChooseTarget, token: MessageActions.UPDATE_FRIEND_LAST_CONTENT);
                }
                //}
                // 刷新最后一条聊天记录
                //else
                //{
                //    if (!old_draft.Equals(new_draft))
                //        Messenger.Default.Send(ChooseTarget, token: MessageActions.UPDATE_FRIEND_LAST_CONTENT);
                //}
            }

            //新的聊天对象
            if (friend != null)
            {
                //获取新聊天对象的草稿
                string draft = LocalDataUtils.GetStringData(Applicate.MyAccount.userId + "_DRAFT_" + friend.UserId);
                if (string.IsNullOrEmpty(draft))
                    txtSend.Text = draft;
                else
                {

                    //emoji回显
                    using (RichTextBox richTextBox = new RichTextBox())
                    {
                        richTextBox.Rtf = draft;
                        foreach (string emoji_code in EmojiCodeDictionary.GetEmojiDataNotMine().Keys)
                        {
                            string emoji_rtf = EmojiCodeDictionary.GetEmojiRtfByCode(emoji_code);
                            if (richTextBox.Rtf.IndexOf(emoji_rtf) >= 0)
                            {
                                //不存在才添加
                                if (emoji_codes.FindIndex(code => code.Equals("[" + emoji_code + "]")) < 0)
                                {
                                    emoji_num++;
                                    emoji_codes.Add("[" + emoji_code + "]");
                                }
                            }
                        }
                    }
                    //文本框回显
                    txtSend.Rtf = draft;
                }
            }
        }
        #endregion

        #region 初次加载控件

        private void ShowMsgPanel_Load(object sender, EventArgs e)
        {
            RegisterMessengers();       //注册通知
            this.SuspendLayout();
            try
            {
                //添加滚动到顶部的监听
                xListView.HeaderRefresh += () =>
                {
                    if (msgTabAdapter.FirstMsgIndex == 1)
                        LoadMsg();
                };
                isOpenOnlineStatus = Applicate.URLDATA.data.isOpenOnlineStatus == 1;

                //允许拖拽(liuhuan)
                txtSend.AllowDrop = true;
                txtSend.DragDrop += TxtSend_DragDrop;
                txtSend.DragEnter += TxtSend_DragEnter;
                getCustomter();
            }
            catch (Exception ex) { LogHelper.log.Error("----加载控件出错，方法（ShowMsgPanel_Load）: \r\n" + ex.Message); }
            this.ResumeLayout();
        }
        /// <summary>
        /// 是否已经开启了客户模式
        /// </summary>
        public void getCustomter()
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings")
              .AddParams("access_token", Applicate.Access_Token)
              .AddParams("userId", Applicate.MyAccount.userId).
              Build().Execute((suss, data) =>
              {
                  if (suss)
                  {


                      btnEnding.Visible = UIUtils.DecodeInt(data, "openService") == 1 ? true : false;
                  }

              });

        }

        #region 实例化对象
        public ShowMsgPanel()
        {
            InitializeComponent();
            msgTabAdapter = new MsgTabAdapter
            {
                xListView = xListView
            };
            msgRecord = new DownMsgRecord(this);    //实例化漫游接口
            //绑定列表添加控件的方法
            xListView.panel1.ControlAdded += Panel1_ControlAdded;

            xListView.FooterRefresh += () =>
            {

                //Console.WriteLine("FooterRefresh show msg panel");
                if (unReadNumPanel != null)
                {
                    unReadNumPanel.IsShowPanel("", 0, false);
                }
                UnReadMsgNum = 0;
            };


            #region @通知的点击监听
            AtMePanel.AddEvent((msgId) =>
            {
                //更新@状态
                ChooseTarget.UpdateAtMeState(0);

                if (ChooseTarget.IsGroup != 1)
                    return;

                //获取收到@的message
                MessageObject msg = msgTabAdapter.TargetMsgData.GetMsg(msgId);

                ChooseTarget.IsAtMe = 0;
                //清空At 刷新最后一条消息
                //Messenger.Default.Send(ChooseTarget, MessageActions.UPDATE_FRIEND_LAST_CONTENT);

                LocalDataUtils.SetStringData(ChooseTarget.UserId + "GROUP_AT_MESSAGEID" + Applicate.MyAccount.userId, "");
                //跟踪到该信息位置
                if (msg != null)
                {
                    int index = msgTabAdapter.msgList.FindIndex(m => m.messageId.Equals(msg.messageId));
                    xListView.ShowRangeStart(index, 0, true);
                }
                //如果不存在则直追踪到第一行
                else
                    xListView.ShowRangeStart(0, 0, true);
            });
            #endregion

            #region 新消息标识点击监听
            unReadNumPanel.AddListen((msgId) =>
            {
                //查找本地数据库
                MessageObject msg = new MessageObject() { FromId = ChooseTarget.UserId, messageId = msgId }.GetMessageObject();

                // 向下箭头，追踪到底部 禅道#7584
                if (!unReadNumPanel.direction)
                {
                    LastReadMsgId = string.Empty;
                    UnReadMsgNum = 0;
                    int end = msgTabAdapter.msgList.Count - 1;
                    xListView.ShowRangeEnd(end, 0, true);
                    return;
                }

                //查询的结果为空
                if (string.IsNullOrEmpty(msg.messageId))
                {
                    return;
                }


                //清空最新消息未读数量和字段
                LastReadMsgId = string.Empty;
                UnReadMsgNum = 0;

                #region 追踪行
                Task.Factory.StartNew(() =>
                {
                    //在字典中查找
                    int index = msgTabAdapter.msgList.FindIndex(m => m.messageId.Equals(msgId));

                    //跟踪到该信息位置
                    if (index > -1)
                    {
                        if (IsHandleCreated)
                            Invoke(new Action(() => { xListView.ShowRangeStart(index, 0, true); }));

                    }
                    //不在列表中，则必定在数据库中
                    else
                    {
                        int time = 0;
                        while (msgTabAdapter.msgList.Count < 200 && time < 10)
                        {
                            index = msgTabAdapter.msgList.FindIndex(m => m.messageId == msgId);
                            if (index > -1)
                            {
                                if (IsHandleCreated)
                                    Invoke(new Action(() => { xListView.ShowRangeStart(index, 0, true); }));
                                return;
                            }
                            //加载更多聊天记录
                            //msgTabAdapter.AddMoreMsg();
                            if (IsHandleCreated)
                                Invoke(new Action(() => { LoadMsg(); }));

                            time++;
                        }
                        if (IsHandleCreated)
                            Invoke(new Action(() => { xListView.ShowRangeStart(1, 0, true); }));
                    }
                });
                #endregion
            });
            #endregion

            #region 录音回调
            userSoundRecording.PathCallback = (localPath, timespan) =>
            {
                //修改焦点
                txtSend.Focus();
                int timeLen = (int)timespan.TotalSeconds;
                int fileSize = Convert.ToInt32(new FileInfo(localPath).Length);
                //先生成气泡
                MessageObject msg = ShiKuManager.SendVoiceMessage(ChooseTarget, "", localPath, fileSize, timeLen, false);
                JudgeMsgIsAddToPanel(msg);
                //上传音频文件
                UploadEngine.Instance.From(localPath).
                    UploadFile((success, url) =>
                    {
                        if (success)
                        {
                            msg.content = url;
                            msg.UpdateMessageContent();
                            ShiKuManager.SendMessage(msg);

                            //获取控件并转化文件
                            EQBaseControl talk_panel = GetTalkPanelByMsg(msg.messageId);
                            var result = talk_panel.Controls.Find("crl_content", true);
                            if (result.Length > 0 && result[0] is Panel panel_voice && talk_panel is EQVoiceControl voice_crl)
                            {
                                voice_crl.DownloadAndChangeVoice(panel_voice);
                            }
                        }
                    });
            };
            #endregion
        }
        #endregion

        #region 拖入控件边界时发生（liuhuan/2019/4/22）
        /// <summary>
        /// 拖入控件边界时发生
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void TxtSend_DragEnter(object sender, DragEventArgs e)
        {
            //if (e.Data.GetDataPresent(DataFormats.FileDrop))
            //{
            //    //e.Effect = DragDropEffects.Copy;
            //    e.Effect = DragDropEffects.Move;
            //}
            //else
            //{
            //    e.Effect = DragDropEffects.None;
            //}
            //如果拖拽的文件是pptx的空文件，会出现生成的图片为空（为解决）
            e.Effect = DragDropEffects.Move;
            String[] supportedFormats = e.Data.GetFormats(true);
            if (supportedFormats != null)
            {
                List<string> sfList = new List<string>(supportedFormats);
                if (sfList.Contains(DataFormats.FileDrop.ToString()))
                {
                    txtSend.EnableAutoDragDrop = false;
                }
                else
                {
                    txtSend.EnableAutoDragDrop = true;

                }
            }
        }
        #endregion

        #region  在完成拖放操作时完成（liuhuan/2019/4/22）
        /// <summary>
        /// 在完成拖放操作时完成
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void TxtSend_DragDrop(object sender, DragEventArgs e)
        {
            //string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);
            //if (files.Length > 0)
            //    fileCollect.Add(files[0]);
            //foreach (string file in files)
            //{
            //    FileStream fs = new FileStream(file, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
            //    StreamReader sr = new StreamReader(fs, System.Text.Encoding.Default);
            //    sr.Close();
            //}
            String[] supportedFormats = e.Data.GetFormats(true);
            if (supportedFormats != null)
            {
                List<string> sfList = new List<string>(supportedFormats);
                if (sfList.Contains(DataFormats.FileDrop.ToString()))
                {
                    string[] fileList = (string[])((System.Array)e.Data.GetData(DataFormats.FileDrop));
                    foreach (string fileName in fileList)
                    {
                        FileInfo fileInfo = new FileInfo(fileName);

                        if (Directory.Exists(fileName))//如果是文件夹，不允许生成图片
                        {
                            HttpUtils.Instance.ShowTip("暂不支持文件夹发送");
                            continue;
                        }
                        if (fileInfo.Length == 0 || fileInfo == null)//文件为空的情况
                        {
                            HttpUtils.Instance.ShowTip("文件为空,不允许发送请重新选择");
                            continue;
                        }
                        if (fileName.Contains(".pptx") || fileName.Contains(".ppt"))
                        {

                            //PpointFile = myWordApp.Presentations.Open(fileName, MsoTriState.msoFalse, MsoTriState.msoFalse, MsoTriState.msoFalse);
                            //PpointFile = myWordApp.Presentations.Open(fileName, MsoTriState.msoFalse, MsoTriState.msoFalse, MsoTriState.msoFalse);
                            int pages = PpointFile.Slides.Count;
                            PpointFile.Close();
                            if (pages == 0)
                            {
                                HttpUtils.Instance.ShowTip("不允许发送空白ppt");
                                continue;
                            }
                        }
                        if (!fileCollect.Contains(fileName))
                        {
                            fileCollect.Add(fileName);
                            int pic_size = 48;
                            Bitmap bm = WindowsThumbnailProvider.GetThumbnail(fileName, pic_size, pic_size, ThumbnailOptions.None);

                            Clipboard.Clear();
                            Clipboard.SetDataObject(bm, false, 3, 200);//将图片放在剪贴板中
                            if (txtSend.CanPaste(DataFormats.GetFormat(DataFormats.Bitmap)))
                                txtSend.Paste();//粘贴数据
                        }


                    }
                }
            }
            txtSend.EnableAutoDragDrop = true;
        }
        #endregion

        #region liuhuan2019/08/03获取图片的字符串
        /// <summary>
        /// 获取richtextbox所有的图片的纯rtf代码(不包括高度宽度像素等信息)
        /// </summary>
        /// <param name="_ImageList">返回图片rtf字符串列表</param>
        private void ReadImg(ref List<string> _ImageList)
        {
            _ImageList.Clear();
            string _RtfText = txtSend.Rtf;
            while (true)
            {
                int _Index = _RtfText.IndexOf("pichgoal");
                if (_Index == -1) break;
                _RtfText = _RtfText.Remove(0, _Index + 8);
                _Index = _RtfText.IndexOf("\r\n");
                _RtfText = _RtfText.Remove(0, _Index);
                _Index = _RtfText.IndexOf("}");
                _ImageList.Add(_RtfText.Substring(0, _Index).Replace("\r\n", ""));
                _RtfText = _RtfText.Remove(0, _Index);
            }
        }
        #endregion
        #region  发送拖拽后的文件（liuhuan/2019/4/22）
        /// <summary>
        /// 拖拽后点击发送文件
        /// </summary>
        private void DroupFeileSend()
        {
            //if (_ImageList.Count == 0)
            //{
            //    fileCollect.Clear();
            //}
            try
            {
                foreach (string local_path in fileCollect)
                {
                    if (File.Exists(local_path))
                    {
                        bool isVideo = FileUtils.JudgeIsVideoFile(local_path);
                        //如果为视频文件
                        if (isVideo)
                        {
                            //先生成气泡
                            int fileSize = Convert.ToInt32(new FileInfo(local_path).Length);
                            MessageObject msg = ShiKuManager.SendVideoMessage(ChooseTarget, "", local_path, fileSize, false);
                            msg.isLoading = 1;
                            JudgeMsgIsAddToPanel(msg);

                            //获取气泡
                            EQBaseControl talk_panel = GetTalkPanelByMsg(msg.messageId);
                            if (talk_panel != null)
                            {
                                UploadEngine.Instance.From(local_path).
                                //上传完成
                                UploadFile((success, url) =>
                                {
                                    UploadVideo(talk_panel, msg, url, success);
                                });
                            }
                        }
                        else
                            UploadFileOrImage(local_path, Convert.ToInt32(new FileInfo(local_path).Length));
                    }
                    else
                        HttpUtils.Instance.ShowTip("路径不存在：" + local_path);
                }
            }
            catch (Exception ex) { LogHelper.log.Error("----------发送拖拽后的文件出错：方法（DroupFeileSend）\n" + ex.Message); }
            //txtSend.Clear();
            fileCollect.Clear();
        }
        #endregion

        #region 注册通知
        /// <summary>
        /// 注册通知  (注释可将鼠标移至Notifaction属性上查看)    
        /// </summary>
        private void RegisterMessengers()
        {
            //注册添加消息气泡到消息列表
            //Messenger.Default.Register<MessageObject>(this, CommonNotifications.XmppMsgAddTable, item => AddMessageToPanel(item.messageId));
            //注册往文本框添加emoji表情
            //Messenger.Default.Register<string>(this, EQFrmInteraction.AddEmojiToTxtSend, item => AddEmojiToTxtSend(item));
            //注册发送消息时添加消息气泡
            //Messenger.Default.Register<MessageObject>(this, EQFrmInteraction.SendMsgAddBubble, item => AddMessageToPanel(item));
            //多选操作结束
            Messenger.Default.Register<Friend>(this, EQFrmInteraction.MultiSelectEnd, item => { if (ChooseTarget.UserId.Equals(item.UserId)) LblClose_Click(null, null); });
            #region 清空UI
            //注册清空UI（单向）
            Messenger.Default.Register<string>(this, EQFrmInteraction.ClearFdMsgsSingle, (userId) =>
            {
                //请求接口删除聊天记录
                MessageObject message = new MessageObject() { FromId = userId };
                message.DeleteTable();

                //通知最近聊天列表更新


                Friend fd = new Friend() { UserId = userId }.GetByUserId();
                Messenger.Default.Send(fd, token: MessageActions.UPDATE_FRIEND_LAST_CONTENT);

                // 清除服务器数据
                ClearServerFriendMsg(userId);

                if (ChooseTarget == null)
                    return;
                if (userId == ChooseTarget.UserId)     //对象必须是当前聊天对象才清空页面
                    ClearUI(ChooseTarget);
            });
            //注册清空UI（双向）
            Messenger.Default.Register<string>(this, MessageActions.CLEAR_FRIEND_MSGS, (userId) =>
            {
                //通知最近聊天列表更新
                Friend fd = new Friend() { UserId = userId }.GetByUserId();
                Messenger.Default.Send(fd, token: MessageActions.UPDATE_FRIEND_LAST_CONTENT);

                if (ChooseTarget == null)
                    return;
                if (userId == ChooseTarget.UserId)     //对象必须是当前聊天对象才清空页面
                    ClearUI(ChooseTarget);
            });
            #endregion
            //注册移除某一行
            Messenger.Default.Register<string>(this, EQFrmInteraction.RemoveMsgOfPanel, item => RemoveMsgOfPanel(item));
            //按回执更新送达消息状态（成功）
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_SEND_SUCCESS, item => DrawIsSend(item));
            //按回执更新送达消息状态（失败）
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_SEND_FAILED, item => DrawIsSend(item));
            //按回执更新已读消息状态
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_RECEIVED_READ, item => DrawIsRead(item));
            //给消息列表添加消息
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_NORMAL_MESSAGE, item => JudgeMsgIsAddToPanel(item));
            //收到了一个群组控制消息
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_ROOM_CHANGE_MESSAGE, item => UpdateRoomUIByMessage(item));
            //收到了一个撤回通知
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_RECALL_MESSAGE, item => RecallMsg(item));
            //收到了一个群禁言通知
            Messenger.Default.Register<MessageObject>(this, MessageActions.ROOM_UPDATE_BANNED_TALK, item => UpdateBannedTalk(item));
            //收到了一个修改备注通知
            Messenger.Default.Register<Friend>(this, MessageActions.UPDATE_FRIEND_REMARKS, item => ModifyFriendName(item));
            //收到了一个批量删除通知
            Messenger.Default.Register<List<MessageObject>>(this, EQFrmInteraction.BatchDeleteMsg, item => BatchDeleteMsg(item));
            //收到了一个@我的通知
            Messenger.Default.Register<Friend>(this, MessageActions.ROOM_UPDATE_AT_ME, item => AtMeShowPanel(item));
            //收到我主动@别人的通知
            Messenger.Default.Register<MessageObject>(this, EQFrmInteraction.AddAtUserToTxtSend, item => AddAtUserToTxtSend(item));
            //重新上传图片并更新气泡
            Messenger.Default.Register<MessageObject>(this, EQFrmInteraction.ResumeUploadImageMsg, item => ResumeUploadImageMsg(item));
            //重新上传视频并更新气泡
            Messenger.Default.Register<MessageObject>(this, EQFrmInteraction.ResumeUploadVideoMsg, ResumeUploadVideoMsg);
            //多点登录上线离线消息
            Messenger.Default.Register<string>(this, MessageActions.UPDATE_DEVICE_STATE, item => UpdateDeviceState(item));
            //独立聊天窗口收到删除好友的通知需要关闭窗体
            Messenger.Default.Register<Friend>(this, MessageActions.DELETE_FRIEND, DeleteFdCloseFrm);
            //拉黑的通知
            Messenger.Default.Register<Friend>(this, MessageActions.ADD_BLACKLIST, DeleteFdCloseFrm);

            Messenger.Default.Register<Friend>(this, MessageActions.UPDATE_FRIEND_READDEL, (lacal) =>
            {
                if (ChooseTarget != null && lacal.UserId.Equals(ChooseTarget.UserId))
                {
                    ChooseTarget.IsOpenReadDel = lacal.IsOpenReadDel;
                }
            });
            Messenger.Default.Register<string>(this, MessageActions.XMPP_UPDATE_CUSTOMERSERVICE, updateCustomer);

            Messenger.Default.Register<List<List<string>>>(this, MessageActions.RED_UPDATE_COMMAND, SetRedCommand);
            Messenger.Default.Register<string>(this, MessageActions.RED_OPEN_COMMAND, OPENRedCommand);

        }
        private void OPENRedCommand(string id)
        {
            RedpaperUIUtils.OpenRedPacket(id);
        }
        #region 口令红包        
        private void SetRedCommand(List<List<string>> keyValues)
        {
            if (!CommandLst.Contains(keyValues[0]))
            {
                CommandLst.Add(keyValues[0]);
            }

            //CommandLst = keyValues;
            int count = keyValues.Count - 1;
            txtSend.Text = keyValues[count][0];
            RedCommand = keyValues[count][0];
            RedId = keyValues[count][1];
            Redopen = keyValues[count][2];
        }
        #endregion
        #endregion
        #endregion

        #region 切换聊天对象
        #region 更换聊天对象，清除缓存
        /// <summary>
        /// 更换聊天对象，清除缓存
        /// </summary>
        /// <param name="friend">切换签的聊天对象</param>
        /// <param name="isDispon"></param>
        private void ClearUI(Friend friend, bool isDispon = true)
        {
            //关闭设置页
            //if (frmSet != null)
            //{
            //    frmSet.Close();
            //    frmSet = null;
            //}
            //关闭之前对象的接口调用
            if (!string.IsNullOrEmpty(ChooseTarget.UserId))
            {

                HttpUtils.Instance.Cancel(ChooseTarget.UserId);
                HttpUtils.Instance.Cancel(ChooseTarget.UserId + "roomget");

            }


            //清除已选择的emoji
            emoji_num = 0;
            emoji_codes = new List<string>();

            //草稿回显
            DraftShow(friend);

            //阅后即焚处理
            SaveReadDelTime();
            isHaveReadDel = 0;

            //非独立窗体
            if (isSeparateChat == 0)
            {
                //获取上个聊天对象
                if (!string.IsNullOrEmpty(ChooseTarget.UserId))
                {
                    var last_target = ChatTargetDictionary.GetMsgData(ChooseTarget.UserId);
                    //如果上个聊天对象不为独立窗体
                    if (last_target.isSeparateChat == 0)
                    {
                        //清除上个聊天对象的消息
                        if (ChooseTarget != null && !string.IsNullOrEmpty(ChooseTarget.UserId))
                        {
                            if (last_target.GetMsgList().Count > 0)
                                last_target.RemoveAllData();
                        }
                        //移除切换好友前的对象
                        ChatTargetDictionary.RemoveItem(ChooseTarget.UserId);
                    }
                }
            }
            else
            {
                //上一个对象必定为空
                //if(string.IsNullOrEmpty(choose_target.userId))
                //{
                //获取新独立窗体的聊天对象
                //targetMsgData = ChatTargetDictionary.GetMsgData(friend.userId);
                var current_target = ChatTargetDictionary.GetMsgData(friend.UserId);
                //清除数据
                if (current_target != null && current_target.GetMsgList().Count > 0)
                    current_target.RemoveAllData();
                //}
            }
            //更新聊天对象
            ChooseTarget = friend;
            //清空聊天列表并绑定新的数据
            msgTabAdapter.direction = false;        //倒序排列
            msgTabAdapter.choose_target = ChooseTarget;
            //保存是否为独立聊天
            msgTabAdapter.TargetMsgData.isSeparateChat = this.isSeparateChat;
            //List<MessageObject> msgList = msgTabAdapter.LoadObjectLocalMsg();   //获取本地数据
            BubbleBgDictionary.RemoveAllBg();       //移除所有缓存的背景图
            //msgTabAdapter.BindData(msgList);        //绑定数据源
            xListView.SetAdapter(msgTabAdapter);    //绑定适配器

            Helpers.ClearMemory();
            atCount = 0;    //重置@符数量

            //重置向上翻页
            //canAddMsg = 1;
            //清空录制
            ClearTranscribe();

            //关闭等待符
            loding.stop();

            //重置漫游状态
            isDownloadRoaming = false;

            //取消录音
            if (userSoundRecording.SoundState)
                userSoundRecording.StopSound();

            lastMsgTime = 0;    //重置最后一条消息的时间

            //隐藏并清空回复面板
            replyPanel.ReplyMsg = null;
            replyPanel.SendToBack();

            page_index = 1;      //漫游页数重置
                                 //1.将复制好的图片放入发送框中，切换一个聊天对象并复制发送图片，再切换回去原先的图片无法发
                                 // SrcImages = new Dictionary<string, string>();


        }
        #endregion

        #region 清空聊天缓存，保存新选择的聊天对象
        /// <summary>
        /// 清空聊天缓存，保存新选择的聊天对象
        /// <para>如果聊天对象不变，请不要调用</para>
        /// </summary>
        /// <param name="friend">聊天对象</param>
        public void SetChooseFriend(Friend friend, int readNum = 0, string msgId = "", int isSeparateChat = 0)
        {
            try
            {
                //避免因为错误退出，界面挂起没恢复
                this.ResumeLayout();
                xListView.panel1.ResumeLayout();

                //记录未读的相关信息
                this.readNum = readNum;
                this.readMsgId = msgId;
                friend.MsgNum = 0;

                //记录是否为独立聊天对象
                this.isSeparateChat = isSeparateChat;

                //设置空的聊天对象，重置面板
                if (friend == null || string.IsNullOrEmpty(friend.UserId))
                {
                    ClearUI(friend);
                    ChooseTarget = null;
                    return;
                }
                //点击相同的对象
                //if (choose_target != null && choose_target.userId == friend.userId)
                //    return;

                //this.SuspendLayout();
                //panShade.BringToFront();    //遮罩层使界面加载过程不可见
                //复选框列不可见
                if (msgTabAdapter.TargetMsgData.isMultiSelect)
                    LblClose_Click(null, null);
                IsShowPanelMultiSelect(false);      //显示聊天发送框而不是多选操作面板
                                                    //Applicate.FriendObj = friend;
                ClearUI(friend);
                //保存聊天对象
                //choose_target = friend;

                //修改标题
                labName.Text = friend.GetRemarkName();

                //群公告隐藏
                roomNotice.CloseNotice();
                //获取群设置
                if (ChooseTarget.IsGroup == 1)
                {
                    GetRoomSetting();
                    // 增加容错，自动加群防止收不到群消息
                    if (!UIUtils.IsNull(ChooseTarget.UserId))
                    {
                        ShiKuManager.mSocketCore.JoinRoom(ChooseTarget.UserId, 0);
                    }
                }
                else
                {
                    //获取好友状态到标题栏
                    SetOnlineState();
                    //设置音视频的可见度
                    if (Applicate.ENABLE_MEET && Applicate.CURRET_VERSION > 4.0f)
                    {
                        lblAudio.Visible = true;
                        lblVideo.Visible = true;
                    }
                }

                //先更新界面再
                Application.DoEvents();

                //先进行漫游
                //FirstDownloadRoaming();
                page_index = 1;
                isFirstLoad = true;
                if (msgTabAdapter.msgList.Count > 0)
                {
                    msgTabAdapter.TargetMsgData.RemoveAllData();
                    xListView.ClearList();
                }

                msgRecord.LoadMsgDatas(friend, page_index, 0);

                //如果正在漫游则漫游结束后才对面板进行操作
                //if (!isDownloadRoaming)
                //    SetShowInfoPanel();

                #region 禁言与隐身人
                //清除禁言面板
                IsShow_BannedTalkPanel(false);

                SetBannedTalk();
                #endregion

                //控制是否显示未读数量悬浮标识
                IsShowUnReadNumPanel(readNum, readMsgId);

                //是否显示音视频按钮
                if (!Applicate.ENABLE_MEET || Applicate.CURRET_VERSION < 4.6f)
                {
                    lblAudio.Visible = false;
                    lblVideo.Visible = false;
                }
                //控制是否要显示@角标
                AtMeShowPanel(friend);

                //如果有空白滚动到底部
                //RollBottom_HaveEmpty();

                txtSend.Focus();    //文本输入框自动获取焦点
                if (ChooseTarget.Content.Contains("您好我是客户客户" + ChooseTarget.UserId + ",很高兴为您服务，请问有什么问题可以帮您的?"))
                {
                    lab_detial.Visible = false;
                }
                else
                {
                    lab_detial.Visible = true; ;
                }
            }
            catch (Exception ex)
            {
                LogHelper.log.Error("-------------保存聊天对象出错，方法（SetChooseFriend）: \r\n" + ex.Message);
            }
        }
        #endregion

        #endregion

        #region 处理群通知UI更新
        private void UpdateRoomUIByMessage(MessageObject msg)
        {
            try
            {
                if (ChooseTarget == null)
                    return;
                if (ChooseTarget.IsGroup == 0 || !ChooseTarget.UserId.Equals(msg.objectId))
                    return;

                switch (msg.type)
                {
                    //是否允许私聊
                    case kWCMessageType.RoomUserRecommend:
                        if (msg.content == "1")  //允许群成员私聊
                        {
                            ChooseTarget.AllowSendCard = 1;
                        }
                        else    //不允许群成员私聊
                        {
                            ChooseTarget.AllowSendCard = 0;
                        }
                        break;
                    //群管理员转让
                    case kWCMessageType.RoomManagerTransfer:
                        //如果是我转让群主出去
                        if (msg.fromUserId.Equals(Applicate.MyAccount.userId))
                        {
                            //检查禁言
                            SetBannedTalk();
                        }
                        //如果是转让群主给我
                        else
                            IsShow_BannedTalkPanel(false);
                        break;
                    //群公告
                    case kWCMessageType.RoomNotice:
                    case kWCMessageType.RoomNoticeEdit:
                        roomNotice.Getmonitor(msg);
                        break; ;
                    //解散群聊
                    case kWCMessageType.RoomDismiss:
                        string remindTxt = "该群已被解散";
                        IsShow_BannedTalkPanel(true, remindTxt);
                        break;
                    //修改房间名称
                    case kWCMessageType.RoomNameChange:
                        ChooseTarget.NickName = msg.content;
                        if (this.IsHandleCreated)
                            Invoke(new Action(() =>
                            {
                                //msg.content + "（" + userSize + "人）";
                                labName.Text = UIUtils.LimitTextLength(msg.content, 18, true) + "(" + userSize + "人)";
                            }));
                        break;
                    //显示阅读人数
                    case kWCMessageType.RoomReadVisiblity:
                        ChooseTarget.ShowRead = Convert.ToInt32(msg.content);
                        IsShowReadPersons(ChooseTarget.ShowRead == 0 ? false : true);
                        break;
                    //群讲课
                    case kWCMessageType.RoomAllowSpeakCourse:
                        if (this.IsHandleCreated)
                            Invoke(new Action(() =>
                            {
                                if (Applicate.ENABLE_MEET && Applicate.CURRET_VERSION > 4.0f)
                                {
                                    ChooseTarget.AllowConference = Convert.ToInt32(msg.content);
                                    //关闭后，改变普通成员的音视频按钮状态
                                    SetControlEnabled(lblAudio, ChooseTarget.AllowSpeakCourse == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true);
                                    SetControlEnabled(lblVideo, ChooseTarget.AllowSpeakCourse == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true);
                                }
                                else
                                {
                                    SetControlEnabled(lblAudio, false);
                                    SetControlEnabled(lblVideo, false);
                                }
                            }));
                        break;
                    //群会议开关
                    case kWCMessageType.RoomAllowConference:
                        if (this.IsHandleCreated)
                            Invoke(new Action(() =>
                            {
                                if (Applicate.ENABLE_MEET && Applicate.CURRET_VERSION > 4.0f)
                                {
                                    ChooseTarget.AllowConference = Convert.ToInt32(msg.content);
                                    //关闭群会议，普通成员不允许点击视频和音频
                                    //SetControlEnabled(lblAudio, choose_target.allowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true);
                                    //SetControlEnabled(lblVideo, choose_target.allowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true);
                                    lblAudio.Visible = ChooseTarget.AllowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true;
                                    lblVideo.Visible = ChooseTarget.AllowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true;
                                }
                                else
                                {
                                    lblAudio.Visible = false;
                                    lblVideo.Visible = false;
                                }
                            }));
                        break;
                    //入群通知
                    case kWCMessageType.RoomInvite:
                        if (this.IsHandleCreated)
                            Invoke(new Action(() =>
                            {
                                userSize++;
                                labName.Text = UIUtils.LimitTextLength(ChooseTarget.GetRemarkName(), 18, true) + "(" + userSize + "人)";
                            }));
                        break;
                    //退群通知
                    case kWCMessageType.RoomExit:
                        if (this.IsHandleCreated)
                            Invoke(new Action(() =>
                            {
                                //如果是自己的退群通知
                                if (msg.toUserId == Applicate.MyAccount.userId)
                                    IsShow_BannedTalkPanel(true, "您已经不在该群中");
                                else
                                {
                                    //修改群标题人数
                                    userSize--;
                                    labName.Text = UIUtils.LimitTextLength(ChooseTarget.GetRemarkName(), 18, true) + "(" + userSize + "人)";

                                }
                            }));
                        break;
                    case kWCMessageType.RoomUnseenRole:
                        //隐身人是否为自己
                        if (msg.ToId.Equals(Applicate.MyAccount.userId))
                        {
                            string remind_txt = "您当前为隐身人状态";
                            bool isBannedTalk = false;
                            bool isUnseen = msg.content == "1";
                            //开启隐身人
                            if (isUnseen)
                                isBannedTalk = true;
                            //关闭隐身人
                            else
                                isBannedTalk = JudgeIsBannedTalk(ref remind_txt);
                            IsShow_BannedTalkPanel(isBannedTalk, remind_txt, isUnseen);
                        }
                        break;
                    case kWCMessageType.RoomAdmin:
                        //指定群管理员
                        var room = msg.GetFriend();
                        if (room != null)
                        {
                            int role = 3;
                            if (msg.content == "0")//取消管理员
                            {
                                role = 3;
                            }
                            else if (msg.content == "1")//设置管理员
                            {
                                role = 2;
                            }
                            var member = new RoomMember() { userId = msg.toUserId, roomId = room.RoomId, role = role };
                            member.UpdateRole();
                        }
                        break;

                }
            }
            catch (Exception ex)
            {
                LogHelper.log.Error("----处理群设置消息出错，方法（UpdateRoomUIByMessage）: \r\n" + ex.Message);
            }
        }
        #endregion

        #region 列表容器添加和移除控件
        private void Panel1_ControlAdded(object sender, ControlEventArgs e)
        {
            #region 添加右键菜单
            EQShowInfoPanelAlpha panelAlpha = null;
            for (int index = e.Control.Controls.Count - 1; index > -1; index--)
            {
                Control pan_crl = e.Control.Controls[index];
                if (pan_crl is EQBaseControl talk_panel)
                {
                    foreach (Control item in talk_panel.Controls)
                    {
                        switch (item.Name)
                        {
                            case "lab_msg": break;
                            case "lab_hand": break;
                            //内容控件在气泡内
                            case "image_panel":
                                //item.MouseDown += Content_MouseDown;
                                foreach (Control crl in item.Controls)
                                {
                                    if (string.Equals(crl.Name, "crl_content"))
                                    {
                                        crl.MouseDown += Content_MouseDown;
                                        AddContentMouseDownToCrl(crl);  //给所有子控件设置右键菜单事件
                                        crl.ContextMenuStrip = cmsMsgMenu;
                                    }
                                }
                                break;
                            case "crl_content":
                                item.MouseDown += Content_MouseDown;
                                AddContentMouseDownToCrl(item);  //给所有子控件设置右键菜单事件
                                item.ContextMenuStrip = cmsMsgMenu;
                                break;
                            default:
                                break;
                        }
                    }
                }

                //开启多选后遮罩层在上
                else if (pan_crl is EQShowInfoPanelAlpha e_panelAlpha)
                    panelAlpha = e_panelAlpha;
            }
            if (panelAlpha != null)
                if (msgTabAdapter.TargetMsgData.isMultiSelect)
                    panelAlpha.SendToBack();
            #endregion
        }

        #region 移除并销毁某一条消息
        private void RemoveMsgOfPanel(string msgId)
        {
            MessageObject msg = msgTabAdapter.TargetMsgData.GetMsg(msgId);
            if (msg == null)
                return;

            int index = msgTabAdapter.msgList.FindIndex(m => m.messageId == msg.messageId);
            Action action = new Action(() =>
            {
                //从容器中移除控件
                xListView.RemoveItem(index);
                //从字典中移除
                msgTabAdapter.TargetMsgData.RemoveMsgData(msgId);

                //删除数据库数据
                msg.DeleteData();

                if (xListView.Progress == 100)
                {
                    int end = msgTabAdapter.msgList.Count - 1;
                    xListView.ShowRangeEnd(end, 0, true);
                }
            });
            if (this.IsHandleCreated)
                Invoke(action);
        }
        #endregion

        #region 替换为remind类型气泡
        private void ReplaceMsgToRemind(string msgId, string content)
        {
            //不存在该消息
            if (msgTabAdapter.TargetMsgData.GetMsg(msgId) == null)
                return;

            //获取msg
            MessageObject msg = msgTabAdapter.TargetMsgData.GetMsg(msgId);

            msg.type = kWCMessageType.Remind;
            msg.content = content;
            //msg.isReadDel = 0;
            msg.UpdateData();

            Action action = new Action(() =>
            {
                xListView.panel1.SuspendLayout();
                try
                {
                    //避免重复右键菜单，先更新UI
                    msg.BubbleWidth = 0; msg.BubbleHeight = 0;
                    msgTabAdapter.TargetMsgData.UpdateMsg(msg);
                    int index = msgTabAdapter.msgList.FindIndex(m => m.messageId == msg.messageId);
                    xListView.RefreshItem(index);
                    RollBottom_HaveEmpty();
                }
                catch (Exception ex) { LogHelper.log.Error("-------------替换为remind类型气泡出错，方法（ReplaceMsgToRemind）: \r\n" + ex.Message); }
                xListView.panel1.ResumeLayout();
            });
            if (this.IsHandleCreated)
                Invoke(action);
        }
        #endregion
        #endregion

        #region 展示等待符
        LodingUtils loding = new LodingUtils();     //新创一个等待符
        private void StartLoding(Control parent_crl, string title = "")
        {
            //loding = new LodingUtils();
            loding.Title = title;
            loding.size = new Size(30, 30);
            loding.parent = parent_crl;
            loding.BgColor = Color.Transparent;
            loding.start();
        }
        #endregion

        #region 发送消息

        
        #region 发送按钮发送
        private void BtnSend_Click(object sender, EventArgs e)
        {
            //选择对象不能为空
            if (ChooseTarget == null || string.IsNullOrEmpty(ChooseTarget.UserId))
                return;
            if (txtSend.Text == null)
            { return; }
            //如果当前为禁言中
            if (!btnSend.Visible)
                return;

            if (fileCollect != null && fileCollect.Count > 0)
            {
                DroupFeileSend();
            }

            try
            {
                //保存变量，异步执行会导致变量出错
                string strSend = txtSend.Text;
                string rtfSend = txtSend.Rtf;
                int eji_num = emoji_num;
                List<string> eji_codes = emoji_codes;
                int at_count = atCount;
                List<Friend> atFriends = list_atFriends;
                MessageObject replyMsg = replyPanel.ReplyMsg;
                Friend fdSend = ChooseTarget;
                if (this.SrcImages == null)
                {
                    this.SrcImages = new Dictionary<string, string>();
                }
                Dictionary<string, string> SrcImages = this.SrcImages.Copy();

                Thread sendThread = new Thread(() =>
                {
                    //输入不能为空
                    if (string.IsNullOrEmpty(strSend) && eji_num < 1)
                    {
                        //不存在图片
                        if (!EQControlManager.JudgeRtfHaveImg(rtfSend))
                            return;
                    }

                    //emoji表情转为code
                    if (eji_codes != null && eji_codes.Count > 0)
                        rtfSend = EmojiPngToCode(rtfSend, eji_codes);
                    //用于rtf的转化
                    using (RichTextBox richTextBox = new RichTextBox())
                    {
                        richTextBox.Rtf = rtfSend;

                        #region 解析图片并单独发送
                        try
                        {
                            //用正则表达式，获取图片rtf
                            //MatchCollection matchs = Regex.Matches(richTextBox.Rtf, @"{\\object[^}]+}", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                            //foreach (Match item in matchs)
                            //{
                            //    richTextBox.Rtf = richTextBox.Rtf.Replace(item.Value, "");
                            //}

                            //List<Image> list_images = new List<Image>();
                            //用正则表达式，获取图片rtf
                            //MatchCollection matchs = Regex.Matches(richTextBox.Rtf, @"{\\pict[^}]+}", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                            //foreach (Match item in matchs)
                            foreach (string filePath in SrcImages.Keys)
                            {
                                string old_rtf = richTextBox.Rtf;
                                string img_rtf = SrcImages[filePath].Replace("{\\*\\picprop{\\sp{\\sn wzDescription}{\\sv Image}}{\\sp{\\sn posv}{\\sv 1}}\r\n}\\pngblip", "\\wmetafile8");
                                //var result = old_rtf.Split(new string[] { img_rtf }, StringSplitOptions.None);
                                int pic_num = old_rtf.Split(new string[] { img_rtf }, StringSplitOptions.None).Length - 1;
                                richTextBox.Rtf = richTextBox.Rtf.Replace(img_rtf, "");
                                //如果图片已经从文本框删除
                                if (old_rtf.Equals(richTextBox.Rtf))
                                    continue;

                                //保存图片到本地
                                //string filePath = EQControlManager.RtfToImageSave(item.Value);

                                //可能发送多张相同的图片
                                for (int index = 0; index < pic_num; index++)
                                {
                                    //发送图片
                                    if (!string.IsNullOrEmpty(filePath))
                                    {
                                        //添加气泡到列表
                                        MessageObject msg = ShiKuManager.SendImageMessage(fdSend, "", filePath, Convert.ToInt32(new FileInfo(filePath).Length), false);
                                        JudgeMsgIsAddToPanel(msg);

                                        //上传完成
                                        UploadEngine.Instance.From(filePath).
                                            UploadFile((success, url_path) =>
                                            {
                                                MessageObject t_msg = msgTabAdapter.TargetMsgData.GetMsg(msg.messageId);
                                                if (t_msg != null)
                                                {
                                                    //修改气泡的图片和样式
                                                    string name = "talk_panel_" + t_msg.messageId;
                                                    EQBaseControl talk_panel = GetTalkPanelByMsg(t_msg.messageId);
                                                    if (talk_panel is EQImageControl imageCrl)
                                                    {
                                                        UploadImage(imageCrl, t_msg, url_path, success);
                                                    }
                                                }
                                                //如果当前聊天对象已切换，则不更新UI只发送
                                                if (!ChooseTarget.UserId.Equals(msg.fromUserId) && success)
                                                {
                                                    msg.content = url_path;
                                                    msg.UpdateMessageContent();
ShiKuManager.SendMessage(msg);                                                }
                                            });
                                    }
                                }
                            }

                        }
                        catch (Exception ex)
                        {
                            LogHelper.log.Error("----解析图片出错，方法（btnSend_Click） : " + ex.Message);
                        }
                        #endregion

                        //发送文本消息
                        try
                        {
                            if (!string.IsNullOrEmpty(strSend) && !string.IsNullOrWhiteSpace(richTextBox.Text))
                            {
                                //如果是长文本消息
                                if (richTextBox.Text.Length > 3000)
                                    SendTxtFile_LongTextMsg(richTextBox.Text.TrimEnd());
                                else
                                {
                                    // 修改搜狗输入法回车后直接发出文字的问题#7303
                                    var textarray = richTextBox.Text.ToArray();
                                    if (textarray.Length > 0)
                                    {
                                        char cc = textarray[textarray.Length - 1];
                                        if (10 != cc && sender == null)
                                        {
                                            return;
                                        }
                                    }


                                    MessageObject txt_msg = null;
                                    //回复消息
                                    if (replyMsg != null && !string.IsNullOrEmpty(replyMsg.messageId))
                                        txt_msg = ShiKuManager.SendReplayMessage(fdSend, replyMsg, richTextBox.Text, false);
                                    else
                                    {
                                        // 修改禅道7938
                                        if (at_count > 0 && !UIUtils.IsNull(atFriends))
                                        {
                                            atFriends = atFriends.FindIndex(f => f.UserId.Equals("allRoomMember")) > -1 ? new List<Friend>() : atFriends;
                                            txt_msg = ShiKuManager.SendAtMessage(fdSend, atFriends, richTextBox.Text, false);
                                        }
                                        else
                                            txt_msg = ShiKuManager.SendTextMessage(fdSend, richTextBox.Text.TrimEnd(), false);

                                        if (txt_msg.content != null)
                                        {
                                            for (int i = 0; i < CommandLst.Count; i++)
                                            {
                                                if (CommandLst[i].Contains(txt_msg.content))
                                                {
                                                    RedId = CommandLst[i][1];
                                                    Messenger.Default.Send(RedId, MessageActions.RED_OPEN_COMMAND);// 更新UI消息
                                                    CommandLst.Remove(CommandLst[i]);
                                                }
                                            }
                                        }

                                    }
                                    JudgeMsgIsAddToPanel(txt_msg);
                                    //添加消息气泡
                                    //指定发送的UserId
                                    ShiKuManager.SendMessage(txt_msg);
                                }
                            }


                            //清空发送框
                            txtSend.Focus();
                            txtSend.Clear();
                        }
                        catch (Exception ex)
                        {
                            LogHelper.log.Error("----发送文本消息出错，方法（btnSend_Click） : " + ex.Message);
                        }
                    }

                });
                if (this.IsHandleCreated)
                {
                    sendThread.SetApartmentState(ApartmentState.STA);
                    sendThread.Start();
                }
            }
            catch (Exception ex) { LogHelper.log.Error("----发送消息出错，方法（btnSend_Click） : " + ex.Message, ex); }

            emoji_num = 0;
            atCount = 0;
            list_atFriends = new List<Friend>();
            //bug7688()
            // this.SrcImages = new Dictionary<string, string>();

            //清空回复面板
            if (!string.IsNullOrEmpty(replyPanel.ReplyMsg.messageId))
            {
                replyPanel.ReplyMsg = new MessageObject();
                replyPanel.SendToBack();
            }
        }
        #endregion

        #region 长文本转文件消息发送
        private void SendTxtFile_LongTextMsg(string txt_msg)
        {
            //保存的本地路径   //文件命名规则：2019-06-25 时间戳
            string local_path = Applicate.LocalConfigData.FileFolderPath +
                string.Format(@"文件({0}).txt", DateTime.Now.ToString("yyyy-MM-dd") + " " + TimeUtils.CurrentIntTime());
            FileStream fs = new FileStream(local_path, FileMode.OpenOrCreate);
            StreamWriter wr = null;
            wr = new StreamWriter(fs);
            wr.WriteLine(txt_msg);
            wr.Close();

            //上传并发送文件
            int file_size = Convert.ToInt32(new FileInfo(local_path).Length);
            UploadFileOrImage(local_path, file_size);
        }
        #endregion

        #endregion

        #region 文本框事件
        #region 发送消息文本框，文本变更事件
        private bool isChangingEmoji = false;   //是否正在转换emoji表情
        private int txtChangedState = 1;    //0为正在选择@成员，不再弹出好友选择器
        private int atCount = 0;    //@的人数
        private List<Friend> list_atFriends = new List<Friend>();
        private void TxtSend_TextChanged(object sender, EventArgs e)
        {
            #region 图片被删除 liuhuan2019/08/03
            //if (change == false)
            //    change = true;
            //if (ln > txtSend.TextLength && fileCollect.Count != 0)
            //{
            //    ReadImg(ref _ImageList2);
            //    //获取删除的图片
            //    List<string> reducelist = _ImageList.Except(_ImageList2).ToList();
            //    if (reducelist.Count > 0) //代表有删除过图片
            //    {
            //        int index = _ImageList.FindIndex(r => r == reducelist[0]);
            //        if (index != -1)
            //        {
            //            fileCollect.RemoveAt(index);
            //        }
            //    }
            //}
            //ln = txtSend.TextLength;
            //ReadImg(ref _ImageList);
            #endregion

            #region 群@功能
            if (ChooseTarget != null && ChooseTarget.IsGroup == 1)
            {
                string[] sArray = txtSend.Text.Split('@');
                if (sArray.Length > 1 && txtChangedState == 1)
                {
                    string addAtMember = "";    //@的群员
                    int addAtCount = 0;     //单次好友选择器添加的@数量
                    //是否新输入了@字符
                    if ((sArray.Length - 1 - atCount) > 0)
                    {
                        FrmFriendSelect frmFriendSelect = new FrmFriendSelect();
                        frmFriendSelect.LoadFriendsData(ChooseTarget, true);
                        frmFriendSelect.AddConfrmListener((UserFriends) =>
                        {
                            if (UserFriends == null || UserFriends.Count == 0)
                            {
                                txtSend.Text = "";
                                return;
                            }

                            txtChangedState = 0;
                            foreach (var friend in UserFriends.Values)
                            {
                                addAtMember += "@" + (string.IsNullOrEmpty(friend.RemarkName) ? friend.NickName : friend.RemarkName) + " ";
                                addAtCount++;
                                list_atFriends.Add(friend);
                            }

                            //选择完好友后
                            addAtMember = addAtMember.Substring(1);     //去除第一个@符
                            int SelectIndex = txtSend.SelectionStart;
                            txtSend.Text = txtSend.Text.Insert(txtSend.SelectionStart, addAtMember);
                            //EQPosition txtSend_CursorPosition = EQControlManager.GetRichTextPosition(txtSend);
                            atCount = sArray.Length - 1 + (addAtCount > 0 ? addAtCount - 1 : 0);

                            //修改@颜色
                            EQControlManager.GroupAtModifyColor(txtSend);
                            txtSend.SelectionStart = SelectIndex + addAtMember.Length;
                            txtChangedState = 1;
                        });
                    }
                }
                atCount = sArray.Length - 1;
            }
            #endregion


            //if (lastInputCount - txtSend.TextLength == -1)
            //{
            //    lastInputCount = txtSend.TextLength;
            //    char cc = txtSend.Text.ElementAt(txtSend.TextLength - 1);
            //    if (cc == 93)
            //    {
            //        return;
            //    }
            //    Console.WriteLine("ccc");
            //}

            #region 修改emojiCode转图片
            //正在转化emoji表情
            if (!isChangingEmoji)
           {
                if (string.IsNullOrEmpty(txtSend.Text) || txtSend.Text.IndexOf("[") < 0)
                    return;

                Console.WriteLine("TextChanged_Emoji");
                //匹配符合规则的表情code
                //MatchCollection matchs = Regex.Matches(txtSend.Text, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                //if (matchs.Count > 0)
                //{
                isChangingEmoji = true;
                txtSend.SuspendLayout();
                try
                {
                    //string rtf = txtSend.Rtf;
                    //Parallel.ForEach(matchs.OfType<Match>(), match =>
                    //{
                    //    string emoji_rtf = EmojiCodeDictionary.GetEmojiRtfByCode(match.Value);
                    //    if (!string.IsNullOrEmpty(emoji_rtf))
                    //    {
                    //        emoji_codes.Add(match.Value);
                    //        rtf = rtf.Replace(match.Value, emoji_rtf);
                    //    }
                    //});
                    //txtSend.Rtf = rtf;    
                    //

                    bool isParallel = false;
                    stopwatch.Restart();
                    string[] rtfs = txtSend.Rtf.Split(']');
                    Parallel.For(0, rtfs.Length, (index, loopState) =>
                    //Parallel.ForEach(rtfs.OfType<string>(), rtf =>
                    {
                        if (string.IsNullOrEmpty(rtfs[index]) || rtfs[index].IndexOf("[") < 0)
                            loopState.Break();
                        //匹配符合规则的表情code
                        MatchCollection matchs = Regex.Matches(rtfs[index] + "]", @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                        if (matchs.Count > 0)
                        {
                            string emoji_rtf = EmojiCodeDictionary.GetEmojiRtfByCode(matchs[0].Value);
                            if (!string.IsNullOrEmpty(emoji_rtf))
                            {
                                isParallel = true;
                                emoji_codes.Add(matchs[0].Value);
                                rtfs[index] = (rtfs[index] + "]").Replace(matchs[0].Value, emoji_rtf);
                            }

                        }
                    });

                    // 修改禅道#6891 还是会有问题
                    if (isParallel)
                    {
                        string new_rtf = string.Empty;
                        for (int i = 0; i < rtfs.Length; i++)
                        {
                            new_rtf += rtfs[i];
                        }
                        txtSend.Rtf = new_rtf;//rtf赋值
                    }

                    //List<string> replacedEmoji = new List<string>();      
                    //foreach (Match match in matchs)
                    //{
                    //    if (replacedEmoji.Contains(match.Value))
                    //        continue;

                    //    string emoji_rtf = EmojiCodeDictionary.GetEmojiRtfByCode(match.Value);
                    //    if (!string.IsNullOrEmpty(emoji_rtf))
                    //    {
                    //        if (!emoji_codes.Contains(match.Value))
                    //            emoji_codes.Add(match.Value);
                    //        txtSend.Rtf = txtSend.Rtf.Replace(match.Value, emoji_rtf);
                    //    }

                    //    replacedEmoji.Add(match.Value);
                    //}
                }
                catch (Exception ex)
                {
                    LogHelper.log.Error("----转化emoji出错，方法（txtSend_TextChanged） : " + ex.Message, ex);
                }
                txtSend.ResumeLayout();
                isChangingEmoji = false;
                stopwatch.Stop();
                //Console.WriteLine("输出时间：" + stopwatch.ElapsedMilliseconds + "ms");
                //}
            }
            #endregion
        }
        #endregion

        #region 给对方发送我正在输入的通知
        private void TxtSend_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (ChooseTarget.UserType > FriendType.USER_TYPE || ChooseTarget.IsGroup == 1)
                    return;
                ShiKuManager.SendInputMessage(ChooseTarget);
            }
        }
        #endregion

        #region 监控按键
        private void TxtSend_KeyUp(object sender, KeyEventArgs e)
        {
            //当Ctrl+V按太快，会导致e.Control == false
            if (e.KeyCode == Keys.V)
            {
                try
                {
                    if (e.Control)
                        LogHelper.log.Debug("KeyUp start => Ctrl+V");
                    //Console.WriteLine("KeyUp complate => Ctrl+V");
                    else
                        LogHelper.log.Debug("KeyUp start => V");
                    //Console.WriteLine("KeyUp complate => V");
                    if (!string.IsNullOrEmpty(paste_path))
                    {
                        //IDataObject IData = Clipboard.GetDataObject();
                        //if (IData.GetDataPresent(DataFormats.Bitmap))
                        //using (Image paste_image = Image.FromFile(paste_path))
                        //{
                        if (!BitmapUtils.IsNull(paste_image))
                        {
                            //Console.WriteLine("width: " + paste_image.Width);
                            //Console.WriteLine("height: " + paste_image.Height);
                            //恢复到初始
                            Clipboard.Clear();
                            Clipboard.SetDataObject(paste_image, true, 3, 200);//将图片放在剪贴板中
                            paste_path = string.Empty;
                        }
                        //}
                    }
                }
                catch (Exception ex) { LogHelper.log.Error("-----------粘贴图片到文本框时出错，txtSend_KeyUp：", ex); }
            }
            if (e.KeyData == Keys.Return)
            {
                BtnSend_Click(null, null);

                var textarray = txtSend.Text.ToArray();
                if (textarray.Length > 0 && 10 == textarray[textarray.Length - 1])
                {
                    txtSend.Clear();
                }

            }
        }

        private static string paste_path = "";      //用于短暂保存粘贴板的图片
        private static Image paste_image = null;      //用于短暂保存粘贴板的图片
        private void TxtSend_KeyDown(object sender, KeyEventArgs e)
        {

            //if (e.KeyData == Keys.Enter)
            //    btnSend_Click(null, null);
            //Ctrl+V
            if (e.Control && e.KeyCode == Keys.V)
            {
                try
                {
                    //stopwatch.Restart();
                    //检查是否黏贴文件
                    if (Clipboard.GetFileDropList().Count > 0)
                    {
                        var strCollection = Clipboard.GetFileDropList();
                        foreach (string item in strCollection)
                            fileCollect.Add(item);
                    }

                    IDataObject IData = Clipboard.GetDataObject();
                    if (IData.GetDataPresent(DataFormats.Bitmap))
                    {
                        //保存路径
                        string filePath = Applicate.LocalConfigData.ImageFolderPath + Guid.NewGuid().ToString("N") + ".png";
                        //获取黏贴板的图片
                        Image image = (Bitmap)IData.GetData(DataFormats.Bitmap);
                        paste_image = image;
                        paste_path = filePath;
                        int new_width = image.Width, new_height = image.Height;
                        EQControlManager.ModifyWidthAndHeight(ref new_width, ref new_height, 150, 150);
                        Image new_image = new Bitmap(image, new_width, new_height);

                        Clipboard.Clear();
                        Clipboard.SetDataObject(new_image, true, 3, 200);//将图片放在剪贴板中

                        //Task.Factory.StartNew(() =>
                        //{
                        image.MySave(filePath, ImageFormat.Png);
                        //获取截图的图片的RTF
                        using (RichTextBox richTextBox = new RichTextBox())
                        {
                            richTextBox.Paste();
                            string txt_rtf = richTextBox.Rtf;
                            string image_rtf = EQControlManager.subRtf(txt_rtf);
                            SrcImages.Add(filePath, image_rtf);
                            //Console.WriteLine("SrcImage_Count: " + SrcImages.Count);
                            //Console.WriteLine("filePath:" + filePath);
                        }
                        //});
                    }
                    if (IData.GetDataPresent(DataFormats.Rtf))
                    {
                        using (RichTextBox richTextBox = new RichTextBox())
                        {
                            richTextBox.Paste();
                            foreach (string emoji_code in EmojiCodeDictionary.GetEmojiDataNotMine().Keys)
                            {
                                string emoji_rtf = EmojiCodeDictionary.GetEmojiRtfByCode(emoji_code);
                                if (richTextBox.Rtf.IndexOf(emoji_rtf) >= 0)
                                {
                                    //不存在才添加
                                    if (emoji_codes.FindIndex(code => code.Equals("[" + emoji_code + "]")) < 0)
                                    {
                                        emoji_num++;
                                        emoji_codes.Add("[" + emoji_code + "]");
                                    }
                                }
                            }
                        }
                    }
                    //stopwatch.Stop();
                    //Console.WriteLine("输出时间：" + stopwatch.ElapsedMilliseconds + "ms");
                    LogHelper.log.Debug("KeyDown complate => Ctrl+V");
                    //Console.WriteLine("KeyDown complate => Ctrl+V");
                }
                catch (Exception ex) { LogHelper.log.Error("-----------粘贴数据到文本框时出错，txtSend_KeyDown：", ex); }
            }
        }
        #endregion

        private void TxtSend_DoubleClick(object sender, EventArgs e)
        {
            try
            {
                //只对图片的双击做处理
                if (txtSend.SelectedRtf.IndexOf("{\\pict") < 0)
                    return;

                Image image = null;
                string filePath = "";
                string image_rtf = EQControlManager.subRtf(txtSend.SelectedRtf);
                if (image_rtf.LastIndexOf("}\r\n") == image_rtf.Length - "}\r\n".Length)
                    image_rtf = image_rtf.Remove(image_rtf.LastIndexOf("}\r\n"));
                if (SrcImages.ContainsValue(image_rtf))
                {
                    var result = SrcImages.FirstOrDefault(d => d.Value.Equals(image_rtf));
                    if (result.Key != null && File.Exists(result.Key))
                    {
                        filePath = result.Key;
                        image = Image.FromFile(filePath);
                    }
                }
                //没有在字典中获得到图片
                if (image == null || BitmapUtils.IsNull(image))
                {
                    image = EQControlManager.RtfToImageSave(image_rtf);
                }

                if (image != null && !BitmapUtils.IsNull(image))
                {
                    //打开图片编辑器
                    FrmEditImage frmEditImage = new FrmEditImage()
                    {
                        Image = image,
                        filePath = filePath
                    };
                    frmEditImage.Show();
                    frmEditImage.action_ok = (img) =>
                    {
                        int new_width = img.Width, new_height = img.Height;
                        EQControlManager.ModifyWidthAndHeight(ref new_width, ref new_height, 150, 150);
                        Image new_image = new Bitmap(img, new_width, new_height);
                        string new_rtf = EQControlManager.ImageToRtf(new_image);
                        if (!string.IsNullOrEmpty(new_rtf))
                        {
                            txtSend.Rtf = txtSend.Rtf.Replace(image_rtf, new_rtf);
                            SrcImages.Add(frmEditImage.filePath, new_rtf);
                        }
                    };
                }
                else
                    LogHelper.log.Error("---------------双击弹出图片无法获取到图片：\r\n image: " + image);
            }
            catch (Exception ex) { LogHelper.log.Error("---------------双击弹出图片编辑窗出错：\r\n" + ex.Message); }
        }
        #endregion

        #region 按回执更新送达消息状态
        private void DrawIsSend(MessageObject msg)
        {
            MessageObject t_msg = msgTabAdapter.TargetMsgData.GetMsg(msg.messageId);
            //不属于自己的消息回执
            if (t_msg == null)
                return;
            t_msg.isSend = msg.isSend;
            if (t_msg == null || string.IsNullOrEmpty(t_msg.messageId))
                return;

            if (t_msg.fromUserId != Applicate.MyAccount.userId || ChooseTarget == null)
                return;

            //获得需要更新的控件
            EQBaseControl talk_panel = GetTalkPanelByMsg(t_msg.messageId);

            //是否存在该气泡消息和送达标识
            if (talk_panel == null || talk_panel.Controls["lab_msg"] == null)
                return;

            //群聊没有送达
            if (ChooseTarget.IsGroup == 1 && t_msg.isSend == 1)
            {
                if (this.IsHandleCreated)
                    Invoke(new Action(() =>
                    {
                        if (ChooseTarget.ShowRead == 1)
                            EQControlManager.DrawReadPerson(t_msg.readPersons, (Label)talk_panel.Controls["lab_msg"]);
                        else
                        {
                            var result = talk_panel.Controls.Find("lab_msg", true);
                            if (result.Length > 0 && result[0] is Label lab_msg)
                                lab_msg.Visible = false;
                        }
                    }));
                return;
            }
            //修改气泡的发送状态
            Action action = new Action(() =>
            {
                if (talk_panel.Controls["lab_msg"] != null)
                    EQControlManager.DrawIsSend(t_msg, (Label)talk_panel.Controls["lab_msg"]);
            });
            if (this.IsHandleCreated)
                Invoke(action);
        }
        #endregion

        #region 按回执更新已读消息状态
        private void DrawIsRead(MessageObject msg)
        {
            //获得需要更新的控件
            EQBaseControl talk_panel = GetTalkPanelByMsg(msg.messageId);

            //是否存在该气泡消息
            if (talk_panel == null || talk_panel.Controls["lab_msg"] == null)
                return;

            MessageObject t_msg = msgTabAdapter.TargetMsgData.GetMsg(msg.messageId);
            //是否为阅后即焚的已读通知
            int isReadDel = 0;
            if (t_msg != null)
                isReadDel = t_msg.isReadDel;
            if (isReadDel == 1)
                ReplaceMsgToRemind(msg.messageId, "对方查看了您的这条阅后即焚消息");
            else
            {
                if (talk_panel.Controls["lab_msg"] != null && talk_panel.Controls["lab_msg"] is Label lab_msg)
                {

                    //群需要开启群已读
                    if (ChooseTarget.IsGroup == 1)
                    {
                        if (this.IsHandleCreated)
                            Invoke(new Action(() =>
                            {
                                //显示群已读
                                if (ChooseTarget.ShowRead == 1)
                                {
                                    EQControlManager.DrawReadPerson(msg.readPersons, lab_msg);
                                }
                            }));
                    }
                    else
                    {
                        if (msg.fromUserId != Applicate.MyAccount.userId)
                            return;

                        Action action = new Action(() =>
                        {
                            EQControlManager.DrawIsRead(lab_msg);
                        });
                        if (this.IsHandleCreated)
                            Invoke(action);
                    }
                }
            }
        }
        #endregion

        #region 处理emoji表情
        private void AddEmojiToTxtSend(string emoji_code)
        {
            int selectionIndex = txtSend.SelectionStart;    //记录鼠标的当前光标
            ////获取表情字典
            //Dictionary<string, string> emojiData = EmojiCodeDictionary.GetEmojiCodeDataDictionary();
            ////获取emoji图并转为rtf
            //string emoji_rtf = GetEmoji(emoji_code, Color.White);
            ////截取emoji图片部分的rtf
            //emoji_rtf = subRtf(emoji_rtf);
            ////如果字典中不存在，则添加，用作后来的互转
            //if (!emojiData.ContainsKey(emoji_rtf))
            //    emojiData.Add(emoji_rtf, emoji_code);

            //创建一个副本
            //RichTextBox richSend = new RichTextBox();
            //richSend.Rtf = EmojiPngToCode(txtSend.Rtf);
            ////从光标处添加
            //richSend.SelectedText += emoji_code;
            //richSend.Rtf = GetEmoji(richSend.Text, Color.White);
            //txtSend.Rtf = richSend.Rtf;
            //richSend.Dispose();

            txtSend.SelectedText += emoji_code;
            //txtSend.Rtf = GetEmojiByRtf(txtSend.Rtf, Color.White);
            //txtSend.Rtf = txtSend.Rtf.Replace(emoji_code, EmojiCodeDictionary.GetEmojiRtfByCode(emoji_code));

            emoji_num++;
            //emoji_codes.Add(emoji_code);
            Helpers.ClearMemory();

            txtSend.SelectionStart = selectionIndex + 1;    //修改光标的位置
        }

        /// <summary>
        /// 根据传递的rtf转为code文本
        /// </summary>
        /// <param name="rtf"></param>
        /// <returns></returns>
        private string EmojiPngToCode(string rtf, List<string> emoji_codes)
        {
            ////获取表情字典
            //Dictionary<string, string> emojiData = EmojiCodeDictionary.GetEmojiCodeDataDictionary();

            ////创建一个副本
            //RichTextBox richSend = new RichTextBox();
            //richSend.Rtf = rtf;
            ////通过循环，把rtf图片替换为code
            //foreach (var key in emojiData.Keys)
            //{
            //    RichTextBox rich = new RichTextBox();
            //    rich.Text = emojiData[key];
            //    string replace = subRtf(rich.Rtf).Trim();
            //    richSend.Rtf = richSend.Rtf.Replace(key, replace);
            //    rich.Dispose();
            //}
            //string new_rtf = richSend.Rtf;
            //richSend.Dispose();

            string new_rtf = rtf;
            foreach (string emojiCode in emoji_codes)
            {
                //string code = "[" + emojiCode + "]";
                string code = emojiCode;
                string emojiRtf = EmojiCodeDictionary.GetEmojiRtfByCode(code);
                if (!string.IsNullOrWhiteSpace(emojiRtf))
                    new_rtf = new_rtf.Replace(emojiRtf, code);
            }
            return new_rtf;
        }

        private string SubRtf(string emoji_rtf)
        {
            //rtf1–> RTF版本
            //ansi–> 字符集
            //ansicpg936–> 简体中文
            //deff0–> 默认字体0
            //deflang1033–> 美国英语
            //deflangfe2052–> 中国汉语
            //fonttb–> 字体列表
            //f0->字体0
            //fcharset134->GB2312国标码
            //‘cb\’ce\’cc\’e5–> 宋体
            int startIndex = emoji_rtf.IndexOf("\\viewkind4\\uc1\\pard\\lang2052\\f0\\fs18") + "\\viewkind4\\uc1\\pard\\lang2052\\f0\\fs18".Length;
            emoji_rtf = emoji_rtf.Substring(startIndex);
            int endIndex = emoji_rtf.IndexOf("\\par");
            emoji_rtf = emoji_rtf.Substring(0, endIndex);
            return emoji_rtf;
        }

        #region StringToEmoji
        /// <summary>
        /// 传递含有emoji code的文本，返回转化为图片后的rtf字符串
        /// </summary>
        /// <param name="ric_text">含有emoji code的文本</param>
        /// <param name="bg_cloor">填充绘画底色的背景色</param>
        /// <returns></returns>
        private void GetEmoji(string ric_text, Color bg_cloor)
        {
            //RichTextBox richTextBox = new RichTextBox
            //{
            //    Text = ric_text
            //};
            ////匹配符合规则的表情code
            //MatchCollection match = Regex.Matches(richTextBox.Text, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            //string[] newStr = new string[match.Count];
            ////不用做记录的变量
            //int index = 0;
            //foreach (Match item in match)
            //{
            //    newStr[index] = item.Groups[0].Value;
            //    index++;
            //}

            ////循环替换code为表情图片
            //for (int i = 0; i < newStr.Length; i++)
            //{
            //    //获取表情code在RichTextBox的位置
            //    index = richTextBox.Text.IndexOf(newStr[i]);
            //    //表情code去除[]
            //    string image_name = newStr[i].Replace("[", "").Replace("]", "");
            //    //给剪切板设置图片对象
            //    string path = string.Format(@"Res\Emoji\{0}.png", image_name);
            //    if (!File.Exists(path))
            //        break;

            //    //获取RichTextBox控件中鼠标焦点的索引位置
            //    richTextBox.SelectionStart = index;
            //    //从鼠标焦点处开始选中几个字符
            //    richTextBox.SelectionLength = newStr[i].Length;
            //    //清空剪切板，防止里面之前有内容
            //    Clipboard.Clear();
            //    Bitmap bmp = new Bitmap(path);
            //    Bitmap newBmp = new Bitmap(25, 25);
            //    Graphics g = Graphics.FromImage(newBmp);
            //    //g.Clear(bg_cloor);

            //    //画圆形
            //    GraphicsPath gpath = new GraphicsPath();
            //    gpath.AddEllipse(0, 0, 25, 25);
            //    g.SmoothingMode = SmoothingMode.AntiAlias;
            //    g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            //    g.CompositingQuality = CompositingQuality.HighQuality;
            //    g.SetClip(gpath);

            //    g.DrawImage(bmp, new Rectangle(0, 0, 25, 25), new Rectangle(0, 0, bmp.Width, bmp.Height), GraphicsUnit.Pixel);
            //    g.Dispose();
            //    Clipboard.SetImage(newBmp);
            //    //将图片粘贴到鼠标焦点位置(选中的字符都会被图片覆盖)
            //    richTextBox.Paste();
            //    Clipboard.Clear();
            //}

            //string result = richTextBox.Rtf;
            //richTextBox.Dispose();
            //return result;
        }
        #endregion

        #region RtfToEmoji
        /// <summary>
        /// 传递含有emoji code的文本，返回转化为图片后的rtf字符串
        /// </summary>
        /// <param name="ric_text">含有emoji code的文本</param>
        /// <param name="bg_cloor">填充绘画底色的背景色</param>
        /// <returns></returns>
        //private string GetEmojiByRtf(string ric_rtf, Color bg_cloor)
        //{
        //    RichTextBox richTextBox = new RichTextBox
        //    {
        //        Rtf = ric_rtf
        //    };
        //    //匹配符合规则的表情code
        //    MatchCollection match = Regex.Matches(richTextBox.Text, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
        //    string[] newStr = new string[match.Count];
        //    //不用做记录的变量
        //    int index = 0;
        //    foreach (Match item in match)
        //    {
        //        newStr[index] = item.Groups[0].Value;
        //        index++;
        //    }

        //    //循环替换code为表情图片
        //    for (int i = 0; i < newStr.Length; i++)
        //    {
        //        //获取表情code在RichTextBox的位置
        //        index = richTextBox.Text.IndexOf(newStr[i]);
        //        //表情code去除[]
        //        string image_name = newStr[i].Replace("[", "").Replace("]", "");
        //        //给剪切板设置图片对象
        //        string path = string.Format(@"Res\Emoji\{0}.png", image_name);
        //        if (!File.Exists(path))
        //            break;

        //        //获取RichTextBox控件中鼠标焦点的索引位置
        //        richTextBox.SelectionStart = index;
        //        //从鼠标焦点处开始选中几个字符
        //        richTextBox.SelectionLength = newStr[i].Length;
        //        //清空剪切板，防止里面之前有内容
        //        Clipboard.Clear();
        //        Bitmap bmp = new Bitmap(path);
        //        Bitmap newBmp = new Bitmap(25, 25);
        //        Graphics g = Graphics.FromImage(newBmp);
        //        g.Clear(bg_cloor);

        //        g.InterpolationMode = InterpolationMode.HighQualityBicubic;

        //        g.DrawImage(bmp, new Rectangle(0, 0, 25, 25), new Rectangle(0, 0, bmp.Width, bmp.Height), GraphicsUnit.Pixel);
        //        g.Dispose();
        //        Clipboard.SetImage(newBmp);
        //        //将图片粘贴到鼠标焦点位置(选中的字符都会被图片覆盖)
        //        richTextBox.Paste();
        //        Clipboard.Clear();
        //    }

        //    string result = richTextBox.Rtf;
        //    richTextBox.Dispose();
        //    return result;
        //}
        #endregion
        #endregion

        #region Send File

        #region 上传文件
        private void UploadFileOrImage(string fileLocation, int fileSize)
        {
            try
            {
                MessageObject msg = null;
                if (JudgeIsImage(fileLocation))
                    msg = ShiKuManager.SendImageMessage(ChooseTarget, "", fileLocation, fileSize, false);
                else
                    msg = ShiKuManager.SendFileMessage(ChooseTarget, "", fileLocation, fileSize, false);
                //添加气泡
                JudgeMsgIsAddToPanel(msg);

                //获取气泡
                EQBaseControl talk_panel = GetTalkPanelByMsg(msg.messageId);
                if (talk_panel == null)
                    return;


                if (msg.type == kWCMessageType.File && talk_panel is EQFileControl fileControl)
                {
                    UploadEngine.Instance.From(fileLocation).
                    //上传中
                    UpProgress((progress) =>
                    {
                        fileControl.isDownloading = true;
                        //获取到文件的panel
                        if (talk_panel.Controls.Find("image_panel", true).Length > 0 && talk_panel.Controls.Find("image_panel", true)[0] is Panel image_panel)
                            if (image_panel.Controls.Find("crl_content", true).Length > 0 && image_panel.Controls.Find("crl_content", true)[0] is FilePanelLeft filePanel)
                            {
                                filePanel.lab_lineLime.BringToFront();
                                filePanel.lab_lineLime.Width = Convert.ToInt32(filePanel.lab_lineSilver.Width * ((decimal)progress / 100));
                                if ((progress / 100) == 1)
                                    filePanel.lab_lineLime.Width = 0;
                            }
                    }).
                    UpSpeed((speed) =>
                    {
                        //获取到文件的panel
                        if (talk_panel.Controls.Find("image_panel", true).Length > 0 && talk_panel.Controls.Find("image_panel", true)[0] is Panel image_panel)
                            if (image_panel.Controls.Find("crl_content", true).Length > 0 && image_panel.Controls.Find("crl_content", true)[0] is FilePanelLeft filePanel)
                            {
                                filePanel.lblSpeed.Visible = true;
                                filePanel.lblSpeed.BringToFront();
                                filePanel.lblSpeed.Text = speed + @"/s";
                            }
                    }).
                    //上传完成
                    UploadFile((success, url) =>
                    {
                        fileControl.isDownloading = false;
                        //获取到文件的panel
                        if (talk_panel.Controls.Find("image_panel", true).Length > 0 && talk_panel.Controls.Find("image_panel", true)[0] is Panel image_panel)
                            if (image_panel.Controls.Find("crl_content", true).Length > 0 && image_panel.Controls.Find("crl_content", true)[0] is FilePanelLeft filePanel)
                                //关闭下载速度
                                filePanel.lblSpeed.Visible = false;

                        msg.content = url;
                        msg.UpdateMessageContent();
                        if (success)
                        {
                            string localPath = Applicate.LocalConfigData.FileFolderPath + FileUtils.GetFileName(msg.fileName);
                            if (File.Exists(localPath))//如果对应文件存在 先删除文件(再下载文件)
                            {
                                try
                                {
                                    var r = new Random(Guid.NewGuid().GetHashCode());//产生不重复的随机数
                                    string filename = FileUtils.GetFileName(msg.fileName);
                                    string suffix = FileUtils.GetFileExtension(msg.fileName);//取出后缀
                                    string filename1 = filename.Replace(suffix, "") + "(" + r.Next(0, 1000) + ")" + suffix;//合成名称
                                    msg.fileName = Applicate.LocalConfigData.FileFolderPath + filename1;//重新赋值
                                    msg.UpdateFilename();
                                }
                                catch (Exception)
                                {

                                }
                            }
                            ShiKuManager.SendMessage(msg);
                        }

                    });
                }
                else if (msg.type == kWCMessageType.Image)
                {

                    UploadEngine.Instance.From(fileLocation).
                    //上传完成
                    UploadFile((success, url) =>
                    {
                        UploadImage(talk_panel, msg, url, success);
                    });
                }
            }
            catch (Exception ex)
            {
                LogHelper.log.Error("----上传文件出错，方法（UploadFileOrImage） : " + ex.Message, ex);
            }
        }
        #endregion

        #region 上传图片
        private void UploadImage(EQBaseControl talk_panel, MessageObject msg, string url, bool success)
        {
            #region 更新msg
            //上传失败
            if (string.IsNullOrEmpty(url) || !success)
            {
                msg.isSend = -1;
                msg.content = "error";
                msg.UpdateData();
            }
            else
            {
                msg.content = url;
                msg.UpdateMessageContent();
                ShiKuManager.SendMessage(msg);
            }
            #endregion

            #region 更新UI
            msg = msgTabAdapter.TargetMsgData.GetMsg(msg.messageId);
            if (msg == null)
                return;
            //修改气泡的图片和样式
            if (talk_panel is EQImageControl imageCrl)
            {
                if (imageCrl.Controls.Find("crl_content", true).Length > 0 && imageCrl.Controls.Find("crl_content", true)[0] is PictureBox pic_image)
                {
                    //上传失败
                    if (string.IsNullOrEmpty(url) || !success)
                    {
                        //关闭等待符
                        if (pic_image.Controls.Find("loding", true).Length > 0 && pic_image.Controls.Find("loding", true)[0] is USELoding loding)
                        {
                            loding.Dispose();
                            Helpers.ClearMemory();
                        }
                        var result = imageCrl.Controls.Find("lab_msg", false);
                        if (result.Length > 0 && result[0] is Label lab_msg)
                            EQControlManager.DrawIsSend(msg, lab_msg);
                    }
                    else
                    {
                        imageCrl.LoadImage(pic_image);
                    }
                }
            }
            #endregion
        }
        #endregion

        #region 上传视频
        private void UploadVideo(EQBaseControl talk_panel, MessageObject msg, string url, bool success)
        {
            #region 更新msg
            //上传失败
            if (string.IsNullOrEmpty(url) || !success)
            {
                msg.isSend = -1;
                msg.content = "error";
                msg.UpdateData();
            }
            else
            {
                msg.content = url;
                msg.UpdateMessageContent();
                ShiKuManager.SendMessage(msg);
            }
            #endregion

            #region 更新ui
            msg = msgTabAdapter.TargetMsgData.GetMsg(msg.messageId);
            if (msg != null)
            {
                //修改气泡的图片和样式
                if (talk_panel is EQVideoControl videoCrl)
                {
                    var video_result = videoCrl.Controls.Find("crl_content", true);
                    if (video_result.Length > 0 && video_result[0] is PictureBox pic_content)
                    {
                        //上传失败
                        if (string.IsNullOrEmpty(url) || !success)
                        {
                            var loding_result = pic_content.Controls.Find("loding", true);
                            //关闭等待符
                            if (loding_result.Length > 0 && loding_result[0] is USELoding loding)
                            {
                                loding.Dispose();
                                Helpers.ClearMemory();
                            }
                            var result = videoCrl.Controls.Find("lab_msg", false);
                            if (result.Length > 0 && result[0] is Label lab_msg)
                                EQControlManager.DrawIsSend(msg, lab_msg);
                        }
                        else
                        {
                            videoCrl.LoadVideo(pic_content);
                        }
                    }
                }
            }
            #endregion
        }
        #endregion

        #region 判断是否为图片
        private bool JudgeIsImage(string fileName)
        {
            try
            {

                if (!File.Exists(fileName))
                {
                    return false;
                }

                string extension = FileUtils.GetFileExtension(fileName);

                if (UIUtils.IsNull(extension))
                {
                    return false;
                }

                if (string.Equals(".jpg", extension.ToLower()))
                {
                    return true;
                }

                if (string.Equals(".gif", extension.ToLower()))
                {
                    return true;
                }

                if (string.Equals(".png", extension.ToLower()))
                {
                    return true;
                }

                if (string.Equals(".bmp", extension.ToLower()))
                {
                    return true;
                }

                return false;
            }
            catch (Exception ex)
            {
                LogHelper.log.Error("----JudgeIsImage : " + ex.Message, ex);
            }
            return false;
        }
        #endregion
        #endregion

        #region 右键菜单

        #region 获取选中控件的msg
        private MessageObject GetMsgBySelectCrl()
        {
            string messageId = selectControl.Name.Replace("talk_panel_", "");
            return msgTabAdapter.TargetMsgData.GetMsg(messageId);
        }
        #endregion

        #region 删除
        private void MenuItem_Delete_Click(object sender, EventArgs e)
        {
            if (selectControl.Name.IndexOf("talk_panel_") < 0)
                return;

            MessageObject msg = GetMsgBySelectCrl();
            if (msg == null)
                return;
            //获取最后一条消息
            MessageObject lastMsg = msgTabAdapter.TargetMsgData.GetLastIndexMsg();
            //从界面中移除
            msgTabAdapter.RemoveData(rowIndex);

            //调用接口删除
            bool isLastMsg = false;
            //如果是最后一条消息，需要通知最近聊天列表更新最后一条消息
            if (lastMsg != null && lastMsg.messageId == msg.messageId)
                isLastMsg = true;
            //调用接口从服务端删除
            CollectUtils.DelServerMessages(msg, isLastMsg);

            //滚动到底部
            RollBottom_HaveEmpty();

            //更新列表最后一条消息的时间
            //if (isLastMsg)
            //{
            //    int endIndex = msgTabAdapter.msgList.Count() - 1;
            //    lastMsg = msgTabAdapter.msgList[endIndex];
            //    lastMsgTime = lastMsg == null ? 0 : lastMsg.timeSend;
            //}
        }
        #endregion

        #region 撤回
        private void MenuItem_Recall_Click(object sender, EventArgs e)
        {
            if (selectControl == null || selectControl.Name.IndexOf("talk_panel_") < 0)
                return;

            MessageObject messageObject = GetMsgBySelectCrl();
            if (messageObject == null)
                return;

            // 判断我能否撤回这条消息

            // 我一定能撤回自己的消息  群聊我是管理可以随意撤回消息
            bool isOwnerRecall = ChooseTarget.IsGroup == 1 && JudgeIsAdmin(Applicate.MyAccount.userId);
            if (messageObject.IsMySend() || isOwnerRecall)
            {
                // 可以撤回

                //重新创建一个msg
                MessageObject msg = messageObject.CopyMessage();
                msg.type = kWCMessageType.Remind;
                msg.content = "你撤回了一条消息";

                if (IsHandleCreated)
                {
                    Invoke(new Action(() =>
                    {
                        //避免重复右键菜单，先更新UI
                        msgTabAdapter.TargetMsgData.UpdateMsg(msg);
                        int index = msgTabAdapter.msgList.FindIndex(m => m.messageId == msg.messageId);
                        xListView.RefreshItem(index);
                    }));
                }

                //调用接口
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "tigase/deleteMsg"). //删除消息
                    AddParams("access_token", Applicate.Access_Token).
                    AddParams("type", msg.isGroup == 0 ? "1" : "2").    //1 单聊  2 群聊
                    AddParams("delete", "2").   //1： 删除属于自己的消息记录 2：撤回 删除整条消息记录
                    AddParams("messageId", msg.messageId).
                    AddParams("roomJid", msg.toUserId).
                    Build().ExecuteJson<object>((sccess, obj) =>   //返回值说明： text：加密后的内容
                        {
                            //删除成功
                            if (sccess)
                            {
                                ShiKuManager.SendRecallMessage(msg.GetFriend(), msg);
                                HttpUtils.Instance.ShowTip("撤回成功");
                            }
                        });
            }


            ////重新创建一个msg
            //MessageObject copyMsg = messageObject.CopyMessage();
            //copyMsg.type = kWCMessageType.Remind;
            //copyMsg.content = "你撤回了一条消息";
            //RecallMsg(copyMsg, true);
            RollBottom_HaveEmpty();
        }

        private void RecallMsg(MessageObject msg, bool isSendRecall = false)
        {
            //该消息是否为当前聊天对象
            if (msg.GetFriend().UserId != ChooseTarget.UserId)
                return;
            if (msg.type == kWCMessageType.Withdraw)
            {
                Invoke(new Action(() =>
                {
                    msg.BubbleHeight = 0; msg.BubbleWidth = 0;
                    //避免重复右键菜单，先更新UI
                    msgTabAdapter.TargetMsgData.UpdateMsg(msg);
                    //var s = msgTabAdapter.msgList[rowIndex];
                    int index = msgTabAdapter.msgList.FindIndex(m => m.messageId == msg.messageId);
                    xListView.RefreshItem(index);
                    RollBottom_HaveEmpty();
                }));
                return;
            }

            if (IsHandleCreated)
            {
                Invoke(new Action(() =>
                {
                    msg.BubbleHeight = 0; msg.BubbleWidth = 0;
                    //避免重复右键菜单，先更新UI
                    msgTabAdapter.TargetMsgData.UpdateMsg(msg);
                    //var s = msgTabAdapter.msgList[rowIndex];
                    int index = msgTabAdapter.msgList.FindIndex(m => m.messageId == msg.messageId);
                    xListView.RefreshItem(index);
                    RollBottom_HaveEmpty();
                }));
            }

            //接收到通知代表别人已经发了
            if (isSendRecall)
            {
                //群主撤回消息
                bool isOwnerRecall = ChooseTarget.IsGroup == 1 && JudgeIsAdmin(Applicate.MyAccount.userId);
                //自己撤回的消息
                if (msg.fromUserId.Equals(Applicate.MyAccount.userId) || isOwnerRecall)
                {
                    //调用接口
                    HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "tigase/deleteMsg"). //删除消息
                        AddParams("access_token", Applicate.Access_Token).
                        AddParams("type", msg.isGroup == 0 ? "1" : "2").    //1 单聊  2 群聊
                        AddParams("delete", "2").   //1： 删除属于自己的消息记录 2：撤回 删除整条消息记录
                        AddParams("messageId", msg.messageId).
                        AddParams("roomJid", msg.toUserId).
                        Build().ExecuteJson<object>((sccess, obj) =>   //返回值说明： text：加密后的内容
                        {
                            //删除成功
                            if (sccess)
                            {
                                ShiKuManager.SendRecallMessage(msg.GetFriend(), msg);
                                //int result = messageObject.UpdateData();
                                HttpUtils.Instance.ShowTip("撤回成功");
                            }
                        });
                }
            }
        }
        #endregion

        #region 复制
        private void MenuItem_Copy_Click(object sender, EventArgs e)
        {
            if (selectControl == null || selectControl.Name.IndexOf("talk_panel_") < 0)
                return;

            MessageObject msg = GetMsgBySelectCrl();
            if (msg == null)
                return;
            switch (msg.type)
            {
                case kWCMessageType.Image:
                    //清空剪切板，防止里面之前有内容
                    Clipboard.Clear();
                    //给剪切板设置图片对象
                    PictureBox picBox = crl_content as PictureBox;
                    Image image = picBox.BackgroundImage;
                    string msgId = picBox.Tag != null ? picBox.Tag.ToString() : "";
                    if (!string.IsNullOrEmpty(msgId))
                    {
                        MessageObject image_msg = msgTabAdapter.TargetMsgData.GetMsg(msgId);
                        string fileName = FileUtils.GetFileName(image_msg.content);
                        string filePath = Applicate.LocalConfigData.ImageFolderPath + fileName;
                        //string filePath = Applicate.LocalConfigData.ImageFolderPath + msgId + ".png";

                        if (File.Exists(filePath))
                        {
                            image = Image.FromFile(filePath);
                        }
                    }
                    //Bitmap bitmap = new Bitmap(image);
                    Clipboard.SetImage(image);
                    break;
                case kWCMessageType.Text:
                    //清空剪切板，防止里面之前有内容
                    Clipboard.Clear();
                    //给剪切板设置图片对象
                    if (crl_content is RichTextBoxEx richTextBox)
                    {
                        string content = "";
                        if (string.IsNullOrEmpty(richTextBox.SelectedRtf))
                            content = richTextBox.Tag.ToString().Trim();
                        else
                        {
                            bool isOneself = msg.FromId.Equals(Applicate.MyAccount.userId);
                            string selected_rtf = richTextBox.SelectedRtf;
                            selected_rtf = selected_rtf.Replace("{\\*\\picprop}", "");
                            foreach (string item in EmojiCodeDictionary.GetEmojiDataIsMine().Keys)
                            {
                                string emoji_code = "[" + item + "]";
                                selected_rtf = selected_rtf.Replace(EmojiCodeDictionary.GetEmojiRtfByCode(item, isOneself), emoji_code);
                            }
                            using (RichTextBox ri = new RichTextBox())
                            {
                                ri.Rtf = selected_rtf;
                                content = ri.Text;
                            }
                        }
                        Clipboard.SetText(content);
                    }
                    break;
                case kWCMessageType.Replay:
                    //清空剪切板，防止里面之前有内容
                    Clipboard.Clear();
                    //给剪切板设置图片对象
                    //RichTextBox richTextBox = crl_content as RichTextBox;
                    //string content = richTextBox.Tag.ToString();
                    Clipboard.SetText(msg.content);
                    break;
                case kWCMessageType.File:
                    string localPath = Applicate.LocalConfigData.FileFolderPath + msg.fileName;
                    if (!File.Exists(localPath))
                        DownloadFile(msg, localPath, true);
                    else
                    {
                        StringCollection strcoll = new StringCollection
                        {
                            localPath
                        };
                        Clipboard.SetFileDropList(strcoll);
                    }
                    break;
                case kWCMessageType.Video:
                    string videoPath = Applicate.LocalConfigData.VideoFolderPath + FileUtils.GetFileName(msg.content);
                    if (!File.Exists(videoPath))
                    {
                        DownloadEngine.Instance.DownUrl(msg.content).Down((path) =>
                        {
                            StringCollection strcoll = new StringCollection();
                            strcoll.Add(path);
                            Clipboard.SetFileDropList(strcoll);
                        });
                    }
                    else
                    {
                        StringCollection strcoll = new StringCollection();
                        strcoll.Add(videoPath);
                        Clipboard.SetFileDropList(strcoll);
                    }
                    break;
                default:
                    break;
            }
        }
        #endregion

        #region 转发
        private void MenuItem_Relay_Click(object sender, EventArgs e)
        {
            //获取选择的Message
            if (selectControl == null || selectControl.Name.IndexOf("talk_panel_") < 0)
                return;
            MessageObject messageObject = GetMsgBySelectCrl();
            if (messageObject == null)
                return;

            //选择转发的好友
            var frmFriendSelect = new FrmSortSelect();
            frmFriendSelect.LoadFriendsData(true, true, true, true, true);
            frmFriendSelect.Show();
            frmFriendSelect.AddConfrmListener((UserFriends) =>
            {
                foreach (var friend in UserFriends.Values)
                {
                    if (friend.IsGroup == 1)
                    {
                        RoomMember roomMember = new RoomMember { roomId = friend.RoomId, userId = Applicate.MyAccount.userId };
                        roomMember = roomMember.GetRommMember();

                        if (roomMember.role == 3)
                        {
                            //是否全体禁言
                            string all = LocalDataUtils.GetStringData(friend.UserId + "BANNED_TALK_ALL" + Applicate.MyAccount.userId, "0");
                            //管理员和群主除外
                            if (!"0".Equals(all))
                            {
                                // 全体禁言
                                HttpUtils.Instance.ShowTip("不能转发消息到全体禁言群");
                                continue;
                            }

                            string single = LocalDataUtils.GetStringData(friend.UserId + "BANNED_TALK" + Applicate.MyAccount.userId, "0");
                            //是否单个禁言
                            if (!"0".Equals(single))
                            {
                                HttpUtils.Instance.ShowTip("您已被禁止在此群发言");
                                continue;
                            }
                        }
                    }


                    MessageObject msg = ShiKuManager.SendForwardMessage(friend, messageObject);
                    //如果转发对象包括当前聊天对象，给UI添加消息气泡
                    if (friend.UserId == ChooseTarget.UserId)
                    {
                        //添加消息气泡通知
                        JudgeMsgIsAddToPanel(msg);
                    }
                }
            });
        }
        #endregion

        #region 多选
        /// <summary>
        /// 开启多选
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void MenuItem_MultiSelect_Click(object sender, EventArgs e)
        {
            msgTabAdapter.TargetMsgData.isMultiSelect = true;
            foreach (Control crl in xListView.panel1.Controls)
            {
                foreach (Control item in crl.Controls)
                {
                    if (item is CheckBoxEx checkBox)
                    {
                        checkBox.Visible = true;
                        checkBox.Checked = false;
                    }
                    else if (item is EQBaseControl talk_panel && !talk_panel.isOneSelf)
                        talk_panel.Location = new Point(talk_panel.Location.X + 22, talk_panel.Location.Y);
                    else if (item is EQShowInfoPanelAlpha panelAlpha)
                    {
                        panelAlpha.Visible = true;
                        panelAlpha.BringToFront();
                    }
                }
            }
            ////清空之前被多选的集合
            multiSelectPanel.List_Msgs = new List<MessageObject>();
            multiSelectPanel.FdTalking = ChooseTarget;
            //展示多选
            IsShowPanelMultiSelect(true);
        }

        /// <summary>
        /// 展示多选面板
        /// </summary>
        /// <param name="visible"></param>
        private void IsShowPanelMultiSelect(bool visible)
        {
            this.SuspendLayout();
            try
            {
                panMultiSelect.Visible = visible;
                Bottom_Panel.Visible = !visible;
                if (visible == false)
                {
                    panMultiSelect.Dock = DockStyle.None;
                    Bottom_Panel.Dock = DockStyle.Bottom;
                    //multiSelectPanel.Visible = false;
                    panMultiSelect.SendToBack();
                }
                else
                {
                    panMultiSelect.Dock = DockStyle.Bottom;
                    Bottom_Panel.Dock = DockStyle.None;
                    //multiSelectPanel.Visible = true;
                    panMultiSelect.BringToFront();
                }
            }
            catch (Exception ex) { LogHelper.log.Error("-------------展示多选面板出错，方法（IsShowPanelMultiSelect）: \r\n" + ex.Message); }
            this.ResumeLayout();
        }

        #region 关闭多选面板
        private void LblClose_Click(object sender, EventArgs e)
        {
            msgTabAdapter.TargetMsgData.isMultiSelect = false;
            foreach (Control crl in xListView.panel1.Controls)
            {
                foreach (Control item in crl.Controls)
                {
                    if (item is CheckBoxEx checkBox)
                        checkBox.Visible = false;
                    else if (item is EQBaseControl talk_panel && !talk_panel.isOneSelf)
                        talk_panel.Location = new Point(talk_panel.Location.X - 22, talk_panel.Location.Y);
                }
                foreach (Control item in crl.Controls)
                    if (item is EQShowInfoPanelAlpha panelAlpha)
                    {
                        panelAlpha.Visible = false;
                        panelAlpha.SendToBack();
                        break;
                    }
            }
            IsShowPanelMultiSelect(false);
        }
        #endregion

        #region 批量删除
        private void BatchDeleteMsg(List<MessageObject> list_msgs)
        {
            if (list_msgs == null || list_msgs.Count < 1)
                return;

            xListView.panel1.SuspendLayout();
            try
            {
                MessageObject lastMsg = msgTabAdapter.TargetMsgData.GetLastIndexMsg();
                bool isLastMsg = false;     //记录是否含有最后一条消息在内
                foreach (MessageObject msg in list_msgs)
                {
                    //如果是最后一条消息，需要通知最近聊天列表更新最后一条消息
                    if (msg != null && lastMsg != null && lastMsg.rowIndex == msg.rowIndex)
                    {
                        isLastMsg = true;
                        lastMsgTime = msg.timeSend;     //更新列表最后一条消息的时间
                    }

                    //从界面中移除
                    int index = msgTabAdapter.msgList.FindIndex(m => m.messageId == msg.messageId);
                    msgTabAdapter.RemoveData(index);
                }
                //调用接口删除数据
                CollectUtils.DelServerMessages(list_msgs, isLastMsg);

                //滚动到底部
                RollBottom_HaveEmpty();
            }
            catch (Exception) { }
            xListView.panel1.ResumeLayout();
        }
        #endregion
        #endregion

        #region 收藏
        private void MenuItem_Collect_Click(object sender, EventArgs e)
        {
            //获取选择的Message
            if (selectControl == null || selectControl.Name.IndexOf("talk_panel_") < 0)
                return;
            string messageId = selectControl.Name.Replace("talk_panel_", "");
            MessageObject messageObject = msgTabAdapter.TargetMsgData.GetMsg(messageId);

            CollectUtils.CollectMessage(messageObject);
        }
        #endregion

        #region 回复
        private void MenuItem_Reply_Click(object sender, EventArgs e)
        {
            MessageObject msg = GetMsgBySelectCrl();
            replyPanel.lblContent.Text = EQControlManager.ChangeContentByType(msg);
            replyPanel.ReplyMsg = msg;
            replyPanel.Visible = true;
            replyPanel.BringToFront();
            //replyPanel.Visible = true;
        }
        #endregion

        #region 打开文件夹
        private void MenuItem_OpenFileFolder_Click(object sender, EventArgs e)
        {
            MessageObject msg = GetMsgBySelectCrl();
            string filePath = EQControlManager.GetFilePathByType(msg);
            //文件不存在
            if (!File.Exists(filePath))
            {
                HttpUtils.Instance.ShowTip("文件不存在");
                return;
            }
            System.Diagnostics.Process.Start("explorer.exe", "/select," + filePath);
        }
        #endregion

        #region 另存为
        private void MenuItem_SaveAs_Click(object sender, EventArgs e)
        {
            MessageObject msg = GetMsgBySelectCrl();
            //选择文件夹路径
            FolderBrowserDialog dialog = new FolderBrowserDialog
            {
                Description = "另存为.."
            };
            if (dialog.ShowDialog() == DialogResult.OK)
            {
                //文件的本地路径
                string localPath = dialog.SelectedPath;
                if (string.IsNullOrEmpty(localPath))
                    return;

                //下载文件
                if (msg.type == kWCMessageType.File)
                {
                    localPath += "\\" + FileUtils.GetFileName(msg.fileName);
                    DownloadFile(msg, localPath);
                }
                else
                {
                    localPath += "\\" + FileUtils.GetFileName(msg.content);
                    DownloadEngine.Instance.DownUrl(msg.content).SavePath(localPath)
                        .Down((path) =>
                        {
                            HttpUtils.Instance.ShowTip("下载完成：" + path);
                        });
                }
            }
        }
        #endregion

        #region 下载
        private void MenuItem_Dowmload_Click(object sender, EventArgs e)
        {
            MessageObject msg = GetMsgBySelectCrl();
            if (msg == null)
                return;
            if (msg.type == kWCMessageType.File)
            {
                //文件的本地路径
                string localPath = Applicate.LocalConfigData.FileFolderPath + FileUtils.GetFileName(msg.fileName);
                DownloadFile(msg, localPath);
            }
        }
        #endregion

        #region 存表情
        private void MenuItem_SaveCustomize_Click(object sender, EventArgs e)
        {
            MessageObject msg = GetMsgBySelectCrl();
            if (msg == null)
                return;
            // http收藏表情
            CollectUtils.CollectExpression(msg);
        }
        #endregion

        #region 录制
        private int isStartTrans = 0;       //是否开始录制
        private double startTransTime = 0;    //开始录制的时间
        private double endTransTime = 0;      //结束录制的时间
        private void MenuItem_Transcribe_Click(object sender, EventArgs e)
        {
            isStartTrans = isStartTrans == 1 ? 0 : 1;
            menuItem_Transcribe.Text = isStartTrans == 1 ? "停止录制" : "开始录制";

            //开始录制
            if (isStartTrans == 1)
            {
                MessageObject selectMsg = GetMsgBySelectCrl();
                startTransTime = selectMsg.timeSend;
            }
            //结束录制
            else
            {
                MessageObject selectMsg = GetMsgBySelectCrl();
                endTransTime = selectMsg.timeSend;
                FrmMyColleagueEidt frmMyColleagueEidt = new FrmMyColleagueEidt();

                frmMyColleagueEidt.ColleagueName((data) =>
                {
                    frmMyColleagueEidt.Close();
                    HttpUtils.Instance.PopView(frmMyColleagueEidt);
                    TeachUlUtils.CourseMade(data, startTransTime, endTransTime, msgTabAdapter.TargetMsgData);

                });

                frmMyColleagueEidt.ShowThis("课件录制", "课件名称");
            }
        }

        /// <summary>
        /// 取消录制
        /// </summary>
        private void ClearTranscribe()
        {
            isStartTrans = 0;
            startTransTime = 0;    //开始录制的时间
            endTransTime = 0;      //结束录制的时间
            menuItem_Transcribe.Text = "开始录制";
        }
        #endregion

        #region 鼠标右键菜单
        //不同的控件鼠标点击事件也不同
        private void Content_MouseDown(object sender, MouseEventArgs e)
        {
            crl_content = sender as Control;
            string crl_type = crl_content.GetType().Name;

            if (e.Button == MouseButtons.Right)
            {
                //记录被选中的控件
                selectControl = crl_content.Parent;
                while (true)
                {
                    if (selectControl.Name.IndexOf("talk_panel") > -1)
                        break;
                    else
                        selectControl = selectControl.Parent;
                }

                //如果是文件消息类型，下载中没有右键菜单
                if (selectControl is EQFileControl fileControl)
                {
                    if (fileControl.isDownloading)
                    {
                        foreach (ToolStripItem item in cmsMsgMenu.Items)
                            item.Visible = false;
                        return;
                    }
                }

                MessageObject msg = msgTabAdapter.TargetMsgData.GetMsg(selectControl.Name.Replace("talk_panel_", ""));
                //获得绑定数据的集合的索引
                rowIndex = msgTabAdapter.msgList.FindIndex(m => m == msg);
                //rowIndex = msg.rowIndex;    //记录被选中行
                //判断是否为本人
                bool isOneself = msg.fromUserId != Applicate.MyAccount.userId ? false : true;
                //设置右键菜单的可见度
                if (msg != null)
                    new KWTypeMenuStripDictionary().SettingMenuStripVisible(ref cmsMsgMenu, msg.type, isOneself, msg.isReadDel == 1);
                //如果自己为群主或管理员，则可以撤回所有信息
                if (ChooseTarget.IsGroup == 1 && JudgeIsAdmin(Applicate.MyAccount.userId))
                    cmsMsgMenu.Items["menuItem_Recall"].Visible = true;
                //除了阅后即焚，所有自己的消息都可以进行录制（只能往后录制）
                if (msg.fromUserId == Applicate.MyAccount.userId && msg.isReadDel == 0)
                {
                    if ((isStartTrans == 1 && startTransTime <= msg.timeSend) || isStartTrans == 0)
                    {
                        menuItem_Transcribe.Visible = true;
                        separator_one.Visible = true;
                    }
                }
                else
                {
                    menuItem_Transcribe.Visible = false;
                    separator_one.Visible = false;
                }
                //如果正在录音，则不能进行回复
                menuItem_Reply.Enabled = userSoundRecording.SoundState ? false : true;
                //如果文件不存在，则不显示打开文件夹，而是显示下载
                if (msg.type == kWCMessageType.File)
                {
                    string filePath = EQControlManager.GetFilePathByType(msg);
                    //文件不存在
                    if (!File.Exists(filePath))
                    {
                        menuItem_OpenFileFolder.Visible = false;
                        menuItem_Dowmload.Visible = true;
                    }
                    else
                    {
                        menuItem_OpenFileFolder.Visible = true;
                        menuItem_Dowmload.Visible = false;
                    }
                }
                cmsMsgMenu.RightToLeft = RightToLeft.No;
            }
        }
        #endregion

        #region 给所有子控件设置右键菜单事件
        private void AddContentMouseDownToCrl(Control crl)
        {
            foreach (Control child_crl in crl.Controls)
            {
                child_crl.MouseDown += Content_MouseDown;
                child_crl.ContextMenuStrip = cmsMsgMenu;
                if (child_crl.Controls.Count > 0)
                    AddContentMouseDownToCrl(child_crl);
            }
        }
        #endregion
        #endregion

        #region 鼠标悬浮文本提醒
        private void LblHistory_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblHistory, "聊天记录");//设置提示按钮和提示内容
        }

        private void LblLocation_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblLocation, "发送位置");//设置提示按钮和提示内容
        }

        private void LblScreen_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblScreen, "截图");//设置提示按钮和提示内容
        }

        private void LblSendFile_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblSendFile, "发送文件");//设置提示按钮和提示内容
        }

        private void LblExpression_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblExpression, "表情");//设置提示按钮和提示内容
        }

        private void LblSoundRecord_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblSoundRecord, "录音");//设置提示按钮和提示内容
        }

        private void LblCamera_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblCamera, "拍照");//设置提示按钮和提示内容
        }

        private void LblPhotography_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblPhotography, "录像");//设置提示按钮和提示内容
        }

        private void LblAudio_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblAudio, "语音聊天");//设置提示按钮和提示内容
        }

        private void LblVideo_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblVideo, "视频聊天");//设置提示按钮和提示内容
        }
        #endregion

        #region Set Title
        #region 显示正在输入
        private void IsShowTyping()
        {
            if (this.IsHandleCreated)
            {
                Invoke(new Action(() =>
                {
                    labName.Text = "对方正在输入...";
                }));
            }

            Task.Factory.StartNew(() =>
            {
                Thread.Sleep(15000);
                Invoke(new Action(() =>
                {
                    labName.Text = labName.Text.Replace("对方正在输入...", "");
                }));
            });

        }
        #endregion

        #region 收到通知修改聊天对象名字
        private void ModifyFriendName(Friend friend)
        {
            string newName = friend.GetRemarkName();
            //单聊并且为当前聊天对象
            if (friend.UserId == ChooseTarget.UserId && friend.IsGroup == 0)
            {
                labName.Text = newName;
                //是否在线
                SetOnlineState();
            }
            //修改字典
            if (Applicate.FdNames.ContainsKey(friend.UserId))
                Applicate.FdNames[friend.UserId] = newName;
        }
        #endregion
        #endregion

        #region Upload File

        #region 重新上传图片
        private void ResumeUploadImageMsg(MessageObject msg)
        {
            string filePath = msg.fileName;
            if (!File.Exists(filePath))
                return;

            UploadEngine.Instance.From(filePath).
                //上传中
                UpProgress((progress) =>
                {

                }).
                //上传完成
                UploadFile((success, url) =>
                {
                    msg = msgTabAdapter.TargetMsgData.GetMsg(msg.messageId);
                    EQBaseControl talk_panel = GetTalkPanelByMsg(msg.messageId);
                    //更新UI
                    if (talk_panel != null && talk_panel is EQImageControl imageCrl)
                        UploadImage(imageCrl, msg, url, success);
                });
        }
        #endregion

        #region 重新上传视频
        private void ResumeUploadVideoMsg(MessageObject msg)
        {
            string filePath = msg.fileName;
            if (!File.Exists(filePath))
                return;

            UploadEngine.Instance.From(filePath).
                //上传完成
                UploadFile((success, url) =>
                {
                    msg = msgTabAdapter.TargetMsgData.GetMsg(msg.messageId);
                    EQBaseControl talk_panel = GetTalkPanelByMsg(msg.messageId);
                    //更新UI
                    if (talk_panel != null && talk_panel is EQVideoControl videoCrl)
                        UploadVideo(videoCrl, msg, url, success);
                });
        }
        #endregion
        #endregion

        #region 获取身份
        #region 判断是否为群主或者管理员
        private bool JudgeIsAdmin(string userId)
        {
            if (ChooseTarget.IsGroup == 1)
            {
                int role = new RoomMember() { roomId = ChooseTarget.RoomId, userId = userId }.GetRoleByUserId();
                if (role == 1 || role == 2)
                    return true;
            }
            return false;
        }
        #endregion

        #region 判断是否为群主
        private bool JudgeIsGroupOwner(string userId)
        {
            if (ChooseTarget.IsGroup == 1)
            {
                int role = new RoomMember() { roomId = ChooseTarget.RoomId, userId = userId }.GetRoleByUserId();
                if (role == 1)
                    return true;
            }
            return false;
        }
        #endregion

        #region 判断是否为隐身人
        private bool JudgeIsUnseen(string userId)
        {
            if (ChooseTarget.IsGroup == 1)
            {
                int role = new RoomMember() { roomId = ChooseTarget.RoomId, userId = userId }.GetRoleByUserId();
                if (role == 4)
                    return true;
            }
            return false;
        }
        #endregion

        #endregion

        #region 判断是否添加气泡到列表
        private void JudgeMsgIsAddToPanel(MessageObject msg)
        {
            #region 过滤消息
            if (ChooseTarget == null || msg == null || string.IsNullOrEmpty(msg.messageId))
                return;
            //正在输入。。通知
            if (msg.type == kWCMessageType.Typing)
            {
                if (msg.fromUserId == ChooseTarget.UserId)
                    IsShowTyping();
                return;
            }
            //不生成气泡的消息类型
            if (!msg.IsVisibleMsg() && msg.type != kWCMessageType.RoomIsVerify)
                return;
            //已存在该气泡控件
            if (xListView.panel1.Controls["talk_panel_" + msg.messageId] != null)
                return;
            //content为空的消息不显示
            if (string.IsNullOrEmpty(msg.content))
            {
                switch (msg.type)
                {
                    case kWCMessageType.Text:
                        msg.content = " ";
                        break;
                    case kWCMessageType.Image:
                        break;
                    case kWCMessageType.File:
                        break;
                    case kWCMessageType.Video:
                        break;
                    case kWCMessageType.Voice:
                        break;
                    default:
                        return;
                }
            }

            #region 判断消息是否为当前聊天对象的
            //多点登录的FromId也是自己，需要判断ToId是否为当前对象
            if (msg.FromId == Applicate.MyAccount.userId)
            {
                if (msg.ToId != ChooseTarget.UserId)
                    return;
            }
            //FromId和ToId必须是自己和当前聊天对象，FromId或者ToId为自己时，另一个必定为聊天对象
            else if (msg.FromId == ChooseTarget.UserId)
            {
                if (msg.ToId != Applicate.MyAccount.userId)
                    return;
            }
            //FromId既不是自己也不是聊天对象，该消息必定不为该聊天页面
            else
                return;
            #endregion

            //过期消息
            if (msg.deleteTime < TimeUtils.CurrentTimeDouble() && msg.deleteTime > 0)
            {
                msg.DeleteData();
                return;
            }
            #endregion

            //获取滚动条的位置
            int progress = xListView.Progress;
            //是否在底部
            //if (progress == 100 || xListView.Height >= xListView.panel1.Height)
            //    isInsert = true;
            bool isInsert = JudgeIsInsert(msg);
            if (this.IsHandleCreated)
                Invoke(new Action(() =>
                {
                    try
                    {
                        //添加消息气泡
                        msgTabAdapter.TargetMsgData.AddMsgData(msg);
                        int index = msgTabAdapter.msgList.FindIndex(m => m.messageId == msg.messageId);
                        //msgTabAdapter.msgList.Insert(end, msg);
                        xListView.InsertItem(index, isInsert);
                        //更新未读数量

                        if (msgTabAdapter.msgList.Count > 2)
                            LastReadMsgId = string.IsNullOrEmpty(LastReadMsgId) ? msgTabAdapter.msgList[msgTabAdapter.msgList.Count - 2].messageId : LastReadMsgId;

                        //如果是自己发送的消息，或者当前滚动到了底部，则调用滚动到底部的方法
                        if (msg.fromUserId == Applicate.MyAccount.userId || progress == 100)
                        {
                            UnReadMsgNum = 0;
                            int end = msgTabAdapter.msgList.Count - 1;
                            //bool isFillCrl = Applicate.GetWindow<FrmMain>().WindowState != FormWindowState.Minimized;
                            xListView.ShowRangeEnd(end, 0, true);
                        }
                        //显示未读消息数量
                        else
                        {
                            UnReadMsgNum++;
                            if (UnReadMsgNum > 0 && !string.IsNullOrEmpty(LastReadMsgId))
                            {
                                unReadNumPanel.IsShowPanel(LastReadMsgId, UnReadMsgNum, true, false);
                            }
                        }
                        //如果数据已经加载了400条，继续滚动会超过最大值
                        if (msgTabAdapter.msgList.Count > 300)
                        {
                            ////如果第一行是显示更多聊天记录
                            //if (msgTabAdapter.FirstMsgIndex > 0)
                            //{
                            //    msgTabAdapter.msgList[0].content = "更多消息请在消息记录中查阅";
                            //    xListView.RefreshItem(0);
                            //}

                            ////清除一部分数据
                            //ClearTopMsg();

                            //重新加载数据
                            AfreshBindData();
                        }
                    }
                    catch (Exception ex)
                    {
                        LogHelper.log.Error("----添加气泡出错，方法（JudgeMsgIsAddToPanel） : " + ex.Message, ex);
                    }
                }));
        }
        #endregion

        private bool JudgeIsInsert(MessageObject msg)
        {
            if (xListView.Height >= xListView.panel1.Height)
                return true;

            //1.判断消息是否是对方发送的
            //2.判断滚动条的位置决定是否在底部
            //3.位置不在底部返回false，默认为true
            int progress = xListView.Progress;      //获取滚动条的位置
            if (!msg.IsMySend())
            {
                if (progress != 100 && Math.Abs(xListView.panel1.Location.Y) != xListView.panel1.Height - xListView.Height)
                    return false;
            }
            return true;
        }

        #region 所有需要调用接口的方法

        #region 下载文件
        private void DownloadFile(MessageObject msg, string localPath, bool isCopy = false)
        {
            var result = selectControl.Controls.Find("image_panel", true);
            if (result.Length > 0 && result[0] is Panel image_panel)
            {
                result = image_panel.Controls.Find("panel_file", true);
                if (image_panel.Controls[0] is FilePanelLeft panel_file)
                {
                    #region download file
                    //正在下载
                    if (panel_file.lab_lineLime.Width > 0)
                        return;

                    //开始下载
                    panel_file.isDownloading = true;
                    //下载文件
                    DownloadEngine.Instance.DownUrl(msg.content)
                    .DownProgress((progress) =>
                    {
                        panel_file.lab_lineLime.BringToFront();
                        panel_file.lab_lineLime.Width = Convert.ToInt32(panel_file.lab_lineSilver.Width * ((decimal)progress / 100));
                        if ((progress / 100) == 1)
                            panel_file.lab_lineLime.Width = 0;
                    }).
                    DownSpeed((speed) =>
                    {
                        panel_file.lblSpeed.Visible = true;
                        panel_file.lblSpeed.BringToFront();
                        panel_file.lblSpeed.Text = speed + @"/s";
                    })
                    .SavePath(localPath)    //保存路径
                    .Down((path) =>
                    {
                        panel_file.lblSpeed.Visible = false;
                        //下载完成
                        panel_file.isDownloading = false;

                        if (string.IsNullOrEmpty(path))
                            return;

                        if (isCopy)
                        {
                            StringCollection strcoll = new StringCollection
                            {
                                localPath
                            };
                            Clipboard.SetFileDropList(strcoll);
                        }

                        HttpUtils.Instance.ShowTip("下载完成：" + path);
                    });
                    #endregion
                }
            }
        }
        #endregion

        #region 获取群设置并设置群人数和群公告
        private int userSize = 0;
        private void GetRoomSetting()
        {
            if (ChooseTarget.UserType > FriendType.USER_TYPE || ChooseTarget.Status != 2 || ChooseTarget == null)
                return;

            //防止因为接口异步导致名称不对
            string name = ChooseTarget.NickName;
            //避免切换聊天对象
            string userId = ChooseTarget.UserId;
            //http get请求获得数据
            HttpUtils.Instance.InitHttp(this);
            //将数据保存
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/getRoom") //获取群详情
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("roomId", ChooseTarget.RoomId)
                .Build()
                .BindTag(ChooseTarget.UserId + "roomget")
                .Execute((success, result) =>
                {

                    Friend choose_fd = new Friend() { UserId = userId }.GetFdByUserId();
                    if (ChooseTarget == null || choose_fd.IsGroup == 0 || !choose_fd.UserId.Equals(ChooseTarget.UserId) || choose_fd.IsDismiss == 1)
                        return;


                    if (success && choose_fd != null)
                    {
                        string requestUserId = UIUtils.DecodeString(result, "jid");
                        if (ChooseTarget == null || !requestUserId.Equals(ChooseTarget.UserId))
                        {
                            return;
                        }

                        Thread getRoom_thread = new Thread(() =>
                        {
                            userSize = UIUtils.DecodeInt(result, "userSize");

                            // 修改禅道bug5138
                            int showread = choose_fd.ShowRead;
                            choose_fd.TransToMember(result);
                            if (showread != choose_fd.ShowRead)
                            {
                                choose_fd.UpdateShowRead();

                                if (msgTabAdapter.msgList != null && choose_fd.ShowRead == 1)
                                {
                                    foreach (var item in msgTabAdapter.msgList)
                                    {
                                        ShiKuManager.SendReadMessage(choose_fd, item);
                                    }
                                }
                            }

                            // 更新对象的属性值
                            //Applicate.FriendObj = choose_target;

                            //是否显示群公告
                            //bool isShowNotice = LocalDataUtils.GetBoolData(choose_fd.UserId + "show_notice");
                            string json_notice = UIUtils.DecodeString(result, "notice");

                            if (IsHandleCreated)
                                Invoke(new Action(() =>
                                {
                                    if (ChooseTarget == null || choose_fd.IsGroup == 0 || !choose_fd.UserId.Equals(ChooseTarget.UserId) || choose_fd.IsDismiss == 1)
                                        return;
                                    #region 更新UI
                                    //标题（群名称+人数）
                                    labName.Text = name + "（" + UIUtils.DecodeString(result, "userSize") + "人）";
                                    if (Applicate.ENABLE_MEET && Applicate.CURRET_VERSION > 4.0f)
                                    {
                                        //关闭群会议，普通成员不允许点击视频和音频
                                        lblAudio.Visible = choose_fd.AllowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true;
                                        lblVideo.Visible = choose_fd.AllowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true;

                                    }
                                    else
                                    {
                                        lblAudio.Visible = false;
                                        lblVideo.Visible = false;
                                    }

                                    if (!UIUtils.IsNull(json_notice))
                                    {
                                        //按条件判断是否展示群公告
                                        //Dictionary<string, object> noticeinfo = JsonConvert.DeserializeObject<Dictionary<string, object>>(json_notice);
                                        //if (noticeinfo.ContainsKey("text"))
                                        //if (/*isShowNotice &&*/ !string.IsNullOrEmpty(json_notice))
                                        ShowNotice(json_notice);
                                    }

                                    #region 是否需要刷新群禁言状态（避免先更新了UI，接口才回调）
                                    string remindTxt = "";
                                    //如果需要禁言且UI没有禁言
                                    if (Bottom_Panel.Controls["lblRemind"] == null && JudgeIsBannedTalk(ref remindTxt))
                                    {
                                        SetBannedTalk();
                                    }
                                    #endregion
                                    #endregion
                                }));
                        })
                        {
                            IsBackground = true
                        };
                        getRoom_thread.Start();
                    }
                    else
                    {
                        new Friend() { UserId = userId }.SetDismiss();
                        string remindTxt = "群信息无法获取";
                        IsShow_BannedTalkPanel(true, remindTxt);
                    }
                });
        }
        #endregion

        #region 获取好友是否在线
        private void SetOnlineState()
        {
            if (!isOpenOnlineStatus)
                return;

            if (ChooseTarget.IsDevice())
            {
                bool isOnline = MultiDeviceManager.Instance.IsDeviceLine(ChooseTarget.UserId);
                string userName = ChooseTarget.GetRemarkName();
                labName.Text = userName + (isOnline ? "（在线）" : "（离线）");
                return;
            }

            string userId = ChooseTarget.UserId;
            if (userId.Length > 5 && userId.Length < 12)
            {
                //http get请求获得数据
                HttpUtils.Instance.InitHttp(this);
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/getOnLine") //获取群详情
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("userId", userId)
                    .Build()
                    .BindTag(ChooseTarget.UserId)
                    .Execute((success, result) =>
                    {
                        if (success && userId.Equals(ChooseTarget.UserId))
                        {
                            string userName = ChooseTarget.GetRemarkName();
                            //在线
                            if (result["data"].ToString().Equals("1"))
                                labName.Text = userName + "（在线）";
                            else
                                labName.Text = userName + "（离线）";
                        }
                    });
            }
        }
        #endregion

        #region 请求接口单向清除聊天记录
        public void ClearServerFriendMsg(string toUserid)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "tigase/emptyMyMsg")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("type", "1")
                .AddParams("toUesrId", toUserid)
                .Build().Execute(null);
        }
        #endregion

        #endregion

        #region 禁言
        /// <summary>
        /// 判断是否禁言
        /// </summary>
        /// <returns>返回true则为禁言状态</returns>
        private bool JudgeIsBannedTalk(ref string remindTxt)
        {
            if (ChooseTarget.IsGroup != 1)
                return false;
            if (string.IsNullOrEmpty(ChooseTarget.UserId))
            {
                remindTxt = "聊天对象为空";
                return true;
            }
            //是否全体禁言
            string all = LocalDataUtils.GetStringData(ChooseTarget.UserId + "BANNED_TALK_ALL" + Applicate.MyAccount.userId, "0");
            //管理员和群主除外
            if (!"0".Equals(all) && !JudgeIsAdmin(Applicate.MyAccount.userId))
            {
                // 全体禁言
                remindTxt = "本群已进行全体禁言";
                return true;
            }

            string single = LocalDataUtils.GetStringData(ChooseTarget.UserId + "BANNED_TALK" + Applicate.MyAccount.userId, "0");
            //是否单个禁言
            if (!"0".Equals(single) && !JudgeIsGroupOwner(Applicate.MyAccount.userId))
            {
                double time = double.Parse(single);
                if (time > TimeUtils.CurrentTimeDouble())
                {
                    remindTxt = "禁言时间至：" + time.StampToDatetime().ToString("yyyy-MM-dd HH:mm:ss");
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        ///1.不是隐身人，逻辑往下走
        ///<para>2.是隐身人，已经设置了隐身人禁言，跳出禁言</para>
        ///<para>3.是隐身人，但是还未设置隐身人禁言，逻辑往下走（isShow: true）</para>
        ///<para>4.解除隐身人（逻辑往下走）：</para>
        ///<para>a.当前用户被禁言——更新禁言的文本（isShow: true）</para>
        ///<para>b.当前用户未被禁言——移除禁言（isShow: false）</para>
        /// </summary>
        /// <param name="isShow">是否显示</param>
        /// <param name="remindTxt">提示文本内容</param>
        /// <param name="isUnseen">是否为隐身人</param>
        private void IsShow_BannedTalkPanel(bool isShow, string remindTxt = "", bool isUnseen = false)
        {
            //当通知触发时，需要回到主线程
            Action action = new Action(() =>
            {
                if (isUnseen && Bottom_Panel.Controls["lblRemind"] != null && Bottom_Panel.Controls["lblRemind"] is Label lblUnseen)
                {
                    if (lblUnseen.Text.IndexOf("隐身") > -1)
                        return;
                }

                if (isShow)
                {
                    //隐藏发送按钮
                    btnSend.Visible = false;
                    txtSend.Visible = false;
                    txtSend.Clear();

                    if (Bottom_Panel.Controls["lblRemind"] != null && Bottom_Panel.Controls["lblRemind"] is Label lbl)
                    {
                        lbl.Text = remindTxt;
                        int location_x = (Bottom_Panel.Width - lbl.Width) / 2;
                        int location_y = (Bottom_Panel.Height - lbl.Height) / 2;
                        lbl.Location = new Point(location_x, location_y);
                    }
                    else
                    {
                        //文字提醒
                        Label lblRemind = new Label
                        {
                            Name = "lblRemind",
                            AutoSize = true,
                            Font = new Font(Applicate.SetFont, 10f),
                            Text = remindTxt,
                            //lblRemind.Size = new Size(200, 23);
                            ForeColor = Color.FromArgb(157, 157, 157),
                            Anchor = AnchorStyles.None
                        };
                        Bottom_Panel.Controls.Add(lblRemind);
                        lblRemind.Focus();
                        int location_x = (Bottom_Panel.Width - lblRemind.Width) / 2;
                        int location_y = (Bottom_Panel.Height - lblRemind.Height) / 2;
                        lblRemind.Location = new Point(location_x, location_y);
                    }

                    SetControlEnabled(this.Bottom_Panel, false);
                }
                else
                {
                    //恢复发送按钮
                    btnSend.Visible = true;
                    txtSend.Visible = true;
                    if (Bottom_Panel.Controls["lblRemind"] != null && Bottom_Panel.Controls["lblRemind"] is Label lblRemind)
                    {
                        txtSend.Controls.Remove(lblRemind);
                        lblRemind.Dispose();
                    }
                    SetControlEnabled(this.Bottom_Panel, true);
                }
            });
            if (this.IsHandleCreated)
                Invoke(action);
        }

        private void UpdateBannedTalk(MessageObject msg)
        {
            if (!msg.objectId.Equals(ChooseTarget.UserId))
                return;

            //判断是否为隐身人
            bool isUnseen = JudgeIsUnseen(Applicate.MyAccount.userId);

            //当前是否为禁言
            string remindTxt = "";
            bool isBannedTalk = false;
            if (isUnseen)
                return;

            else
                isBannedTalk = JudgeIsBannedTalk(ref remindTxt);
            if (isBannedTalk)
                txtSend.Clear();
            IsShow_BannedTalkPanel(isBannedTalk, remindTxt, isUnseen);
        }
        #endregion

        #region 显示公告
        private void ShowNotice(string json_notice = "")
        {
            roomNotice.RoomData = ChooseTarget;
            roomNotice.LoadData(json_notice);
            Dictionary<string, object> noticeinfo = JsonConvert.DeserializeObject<Dictionary<string, object>>(json_notice);
            if (noticeinfo.ContainsKey("text"))
            {
                roomNotice.Visible = true;
                roomNotice.BringToFront();
            }
            else
            {
                roomNotice.Visible = false;
            }

        }
        #endregion

        #region 控制是否显示新消息标识
        private void IsShowUnReadNumPanel(int readNum, string msgId)
        {
            bool isShow = false;    //是否显示新消息标识

            //没有新消息直接不显示
            if (readNum > 0 && !string.IsNullOrEmpty(msgId))
            {
                List<MessageObject> msgList = msgTabAdapter.msgList;
                //int dataCount = msgTabAdapter.TargetMsgData.GetMessageModelDataDictionary().Count;
                //if (dataCount > 0 && msgTabAdapter.msgList[0].type == kWCMessageType.labMoreMsg)
                //    dataCount--;
                //1.如果列表当前的msg数量小于未读数量，显示
                //if (readNum > msgList.Count)
                //    isShow = true;
                ////2.如果未读行数的总高度大于可显示区域，显示
                //else
                //{
                float totalHeight = 0;
                int listViewHeight = xListView.Height;
                if (listViewHeight == 0)
                    isShow = false;
                else
                {
                    int msgIndex = msgList.FindIndex(m => m.messageId == msgId);
                    if (msgIndex > -1)
                        for (int index = msgIndex; index < msgList.Count; index++)
                        {
                            totalHeight += msgTabAdapter.OnMeasureHeight(index);
                            if (totalHeight > listViewHeight)
                            {
                                isShow = true;
                                break;
                            }
                        }
                }
                //}
            }
            unReadNumPanel.IsShowPanel(msgId, readNum, isShow);
        }
        #endregion

        #region 显示@浮标
        private void AtMeShowPanel(Friend room)
        {
            if (ChooseTarget == null || ChooseTarget.IsGroup != 1 || room.UserId != ChooseTarget.UserId)
            {
                AtMePanel.SendToBack();
                return;
            }

            if (room.IsAtMe == 0)
            {
                AtMePanel.SendToBack();
                return;
            }
            else
            {
                room.UpdateAtMeState(0);
                room.IsAtMe = 0;
                Messenger.Default.Send(room, MessageActions.UPDATE_FRIEND_LAST_CONTENT);//通知界面刷新
            }


            bool isup = true;    //方向
            //获取收到@的messageId
            string messageid = LocalDataUtils.GetStringData(room.UserId + "GROUP_AT_MESSAGEID" + Applicate.MyAccount.userId);
            MessageObject msg = msgTabAdapter.TargetMsgData.GetMsg(messageid);
            if (msg != null)
            {
                //如果@的消息在显示的范围内，则不显示
                int total_height = 0;
                int at_index = msgTabAdapter.msgList.FindIndex(m => m.messageId.Equals(messageid));
                for (int index = at_index; index < msgTabAdapter.msgList.Count; index++)
                {
                    total_height += xListView.GetItemHeight(index);
                    if (total_height > xListView.Height)
                        break;
                }
                if (total_height <= xListView.Height)
                {
                    //清空At
                    LocalDataUtils.SetStringData(room.UserId + "GROUP_AT_MESSAGEID" + Applicate.MyAccount.userId, "");
                    return;
                }

                AtMePanel.Changedata(room, isup);
                AtMePanel.BringToFront();
            }
        }
        #endregion

        #region 自己主动@人的通知
        private void AddAtUserToTxtSend(MessageObject at_msg)
        {
            //不是当前聊天对象的通知
            if (!at_msg.objectId.Equals(ChooseTarget.UserId))
                return;

            //当前为禁言状态
            if (txtSend.Controls["lblRemind"] != null)
                return;

            atCount++;
            Friend friend = new Friend()
            {
                UserId = at_msg.fromUserId,
                NickName = at_msg.fromUserName,
                IsGroup = 0
            };
            list_atFriends.Add(friend);

            txtSend.SelectedText += at_msg.content;
        }
        #endregion

        #region 更新设备的状态
        private void UpdateDeviceState(string userId)
        {
            if (ChooseTarget == null || ChooseTarget.UserType != FriendType.DEVICE_TYPE || !isOpenOnlineStatus)
                return;

            //修改在线状态
            bool isOnline = MultiDeviceManager.Instance.IsDeviceLine(ChooseTarget.UserId);
            labName.Text = ChooseTarget.NickName/* + (isOnline ? "（在线）" : "（离线）")*/;
        }
        #endregion

        #region 记录阅后即焚的时间
        private void SaveReadDelTime()
        {
            if (isHaveReadDel == 0)
                return;

            foreach (var msg in msgTabAdapter.TargetMsgData.GetMsgList())
            {
                //阅后即焚消息
                if (msg.isReadDel == 1 && msg.ReadDelTime > 0)
                {
                    //记录当前的秒数
                    LocalDataUtils.SetIntData(Applicate.MyAccount.userId + "_ReadDelTime_" + msg.messageId, msg.ReadDelTime);
                    //msg.isReadDel = 0;
                }
            }
        }
        #endregion

        private EQBaseControl GetTalkPanelByMsg(string msgId)
        {
            string name = "panel_" + msgId;
            Control panel = xListView.panel1.Controls[name];
            if (panel == null)
                return null;

            var result = panel.Controls.Find("talk_panel_" + msgId, true);
            if (result.Length > 0 && result[0] is EQBaseControl talk_panel)
                return talk_panel;

            return null;
        }

        #region 工具栏

        #region 选择表情
        private FrmExpressionTab frmExpressionTab;      //表情列表窗口
        private void LblExpression_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            //获取鼠标点击表情时的坐标
            Point ms = Control.MousePosition;
            frmExpressionTab = FrmExpressionTab.GetExpressionTab();
            //修改列表索引
            frmExpressionTab.tabExpression.SelectedIndex = 0;
            //设置弹出窗起始坐标
            int location_x = ms.X - e.X - 8;
            int location_y = ms.Y - frmExpressionTab.Height - e.Y - 5;
            frmExpressionTab.Location = new Point(location_x, location_y);
            //传递对象给新窗口
            frmExpressionTab.SetFriendTarget(ChooseTarget);
            //控件显示在最上层
            frmExpressionTab.TopMost = true;
            frmExpressionTab.Show();

            //回调
            frmExpressionTab.expressionAction = (type, code) =>
            {
                switch (type)
                {
                    //选择了emoji表情
                    case ExpressionType.Emoji:
                        AddEmojiToTxtSend(code);
                        break;
                }
            };
        }
        #endregion

        #region 选择文件并发送
        private void LblSendFile_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            OpenFileDialog dialog = new OpenFileDialog
            {
                Multiselect = true,//该值确定是否可以选择多个文件
                Title = "请选择文件夹",
                Filter = "所有文件 (*.*)|*.*" +
                "|图像 (*.jpg;*.jpeg;*.png)|*.jpg;*.jpeg;*.png" +
                "|视频 (*.avi;*.mp4;*.rmvb;*.flv)|*.avi;*.mp4;*.rmvb;*.flv"
            };

            //完成选择图片的操作
            if (dialog.ShowDialog() == DialogResult.OK)
            {
                foreach (string file in dialog.FileNames)
                {
                    FileStream fsRead = new FileStream(file, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
                    Clipboard.SetDataObject(fsRead, true, 3, 500);

                    bool isVideo = FileUtils.JudgeIsVideoFile(file);
                    //如果为视频文件
                    if (isVideo)
                    {
                        //先生成气泡
                        int fileSize = Convert.ToInt32(new FileInfo(file).Length);
                        MessageObject msg = ShiKuManager.SendVideoMessage(ChooseTarget, file, file, fileSize, false);
                        msg.isLoading = 1;
                        JudgeMsgIsAddToPanel(msg);

                        //获取气泡
                        EQBaseControl talk_panel = GetTalkPanelByMsg(msg.messageId);
                        if (talk_panel != null)
                        {
                            UploadEngine.Instance.From(file).
                            //上传中

                            //上传完成
                            UploadFile((success, url) =>
                            {
                                UploadVideo(talk_panel, msg, url, success);
                            });
                        }
                    }
                    else
                        UploadFileOrImage(file, Convert.ToInt32(new FileInfo(file).Length));   //上传图片
                }
                dialog.Dispose();
            }
        }
        #endregion

        #region 截图
        private void LblScreen_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                CaptureImageTool capture = new CaptureImageTool();

                // capture.SelectCursor = CursorManager.ArrowNew;
                //  capture.DrawCursor = CursorManager.CrossNew;

                if (capture.ShowDialog() == DialogResult.OK)
                {
                    bool txt_readOnly = txtSend.ReadOnly;
                    txtSend.ReadOnly = false;
                    int new_width = capture.Image.Width, new_height = capture.Image.Height;
                    EQControlManager.ModifyWidthAndHeight(ref new_width, ref new_height, 150, 150);
                    Image new_image = new Bitmap(capture.Image, new_width, new_height);

                    Clipboard.Clear();
                    Clipboard.SetImage(new_image);
                    //将图片粘贴到鼠标焦点位置(选中的字符都会被图片覆盖)
                    txtSend.Paste();
                    txtSend.ReadOnly = txt_readOnly;

                    //获取截图的图片的RTF
                    using (RichTextBox richTextBox = new RichTextBox())
                    {
                        if (SrcImages == null)
                        {
                            SrcImages = new Dictionary<string, string>();
                        }
                        richTextBox.Paste();
                        string txt_rtf = richTextBox.Rtf;
                        string image_rtf = EQControlManager.subRtf(txt_rtf);
                        SrcImages.Add(capture.FilePath, image_rtf);
                    }

                    //恢复到初始
                    Clipboard.Clear();
                    Clipboard.SetImage(capture.Image);
                    capture.Image.Dispose();
                }

                if (!Visible)
                {
                    Show();
                }
            }
        }
        #endregion

        #region 历史聊天记录
        private void LblHistory_MoseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            FrmHistoryChat frmHistoryChat = FrmHistoryChat.CreateInstrance();
            frmHistoryChat.ShowFriendMsg(ChooseTarget);
            frmHistoryChat.Show();
        }
        #endregion

        #region 选择并发送定位
        private void LblLocation_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;


            //Console.WriteLine("" + ShiKuManager.GetXmppState());
            if (ShiKuManager.GetXmppState() != SocketConnectionState.Authenticated)
            {
                HttpUtils.Instance.ShowTip("网络异常，不能定位");
                return;
            }

            FrmSedLocation frmSedLocation = FrmSedLocation.CreateInstrance();
            frmSedLocation.initCefSharp(ChooseTarget);
            //frmSedLocation.Show();
        }
        #endregion

        #region 录音
        private void LblSoundRecord_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            //正在录音
            if (userSoundRecording.SoundState)
                return;
            //判断是否正在回复消息
            if (replyPanel.ReplyMsg != null && !string.IsNullOrEmpty(replyPanel.ReplyMsg.messageId))
            {
                var result = HttpUtils.Instance.ShowPromptBox("当前正在回复消息\r\n是否取消回复开启录音");
                if (result)
                {
                    //清空并隐藏恢复面板
                    replyPanel.ReplyMsg = new MessageObject();
                    replyPanel.SendToBack();
                }
                else
                    return;
            }
            //开启录音功能
            if (userSoundRecording.IsCanSoundRecord())
            {
                ShowSoundRecord();
            }
            else
            {
                userSoundRecording.SendToBack();
                HttpUtils.Instance.ShowTip("未发现录音设备");
                //MessageBox.Show("未发现录音设备", "警告");
            }
        }

        private void ShowSoundRecord()
        {
            userSoundRecording.Visible = true;
            //replyPanel.Visible = false;
            userSoundRecording.BringToFront();
        }
        #endregion

        #region 拍照
        private void LblCamera_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            FrmTakePhoto takephoto = FrmTakePhoto.GetInstance();
            if (takephoto.iscontentpoto())
            {
                takephoto.ConnectPhoto();
                takephoto.Show();
                //点击发送的回调
                takephoto.takeimage = (image, localPath) =>
                {
                    if (string.IsNullOrEmpty(localPath) || !File.Exists(localPath))
                        return;
                    //添加气泡到列表
                    MessageObject msg = ShiKuManager.SendImageMessage(ChooseTarget, "", localPath, Convert.ToInt32(new FileInfo(localPath).Length), false);
                    JudgeMsgIsAddToPanel(msg);

                    UploadEngine.Instance.From(localPath).
                        //上传完成
                        UploadFile((success, url_path) =>
                        {
                            msg = msgTabAdapter.TargetMsgData.GetMsg(msg.messageId);
                            if (msgTabAdapter.TargetMsgData.GetMsg(msg.messageId) != null)
                            {
                                //修改气泡的图片和样式
                                EQBaseControl talk_panel = GetTalkPanelByMsg(msg.messageId);
                                if (talk_panel != null && talk_panel is EQImageControl imageCrl)
                                {
                                    UploadImage(imageCrl, msg, url_path, success);
                                }
                            }
                        });
                };
            }
            else
            {
                HttpUtils.Instance.ShowTip("未发现拍照设备");
                //MessageBox.Show("未发现拍照设备", "警告");
                return;
            }
        }
        #endregion

        #region 录像
        private void LblPhotography_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            FrmTakeVideo frmTakeVideo = FrmTakeVideo.GetInstance();
            if (frmTakeVideo.iscontentpoto())
            {
                frmTakeVideo.ConnectPhoto();
                frmTakeVideo.Show();
                frmTakeVideo.videoInfo = (localPath) =>
                {
                    //文件不存在
                    if (!File.Exists(localPath))
                        return;

                    //先生成气泡
                    int fileSize = Convert.ToInt32(new FileInfo(localPath).Length);
                    MessageObject msg = ShiKuManager.SendVideoMessage(ChooseTarget, localPath, localPath, fileSize, false);
                    JudgeMsgIsAddToPanel(msg);

                    //获取气泡
                    EQBaseControl talk_panel = GetTalkPanelByMsg(msg.messageId);
                    if (talk_panel != null)
                    {
                        UploadEngine.Instance.From(localPath).
                        //上传完成
                        UploadFile((success, url) =>
                        {
                            UploadVideo(talk_panel, msg, url, success);
                        });
                    }
                };
            }
            else
                HttpUtils.Instance.ShowTip("未发现拍照设备");
        }
        #endregion

        #region 快捷回复
        private void Lbl_qreply_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            FrmReplay frmReplay = new FrmReplay();
            frmReplay.loadData(e);
            frmReplay.Sometimetext = (text) =>
            {
                txtSend.Clear();
                txtSend.Text = text;
                frmReplay.Close();
            };
        }
        #endregion

        #region 发起语音聊天
        private void LblAudio_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            //单聊
            if (ChooseTarget.IsGroup == 0 && Applicate.IsOpenFrom)
                ShiKuManager.SendAskMeetMessage(ChooseTarget, false);
            //群聊
            else
            {
                if (!Applicate.IsOpenFrom)
                    return;

                //选择转发的好友
                var frmFriendSelect = new FrmFriendSelect();
                frmFriendSelect.LoadFriendsData(ChooseTarget);
                frmFriendSelect.AddConfrmListener((UserFriends) =>
                {
                    if (UserFriends.Values.Count < 0)
                        return;
                    List<Friend> toFriends = new List<Friend>();
                    foreach (var friend in UserFriends.Values)
                        toFriends.Add(friend);
                    ShiKuManager.SendGroupAudioMeetMsg(toFriends, ChooseTarget.RoomId, ChooseTarget.UserId);
                });
            }
        }
        #endregion

        #region 发起视频聊天
        private void LblVideo_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            //单聊
            if (ChooseTarget.IsGroup == 0 && Applicate.IsOpenFrom)
                ShiKuManager.SendAskMeetMessage(ChooseTarget, true);
            //群聊
            else
            {
                if (!Applicate.IsOpenFrom)
                    return;

                //选择转发的好友
                var frmFriendSelect = new FrmFriendSelect();
                frmFriendSelect.LoadFriendsData(ChooseTarget);
                frmFriendSelect.AddConfrmListener((UserFriends) =>
                {
                    if (UserFriends.Values.Count < 0)
                        return;
                    List<Friend> toFriends = new List<Friend>();
                    foreach (var friend in UserFriends.Values)
                        toFriends.Add(friend);
                    ShiKuManager.SendGroupVideoMeetMsg(toFriends, ChooseTarget.RoomId, ChooseTarget.UserId);
                });
            }
        }
        #endregion

        #endregion

        #region 点击弹出设置页
        FrmSuspension frmSet;   //设置页
        private void Lab_detial_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;

            if (string.IsNullOrEmpty(ChooseTarget.UserId))
                return;

            //如果聊天对象为群组
            if (ChooseTarget.IsGroup == 1)
            {
                frmSet = new FrmSMPGroupSet() { room = ChooseTarget };
                //frmSet = FrmSMPGroupSet.GetFrmSMPGroupSet();
                //FrmSMPGroupSet.GetFrmSMPGroupSet().room = choose_target;
            }
            else
            {
                frmSet = new FrmSingleSet() { friend = ChooseTarget };
                //frmSet = FrmSingleSet.GetFrmSingleSet();
                //FrmSingleSet.GetFrmSingleSet().friend = choose_target;
            }
            //获取三个点控件相对屏幕的位置
            Point point = PointToScreen(xListView.Location);
            point = new Point(point.X + (xListView.Width - frmSet.Width), point.Y);

            frmSet.StartPosition = FormStartPosition.Manual;
            frmSet.Location = point;
            frmSet.Height = this.Height - panTitle.Height - 1;
            frmSet.Show(this.Parent);
        }

        private void LabName_MouseClick(object sender, MouseEventArgs e)
        {
            Lab_detial_MouseClick(lab_detial, e);
        }
        #endregion

        #region 显示或隐藏群已读人数
        private void IsShowReadPersons(bool isShow)
        {
            var msg_list = msgTabAdapter.msgList;
            foreach (MessageObject msg in msg_list)
            {
                EQBaseControl talk_panel = GetTalkPanelByMsg(msg.messageId);
                if (talk_panel == null)
                    continue;
                //显示已读人数标识
                var crls = talk_panel.Controls.Find("lab_msg", true);
                if (crls.Length > 0 && crls[0] is Label lab_msg)
                    if (this.IsHandleCreated)
                    {
                        Invoke(new Action(() =>
                        {
                            if (lab_msg.Tag != null)
                            {
                                int status = 0;
                                try
                                {
                                    status = Convert.ToInt32(lab_msg.Tag.ToString().Substring(lab_msg.Tag.ToString().IndexOf("_") + 1));
                                }
                                catch (Exception ex) { LogHelper.log.Error("-------------显示或隐藏群已读人数出错，方法（IsShowReadPersons）: \r\n" + ex.Message); }
                                finally
                                {
                                    if (status != msg.isSend)
                                        EQControlManager.DrawReadPerson(msg.readPersons, lab_msg);
                                }

                            }
                            lab_msg.Visible = isShow;
                        }));

                        if (isShow)
                        {
                            //红点下移
                            crls = talk_panel.Controls.Find("lab_redPoint", true);
                            if (crls.Length > 0 && crls[0] is Label lab_redPoint)
                                Invoke(new Action(() =>
                                {
                                    if (lab_redPoint.Location.Y < 40)
                                        lab_redPoint.Location = new Point(lab_redPoint.Location.X, 40);
                                }));
                        }
                    }
            }
        }
        #endregion

        #region 如果底部有空白滚动到底部

        public void RollBottom_HaveEmpty()
        {
            // 1.如果相等代表已经在底部
            // 2.如果panel1小于列表高度，则不滚动
            if ((Math.Abs(xListView.panel1.Location.Y) + xListView.Height) != xListView.panel1.Height
                && xListView.Height < xListView.panel1.Height
                && msgTabAdapter.msgList.Count() > 1)
                xListView.ShowRangeEnd(msgTabAdapter.msgList.Count() - 1, 0, true);
        }
        #endregion

        #region 文本发送框的右键菜单
        #region 粘贴
        private void MenuItem_paste_Click(object sender, EventArgs e)
        {
            IDataObject IData = Clipboard.GetDataObject();
            if (IData.GetDataPresent(DataFormats.Bitmap))
            {
                //保存路径
                string filePath = Applicate.LocalConfigData.ImageFolderPath + Guid.NewGuid().ToString("N") + ".png";
                //获取黏贴板的图片
                Image image = (Bitmap)IData.GetData(DataFormats.Bitmap);
                if (BitmapUtils.IsNull(image))
                    return;
                int new_width = image.Width, new_height = image.Height;
                EQControlManager.ModifyWidthAndHeight(ref new_width, ref new_height, 150, 150);
                Image new_image = new Bitmap(image, new_width, new_height);
                image.MySave(filePath, ImageFormat.Png); ;

                Clipboard.Clear();
                Clipboard.SetImage(new_image);
                txtSend.Paste();
                if (SrcImages == null)
                {
                    SrcImages = new Dictionary<string, string>();
                }
                //获取截图的图片的RTF
                using (RichTextBox richTextBox = new RichTextBox())
                {

                    richTextBox.Paste();
                    string txt_rtf = richTextBox.Rtf;
                    string image_rtf = EQControlManager.subRtf(txt_rtf);
                    SrcImages.Add(filePath, image_rtf);
                }

                //恢复到初始
                Clipboard.Clear();
                Clipboard.SetImage(image);
                image.Dispose();
                return;
            }

            //检查是否黏贴文件
            if (Clipboard.GetFileDropList().Count > 0)
            {
                var strCollection = Clipboard.GetFileDropList();
                foreach (string item in strCollection)
                    fileCollect.Add(item);
            }
            txtSend.Paste();
        }
        #endregion
        #endregion

        private void LabName_TextChanged(object sender, EventArgs e)
        {
            EQControlManager.StrAddEllipsis(labName, labName.Font, this.Width - 80);
        }

        private void SetBannedTalk()
        {
            //判断是否为隐身人
            bool isUnseen = JudgeIsUnseen(Applicate.MyAccount.userId);

            //当前是否为禁言
            string remindTxt = "";
            bool isBannedTalk = false;
            if (isUnseen)
            {
                isBannedTalk = true;
                remindTxt = "您当前为隐身人状态";
            }
            else
                isBannedTalk = JudgeIsBannedTalk(ref remindTxt);
            if (isBannedTalk)
                IsShow_BannedTalkPanel(isBannedTalk, remindTxt, isUnseen);
        }

        #region 漫游
        public void OnShowLoading()
        {
            //显示等待符
            StartLoding(xListView, "正在下载漫游消息...");
            isDownloadRoaming = true;
        }

        #region 加载消息记录
        public void OnDownRecord(List<MessageObject> data)
        {
            xListView.SuspendLayout();
            try
            {
                //销毁等待符
                loding.stop();
                //结束漫游
                isDownloadRoaming = false;
                //如果既不存在更多的本地消息，也没有漫游记录可以拉取
                //if (msgTabAdapter.msgList[0].type != kWCMessageType.labMoreMsg && !CanAddMoreRoaming)
                //    return;

                ////List<MessageObject> msg_list = DownRoamAndLoadLocalMsg();   
                List<MessageObject> msg_list = data;//获取本地数据
                if (msg_list == null || msg_list.Count == 0)
                    msgTabAdapter.NotCanAddMoreMsg();
                if (msg_list != null && msg_list.Count > 0)
                {
                    //批量加载
                    msgTabAdapter.BindData(msg_list);
                    int index = msgTabAdapter.FirstMsgIndex;
                    xListView.InsertRange(index);

                    // 修改禅道bug#7359
                    bool ismore = msg_list[0].type == kWCMessageType.labMoreMsg;

                    //添加lable，显示更多聊天记录
                    if (msgTabAdapter.msgList.Count >= MsgTabAdapter.row_insert || ismore)
                        msgTabAdapter.CanAddMoreMsg();
                }
                //第一次添加集合是切换聊天对象时，所以需要滚动到底部
                if (isFirstLoad)
                {
                    isFirstLoad = false;
                    RollBottom_HaveEmpty();
                }
            }
            catch (Exception ex) { LogHelper.log.Error("-------------加载消息记录出错，方法（OnDownRecord）: \r\n" + ex.Message); }
            xListView.ResumeLayout();
        }
        #endregion

        public void LoadMsg()
        {
            //如果数据已经加载了400条，继续滚动会超过最大值
            if (msgTabAdapter.msgList.Count > 400)
            {
                //如果第一行是显示更多聊天记录
                if (msgTabAdapter.FirstMsgIndex > 0 && !msgTabAdapter.msgList[0].content.Equals("更多消息请在消息记录中查阅"))
                {
                    msgTabAdapter.msgList[0].content = "更多消息请在消息记录中查阅";
                    xListView.RefreshItem(0);
                }
                return;
            }

            if (isDownloadRoaming)
                return;
            isDownloadRoaming = true;
            //msgTabAdapter.AddMoreMsg();
            MessageObject msg = msgTabAdapter.TargetMsgData.GetFirstIndexMsg();
            page_index++;

            //获取时间
            double timeSend = msg == null ? 0 : msg.timeSend;
            msgRecord.LoadMsgDatas(ChooseTarget, page_index, timeSend);
        }
        #endregion

        /// <summary>
        /// 清除过多的消息气泡并进行位移
        /// </summary>
        private void ClearTopMsg()
        {
            int start_index = msgTabAdapter.FirstMsgIndex;
            int msg_count = msgTabAdapter.msgList.Count;
            if (msg_count < 1 || msg_count < 100)
                return;

            int clear_count = msg_count - 50;
            //清除数据
            for (int index = start_index; index < clear_count + start_index; index++)
            {
                string remove_msgId = msgTabAdapter.msgList[start_index].messageId;
                msgTabAdapter.TargetMsgData.RemoveMsgData(remove_msgId);
            }

            xListView.DeleteRange(start_index, clear_count);
        }

        private void AfreshBindData()
        {
            try
            {
                var current_target = ChatTargetDictionary.GetMsgData(ChooseTarget.UserId);
                //清除数据
                if (current_target != null && current_target.GetMsgList().Count > 0)
                    current_target.RemoveAllData();
                BubbleBgDictionary.RemoveAllBg();       //移除所有缓存的背景图

                //清空聊天列表并绑定新的数据
                msgTabAdapter.direction = false;        //倒序排列
                msgTabAdapter.choose_target = ChooseTarget;
                //保存是否为独立聊天
                msgTabAdapter.TargetMsgData.isSeparateChat = this.isSeparateChat;
                page_index = 1;         //漫游页数重置
                isFirstLoad = true;     //能够触发滚动到底部
                msgRecord.LoadMsgDatas(ChooseTarget, page_index, 0);
                //List<MessageObject> msgList = msgTabAdapter.LoadObjectLocalMsg();   //获取本地数据
                //msgTabAdapter.BindData(msgList);        //绑定数据源
                xListView.SetAdapter(msgTabAdapter);    //绑定适配器

                Helpers.ClearMemory();
            }
            catch (Exception ex)
            {
                LogHelper.log.Error("----重新绑定数据出错，方法（AfreshBindData） : " + ex.Message, ex);
            }
        }

        #region 当前聊天对象已删除
        private void DeleteFdCloseFrm(Friend friend)
        {
            if (friend.UserId.Equals(ChooseTarget.UserId) && isSeparateChat == 1)
            {
                if (this.Parent is FrmNewTable frmNewTable)
                {
                    //获取用户
                    Friend targetFd = ChooseTarget;
                    //获取当前对象的字典
                    var targetData = ChatTargetDictionary.GetMsgData(targetFd.UserId);
                    //移除数据和对象
                    targetData.RemoveAllData();
                    ChatTargetDictionary.RemoveItem(targetFd.UserId);

                    frmNewTable.Close();
                }
            }
        }
        #endregion
        private void updateCustomer(string isopen)
        {
            if (isopen.Equals("1"))
            {
                lbl_qreply.Visible = true;
                btnEnding.Visible = true;
            }
            else
            {
                lbl_qreply.Visible = false;
                btnEnding.Visible = false;
            }
        }
        /// <summary>
        /// 客服模式下结束会话
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnEnding_Click(object sender, EventArgs e)
        {
            MessageObject msg = ShiKuManager.GetMessageObject(ChooseTarget);
            msg.type = kWCMessageType.CustomerEndConnnect;
            msg.content = "结束会话";
            msg.isEncrypt = 0;
            msg.isReadDel = 0;
            ShiKuManager.SendMessage(msg);
        }

        private void LblLive_MouseClick(object sender, MouseEventArgs e)
        {
            FrmLiveStreaming frmLiveStreaming = FrmLiveStreaming.GetInstance();
            if (frmLiveStreaming.iscontentpoto())
            {
                frmLiveStreaming.ConnectPhoto();
                frmLiveStreaming.Show();
            }
        }

        private void ShowMsgPanel_SizeChanged(object sender, EventArgs e)
        {
            if (xListView.Width != this.Width && this.Width > this.MinimumSize.Width)
            {
                xListView.Location = new Point(0, 35);
                Size changedSize = new Size(this.Width, this.Height - panTitle.Height - Bottom_Panel.Height - 1);
                xListView.Size = changedSize;
            }
        }
    }
}
