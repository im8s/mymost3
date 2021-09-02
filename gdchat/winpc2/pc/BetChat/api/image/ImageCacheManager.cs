using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using WinFrmTalk;

public class ImageCacheManager
{

    private ImageCacheManager() {
        images = new Dictionary<int, Bitmap>();
    }
    private static ImageCacheManager _instance;
    public static ImageCacheManager Instance => _instance ?? (_instance = new ImageCacheManager());


    private int maxCount = 40;
    private Dictionary<int, Bitmap> images;

    public void SetMaxCount(int max) {
        maxCount = max;
    }

    public Bitmap GetCacheImage(string url)
    {
        int hashCode = url.GetHashCode();

        if (images.ContainsKey(hashCode))
        {
            if (FileUtils.IsRecycled(images[hashCode]))
            {
                images.Remove(hashCode);
                return null;
            }
            else
            {
                return images[hashCode];
            }
        }

        return null;
    }

    public void PutImageCache(string url, Bitmap image)
    {
        if (BitmapUtils.IsNull(image))
        {
           LogUtils.Log("图片出错");
            return;
        }

        // 如果内存要满了就去清除一半内存
        if (images.Count > maxCount * 0.8)
        {
            int max = (int)(images.Count * 0.5f);
            int currt = 0;
            while (currt < max)
            {
                int pos = new Random().Next(images.Count);
                int key = images.Keys.ElementAt(pos);
                images.Remove(key);
                currt++;
            }
        }

        int hashCode = url.GetHashCode();

        if (!images.ContainsKey(hashCode))
        {
            images.Add(hashCode, image);
        }
        
    }


    public void ClearImageCache(string url)
    {
        try
        {
            int hashCode = url.GetHashCode();

            if (images.ContainsKey(hashCode))
            {
                images.Remove(hashCode);
            }

            string fileName = FileUtils.GetFileName(url);
            string filePath = Applicate.LocalConfigData.ImageFolderPath + fileName;
            if (File.Exists(filePath))
            {
                //如果对应文件存在 删除文件
                File.Delete(filePath);
            }
        }
        catch (Exception)
        {
        }

       
    }
}
