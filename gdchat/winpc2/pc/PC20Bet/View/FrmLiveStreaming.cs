using System;
using System.Drawing;
using System.Windows.Forms;
using System.IO;
using AForge.Video.DirectShow;
using AForge.Video.FFMPEG;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;

namespace WinFrmTalk.View
{
    public partial class FrmLiveStreaming : FrmBase
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
        private static FrmLiveStreaming instance = null;
        public Action<string> videoInfo;
        //录像保存的本地路径和时间
        private int videoWidth = 0, videoHeight = 0;

        private void FrmLiveStreaming_Load(object sender, EventArgs e)
        {

            string video_name = videoDevices[0].Name;
            string audio_name = "麦克风 (HD Webcam C270)";
            string rtmp_server = @"rtmp://meet.youjob.co:1935/live/10008295_1565162694";
            string cmd_content = string.Format(".\\ffmpeg -r 25 -f dshow -s {0}x{1} -i video=\"{2}\":audio=\"{3}\" -vcodec libx264 -b 800k -acodec aac -ab 128k -f flv -y {4}",
                videoWidth, videoHeight, video_name, audio_name, rtmp_server);
            ConsoleCmd(cmd_content);
        }

        public static FrmLiveStreaming GetInstance()
        {
            if (instance == null || instance.IsDisposed)
            {
                instance = new FrmLiveStreaming();
            }
            if (instance != null)
            {
                instance.Activate();
            }
            return instance;
        }
        public FrmLiveStreaming()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
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
            //报错摄像头的帧宽高
            videoWidth = videoSource.VideoResolution.FrameSize.Width;
            videoHeight = videoSource.VideoResolution.FrameSize.Height;
            //把实例化好的videosource类赋值到photo控件的VideoSource属性
            photo.VideoSource = videoSource;
            //启动photo控件
            photo.Start();
            //这样就把摄像头的图像获取到了本地
            System.Threading.Thread.Sleep(2000);
            //  tmdengdai.Start();
            //   btnSheXiang.Enabled = false;
        }

        private Bitmap bmp = new Bitmap(1, 1);      //每帧
        private void VideoSource_NewFrame(object sender, AForge.Video.NewFrameEventArgs eventArgs)
        {
            if (VideoOutPut.IsOpen)
            {
                try
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
                catch (Exception ex)
                {
                    LogHelper.log.Error("--------添加帧出错\r\n", ex);
                }
            }
        }

        /// <summary>
        /// 关闭窗体释放资源
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrmLiveStreaming_FormClosed(object sender, FormClosedEventArgs e)
        {
            videoSource.NewFrame -= VideoSource_NewFrame;
            photo.Stop();
            videoSource.Stop();
        }


        private void ConsoleCmd(string content)
        {
            try
            {
                Process process = new Process();
                process.StartInfo.FileName = "cmd.exe";
                process.StartInfo.UseShellExecute = false;
                process.StartInfo.CreateNoWindow = true;
                process.StartInfo.RedirectStandardOutput = true;
                process.StartInfo.RedirectStandardInput = true;
                process.Start();
                process.StandardInput.WriteLine("cd " + Application.StartupPath);
                process.StandardInput.WriteLine(content);
                process.StandardInput.AutoFlush = true;
                //process.WaitForInputIdle();

                //退出CMD
                //process.StandardInput.WriteLine("exit");
                ////process.WaitForExit(5000);
                ////process.WaitForExit();
                //process.Close();
            }
            catch (Exception ex)
            {
                LogHelper.log.Error("--------直播输入CMD出错，content: " + content + "\r\n", ex);
            }
        }
    }
}
