using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk;

public class ImageRequstBuild
{
    private ImageLoadConfig mConfig;
    private string mLoadUrl;
    private PictureBox mImageView;
    private bool isBackground;
    private bool isRefresh;


    public ImageRequstBuild(ImageLoadConfig con)
    {
        ImageLoadConfig config = con.Copy();
        this.mConfig = config;
    }

    internal void LoadUrl(string url)
    {
        mLoadUrl = url;
    }

    public ImageRequstBuild Refresh()
    {
        isRefresh = true;
        return this;
    }


    internal void Execute()
    {

        if (string.IsNullOrEmpty(mLoadUrl))
        {
            LogUtils.Log("下载地址为空");
            ToView(null, null);
            return;
        }


        if (isRefresh)
        {
            ImageCacheManager.Instance.ClearImageCache(mLoadUrl);
        }


        if (!mConfig.noReadCache)
        {
            // 从内存加载
            Bitmap bitmap = ImageCacheManager.Instance.GetCacheImage(mLoadUrl);
            if (bitmap != null)
            {

                string path = Applicate.LocalConfigData.ImageFolderPath + FileUtils.GetFileName(mLoadUrl);
                ToView(bitmap, path);

                return;
            }

            // 从本地加载
            string fileName = FileUtils.GetFileName(mLoadUrl);
            string filePath = Applicate.LocalConfigData.ImageFolderPath + fileName;
            bitmap = FileUtils.FileToBitmap(filePath);
            if (bitmap != null)
            {
                // 保存到内存
                if (mConfig.isCache)
                {
                    ImageCacheManager.Instance.PutImageCache(mLoadUrl, bitmap);
                }

                ToView(bitmap, filePath);

                return;
            }
        }


        if (IsFIlePath(mLoadUrl)) // 一个本地路径文件，直接从本地获取
        {
            Bitmap bitmap = FileUtils.FileToBitmap(mLoadUrl);
            if (bitmap != null)
            {
                // 保存到内存
                if (mConfig.isCache)
                {
                    ImageCacheManager.Instance.PutImageCache(mLoadUrl, bitmap);
                }

                ToView(bitmap, mLoadUrl);
            }
            else
            {
                ToView(null, null);
            }

        }
        else
        {

            if (mConfig.bitLoading != null && mImageView != null)
            {
                SetImage(mConfig.bitLoading);
            }

            // 从本地加载
            string fileName = FileUtils.GetFileName(mLoadUrl);
            string filePath = Applicate.LocalConfigData.ImageFolderPath + fileName;
            // 最后从网络加载 保存到本地 => 保存到内存 
            HttpDownloader.DownloadFile(mLoadUrl, filePath, (down) =>
            {
                if (!string.IsNullOrEmpty(down) && File.Exists(down))
                {
                    //Console.WriteLine("从网络中取到的图片");

                    Bitmap image = FileUtils.FileToBitmap(down);

                    ToView(image, down);

                    // 保存到内存
                    if (mConfig.isCache)
                    {
                        ImageCacheManager.Instance.PutImageCache(mLoadUrl, image);
                    }
                    //else
                    //{
                    //    FileUtils.DeleteFile(down);
                    //}

                }
                else
                {
                    if (mConfig.isAvatar)
                    {
                        ImageCacheManager.Instance.PutImageCache(mLoadUrl, mConfig.bitErr);
                    }

                    LogUtils.Log("下载失败：" + filePath);
                    ToView(null, null);
                }

            });
        }
    }



    internal void Into(PictureBox view)
    {
        mImageView = view;
        Execute();
    }

    internal void Into(Action<Bitmap, string> action)
    {
        mConfig.onResponse = action;
        Execute();
    }

    internal ImageRequstBuild Error(Bitmap bitmap)
    {
        mConfig.bitErr = bitmap;
        return this;
    }
    internal ImageRequstBuild Avatar()
    {
        mConfig.isAvatar = true;
        return this;
    }

    internal ImageRequstBuild Tag(string mark)
    {
        mConfig.tag = mark;
        return this;
    }

    internal ImageRequstBuild Error(Action<string> errAction)
    {
        mConfig.onError = errAction;
        return this;
    }

    internal ImageRequstBuild Loading(Bitmap bitmap)
    {
        mConfig.bitLoading = bitmap;
        return this;
    }

    internal ImageRequstBuild NoCache()
    {
        mConfig.isCache = false;
        return this;
    }

    internal ImageRequstBuild NoReadCache()
    {
        mConfig.noReadCache = true;
        return this;
    }

    internal ImageRequstBuild CompteListener(Action<Bitmap> action)
    {
        mConfig.OnCompte = action;
        return this;
    }

    internal ImageRequstBuild Background()
    {
        isBackground = true;
        return this;
    }

    private bool IsFIlePath(string url)
    {
        return File.Exists(url);
    }

    private void ToView(Bitmap bitmap, string path)
    {
        if (BitmapUtils.IsNull(bitmap))
        {


            // 下载出错情况
            SetImage(mConfig.bitErr);

            mConfig.onError?.Invoke("下载出错");
        }
        else
        {
            // 下载成功
            SetImage(bitmap, path);

            mConfig.onResponse?.Invoke(bitmap, path);
        }


    }


    public void SetImage(Bitmap bitmap, string path ="")
    {

        if (bitmap == null)
        {
            return;
        }

        if (mConfig.isAvatar)
        {
            bitmap = BitmapUtils.GetRoundImage(bitmap);
            if (mImageView!=null)
            {
                bitmap = BitmapUtils.ChangeSize(bitmap, mImageView.Width, mImageView.Width);
            }
            
        }

        OnCompte(bitmap);

        if (mImageView != null)
        {
            if (isBackground)
            {
                //HttpUtils.Instance.Invoke(new Action(()=> {
                //    mImageView.BackgroundImage = bitmap;
                //}));
                // mImageView.BackgroundImage = bitmap;
                if (!UIUtils.IsNull(path) && bitmap.RawFormat.Equals(ImageFormat.Gif))
                {
                    FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
                    Image img = Image.FromStream(fs);
                    mImageView.BackgroundImage = img;
                }
                else
                {
                    mImageView.BackgroundImage = bitmap;
                }
                
            }
            else
            {
                //HttpUtils.Instance.Invoke(new Action(() => {
                //    mImageView.Image = bitmap;
                //}));
                if (!UIUtils.IsNull(path) && bitmap.RawFormat.Equals(ImageFormat.Gif))
                {
                    FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
                    Image img = Image.FromStream(fs);
                    mImageView.Image = img;
                }
                else
                {
                    mImageView.Image = bitmap;
                }

                //mImageView.Image = bitmap;
            }
        }

    }


    private void OnCompte(Bitmap bitmap)
    {
        bitmap.Tag = mConfig.tag;
        mConfig.OnCompte?.Invoke(bitmap);

    }
}