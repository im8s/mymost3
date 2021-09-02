using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk;
using WinFrmTalk.Properties;

/// <summary>
/// 视频缩略图加载器
/// </summary>
public class ThubImageLoader
{
    // 单例模式 
    private ThubImageLoader()
    {
    }

    private static ThubImageLoader _instance;
    public static ThubImageLoader Instance => _instance ?? (_instance = new ThubImageLoader());

    public void Load(string videoUrl, PictureBox picture, Action<bool, int, int> action = null)
    {

        if (picture == null || string.IsNullOrEmpty(videoUrl))
        {
            return;

        }


        // 判断视频是否存在
        string thubImagePath = Applicate.LocalConfigData.TempFilepath + FileUtils.ReplaceSuffix(FileUtils.GetFileName(videoUrl), ".jpg");      //保存的缩略图路径

        // 判断视频缩略图是否存在
        if (File.Exists(thubImagePath))
        {
            Bitmap bit = ToImageByView(thubImagePath, picture);
            if (!BitmapUtils.IsNull(bit))
                action?.Invoke(true, bit.Width, bit.Height);
            return;
        }


        string defPath = Environment.CurrentDirectory + "\\Resources\\ic_black_rect.png";
        ToImageByView(defPath, picture);

        ////避免因为cmd导致界面卡死
        Task.Factory.StartNew(() =>
        {
            //生成缩略图
            string ffmpegPath = Environment.CurrentDirectory + @"\ffmpeg.exe";
            int? width, height;

            FileUtils.GetMovWidthAndHeight(ffmpegPath, videoUrl, out width, out height);

            if (width == null || width == 0)
            {
                // 出错了， 说明视频地址不正确

            }
            else
            {
                string size = width + "x" + height;

                string cmd = GenerateVideo2ImageCmd(ffmpegPath, videoUrl, size, thubImagePath);

                bool success = FileUtils.Cmd(cmd);

                HttpUtils.Instance.Invoke(new Action(() =>
                {
                    ToImageByView(thubImagePath, picture);
                    action?.Invoke(true, width.Value, height.Value);
                }));
            }


            Console.WriteLine("获取成功" + thubImagePath);
        });

    }



    public void Load(string videoUrl, PictureBox picture, Action<int> action = null)
    {
        if (picture == null || string.IsNullOrEmpty(videoUrl))
        {
            return;
        }

        // 判断视频是否存在
        string thubImagePath = Applicate.LocalConfigData.TempFilepath + FileUtils.ReplaceSuffix(FileUtils.GetFileName(videoUrl), ".jpg");      //保存的缩略图路径

        // 判断视频缩略图是否存在
        if (File.Exists(thubImagePath))
        {
            ToImageByView(thubImagePath, picture);
            action?.Invoke(1);
            return;
        }


        string defPath = Environment.CurrentDirectory + "\\Resources\\ic_black_rect.png";
        ToImageByView(defPath, picture);

        ////避免因为cmd导致界面卡死
        Task.Factory.StartNew(() =>
        {
            //生成缩略图
            string ffmpegPath = Environment.CurrentDirectory + @"\ffmpeg.exe";
            int? width, height;

            FileUtils.GetMovWidthAndHeight(ffmpegPath, videoUrl, out width, out height);

            if (width == null || width == 0)
            {
                // 出错了， 说明视频地址不正确

            }
            else
            {
                string size = width + "x" + height;

                string cmd = GenerateVideo2ImageCmd(ffmpegPath, videoUrl, size, thubImagePath);

                bool success = FileUtils.Cmd(cmd);

                HttpUtils.Instance.Invoke(new Action(() =>
                {
                    ToImageByView(thubImagePath, picture);
                    action?.Invoke(1);
                }));
            }

            Console.WriteLine("width : " + width);
            Console.WriteLine("height : " + height);
            //string command = string.Format("\"{0}\" -i \"{1}\" -ss {2} -vframes 1 -r 1 -ac 1 -ab 2 -s {3}*{4} -f image2 \"{5}\"", ffmpegPath, oriVideoPath, frameIndex, width, height, thubImagePath);


            Console.WriteLine("获取成功" + thubImagePath);
        });


        //// 先放一张默认图上去
        //string defPath = Environment.CurrentDirectory + "\\Resources\\ic_black_rect.png";
        //ToImageByView(defPath, picture);


        //// 判断url是否是视频 是否存在
        //if (File.Exists(videoUrl))
        //{
        //    // 视频转缩略图
        //    FileUtils.GetVideoThubImage(videoUrl, thubImagePath, (bit) =>
        //    {
        //        //加载图片并添加播放图标
        //        ToImageByView(thubImagePath, picture);
        //        action?.Invoke(1);
        //    });

        //    return;
        //}

        //// 判断视频是否存在本地
        //string savePaht = Applicate.LocalConfigData.AudioFolderPath + FileUtils.GetFileName(videoUrl);
        //if (File.Exists(savePaht))
        //{
        //    // 视频转缩略图
        //    FileUtils.GetVideoThubImage(videoUrl, thubImagePath, (bit) =>
        //    {
        //        //加载图片并添加播放图标
        //        ToImageByView(thubImagePath, picture);
        //        action?.Invoke(1);
        //    });

        //    return;
        //}


        //// 去下载视频
        //HttpDownloader.DownloadFile(videoUrl, savePaht, (path) =>
        //{
        //    // 下载成功
        //    if (savePaht.Equals(path))
        //    {
        //        // 视频转缩略图
        //        FileUtils.GetVideoThubImage(path, thubImagePath, (bit) =>
        //        {
        //            //加载图片并添加播放图标
        //            ToImageByView(thubImagePath, picture);
        //            action?.Invoke(1);
        //        });
        //    }
        //});

    }


    private Bitmap ToImageByView(string thubImagePath, PictureBox picture)
    {
        Bitmap bitmap = null;// ImageCacheManager.Instance.GetCacheImage(thubImagePath);
        if (bitmap != null)
        {
            picture.BackgroundImage = bitmap;
            picture.BackgroundImageLayout = ImageLayout.Stretch;
            picture.Cursor = Cursors.Hand;
        }
        else
        {
            bitmap = EQControlManager.getMixImage(0.80F, Resources.jc_play_normal, thubImagePath);
            picture.BackgroundImage = bitmap;
            picture.BackgroundImageLayout = ImageLayout.Stretch;
            picture.Cursor = Cursors.Hand;
            // ImageCacheManager.Instance.PutImageCache(thubImagePath, bitmap);
        }
        return bitmap;
    }


    public string GenerateVideo2ImageCmd(string ffmpegPath, string videoUrl, string size, string outImagePaht)
    {
        //string cmd = ffmpegPath + " -i " + videoUrl + " -y -f mjpeg -ss 3 -t 0.001 -s " + size + " " + thubImagePath;
        // 有些路劲获取不了：http://47.91.232.3:8089/u/7332/10017332/201910/c03d35f0ff694cbb8acdc82e6bbb74a8.mp4
        //string cmd = ffmpegPath + " -i " + videoUrl + " -y -f mjpeg -ss 3 -t 0.02 -s " + size + " " + thubImagePath;
        string cmd = ffmpegPath + " -i " + videoUrl + " -y -f image2 -ss 0.1 -t 0.02 -s " + size + " " + outImagePaht;
        return cmd;
    }
}
