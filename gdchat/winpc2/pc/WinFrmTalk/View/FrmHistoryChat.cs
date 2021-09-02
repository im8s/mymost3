using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.Controls;
using WinFrmTalk.Properties;
using WinFrmTalk.Controls.CustomControls;
using System.IO;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Text.RegularExpressions;
using RichTextBoxLinks;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Helper;
using Newtonsoft.Json;
using TestListView;
using WinFrmTalk.View.list;
using System.Collections;

namespace WinFrmTalk.View
{
    public partial class FrmHistoryChat : FrmBase
    {
        #region ȫ�ֱ���
        //ѡ�е�label�ؼ�
        public Label is_check;
        public static Friend friends;
        //������Ϣ
        public static List<MessageObject> listData;
        private static FrmHistoryChat frm = null;
        private bool isOpenForm= false;
        private static int emoji_count = 0;
        public int type;
        RichTextBoxEx richText = new RichTextBoxEx();
        PictureBox pictureBoxVideo = new PictureBox();
        PictureBox pictureBoxImage = new PictureBox();
        FilePanelLeft panel_file = new FilePanelLeft();
        Panel pnlReplay = new Panel();
        ChatItem chatFile = new ChatItem();
        private HistotyChatAdapter mAdapter;
        private bool isScrollBar;
        private int page = 1;
        #endregion
        #region ����ģʽ
        public static FrmHistoryChat CreateInstrance()
        {
            if (frm == null || frm.IsDisposed)
            {
                frm = new FrmHistoryChat();
            }
            if (frm != null)
            {
                frm.Activate();
            }
            return frm;
        }
        #endregion
        #region �������
        private FrmHistoryChat()
        {
            mAdapter = new HistotyChatAdapter();
            InitializeComponent();
            xListView1.FooterRefresh += OnFooterRefresh;
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//����iconͼ��
            Font f = new Font(Applicate.SetFont, 12);
            lblAll.ForeColor = ColorTranslator.FromHtml("#1AAD19");
            lblAll.Font = f;
            is_check = lblAll;
            if(!Applicate.IsInputChatList)
            {
                btninpuexcel.Visible = false;
                btninputtxt.Visible = false;
            }
          
        }
        //���¹���
        private void OnFooterRefresh()
        {
            if (isScrollBar)
            {
                page++;
                List<MessageObject> messages = new MessageObject()
                {
                    FromId = friends.UserId,

                }.GetPageListHistory(page);
                if (messages.Count <= 0)
                {
                    return;
                }
                int index = listData.Count;
                listData.AddRange(messages);
                mAdapter.FrmHistoryChat = this;
                mAdapter.BindFriendData(listData);
                xListView1.InsertRange(index);
            }
        }

