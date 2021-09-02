using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Properties;

public class GroupAppendBuild
{

    //
    private List<string> mUrls;
    private int MaxCount;
    private Bitmap[] data;
    private int downCompteCount = 0; // 有几个图已经下载完成了
    private PictureBox mImageView;
    private Action<Bitmap> mCompte;
    private string token;

    public GroupAppendBuild(List<string> urls)
    {
        this.mUrls = urls;
        this.MaxCount = urls.Count;
        data = new Bitmap[MaxCount];
    }

    public GroupAppendBuild CompteListener(Action<Bitmap> compte) {

        mCompte = compte;
        return this;
    }

    public void DownCompt()
    {
        if (downCompteCount == MaxCount)
        {
            // 全部下载完成了
            int width = 45;
            if (mImageView!=null)
            {
                width = mImageView.Width;
            }
            Bitmap result = AppendGroupImage(data, width);


            if (mImageView !=null)
            {
                HttpUtils.Instance.Invoke(new Action(() => {
                    mImageView.BackgroundImage = result;
                    mImageView.Refresh();
                }));
        
            }

            //ImageCacheManager.Instance.PutImageCache(token, result);

            if (mCompte != null)
            {
                HttpUtils.Instance.Invoke(mCompte, result);
            }
            
        }
    }

    internal void Into(PictureBox view)
    {

        token = AppendIds(mUrls);

        Bitmap bitmap = ImageCacheManager.Instance.GetCacheImage(token);
        if (!BitmapUtils.IsNull(bitmap))
        {
            if (view!= null)
            {
                HttpUtils.Instance.Invoke(new Action(() => {
                    mImageView.BackgroundImage = bitmap;
                    mImageView.Refresh();
                }));
            }
           
            if (mCompte != null)
            {
                HttpUtils.Instance.Invoke(mCompte, bitmap);
            }
            return;
        }


        mImageView = view;
        for (int index = 0; index < mUrls.Count; index++)
        {
            ImageLoader.Instance.Load(mUrls[index]).Error(Resources.avatar_default)
                .Tag("" + index)
                .CompteListener((bit)=> {

                    int tag = Convert.ToInt32(bit.Tag);
 
                    downCompteCount++;
                    data[tag] = bit;
                    DownCompt();
                })
                .Into((bit, path) =>
               {
                   
               });
        }
    }

    private string AppendIds(List<string> mUrls)
    {
        StringBuilder stringBuilder = new StringBuilder();
        foreach (var item in mUrls)
        {
            stringBuilder.Append(item);
        }

        return stringBuilder.ToString();
    }

    private Bitmap AppendGroupImage(Bitmap[] data, int width = 40)
    {

        Bitmap bg = new Bitmap(width, width);
        Graphics graphics = Graphics.FromImage(bg);
        graphics.SmoothingMode = SmoothingMode.AntiAlias;

        Pen pen = new Pen(Color.White);
        pen.Width = width / 20f;

        int rotate = 360 / data.Length;
        int gap = Convert.ToInt32(pen.Width);
        int scale = Convert.ToInt32(width / ((data.Length - 2f) * 0.1f + 1.8f));
        for (int i = 0; i < data.Length; i++)
        {

            // 图像变圆
            Bitmap bmp = BitmapUtils.GetRoundImage(data[i]);
            // 缩放
            int rotate_image = 360 - (i * rotate);
            bmp = BitmapUtils.ChangeSize(bmp, scale, scale, rotate_image);

            // 绘制
            graphics.DrawImage(bmp, gap, gap);

            // 画变框
            graphics.DrawEllipse(pen, new Rectangle(gap, gap, scale, scale));

            //旋转角度和平移
            Matrix mtxRotate = graphics.Transform;
            mtxRotate.RotateAt(rotate, new PointF(width >> 1, width >> 1));
            graphics.Transform = mtxRotate;

        }
        graphics.Dispose();
        return bg;
    }
}