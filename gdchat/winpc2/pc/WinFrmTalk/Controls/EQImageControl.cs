using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Windows.Forms;
using CCWin.SkinControl;
using WinFrmTalk.Controls;
using WinFrmTalk;
using WinFrmTalk.Model;
using WinFrmTalk.Dictionarys;
using System.Threading;
using WinFrmTalk.Properties;
using TestListView;
using WinFrmTalk.Controls.CustomControls;

namespace WinFrmTalk.Controls
{
    public class EQImageControl : EQBaseControl
    {
        private static string file_path = "";
        public EQImageControl(string strJson) : base(strJson)
        {
            isRemindMessage = false;
            isShowRedPoint = false;
        }

        public EQImageControl(MessageObject messageObject) : base(messageObject)
        {
            isRemindMessage = false;
            isShowRedPoint = false;
        }

        #region 弃置代码
        private Bitmap GetContentImage(string content_image)
        {
            Bitmap bitmap = GetBitmap(content_image);

            int width = bitmap.Width;
            int height = bitmap.Height;
            EQControlManager.ModifyWidthAndHeight(ref width, ref height, 250, 250);
            Bitmap new_image = EQControlManager.ModifyBitmapSize(bitmap, width, height);

            return new_image;
        }

        /// <summary>
        /// 根据网络路径获取图片
        /// </summary>
        /// <param name="imageUri">图片网络路径</param>
        /// <returns></returns>
        public Bitmap GetBitmap(String imageUri)
        {
            //使用默认头像进行初始化
            Bitmap image_content = new Bitmap(Applicate.LocalConfigData.ImageFolderPath + "fez.png");
            //获取图片
            string file_name = messageObject.fileName;
            if (messageObject.fileName.IndexOf('/') > -1)
                file_name = messageObject.fileName.Substring(messageObject.fileName.LastIndexOf('/') + 1);
            file_path = Applicate.LocalConfigData.ImageFolderPath + file_name;
            if (File.Exists(file_path))    //如果该图片已存在
            {
                image_content = new Bitmap(file_path);
            }
            else    //图片在本地不存在，需要下载
            {
                //否则使用默认头像并下载对应头像,,完成后再填充
                //var client = new WebClient();
                //client.DownloadFile(new Uri(messageObject.content), file_path);
                //client.DownloadFileCompleted += (sen, ev) =>
                //{
                //if (ev.Error == null)    //下载成功
                //{
                //image_content = new Bitmap(file_path);
                //}
                //else    //下载失败
                //{

                //}
                //};
            }

            //Image image = Image.FromStream(System.Net.WebRequest.Create(imageUri).GetResponse().GetResponseStream());
            //Bitmap bitmap = new Bitmap(image);
            return image_content;
        }
        #endregion

        public override Control ContentControl()
        {
            PictureBox pic_image = new PictureBox();
            //try
            //{
            //Bitmap bitmap = GetContentImage(messageObject.content);
            //pic_image.Size = new Size(bitmap.Width, bitmap.Height);
            //pic_image.BackgroundImage = bitmap;
            pic_image.Name = "pic_image";
            pic_image.BackgroundImageLayout = ImageLayout.Stretch;
            pic_image.SizeMode = PictureBoxSizeMode.StretchImage;
            pic_image.Cursor = Cursors.Hand;
            pic_image.Tag = messageObject.messageId;       //保存messageId

            //string fileName = messageObject.content.Substring(messageObject.content.LastIndexOf("/") + 1);
            //fileName = Applicate.LocalConfigData.ImageFolderPath + fileName;

            #region 设置默认图片
            Bitmap bmp = Resources.ic_black_rect;
            int bmp_width = 0, bmp_height = 0;
            if (messageObject.BubbleWidth > 0 && messageObject.BubbleHeight > 0)
            {
                bmp_width = (int)messageObject.BubbleWidth;
                bmp_height = (int)messageObject.BubbleHeight;
                EQControlManager.ModifyWidthAndHeight(ref bmp_width, ref bmp_height, 250, 250);
            }
            else
            {
                bmp_width = bmp.Width;
                bmp_height = bmp.Height;
            }
            //EQControlManager.ModifyWidthAndHeight(ref bmp_width, ref bmp_height, 250, 250);
            //Bitmap new_image = EQControlManager.ModifyBitmapSize(bmp, bmp_width, bmp_height);
            //pic_image.BackgroundImage = bmp;
            pic_image.Size = new Size(bmp_width, bmp_height);
            Calc_PanelWidth(pic_image);
            #endregion

            #region 下载图片
            //启用等待符
            LodingUtils loding = new LodingUtils();
            loding.size = new Size(10, 10);
            loding.parent = pic_image;
            loding.BgColor = Color.Transparent;
            loding.start();

            LoadImage(pic_image);
            #endregion
            //}
            //catch (Exception e)
            //{
            //    throw e;
            //}

            //添加鼠标左键点击事件
            pic_image.MouseClick += (sender, e) =>
            {
                if (e.Button == MouseButtons.Left)
                {
                    //图片未加载完成
                    string msgId = pic_image.Tag == null ? "" : pic_image.Tag.ToString();
                    //MessageObject i_msg = MessageObjectDataDictionary.GetMsg(msgId);
                    MessageObject i_msg = this.messageObject;
                    if (i_msg == null)
                        return;

                    FrmLookImage frmLookImage = new FrmLookImage();
                    //当前点击的图片索引
                    int click_index = 0;
                    //所有图片消息类型
                    List<MessageObject> msgs = new List<MessageObject>();
                    //聊天对象的userId
                    string userId = i_msg.GetChatTargetId();
                    //所有消息类型
                    MessageObjectDataDictionary targetMsgData = ChatTargetDictionary.GetMsgData(userId);
                    var messageObjects = targetMsgData.GetMsgList();
                    //循环获得所有图片集合
                    foreach (MessageObject msg in messageObjects)
                    {
                        if (msg.type == kWCMessageType.Image)
                            msgs.Add(msg);
                    }
                    //循环获得当前选中的图片
                    for (int index = 0; index < msgs.Count; index++)
                    {
                        if (msgs[index].messageId == pic_image.Tag.ToString())
                        {
                            click_index = index;
                            break;
                        }
                    }
                    frmLookImage.ShowImageList(msgs, click_index);
                }
                else if (e.Button == MouseButtons.Right)
                {
                    mouseDownListen?.Invoke();
                }
            };
            return pic_image;
        }