        #endregion
        #region ������֤
        /// <summary>
        /// ͷ��
        /// </summary>
        /// <param name="url"></param>
        /// <param name="incoImage"></param>
        public static void TypeFileToImage(string url, PictureBox incoImage)
        {
            //��ȡ��ǰ�ļ�ѡ���ͷ��
            int type = FileUtils.GetFileTypeByNanme(url);
            //ͼƬ
            if (type == 1)
            {
                ImageLoader.Instance.Load(url).NoCache().Into(incoImage);

            }
            else if (type == 2)
            {

                //music
                incoImage.Image = Resources.ic_muc_flie_type_y;

            }
            else if (type == 3)
            {
                //��Ƶ
                incoImage.Image = Resources.ic_muc_flie_type_v;

            }
            else if (type == 4)
            {
                //ppt
                incoImage.Image = Resources.ic_muc_flie_type_p;

            }
            else if (type == 5)
            {
                //xlse
                incoImage.Image = Resources.ic_muc_flie_type_x;

            }
            else if (type == 6)
            {
                //world
                incoImage.Image = Resources.ic_muc_flie_type_w;

            }
            else if (type == 7)
            {
                //zrp
                incoImage.Image = Resources.ic_muc_flie_type_z;

            }
            else if (type == 8)
            {
                //txt
                incoImage.Image = Resources.ic_muc_flie_type_t;

            }
            else if (type == 9)
            {
                //??
                incoImage.Image = Resources.ic_muc_flie_type_what;

            }
            else if (type == 10)
            {
                //pdf
                incoImage.Image = Resources.ic_muc_flie_type_f;

            }
            else if (type == 11)
            {

                incoImage.Image = Resources.ic_muc_flie_type_a;

            }
        }
        /// <summary>
        /// �ļ�����
        /// </summary>
        /// <param name="toFilePath"></param>
        /// <param name="fileUrl"></param>
        public static void DownFile(string toFilePath, string fileUrl, bool isOpen = false)
        {
            HttpDownloader.DownloadFile(fileUrl, toFilePath, (path) =>
            {
                if (!string.IsNullOrEmpty(path))
                {
                    // ���سɹ�
                    LogUtils.Log("���سɹ���" + path);
                    if (!isOpen)
                    {
                        //�򿪴��ļ�
                        System.Diagnostics.Process.Start(path);
                    }
                }
            });
        }
        #endregion
        #region  �ؼ�����¼�
        private void lblAll_Click(object sender, EventArgs e)
        {
            //���ԭ������
            xListView1.ClearList();
            var views = new List<Control>();
            #region ������ɫ
            Label label = (Label)sender;
            if (is_check != null && is_check != label)
            {
                //�����ǰ
                Font f = new Font(Applicate.SetFont, 12);
                label.ForeColor = ColorTranslator.FromHtml("#1AAD19");
                label.Font = f;
                //���������ť
                Font f2 = new Font(Applicate.SetFont, 12);
                is_check.ForeColor = Color.Black;
                is_check.Font = f2;
                is_check = label;
            }
            #endregion
            #region ȫ��
            if ((Label)sender == lblAll)
            {
                LodingUtils loding = new LodingUtils();
                loding.parent = xListView1;
                loding.size = xListView1.Size;
                loding.start();
                xListView1.Visible = true;
                flowLayoutPanel1.Visible = false;
                //�ж��Ƿ��ڼ���
                mAdapter.isclickFileButton = false;
                mAdapter.FrmHistoryChat = this;
                mAdapter.BindFriendData(listData);
                xListView1.SetAdapter(mAdapter);
                //���²�ѯ
                txtSearch_click(sender, e);
                loding.stop();
            }
            #endregion
            #region �ļ�
            if ((Label)sender == lblFile)
            {
                xListView1.Visible = true;
                flowLayoutPanel1.Visible = false;
                List<MessageObject> listFileData = ShowMsgFileList(friends.UserId);
                foreach (var item in listFileData)
                {
                    FileInfonmation(item);
                    mAdapter.isclickFileButton = true;
                    mAdapter.FrmHistoryChat = this;
                    mAdapter.BindFriendData(listFileData);
                    xListView1.SetAdapter(mAdapter);
                }
            }
            #endregion
            #region ͼƬ
            if ((Label)sender == lblPicBox)
            {
                type = 3;
                //���
                ImageIngomation();
            }
            #endregion
            #region ��Ƶ
            if ((Label)sender == lblLink)
            {
                type = 4;
                VdioShow();
            }
            #endregion
        }
        #endregion
        #region ���ط�������
        //��Ƶ
        private void VdioShow()
        {
            //���
            flowLayoutPanel1.Controls.Clear();
            foreach (var item in listData)
            {
                if (item.type == kWCMessageType.Video)
                {
                    xListView1.Visible = false;
                    flowLayoutPanel1.Visible = true;
                    pictureBoxVideo = new PictureBox();
                    pictureBoxVideo.Tag = item;
                    pictureBoxVideo.Location = new Point(52, 117);
                    pictureBoxVideo.Size = new Size(95, 95);
                    #region ��Ƶ������ӵȴ���
                    LodingUtils loding = new LodingUtils();
                    loding.size = new Size(10, 10);
                    loding.parent = pictureBoxVideo;
                    loding.BgColor = Color.Transparent;
                    loding.start();
                    ThubImageLoader.Instance.Load(item.content, pictureBoxVideo, (sucess) =>
                    {
                        //�رյȴ���
                        var result = pictureBoxVideo.Controls.Find("loding", true);
                        if (result.Length > 0 && result[0] is USELoding lodings)
                        {
                            lodings.Dispose();
                            Helpers.ClearMemory();
                        }
                    });
                    #endregion
                    pictureBoxVideo.SizeMode = PictureBoxSizeMode.StretchImage;
                    pictureBoxVideo.Dock = DockStyle.None;
                    //�󶨵�ǰ����
                    pictureBoxVideo.Tag = item;
                    pictureBoxVideo.MouseClick += new MouseEventHandler(Vido_clike);
                    flowLayoutPanel1.Controls.Add(pictureBoxVideo);
                    BindMouseDown(pictureBoxVideo, item);
                    this.Controls.Add(flowLayoutPanel1);
                }
            }
        }
        //ͼƬ
        private void ImageIngomation()
        {
            flowLayoutPanel1.Controls.Clear();
            foreach (var item in listData)
            {
                if (item.type == kWCMessageType.Image)
                {
                    xListView1.Visible = false;
                    flowLayoutPanel1.Visible = true;
                    pictureBoxImage = new PictureBox();
                    pictureBoxImage.Location = new Point(52, 117);
                    pictureBoxImage.Size = new Size(95, 95);
                    ImageLoader.Instance.Load(item.content).NoCache().Into(pictureBoxImage);
                    pictureBoxImage.SizeMode = PictureBoxSizeMode.StretchImage;
                    pictureBoxImage.Dock = DockStyle.None;
                    //�󶨵�ǰ����
                    pictureBoxImage.Name = item.messageId;
                    pictureBoxImage.Tag = item;
                    pictureBoxImage.MouseClick += new MouseEventHandler(MouseClie);
                    flowLayoutPanel1.Controls.Add(pictureBoxImage);
                    BindMouseDown(pictureBoxImage, item);
                    this.Controls.Add(flowLayoutPanel1);
                }
            }
        }
        //�ļ�
        public ChatItem FileInfonmation(MessageObject item)
        {
            //ʵ�����ؼ�
            chatFile = new ChatItem();
            string fileName = FileUtils.GetFileName(item.fileName);
            chatFile.fileName = UIUtils.LimitTextLength(fileName, 20, true);
            Label lblMsg = new Label();
            lblMsg.AutoSize = false;
            lblMsg.Size = new Size(150, 40);
            lblMsg.TextAlign = ContentAlignment.MiddleLeft;
            lblMsg.Text = UIUtils.FromatFileSize(item.fileSize);
            lblMsg.Location = new Point(73, 32);
            chatFile.Controls.Add(lblMsg);
            lblMsg.BringToFront();
            string Name = item.content != null ? item.content : item.fileName;
            TypeFileToImage(Name, chatFile.pboxHead);
            chatFile.MouseClick += (sende, e1) =>
            {
                if (e1.Button == MouseButtons.Left)
                {
                    string url = "";
                    string filePaht = "";
                    url = item.content;
                    filePaht = FileUtils.GetFileName(item.content);
                    string LoacPath = Applicate.LocalConfigData.RoomFileFolderPath + fileName;
                    //����
                    DownFile(LoacPath, url);
                }
            };
            chatFile.Time = TimeUtils.ChatLastTime(item.timeSend);
            chatFile.Tag = item;
            BindMouseDown(chatFile, item);
            return chatFile;
        }
        #endregion
        #region  ���ݼ���
        // ��ʾ����
        public void ShowFriendMsg(Friend friend)
        {
            if (!isOpenForm)
            {
                this.Show();
                friends = friend;
                //if (friend.GetRemarkName().Length>15)
                //{
                //    lblNickName.Text = friend.GetRemarkName().Substring(0, 15) + "...";
                //}
                lblNickName.Text = friend.GetRemarkName();
                LodingUtils loding = new LodingUtils();
                loding.parent = xListView1;
                loding.size = xListView1.Size;
                loding.start();
                var views = new List<Control>();
                listData = ShowMsgList(friend.UserId);
                if (listData.Count >= 30)
                {
                    isScrollBar = true;
                }
                BindData(listData);
                loding.stop();
            }
            else
            {
                return;
            }
        }
        //���ݰ�
        private void BindData(List<MessageObject> list)
        {
            mAdapter.FrmHistoryChat = this;
            mAdapter.BindFriendData(list);
            xListView1.SetAdapter(mAdapter);
        }

