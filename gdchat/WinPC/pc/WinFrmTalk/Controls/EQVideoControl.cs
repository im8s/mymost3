using System;
using System.Drawing;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Helper.MVVM;
using WinFrmTalk.Model;
using WinFrmTalk.View;

namespace WinFrmTalk.Controls
{
    public class EQVideoControl : EQBaseControl
    {
        public EQVideoControl(string strJson) : base(strJson)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public EQVideoControl(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleWidth = control.Width;
            BubbleHeight = control.Height;
        }

        public override Control ContentControl()
        {
            Size size = Size.Empty;
            if(this.messageObject.BubbleWidth > 0)
                size = new Size(this.messageObject.BubbleWidth, this.messageObject.BubbleHeight);
            else
                size = new Size(200, 200);
            PictureBox pic_content = new PictureBox();
            pic_content.BackColor = bg_color;
            pic_content.Size = size;
            pic_content.Tag = messageObject.messageId;
            //设置控件的背景图片和控件大小
            SetPicContentImage(pic_content);

            Calc_PanelWidth(pic_content);
            return pic_content;
        }

        private void SetPicContentImage(PictureBox pic_content)
        {
            //启用等待符
            //LodingUtils loding = new LodingUtils();
            //loding.size = new Size(10, 10);
            //loding.parent = pic_content;
            //loding.BgColor = Color.Transparent;
            //loding.start();

            LoadVideo(pic_content);
        }

        /// <summary>
        /// 加载视频消息图片控件
        /// </summary>
        /// <param name="pic_content">视频的图片控件</param>
        /// <param name="isReUpload">是否重新上传</param>
        public void LoadVideo(PictureBox pic_content)
        {
            MessageObject msg = this.messageObject;
            //if (msg.isLoading == 0)
            //{
            //    if (msg == null || string.IsNullOrEmpty(msg.content))
            //    {
            //        msg.isSend = -1;
            //        msg.UpdateData();

            //        //关闭等待符
            //        //var result = pic_content.Controls.Find("loding", true);
            //        //if (result.Length > 0 && result[0] is USELoding loding)
            //        //{
            //        //    loding.Dispose();
            //        //    Helpers.ClearMemory();
            //        //}

            //        Image bg_image = Image.FromFile(@"Res\load_default.png");
            //        pic_content.BackgroundImage = bg_image;
            //        pic_content.BackgroundImageLayout = ImageLayout.Stretch;

            //        //更新UI的送达状态
            //        if (pic_content.Parent != null && pic_content.Parent is EQBaseControl talk_panel)
            //        {
            //            if (talk_panel.Controls["lab_msg"] != null && talk_panel.Controls["lab_msg"] is Label lab_msg)
            //                EQControlManager.DrawIsSend(msg, lab_msg);
            //        }
            //    }
            //}
            if (string.IsNullOrEmpty(msg.content) || msg.content.IndexOf("http") < 0)
                return;
            ThubImageLoader.Instance.Load(msg.content, pic_content, (sucess, width, height) =>
            {
                //关闭等待符
                //var result = pic_content.Controls.Find("loding", true);
                //if (result.Length > 0 && result[0] is USELoding loding)
                //{
                //    loding.Dispose();
                //    Helpers.ClearMemory();
                //}

                //if (xListView != null && xListView.Parent != null && xListView.Parent is ShowMsgPanel showMsgPanel)
                //{
                //    int index = showMsgPanel.msgTabAdapter.msgList.FindIndex(m => m.messageId == msg.messageId);
                //    xListView.RefreshItem(index);
                //}

                if (sucess && msg.content.IndexOf("http") > -1)
                {
                    //未进行过刷新
                    if (!msg.isRefresh)
                        if (xListView != null && xListView.Parent != null && xListView.Parent is ShowMsgPanel showMsgPanel)
                        {
                            msg.isRefresh = true;
                            int index = showMsgPanel.msgTabAdapter.msgList.FindIndex(m => m.messageId == msg.messageId);
                            EQControlManager.ModifyWidthAndHeight(ref width, ref height, 250, 250);

                            msg.BubbleHeight = height;
                            msg.BubbleWidth = width;
                            msg.UpdateData();

                            //回到主线程
                            if (IsHandleCreated)
                                Invoke(new Action(() =>
                                {
                                    //刷新项
                                    xListView.RefreshItem(index);

                                    //获取滚动条的位置
                                    int progress = xListView.Progress;
                                    //当前滚动到了底部，则调用滚动到底部的方法
                                    if (progress == 100)
                                    {
                                        int end = showMsgPanel.msgTabAdapter.msgList.Count - 1;
                                        xListView.ShowRangeEnd(end, 0);
                                    }
                                }));
                        }

                    //添加点击打开视频的事件
                    pic_content.Click += (sen, e) =>
                    {
                        if (string.IsNullOrEmpty(msg.content) || ((MouseEventArgs)e).Button != MouseButtons.Left)
                            return;
                        //播放视频
                        //FrmPlayVideo frmPlayVideo = new FrmPlayVideo();
                        //((AxWindowsMediaPlayer)frmPlayVideo.Controls["axWindowsMediaPlayer1"]).URL = msg.content;
                        //frmPlayVideo.Show();
                        FrmVideoFlash frmVideoFlash = FrmVideoFlash.CreateInstrance();
                        frmVideoFlash.VidoShowList(msg);
                        frmVideoFlash.FilePath = msg.content;
                        frmVideoFlash.fileSize = msg.fileSize;
                        frmVideoFlash.Show();
                        //阅后即焚
                        if (msg.isReadDel == 1 && msg.fromUserId != Applicate.MyAccount.userId)
                        {
                            //frmVideoFlash.ShowDialog();
                            Messenger.Default.Send<string>(msg.messageId, token: EQFrmInteraction.RemoveMsgOfPanel);
                        }
                        else
                        {
                            //frmVideoFlash.Show();
                            //更新红点
                            var crl_msg = pic_content.Parent.Controls["lab_redPoint"];
                            if (crl_msg != null && crl_msg is Label lab_redPoint && lab_redPoint.Image != null)
                            {
                                //去除红点
                                DrawIsReceive(lab_redPoint, 1);
                            }
                        }

                        if (msg.isRead == 0)
                            ShiKuManager.SendReadMessage(msg.GetFriend(), msg);

                    };
                }
            });
        }
     
    }
}
