using System;
using System.Drawing;
using System.IO;
using System.Net;
using System.Windows.Forms;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Helper;
using WinFrmTalk.Helper.MVVM;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQVoiceControl : EQBaseControl
    {
        MP3Player mp3 = new MP3Player();
        //static string mp3_fileName = "";        //mp3文件名
        //static string amr_fileName = "";        //amr文件名
        string fileName => Path.GetFileNameWithoutExtension(messageObject.content);           //不含扩展名的文件名
        string bg_filePath = "";        //初始背景

        public EQVoiceControl(string strJson) : base(strJson)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public EQVoiceControl(MessageObject messageObject) : base(messageObject)
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
            Panel panel_voice = new Panel();
            panel_voice.Name = "panel_voice";
            panel_voice.MaximumSize = new Size(250, 0);
            panel_voice.Size = new Size(60 + 5 * messageObject.timeLen, 25);
            panel_voice.BackColor = bg_color;
            panel_voice.Cursor = Cursors.Hand;
            panel_voice.Tag = messageObject.messageId;
            if (isOneSelf)
            {
                bg_filePath = Environment.CurrentDirectory + @"\Res\VoiceBg\voice_paly_right_3.png";
                panel_voice.RightToLeft = RightToLeft.Yes;
            }
            else
            {
                bg_filePath = Environment.CurrentDirectory + @"\Res\VoiceBg\voice_paly_left_3.png";
                panel_voice.RightToLeft = RightToLeft.No;
            }
            Image image = Image.FromFile(bg_filePath);
            panel_voice.BackgroundImage = new Bitmap(image, 23, 23);
            panel_voice.BackgroundImageLayout = ImageLayout.None;
            //添加点击事件
            panel_voice.MouseDown += Panel_voice_MouseDown;

            //显示语音时长
            if (messageObject.timeLen > 0)
            {
                Label lblTimeLen = new Label();
                lblTimeLen.AutoSize = false;
                //lblTimeLen.Dock = DockStyle.Right;
                lblTimeLen.Text = messageObject.timeLen + "″";
                lblTimeLen.Font = new Font(Applicate.SetFont, 10F);
                lblTimeLen.ForeColor = Color.FromArgb(156, 156, 156);
                int width = (int)EQControlManager.GetStringTheSize(lblTimeLen.Text, new Font(Applicate.SetFont, 10F)).Width;
                lblTimeLen.Width = width + 5;
                int locationY = isOneSelf ? 0 : panel_voice.Width - width;
                lblTimeLen.Location = new Point(locationY, (panel_voice.Height - lblTimeLen.Height) / 2);
                panel_voice.Controls.Add(lblTimeLen);
            }

            //下载和转化文件
            DownloadAndChangeVoice(panel_voice);

            Calc_PanelWidth(panel_voice);
            return panel_voice;
        }

        private void Panel_voice_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left && sender is Panel panel_voice)
            {
                //获取语音的msg
                //MessageObject msg = MessageObjectDataDictionary.GetMsg(panel_voice.Tag != null ? panel_voice.Tag.ToString() : "");
                MessageObject msg = this.messageObject;
                if (msg == null)
                    return;
                //string fileName = FileUtils.GetFileName(msg.fileName).Replace(".amr", ".mp3");
                string mp3_fileName = Applicate.LocalConfigData.VoiceFolderPath + fileName + ".mp3";
                //MP3文件不存在
                if (!File.Exists(mp3_fileName))
                {
                    HttpUtils.Instance.ShowTip("语音文件不存在");
                    return;
                }

                //是否为自己发送的消息
                bool isMyMsg = msg.fromUserId == Applicate.MyAccount.userId;
                if (isMyMsg)
                    bg_filePath = Environment.CurrentDirectory + @"\Res\VoiceBg\voice_paly_right_3.png";
                else
                    bg_filePath = Environment.CurrentDirectory + @"\Res\VoiceBg\voice_paly_left_3.png";
                Image image = Image.FromFile(bg_filePath);

                #region 发送已读
                if (msg.isReadDel == 0)
                {
                    //更新红点
                    var crl_msg = panel_voice.Parent.Parent.Controls["lab_redPoint"];
                    if (crl_msg != null && crl_msg is Label lab_redPoint && lab_redPoint.Image != null)
                    {
                        //去除红点
                        DrawIsReceive(lab_redPoint, 1);
                    }
                }
                //发送已读通知
                if (msg.isRead == 0)
                    ShiKuManager.SendReadMessage(msg.GetFriend(), msg);
                #endregion

                //设置要播放的文件   
                mp3.FilePath = mp3_fileName;
                //播放   
                mp3.Play();

                #region 语音异步播放动画
                //语音长度
                int timeLen = msg.timeLen;
                //记录语音的帧数
                int frames = 0;
                //当前播放到第几秒
                int num = 0;
                //播放语音动画
                Timer voice_timer = new Timer();
                voice_timer.Interval = 1000;
                voice_timer.Enabled = true;
                voice_timer.Start();
                voice_timer.Tick += (s, ev) =>
                {
                    frames++;
                    num++;
                    //调用方法
                    Action action;
                    if (isMyMsg)
                        action = new Action(() =>
                        {
                            image = Image.FromFile(Environment.CurrentDirectory + @"\Res\VoiceBg\voice_paly_right_" + frames + ".png");
                            ((Panel)sender).BackgroundImage = new Bitmap(image, 23, 23);
                        });
                    else
                        action = new Action(() =>
                        {
                            image = Image.FromFile(Environment.CurrentDirectory + @"\Res\VoiceBg\voice_paly_left_" + frames + ".png");
                            ((Panel)sender).BackgroundImage = new Bitmap(image, 23, 23);
                        });
                    action.Invoke();
                    //播放三帧则重置
                    frames = frames % 3 == 0 ? 0 : frames;


                    //播放完毕
                    if (num > timeLen)
                    {
                        //结束计时
                        voice_timer.Stop();
                        voice_timer.Dispose();

                        //修改回默认图片
                        image = Image.FromFile(bg_filePath);
                        ((Panel)sender).BackgroundImage = new Bitmap(image, 23, 23);

                        //阅后即焚
                        if (msg.isReadDel == 1 && msg.fromUserId != Applicate.MyAccount.userId)
                            Messenger.Default.Send<string>(msg.messageId, token: EQFrmInteraction.RemoveMsgOfPanel);
                    }
                };
                #endregion
            }
        }

        /// <summary>
        /// 下载和转化文件
        /// </summary>
        public void DownloadAndChangeVoice(Panel panel_voice)
        {
            try
            {
                //拼接路径名
                string mp3_fileName = Applicate.LocalConfigData.VoiceFolderPath + fileName + ".mp3";
                string before_fileName = "";
                //获取文件后缀格式
                string format = Path.GetExtension(messageObject.content);
                if (format.Equals(".wav"))
                {
                    before_fileName = Applicate.LocalConfigData.VoiceFolderPath + fileName + ".wav";
                }
                else
                {
                    before_fileName = Applicate.LocalConfigData.VoiceFolderPath + fileName + ".amr";
                }
                //本地的mp3音频文件不存在
                if (!File.Exists(mp3_fileName))
                {
                    if (!File.Exists(before_fileName))         //如果音频不存在，则需要下载
                    {
                        LogUtils.Save("=====音频需要下载" + "======\r\n");
                        DownloadVoice(before_fileName, messageObject.content, panel_voice);
                    }
                    else
                    {
                        //如果只有amr文件，代表需要转换
                        ConvertToAmr(Application.StartupPath, before_fileName, mp3_fileName);
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.log.Error("音频解析出错，MessageId: " + messageObject.messageId + "; Erro: " + ex.Message);
                LogUtils.Save("=====音频解析出错，MessageId:" + messageObject.messageId + "; Erro: " + ex.Message + "======\r\n");

            }
        }

        private void DownloadVoice(string localpath, string content, Panel panel_voice)
        {
            if (string.IsNullOrEmpty(content))
                return;

            HttpDownloader.DownloadFile(content, localpath, (path) =>
            {
                //下载失败
                if (string.IsNullOrEmpty(path))
                {
                    LogHelper.log.Error(content + "，音频下载失败。。");
                    LogUtils.Save("=====音频下载失败，content:" + content+  "======\r\n");
                    return;
                }
                string mp3_fileName = Applicate.LocalConfigData.VoiceFolderPath + fileName + ".mp3";
                ConvertToAmr(Application.StartupPath, localpath, mp3_fileName);
                LogUtils.Save("=====音频转换MP3:"+ mp3_fileName+" ======\r\n");
            });
        }

        /// <summary>
        /// 将amr音频转成mp3手机音频（反过来也适用）
        /// </summary>
        /// <param name="applicationPath">ffmeg.exe文件路径</param>
        /// <param name="before_fileName">转化之前的文件的路径(带文件名)</param>
        /// <param name="after_fileName">生成目前mp3文件路径（带文件名）</param>
        public void ConvertToAmr(string applicationPath, string before_fileName, string after_fileName)
        {
            LogUtils.Save("=====ffmeg.exe文件路径："+ applicationPath+"======\r\n");
            LogUtils.Save("=====转化之前的文件的路径(带文件名)：" + before_fileName + "======\r\n");
            LogUtils.Save("=====生成目前mp3文件路径（带文件名）：" + after_fileName + "======\r\n");

            string c = applicationPath + @"\ffmpeg.exe -y -i " + before_fileName + " -ar 8000 -ab 12.2k -ac 1 " + after_fileName;
            LogUtils.Save("=====拼接的路径：" + c + "======\r\n");
            Cmd(c);
        }

        /// <summary>
        /// 执行Cmd命令
        /// </summary>
        private void Cmd(string c)
        {
            try
            {
                System.Diagnostics.Process process = new System.Diagnostics.Process();
                process.StartInfo.FileName = "cmd.exe";
                process.StartInfo.UseShellExecute = false;
                process.StartInfo.CreateNoWindow = true;
                process.StartInfo.RedirectStandardOutput = true;
                process.StartInfo.RedirectStandardInput = true;
                process.Start();
                process.StandardInput.WriteLine(c);
                process.StandardInput.AutoFlush = true;
                process.StandardInput.WriteLine("exit");
                StreamReader reader = process.StandardOutput;//截取输出流           
                //process.WaitForExit(5000);
                process.Close();
            }
            catch (Exception ex)
            {
                LogUtils.Save("=====z转换MP3格式错误：" + ex.Message + "======\r\n");

            }
        }
    }
}
