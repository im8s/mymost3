using Newtonsoft.Json;
using RichTextBoxLinks;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    class HistotyChatAdapter : IBaseAdapter
    {
        #region 全局变量
        private List<MessageObject> datas;
        public bool isclickFileButton;
        RichTextBoxEx richText = new RichTextBoxEx();
        PictureBox pictureBoxVideo = new PictureBox();
        PictureBox pictureBoxGif = new PictureBox();
        PictureBox pictureBoxImage = new PictureBox();
        FilePanelLeft panel_file = new FilePanelLeft();
        Panel pnlReplay = new Panel();
        #endregion
        public FrmHistoryChat FrmHistoryChat { get; set; }
        public void BindFriendData(List<MessageObject> data)
        {
            datas = data;
        }
        public override int GetItemCount()
        {
            if (datas != null)
            {
                return datas.Count;
            }

            return 0;
        }

        public override Control OnCreateControl(int index)
        {
            MessageObject message = datas[index];
            ChatItem chat=new ChatItem();
            if (!isclickFileButton)
            {
                //锚边
                string content = message.content;
                switch (message.type)
                {
                    case kWCMessageType.Text:
                        richText = new RichTextBoxEx();
                        richText.SelectionFont = new Font(Applicate.SetFont, 10);
                        richText.Font = new Font(Applicate.SetFont, 9);
                        richText.Size = new Size(420, 130);
                        richText.Location = new Point(73, 40);
                        richText.BorderStyle = BorderStyle.None;
                        richText.ScrollBars = RichTextBoxScrollBars.None;
                        richText.ReadOnly = true;
                        richText.BackColor = Color.White;
                        richText.Multiline = true;
                        richText.BringToFront();
                        richText.Text = content;
                        richText.Tag = message;
                        //自适应高度
                        richText.ContentsResized += FrmHistoryChat.RichTextBox_Height;
                        //超链接
                        richText.DetectUrls = true;
                        FrmHistoryChat.Calc_PanelWidth(richText);
                        //点击超链接
                        richText.LinkClicked += (sender, e) =>
                        {
                            MessageObject msg = message.CopyMessage();
                            msg.content = e.LinkText;
                            //打开浏览器窗口
                            FrmBrowser frm = new FrmBrowser();
                            frm.BrowserShow(msg);
                        };

                        chat.Size = new Size(567, richText.Height + 50);
                        chat.Controls.Add(richText);
                        //右键菜单
                        FrmHistoryChat.BindMouseDown(richText, message);

                        break;
                    case kWCMessageType.File:
                        UserFileLeft panel_file = new UserFileLeft();

                        panel_file.Cursor = Cursors.Hand;
                        string fileNames = FileUtils.GetFileName(message.fileName);
                        panel_file.lab_fileName.Text = fileNames;
                        panel_file.lab_fileSize.Text = UIUtils.FromatFileSize(message.fileSize)+" "+message.fromUserName;
                        panel_file.Location = new Point(70, 12);
                        panel_file.BringToFront();
                        panel_file.Tag = message;
                        FrmHistoryChat.TypeFileToImage(message.content, panel_file.lab_icon);
                        chat.lblName.Visible = false;
                       
                        foreach (Control itemControl in panel_file.Controls)
                        {
                            itemControl.MouseClick += (sender, e) =>
                            {
                                if (e.Button == MouseButtons.Left)
                                {
                                    string path = "";
                                    string fileName = "";
                                    path = message.content;
                                    fileName = FileUtils.GetFileName(message.content);
                                    string filePath = Applicate.LocalConfigData.RoomFileFolderPath + fileName;
                                    //下载
                                    FrmHistoryChat.DownFile(filePath, path);
                                }
                            };
                            if (itemControl.Controls.Count > 0)
                                foreach (Control itemcl in itemControl.Controls)
                                    itemcl.MouseClick += (sender, e) =>
                                    {
                                        if (e.Button == MouseButtons.Left)
                                        {
                                            string path = "";
                                            string fileName = "";
                                            path = message.content;
                                            fileName = FileUtils.GetFileName(message.content);
                                            string filePath = Applicate.LocalConfigData.RoomFileFolderPath + fileName;
                                            //下载
                                            FrmHistoryChat.DownFile(filePath, path);
                                        }
                                    };
                        }
                        chat.Controls.Add(panel_file);
                        FrmHistoryChat.BindMouseDown(panel_file, message);
                        break;
                    case kWCMessageType.Image:
                        //实例化控件
                        content = "";
                        chat.Size = new Size(564, 175);
                        pictureBoxImage = new PictureBox();
                        pictureBoxImage.Location = new Point(73, 35);
                        pictureBoxImage.Size = new Size(130, 130);
                        ImageLoader.Instance.Load(message.content).NoCache().Into(pictureBoxImage);
                        pictureBoxImage.SizeMode = PictureBoxSizeMode.StretchImage;
                        pictureBoxImage.Dock = DockStyle.None;
                        //绑定当前的索引
                        pictureBoxImage.Name = message.messageId;
                        pictureBoxImage.Tag = message;
                        pictureBoxImage.MouseClick += FrmHistoryChat.MouseClie;
                        chat.Controls.Add(pictureBoxImage);
                        FrmHistoryChat.BindMouseDown(pictureBoxImage, message);
                        break;
                    case kWCMessageType.Gif:
                        //实例化控件
                        content = "";
                        chat.Size = new Size(564, 175);
                        pictureBoxGif = new PictureBox();
                        pictureBoxGif.Location = new Point(73, 35);
                        pictureBoxGif.Size = new Size(130, 130);
                        pictureBoxGif.SizeMode = PictureBoxSizeMode.Zoom;
                        if (message.content.Contains("http") )
                        {
                            ImageLoader.Instance.Load( message.content).NoCache().Into(pictureBoxGif);
                        }
                        else
                        {
                            ImageLoader.Instance.Load(Applicate.LocalConfigData.GifFolderPath + message.content).NoCache().Into(pictureBoxGif);
                        }
                        pictureBoxGif.SizeMode = PictureBoxSizeMode.Zoom;
                        pictureBoxGif.Dock = DockStyle.None;
                        //绑定当前的索引
                        pictureBoxGif.Name = message.messageId;
                        pictureBoxGif.Tag = message;
                        pictureBoxGif.MouseClick += FrmHistoryChat.MouseClie;
                        chat.Controls.Add(pictureBoxGif);
                        FrmHistoryChat.BindMouseDown(pictureBoxGif, message);
                        
                        break;

                    case kWCMessageType.Video:
                        chat.Size = new Size(564, 175);
                        chat.lblDatime.Location = new Point(499, 17);
                        pictureBoxVideo = new PictureBox();
                        pictureBoxVideo.Location = new Point(73, 35);
                        pictureBoxVideo.Size = new Size(130, 130);
                        pictureBoxVideo.SizeMode = PictureBoxSizeMode.StretchImage;
                        pictureBoxVideo.Dock = DockStyle.None;
                        //绑定当前的索引
                        pictureBoxVideo.Tag = message;
                        #region 视频加载等待符
                        LodingUtils loding = new LodingUtils();
                        loding.size = new Size(10, 10);
                        loding.parent = pictureBoxVideo;
                        loding.BgColor = Color.Transparent;
                        loding.start();
                        ThubImageLoader.Instance.Load(message.content, pictureBoxVideo, (sucess) =>
                        {
                            //关闭等待符
                            var result = pictureBoxVideo.Controls.Find("loding", true);
                            if (result.Length > 0 && result[0] is USELoding lodings)
                            {
                                lodings.Dispose();
                                Helpers.ClearMemory();
                            }
                        });
                        #endregion
                      
                        pictureBoxVideo.MouseClick += FrmHistoryChat.Vido_clike;
                        chat.Controls.Add(pictureBoxVideo);
                        FrmHistoryChat.BindMouseDown(pictureBoxVideo, message);
                        break;
                    case kWCMessageType.Location:
                        content = "";
                        chat.Size = new Size(564, 135);
                        //实例化控件
                        Panel pnlLoction = new Panel();
                        pnlLoction.Cursor = Cursors.Hand;
                        pnlLoction.Location = new Point(73, 35);
                        pnlLoction.Size = new Size(200, 88);
                        pnlLoction.Tag = message.messageId;
                        //地图
                        PictureBox pic_image = new PictureBox();
                        pic_image.Size = new Size(196, 70);
                        pic_image.Location = new Point(1, 1);
                        pic_image.SizeMode = PictureBoxSizeMode.StretchImage;
                        pic_image.Dock = DockStyle.Top;
                        ImageLoader.Instance.Load(message.content).NoCache().Into(pic_image);
                        pnlLoction.Controls.Add(pic_image);
                        //增加布局
                        Label lab_name = new Label();
                        lab_name.BackColor = Color.White;
                        lab_name.Text = message.objectId;
                        lab_name.TextAlign = ContentAlignment.MiddleCenter;
                        lab_name.AutoSize = false;
                        lab_name.Size = new Size(200, 12);
                        lab_name.Location = new Point(4, 73);
                        pnlLoction.Controls.Add(lab_name);
                        chat.Controls.Add(pnlLoction);
                        pic_image.MouseClick += (sender, e) =>
                        {
                            if (e.Button == MouseButtons.Left)
                            {
                                FrmBrowser frm = new FrmBrowser();
                                frm.BrowserShow(message);
                            }
                        };
                        break;
                    case kWCMessageType.History:
                        Label lblText = new Label();
                        lblText.Font = new Font(Applicate.SetFont, 10);
                        lblText.AutoSize = false;
                        lblText.Size = new Size(150, 40);
                        lblText.Location = new Point(73, 40);
                        lblText.Text = "[聊天记录]";
                        chat.Controls.Add(lblText);
                        lblText.Cursor = Cursors.Hand;
                        lblText.MouseClick += (sender, e) =>
                        {
                            if (e.Button == MouseButtons.Left)
                            {
                                FrmHistoryMsg frmHistory = new FrmHistoryMsg();
                                frmHistory.content = message.content;
                                frmHistory.TitleText = datas[index].toUserName;
                                frmHistory.FromLocal = false;
                                frmHistory.Show();
                            }
                        };
                        break;
                    case kWCMessageType.Voice:
                        Label label = new Label();
                        label.Size = new Size(300, 100);
                        label.Location = new Point(73, 40);
                        label.Text = "[语音]";
                        chat.Controls.Add(label);
                        break;
                    case kWCMessageType.Replay:
                        pnlReplay = new Panel();
                        pnlReplay.Location = new Point(73, 35);
                        Label lblNickName = new Label();
                        lblNickName.Location = new Point(0, 4);
                        lblNickName.AutoSize = false;
                        lblNickName.Size = new Size(200, 12);
                        var data = JsonConvert.DeserializeObject<MessageObject>(message.objectId);
                        lblNickName.Text = "回复_" + data.fromUserName + ":";
                        richText = new RichTextBoxEx();
                        richText.Location = new Point(0, 20);
                        richText.Font = new Font(Applicate.SetFont, 9);
                        richText.Size = new Size(400, 140);
                        richText.BorderStyle = BorderStyle.None;
                        richText.ScrollBars = RichTextBoxScrollBars.None;
                        richText.ReadOnly = true;
                        richText.BackColor = Color.White;
                        richText.Multiline = true;
                        richText.Text = content;
                        richText.Tag = message;
                        //自适应高度
                        richText.ContentsResized += FrmHistoryChat.RichTextBox_Height;
                        //超链接
                        richText.DetectUrls = true;
                        FrmHistoryChat.Calc_PanelWidth(richText);
                        pnlReplay.Controls.Add(lblNickName);
                        pnlReplay.Controls.Add(richText);
                        pnlReplay.Size = new Size(564, richText.Height + 50);
                        chat.Controls.Add(pnlReplay);
                        chat.Size = new Size(564, pnlReplay.Height + 10);
                        //点击超链接
                        richText.LinkClicked += (sender, e) =>
                        {
                            MessageObject msg = message.CopyMessage();
                            msg.content = e.LinkText;
                            //打开浏览器窗口
                            FrmBrowser frm = new FrmBrowser();
                            frm.BrowserShow(msg);
                        };
                        FrmHistoryChat.BindMouseDown(richText, message);
                        break;

                }
                #region 加载信息
                ImageLoader.Instance.DisplayAvatar(message.fromUserId, chat.pboxHead);
                chat.Time = TimeUtils.ChatLastTime(message.timeSend);
                chat.fileName = message.fromUserName;
                if (message.type == kWCMessageType.Text || message.type == kWCMessageType.Replay)
                {
                    chat.Tag = message.content;
                }
                if (chat.Time.Length == 2)
                {
                    chat.Time = "  " + TimeUtils.ChatLastTime(message.timeSend);
                }
                else if (chat.Time.Length == 3)
                {
                    chat.Time = "" + TimeUtils.ChatLastTime(message.timeSend);
                }
                else
                {
                    chat.Time = TimeUtils.ChatLastTime(message.timeSend);
                }
            }
            else
            {
                chat = FrmHistoryChat.FileInfonmation(message);
            }
            #endregion
            return chat;
        }

        public override int OnMeasureHeight(int index)
        {
            EQControlManager.CalculateWidthAndHeight_Text(datas[index], false, 420);
            if (datas[index].type == kWCMessageType.Text)
            {
                return datas[index].BubbleHeight+75 ;
            }

            else if (datas[index].type == kWCMessageType.Image||datas[index].type==kWCMessageType.Video|| datas[index].type == kWCMessageType.Gif)
            {
                
                return datas[index].BubbleHeight + 135;
            }

            else if (datas[index].type == kWCMessageType.Location)
            {
                return datas[index].BubbleHeight + 110;
            }

            else if (datas[index].type == kWCMessageType.History || datas[index].type == kWCMessageType.File)
            {
                return 100;
            }

            else
                return datas[index].BubbleHeight + 70;
        }

        public override void RemoveData(int index)
        {
            datas.RemoveAt(index);
        }
    }
}
