using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Windows.Interop;
using System.Windows.Media.Imaging;
using System.IO;
using System.Drawing.Imaging;
using AForge.Video.DirectShow;


using AForge.Video.FFMPEG;
using System.Diagnostics;

namespace WinFrmTalk.View
{
    public partial class FrmTakeVideo : FrmBase
    {
        FilterInfoCollection videoDevices;
        /// <summary>
        /// 这个视频源类从本地视频捕获设备获取视频数据，
        /// 像USB网络摄像头(或内部)、帧抓取器、捕捉板——任何东西
        /// 支持DirectShow的接口。对于有快门按钮的设备
        /// 或者支持外部软件触发，类也允许做快照。
        /// 视频大小和快照大小都可以配置。
        /// </summary>
        //定义视频源抓取类
        VideoCaptureDevice videoSource;
        private VideoFileWriter VideoOutPut = new VideoFileWriter();
        //定义下标
        public int selectedDeviceIndex = 0;
        private static FrmTakeVideo instance = null;
        public Action<string> videoInfo;//录像保存的本地路径和时间
        String picName = "";
        bool is_record_video = false;
        int tick_num = 0;
        public static FrmTakeVideo GetInstance()
        {
            if (instance == null || instance.IsDisposed)
            {
                instance = new FrmTakeVideo();
            }
            if (instance != null)
            {
                instance.Activate();
            }
            return instance;
        }
        public FrmTakeVideo()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            btnstart.Parent = photo;
            btnstop.Parent = photo;
            btnstop.BackColor = Color.Transparent;
            btnstart.BackColor = Color.Transparent;
            btnpuse.Parent = photo;
            btnreturn.Parent = photo;
            btnsend.Parent = photo;
            btnsend.BackColor = Color.Transparent;
            btnpuse.BackColor = Color.Transparent;
            btnreturn.BackColor = Color.Transparent;
        }
        /// <summary>
        /// 获取是否有相机设备
        /// </summary>
        /// <returns></returns>
        public bool iscontentpoto()
        {
            bool iscontent = true;
            videoDevices = new FilterInfoCollection(FilterCategory.VideoInputDevice);

            if (videoDevices.Count == 0)
            {
                iscontent = false;
            }
            return iscontent;
        }


        public void ConnectPhoto()
        {
            //实例化过滤类
            //FilterCategory.VideoInputDevice视频输入设备类别。
            //  videoDevices = new FilterInfoCollection(FilterCategory.VideoInputDevice);

            if (!iscontentpoto())
            {
                return;
            }
            //实例化下标
            selectedDeviceIndex = 0;

            //设置回调,aforge会不断从这个回调推出图像数据
           
            //实例化视频源抓取类
            //videoDevices[selectedDeviceIndex].MonikerString   过滤器的名字的字符串。
            videoSource = new VideoCaptureDevice(videoDevices[selectedDeviceIndex].MonikerString);//连接摄像头
            //视频分辨设置
            //该属性允许设置一个支持的视频分辨率
            //相机。使用AForge.Video.DirectShow.VideoCaptureDevice.VideoCapabilities
            //属性以获得支持的视频分辨率列表。
            //在照相机开始生效之前必须设置好该属性。
            //属性的默认值设置为null，这意味着默认的视频分辨率
            //使用。
            videoSource.VideoResolution = videoSource.VideoCapabilities[selectedDeviceIndex];
            //把实例化好的videosource类赋值到photo控件的VideoSource属性
         
            photo.VideoSource = videoSource;
            //启动photo控件
            photo.Start();
            //这样就把摄像头的图像获取到了本地
          System.Threading.Thread.Sleep(2000);
            //  tmdengdai.Start();
            //   btnSheXiang.Enabled = false;
        }
        private Bitmap bmp = new Bitmap(1, 1);
        private Stopwatch stopWatch = new Stopwatch();
       
