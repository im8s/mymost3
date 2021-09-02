using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using WinFrmTalk.Properties;

public class BitmapUtils
{

    public static bool IsNull(Image image)
    {

        if (image == null || image.PixelFormat == PixelFormat.DontCare || image.PixelFormat == PixelFormat.Undefined)
        {
            return true;
        }
        else
        {
            return false;
        }
    }


    internal static Bitmap GetRoundImage(Bitmap image, int size)
    {
        return GetRoundImage(image, size, size);
    }

    internal static Bitmap GetRoundImage(Bitmap image, int width, int height)
    {
        return ChangeSize(GetRoundImage(image), width, height);
    }

    internal static Bitmap GetRoundImage(Bitmap image)
    {
        Bitmap bm = new Bitmap(image.Width + 1, image.Height + 1);
        Graphics g = Graphics.FromImage(bm);

        GraphicsPath gpath = new GraphicsPath();
        gpath.AddEllipse(0, 0, image.Width, image.Height);

        g.SmoothingMode = SmoothingMode.AntiAlias;
        //g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        //g.CompositingQuality = CompositingQuality.HighQuality;

        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.CompositingQuality = CompositingQuality.HighQuality;

        g.SetClip(gpath);

        g.DrawImage(image, new Rectangle(0, 0, image.Width + 5, image.Height + 5), 0, 0, image.Width, image.Height, GraphicsUnit.Pixel);
        g.Dispose();

        return bm;
    }

    internal static Bitmap AppendGroupAvatar(Bitmap image, int role)
    {

        Bitmap frontImage = GetRoundImage(image);

        if (role > 2 || role == 0)
        {
            return frontImage;
        }

        Bitmap background = role == 1 ? Resources.frame_group_owner : Resources.frame_group_manager;
        int iwidth = background.Width > frontImage.Width ? background.Width : frontImage.Width;
        int iheight = background.Height > frontImage.Height ? background.Height : frontImage.Height;
        //按最大值修改气泡长宽
        ModifyWidthAndHeight(ref iwidth, ref iheight, 200, 200);
        background = ChangeSize(background, iwidth, iheight);
        //frontImage = ModifyBitmapSize(frontImage, 140, 160);
        Bitmap mixImage2 = new Bitmap(iwidth, iheight);
        Graphics g = Graphics.FromImage(mixImage2);
        g.DrawImage(frontImage, new Rectangle(3, 3, iwidth - 6, iheight - 6));
        g.DrawImage(background, new Rectangle(0, 0, iwidth, iheight));
        return mixImage2;
    }


    #region 修改图片的尺寸
    /// <summary>
    /// 修改图片的尺寸
    /// </summary>
    /// <param name="old_bitmap"></param>
    /// <param name="new_width"></param>
    /// <param name="new_height"></param>
    /// <returns></returns>
    internal static Bitmap ChangeSize(Bitmap old_bitmap, int new_width, int new_height)
    {
        Bitmap new_bitmap = new Bitmap(new_width, new_height);
        Graphics g = Graphics.FromImage(new_bitmap);
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.DrawImage(old_bitmap, new Rectangle(0, 0, new_width, new_height), new Rectangle(0, 0, old_bitmap.Width, old_bitmap.Height), GraphicsUnit.Pixel);
        g.Dispose();
        old_bitmap.Dispose();

        return new_bitmap;
    }
    #endregion

    #region 修改图片的尺寸
    /// <summary>
    /// 修改图片的尺寸
    /// </summary>
    /// <param name="old_bitmap"></param>
    /// <param name="new_width"></param>
    /// <param name="new_height"></param>
    /// <returns></returns>
    internal static Bitmap ChangeSize(Bitmap old_bitmap, int new_width, int new_height, float rotate)
    {
        Bitmap new_bitmap = new Bitmap(new_width, new_height);
        Graphics graphics = Graphics.FromImage(new_bitmap);
        graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;

        //旋转角度和平移
        Matrix mtxRotate = graphics.Transform;
        mtxRotate.RotateAt(rotate, new PointF(new_width >> 1, new_height >> 1));
        graphics.Transform = mtxRotate;

        graphics.DrawImage(old_bitmap, new Rectangle(0, 0, new_width, new_height), new Rectangle(0, 0, old_bitmap.Width, old_bitmap.Height), GraphicsUnit.Pixel);
        graphics.Dispose();

        return new_bitmap;
    }
    #endregion

