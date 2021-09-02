using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Timers;
using System.Windows.Forms;
using WinFrmTalk.Properties;
using WinFrmTalk.Model;
using WinFrmTalk.Helper;

namespace WinFrmTalk.View
{
    public partial class FrmVideoFlash : FrmBase
    {
        #region 全局变量
        private VlcPlayer player;
        public int Seconds { get; private set; }
        //路径
        public string LocationPath;
        private MessageObject messageList;
        private bool isMessageObject;
        //大小
        public long fileSize;
        //单例
        private static FrmVideoFlash frm = null;
        private static LodingUtils loding = null;
        internal string FilePath;
        public string fileName;
        public bool isVideo;
        private double timer=0.00;
        public bool isCollect { get; set; }//判断是不是

        #endregion
        #region 窗体加载
        //单例模式
        public static FrmVideoFlash CreateInstrance()
        {
            if (frm == null || frm.IsDisposed)
            {
                frm = new FrmVideoFlash();
            }
            if (frm != null)
            {
                frm.Activate();
            }
            return frm;
        }
        private FrmVideoFlash()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            
        }
        private void FrmVideoFlash_Load(object sender, EventArgs e)
        {
            if (isCollect) pboxColle.Visible = false;
            //跨线程
            Control.CheckForIllegalCrossThreadCalls = false;
            //验证文件是否存在
            if (!isMessageObject)
            {
                if (IsFileExists(fileName))
                {
                    pboxDown.Visible = false;
                    pboxFile.Visible = true;
                    pboxFile.Location = pboxDown.Location;//换坐标
                    FilePath = Path.GetDirectoryName(FilePath);
                }
            }
            //下载好了的视频
            else
            {

                string path = LocalDataUtils.GetStringData(messageList.content);
                if (File.Exists(path))
                {
                    // 下载好了
                    pboxDown.Visible = false;
                    pboxFile.Visible = true;
                    pboxFile.Location = pboxDown.Location;//换坐标
                    FilePath = Path.GetDirectoryName(path);
                }

            }
        }
        #endregion
        #region 验证方法
        /// <summary>
        /// 下载方法
        /// </summary>
        /// <param name="toFilePath"></param>
        /// <param name="fileUrl"></param>
        private void DownFile(string toFilePath, string fileUrl)
        {
            HttpDownloader.DownloadFile(fileUrl, toFilePath, (path) =>
            {
                if (!string.IsNullOrEmpty(path))
                {
                    HttpUtils.Instance.ShowTip("下载成功");
                }
            });
        }
        /// <summary>
        /// 文件是否存在
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        private bool IsFileExists(string name)
        {
            // 判断下载地址是否有这个文件
            string filePath = Applicate.LocalConfigData.RoomFileFolderPath + name;
            return File.Exists(filePath);
        }
        #endregion
        #region 参数传递
        /// <summary>
        /// 群文件传递
        /// </summary>
        /// <param name="url"></param>
        public void VidoShow(string LocationPath)
        {
            //LocationPath = url;
            isMessageObject = false;
            pboxColle.Visible = false;
            if (!isVideo)
            {
                VidoPlay(LocationPath);

            }
            isVideo = true;
        }
        /// <summary>
        /// 聊天框传递
        /// </summary>
        /// <param name="messageObjects"></param>
        public void VidoShowList(MessageObject message)
        {
            pboxColle.Visible = true;
            messageList = message;
            isMessageObject = true;
            if (!isVideo)
            {
                string filepath = message.content;
                string fileName = FileUtils.GetFileName(filepath);
                LocationPath = Applicate.LocalConfigData.VideoFolderPath + fileName;
                if (!File.Exists(LocationPath))
                {
                    //等待符
                    loding = new LodingUtils();
                    loding.parent = pboxVideo;
                    loding.size = pboxVideo.Size;
                    loding.start();
                    HttpDownloader.DownloadFile(filepath, LocationPath, (path) =>
                    {
                        if (!string.IsNullOrEmpty(path))
                        {
                            VidoPlay(LocationPath);
                            loding.stop();
                        }
                    });
                }
                //复制过去
                else
                {
                    //LocationPath = Applicate.LocalConfigData.AudioFolderPath + fileName;
                    //FileInfo fileInfo = new FileInfo(filepath);
                    VidoPlay(LocationPath);
                    //fileInfo.CopyTo(LocationPath, true);
                    //loding.stop();
                }
            }
            isVideo = true;
        }
        //播放的方法
        private void VidoPlay(string LocationPath)
        {
            tmrVideo.Enabled = true;
            //LocationPath = url;
            string pluginPath = Environment.CurrentDirectory + "\\plugins\\";  //插件目录
            player = new VlcPlayer(pluginPath);
            player.SetRenderWindow((int)pboxVideo.Handle);//panel
            player.LoadFile(LocationPath);//视频文件  
            player.Play();                     //视频长度
            int durationSecond = (int)this.player.Duration;
            string Min = durationSecond / 60 + "";
            if (Min.Length == 1)
            {
                Min = "0" + Min;
            }
            Seconds = durationSecond % 60;
            string secos = Seconds.ToString();
            if (secos.Length == 1)
            {
                secos = "0" + secos;
            }
            string endTime = Min + ":" + secos;
            //结束时间
            lblEndTime.Text = endTime;
            //最大值
            if (timer >= player.Duration)
            {
                timer = 0;
                musicBar1.Value = 0.0;
                //停止计时器
                pboxStar.Visible = false;
                pboxStop.Visible = true;
                pboxStop.Location = pboxStar.Location;
            }
        }
        #endregion
        #region 按钮功能
        //暂停
        private void pboStop_Click(object sender, EventArgs e)
        {
            musicBar1.Visible = true;
            pboxStar.Visible = true;
            pboxStop.Visible = false;
            player.Play();
            tmrVideo.Start();
            if (timer >= player.Duration)
            {
                timer = 0;
                player.Stop();
                musicBar1.Value = 0.0;
                tmrVideo.Stop();
                tmrVideo.Start();
                player.Play();
                tmrVideo_Tick(sender, e);
                pboxStar.Visible = true;
                pboxStop.Visible = false;
            }

        }
        //播放(快速的暂停跟继续导致进度条没有跟上，将计时器的频率值修改到100就可解决)
        private void pboxStar_Click(object sender, EventArgs e)
        {
            pboxStar.Visible = false;
            pboxStop.Visible = true;
            pboxStop.Location = pboxStar.Location;
            player.Pause();
            
            tmrVideo.Stop();

        }
        #endregion