        //计算气泡宽高
        public override void Calc_PanelWidth(Control control)
        {
            BubbleHeight = control.Height;
            BubbleWidth = control.Width;
        }

        #region 加载图片
        public void LoadImage(PictureBox pic_image)
        {
            //if (string.IsNullOrEmpty(messageObject.content))
            //{
            //    //关闭等待符
            //    if (pic_image.Controls.Find("loding", true).Length > 0 && pic_image.Controls.Find("loding", true)[0] is USELoding loding)
            //    {
            //        loding.Dispose();
            //        Helpers.ClearMemory();
            //    }
            //}
            //else
            //MessageObject msg = MessageObjectDataDictionary.GetMsg(pic_image.Tag.ToString());
            MessageObject msg = this.messageObject;
            if (msg == null || string.IsNullOrEmpty(msg.content))
                return;
            ImageLoader.Instance.Load(msg.content).NoCache().Into((image, path) =>
            {
                Helpers.ClearMemory();  //加载大图会占用很多内存
                int width = 0, height = 0;
                if (messageObject.BubbleHeight > 0 && messageObject.BubbleWidth > 0)
                {
                    width = messageObject.BubbleWidth;
                    height = messageObject.BubbleHeight;
                }
                else
                {
                    width = image.Width;
                    height = image.Height;
                    EQControlManager.ModifyWidthAndHeight(ref width, ref height, 250, 250);
                }
                int addWidth = width - pic_image.Width;
                int addHeight = height - pic_image.Height;
                if (Path.GetExtension(msg.content).Equals(".gif"))
                {
                    FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
                    Image img = Image.FromStream(fs);
                    pic_image.Image = img;
                }
                else
                {
                    Bitmap mdf_image = EQControlManager.ModifyBitmapSize(image, width, height);
                    //mdf_image.Save("D:\\big.jpg");
                    image.Dispose();
                    pic_image.BackgroundImage = mdf_image;
                }
                pic_image.Size = new Size(width, height);
                //pic_image.Tag = pic_image.Tag == null ? messageObject.messageId : pic_image.Tag;       //保存messageId
                Calc_PanelWidth(pic_image);

                //未进行过刷新
                if (!msg.isRefresh)
                    if (xListView != null && xListView.Parent != null && xListView.Parent is ShowMsgPanel showMsgPanel)
                    {
                        msg.isRefresh = true;
                        int index = showMsgPanel.msgTabAdapter.msgList.FindIndex(m => m.messageId == msg.messageId);

                        //回到主线程
                        if (IsHandleCreated)
                            Invoke(new Action(() =>
                            {
                                xListView.RefreshItem(index);

                                //获取滚动条的位置
                                int progress = xListView.Progress;
                                //如果是自己发送的消息，或者当前滚动到了底部，则调用滚动到底部的方法
                                if (progress == 100)
                                {
                                    int end = showMsgPanel.msgTabAdapter.msgList.Count - 1;
                                    xListView.ShowRangeEnd(end, 0);
                                }
                            }));                        
                    }

                //由于异步的原因，可能已经加载至主界面
                if (pic_image.Parent != null && pic_image.Parent is EQBaseControl talk_panel)    //Name: talk_panel_messageId
                {
                    if (msg != null)
                    {
                        if (talk_panel.Parent != null || talk_panel.Parent.Parent != null)
                            if (pic_image.Parent.Parent != null && pic_image.Parent.Parent is TableLayoutPanelEx showInfo_panel)
                            {
                                //string messageId = pic_image.Parent.Name.Substring(pic_image.Parent.Name.LastIndexOf("_") + 1);
                                //if (!string.IsNullOrEmpty(messageId) && MessageObjectDataDictionary.GetMsg(messageId) != null)
                                //    return;
                                //int row_index = MessageObjectDataDictionary.GetMsg(messageId).rowIndex;
                                int row_index = msg.rowIndex;
                                //showInfo_panel.RowStyles[row_index].Height += addHeight;
                                showInfo_panel.Height += addHeight;

                                //调整位置
                                if (showInfo_panel.Top < 0)
                                    showInfo_panel.Top -= addHeight;

                                //必须先修改列表行高再修改气泡高度
                                int lab_msg_width = 0, lab_head_width = 0, lab_del_width = 0;
                                //气泡对齐
                                int align = 5;

                                var result = pic_image.Parent.Controls.Find("lab_head", false);
                                if (result.Length > 0)
                                {
                                    lab_head_width = result[0].Width;

                                    //如果有头像需要修改自己的位置
                                    if (msg.fromUserId == Applicate.MyAccount.userId)
                                        //修改头像的位置
                                        result[0].Location = new Point(pic_image.Location.X + width + 10 + align, result[0].Location.Y);
                                }
                                result = pic_image.Parent.Controls.Find("lab_msg", false);
                                if (result.Count() > 0 && result[0] is Label lab_msg)
                                {
                                    if (msg.fromUserId != Applicate.MyAccount.userId)
                                        lab_msg.Location = new Point(lab_msg.Location.X + addWidth, lab_msg.Location.Y);
                                    lab_msg_width = lab_msg.Width;
                                }

                                //如果是对方发的阅后即焚消息，需要修改位置
                                if (msg.isReadDel == 1 && msg.fromUserId != Applicate.MyAccount.userId)
                                {
                                    var crls_result = pic_image.Parent.Controls.Find("lab_readDeleted", true);
                                    if (crls_result.Length > 0 && crls_result[0] is Label lab_readDeleted)
                                    {
                                        lab_del_width = lab_readDeleted.Width;
                                        lab_readDeleted.Location = new Point(lab_readDeleted.Location.X + addWidth, lab_readDeleted.Location.Y + addHeight / 2);
                                    }
                                }
                                //必须修改父级容器的大小，才能有足够空间完整显示
                                int talk_panel_height = pic_image.Parent.Height + addHeight;
                                //图片消息类型的最小高度比文本消息类型的小10
                                if (talk_panel_height < (minHeight - 10))
                                {
                                    int modifyHeight = (minHeight - 10) - talk_panel_height;
                                    //调整聊天面板
                                    showInfo_panel.Height += modifyHeight;

                                    //调整位置
                                    if (showInfo_panel.Top < 0)
                                        showInfo_panel.Top -= modifyHeight;

                                    pic_image.Parent.Size = new Size(width +
                                        (lab_del_width > lab_msg_width ? lab_del_width : lab_msg_width) +
                                        lab_head_width + 20 + align,
                                        minHeight - 10 - 1);  //高度
                                    showInfo_panel.RowStyles[msg.rowIndex].Height = minHeight - 10 - 1 + 6;
                                }
                                else
                                {
                                    pic_image.Parent.Size = new Size(width +
                                            (lab_del_width > lab_msg_width ? lab_del_width : lab_msg_width) +
                                            lab_head_width + 20 + align,
                                            pic_image.Parent.Height + addHeight);  //高度
                                    showInfo_panel.RowStyles[msg.rowIndex].Height += addHeight;
                                }
                            }
                    }
                }
                //关闭等待符
                if (pic_image.Controls.Find("loding", true).Length > 0 && pic_image.Controls.Find("loding", true)[0] is USELoding loding)
                {
                    loding.Dispose();
                    Helpers.ClearMemory();
                }
            });
        }
        #endregion
    }
}
