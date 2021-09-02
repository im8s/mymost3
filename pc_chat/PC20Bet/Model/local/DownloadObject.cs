using System;
using System.Windows.Forms;


/// <summary>
/// 文件类型
/// </summary>
public enum DownLoadFileType
{
    /// <summary>
    /// 图片类型
    /// </summary>
    Image,

    /// <summary>
    /// 下载字符串
    /// </summary>
    String,
}


/// <summary>
/// 下载状态
/// </summary>
public enum DownloadState
{
    /// <summary>
    /// 下载完成
    /// </summary>
    Successed,

    /// <summary>
    /// 下载错误
    /// </summary>
    Error
}


public class DownloadObject
{

    /// <summary>
    /// 回调控件(用于回调至主线程)
    /// </summary>
    public Control CallBackControl { get; set; }

    /// <summary>
    /// 用于文件验证
    /// </summary>
    public string Token { get; set; }

    /// <summary>
    /// 文件大小
    /// </summary>
    public int Size { get; set; }

    /// <summary>
    /// 错误信息
    /// </summary>
    public Exception Error { get; set; }

    /// <summary>
    /// 文件Uri
    /// </summary>
    public string Url { get; set; }

    /// <summary>
    /// Http参数
    /// </summary>
    public string HttpParas { get; set; } = "";

    /// <summary>
    /// Http下载类型
    /// </summary>
    public DownLoadFileType Type { get; set; }

    /// <summary>
    /// 请求状态
    /// </summary>
    public DownloadState State { get; set; }


    #region 追加Http参数
    /// <summary>
    /// 追加Http参数
    /// </summary>
    /// <param name="keyValue">使用键值对的方式获取</param>
    /// <returns>追加参数后的</returns>
    public DownloadObject AppendHttpParameter(string key, string value)
    {
        if (this.HttpParas.Length > 2)
        {
            this.HttpParas = this.HttpParas + "&";
        }
        if (string.IsNullOrEmpty(this.HttpParas))
        {
            this.HttpParas = this.HttpParas + "?";
        }
        this.HttpParas = this.HttpParas + key + "=" + value;
        return this;
    }
    #endregion

}


/// <summary>
/// 文件下载对象
/// </summary>
public class DownloadFile : DownloadObject
{

    /// <summary>
    /// 文件名称
    /// </summary>
    public string Name { get; set; }

    /// <summary>
    /// 用户Jid
    /// </summary>
    public string Jid { get; set; }

    /// <summary>
    /// 如果文件存在时是否先删除并重新下载
    /// </summary>
    public bool ShouldDeleteWhileFileExists { get; set; }


    /// <summary>
    /// 下载到本地的路径()绝对路径
    /// </summary>
    public string LocalUrl { get; internal set; }
    public byte[] ResultBytes { get; internal set; }
}


/// <summary>
/// 字符串下载对象
/// </summary>
public class DownloadString : DownloadObject
{

    /// <summary>
    /// 下载完成的文本
    /// </summary>
    public string ResultText { get; set; }



}

