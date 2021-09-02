using AForge.Video.DirectShow;
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
using System.Threading.Tasks;

namespace WinFrmTalk.View
{
    public partial class FrmTakePhoto : FrmBase
    {
        string picName = "";//照片名称
        public Action<Image,string> takeimage;
        /// <summary>
        /// 单例对象
        /// </summary>
        private static FrmTakePhoto instance = null;
        public FrmTakePhoto()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            
            btnsurue.Parent = photo;
            btnreturntophoto.Parent = photo;
            btnsave.Parent = picimage;
            btnsurue.BackColor = Color.Transparent;
            btnreturntophoto.BackColor = Color.Transparent;
            btnsave.BackColor = Color.Transparent;
        }
        ///是否需要创建单例模式，这样的好处与作用
        /// <summary>
        /// 单例获取
        /// </summary>
        /// <returns></returns>
        public static FrmTakePhoto GetInstance()
        {
            //if (instance == null)
            //{
            //    instance = new FrmTakePhoto();
            //}
            //return instance;
            if (instance == null || instance.IsDisposed)
            {
                instance = new FrmTakePhoto();
            }
            if (instance != null)
            {
                instance.Activate();
            }
            return instance;
        }

        /// <summary>
        /// 类别的一个列表看到AForge.Video.DirectShow.FilterCategory。
        ///样本用法:
        ///列举videoDevices =新FilterInfoCollection(FilterCategory.VideoInputDevice视频设备);
        ///列出设备(视频设备中的FilterInfo设备)
        /// </summary>
        //定义收集过滤器信息的对象
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
       // private VideoFileWriter VideoOutPut = new VideoFileWriter();
        //定义下标
        public int selectedDeviceIndex = 0;


        /// <summary>
        /// 1.在窗体加载显示出来进行设备判断
        /// 2.界面打开就已经连接获得到设备
        /// 3.控制按钮的显示和隐藏
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrmTakePhoto_Load(object sender, EventArgs e)
        {

        }
        /// <summary>
        /// 获取是否有相机设备
        /// </summary>
        /// <returns></returns>
        public  bool iscontentpoto()
        {
            bool iscontent = true;
            videoDevices = new FilterInfoCollection(FilterCategory.VideoInputDevice);

            if (videoDevices.Count == 0)
            {
                iscontent = false;
            }
            return iscontent;
        }
        

        /// <summary>
        /// 连接相机
        /// </summary>
       public void ConnectPhoto()
        {
            //实例化过滤类
            //FilterCategory.VideoInputDevice视频输入设备类别。
          //  videoDevices = new FilterInfoCollection(FilterCategory.VideoInputDevice);

            if(!iscontentpoto())
            {
                return;
            }
            //实例化下标
            selectedDeviceIndex = 0;

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
          
          //  tmdengdai.Start();
         //   btnSheXiang.Enabled = false;
        }
        /// <summary>
        ///拍照
        ///1.拍好的照片也应该在设备窗口显示
        ///2.并且有一个保存和返回按钮
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnsurue_Click(object sender, EventArgs e)
        {
            try
            {
                if (photo.IsRunning)
                {
                    //   BitmapSource bitmapSource = Imaging.CreateBitmapSourceFromHBitmap(
                    //                   photo.GetCurrentVideoFrame().GetHbitmap(),
                    //                   IntPtr.Zero,
                    //                    System.Windows.Int32Rect.Empty,
                    //                   BitmapSizeOptions.FromEmptyOptions());
                    //   PngBitmapEncoder pE = new PngBitmapEncoder();
                    //   pE.Frames.Add(BitmapFrame.Create(bitmapSource));

                    ////   btnreturntophoto.Visible = true;
                    Bitmap bitmap = photo.GetCurrentVideoFrame();
                    photo.Visible = false;
                    picimage.Visible = true;
                    picName = GetImagePath() + "\\" + "myphoto"+TimeUtils.CurrentTime().ToString() + ".jpg";
                    picimage.BackgroundImage = bitmap;
                  //  picimage.ImageLocation = picName;
                    
                   
                    isshowbutton(picimage.Visible);
                    btnreturntophoto.Tag = "返回相机";
                    btnsave.Visible = true;
                    
                    //if (File.Exists(picName))
                    //{
                    //    File.Delete(picName);
                    //}
                    //using (Stream stream = File.Create(picName))
                    //{
                    //    pE.Save(stream);
                    //}
                    ////拍照完成后关摄像头并刷新同时关窗体
                    //if (photo != null && photo.IsRunning)
                    //{
                    //    photo.SignalToStop();
                    //    photo.WaitForStop();

                    //}

                    //  this.Close();
                }
            }
            catch (Exception ex)
            {
                ShowPromptBox("摄像头异常"+ ex.Message);
              //  MessageBox.Show("摄像头异常：" + ex.Message);
            }
        }
        //获取路径
        private string GetImagePath()
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
        /// 返回按钮，返回拍照和关闭窗体
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnreturntophoto_Click(object sender, EventArgs e)
        {
            if(btnreturntophoto.Tag.ToString()== "关闭")
            {
                this.Close();
            }
            else
            {
                picimage.Visible = false;
                isshowbutton(picimage.Visible);
                photo.Visible = true;
                
            }
           
        }
        /// <summary>
        /// 保存图片
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnsave_Click(object sender, EventArgs e)
        {
            Bitmap bitmap = new Bitmap(picimage.BackgroundImage);
            //定义图片路径
         
            //创建图片
            bitmap.Save(picName, ImageFormat.Jpeg);//只是将图片保存在固定位置
            HttpUtils.Instance.ShowTip("图片保存至："+picName);
            Task.Factory.StartNew(() =>
            {
                takeimage?.Invoke(bitmap, picName);
            });
            btnsave.Visible = false;
            this.Close();
        }
        
        private void isshowbutton( bool  isshow)
        {
            if (isshow)
            {
                
                btnreturntophoto.Visible = true;
                btnreturntophoto.Parent = picimage;
                btnreturntophoto.BackColor = Color.Transparent;
            }
            else
            {
                btnreturntophoto.Parent = photo;
                btnreturntophoto.Tag = "关闭";
            }
        }

        private void FrmTakePhoto_FormClosed(object sender, FormClosedEventArgs e)
        {
            videoSource.Stop();
            photo.Stop();
        }
    }
}