        //��ʾ��������
        public void ShowMessageList(List<MessageObject> datas, string title)
        {
            //�ǳ�
            LodingUtils loding = new LodingUtils();
            loding.parent = xListView1;
            loding.size = xListView1.Size;
            loding.start();
            listData = datas;
          
            lblNickName.Text = title;
            lblAll.Visible = false;
            lblFile.Visible = false;
            lblPicBox.Visible = false;
            lblLink.Visible = false;
            this.Show();
            BindData(datas);
            loding.stop();
        }
        /// <summary>
        /// �ı��߿�
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void RichTextBox_Height(object sender, ContentsResizedEventArgs e)
        {
            RichTextBoxEx richText = (RichTextBoxEx)sender;
            richText.Height = e.NewRectangle.Height + 10;
        }
        #endregion
        #region ���Ҽ��˵�
        // ���Ҽ��˵�
        public void BindMouseDown(Control item, MessageObject message)
        {
            var copyitem = new MenuItem("����", (sen, eve) =>
            {
                CopyData(message);
                HttpUtils.Instance.ShowTip("���Ƴɹ�");
            });
            var sendcard = new MenuItem("ת��", (sen, eve) =>
            {
                var frmFriend = new FrmFriendSelect();
                frmFriend.LoadFriendsData();   //���ݼ���
                // ���ú���ѡ����
                frmFriend.AddConfrmListener((userLiser) =>
                {
                    foreach (var itemFriend in userLiser)
                    {
                        // ����xmppת����Ϣ
                        ShiKuManager.SendForwardMessage(itemFriend.Value, message);
                    }
                });
            });
            var colleitem = new MenuItem("�ղ�", (sen, eve) =>
            {

                CollectUtils.CollectMessage(message);
            });
            var cm = new ContextMenu();
            cm.MenuItems.Add(copyitem);
            cm.MenuItems.Add(sendcard);
            cm.MenuItems.Add(colleitem);
            item.ContextMenu = cm;//�����Ҽ��˵�
            item.MouseDown += ClickSelectItem;//�����¼�
        }
        //��������
        private void CopyData(MessageObject message)
        {
            if (message.type == kWCMessageType.Text || message.type == kWCMessageType.Replay)
            {
                Clipboard.Clear();
                string selected = richText.SelectedText;
                if (selected.Length == 0)
                {
                    Clipboard.SetText(message.content);
                    return;
                }
                //�����а����ö���
                Clipboard.SetText(message.content);
            }
            if (message.type == kWCMessageType.Image)
            {
                Clipboard.Clear();
                //�����а�����ͼƬ����
                Clipboard.SetImage(pictureBoxImage.Image);
            }
            if (message.type == kWCMessageType.File || message.type == kWCMessageType.Video)
            {
                string fileNames = FileUtils.GetFileName(message.fileName);
                string path = "";
                path = Applicate.LocalConfigData.RoomFileFolderPath + fileNames;
                if (!File.Exists(message.content))
                {
                    DownFile(path, message.content, true);
                }
                else
                {
                    path = message.content;
                }
                Clipboard.Clear();
                System.Collections.Specialized.StringCollection files = new System.Collections.Specialized.StringCollection();
                files.Add(path);
                Clipboard.SetFileDropList(files);
            }
        }
        #endregion
        #region ѡ�ж�Ӧ��
        private void ClickSelectItem(object sender, EventArgs e)
        {
            Control item = sender as Control;
            MessageObject message = item.Tag as MessageObject;
            //��ȫ�ֱ�����ֵ
            if (message.type == kWCMessageType.Image)
            {
                //��ȫ�ֱ�����ֵ
                pictureBoxImage = sender as PictureBox;

            }
            else if (message.type == kWCMessageType.Text)
            {
                richText = sender as RichTextBoxEx;
            }
            else if (message.type == kWCMessageType.Video)
            {
                pictureBoxVideo = sender as PictureBox;

            }
            else if (message.type == kWCMessageType.File)
            {
                panel_file = sender as FilePanelLeft;
                chatFile = sender as ChatItem;
            }
            else if (message.type == kWCMessageType.Replay)
            {
                richText = sender as RichTextBoxEx;
            }
        }
        #endregion
        #region ͼƬ����¼�
        /// <summary>
        /// ��ͼƬ�鿴��
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void MouseClie(object sender, MouseEventArgs e)
        {
            //��ȡ��ǰ��ͼƬ
            PictureBox picture = (PictureBox)sender;
            if (e.Button == MouseButtons.Left)
            {
                FrmLookImage frm = new FrmLookImage();
                //��ȡTagֵ
                string messageid = (string)picture.Name;
                //���
                List<MessageObject> listmessage = ShowMsgImageList(friends.UserId);
                //����
                int index = 0;
                for (int i = 0; i < listmessage.Count; i++)
                {
                    if (listmessage[i].messageId.Equals(messageid))
                    {
                        index = i;
                        break;

                    }
                    frm.fielSize = listmessage[i].fileSize.ToString();
                }
                frm.ShowImageList(listmessage, index);
            }

        }
        //��Ƶ����
        public static void Vido_clike(object sender, MouseEventArgs e)
        {
            PictureBox picture = (PictureBox)sender;
            if (e.Button == MouseButtons.Left)
            {
                FrmVideoFlash frm = FrmVideoFlash.CreateInstrance();
                frm.VidoShowList((MessageObject)picture.Tag);
                frm.Show();
            }
        }
        #endregion
        #region ���ݿ��ѯ
        //��������
        public static List<MessageObject> ShowMsgList(string toUserid)
        {
            //��ҳ��������
            List<MessageObject> messages = new MessageObject()
            {
                FromId = Applicate.MyAccount.userId,
                ToId = toUserid
            }.GetPageListHistory(1, 30);
            return messages;
        }
        //�ļ�
        public static List<MessageObject> ShowMsgFileList(string toUserid)
        {
            //��ҳ��������
            List<MessageObject> messages = new MessageObject()
            {
                FromId = Applicate.MyAccount.userId,
                ToId = toUserid
            }.GetFileList(1, 30);
            return messages;

        }
        //ͼƬ
        public static List<MessageObject> ShowMsgImageList(string toUserid)
        {
            //��ҳ��������
            List<MessageObject> messages = new MessageObject()
            {
                FromId = Applicate.MyAccount.userId,
                ToId = toUserid
            }.GetVideoImageList(1, 30);
            return messages;

        }
        //��ʷ��¼
        public static List<MessageObject> ShowMsgHistoryList(string toUserid, string content)
        {
            //��ҳ��������
            List<MessageObject> messages = new MessageObject()
            {
                FromId = Applicate.MyAccount.userId,
                ToId = toUserid
            }.GetPageHotrysList(1, content, 1, 30);
            return messages;

        }
        #endregion
        #region ��ȡ��������emaijo����
        public static void Calc_PanelWidth(Control control)
        {
            if (!(control is RichTextBoxEx richContent))
                return;

            //��ʱ����һ������װ������
            RichTextBoxEx canv_Rich = control as RichTextBoxEx;
            //��ȡȫ��Text��ֵ
            canv_Rich.Text = richContent.Text;
            //��codeתΪemoji
            canv_Rich.Rtf = GetLink(canv_Rich.Text);
            canv_Rich.Font = new Font(Applicate.SetFont, 10);//������������ģ�һ�������٣���Ȼ����Ĭ�ϵ�������
            richContent.Rtf = canv_Rich.Rtf;
        }
        public static string GetLink(string msgText)
        {
            RichTextBoxEx richTextBox = new RichTextBoxEx();
            richTextBox.Text = msgText;
            MatchCollection msg = Regex.Matches(msgText, @"^http://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            foreach (Match match in msg)
            {
                int str_index = richTextBox.Text.IndexOf(match.Value);
                richTextBox.SelectionStart = str_index;
                richTextBox.SelectionLength = match.Value.Length;
                richTextBox.SelectedText = "";
                richTextBox.InsertLink(match.Value);
            }

            //������ʽ

            //emajio����
            msg = Regex.Matches(richTextBox.Text, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            emoji_count = msg.Count;
            int index = 0;
            string[] newStr = new string[msg.Count];
            foreach (Match item in msg)
            {
                newStr[index] = item.Groups[0].Value;
                index++;
            }
            //ѭ���滻codeΪ����ͼƬ
            for (int i = 0; i < newStr.Length; i++)
            {
                //bool isMin = friends.userId == Applicate.MyAccount.userId;
                richTextBox.Rtf = richTextBox.Rtf.Replace(newStr[i], EnjoyCodeColor.GetEmojiRtfByCode(newStr[i], Color.White));
              //  richTextBox.Rtf = richTextBox.Rtf.Replace(newStr[i], EmojiCodeDictionary.GetEmojiRtfByCode(newStr[i]));
            }
            string result = richTextBox.Rtf;
            richTextBox.Dispose();
            return result;
        }
        #endregion
        #region ��ѯ��Ϣ��¼
        private void searchTextBox_Load(object sender, EventArgs e)
        {
            searchTextBox.txtSearch.TextChanged += new EventHandler(txtSearch_click);
        }
        private void txtSearch_click(object sender, EventArgs e)
        {
            string content = searchTextBox.txtSearch.Text;
            if (!string.IsNullOrEmpty(content))
            {
                xListView1.ClearList();
                LodingUtils loding = new LodingUtils();
                loding.parent = xListView1;
                loding.size = xListView1.Size;
                loding.start();
                List<MessageObject> newListData = new List<MessageObject>();

                if (lblAll.Visible)
                {
                    newListData = ShowMsgHistoryList(friends.UserId, content);
                }
                else
                {
                    foreach (var item in listData)
                    {
                        if (item.content.Contains(content))
                        {
                            newListData.Add(item);
                        }
                    }
                }
           
                mAdapter.isclickFileButton = false;
                BindData(newListData);
                loding.stop();
            }
            else
            {
                mAdapter.isclickFileButton = false;
                BindData(listData);
            }
        }
        #endregion
        #region ����ر�
        private void FrmHistoryChat_FormClosed(object sender, FormClosedEventArgs e)
        {
            frm.Dispose();
            frm = null;
        }
        #endregion

        private void FrmHistoryChat_Load(object sender, EventArgs e)
        {

        }
        #region ����excel �ļ��� txt �ļ�
        /// <summary>
        /// ��ȡ�ļ�·��
        /// </summary>
        /// <returns></returns>

        public   string GetImagePath()
        {
            string personImgPath = "";
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            dialog.Description = "��ѡ���ļ�·��";

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                personImgPath = dialog.SelectedPath;

            }

            return personImgPath;
        }
        /// <summary>
        /// ����excel�ĵ�
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button1_Click(object sender, EventArgs e)
        {
            string personImgPath = "";
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            dialog.Description = "��ѡ���ļ�·��";

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                personImgPath = dialog.SelectedPath;

            }

            else
            {
                return;
            }
            if (!this.btninpuexcel.Enabled)
            { return; }
            this.btninpuexcel.Enabled = false;
            //�ҽ�ҵ������߳��ﴦ��,���������߳���,this.btnConfirm.Enabled = false;�����н�ֹЧ��,��Ϊ�������߳�û����ɡ�
            Task task = new Task(() =>
            {
                string filepath = personImgPath + "\\" + friends.NickName + "��" + Applicate.MyAccount.nickname + "�������¼" + (friends.UserId).Substring(friends.UserId.Length - 4, 4) + ".xlsx"; //�ļ�·��
                if (File.Exists(filepath))
                {
                    File.Delete(filepath);
                }
                DataTable dt = new DataTable();
                List<MessageObject> Alllist = new List<MessageObject>();
                Alllist = ShowAllMsgList(friends.UserId);
                dt.Columns.Add("������");//��

                dt.Columns.Add("����");
                dt.Columns.Add("ʱ��");
                dt.Columns.Add("����");
                for (int i = 0; i < Alllist.Count; i++)
                {
                    DataRow dr2 = dt.NewRow();//��
                    dr2[0] = Alllist[i].fromUserName;

                    if (Alllist[i].content == null)
                    {
                        Alllist[i].content = "";
                    }
                    dr2[1] = Alllist[i].content;
                    dr2[2] = TimeUtils.FromatTime(Convert.ToInt64(Alllist[i].timeSend), "yyyy / MM / dd HH: mm:ss");
                    dr2[3] = UIUtils.NewstypeTostring(Alllist[i].type);
                    dt.Rows.Add(dr2);
                }
                //DataSetToExcel()
                InputFileUtils.DataTableToExcel(filepath, dt, false);//����exele,
                btninpuexcel.Enabled = true;
            }
            );
            task.Start();
        }
        /// <summary>
        /// ��ȡ��ú��ѵ����������¼������ҳ)
        /// </summary>
        /// <param name="toUserid"></param>
        /// <returns></returns>
        public static List<MessageObject> ShowAllMsgList(string toUserid)
        {
            List<MessageObject> messages = new MessageObject()
            {
                FromId = Applicate.MyAccount.userId,
                ToId = toUserid
            }.LoadRecordMsg();
            return messages;
        }
        /// <summary>
        /// ����txt�ĵ�
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btninputtxt_Click(object sender, EventArgs e)
        {
            string personImgPath = "";
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            dialog.Description = "��ѡ���ļ�·��";

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                personImgPath = dialog.SelectedPath;

            }

            else
            {
                return;
            }
            if (!this.btninputtxt.Enabled)
            { return; }
            this.btninputtxt.Enabled = false;
            //�ҽ�ҵ������߳��ﴦ��,���������߳���,this.btnConfirm.Enabled = false;�����н�ֹЧ��,��Ϊ�������߳�û����ɡ�
            Task task = new Task(() =>
            {
                string filepath = personImgPath + "\\" + friends.NickName + "��" + Applicate.MyAccount.nickname + "�������¼" + (friends.UserId).Substring(friends.UserId.Length - 4, 4) + ".txt"; //�ļ�·��
                if (File.Exists(filepath))
                {
                    File.Delete(filepath);
                }
                List<MessageObject> Alllist = new List<MessageObject>();
                Alllist = ShowAllMsgList(friends.UserId);
                InputFileUtils.SaveTxtFile(Alllist, filepath);
                btninputtxt.Enabled = true;
            }
            );
            task.Start();
        }

        #endregion

      
        private void lblNickName_TextChanged(object sender, EventArgs e)
        {
            EQControlManager.StrAddEllipsis(lblNickName, lblNickName.Font, this.Width - 40);
        }
    }
}
