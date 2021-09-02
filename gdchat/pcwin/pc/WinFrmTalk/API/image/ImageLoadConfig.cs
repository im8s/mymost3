using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;


public class ImageLoadConfig
{
    public Bitmap bitErr; // 全局的加载错误处理
    public Bitmap bitLoading; // 全局的加载中处理
    public Action<Bitmap,string> onResponse; // 加载成功的回调
    public Action<string> onError; // 加载失败的回调
    public Action<Bitmap> OnCompte; // 加载完成
    
    public bool isCache = true;
    public string tag  ;
    public bool noReadCache; // 不读缓存，直接从网页加载

    internal ImageLoadConfig Copy()
    {
        ImageLoadConfig config = new ImageLoadConfig();
        config.bitErr = this.bitErr;
        config.bitLoading = this.bitLoading;
        config.onResponse = this.onResponse;
        config.onError = this.onError;
        config.isCache = this.isCache;
        config.noReadCache = this.noReadCache;

        return config;
    }

    public int maxCount = 80;
    public bool isAvatar;// 是否头像
}