        private void VideoSource_NewFrame(object sender, AForge.Video.NewFrameEventArgs eventArgs)
        {
           if (is_record_video )
            {
                VideoOutPut.WriteVideoFrame(eventArgs.Frame);
                lock (bmp)
                {
                    //释放上一个缓存
                    bmp.Dispose();
                    //保存一份缓存
                    bmp = eventArgs.Frame.Clone() as Bitmap;
                }
            }
        }
        #region 开始录制视频
        /// <summary>
        /// 开始
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnstart_Click(object sender, EventArgs e)
        {
           
            if (photo.IsRunning)
            {
                timer_count.Start();
                btnstart.Visible = false;
                isshowbutton(btnstart.Visible);
                btnstop.Visible = true;
                btnpuse.Visible = true;
                btnreturn.Visible = false;
                is_record_video = true;
                timer_count.Enabled = true;
                lbltime.Text = "";
                lbltime.Visible = true;
            
                 picName = GetVideoPath() + "\\" +TimeUtils.CurrentTime().ToString() + ".avi";
                //设置为9的原因：如果低于这个值录制的视频会慢速，高于这个值会快速（快进）播放
                VideoOutPut.Open(picName, videoSource.VideoResolution.FrameSize.Width, videoSource.VideoResolution.FrameSize.Height,9, VideoCodec.MPEG4);
              
                videoSource.NewFrame += VideoSource_NewFrame;
            }
        }
        #endregion
        /// <summary>
        /// 获取路径
        /// </summary>
        /// <returns></returns>
        private string GetVideoPath()
        {
            string personImgPath = Path.GetDirectoryName(AppDomain.CurrentDomain.BaseDirectory)
                         + Path.DirectorySeparatorChar.ToString() + "PersonImg";
            if (!Directory.Exists(personImgPath))
            {
                Directory.CreateDirectory(personImgPath);
            }

            return personImgPath;
        }
        /// <summary>
        /// 计时器计时并转换时间
        /// </summary>
        /// <param name="source"></param>
        /// <param name="e"></param>

        public void tick_count(object source, System.Timers.ElapsedEventArgs e)
        {
            tick_num++;
            int temp = tick_num;

            int sec = temp % 60;

            int min = temp / 60;
            if (60 == min)
            {
                min = 0;
                min++;
            }

            int hour = min / 60;

            String tick = hour.ToString() + "：" + min.ToString() + "：" + sec.ToString();
            this.lbltime.Text = tick;
        }
        #region 结束录制，暂停与继续
        /// <summary>
        /// 结束录制
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnstop_Click(object sender, EventArgs e)
        {
            videoSource.NewFrame -= VideoSource_NewFrame;
            // videoSource.Stop();
            timer_count.Enabled = false; ;
            lbltime.Visible = false;
            is_record_video = false;
            tick_num = 0;
            //关闭录像文件,如果忘了不关闭,将会得到一个损坏的文件,无法播放
            VideoOutPut.Close();
            btnstart.Visible = true;
            btnreturn.Visible = true;
            btnpuse.Visible = false;
            btnsend.Visible = true;
          
            //停止之后
        }
        /// <summary>
        /// 暂停与继续
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnpuse_Click(object sender, EventArgs e)
        {
            
            if (this.btnpuse.Tag.ToString()== "暂停")
            {

             //   stopWatch.Stop();
                this.lbltime.Visible = true;
                this.btnpuse.Tag = "继续";
                is_record_video = false;
                this.btnpuse.BackgroundImage = global::WinFrmTalk.Properties.Resources.videoContinue;
                //改变背景图片
               
                timer_count.Enabled = false;  //暂停计时
                return;
            }
            if (this.btnpuse.Tag.ToString() == "继续")
            {
                // stopWatch.Start();

                timer_count.Enabled = true;

                is_record_video = true;

                this.lbltime.Visible = true;
                this.btnpuse.BackgroundImage = global::WinFrmTalk.Properties.Resources.videoSpuse;
                this.btnpuse.Tag = "暂停";
            }
        }
        #endregion
        /// <summary>
        /// 返回按钮上文字的显示
        /// </summary>
        /// <param name="isshow"></param>
        private void isshowbutton(bool isshow)
        {
            if (isshow)
            {

                btnreturn.Tag= "返回";
            }
            else
            {

                btnreturn.Tag = "返回相机";
            }
        }
        /// <summary>
        /// 返回1.返回主界面2.退出功能
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnreturn_Click(object sender, EventArgs e)
        {
            if(btnreturn.Tag .ToString()== "返回")
            {
                this.Close();
            }
            if(btnreturn.Tag.ToString() == "返回相机")
            {
                if (File.Exists(picName))
                {
                    File.Delete(picName);
                }
            }
        }
        /// <summary>
        /// 关闭窗体释放资源
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrmTakeVideo_FormClosed(object sender, FormClosedEventArgs e)
        {
            videoSource.NewFrame -= VideoSource_NewFrame;
            photo.Stop();
            videoSource.Stop();
           
        }
        System.Timers.Timer timer_count = new System.Timers.Timer();

       /// <summary>
       /// 窗体加载
       /// </summary>
       /// <param name="sender"></param>
       /// <param name="e"></param>
        private void FrmTakeVideo_Load(object sender, EventArgs e)
        {
            timer_count.Elapsed += new System.Timers.ElapsedEventHandler(tick_count);  //到达时间的时候执行事件；
           timer_count.AutoReset = true;  //设置是执行一次（false）还是一直执行(true)；
          timer_count.Interval = 1000;
        }
        /// <summary>
        /// 发送
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnsend_Click(object sender, EventArgs e)
        {
            isshowbutton(btnstart.Visible);
            videoInfo?.Invoke(picName);//本地路径和时间
            this.Close();
        }
    }
}