        #region 进度条
        /// <summary>
        /// 播放进度条
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tmrVideo_Tick(object sender, EventArgs e)
        {
            timer += 0.1;
            if (timer >= player.Duration)
            {
                timer = player.Duration;
                musicBar1.Value =timer / player.Duration * 100;
                tmrVideo.Stop();
                pboxStar.Visible = false;
                pboxStop.Visible = true;
                pboxStop.Location = pboxStar.Location;
                musicBar1.Visible = false;
            }
            else
            {
               musicBar1.Value =timer / player.Duration *100;
            }
            
        }
        /// <summary>
        /// 拖动播放进度
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void musicBar1_MouseClick(object sender, MouseEventArgs e)
        {
            //当前值
            //player.Stop();
            // tmrVideo.Stop();


            //if (timer >= player.Duration)
            //{
            //    pboxStar.Visible = true;
            //    pboxStop.Visible = false;
            //    player.Play();
            //    tmrVideo.Start();
            //}

            double pos = e.X / (double)musicBar1.Width * musicBar1.MaxValue;
            musicBar1.Value = pos;
            double time = pos / musicBar1.MaxValue * player.Duration;
            timer = time;
            player.SetPlayTime(time);


          //  tmrVideo.Start();
            //tmrVideo.Start();
            //设置时间后进度条有更新，但是视频没有

        }
        #endregion
        
