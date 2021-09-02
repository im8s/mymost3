using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk;

public static class HttpDownloader
{


    internal static void DownloadFile(string url, string path, Action<string> action)
    {
        if (string.IsNullOrEmpty(url) || string.IsNullOrEmpty(path))
        {
            action(null);
        }

        Task.Factory.StartNew(() =>
        {
            try
            {
                //如果对应文件存在 先删除文件(再下载文件)
                FileUtils.DeleteFile(path);

                HttpItem httpitem = new HttpItem()
                {
                    URL = url,
                    ResultType = ResultType.Byte
                };
                var result = new HTTP().GetHtml(httpitem);

                if (result.StatusCode == System.Net.HttpStatusCode.OK)//服务器返回正常才处理字节
                {
                    if(!File.Exists(path))
                    {
                        //创建一个文件流
                        FileStream fs = new FileStream(path, FileMode.Create);
                        if (result.ResultByte != null)
                        {
                            //将byte数组写入文件中
                            fs.Write(result.ResultByte, 0, result.ResultByte.Length);
                            //所有流类型都要关闭流，否则会出现内存泄露问题
                            fs.Close();
                            fs.Dispose();
                            HttpUtils.Instance.Invoke(action, path);

                        }
                        else
                        {   //所有流类型都要关闭流，否则会出现内存泄露问题
                            fs.Close();
                            FileUtils.DeleteFile(path);
                            HttpUtils.Instance.Invoke(action, "");
                        }
                    }
                    else
                    {
                        HttpUtils.Instance.Invoke(action, path);
                    }
                }
                else
                {
                    HttpUtils.Instance.Invoke(action, path);
                }
            }
            catch (Exception)
            {
                HttpUtils.Instance.Invoke(action, "");
            }
        });
    }





    #region 下载
    internal static void DownloadFile(List<DownloadFile> downlist, List<Action<DownloadFile>> actions)
    {
        Task.Factory.StartNew(() =>
       {
           //这里需要在线程中循环下载下载
           foreach (var item in downlist)
           {
               try
               {
                   if (File.Exists(item.LocalUrl) && item.ShouldDeleteWhileFileExists)//如果对应文件存在 且 需要下载替换对应文件时
                   {
                       File.Delete(item.LocalUrl);//先删除文件(再下载文件)
                   }
                   else if (File.Exists(item.LocalUrl) && !item.ShouldDeleteWhileFileExists)
                   {
                       continue;//如果文件存在不需要删除时 ,, 不执行循环剩下代码并执行下一个循环
                   }
                   HttpItem httpitem = new HttpItem()
                   {
                       URL = item.Url,
                       ResultType = ResultType.Byte
                   };
                   var result = new HTTP().GetHtml(httpitem);
                   if (result.StatusCode == System.Net.HttpStatusCode.OK)//服务器返回正常才处理字节
                   {
                       item.ResultBytes = result.ResultByte;//设置下载后的数据
                       //委托调用 通知前端 某一张 下载完成
                       item.State = DownloadState.Successed;
                   }
                   else
                   {
                       item.State = DownloadState.Error;
                   }
               }
               catch (Exception ex)//下载错误的时候该怎么弄头像
               {
                   ConsoleLog.Output("File--DownloadError" + ex.Message);
                   item.State = DownloadState.Error;
               }
               //Application
               foreach (var action in actions)
               {
                   if (item.CallBackControl == null)
                   {
                       action(item);
                   }
                   else
                   {
                       item.CallBackControl.Invoke(action, item);
                   }
               }
           }
       });
    }
    #endregion


    #region 下载字符串
    /// <summary>
    /// 下载字符串
    /// </summary>
    /// <param name="item">单个请求的下载</param>
    /// <param name="completeActions">下载完成需要操作的</param>
    internal static void DownloadString(DownloadString item, List<Action<DownloadString>> completeActions)
    {
        Task.Factory.StartNew(() =>
        {
            //这里需要在线程中循环下载下载
            try
            {
                var httpitem = new HttpItem() { URL = item.Url, ResultType = ResultType.Byte };
                if (!string.IsNullOrWhiteSpace(item.HttpParas))
                {
                    httpitem.Method = "GET";
                    httpitem.URL += item.HttpParas;//追加Get参数
                    /*
                    httpitem.Postdata = item.HttpParas;
                    httpitem.PostEncoding = Encoding.UTF8;
                    httpitem.PostDataType = PostDataType.String;
                    httpitem.PostEncoding = Encoding.UTF8;
                    */
                }
                HttpResult result = new HTTP().GetHtml(httpitem);//调用http请求获取返回值
                if (result.StatusCode == System.Net.HttpStatusCode.OK)//服务器返回正常才处理字节
                {
                    if (item.Type == DownLoadFileType.String)
                    {
                        item.ResultText = Encoding.UTF8.GetString(result.ResultByte);
                        item.State = DownloadState.Successed;
                    }
                }
                else
                {
                    item.State = DownloadState.Error;
                    item.Error = new Exception("网络错误：" + result.StatusCode + ", " + result.StatusDescription);
                }
            }
            catch (Exception ex)//下载错误时
            {
                ConsoleLog.Output("String--DownloadError" + ex.Message);
                item.State = DownloadState.Error;
                item.Error = ex;//收集错误信息
            }
            if (completeActions != null)
            {
                foreach (var action in completeActions)
                {
                    if (item.CallBackControl == null)
                    {
                        action(item);
                    }
                    else
                    {
                        item.CallBackControl.Invoke(action, item);
                    }
                }
            }
        });
    }
    #endregion

    #region 批量下载字符串
    /// <summary>
    /// 批量下载字符串
    /// </summary>
    /// <param name="downlist"></param>
    /// <param name="action"></param>
    internal static void DownloadStringList(List<DownloadFile> downlist, Action<DownloadFile> action)
    {
        Task.Factory.StartNew(() =>
        {
            //这里需要在线程中循环下载下载
            foreach (var item in downlist)
            {
                try
                {
                    if (File.Exists(item.LocalUrl) && item.ShouldDeleteWhileFileExists)//如果对应文件存在 且 需要下载替换对应文件时
                    {
                        File.Delete(item.LocalUrl);//先删除文件(再下载文件)
                    }
                    else if (File.Exists(item.LocalUrl) && !item.ShouldDeleteWhileFileExists)
                    {
                        continue;//如果文件存在不需要删除时 ,, 不执行循环剩下代码并执行下一个循环
                    }

                    var httpitem = new HttpItem() { URL = item.Url, ResultType = ResultType.Byte };
                    if (!string.IsNullOrWhiteSpace(item.HttpParas))
                    {
                        httpitem.Postdata = item.HttpParas;
                        httpitem.PostEncoding = Encoding.UTF8;
                    }
                    HttpResult result = new HTTP().GetHtml(httpitem);//调用http请求获取返回值
                    if (result.StatusCode == System.Net.HttpStatusCode.OK)//服务器返回正常才处理字节
                    {
                        if (item.Type == DownLoadFileType.Image)
                        {
                            //委托调用 通知前端 某一张 下载完成
                            item.State = DownloadState.Successed;
                            action(item);
                        }
                    }
                    else
                    {
                        item.State = DownloadState.Error;
                        action(item);
                    }
                }
                catch (Exception ex)//下载错误的时候该怎么弄头像
                {
                    ConsoleLog.Output("File--DownloadError" + ex.Message);
                    item.State = DownloadState.Error;
                    action(item);
                }
            }
        });
    }
    #endregion
}
