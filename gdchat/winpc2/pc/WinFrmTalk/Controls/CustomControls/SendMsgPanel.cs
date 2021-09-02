using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Helper;
using WinFrmTalk.Helper.MVVM;
using WinFrmTalk.Model;
using WinFrmTalk.Properties;
using WinFrmTalk.View;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class SendMsgPanel : UserControl
    {
        #region 双缓冲
        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.ExStyle |= 0x02000000;
                return cp;
            }
        }
        #endregion

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

        private int isHaveReadDel = 0;      //本次聊天列表是否含有阅后即焚消息
        private bool isHaveMoreLocalMsg = true;        //本地数据库是否有更多聊天记录
        private FrmExpressionTab frmExpressionTab;      //表情列表窗口
        private Friend _choose_target;
        //选择的联系人
        public Friend choose_target
        {
            get { if (_choose_target == null) return new Friend(); else return _choose_target; }
            set => _choose_target = value;
        }
        private int emoji_num = 0;      //当前文本框有多少个emoji表情
        private List<string> emoji_codes = new List<string>();   //记录文本框中的emojiCode
        private const int row_insert = 20;     //更多聊天记录，一次加载多少行
        private int PAGE_INDEX = 1;     //当前的消息列表页数
        Control crl_content = null;         //选中的聊天框内容控件
        Control selectControl = null;        //contextMenuStrip的右键选中对象
        int rowIndex = 0;        //被点击的行
        private int canAddMsg = 1;      //为0时代表本地没有更多消息记录
        private int isReplace = 1;      //为0时代表正在发送，不进行emoji的替换
        private List<string> fileCollect = new List<string>();
        EQShowInfoPanelAlpha ShowInfoShade = new EQShowInfoPanelAlpha();       //透明panel用于捕捉多选点击事件
        private bool isCanTalk = false;  //群解散或者被踢出等，不能再聊天。同时控制不再拉取漫游
        private bool isDownloadRoaming = false;     //是否正在拉取漫游，避免选择聊天对象还未拉取到最新消息就已经生成气泡
        private Dictionary<string, MessageObject> loadMsgsData = new Dictionary<string, MessageObject>();   //保存暂时不能添加到列表的消息
        LodingUtils loding = new LodingUtils();     //新创一个等待符
        private int readNum = 0;    //未读数量计数
        private string readMsgId = "";      //未读信息的第一条id
        private double lastMsgTime = 0;
        private MessageObjectDataDictionary targetMsgData
        {
            get
            {
                //获取新的聊天对象的消息列表
                if (choose_target == null || string.IsNullOrEmpty(choose_target.UserId))
                    return new MessageObjectDataDictionary();
                else
                    return ChatTargetDictionary.GetMsgData(choose_target.UserId);
            }
        }     //当前聊天对象的消息字典
        public int isSeparateChat = 0;      //记录是否为独立聊天窗体
        
        #region 草稿回显
        private void DraftShow(Friend friend)
        {
            if (choose_target != null)
            {
                //旧聊天对象储存在数据库的草稿
                string old_draft = LocalDataUtils.GetStringData(Applicate.MyAccount.userId + "_DRAFT_" + choose_target.UserId);
                //旧聊天对象当前的草稿
                string new_draft = txtSend.Rtf;
                //需要保存草稿的对象
                LocalDataUtils.SetStringData(Applicate.MyAccount.userId + "_DRAFT_" + choose_target.UserId, txtSend.Rtf);

                //用正则表达式，获取图片rtf
                MatchCollection matchs = Regex.Matches(txtSend.Rtf, @"{\\pict[a-z0-9\\\s]*}", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                foreach (Match match in matchs)
                {
                    txtSend.Rtf = txtSend.Rtf.Replace(match.Value, "[图片]");
                }

                //最近消息列表的回显
                if (!string.IsNullOrEmpty(txtSend.Text))
                {
                    choose_target.UpdateLastContent("草稿:" + txtSend.Text, TimeUtils.CurrentTimeDouble());
                    MessageObject message = new MessageObject()
                    {
                        FromId = Applicate.MyAccount.userId,
                        ToId = choose_target.UserId,
                        toUserId = choose_target.UserId,
                        fromUserId = Applicate.MyAccount.userId,
                        fromUserName = Applicate.MyAccount.nickname,
                        toUserName = choose_target.NickName,
                    };
                    Messenger.Default.Send(message, MessageActions.XMPP_SHOW_SINGLE_MESSAGE);
                }
                // 刷新最后一条聊天记录
                else
                {
                    if (!old_draft.Equals(new_draft))
                        Messenger.Default.Send(choose_target, token: MessageActions.UPDATE_FRIEND_LAST_CONTENT);
                }
            }

            //新的聊天对象
            if (friend != null)
            {
                //获取新聊天对象的草稿
                string draft = LocalDataUtils.GetStringData(Applicate.MyAccount.userId + "_DRAFT_" + friend.UserId);
                if (string.IsNullOrEmpty(draft))
                    txtSend.Text = draft;
                else
                    txtSend.Rtf = draft;
            }
        }
        #endregion

        #region 聊天列表第一次加载
        public SendMsgPanel()
        {
            InitializeComponent();

            ShowInfoVScroll.SetCurrentPanel(showInfo_Panel.Name);   //设置滚动条

            //消息列表遮罩层（多选）
            ShowInfoShade.Name = "ShowInfoShade";
            ShowInfoShade.MouseDown += ShowInfoShade_MouseDown;
            //不显示遮罩层
            IsShowInfoShade(false);
            //添加控件
            Takeconter_panel.Controls.Add(ShowInfoShade);
            //绑定滚动事件
            ShowInfoVScroll.SetShowInfoShade(ShowInfoShade.Name);

            //添加滚动监听
            ShowInfoVScroll.AddScollerBouttom(() =>
            {
                AddMoreMsg();
            });

            //@通知的点击监听
            AtMePanel.AddEvent((msgId) =>
            {
                //更新@状态
                choose_target.UpdateAtMeState(0);

                //获取收到@的message
                MessageObject msg = targetMsgData.GetMsg(msgId);

                if (choose_target.IsGroup != 1 || msg.rowIndex < -1)
                    return;

                //跟踪到该信息位置
                if (msg != null)
                {
                    SetPanTopByRowIndex(msg.rowIndex);
                }
                //不在列表中，则必定在数据库中
                else
                {
                    while (ShowInfoVScroll.canAdd == 1)
                    {
                        AddMoreMsg();
                        msg = targetMsgData.GetMsg(msgId);
                        if (msg != null)
                        {
                            SetPanTopByRowIndex(msg.rowIndex);
                            return;
                        }
                    }
                }
            });

            #region 新消息标识点击监听
            unReadNumPanel.AddListen((msgId) =>
            {
                MessageObject msg = new MessageObject() { FromId = choose_target.UserId, messageId = msgId }.GetMessageObject();
                //查询的结果为空
                if (string.IsNullOrWhiteSpace(msg.messageId))
                    return;

                #region 追踪行
                //在字典中查找
                MessageObject dic_msg = targetMsgData.GetMsg(msgId);

                //跟踪到该信息位置
                if (dic_msg != null)
                {
                    if (dic_msg.rowIndex < 0)
                        return;

                    SetPanelTopByMsg(dic_msg);
                }
                //不在列表中，则必定在数据库中
                else
                {
                    while (ShowInfoVScroll.canAdd == 1)
                    {
                        AddMoreMsg();
                        dic_msg = targetMsgData.GetMsg(msgId);
                        if (dic_msg != null)
                        {
                            SetPanelTopByMsg(dic_msg);
                            return;
                        }
                    }
                }
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
                MessageObject msg = ShiKuManager.SendVoiceMessage(choose_target, "", localPath, fileSize, timeLen, false);
                JudgeMsgIsAddToPanel(msg);
                //上传音频文件
                UploadEngine.Instance.From(localPath).
                    UploadFile((success, url) =>
                    {
                        if (success)
                        {
                            msg.content = url;
                            msg.UpdateMessageContent();
                            ShiKuManager.xmpp.SendMessage(msg);
                        }
                    });
            };
            #endregion

            #region 拍照回调

            #endregion

            //允许拖拽(liuhuan)
            txtSend.AllowDrop = true;
            txtSend.DragDrop += TxtSend_DragDrop;
            txtSend.DragEnter += TxtSend_DragEnter;

        }
        #region 拖入控件边界时发生（liuhuan/2019/4/22）
        /// <summary>
        /// 拖入控件边界时发生
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void TxtSend_DragEnter(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
            {
                //e.Effect = DragDropEffects.Copy;
                e.Effect = DragDropEffects.Link;
            }
            else
            {
                e.Effect = DragDropEffects.None;
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
            string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);
            fileCollect.Add(files[0]);
            foreach (string file in files)
            {
                FileStream fs = new FileStream(file, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
                StreamReader sr = new StreamReader(fs, System.Text.Encoding.Default);
                sr.Close();
                //DroupFeileSend();
                // txtSend.Clear();

                //switch (Path.GetExtension(file))
                //{
                //    case ".txt"://判断文件类型为txt文件
                //        sr = new StreamReader(file, System.Text.Encoding.Default);

                //        sr.Close();
                //        break;
                //    case ".png":
                //    case ".jpg": //判断文件类型为png文件
                //    case ".bmp":

                //        sr.Close();
                //        break;
                //    case ".html": //判断文件类型为html文件

                //        sr.Close();
                //        break;
                //    case ".docx":
                //    case ".xlsx":
                //        sr.Close();
                //        break;
                //    default:
                //        break;
                //}

            }
        }
        #endregion

        #region  发送拖拽后的文件（liuhuan/2019/4/22）
        /// <summary>
        /// 拖拽后点击发送文件
        /// </summary>
        private void DroupFeileSend()
        {
            if (fileCollect != null)
            {
                for (int i = 0; i < fileCollect.Count; i++)
                {
                    UploadFileOrImage(fileCollect[i], Convert.ToInt32(new FileInfo(fileCollect[i]).Length));   //上传图片
                }
                txtSend.Clear();
                fileCollect.Clear();
            }
        }
        #endregion
        private void SendMsgPanel_Load(object sender, EventArgs e)
        {
            this.TabStop = false;
            RegisterMessengers();       //注册通知
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
            Messenger.Default.Register<Friend>(this, EQFrmInteraction.MultiSelectEnd, item => CloseMultiSelect(false));
            #region 清空UI
            //注册清空UI（单向）
            Messenger.Default.Register<string>(this, EQFrmInteraction.ClearFdMsgsSingle, (userId) =>
            {
                //请求接口删除聊天记录
                MessageObject message = new MessageObject() { FromId = userId };
                message.DeleteTable();

                //通知最近聊天列表更新
                Friend fd = new Friend() { UserId = userId };
                Messenger.Default.Send(fd, token: MessageActions.UPDATE_FRIEND_LAST_CONTENT);

                // 清除服务器数据
                ClearServerFriendMsg(userId);

                if (choose_target == null)
                    return;
                if (userId == choose_target.UserId)     //对象必须是当前聊天对象才清空页面
                    ClearUI(choose_target);
            });
            //注册清空UI（双向）
            Messenger.Default.Register<string>(this, MessageActions.CLEAR_FRIEND_MSGS, (userId) =>
            {
                //通知最近聊天列表更新
                Friend fd = new Friend() { UserId = userId };
                Messenger.Default.Send(fd, token: MessageActions.UPDATE_FRIEND_LAST_CONTENT);

                if (choose_target == null)
                    return;
                if (userId == choose_target.UserId)     //对象必须是当前聊天对象才清空页面
                    ClearUI(choose_target);
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
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_RECALL_MESSAGE,
                item => EQMenuStripControl.menuItem_Recall_Click(this.showInfo_Panel, item, choose_target == null ? "" : choose_target.UserId));
            //收到了一个群禁言通知
            Messenger.Default.Register<MessageObject>(this, MessageActions.ROOM_UPDATE_BANNED_TALK, item => UpdateBannedTalk(item));
            //收到了一个修改备注通知
            Messenger.Default.Register<Friend>(this, MessageActions.UPDATE_FRIEND_REMARKS, item => ModifyFriendName(item));
            //收到了一个批量删除通知
            Messenger.Default.Register<List<MessageObject>>(this, EQFrmInteraction.BatchDeleteMsg, item => BatchDeleteMsg(item));
            //收到了一个@我的通知
            Messenger.Default.Register<Friend>(this, MessageActions.ROOM_UPDATE_AT_ME, item => AtMeShowPanel(item));
            //收到我主动@别人的通知
            Messenger.Default.Register<Friend>(this, EQFrmInteraction.AddAtUserToTxtSend, item => AddAtUserToTxtSend(item));
            //重新上传图片并更新气泡
            Messenger.Default.Register<MessageObject>(this, EQFrmInteraction.ResumeUploadImageMsg, item => ResumeUploadImageMsg(item));
            //多点登录上线离线消息
            Messenger.Default.Register<string>(this, MessageActions.UPDATE_DEVICE_STATE, item => UpdateDeviceState(item));

        }

        #endregion

        #region 更换聊天对象，清除缓存
        private void ClearUI(Friend friend, bool isDispon = true)
        {
            //关闭设置页
            if (frmSet != null)
            {
                frmSet.Close();
                frmSet = null;
            }

            //草稿回显
            DraftShow(friend);

            //清除已选择的emoji
            emoji_num = 0;
            emoji_codes = new List<string>();

            //阅后即焚处理
            SaveReadDelTime();
            isHaveReadDel = 0;

            //非独立窗体
            if (isSeparateChat == 0)
            {
                //获取上个聊天对象
                if (!string.IsNullOrEmpty(choose_target.UserId))
                {
                    var last_target = ChatTargetDictionary.GetMsgData(choose_target.UserId);
                    //如果上个聊天对象不为独立窗体
                    if (last_target.isSeparateChat == 0)
                    {
                        //清除上个聊天对象的消息
                        if (choose_target != null && !string.IsNullOrEmpty(choose_target.UserId))
                        {
                            if (last_target.GetMsgList().Count > 0)
                                last_target.RemoveAllData();
                        }
                        //移除切换好友前的对象
                        ChatTargetDictionary.RemoveItem(choose_target.UserId);
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
            choose_target = friend;
            //保存是否为独立聊天
            targetMsgData.isSeparateChat = this.isSeparateChat;
            while (showInfo_Panel.Controls.Count > 0)
            {
                //foreach循环一次循环只能移除一半
                foreach (Control item in showInfo_Panel.Controls)
                {
                    showInfo_Panel.Controls.Remove(item);
                    if (isDispon)
                        item.Dispose();
                }
                if (showInfo_Panel.Controls.Count == 0)
                    break;
            }
            showInfo_Panel.RowStyles.Clear();
            showInfo_Panel.RowCount = 1;
            showInfo_Panel.Height = 0;
            Helpers.ClearMemory();
            showInfo_Panel.Top = 0;
            PAGE_INDEX = 1;     //重置翻页
            atCount = 0;    //重置@符数量

            //重置向上翻页
            canAddMsg = 1;
            ShowInfoVScroll.canAdd = 1;
            CanAddMoreRoaming = true;

            //清空录制
            isStartTrans = 0;
            startTransIndex = 0;
            endTransIndex = 0;

            //恢复对话状态
            isCanTalk = true;

            //关闭等待符
            loding.stop();

            //重置漫游状态
            isDownloadRoaming = false;

            lastMsgTime = 0;    //重置最后一条消息的时间

            //隐藏并清空回复面板
            replyPanel.ReplyMsg = null;
            replyPanel.SendToBack();
        }
        #endregion

        private Stopwatch stopwatch2 = new Stopwatch();
        #region 清空聊天缓存，保存新选择的聊天对象
        /// <summary>
        /// 清空聊天缓存，保存新选择的聊天对象
        /// <para>如果聊天对象不变，请不要调用</para>
        /// </summary>
        /// <param name="friend">聊天对象</param>
        public void SetChooseFriend(Friend friend, int readNum = 0, string msgId = "", int isSeparateChat = 0)
        {
            //避免因为错误退出，界面挂起没恢复
            this.ResumeLayout();
            showInfo_Panel.ResumeLayout();

            //记录未读的相关信息
            this.readNum = readNum;
            this.readMsgId = msgId;

            //记录是否为独立聊天对象
            this.isSeparateChat = isSeparateChat;

            //设置空的聊天对象，重置面板
            if (friend == null || string.IsNullOrEmpty(friend.UserId))
            {
                ClearUI(friend);
                choose_target = null;
                return;
            }
            //点击相同的对象
            if (choose_target != null && choose_target.UserId == friend.UserId)
                return;

            //this.SuspendLayout();
            //panShade.BringToFront();    //遮罩层使界面加载过程不可见
            showInfo_Panel.ColumnStyles[0].Width = 0;   //复选框列不可见
            IsShowPanelMultiSelect(false);      //显示聊天发送框而不是多选操作面板
            IsShowInfoShade(false);     //关闭消息列表多选遮罩层
            //Applicate.FriendObj = friend;
            ClearUI(friend);
            //保存聊天对象
            //choose_target = friend;

            //修改标题
            if (choose_target.IsGroup == 0)
                labName.Text = string.IsNullOrEmpty(friend.RemarkName) ? friend.NickName : friend.RemarkName;
            else
                labName.Text = friend.NickName;
            //群公告隐藏
            roomNotice.CloseNotice();
            //获取群设置
            if (choose_target.IsGroup == 1)
                GetRoomSetting();
            //获取好友状态到标题栏
            else
            {
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

            stopWatch1.Restart();
            //先进行漫游
            FirstDownloadRoaming();

            //如果正在漫游则漫游结束后才对面板进行操作
            if (!isDownloadRoaming)
                SetShowInfoPanel();
            stopWatch1.Stop();
           LogUtils.Log("Total " + stopWatch1.ElapsedMilliseconds + " ms.");
        }
        #endregion

        #region 加载消息面板
        private Stopwatch stopWatch1 = new Stopwatch();
        private void SetShowInfoPanel()
        {
            //Thread thread = new Thread(() =>
            //{

            showInfo_Panel.SuspendLayout();
            //加载历史记录
            List<MessageObject> msgList = DownRoamAndLoadLocalMsg();
            if (msgList.Count == 0)
            {
                NotCanAddMoreMsg();
            }
            //小于二十条代表数据库没有更多的聊天记录
            //if (showInfo_Panel.RowCount == 1)
            //{
            //    showInfo_Panel.RowStyles.Clear();
            //    if (msgList.Count == row_insert)
            //    {
            //        showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 25));
            //        AddMoreMessageLabe();
            //    }
            //    else
            //        showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 0));
            //}
            foreach (MessageObject msg in msgList)
            {
                JudgeMsgIsAddToPanel(msg);
            }
            showInfo_Panel.ResumeLayout();
            //});
            //if (this.IsHandleCreated)
            //thread.Start();

            //清除禁言面板
            IsShow_BannedTalkPanel(false);

            //显示群已读人数
            if (choose_target.ShowRead == 1)
                IsShowReadPersons(true);

            //第一次加载数据，如果消息列表超过面板，则滚动到底部
            if ((Takeconter_panel.Height - showInfo_Panel.Height) <= 0)
                ShowInfoVScroll.SetVScroolToBottom();

            //遮罩层置底
            //panShade.SendToBack();
            //this.ResumeLayout();

            //当前是否为禁言
            string remindTxt = "";
            bool isShow = JudgeIsBannedTalk(ref remindTxt);
            if (isShow)
                IsShow_BannedTalkPanel(isShow, remindTxt);

            //控制是否显示未读数量悬浮标识
            IsShowUnReadNumPanel(readNum, readMsgId);

            //是否显示音视频按钮
            if (!Applicate.ENABLE_MEET || Applicate.CURRET_VERSION < 4.6f)
            {
                lblAudio.Visible = false;
                lblVideo.Visible = false;
            }

            //控制是否要显示@角标
            AtMeShowPanel(choose_target);
        }
        #endregion

        #region 首次选择聊天对象，下载漫游消息
        private void FirstDownloadRoaming()
        {
            choose_target = choose_target.GetByUserId();
            //需要拉漫游
            if (choose_target.DownloadRoamStartTime > 0)
            {
                //正在漫游
                isDownloadRoaming = true;
                //开启禁言
                IsShow_BannedTalkPanel(true);
                //显示等待符
                StartLoding(Takeconter_panel, "正在下载漫游消息...");

                if (choose_target.IsGroup == 0)      //单聊
                    GetRoamMessageSingle(choose_target.DownloadRoamEndTime, choose_target.DownloadRoamStartTime);
                else
                    GetRoamMessageGroup(choose_target.DownloadRoamEndTime, choose_target.DownloadRoamStartTime);
            }
        }
        #endregion

        #region 展示等待符
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

        #region 处理群通知UI更新
        private void UpdateRoomUIByMessage(MessageObject msg)
        {
            try
            {
                if (choose_target == null)
                    return;
                if (choose_target.IsGroup == 0 || !choose_target.UserId.Equals(msg.objectId))
                    return;

                //群管理员转让
                if (msg.type == kWCMessageType.RoomManagerTransfer)
                {

                }
                //群公告
                if (msg.type == kWCMessageType.RoomNotice)
                {
                    ShowNotice();
                }
                //解散群
                if (msg.type == kWCMessageType.RoomDismiss)
                {
                    string remindTxt = "该群已被解散";
                    IsShow_BannedTalkPanel(true, remindTxt);
                }
                //更改群名称
                if (msg.type == kWCMessageType.RoomNameChange)
                {
                    choose_target.NickName = msg.content;
                    if (this.IsHandleCreated)
                        Invoke(new Action(() => { labName.Text = msg.content + "（" + userSize + "人）"; }));
                }
                //群已读人数开关
                else if (msg.type == kWCMessageType.RoomReadVisiblity)
                {
                    choose_target.ShowRead = Convert.ToInt32(msg.content);
                    IsShowReadPersons(choose_target.ShowRead == 0 ? false : true);
                }
                //群讲课
                else if (msg.type == kWCMessageType.RoomAllowSpeakCourse)
                {
                    if (this.IsHandleCreated)
                        Invoke(new Action(() =>
                        {
                            if (Applicate.ENABLE_MEET && Applicate.CURRET_VERSION > 4.0f)
                            {
                                choose_target.AllowConference = Convert.ToInt32(msg.content);
                                //关闭后，改变普通成员的音视频按钮状态
                                SetControlEnabled(lblAudio, choose_target.AllowSpeakCourse == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true);
                                SetControlEnabled(lblVideo, choose_target.AllowSpeakCourse == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true);
                            }
                            else
                            {
                                SetControlEnabled(lblAudio, false);
                                SetControlEnabled(lblVideo, false);
                            }
                        }));
                }
                //群会议开关
                else if (msg.type == kWCMessageType.RoomAllowConference)
                {
                    if (this.IsHandleCreated)
                        Invoke(new Action(() =>
                        {
                            if (Applicate.ENABLE_MEET && Applicate.CURRET_VERSION > 4.0f)
                            {
                                choose_target.AllowConference = Convert.ToInt32(msg.content);
                                //关闭群会议，普通成员不允许点击视频和音频
                                //SetControlEnabled(lblAudio, choose_target.allowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true);
                                //SetControlEnabled(lblVideo, choose_target.allowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true);
                                lblAudio.Visible = choose_target.AllowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true;
                                lblVideo.Visible = choose_target.AllowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true;
                            }
                            else
                            {
                                lblAudio.Visible = false;
                                lblVideo.Visible = false;
                            }
                        }));
                }
                //入群通知
                else if (msg.type == kWCMessageType.RoomInvite)
                {
                    if (this.IsHandleCreated)
                        Invoke(new Action(() =>
                        {
                            userSize++;
                            labName.Text = (string.IsNullOrEmpty(choose_target.RemarkName) ? choose_target.NickName : choose_target.RemarkName)
                                        + "（" + userSize + "人）";
                        }));
                }
                //退群通知
                else if (msg.type == kWCMessageType.RoomExit)
                {
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
                                labName.Text = (string.IsNullOrEmpty(choose_target.RemarkName) ? choose_target.NickName : choose_target.RemarkName)
                                            + "（" + userSize + "人）";
                            }
                        }));
                }
            }
            catch (Exception ex)
            {
                LogHelper.log.Error("----处理群设置消息出错，方法（UpdateRoomUIByMessage） : " + ex.Message);
            }
        }
        #endregion

        #region 显示更多聊天记录
        Label labMoreMsg = null;
        private void AddMoreMessageLabe()
        {
            if (showInfo_Panel.GetPositionFromControl(labMoreMsg).Row == -1)
            {
                labMoreMsg = new Label();
                labMoreMsg.Name = "labMoreMsg";
                labMoreMsg.Font = new Font(Applicate.SetFont, 9F, FontStyle.Bold, GraphicsUnit.Point, 134);
                labMoreMsg.ForeColor = Color.FromArgb(78, 169, 233);
                labMoreMsg.Text = "显示更多的消息记录";
                labMoreMsg.TextAlign = ContentAlignment.MiddleCenter;
                labMoreMsg.Padding = new Padding(0, 10, 0, 0);    //上边距5
                labMoreMsg.AutoSize = true;
                labMoreMsg.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right;
                labMoreMsg.Cursor = Cursors.Hand;

                labMoreMsg.Click += labMoreMsg_Click;
                if (showInfo_Panel.RowStyles.Count == 1)
                    showInfo_Panel.RowStyles[0].Height = 45;
                if (showInfo_Panel.RowStyles.Count == 0)
                    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 45));
                if (showInfo_Panel.GetPositionFromControl(labMoreMsg) != null || showInfo_Panel.GetPositionFromControl(labMoreMsg).Row > -1)
                    showInfo_Panel.Controls.Remove(labMoreMsg);
                showInfo_Panel.Controls.Add(labMoreMsg, 1, 0);

                if (isHaveMoreLocalMsg)
                    labMoreMsg.Visible = true;
                else
                    labMoreMsg.Visible = false;
            }
        }

        private void labMoreMsg_Click(object sender, EventArgs e)
        {
            if (ShowInfoVScroll.canAdd > -1)
            {
                ShowInfoVScroll.canAdd = 0;
                AddMoreMsg();
                ShowInfoVScroll.canAdd = 1;
            }
        }

        /// <summary>
        /// 不能继续向上翻页和点击加载更多聊天记录
        /// </summary>
        private void NotCanAddMoreMsg()
        {
            if (this.IsHandleCreated)
                //UI主线程进行操作
                Invoke(new Action(() =>
                {
                    if (labMoreMsg != null)
                        labMoreMsg.Visible = false;
                    //不再拉取和翻页获取数据
                    isHaveMoreLocalMsg = false;
                    ShowInfoVScroll.canAdd = -1;

                    if (showInfo_Panel.RowStyles.Count > 0)
                    {
                        int rowStyle0 = (int)showInfo_Panel.RowStyles[0].Height;
                        if (rowStyle0 > 0)
                        {
                            showInfo_Panel.Height -= rowStyle0;
                            showInfo_Panel.RowStyles[0].Height = 0;
                        }
                    }
                }));
        }

        /// <summary>
        /// 能继续向上翻页和点击加载更多聊天记录
        /// </summary>
        private void CanAddMoreMsg()
        {
            if (this.IsHandleCreated)
                //UI主线程进行操作
                Invoke(new Action(() =>
                {
                    //不再拉取和翻页获取数据
                    isHaveMoreLocalMsg = true;
                    ShowInfoVScroll.canAdd = 1;
                    if (showInfo_Panel.RowStyles.Count > 0 && showInfo_Panel.RowStyles[0].Height == 0)
                    {
                        showInfo_Panel.Height += 45;
                        showInfo_Panel.RowStyles[0].Height = 45;
                    }
                    if (labMoreMsg != null)
                        labMoreMsg.Visible = true;
                }));
        }

        private void AddMoreMsg()
        {
            //等待符
            //LodingUtils lodingUtils = new LodingUtils();

            List<MessageObject> msgList = DownRoamAndLoadLocalMsg();   //数据库获取的集合
            if (msgList.Count == 0)
            {
                NotCanAddMoreMsg();
                return;
            }
            //小于二十条代表数据库没有更多的聊天记录
            //if(showInfo_Panel.RowCount == 1)
            //{
            //    showInfo_Panel.RowStyles.Clear();
            //    if (msgList.Count == row_insert)
            //    {
            //        showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 25));
            //        AddMoreMessageLabe();
            //    }
            //    else
            //        showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 0));
            //}


            //临时挂起布局
            showInfo_Panel.SuspendLayout();

            try
            {
                #region 加载历史记录并且控件下移
                List<EQBaseControl> msgPanels = new List<EQBaseControl>();    //需要添加的控件，key为list_msg的索引
                                                                              //获取聊天气泡集合
                for (int index = 0; index < msgList.Count; index++)
                {
                    EQBaseControl talk_panel = GetMessagePanel(msgList[index], index + 1);
                    if (talk_panel != null)
                        msgPanels.Add(talk_panel);
                }
                //添加新的行数
                for (int index = 0; index < msgPanels.Count; index++)
                {
                    //第一条消息对列表进行初始化
                    if (showInfo_Panel.RowCount == 1)
                    {
                        showInfo_Panel.RowStyles.Clear();
                        showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 45));
                        //showInfo_Panel.RowStyles[0].Height = 50;
                        AddMoreMessageLabe();
                    }

                    //按控件高度插入一行
                    showInfo_Panel.RowStyles.Insert(index + 1, new RowStyle(SizeType.Absolute, msgPanels[index].Height));
                    showInfo_Panel.RowCount++;
                    //showInfo_Panel.Height += msgPanels[index].Height;
                }
                Dictionary<int, Control> tab_crl = new Dictionary<int, Control>();  //列表原本的控件，key为行号
                //循环每一行，获取所有的控件
                foreach (Control item in showInfo_Panel.Controls)
                {
                    if (item.Name.IndexOf("labMoreMsg") > -1 || item.GetType().Name == "CheckBoxEx")
                        continue;

                    var position = showInfo_Panel.GetPositionFromControl(item);
                    tab_crl.Add(position.Row, item);
                }
                //重新排序（必须从最后一行开始往下挪）
                for (int index = showInfo_Panel.RowStyles.Count; index > 0; index--)
                {
                    if (!tab_crl.ContainsKey(index))
                        continue;
                    //获得该行的消息气泡
                    var item = tab_crl[index];
                    showInfo_Panel.SetRow(item, index + msgPanels.Count);
                    //如果该行有复选框，则下移
                    if (showInfo_Panel.GetControlFromPosition(0, index) != null && showInfo_Panel.GetControlFromPosition(0, index) is CheckBoxEx checkBox)
                        showInfo_Panel.SetRow(checkBox, index + msgPanels.Count);
                    //修改字典的行号
                    string msgId = item.Name.Replace("talk_panel_", "");
                    MessageObject msg = targetMsgData.GetMsg(msgId);
                    if (msg != null)
                        msg.rowIndex += msgPanels.Count;
                }
                //插入控件集合
                for (int index = 0; index < msgPanels.Count; index++)
                {
                    //因为不是所有msg都会生成气泡
                    //if (!msgPanels.ContainsKey(index))
                    //    continue;
                    InsertControlToRow(msgPanels[index], index + 1, msgList[index]);
                }
                #endregion
            }
            catch (Exception ex)
            {

            }
            //恢复挂起的布局
            showInfo_Panel.ResumeLayout();

            //由于向上翻页中添加消息气泡会导致空行，所以翻页加载完成后添加气泡
            //AddLoadMsgsToPanel();
        }
        #endregion

        #region 加载本地聊天记录
        private List<MessageObject> LoadObjectLocalMsg()
        {
            double timeSend = TimeUtils.CurrentTime();
            if (targetMsgData.GetFirstIndexMsg() != null)
                timeSend = targetMsgData.GetFirstIndexMsg().timeSend;
            //获取固定数量的聊天消息
            List<MessageObject> msgList = new MessageObject()
            {
                FromId = choose_target.UserId
            }.GetPageListNotHaveIsRead(timeSend, row_insert);
            //保存需要移除的msg集合
            List<MessageObject> removeList = new List<MessageObject>();
            //移除掉已存在的msg
            foreach (MessageObject msg in targetMsgData.GetMsgList())
                foreach (MessageObject item in msgList)
                    if (item.messageId.Equals(msg.messageId))
                        removeList.Add(item);
            //循环移除重复msg
            foreach (var msg in removeList)
                msgList.Remove(msg);             
            //数量足够显示加载更多
            if (msgList.Count == row_insert)
                isHaveMoreLocalMsg = true;
            //重新排序
            msgList.Sort((x, y) =>
            {
                if (x.timeSend < y.timeSend)
                    return -1;
                else if (x.timeSend > y.timeSend)
                    return 1;
                else
                    return 0;
            });
            //foreach (MessageObject msg in msgList)
            //{
            //    //添加到缓存中
            //    MessageObjectDataDictionary.AddMsgData(msg);
            //}
            //PAGE_INDEX++;       //翻页
            return msgList;
        }
        #endregion

        #region 加载本地和漫游消息
        private bool CanAddMoreRoaming = true;  //是否有更多的聊天记录
        private List<MessageObject> DownRoamAndLoadLocalMsg()
        {
            List<MessageObject> list_msgs = LoadObjectLocalMsg();
            //数据库数据不足
            if (list_msgs.Count < row_insert)
            {
                #region 漫游
                //设备不会有漫游消息
                if (choose_target.IsDevice == 0 && ShowInfoVScroll.canAdd == 0 && CanAddMoreRoaming)
                {
                    //正在漫游
                    isDownloadRoaming = true;
                    //开启禁言
                    IsShow_BannedTalkPanel(true);
                    //显示等待符
                    StartLoding(Takeconter_panel, "正在下载漫游消息...");

                    //单位为毫秒
                    double endTime = list_msgs.Count < 1   //消息列表不存在气泡
                            ? (targetMsgData.GetMsgList().Count > 0
                                ? targetMsgData.GetFirstIndexMsg().timeSend * 1000
                                : TimeUtils.CurrentTimeMillis())
                            : list_msgs[0].timeSend * 1000;
                    if (choose_target.IsGroup == 0)      //单聊
                        GetRoamMessageSingle(endTime);
                    else
                        GetRoamMessageGroup(endTime);
                }
                #endregion
            }
            return list_msgs;
        }
        #endregion

        #region 消息漫游
        #region 单聊
        private void GetRoamMessageSingle(double endTime, double startTime = 1262275200000, int page_index = 0)
        {
            //修改时间戳  
            //endTime = endTime == 0 ? UIUtils.CurrentTimeMillis() : endTime * 1000;
            //endTime--;      //防止拉取本地的最后一条记录

            //http get请求获得数据
            HttpUtils.Instance.InitHttp(this);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "tigase/shiku_msgs") //获取单聊漫游
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("receiver", choose_target.UserId)
                .AddParams("startTime", startTime.ToString())    // 2010-01-01 00:00:00  服务端返回的数据为倒序返回
                .AddParams("endTime", Convert.ToInt64(endTime).ToString())
                .AddParams("pageIndex", page_index.ToString())
                .AddParams("pageSize", "100")
                .Build().Execute((success, result) =>
                {
                    try
                    {
                        #region 保存漫游消息到本地
                        if (success)
                        {
                            //Dictionary<string, MessageObject> msgsData = new Dictionary<string, MessageObject>(); //用于检验批量插入
                            string str = result["data"].ToString();
                            JArray itemArray = JArray.Parse(str);
                            var data = new MessageObject().SingleChat(result);
                            //foreach(JToken item in itemArray)
                            for (int index = 0; index < data.Count; index++)
                            {
                                //过滤某些消息类型
                                if (!data[index].IsVisibleMsg())
                                    continue;

                                //因为服务器1个小时才去删除一次过期消息，所以可能会拉到已过期的时间
                                if (data[index].deleteTime < TimeUtils.CurrentTimeDouble() && data[index].deleteTime > 0)
                                    continue;

                                JToken item = itemArray[index];
                                data[index].isRead = 1;
                                data[index].isSend = 1;
                                data[index].FromId = data[index].fromUserId;
                                data[index].ToId = data[index].toUserId;
                                data[index].isGroup = 0;

                                //解密
                                if (data[index].isEncrypt == 1)
                                    AES.TDecrypt3Des(data[index]);

                                //保存数据
                                data[index].InsertData();

                                ////获取不重复id的数据集合
                                //if (!msgsData.ContainsKey(data[index].messageId))
                                //    msgsData.Add(data[index].messageId, data[index]);
                            }

                            //漫游记录数量不足
                            if (data.Count < 100)
                                CanAddMoreRoaming = false;

                            //防止漫游下载中进行滚动，导致判断数据库无数据后无法翻页
                            if (data.Count > 0)
                                CanAddMoreMsg();

                            //data = MessageObject.DictionaryToList(msgsData);
                            ////批量插入数据库
                            //if (data.Count > 0)
                            //    data[0].InsertArrayData(data);
                        }
                        #endregion
                        //没有更多的漫游消息
                        else
                        {
                            CanAddMoreRoaming = false;
                        }
                    }
                    catch (Exception ex)
                    {
                        LogHelper.log.Error("----漫游出错，方法（GetRoamMessageSingle） : " + ex.Message);
                    }
                    //销毁等待符
                    loding.stop();
                    //结束漫游
                    isDownloadRoaming = false;
                    //避免再次触发拉取漫游
                    choose_target.UpdateDownTime(0, 0);
                    //关闭禁言
                    IsShow_BannedTalkPanel(false);
                    //防止上翻拉取聊天记录出错
                    if (targetMsgData.GetMsgList().Count < 1)
                    {
                        //添加气泡等
                        if (!isDownloadRoaming)
                            SetShowInfoPanel();
                    }
                });
        }
        #endregion
        #region 群聊
        private void GetRoamMessageGroup(double endTime, double startTime = 1262275200000, int page_index = 0)
        {
            //http get请求获得数据
            HttpUtils.Instance.InitHttp(this);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "tigase/shiku_muc_msgs") //获取群漫游
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("roomId", choose_target.UserId)
                .AddParams("startTime", startTime.ToString())    // 2010-01-01 00:00:00  服务端返回的数据为倒序返回
                .AddParams("endTime", Convert.ToInt64(endTime).ToString())
                .AddParams("pageIndex", page_index.ToString())
                .AddParams("pageSize", "100")
                .Build().Execute((success, result) =>
                {
                    try

                    {
                        #region 保存漫游消息到本地
                        if (success)
                        {
                            //Dictionary<string, MessageObject> msgsData = new Dictionary<string, MessageObject>();
                            string str = result["data"].ToString();
                            JArray itemArray = JArray.Parse(str);
                            var data = new MessageObject().SingleChat(result);
                            //foreach(JToken item in itemArray)
                            for (int index = 0; index < data.Count; index++)
                            {
                                //因为服务器1个小时才去删除一次过期消息，所以可能会拉到已过期的时间
                                if (data[index].deleteTime < TimeUtils.CurrentTimeDouble() && data[index].deleteTime > 0)
                                    continue;

                                //过滤某些消息类型
                                if (!data[index].IsVisibleMsg())
                                    continue;
                                if (string.IsNullOrEmpty(data[index].messageId))
                                    continue;

                                JToken item = itemArray[index];
                                data[index].isSend = 1;
                                data[index].FromId = data[index].toUserId;
                                data[index].ToId = Applicate.MyAccount.userId;
                                data[index].isGroup = 1;

                                //解密
                                if (data[index].isEncrypt == 1)
                                    AES.TDecrypt3Des(data[index]);

                                //保存数据
                                data[index].InsertData();

                                ////获取不重复id的数据集合
                                //if (!msgsData.ContainsKey(data[index].messageId))
                                //    msgsData.Add(data[index].messageId, data[index]);
                            }

                            //漫游数量不足
                            if (data.Count < 100)
                                CanAddMoreRoaming = false;

                            //防止漫游下载中进行滚动，导致判断数据库无数据后无法翻页
                            if (data.Count > 0)
                                CanAddMoreMsg();

                            //data = MessageObject.DictionaryToList(msgsData);
                            ////批量插入数据库
                            //if (data.Count > 0)
                            //    data[0].InsertArrayData(data);
                        }
                        #endregion
                        //没有更多的漫游消息
                        else
                        {
                            CanAddMoreRoaming = false;
                        }
                    }
                    catch (Exception ex)
                    {
                        LogHelper.log.Error("----漫游出错，方法（GetRoamMessageSingle） : " + ex.Message);
                    }
                    //销毁等待符
                    loding.stop();
                    //结束漫游
                    isDownloadRoaming = false;
                    //避免再次触发拉取漫游
                    choose_target.UpdateDownTime(0, 0);
                    //关闭禁言
                    IsShow_BannedTalkPanel(false);
                    //防止上翻拉取聊天记录出错
                    if (targetMsgData.GetMsgList().Count < 1)
                    {
                        //添加气泡等操作
                        if (!isDownloadRoaming)
                            SetShowInfoPanel();
                    }
                });
        }
        #endregion
        #endregion

        #region 按回执更新送达消息状态
        private void DrawIsSend(MessageObject msg)
        {
            MessageObject t_msg = targetMsgData.GetMsg(msg.messageId);
            //不属于自己的消息回执
            if (t_msg == null)
                return;
            t_msg.isSend = msg.isSend;
            if (t_msg == null || string.IsNullOrEmpty(t_msg.messageId))
                return;

            if (t_msg.fromUserId != Applicate.MyAccount.userId || choose_target == null)
                return;

            //获得需要更新的控件
            string c_name = "talk_panel_" + t_msg.messageId;

            //是否存在该气泡消息和送达标识
            if (showInfo_Panel.Controls[c_name] == null || showInfo_Panel.Controls[c_name].Controls["lab_msg"] == null)
                return;
            var position = showInfo_Panel.GetPositionFromControl(showInfo_Panel.Controls[c_name]);
            if (position.Row < 0 || position.Column < 0)
                return;

            //群聊没有送达
            if (choose_target.IsGroup == 1 && t_msg.isSend == 1)
            {
                if (this.IsHandleCreated)
                    Invoke(new Action(() =>
                    {
                        if (choose_target.ShowRead == 1)
                            EQControlManager.DrawReadPerson(t_msg.readPersons, (Label)showInfo_Panel.Controls[c_name].Controls["lab_msg"]);
                        else
                            showInfo_Panel.Controls[c_name].Controls["lab_msg"].Visible = false;
                    }));
                return;
            }
            //修改气泡的发送状态
            Action action = new Action(() =>
            {
                EQControlManager.DrawIsSend(t_msg, (Label)showInfo_Panel.Controls[c_name].Controls["lab_msg"]);
            });
            if (this.IsHandleCreated)
                Invoke(action);
        }
        #endregion

        #region 按回执更新已读消息状态
        private void DrawIsRead(MessageObject msg)
        {
            //获得需要更新的控件
            string c_name = "talk_panel_" + msg.messageId;

            //是否存在该气泡消息
            if (showInfo_Panel.Controls[c_name] == null)
                return;
            var position = showInfo_Panel.GetPositionFromControl(showInfo_Panel.Controls[c_name]);
            if (position.Row < 0 || position.Column < 0)
                return;

            MessageObject t_msg = targetMsgData.GetMsg(msg.messageId);
            //是否为阅后即焚的已读通知
            int isReadDel = 0;
            if (t_msg != null)
                isReadDel = t_msg.isReadDel;
            if (isReadDel == 1)
                ReplaceMsgToRemind(msg.messageId, "对方查看了您的这条阅后即焚消息");
            else
            {
                if (showInfo_Panel.Controls[c_name].Controls["lab_msg"] == null)
                    return;

                //群需要开启群已读
                if (choose_target.IsGroup == 1)
                {
                    if (this.IsHandleCreated)
                        Invoke(new Action(() =>
                        {
                            //显示群已读
                            if (choose_target.ShowRead == 1)
                            {
                                EQControlManager.DrawReadPerson(msg.readPersons, (Label)showInfo_Panel.Controls[c_name].Controls["lab_msg"]);
                            }
                        }));
                }
                else
                {
                    if (msg.fromUserId != Applicate.MyAccount.userId)
                        return;

                    Action action = new Action(() =>
                    {
                        EQControlManager.DrawIsRead((Label)showInfo_Panel.Controls[c_name].Controls["lab_msg"]);
                    });
                    if (this.IsHandleCreated)
                        Invoke(action);
                }
            }
        }
        #endregion

        #region 如果该消息为群信息，且打开了群已读设置
        private void SetReadPerson_Click(MessageObject messageObject, EQBaseControl talk_panel)
        {
            if (messageObject.isGroup == 1)
            {
                var crls = talk_panel.Controls.Find("lab_msg", true);
                Control lab_msg = crls.Length > 0 ? crls[0] : null;
                if (lab_msg != null)
                {
                    lab_msg.MouseDown += (sender, e) =>
                    {
                        //弹出已读人数显示框
                        if (choose_target.ShowRead == 1 && e.Button == MouseButtons.Left)
                        {
                            FrmReaded frmReaded = new FrmReaded();
                            frmReaded.GetFriend = choose_target;
                            frmReaded.DesMessage(messageObject);
                            frmReaded.Show();
                        }
                    };
                }
            }
        }
        #endregion

        #region 加载历史消息时，暂停接收最新消息
        /// <summary>
        /// 如果正在翻页，则保存该msg，暂不添加
        /// </summary>
        /// <param name="msg"></param>
        private void JudgeMsgIsAddToPanel(MessageObject msg)
        {
            #region 过滤消息
            if (choose_target == null || msg == null || string.IsNullOrEmpty(msg.messageId))
                return;
            //正在输入。。通知
            if (msg.type == kWCMessageType.Typing)
            {
                if (msg.fromUserId == choose_target.UserId)
                    IsShowTyping();
                return;
            }
            //不生成气泡的消息类型
            if (!msg.IsVisibleMsg() && msg.type != kWCMessageType.RoomIsVerify)
                return;
            //已存在该气泡控件
            if (showInfo_Panel.Controls["talk_panel_" + msg.messageId] != null)
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
                if (msg.ToId != choose_target.UserId)
                    return;
            }
            //FromId和ToId必须是自己和当前聊天对象，FromId或者ToId为自己时，另一个必定为聊天对象
            else if (msg.FromId == choose_target.UserId)
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

            //正在加载漫游消息
            if (isDownloadRoaming)
            {
                loadMsgsData.Add(msg.messageId, msg);
            }
            else
            {
                //Thread thread = new Thread(() =>
                //{
                stopWatch.Restart();
                AddMessageToPanel(msg);
                stopWatch.Stop();
               LogUtils.Log(msg.type + " run " + stopWatch.ElapsedMilliseconds + " ms.");
                //});
                //thread.SetApartmentState(ApartmentState.STA);
                //thread.Start();
            }
        }

        /// <summary>
        /// 添加msgs到面板
        /// </summary>
        private void AddLoadMsgsToPanel()
        {
            if (loadMsgsData.Count > 0)
            {
                foreach (var msg in loadMsgsData.Values)
                    AddMessageToPanel(msg);
                loadMsgsData = new Dictionary<string, MessageObject>();
            }
        }
        #endregion

        #region 添加消息气泡到列表
        private Stopwatch stopWatch = new Stopwatch();
        private void AddMessageToPanel(MessageObject msg)
        {
            //添加到缓存
            targetMsgData.AddMsgData(msg);
            //获取字典中存储的message
            MessageObject messageObject = targetMsgData.GetMsg(msg.messageId);
            if (messageObject == null || string.IsNullOrWhiteSpace(messageObject.messageId))
                return;

            bool isOneSelf = string.Equals(messageObject.fromUserId, Applicate.MyAccount.userId);     //判断是否为本人发送的消息

            //从主线程中访问
            Action action = new Action(() =>
            {
                //获取控件的类型
                //KWTypeControlsDictionary kWTypeControls = new KWTypeControlsDictionary(messageObject);
                //EQBaseControl eqBase = kWTypeControls.GetObjectByType();
                EQBaseControl eqBase = KWTypeControlsDictionary.GetObjectByType(messageObject);

                //EQBaseControl crl = null;
                //    KWTypeControlsDictionary.GetObjectByType(messageObject, crl, (eqBase) =>
                //    {
                //是否显示群已读人数
                if (choose_target.IsGroup == 1)
                    eqBase.isShowLabMsg = choose_target.ShowRead == 1 ? true : false;
                //是否显示阅后即焚
                if (choose_target.IsGroup == 0)
                    eqBase.isReadDel = messageObject.isReadDel == 1 ? true : false;
                //含有阅后即焚消息
                if (eqBase.isReadDel)
                    isHaveReadDel = 1;

                #region 气泡在面板的位置
                //获取气泡控件
                EQBaseControl talk_panel = eqBase.GetRecombinedPanel();
                //talk_panel.Location = new Point(Message_panel.Width - talk_panel.Width - 10, 0);
                if (talk_panel is EQRemindControl)
                    talk_panel.Anchor = AnchorStyles.None;
                else
                {
                    if (isOneSelf)
                        talk_panel.Anchor = (AnchorStyles.Right | AnchorStyles.Top);
                    else
                        talk_panel.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
                }
                #endregion

                showInfo_Panel.SuspendLayout();
                //第一条消息对列表进行初始化
                if (showInfo_Panel.RowCount == 1)
                {
                    showInfo_Panel.RowStyles.Clear();
                    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 45));
                    //showInfo_Panel.RowStyles[0].Height = 50;
                    AddMoreMessageLabe();
                }

                //添加时间气泡
                AddSendTime(eqBase, messageObject);

                //添加新的行
                showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
                showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, talk_panel.Height));

                //添加多选复选框
                if (EQControlManager.JudgeIsBubleMsg(messageObject.type))
                {
                    CheckBoxEx checkBox = new CheckBoxEx();
                    checkBox.Text = "";
                    checkBox.Size = new Size(20, 20);
                    //checkBox.Visible = false;
                    checkBox.Anchor = AnchorStyles.None;
                    showInfo_Panel.Controls.Add(checkBox, 0, showInfo_Panel.RowCount - 1);
                }

                //添加聊天气泡
                talk_panel.Name = "talk_panel_" + messageObject.messageId;
                showInfo_Panel.Controls.Add(talk_panel, 1, showInfo_Panel.RowCount - 1);
                showInfo_Panel.ResumeLayout();
                //修改群员名称
                ModifyLabName(talk_panel, messageObject.fromUserId);

                //发送已读通知（无复选框代表不是消息气泡），不显示红点的才直接发送已读
                if (messageObject.isRead != 1 && !talk_panel.isShowRedPoint && messageObject.isReadDel == 0)
                {
                    //只对别人的消息发送已读
                    if (messageObject.fromUserId != Applicate.MyAccount.userId)
                    {
                        //if (choose_target.showRead == 1)
                        //{
                        //    messageObject.readPersons++;
                        //    messageObject.UpdateReadPersons();
                        //    DrawIsRead(messageObject);
                        //}
                        ShiKuManager.SendReadMessage(choose_target, messageObject);
                    }
                }

                #region 是否添加邀请入群点击事件
                //如果为RoomIsVerify则需要点击事件，确认进群
                if (messageObject.type == kWCMessageType.RoomIsVerify)
                {
                    talk_panel.MouseDown += (sender, e) =>
                    {
                        if (e.Button == MouseButtons.Left)
                        {
                            if (choose_target.IsGroup != 1)
                                return;

                            FrmInviteToGroup frmInviteToGroup = new FrmInviteToGroup();
                            frmInviteToGroup.AcceptMessage = messageObject;
                            frmInviteToGroup.Getfriend = choose_target;
                            frmInviteToGroup.Show();
                        }
                    };
                }
                #endregion

                //添加已读人数点击事件
                SetReadPerson_Click(messageObject, talk_panel);

                //如果是自己的消息，要滚到底部
                if ((Takeconter_panel.Height - showInfo_Panel.Height) <= 0 && messageObject.fromUserId == Applicate.MyAccount.userId)
                    ShowInfoVScroll.SetVScroolToBottom();

                //往字典中记录当前行
                messageObject.rowIndex = showInfo_Panel.RowCount - 1;
                //});
            });
            if (this.IsHandleCreated)
                Invoke(action);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="msg"></param>
        /// <param name="row_index">控件需要添加的位置</param>
        /// <returns></returns>
        private EQBaseControl GetMessagePanel(MessageObject msg, int row_index)
        {

            #region 过滤消息
            if (choose_target == null)
                return null;
            //正在输入。。通知
            if (msg.type == kWCMessageType.Typing)
            {
                if (msg.fromUserId == choose_target.UserId)
                    IsShowTyping();
                return null;
            }
            //不生成气泡的消息类型
            if (!msg.IsVisibleMsg() && msg.type != kWCMessageType.RoomIsVerify)
                return null;
            //已存在该气泡控件
            if (showInfo_Panel.Controls["talk_panel_" + msg.messageId] != null)
                return null;
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
                    default:
                        return null;
                }
            }

            #region 判断消息是否为当前聊天对象的
            //多点登录的FromId也是自己，需要判断ToId是否为当前对象
            if (msg.FromId == Applicate.MyAccount.userId)
            {
                if (msg.ToId != choose_target.UserId)
                    return null;
            }
            //FromId和ToId必须是自己和当前聊天对象，FromId或者ToId为自己时，另一个必定为聊天对象
            else if (msg.FromId == choose_target.UserId)
            {
                if (msg.ToId != Applicate.MyAccount.userId)
                    return null;
            }
            //FromId既不是自己也不是聊天对象，该消息必定不为该聊天页面
            else
                return null;
            #endregion

            //过期消息
            if (msg.deleteTime < TimeUtils.CurrentTimeDouble() && msg.deleteTime > 0)
            {
                msg.DeleteData();
                return null;
            }
            #endregion

            //如果是对方发送的消息
            targetMsgData.AddMsgData(msg);

            bool isOneSelf = string.Equals(msg.fromUserId, Applicate.MyAccount.userId);     //判断是否为本人发送的消息

            //获取控件的类型
            //KWTypeControlsDictionary kWTypeControls = new KWTypeControlsDictionary(msg);
            //EQBaseControl eqBase = kWTypeControls.GetObjectByType();
            EQBaseControl eqBase = KWTypeControlsDictionary.GetObjectByType(msg);

            //是否显示群已读人数
            if (choose_target.IsGroup == 1)
                eqBase.isShowLabMsg = choose_target.ShowRead == 1 ? true : false;
            //是否显示阅后即焚
            if (choose_target.IsGroup == 0)
                eqBase.isReadDel = msg.isReadDel == 1 ? true : false;
            //含有阅后即焚消息
            if (eqBase.isReadDel)
                isHaveReadDel = 1;

            //获取气泡控件
            EQBaseControl talk_panel = eqBase.GetRecombinedPanel();
            talk_panel.Name = "talk_panel_" + msg.messageId;
            //talk_panel.Location = new Point(Message_panel.Width - talk_panel.Width - 10, 0);
            if (eqBase is EQRemindControl)
                talk_panel.Anchor = AnchorStyles.None;
            else
            {
                if (isOneSelf)
                    talk_panel.Anchor = (AnchorStyles.Right | AnchorStyles.Top);
                else
                    talk_panel.Anchor = (AnchorStyles.Left | AnchorStyles.Top);
            }

            //添加已读人数点击事件
            SetReadPerson_Click(msg, talk_panel);

            //获取字典中存储的message
            MessageObject messageObject = targetMsgData.GetMsg(msg.messageId);
            //往字典中记录当前行
            if (messageObject != null)
                messageObject.rowIndex = row_index;

            return talk_panel;
        }
        /// <summary>
        /// 往消息列表插入控件
        /// </summary>
        /// <param name="talk_panel">需要插入的控件</param>
        /// <param name="row_index">目标行</param>
        public void InsertControlToRow(EQBaseControl talk_panel, int row_index, MessageObject messageObject)
        {
            if (showInfo_Panel.Controls[talk_panel.Name] != null)
                return;

            //多选复选框
            if (EQControlManager.JudgeIsBubleMsg(messageObject.type))
            {
                CheckBoxEx checkBox = new CheckBoxEx();
                checkBox.Text = "";
                checkBox.Size = new Size(20, 20);
                checkBox.Anchor = AnchorStyles.None;
                //checkBox.Visible = false;
                showInfo_Panel.Controls.Add(checkBox, 0, row_index);
            }

            //发送已读通知（无复选框代表不是消息气泡），不显示红点的才直接发送已读
            if (messageObject.isRead != 1 && !talk_panel.isShowRedPoint && messageObject.isReadDel == 0)
            {
                //只对别人的消息发送已读
                if (messageObject.fromUserId != Applicate.MyAccount.userId)
                {
                    //if (choose_target.showRead == 1)
                    //{
                    //    messageObject.readPersons++;
                    //    messageObject.UpdateReadPersons();
                    //    DrawIsRead(messageObject);
                    //}
                    ShiKuManager.SendReadMessage(choose_target, messageObject);
                }
            }

            //如果为RoomIsVerify则需要点击事件，确认进群
            if (messageObject.type == kWCMessageType.RoomIsVerify)
            {
                talk_panel.MouseDown += (sender, e) =>
                {
                    if (e.Button == MouseButtons.Left)
                    {
                        if (choose_target.IsGroup != 1)
                            return;

                        FrmInviteToGroup frmInviteToGroup = new FrmInviteToGroup();
                        frmInviteToGroup.AcceptMessage = messageObject;
                        frmInviteToGroup.Getfriend = choose_target;
                        frmInviteToGroup.Show();
                    }
                };
            }

            //添加聊天气泡
            showInfo_Panel.Controls.Add(talk_panel, 1, row_index);
        }
        #endregion

        #region 发送按钮点击事件
        private void btnSend_Click(object sender, EventArgs e)
        {
            //选择对象不能为空
            if (choose_target == null || string.IsNullOrEmpty(choose_target.UserId))
                return;

            //如果当前为禁言中
            if (isBannedTalk || !btnSend.Visible)
                return;

            if (fileCollect.Count != 0)
            {
                DroupFeileSend();

            }
            else
            {
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
                    Friend fdSend = choose_target;

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
                        strSend = EmojiPngToCode(rtfSend, eji_codes);
                        //用于rtf的转化
                        RichTextBox richTextBox = new RichTextBox();
                        richTextBox.Rtf = strSend;

                        #region 解析图片并单独发送
                        try
                        {
                            List<Image> list_images = new List<Image>();
                            //用正则表达式，获取图片rtf
                            MatchCollection matchs = Regex.Matches(richTextBox.Rtf, @"{\\pict[^}]+}", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                            foreach (Match item in matchs)
                            {
                                //richTextBox.Rtf = richTextBox.Rtf.Replace(item.Value, "");
                                ////保存图片到本地
                                //string filePath = EQControlManager.RtfToImageSave(item.Value);

                                ////发送图片
                                //if (!string.IsNullOrEmpty(filePath))
                                //{
                                //    //添加气泡到列表
                                //    MessageObject msg = ShiKuManager.SendImageMessage(fdSend, "", filePath, Convert.ToInt32(new FileInfo(filePath).Length), false);
                                //    JudgeMsgIsAddToPanel(msg);

                                //    UploadEngine.Instance.From(filePath).
                                //        //上传中
                                //        UpProgress((progress) =>
                                //        {

                                //        }).
                                //        //上传完成
                                //        UploadFile((success, url_path) =>
                                //        {
                                //            MessageObject t_msg = targetMsgData.GetMsg(msg.messageId);
                                //            if (t_msg != null)
                                //            {
                                //                //修改气泡的图片和样式
                                //                string name = "talk_panel_" + t_msg.messageId;
                                //                if (showInfo_Panel.Controls.Find(name, true).Length > 0 && showInfo_Panel.Controls.Find(name, true)[0] is EQImageControl imageCrl)
                                //                {
                                //                    UploadImage(imageCrl, t_msg, url_path, success);
                                //                }
                                //            }
                                //            //如果当前聊天对象已切换，则不更新UI只发送
                                //            if (!choose_target.userId.Equals(msg.fromUserId) && success)
                                //            {
                                //                msg.content = url_path;
                                //                msg.UpdateMessageContent();
                                //                ShiKuManager.xmpp.SendMessage(msg);
                                //            }
                                //        });
                                //}
                            }

                        }
                        catch (Exception ex)
                        {
                            LogHelper.log.Error("----解析图片出错，方法（btnSend_Click） : " + ex.Message);
                        }
                        #endregion

                        //发送文本消息
                        if (!string.IsNullOrEmpty(strSend) && !string.IsNullOrWhiteSpace(richTextBox.Text))
                        {
                            MessageObject msg = null;
                            //回复消息
                            if (replyMsg != null && !string.IsNullOrEmpty(replyMsg.messageId))
                                msg = ShiKuManager.SendReplayMessage(fdSend, replyMsg, richTextBox.Text, false);
                            else
                            {
                                if (at_count > 0)
                                    msg = ShiKuManager.SendAtMessage(fdSend, atFriends, richTextBox.Text, false);
                                else
                                    msg = ShiKuManager.SendTextMessage(fdSend, richTextBox.Text.TrimEnd(), false);

                            }
                            JudgeMsgIsAddToPanel(msg);     //添加消息气泡
                            ShiKuManager.xmpp.SendMessage(msg);//指定发送的UserId
                        }

                        //滚动到底部
                        //if ((Takeconter_panel.Height - showInfo_Panel.Height) <= 0)
                        //    ShowInfoVScroll.SetVScroolToBottom();

                    });
                    if (this.IsHandleCreated)
                    {
                        sendThread.SetApartmentState(ApartmentState.STA);
                        sendThread.Start();
                    }
                }
                catch (Exception ex) { LogHelper.log.Error("----发送消息出错，方法（btnSend_Click） : " + ex.Message, ex); }

                //清空发送框
                txtSend.Focus();
                txtSend.Clear();
                emoji_num = 0;
                emoji_codes = new List<string>();
                atCount = 0;
                list_atFriends = new List<Friend>();

                //清空回复面板
                if (!string.IsNullOrEmpty(replyPanel.ReplyMsg.messageId))
                {
                    replyPanel.ReplyMsg = new MessageObject();
                    replyPanel.SendToBack();
                }
            }
        }
        #endregion

        #region 选择表情
        private void lblExpression_MouseEnter(object sender, EventArgs e)
        {
            lblExpression.Image = Resources.ExpressionBase;
            lblExpression.Cursor = Cursors.Hand;
        }

        private void lblExpression_MouseLeave(object sender, EventArgs e)
        {
            lblExpression.Image = Resources.ExpressionNormal;
            lblExpression.Cursor = Cursors.Default;
        }

        #region 点击弹出表情选择框
        private void lblExpression_MouseClick(object sender, MouseEventArgs e)
        {
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
            frmExpressionTab.SetFriendTarget(choose_target);
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
                string emojiRtf = EmojiCodeDictionary.GetEmojiRtfByCode(emojiCode);
                if (!string.IsNullOrWhiteSpace(emojiRtf))
                    new_rtf = new_rtf.Replace(emojiRtf, emojiCode);
            }
            return new_rtf;
        }

        private string subRtf(string emoji_rtf)
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
        private string GetEmoji(string ric_text, Color bg_cloor)
        {
            RichTextBox richTextBox = new RichTextBox();
            richTextBox.Text = ric_text;
            //匹配符合规则的表情code
            MatchCollection match = Regex.Matches(richTextBox.Text, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            string[] newStr = new string[match.Count];
            //不用做记录的变量
            int index = 0;
            foreach (Match item in match)
            {
                newStr[index] = item.Groups[0].Value;
                index++;
            }

            //循环替换code为表情图片
            for (int i = 0; i < newStr.Length; i++)
            {
                //获取表情code在RichTextBox的位置
                index = richTextBox.Text.IndexOf(newStr[i]);
                //表情code去除[]
                string image_name = newStr[i].Replace("[", "").Replace("]", "");
                //给剪切板设置图片对象
                string path = string.Format(@"Res\Emoji\{0}.png", image_name);
                if (!File.Exists(path))
                    break;

                //获取RichTextBox控件中鼠标焦点的索引位置
                richTextBox.SelectionStart = index;
                //从鼠标焦点处开始选中几个字符
                richTextBox.SelectionLength = newStr[i].Length;
                //清空剪切板，防止里面之前有内容
                Clipboard.Clear();
                Bitmap bmp = new Bitmap(path);
                Bitmap newBmp = new Bitmap(25, 25);
                Graphics g = Graphics.FromImage(newBmp);
                //g.Clear(bg_cloor);

                //画圆形
                GraphicsPath gpath = new GraphicsPath();
                gpath.AddEllipse(0, 0, 25, 25);
                g.SmoothingMode = SmoothingMode.AntiAlias;
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.CompositingQuality = CompositingQuality.HighQuality;
                g.SetClip(gpath);

                g.DrawImage(bmp, new Rectangle(0, 0, 25, 25), new Rectangle(0, 0, bmp.Width, bmp.Height), GraphicsUnit.Pixel);
                g.Dispose();
                Clipboard.SetImage(newBmp);
                //将图片粘贴到鼠标焦点位置(选中的字符都会被图片覆盖)
                richTextBox.Paste();
                Clipboard.Clear();
            }

            string result = richTextBox.Rtf;
            richTextBox.Dispose();
            return result;
        }
        #endregion

        #region RtfToEmoji
        /// <summary>
        /// 传递含有emoji code的文本，返回转化为图片后的rtf字符串
        /// </summary>
        /// <param name="ric_text">含有emoji code的文本</param>
        /// <param name="bg_cloor">填充绘画底色的背景色</param>
        /// <returns></returns>
        private string GetEmojiByRtf(string ric_rtf, Color bg_cloor)
        {
            RichTextBox richTextBox = new RichTextBox();
            richTextBox.Rtf = ric_rtf;
            //匹配符合规则的表情code
            MatchCollection match = Regex.Matches(richTextBox.Text, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            string[] newStr = new string[match.Count];
            //不用做记录的变量
            int index = 0;
            foreach (Match item in match)
            {
                newStr[index] = item.Groups[0].Value;
                index++;
            }

            //循环替换code为表情图片
            for (int i = 0; i < newStr.Length; i++)
            {
                //获取表情code在RichTextBox的位置
                index = richTextBox.Text.IndexOf(newStr[i]);
                //表情code去除[]
                string image_name = newStr[i].Replace("[", "").Replace("]", "");
                //给剪切板设置图片对象
                string path = string.Format(@"Res\Emoji\{0}.png", image_name);
                if (!File.Exists(path))
                    break;

                //获取RichTextBox控件中鼠标焦点的索引位置
                richTextBox.SelectionStart = index;
                //从鼠标焦点处开始选中几个字符
                richTextBox.SelectionLength = newStr[i].Length;
                //清空剪切板，防止里面之前有内容
                Clipboard.Clear();
                Bitmap bmp = new Bitmap(path);
                Bitmap newBmp = new Bitmap(25, 25);
                Graphics g = Graphics.FromImage(newBmp);
                g.Clear(bg_cloor);

                g.InterpolationMode = InterpolationMode.HighQualityBicubic;

                g.DrawImage(bmp, new Rectangle(0, 0, 25, 25), new Rectangle(0, 0, bmp.Width, bmp.Height), GraphicsUnit.Pixel);
                g.Dispose();
                Clipboard.SetImage(newBmp);
                //将图片粘贴到鼠标焦点位置(选中的字符都会被图片覆盖)
                richTextBox.Paste();
                Clipboard.Clear();
            }

            string result = richTextBox.Rtf;
            richTextBox.Dispose();
            return result;
        }
        #endregion
        #endregion

        #region 修改发送按钮悬浮时颜色
        private void btnSend_MouseEnter(object sender, EventArgs e)
        {
            btnSend.ForeColor = Color.White;
        }

        private void btnSend_MouseLeave(object sender, EventArgs e)
        {
            btnSend.ForeColor = Color.Black;
        }
        #endregion

        #region Send File
        #region 文件发送
        private void lblSendFile_MouseDown(object sender, MouseEventArgs e)
        {
            OpenFileDialog dialog = new OpenFileDialog();
            dialog.Multiselect = true;//该值确定是否可以选择多个文件
            dialog.Title = "请选择文件夹";
            dialog.Filter = "所有文件 (*.*)|*.*" +
                "|图像 (*.jpg;*.jpeg;*.png)|*.jpg;*.jpeg;*.png" +
                "|视频 (*.avi;*.mp4;*.rmvb;*.flv)|*.avi;*.mp4;*.rmvb;*.flv";

            //完成选择图片的操作
            if (dialog.ShowDialog() == DialogResult.OK)
            {
                foreach (string file in dialog.FileNames)
                {
                    bool isVideo = FileUtils.JudgeIsVideoFile(file);
                    //如果为视频文件
                    if (isVideo)
                    {
                        //先生成气泡
                        int fileSize = Convert.ToInt32(new FileInfo(file).Length);
                        MessageObject msg = ShiKuManager.SendVideoMessage(choose_target, "", file, fileSize, false);
                        JudgeMsgIsAddToPanel(msg);
                        
                        //获取气泡
                        string name = "talk_panel_" + msg.messageId;
                        if (showInfo_Panel.Controls.Find(name, true).Length > 0 && showInfo_Panel.Controls.Find(name, true)[0] is EQBaseControl talk_panel)
                        {
                            UploadEngine.Instance.From(file).
                            //上传中
                            UpProgress((progress) =>
                            {

                            }).
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

        #region 上传文件
        private void UploadFileOrImage(string fileLocation, int fileSize)
        {
            try
            {
                MessageObject msg = null;
                if (JudgeIsImage(fileLocation))
                    msg = ShiKuManager.SendImageMessage(choose_target, "", fileLocation, fileSize, false);
                else
                    msg = ShiKuManager.SendFileMessage(choose_target, "", fileLocation, fileSize, false);
                //添加气泡
                JudgeMsgIsAddToPanel(msg);

                //获取气泡
                string name = "talk_panel_" + msg.messageId;
                if (showInfo_Panel.Controls.Find(name, true).Length > 0 && showInfo_Panel.Controls.Find(name, true)[0] is EQBaseControl talk_panel)
                {
                    UploadEngine.Instance.From(fileLocation).
                    //上传中
                    UpProgress((progress) =>
                    {
                        if (talk_panel is EQFileControl)
                        {
                            //获取到文件的panel
                            if (talk_panel.Controls.Find("image_panel", true).Length > 0 && talk_panel.Controls.Find("image_panel", true)[0] is Panel image_panel)
                                if (image_panel.Controls.Find("crl_content", true).Length > 0 && image_panel.Controls.Find("crl_content", true)[0] is FilePanelLeft filePanel)
                                {
                                    filePanel.lab_lineLime.BringToFront();
                                    filePanel.lab_lineLime.Width = Convert.ToInt32(filePanel.lab_lineSilver.Width * ((decimal)progress / 100));
                                    if ((progress / 100) == 1)
                                        filePanel.lab_lineLime.Width = 0;
                                }
                        }
                    }).
                    UpSpeed((speed)=> 
                    {
                        if (talk_panel is EQFileControl)
                        {
                            //获取到文件的panel
                            if (talk_panel.Controls.Find("image_panel", true).Length > 0 && talk_panel.Controls.Find("image_panel", true)[0] is Panel image_panel)
                                if (image_panel.Controls.Find("crl_content", true).Length > 0 && image_panel.Controls.Find("crl_content", true)[0] is FilePanelLeft filePanel)
                                {
                                    filePanel.lblSpeed.Visible = true;
                                    filePanel.lblSpeed.BringToFront();
                                    filePanel.lblSpeed.Text = speed + @"/s";
                                }
                        }
                    }).
                    //上传完成
                    UploadFile((success, url) =>
                    {
                        if (msg.type == kWCMessageType.File)
                        {
                            if (talk_panel is EQFileControl)
                            {
                                //获取到文件的panel
                                if (talk_panel.Controls.Find("image_panel", true).Length > 0 && talk_panel.Controls.Find("image_panel", true)[0] is Panel image_panel)
                                    if (image_panel.Controls.Find("crl_content", true).Length > 0 && image_panel.Controls.Find("crl_content", true)[0] is FilePanelLeft filePanel)
                                        //关闭下载速度
                                        filePanel.lblSpeed.Visible = false;
                            }
                            msg.content = url;
                            msg.UpdateMessageContent();
                            if (success)
                                ShiKuManager.xmpp.SendMessage(msg);
                        }
                        else if (msg.type == kWCMessageType.Image)
                            UploadImage(talk_panel, msg, url, success);
                        ////上传失败
                        //if (string.IsNullOrEmpty(url) || !success)
                        //    return;

                        //msg = MessageObjectDataDictionary.GetMsg(msg.messageId);
                        //if (MessageObjectDataDictionary.GetMsg(msg.messageId) != null)
                        //{
                        //    msg.content = url;
                        //    msg.UpdateMessageContent();
                        //    ShiKuManager.xmpp.SendMessage(msg);

                        //    //修改气泡的图片和样式
                        //    if (msg.type == kWCMessageType.Image)
                        //    {
                        //        if (talk_panel is EQImageControl imageCrl)
                        //            if (imageCrl.Controls.Find("crl_content", true).Length > 0 && imageCrl.Controls.Find("crl_content", true)[0] is PictureBox pic_image)
                        //                imageCrl.LoadImage(msg.content, pic_image);
                        //    }
                        //}
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
            msg = targetMsgData.GetMsg(msg.messageId);
            if (targetMsgData.GetMsg(msg.messageId) == null)
                return;
            //修改气泡的图片和样式
            if (talk_panel is EQImageControl imageCrl)
            {
                if (imageCrl.Controls.Find("crl_content", true).Length > 0 && imageCrl.Controls.Find("crl_content", true)[0] is PictureBox pic_image)
                {
                    //上传失败
                    if (string.IsNullOrEmpty(url) || !success)
                    {
                        msg.isSend = -1;
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
                        msg.content = url;
                        msg.UpdateMessageContent();
                        ShiKuManager.xmpp.SendMessage(msg);
                        imageCrl.LoadImage(pic_image);
                    }
                }
            }
        }
        #endregion

        #region 上传视频
        private void UploadVideo(EQBaseControl talk_panel, MessageObject msg, string url, bool success)
        {
            msg = targetMsgData.GetMsg(msg.messageId);
            if (targetMsgData.GetMsg(msg.messageId) != null)
            {
                //修改气泡的图片和样式
                if (talk_panel is EQVideoControl videoCrl)
                {
                    if (videoCrl.Controls.Find("crl_content", true).Length > 0 && videoCrl.Controls.Find("crl_content", true)[0] is PictureBox pic_content)
                    {
                        //上传失败
                        if (string.IsNullOrEmpty(url) || !success)
                        {
                            msg.isSend = -1;
                            msg.content = "error";
                            //关闭等待符
                            if (pic_content.Controls.Find("loding", true).Length > 0 && pic_content.Controls.Find("loding", true)[0] is USELoding loding)
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
                            msg.content = url;
                            msg.UpdateMessageContent();
                            ShiKuManager.xmpp.SendMessage(msg);
                            videoCrl.LoadVideo(pic_content);
                        }
                    }
                }
            }
        }
        #endregion

        #region 判断是否为图片
        private bool JudgeIsImage(string fileName)
        {
            try
            {
                Image img = Image.FromFile(fileName);
                if (img.RawFormat.Equals(ImageFormat.Jpeg))
                    return true;
                if (img.RawFormat.Equals(ImageFormat.Png))
                    return true;
                if (img.RawFormat.Equals(ImageFormat.Bmp))
                    return true;
                if (img.RawFormat.Equals(ImageFormat.MemoryBmp))
                    return true;
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
        #region 删除
        private void menuItem_Delete_Click(object sender, EventArgs e)
        {
            if (selectControl.Name.IndexOf("talk_panel_") < 0)
                return;

            string messageId = selectControl.Name.Replace("talk_panel_", "");
            EQMenuStripControl.menuItem_Delete_Click(this.showInfo_Panel, messageId, ref lastMsgTime, choose_target.UserId);
        }
        #endregion

        #region 撤回
        private void menuItem_Recall_Click(object sender, EventArgs e)
        {
            if (selectControl == null || selectControl.Name.IndexOf("talk_panel_") < 0)
                return;
            string messageId = selectControl.Name.Replace("talk_panel_", "");
            MessageObject messageObject = targetMsgData.GetMsg(messageId);

            //重新创建一个msg
            MessageObject copyMsg = messageObject.CopyMessage();
            copyMsg.type = kWCMessageType.Remind;
            copyMsg.content = "你撤回了一条消息";
            //避免重复右键菜单，先更新UI
            EQMenuStripControl.menuItem_Recall_Click(this.showInfo_Panel, copyMsg, choose_target == null ? "" : choose_target.UserId);

            //调用接口
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "tigase/deleteMsg"). //删除群组
                AddParams("access_token", Applicate.Access_Token).
                AddParams("type", messageObject.isGroup == 0 ? "1" : "2").    //1 单聊  2 群聊
                AddParams("delete", "2").   //1： 删除属于自己的消息记录 2：撤回 删除整条消息记录
                AddParams("messageId", messageObject.messageId).
                AddParams("roomJid", messageObject.toUserId).
                Build().ExecuteJson<object>((sccess, obj) =>   //返回值说明： text：加密后的内容
                {
                    //删除成功
                    if (sccess)
                    {
                        ShiKuManager.SendRecallMessage(messageObject.GetFriend(), messageObject);
                        //int result = messageObject.UpdateData();
                        HttpUtils.Instance.ShowTip("撤回成功");
                    }
                });
        }
        #endregion

        #region 复制
        private void menuItem_Copy_Click(object sender, EventArgs e)
        {
            MessageObject msg = GetMsgBySelectCrl();
            switch (msg.type)
            {
                case kWCMessageType.Image:
                    //清空剪切板，防止里面之前有内容
                    Clipboard.Clear();
                    //给剪切板设置图片对象
                    PictureBox picBox = crl_content as PictureBox;
                    Image image = picBox.BackgroundImage;
                    //Bitmap bitmap = new Bitmap(image);
                    Clipboard.SetImage(image);
                    break;
                case kWCMessageType.Text:
                    //清空剪切板，防止里面之前有内容
                    Clipboard.Clear();
                    //给剪切板设置图片对象
                    RichTextBox richTextBox = crl_content as RichTextBox;
                    string content = richTextBox.Tag.ToString();
                    Clipboard.SetText(content);
                    break;
                case kWCMessageType.Replay:
                    //清空剪切板，防止里面之前有内容
                    Clipboard.Clear();
                    //给剪切板设置图片对象
                    //RichTextBox richTextBox = crl_content as RichTextBox;
                    //string content = richTextBox.Tag.ToString();
                    Clipboard.SetText(msg.content);
                    break;
                default:
                    break;
            }
        }
        #endregion

        #region 转发
        private void menuItem_Relay_Click(object sender, EventArgs e)
        {
            //获取选择的Message
            if (selectControl == null || selectControl.Name.IndexOf("talk_panel_") < 0)
                return;
            string messageId = selectControl.Name.Replace("talk_panel_", "");
            MessageObject messageObject = targetMsgData.GetMsg(messageId);

            //选择转发的好友
            var frmFriendSelect = new FrmFriendSelect();
            frmFriendSelect.LoadFriendsData(1);
            frmFriendSelect.AddConfrmListener((UserFriends) =>
            {
                foreach (var friend in UserFriends.Values)
                {
                    MessageObject msg = ShiKuManager.SendForwardMessage(friend, messageObject);
                    //如果转发对象包括当前聊天对象，给UI添加消息气泡
                    if (friend.UserId == choose_target.UserId)
                    {
                        //添加消息气泡通知
                        JudgeMsgIsAddToPanel(msg);
                    }
                }
            });
        }
        #endregion

        #region 多选
        private void IsShowInfoShade(bool isShow)
        {
            //启用状态
            if (isShow)
            {
                ShowInfoShade.Visible = true;
                ShowInfoShade.Enabled = true;
                ShowInfoShade.Location = showInfo_Panel.Location;
                ShowInfoShade.Size = showInfo_Panel.Size;
                ShowInfoShade.BringToFront();
            }
            else
            {
                ShowInfoShade.Visible = false;
                ShowInfoShade.Enabled = false;
                ShowInfoShade.Size = new Size(0, 0);
                ShowInfoShade.SendToBack();
            }
        }

        /// <summary>
        /// 开启多选
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void menuItem_MultiSelect_Click(object sender, EventArgs e)
        {
            //清空之前被多选的集合
            multiSelectPanel1.List_Msgs = new List<MessageObject>();
            multiSelectPanel1.FdTalking = choose_target;
            //展示多选
            IsShowPanelMultiSelect(true);

            //设置透明panel用于捕捉多选点击事件的点击行
            IsShowInfoShade(true);
        }
        #endregion

        #region 收藏
        private void menuItem_Collect_Click(object sender, EventArgs e)
        {
            //获取选择的Message
            if (selectControl == null || selectControl.Name.IndexOf("talk_panel_") < 0)
                return;
            string messageId = selectControl.Name.Replace("talk_panel_", "");
            MessageObject messageObject = targetMsgData.GetMsg(messageId);

            CollectUtils.CollectMessage(messageObject);

        }
        #endregion

        #region 回复
        private void menuItem_Reply_Click(object sender, EventArgs e)
        {
            MessageObject msg = GetMsgBySelectCrl();
            replyPanel.lblContent.Text = EQControlManager.ChangeContentByType(msg);
            replyPanel.ReplyMsg = msg;
            replyPanel.BringToFront();
            //replyPanel.Visible = true;
        }
        #endregion

        #region 打开文件夹
        private void menuItem_OpenFileFolder_Click(object sender, EventArgs e)
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
        private void menuItem_SaveAs_Click(object sender, EventArgs e)
        {
            MessageObject msg = GetMsgBySelectCrl();
            //选择文件夹路径
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            dialog.Description = "另存为..";
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
        private void menuItem_Dowmload_Click(object sender, EventArgs e)
        {
            MessageObject msg = GetMsgBySelectCrl();
            if (msg.type == kWCMessageType.File)
            {
                //文件的本地路径
                string localPath = Applicate.LocalConfigData.FileFolderPath + FileUtils.GetFileName(msg.fileName);
                DownloadFile(msg, localPath);
            }
        }
        #endregion

        #region 存表情
        private void menuItem_SaveCustomize_Click(object sender, EventArgs e)
        {
            MessageObject msg = GetMsgBySelectCrl();
            // http收藏表情
            CollectUtils.CollectExpression(msg);
        }
        #endregion

        #region 录制
        private int isStartTrans = 0;       //是否开始录制
        private int startTransIndex = 0;    //开始录制的行号
        private int endTransIndex = 0;      //结束录制的行号
        private void menuItem_Transcribe_Click(object sender, EventArgs e)
        {
            isStartTrans = isStartTrans == 1 ? 0 : 1;
            menuItem_Transcribe.Text = isStartTrans == 1 ? "停止录制" : "开始录制";

            //开始录制
            if (isStartTrans == 1)
                startTransIndex = GetMsgBySelectCrl().rowIndex;
            //结束录制
            else
            {
                endTransIndex = GetMsgBySelectCrl().rowIndex;
                FrmMyColleagueEidt frmMyColleagueEidt = new FrmMyColleagueEidt();

                frmMyColleagueEidt.ColleagueName((data) =>
                {
                    TeachUlUtils.CourseMade(data, startTransIndex, endTransIndex, targetMsgData);
                    frmMyColleagueEidt.Close();
                });

                frmMyColleagueEidt.ShowThis("课程录制", "课程名称");
            }
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
                rowIndex = showInfo_Panel.GetRow(selectControl);    //记录被选中行

                MessageObject msg = targetMsgData.GetMsg(selectControl.Name.Replace("talk_panel_", ""));
                //判断是否为本人
                bool isOneself = msg.fromUserId != Applicate.MyAccount.userId ? false : true;
                //设置右键菜单的可见度
                if (msg != null)
                    new KWTypeMenuStripDictionary().SettingMenuStripVisible(ref cmsMsgMenu, msg.type, isOneself);
                //如果自己为群主或管理员，则可以撤回所有信息
                if (choose_target.IsGroup == 1 && JudgeIsAdmin(Applicate.MyAccount.userId))
                    cmsMsgMenu.Items["menuItem_Recall"].Visible = true;
                //所有自己的消息都可以进行录制（只能往后录制）
                if (msg.fromUserId == Applicate.MyAccount.userId)
                    if ((isStartTrans == 1 && startTransIndex < msg.rowIndex) || isStartTrans == 0)
                        cmsMsgMenu.Items["menuItem_Transcribe"].Visible = true;
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
        #endregion

        #region 列表气泡添加和移除触发事件
        private void showInfo_Panel_ControlAdded(object sender, ControlEventArgs e)
        {
            //如果添加复选框不处理
            if (e.Control is CheckBoxEx)
                return;

            #region 滚动到底部
            if (showInfo_Panel.Top == (Takeconter_panel.Height - showInfo_Panel.Height))
            {
                showInfo_Panel.Top -= e.Control.Height;
            }
            #endregion

            #region 正在从顶部加载历史记录
            if (ShowInfoVScroll.canAdd == 0)
            {
                showInfo_Panel.Top -= e.Control.Height;
                //更新滚动条的位置
                ShowInfoVScroll.UpdateVScrollLocation();
            }
            #endregion

            //高度自适应
            if (e.Control is Label && e.Control.Name.Equals("labMoreMsg"))
            {
                showInfo_Panel.Height += 45;
                ShowInfoShade.Height = showInfo_Panel.Height;
            }
            else
            {
                showInfo_Panel.Height += e.Control.Height;
                ShowInfoShade.Height = showInfo_Panel.Height;
            }
            //自动调整高度和滚动条
            //ShowInfoVScroll.UpdateVScrollLocation();

            //不是添加聊天气泡的直接跳出
            if (e.Control.GetType().Name.IndexOf("EQ") < 0)
                return;

            //如果添加的气泡为最新一条消息
            //if (!string.IsNullOrEmpty(e.Control.Name))
            //{
            //    string msgId = e.Control.Name.Replace("talk_panel_", "");
            //    if (msgId.Equals(readMsgId))
            //    {
            //        int rowIndex = showInfo_Panel.RowCount - 1;
            //        EQNewsMsgHint newsMsgHint = new EQNewsMsgHint();
            //        showInfo_Panel.RowCount++;
            //        showInfo_Panel.RowStyles.Insert(rowIndex, new RowStyle(SizeType.Absolute, newsMsgHint.Height));
            //        //控件下移
            //        showInfo_Panel.SetRow(e.Control, rowIndex + 1);
            //        newsMsgHint.Anchor = AnchorStyles.None;
            //        showInfo_Panel.Controls.Add(newsMsgHint, 1, rowIndex);
            //    }
            //}

            #region 添加右键菜单
            foreach (Control item in e.Control.Controls)
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
            #endregion
        }

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

        private void showInfo_Panel_ControlRemoved(object sender, ControlEventArgs e)
        {
            //如果添加复选框不处理
            if (e.Control is CheckBoxEx)
                return;

            if (e.Control is Label)
            {
                //高度自适应
                showInfo_Panel.Height -= e.Control.Height;    //不止为何，会有6个像素偏移
                ShowInfoShade.Height = showInfo_Panel.Height;
            }
            else
            {
                //高度自适应
                showInfo_Panel.Height -= (e.Control.Height + 6);    //不止为何，会有6个像素偏移
                ShowInfoShade.Height = showInfo_Panel.Height;
            }
            //自动调整高度和滚动条
            ShowInfoVScroll.UpdateVScrollLocation();
            //设置滚动条是否可见
            //if (showInfo_Panel.Height - Takeconter_panel.Height > 0)
            //    ShowInfoVScroll.Visible = true;
            //else
            //    ShowInfoVScroll.Visible = false;

            //如果控件是消息气泡类型
            if (e.Control is EQBaseControl talk_panel)
            {
                string msgId = talk_panel.Name.Replace("talk_panel_", "");
                MessageObject msg = targetMsgData.GetMsg(msgId);

                if (msg == null || string.IsNullOrEmpty(msg.messageId))
                    return;

                UpdateSendTime(msg);
            }
        }
        #endregion

        #region 点击弹出设置页
        FrmSuspension frmSet;   //设置页
        private void lab_detial_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (choose_target == null)
                    return;
                
                //如果聊天对象为群组
                if (choose_target.IsGroup == 1)
                {
                    frmSet = new FrmSMPGroupSet() { room = choose_target };
                    //frmSet = FrmSMPGroupSet.GetFrmSMPGroupSet();
                    //FrmSMPGroupSet.GetFrmSMPGroupSet().room = choose_target;
                }
                else
                {
                    frmSet = new FrmSingleSet() { friend = choose_target };
                    //frmSet = FrmSingleSet.GetFrmSingleSet();
                    //FrmSingleSet.GetFrmSingleSet().friend = choose_target;
                }
                //获取三个点控件相对屏幕的位置
                Point point = PointToScreen(Takeconter_panel.Location);
                point = new Point(point.X + (Takeconter_panel.Width - frmSet.Width), point.Y + panTitle.Height);

                frmSet.StartPosition = FormStartPosition.Manual;
                frmSet.Location = point;
                frmSet.Height = this.Height - panTitle.Height - 1;
                frmSet.Show(this.Parent);
            }
        }
        #endregion

        #region 群聊记录页
        private void lblHistory_MouseDown(object sender, MouseEventArgs e)
        {
            //FrmHistoryMsg frmHistoryMsg = new FrmHistoryMsg();
            //frmHistoryMsg.TitleText = !string.IsNullOrEmpty(choose_target.remarkName) ? choose_target.remarkName : choose_target.nickName;
            //frmHistoryMsg.friendData = choose_target;
            //frmHistoryMsg.Show();

            FrmHistoryChat frmHistoryChat = FrmHistoryChat.CreateInstrance();
            frmHistoryChat.ShowFriendMsg(choose_target);
            frmHistoryChat.Show();
        }
        #endregion

        #region 多选功能面板
        #region 多选面板点击事件
        /// <summary>
        /// 多选面板点击事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ShowInfoShade_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                //计算当前点击的showInfo_panel的y坐标（相对本身为参照物，而不是窗体）
                float showInfo_panel_y = e.Y;
                float sum_height = 0;
                rowIndex = 0;
                //计算点击的坐标是第几行
                while (true)
                {
                    sum_height += showInfo_Panel.RowStyles[rowIndex].Height;
                    if (sum_height > showInfo_panel_y)
                        break;
                    rowIndex++;
                }

                //判断该行是否有复选框
                if (showInfo_Panel.GetControlFromPosition(0, rowIndex) == null)
                    return;
                if (!(showInfo_Panel.GetControlFromPosition(0, rowIndex) is CheckBoxEx checkBox))
                    return;

                //点击修改选中状态
                //bool box_checked = ((LollipopCheckBox)showInfo_Panel.GetControlFromPosition(0, rowIndex)).Checked;
                checkBox.Checked = checkBox.Checked == true ? false : true;

                string crl_name = showInfo_Panel.GetControlFromPosition(1, rowIndex).Name;
                string messageId = crl_name.Replace("talk_panel_", "");
                MessageObject msg = targetMsgData.GetMsg(messageId);
                //添加选中
                multiSelectPanel1.List_Msgs.Add(msg);

                #region 修改底色
                //isOpenCellPaint = true;     //需要重绘事件给单元格勾选改行后更换底色
                //if (isOpenCellPaint)
                //    this.showInfo_Panel.CellPaint += new TableLayoutCellPaintEventHandler(showInfo_Panel_CellPaint);

                ////触发重绘，修改底色
                ////showInfo_Panel.RowStyles[rowIndex].Height = showInfo_Panel.RowStyles[rowIndex].Height;
                //((MaterialCheckBox)showInfo_Panel.GetControlFromPosition(0, rowIndex)).Visible = false;
                //((MaterialCheckBox)showInfo_Panel.GetControlFromPosition(0, rowIndex)).Visible = true;
                //isOpenCellPaint = false;
                #endregion
            }
        }
        #endregion

        #region 设置复选框可见度
        private void SetCheckBoxVisible(bool visible)
        {
            for (int index = 0; index < showInfo_Panel.Controls.Count; index++)
            {
                var item = showInfo_Panel.Controls[index];
                if (item is CheckBoxEx checkBox)
                {
                    //checkBox.Visible = visible;
                    checkBox.Checked = false;
                }
            }
        }
        #endregion

        private void IsShowPanelMultiSelect(bool visible)
        {
            if (visible == false)
            {
                panMultiSelect.Dock = DockStyle.None;
                Bottom_Panel.Dock = DockStyle.Bottom;
                panMultiSelect.SendToBack();
            }
            else
            {
                panMultiSelect.Dock = DockStyle.Bottom;
                Bottom_Panel.Dock = DockStyle.None;
                panMultiSelect.BringToFront();
            }
            showInfo_Panel.ColumnStyles[0].Width = visible == false ? 0 : 40;
            multiSelectPanel1.Visible = visible;
            Bottom_Panel.Visible = !visible;
            SetCheckBoxVisible(visible);
        }

        private void lblClose_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                CloseMultiSelect(false);
            }
        }

        private void CloseMultiSelect(bool visible)
        {
            IsShowPanelMultiSelect(false);
            IsShowInfoShade(false);
        }
        #endregion

        #region 获取群设置
        private int userSize = 0;
        private void GetRoomSetting()
        {
            if (choose_target.IsDevice == 1 || choose_target.Status != 2 || choose_target == null)
                return;

            //防止因为接口异步导致名称不对
            string name = choose_target.NickName;
            //http get请求获得数据
            HttpUtils.Instance.InitHttp(this);
            //将数据保存
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/getRoom") //获取群详情
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("roomId", choose_target.RoomId)
                .Build().Execute((success, result) =>
                {
                    if (success && choose_target != null)
                    {
                        labName.Text = name + "（" + UIUtils.DecodeString(result, "userSize") + "人）";
                        userSize = UIUtils.DecodeInt(result, "userSize");
                        choose_target.TransToMember(result);
                        // 更新对象的属性值
                        //Applicate.FriendObj = choose_target;

                        if (Applicate.ENABLE_MEET && Applicate.CURRET_VERSION > 4.0f)
                        {
                            //关闭群会议，普通成员不允许点击视频和音频
                            lblAudio.Visible = choose_target.AllowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true;
                            lblVideo.Visible = choose_target.AllowConference == 0 && !JudgeIsAdmin(Applicate.MyAccount.userId) ? false : true;

                        }
                        else
                        {
                            lblAudio.Visible = false;
                            lblVideo.Visible = false;
                        }

                        //是否显示群公告
                        bool isShowNotice = LocalDataUtils.GetBoolData(choose_target.UserId + "show_notice");
                        if (isShowNotice)
                            ShowNotice();
                    }
                    else
                    {
                        string remindTxt = "该群已被解散";
                        IsShow_BannedTalkPanel(true, remindTxt);
                        isCanTalk = false;
                    }
                });
        }
        #endregion

        #region 禁言
        /// <summary>
        /// 判断是否禁言
        /// </summary>
        /// <returns>返回true则为禁言状态</returns>
        private bool JudgeIsBannedTalk(ref string remindTxt)
        {
            if (choose_target == null || choose_target.IsGroup != 1)
                return false;

            //是否全体禁言
            string all = LocalDataUtils.GetStringData(choose_target.UserId + "BANNED_TALK_ALL" + Applicate.MyAccount.userId, "0");
            //管理员和群主除外
            if (!"0".Equals(all) && !JudgeIsAdmin(Applicate.MyAccount.userId))
            {
                // 全体禁言
                remindTxt = "本群已进行全体禁言";
                return true;
            }

            string single = LocalDataUtils.GetStringData(choose_target.UserId + "BANNED_TALK" + Applicate.MyAccount.userId, "0");
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

        private void IsShow_BannedTalkPanel(bool isShow, string remindTxt = "")
        {
            //当通知触发时，需要回到主线程
            Action action = new Action(() =>
            {
                if (isShow)
                {
                    //隐藏发送按钮
                    btnSend.Visible = false;

                    SetControlEnabled(this.Bottom_Panel, false);

                    //文字提醒
                    Label lblRemind = new Label();
                    lblRemind.Name = "lblRemind";
                    lblRemind.AutoSize = false;
                    lblRemind.Text = remindTxt;
                    lblRemind.Size = new Size(200, 23);
                    lblRemind.ForeColor = Color.FromArgb(157, 157, 157);
                    txtSend.Controls.Add(lblRemind);
                    lblRemind.Location = new Point(180, 35);
                    lblRemind.Anchor = AnchorStyles.None;
                    lblRemind.Focus();
                }
                else
                {
                    //恢复发送按钮
                    btnSend.Visible = true;
                    if (txtSend.Controls["lblRemind"] != null && txtSend.Controls["lblRemind"] is Label lblRemind)
                        lblRemind.Dispose();
                    SetControlEnabled(this.Bottom_Panel, true);
                }
            });
            if (this.IsHandleCreated)
                Invoke(action);
        }

        bool isBannedTalk = false;  //是否禁言中
        private void UpdateBannedTalk(MessageObject msg)
        {
            string remindTxt = "";
            //判断是否为禁言状态
            isBannedTalk = JudgeIsBannedTalk(ref remindTxt);
            if (isBannedTalk)
                txtSend.Clear();
            //txtSend.Visible = !isBannedTalk;   //使文本框失去焦点
            IsShow_BannedTalkPanel(isBannedTalk, remindTxt);
        }
        #endregion

        #region 判断是否为群主或者管理员
        private bool JudgeIsAdmin(string userId)
        {
            if (choose_target.IsGroup == 1)
            {
                int role = new RoomMember() { roomId = choose_target.RoomId, userId = userId }.GetRoleByUserId();
                if (role == 1 || role == 2)
                    return true;
            }
            return false;
        }
        #endregion

        #region 判断是否为群主
        private bool JudgeIsGroupOwner(string userId)
        {
            if (choose_target.IsGroup == 1)
            {
                int role = new RoomMember() { roomId = choose_target.RoomId, userId = userId }.GetRoleByUserId();
                if (role == 1)
                    return true;
            }
            return false;
        }
        #endregion

        #region 获取好友是否在线
        private void SetOnlineState()
        {
            if (choose_target.IsDevice == 1)
            {
                bool isOnline = MultiDeviceManager.Instance.IsDeviceLine(choose_target.UserId);
                string userName = string.IsNullOrEmpty(choose_target.RemarkName) ? choose_target.NickName : choose_target.RemarkName;
                labName.Text = userName + (isOnline ? "（在线）" : "（离线）");
                return;
            }

            //http get请求获得数据
            HttpUtils.Instance.InitHttp(this);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/getOnLine") //获取群详情
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("userId", choose_target.UserId)
                .Build().Execute((success, result) =>
                {
                    if (success)
                    {
                        string userName = string.IsNullOrEmpty(choose_target.RemarkName) ? choose_target.NickName : choose_target.RemarkName;
                        //在线
                        if (result["data"].ToString().Equals("1"))
                            labName.Text = userName + "（在线）";
                        else
                            labName.Text = userName + "（离线）";
                    }
                });
        }
        #endregion

        #region 视频
        private void lblVideo_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                //单聊
                if (choose_target.IsGroup == 0)
                    ShiKuManager.SendAskMeetMessage(choose_target, true);
                //群聊
                else
                {
                    //选择转发的好友
                    var frmFriendSelect = new FrmFriendSelect();
                    frmFriendSelect.LoadFriendsData(choose_target);
                    frmFriendSelect.AddConfrmListener((UserFriends) =>
                    {
                        if (UserFriends.Values.Count < 0)
                            return;
                        List<Friend> toFriends = new List<Friend>();
                        foreach (var friend in UserFriends.Values)
                            toFriends.Add(friend);
                        ShiKuManager.SendGroupVideoMeetMsg(toFriends, choose_target.RoomId, choose_target.UserId);
                    });
                }
            }
        }
        #endregion

        #region 音频
        private void lblAudio_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                //单聊
                if (choose_target.IsGroup == 0)
                    ShiKuManager.SendAskMeetMessage(choose_target, false);
                //群聊
                else
                {
                    //选择转发的好友
                    var frmFriendSelect = new FrmFriendSelect();
                    frmFriendSelect.LoadFriendsData(choose_target);
                    frmFriendSelect.AddConfrmListener((UserFriends) =>
                    {
                        if (UserFriends.Values.Count < 0)
                            return;
                        List<Friend> toFriends = new List<Friend>();
                        foreach (var friend in UserFriends.Values)
                            toFriends.Add(friend);
                        ShiKuManager.SendGroupAudioMeetMsg(toFriends, choose_target.RoomId, choose_target.UserId);
                    });
                }
            }
        }
        #endregion

        #region 收到通知修改聊天对象名字
        private void ModifyFriendName(Friend friend)
        {
            string newName = string.IsNullOrWhiteSpace(friend.RemarkName) ? friend.NickName : friend.RemarkName;
            //单聊并且为当前聊天对象
            if (friend.UserId == choose_target.UserId && friend.IsGroup == 0)
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

        #region 批量删除
        private void BatchDeleteMsg(List<MessageObject> list_msgs)
        {
            if (list_msgs == null || list_msgs.Count < 1)
                return;

            showInfo_Panel.SuspendLayout();

            MessageObject lastMsg = targetMsgData.GetLastIndexMsg();
            bool isLastMsg = false;     //记录是否含有最后一条消息在内
            foreach (MessageObject msg in list_msgs)
            {
                //如果是最后一条消息，需要通知最近聊天列表更新最后一条消息
                if (msg != null && lastMsg != null && lastMsg.rowIndex == msg.rowIndex)
                {
                    isLastMsg = true;
                    lastMsgTime = msg.timeSend;     //更新列表最后一条消息的时间
                }

                int rowIndex = msg.rowIndex;
                //移除复选框
                if (showInfo_Panel.GetControlFromPosition(0, rowIndex) is CheckBoxEx checkBox)
                {
                    showInfo_Panel.Controls.Remove(checkBox);
                    checkBox.Dispose();
                }
                //移除气泡控件
                var item = showInfo_Panel.GetControlFromPosition(1, rowIndex);
                showInfo_Panel.Controls.Remove(item);
                if (item != null)
                    item.Dispose();
                showInfo_Panel.RowStyles[rowIndex].Height = 0;
                //从字典中移除
                targetMsgData.RemoveMsgData(msg.messageId);
            }
            //调用接口删除数据
            CollectUtils.DelServerMessages(list_msgs, isLastMsg);
            showInfo_Panel.ResumeLayout();
        }
        #endregion

        #region 显示正在输入
        private void IsShowTyping()
        {
            if (labName.Text.IndexOf("正在输入。。") > -1)
                return;

            if (this.IsHandleCreated)
                Invoke(new Action(() =>
                {
                    labName.Text += "  正在输入。。";
                }));
            Task.Factory.StartNew(() =>
               {
                   Thread.Sleep(15000);
                   if (this.IsHandleCreated)
                       Invoke(new Action(() =>
                       {
                           labName.Text = labName.Text.Replace("  正在输入。。", "");
                       }));
               });

        }
        #endregion

        #region 给对方发送我正在输入的通知
        private void txtSend_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (choose_target.IsDevice == 1 || choose_target.IsGroup == 1)
                    return;
                ShiKuManager.SendInputMessage(choose_target);
            }
        }
        #endregion

        #region 显示或隐藏群已读人数
        private void IsShowReadPersons(bool isShow)
        {
            foreach (Control item in showInfo_Panel.Controls)
            {
                //不是消息气泡
                if (item.Name.IndexOf("talk_panel") < 0)
                    continue;
                //显示已读人数标识
                var crls = item.Controls.Find("lab_msg", true);
                if (crls.Length > 0 && crls[0] is Label lab_msg)
                    if (this.IsHandleCreated)
                    {
                        Invoke(new Action(() =>
                        {
                            lab_msg.Visible = isShow;
                        }));

                        if (isShow)
                        {
                            //红点下移
                            crls = item.Controls.Find("lab_redPoint", true);
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

        #region 监控按键
        private void txtSend_KeyPress(object sender, KeyPressEventArgs e)
        {
            //按下Enter键
            if (e.KeyChar == 13)
            {
                txtSend.Clear();
            }
        }

        private void txtSend_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyData == Keys.Enter)
                btnSend_Click(null, null);
            //Ctrl+V
            if (e.Control && e.KeyCode == Keys.V)
            {
                //检查是否黏贴文件
                if(Clipboard.GetFileDropList().Count > 0)
                {
                    var strCollection = Clipboard.GetFileDropList();
                    foreach (string item in strCollection)
                        fileCollect.Add(item);
                }
            }
        }
        #endregion

        #region 发送消息文本框，文本变更事件
        private bool isChangingEmoji = false;   //是否正在转换emoji表情
        private int txtChangedState = 1;    //0为正在选择@成员，不再弹出好友选择器
        private int atCount = 0;    //@的人数
        private List<Friend> list_atFriends = new List<Friend>();
        private void txtSend_TextChanged(object sender, EventArgs e)
        {
            #region 群@功能
            if (choose_target != null && choose_target.IsGroup == 1)
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
                        frmFriendSelect.LoadFriendsData(choose_target, true);
                        frmFriendSelect.AddConfrmListener((UserFriends) =>
                        {
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

            #region 修改emojiCode转图片
            //正在转化emoji表情
            if (!isChangingEmoji)
            {
                //匹配符合规则的表情code
                MatchCollection matchs = Regex.Matches(txtSend.Text, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                if (matchs.Count > 0)
                {
                    isChangingEmoji = true;
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
                        List<string> replacedEmoji = new List<string>();
                        foreach (Match match in matchs)
                        {
                            if (replacedEmoji.Contains(match.Value))
                                continue;

                            string emoji_rtf = EmojiCodeDictionary.GetEmojiRtfByCode(match.Value);
                            if (!string.IsNullOrEmpty(emoji_rtf))
                            {
                                emoji_codes.Add(match.Value);
                                txtSend.Rtf = txtSend.Rtf.Replace(match.Value, emoji_rtf);
                            }

                            replacedEmoji.Add(match.Value);
                        }
                    }
                    catch (Exception ex)
                    {
                        LogHelper.log.Error("----转化emoji出错，方法（txtSend_TextChanged） : " + ex.Message, ex);
                    }
                    isChangingEmoji = false;
                }
            }
            #endregion
        }
        #endregion

        #region 自己主动@人的通知
        private void AddAtUserToTxtSend(Friend friend)
        {
            atCount++;
            list_atFriends.Add(friend);

            txtSend.SelectedText += "@" + friend.NickName + " ";
        }
        #endregion

        #region 显示公告
        private void ShowNotice()
        {
            roomNotice.RoomData = choose_target;
            roomNotice.LoadData();
            roomNotice.BringToFront();
        }
        #endregion

        #region 获取选中控件的msg
        private MessageObject GetMsgBySelectCrl()
        {
            string messageId = selectControl.Name.Replace("talk_panel_", "");
            return targetMsgData.GetMsg(messageId);
        }
        #endregion

        private EQBaseControl GetControlByMsg(MessageObject msg)
        {
            if (msg == null || string.IsNullOrEmpty(msg.messageId))
                return null;

            if (choose_target == null)
                return null;

            //获得控件名
            string c_name = "talk_panel_" + msg.messageId;

            var result = showInfo_Panel.Controls.Find(c_name, true);
            if (result.Length > 0 && result[0] is EQBaseControl eqCrl)
                return eqCrl;
            else
                return null;
        }

        #region 截图
        private void lblScreen_Click(object sender, EventArgs e)
        {
            if (((MouseEventArgs)e).Button == MouseButtons.Left)
            {
                CaptureImageTool capture = new CaptureImageTool();

                // capture.SelectCursor = CursorManager.ArrowNew;
                //  capture.DrawCursor = CursorManager.CrossNew;

                if (capture.ShowDialog() == DialogResult.OK)
                {
                    bool b = txtSend.ReadOnly;
                    txtSend.ReadOnly = false;
                    Image image = capture.Image;
                    Clipboard.Clear();
                    Clipboard.SetImage(image);
                    //将图片粘贴到鼠标焦点位置(选中的字符都会被图片覆盖)
                    txtSend.Paste();
                    txtSend.ReadOnly = b;

                    //以控件的方式添加进富文本框里
                    //PictureBox pb = new PictureBox();
                    //pb.Size = new Size(30, 30);
                    //pb.SizeMode = PictureBoxSizeMode.Zoom;
                    //pb.Image = image;
                    //this.txtSend.Controls.Add(pb);
                }

                if (!Visible)
                {
                    Show();
                }

                

                //    ShotCutWindow shotCutWindow = new ShotCutWindow();
                //    shotCutWindow.ShotCutComplete = (image) =>
                //    {
                //        //int width = image.Width, height = image.Height;
                //        //EQControlManager.ModifyWidthAndHeight(ref width, ref height, 100, 100);
                //        //Bitmap map = EQControlManager.GetSmall(image, 5);
                //        Clipboard.Clear();
                //        Clipboard.SetImage(image);
                //        //将图片粘贴到鼠标焦点位置(选中的字符都会被图片覆盖)
                //        txtSend.Paste();
                //    };
                //    //shotCutWindow.ShowDialog();
            }
        }
        #endregion

        #region 移除某一条消息（销毁）
        private void RemoveMsgOfPanel(string msgId)
        {
            MessageObject msg = targetMsgData.GetMsg(msgId);
            if (msg == null)
                return;

            int rowIndex = msg.rowIndex;
            Action action = new Action(() =>
            {
                //移除复选框
                if (showInfo_Panel.GetControlFromPosition(0, rowIndex) is CheckBoxEx checkBox)
                {
                    showInfo_Panel.Controls.Remove(checkBox);
                    checkBox.Dispose();
                }
                //移除气泡控件
                var item = showInfo_Panel.GetControlFromPosition(1, rowIndex);
                showInfo_Panel.Controls.Remove(item);
                item.Dispose();
                showInfo_Panel.RowStyles[rowIndex].Height = 0;
                //从字典中移除
                targetMsgData.RemoveMsgData(msgId);

                //删除数据库数据
                msg.DeleteData();
            });
            if (this.IsHandleCreated)
                Invoke(action);
        }
        #endregion

        #region 替换为remind类型气泡
        private void ReplaceMsgToRemind(string msgId, string content)
        {
            //不存在该消息
            if (targetMsgData.GetMsg(msgId) == null)
                return;

            //获取msg
            MessageObject msg = targetMsgData.GetMsg(msgId);

            //修改消息的类型
            msg.type = kWCMessageType.Remind;
            msg.content = content;
            msg.isReadDel = 0;

            Action action = new Action(() =>
            {
                showInfo_Panel.SuspendLayout();
                msg = targetMsgData.UpdateMsg(msg);

                //KWTypeControlsDictionary kWTypeControls = new KWTypeControlsDictionary(msg);
                //EQBaseControl eqBase = kWTypeControls.GetObjectByType();
                EQBaseControl eqBase = KWTypeControlsDictionary.GetObjectByType(msg);
                EQBaseControl talk_panel = eqBase.GetRecombinedPanel();
                talk_panel.Name = "talk_panel_" + msg.messageId;

                //移除聊天气泡换成消息提醒
                float item_height = showInfo_Panel.RowStyles[msg.rowIndex].Height;
                //提示消息居中显示
                talk_panel.Anchor = AnchorStyles.None;
                //循环列，释放控件（复选框和聊天气泡）
                for (int col_index = 0; col_index < showInfo_Panel.ColumnCount; col_index++)
                {
                    var item = showInfo_Panel.GetControlFromPosition(col_index, msg.rowIndex);
                    if (item != null)
                    {
                        showInfo_Panel.Controls.Remove(item);
                        item.Dispose();
                    }
                }
                ////删除该行旧的样式
                //showInfo_Panel.RowStyles.RemoveAt(msg.rowIndex);
                ////添加该行新的样式
                //showInfo_Panel.RowStyles.Insert(msg.rowIndex, new RowStyle(SizeType.Absolute, talk_panel.Height));
                showInfo_Panel.RowStyles[msg.rowIndex].Height = talk_panel.Height;

                showInfo_Panel.Controls.Add(talk_panel, 1, msg.rowIndex);
                showInfo_Panel.ResumeLayout();
            });
            if (showInfo_Panel.IsHandleCreated)
                showInfo_Panel.Invoke(action);
        }
        #endregion

        #region 记录阅后即焚的时间
        private void SaveReadDelTime()
        {
            if (isHaveReadDel == 0)
                return;

            foreach (var msg in targetMsgData.GetMsgList())
            {
                //阅后即焚消息
                if (msg.isReadDel == 1 && msg.ReadDelTime > 0)
                {
                    //记录当前的秒数
                    LocalDataUtils.SetIntData(Applicate.MyAccount.userId + "_ReadDelTime_" + msg.messageId, msg.ReadDelTime);
                    //停止计时器
                    //Control eqBaseCrl = showInfo_Panel.GetControlFromPosition(1, msg.rowIndex);
                    //if(eqBaseCrl is EQBaseControl talk_panel)
                    //{
                    //    talk_panel.isReadDel = false;
                    //    talk_panel.readDel_timer.Stop();
                    //    talk_panel.readDel_timer.Dispose();
                    //}
                    msg.isReadDel = 0;
                }
            }
        }
        #endregion

        #region 点击标题
        private void labName_MouseDown(object sender, MouseEventArgs e)
        {
            lab_detial_MouseClick(lab_detial, e);
        }
        #endregion

        #region 控制是否显示新消息标识
        private void IsShowUnReadNumPanel(int readNum, string msgId)
        {
            bool isShow = false;    //是否显示新消息标识

            //没有新消息直接不显示
            if (readNum > 0 && !string.IsNullOrEmpty(msgId))
            {
                int dataCount = targetMsgData.GetMsgList().Count;
                //1.如果当前显示的msg数量小于未读数量，显示
                if (readNum > dataCount)
                    isShow = true;
                //2.如果未读行数的总高度大于可显示区域，显示
                else
                {
                    float totalHeight = 0;
                    int stylesCount = showInfo_Panel.RowStyles.Count;
                    if (stylesCount == 0)
                        isShow = false;
                    else
                    {
                        for (int index = 0; index < readNum; index++)
                        {
                            totalHeight += showInfo_Panel.RowStyles[stylesCount - index - 1].Height;
                            if (totalHeight > showInfo_Panel.Parent.Height)
                            {
                                isShow = true;
                                break;
                            }
                        }
                    }
                }
            }
            unReadNumPanel.IsShowPanel(msgId, readNum, isShow);
        }
        #endregion

        #region 根据msg追踪行
        private void SetPanelTopByMsg(MessageObject dic_msg)
        {
            int totalHeight = 0;
            for (int index = 0; index < dic_msg.rowIndex; index++)
            {
                int rowHeight = (int)Math.Round(showInfo_Panel.RowStyles[index].Height);
                totalHeight += rowHeight;
            }
            //如果当前的top足够显示最新的消息，则不进行滚动
            //if (totalHeight >= Math.Abs(showInfo_Panel.Top))
            //    unReadNumPanel.SendToBack();
            ////需要滚动到合适位置，到能显示第一条最新消息
            //else
            //{
            //防止出现特殊情况导致消息面板变小，所以不应该滚动
            if (showInfo_Panel.Height > Takeconter_panel.Height)
            {
                showInfo_Panel.Top = -totalHeight;
                //更新进度条位置
                ShowInfoVScroll.UpdateVScrollLocation();
                //防止滚动后出现底部有空白

            }
            //}
        }
        #endregion

        #region 按@提醒定位到该条信息位置
        private void SetPanTopByRowIndex(int rowIndex)
        {
            float topNum = 0;
            //计算该行的TOP
            for (int index = 0; index < rowIndex; index++)
                topNum += showInfo_Panel.RowStyles[index].Height;
            showInfo_Panel.Top = Convert.ToInt32(-topNum + (showInfo_Panel.Parent.Height - showInfo_Panel.RowStyles[rowIndex].Height));
            ShowInfoVScroll.UpdateVScrollLocation();
        }
        #endregion

        #region 鼠标悬浮文本提醒
        private void lblHistory_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblHistory, "聊天记录");//设置提示按钮和提示内容
        }

        private void lblScreen_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblScreen, "截图");//设置提示按钮和提示内容
        }

        private void lblSendFile_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblSendFile, "发送文件");//设置提示按钮和提示内容
        }

        private void lblExpression_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblExpression, "表情");//设置提示按钮和提示内容
        }

        private void lblAudio_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblAudio, "语音聊天");//设置提示按钮和提示内容
        }

        private void lblVideo_MouseHover(object sender, EventArgs e)
        {
            toolTip.ShowAlways = true;//是否显示提示框

            //  设置伴随的对象.
            toolTip.SetToolTip(this.lblVideo, "视频聊天");//设置提示按钮和提示内容
        }
        #endregion

        #region 显示@浮标
        private void AtMeShowPanel(Friend room)
        {
            if (choose_target == null || choose_target.IsGroup != 1 || room.UserId != choose_target.UserId)
            {
                AtMePanel.SendToBack();
                return;
            }

            bool isup = true;    //方向
            //获取收到@的messageId
            string messageid = LocalDataUtils.GetStringData(room.UserId + "GROUP_AT_MESSAGEID" + Applicate.MyAccount.userId);
            if (targetMsgData.GetMsg(messageid) == null)
                isup = false;

            AtMePanel.Changedata(room, isup);
            AtMePanel.BringToFront();
        }
        #endregion

        #region 下载文件
        private void DownloadFile(MessageObject msg, string localPath)
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

                        HttpUtils.Instance.ShowTip("下载完成：" + path);
                    });
                    #endregion
                }
            }
        }
        #endregion

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
                    msg = targetMsgData.GetMsg(msg.messageId);
                    if (targetMsgData.GetMsg(msg.messageId) != null)
                    {
                        //修改气泡的图片和样式
                        string name = "talk_panel_" + msg.messageId;
                        if (showInfo_Panel.Controls.Find(name, true).Length > 0 && showInfo_Panel.Controls.Find(name, true)[0] is EQImageControl imageCrl)
                            UploadImage(imageCrl, msg, url, success);
                    }
                });
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

        #region 修改消息的成员名称
        private void ModifyLabName(EQBaseControl talk_panel, string userId)
        {
            if (talk_panel.lab_name != null && JudgeIsGroupOwner(Applicate.MyAccount.userId))
            {
                if (string.IsNullOrEmpty(choose_target.RoomId))
                    return;
                //获取群主备注
                string remarkName = new RoomMember() { roomId = choose_target.RoomId, userId = userId }.GetRemarkName();
                if (string.IsNullOrEmpty(remarkName))
                    return;
                talk_panel.lab_name.Text = remarkName;
            }
        }
        #endregion
        
        #region 工具栏
        #region 选择定位
        private void lblLocation_Click(object sender, EventArgs e)
        {
            FrmSedLocation frmSedLocation = FrmSedLocation.CreateInstrance();
            frmSedLocation.initCefSharp(choose_target);
            frmSedLocation.Show();
        }
        #endregion

        #region 拍照
        private void lblCamera_Click(object sender, EventArgs e)
        {
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
                    MessageObject msg = ShiKuManager.SendImageMessage(choose_target, "", localPath, Convert.ToInt32(new FileInfo(localPath).Length), false);
                    JudgeMsgIsAddToPanel(msg);

                    UploadEngine.Instance.From(localPath).
                        //上传完成
                        UploadFile((success, url_path) =>
                        {
                            msg = targetMsgData.GetMsg(msg.messageId);
                            if (targetMsgData.GetMsg(msg.messageId) != null)
                            {
                                //修改气泡的图片和样式
                                string name = "talk_panel_" + msg.messageId;
                                var crls = showInfo_Panel.Controls.Find(name, true);
                                if (crls.Length > 0 && crls[0] is EQImageControl imageCrl)
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

        #region 录音
        private void lblSoundRecord_Click(object sender, EventArgs e)
        {
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
            //replyPanel.Visible = false;
            userSoundRecording.BringToFront();
        }
        #endregion

        #region 录像
        private void lblPhotography_Click(object sender, EventArgs e)
        {
            FrmTakeVideo frmTakeVideo = FrmTakeVideo.GetInstance();
            if(frmTakeVideo.iscontentpoto())
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
                    MessageObject msg = ShiKuManager.SendVideoMessage(choose_target, "", localPath, fileSize, false);
                    JudgeMsgIsAddToPanel(msg);

                    //获取气泡
                    string name = "talk_panel_" + msg.messageId;
                    if (showInfo_Panel.Controls.Find(name, true).Length > 0 && showInfo_Panel.Controls.Find(name, true)[0] is EQBaseControl talk_panel)
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
        #endregion

        #region  添加发送时间
        private bool AddSendTime(EQBaseControl eqBase, MessageObject messageObject)
        {
            bool isAddCrl = false;  //返回结果
            //if (lastMsgTime > 0)
            //{
                Label lab_sendTime = eqBase.DrawSendTime(lastMsgTime);
                if (lab_sendTime != null)
                {
                    showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
                    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, lab_sendTime.Height));
                    //lab_sendTime.Location = new Point(showInfo_Panel.Width - lab_sendTime.Width + 2, 3);
                    lab_sendTime.Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right;
                    showInfo_Panel.Controls.Add(lab_sendTime, 1, showInfo_Panel.RowCount - 1);
                    isAddCrl = true;
                }
            //}
            //保存最后一条消息的发送时间
            if (messageObject.timeSend > lastMsgTime)
                lastMsgTime = messageObject.timeSend;
            return isAddCrl;
        }

        /// <summary>
        /// 消息被移除需要更新气泡的时间
        /// </summary>
        private void UpdateSendTime(MessageObject msg)
        {
            //如果是撤回消息，则不需要变化时间控件
            if (msg.isRecall == 1)
                return;

            //如果该消息存在时间控件，则下一条消息应该判断是否需要更新
            string crlName = "lab_sendTime_" + msg.messageId;   //时间控件名
            var result = showInfo_Panel.Controls.Find(crlName, true); //查找控件是否存在
            if (result.Length > 0 && result[0] is Label lab_sendTime)
            {
                //查询下一个控件为消息气泡还是时间控件
                var next_crl = showInfo_Panel.GetControlFromPosition(1, msg.rowIndex + 1);
                //如果下一行没有控件存在，直接移除时间控件
                if (next_crl == null)
                {
                    RemoveSendTime(lab_sendTime, msg.rowIndex - 1);
                    return;
                }
                //如果下一行控件为气泡控件
                if(next_crl is EQBaseControl talk_panel)
                {
                    MessageObject next_msg = targetMsgData.GetMsg(talk_panel.Name.Replace("talk_panel_", ""));
                    if(next_msg != null)
                    {
                        lab_sendTime.Name = "lab_sendTime_" + next_msg.messageId;   //修改控件名
                        string time_format = lab_sendTime.Tag.ToString();   //时间的格式
                        DateTime dt_timeSend = Helpers.StampToDatetime(next_msg.timeSend);     //信息发送时间
                        string send_time = dt_timeSend.ToString(time_format);   //发送时间
                        lab_sendTime.Text = send_time;      //修改文本内容
                    }
                }
                //下一行为时间控件或者其他，移除
                else
                    RemoveSendTime(lab_sendTime, msg.rowIndex - 1);
            }
        }

        private void RemoveSendTime(Label lab_sendTime, int removeRowIndex)
        {
            showInfo_Panel.Controls.Remove(lab_sendTime);
            lab_sendTime.Dispose();
            lab_sendTime = null;
            showInfo_Panel.RowStyles[removeRowIndex].Height = 0;
        }
        #endregion

        #region 更新设备的状态
        private void UpdateDeviceState(string userId)
        {
            if (choose_target == null || choose_target.IsDevice != 1)
                return;

            //修改在线状态
            bool isOnline = MultiDeviceManager.Instance.IsDeviceLine(choose_target.UserId);
            labName.Text = choose_target.NickName + (isOnline ? "（在线）" : "（离线）");
        }
        #endregion

        #region 列表控件的重绘
        //设置了marginRight=20，防止头像显示只有一半
        private void showInfo_Panel_Paint(object sender, PaintEventArgs e)
        {

        }

        private void showInfo_Panel_SizeChanged(object sender, EventArgs e)
        {
            //防止右边距错误自适应（真是奇怪的BUG）
            int rightMargin = Takeconter_panel.Width - (showInfo_Panel.Location.X + showInfo_Panel.Width);
            if (rightMargin < 20)
                showInfo_Panel.Width -= 20 - rightMargin;
        }
        #endregion
    }
}