    #region 按最大值修改长宽进行自适应
    /// <summary>
    /// 按最大值修改长宽进行自适应
    /// </summary>
    /// <param name="width"></param>
    /// <param name="height"></param>
    /// <param name="maxWidth"></param>
    /// <param name="maxHeight"></param>
    internal static void ModifyWidthAndHeight(ref int width, ref int height, int maxWidth, int maxHeight)
    {
        //暂时只考虑长宽最大值相同的情况
        if (maxWidth != maxHeight)
        {
            return;
        }
        //都没有超过最大值
        if (width <= maxWidth && height <= maxHeight)
        {
            return;
        }
        //只有宽度超过了最大值
        else if (width > maxWidth && height <= maxHeight)
        {
            height = Convert.ToInt32((decimal)maxWidth / (decimal)width * (decimal)height);
            width = maxWidth;
        }
        //只有高度超过了最大值
        else if (width <= maxWidth && height > maxHeight)
        {
            width = Convert.ToInt32((decimal)maxHeight / (decimal)height * (decimal)width);
            height = maxHeight;
        }
        //都超过了最大值
        else if (width > maxWidth && height > maxHeight)
        {
            if (width >= height)
            {
                height = Convert.ToInt32((decimal)maxWidth / (decimal)width * (decimal)height);
                width = maxWidth;
            }
            else
            {
                width = Convert.ToInt32((decimal)maxHeight / (decimal)height * (decimal)width);
                height = maxHeight;
            }
        }
    }
    #endregion


    #region 拼合红点图到 图片上
    public static Bitmap CombineRedPointToImg(Image foreImage, Image backImage)
    {

        Bitmap bitmap = new Bitmap(45, 45);
        Graphics g = Graphics.FromImage(bitmap);
        g.SmoothingMode = SmoothingMode.AntiAlias;
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.CompositingQuality = CompositingQuality.HighQuality;
        g.DrawImage(backImage, new Rectangle(0, 8, 35, 35), 0, 0, backImage.Width, backImage.Height, GraphicsUnit.Pixel);
        g.DrawImage(foreImage, new Rectangle(23, 0, foreImage.Width, foreImage.Height), 0, 0, foreImage.Width, foreImage.Height, GraphicsUnit.Pixel);

        return bitmap;
    }
    #endregion


    /// <summary>
    /// 无损压缩图片
    /// </summary>
    /// <param name="sFile">原图片地址</param>
    /// <param name="dFile">压缩后保存图片地址</param>
    /// <param name="flag">压缩质量（数字越小压缩率越高）1-100</param>
    /// <param name="size">压缩后图片的最大大小</param>
    /// <param name="sfsc">是否是第一次调用</param>
    /// <returns></returns>
    public static bool CompressImage(string sFile, string dFile, int flag = 90, int size = 20, bool sfsc = true)
    {
        Image iSource = Image.FromFile(sFile);
        ImageFormat tFormat = iSource.RawFormat;
        int dHeight = iSource.Height / 2;
        int dWidth = iSource.Width / 2;

        int sW = 0, sH = 0;
        //按比例缩放
        Size tem_size = new Size(iSource.Width, iSource.Height);
        if (tem_size.Width > dHeight || tem_size.Width > dWidth)
        {
            if ((tem_size.Width * dHeight) > (tem_size.Width * dWidth))
            {
                sW = dWidth;
                sH = (dWidth * tem_size.Height) / tem_size.Width;
            }
            else
            {
                sH = dHeight;
                sW = (tem_size.Width * dHeight) / tem_size.Height;
            }
        }
        else
        {
            sW = tem_size.Width;
            sH = tem_size.Height;
        }

        Bitmap ob = new Bitmap(dWidth, dHeight);
        Graphics g = Graphics.FromImage(ob);

        g.Clear(Color.WhiteSmoke);
        g.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighQuality;
        g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;

        g.DrawImage(iSource, new Rectangle((dWidth - sW) / 2, (dHeight - sH) / 2, sW, sH), 0, 0, iSource.Width, iSource.Height, GraphicsUnit.Pixel);

        g.Dispose();
        iSource.Dispose();
        //以下代码为保存图片时，设置压缩质量
        EncoderParameters ep = new EncoderParameters();
        long[] qy = new long[1];
        qy[0] = flag;//设置压缩的比例1-100
        EncoderParameter eParam = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, qy);
        ep.Param[0] = eParam;

        try
        {
            ImageCodecInfo[] arrayICI = ImageCodecInfo.GetImageEncoders();
            ImageCodecInfo jpegICIinfo = null;
            for (int x = 0; x < arrayICI.Length; x++)
            {
                if (arrayICI[x].FormatDescription.Equals("JPEG"))
                {
                    jpegICIinfo = arrayICI[x];
                    break;
                }
            }
            if (jpegICIinfo != null)
            {
                File.Delete(dFile);
                ob.Save(dFile, jpegICIinfo, ep);//dFile是压缩后的新路径
                FileInfo fi = new FileInfo(dFile);
                if (fi.Length > 1024 * size)
                {
                    flag = flag - 10;
                    CompressImage(sFile, dFile, flag, size, false);
                }
            }
            else
            {
                ob.Save(dFile, tFormat);
            }
            return true;
        }
        catch
        {
            return false;
        }
        finally
        {
            iSource.Dispose();
            ob.Dispose();
        }
    }

}