        #region 图标功能
        /// <summary>
        /// 声音
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxVoice_Click(object sender, EventArgs e)
        {
            if (player.GetVolume() > 0)
            {
                player.SetVolume(0);
                pboxSound.Image = Resources.mute;
            }
            else
            {
                player.SetVolume(100);
                pboxSound.Image = Resources.volume;

            }
        }
        /// <summary>
        /// 转发
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxZhuan_Click(object sender, EventArgs e)
        {
            string httpurl = "";
            string locapath = "";
            if (isMessageObject)
            {
                fileSize = messageList.fileSize;
                httpurl = messageList.content;
                string fileName = FileUtils.GetFileName(httpurl);
                LocationPath = Applicate.LocalConfigData.VideoFolderPath + fileName;
              
            }
            else
            {
                //群文件传过来的路径
                httpurl = LocationPath;
                locapath = FilePath;
            }
            //长度
            long size = fileSize;
            //开好友选择器
            //调用好友选择器
            var frmFriend = new FrmFriendSelect();
            //数据加载
            frmFriend.LoadFriendsData();
            frmFriend.AddConfrmListener((userLiser) =>
            {
                //添加
                foreach (var item in userLiser)
                {
                    //调研xmpp
                    MessageObject messImg = ShiKuManager.SendVideoMessage(item.Value, httpurl, locapath, size);
                    Messenger.Default.Send(messImg, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                }

            });
        }
        /// <summary>
        /// 收藏
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxColle_Click(object sender, EventArgs e)
        {
            if (isMessageObject)
            {
                CollectUtils.CollectMessage(messageList);
            }

        }
        /// <summary>
        /// 打开文件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxFile_Click_1(object sender, EventArgs e)
        {
            OpenFileDialog openFile = new OpenFileDialog();
            //打开跟目录
            openFile.InitialDirectory = FilePath;
            //名称
            openFile.Title = "请选择";
            if (openFile.ShowDialog() == DialogResult.OK)
            {
                //播放
                LocationPath = openFile.FileName;
                System.Diagnostics.Process.Start(LocationPath);
            }
        }
        /// <summary>
        /// 下载
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxDown_Click_1(object sender, EventArgs e)
        {
            string foldPath = "";
            //文件路径
            string filePath = "";
            if (isMessageObject)
            {
                filePath = LocationPath;
            }
            fileName = FileUtils.GetFileName(filePath);
            //选择框
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            dialog.Description = "请选择文件路径";
            //确认选择
            if (dialog.ShowDialog() == DialogResult.OK)
            {
                foldPath = dialog.SelectedPath + "\\" + fileName;
                //验证路径
                FileInfo file = new FileInfo(filePath);
                file.CopyTo(foldPath, true);
                HttpUtils.Instance.ShowTip("下载成功");
                //获去到更目录
                FilePath = Path.GetDirectoryName(foldPath);
                //保存路径
                LocalDataUtils.SetStringData(messageList.content, foldPath);
                //隐藏下载按钮
                pboxDown.Visible = false;
                pboxFile.Visible = true;
                pboxFile.Location = pboxDown.Location;//换坐标
            }
        }
        #endregion
        #region 图标提示功能
        //下载
        private void pboxDown_MouseEnter(object sender, EventArgs e)
        {
            string msg = "下载";
            toolTip1.SetToolTip(pboxDown, msg);

        }

        private void toolTip1_Draw_1(object sender, DrawToolTipEventArgs e)
        {

        }

        private void pboxZhuan_MouseEnter(object sender, EventArgs e)
        {
            string msg = "转发";
            toolTip1.SetToolTip(pboxZhuan, msg);
        }

        private void pboxFile_MouseEnter(object sender, EventArgs e)
        {
            string msg = "打开";
            toolTip1.SetToolTip(pboxFile, msg);
        }

        private void pboxColle_MouseEnter(object sender, EventArgs e)
        {
            string msg = "收藏";
            toolTip1.SetToolTip(pboxColle, msg);
        }
        #endregion
        #region 窗体关闭
        /// <summary>
        /// 窗体关闭
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrmVideoFlash_FormClosed(object sender, FormClosedEventArgs e)
        {
            frm.Dispose();
            //停止播放
            if (player!=null)
            {
                player.Stop();
            }
            Helpers.ClearMemory();
        }
        #endregion
        
    }
}
