using Newtonsoft.Json;
using RestSharp;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using WinFrmTalk;

public class UploadFileBuild
{
    private string filePath;
    private Action<int> progressListener;
    private Action<string> speedListener;

    private System.Timers.Timer SpeedTime;
    private long lastupsize; // 上次下载的大小

    public UploadFileBuild(string path)
    {
        filePath = path;
    }


    internal UploadFileBuild UpProgress(Action<int> action)
    {
        progressListener = action;
        return this;
    }

    internal UploadFileBuild UpSpeed(Action<string> action)
    {
        speedListener = action;

        SpeedTime = new System.Timers.Timer();
        SpeedTime.Interval = 1000; // 1秒 刷新一次下载速度
        SpeedTime.Elapsed += new ElapsedEventHandler(OnSpeed);
        SpeedTime.AutoReset = true;
        SpeedTime.Enabled = true;

        return this;
    }


    private void OnSpeed(object source, System.Timers.ElapsedEventArgs e)
    {
        //Console.WriteLine("下载速度" + lastupsize);

        if (speedListener != null)
        {
            string size = UIUtils.FromatFileSize(lastupsize);
            HttpUtils.Instance.Invoke(speedListener, size);
        }

        lastupsize = 0;

    }


    internal void UploadFile(Action<bool, string> action)
    {
        if (string.IsNullOrEmpty(filePath) || !File.Exists(filePath))
        {
            LogUtils.Log("文件错误");
            action(false, "文件错误");
            DisposeTimer();
            return;
        }



        if (progressListener == null && speedListener == null)
        {
            UploadFileAsyc(action);
        }
        else
        {
            HttpUploadFile(action);
        }
    }


    internal void UploadAvatar(string userId, Action<bool> action)
    {
        if (string.IsNullOrEmpty(filePath) || !File.Exists(filePath))
        {
            LogUtils.Log("文件错误");
            action(false);
            return;
        }

        try
        {
            var request = new RestRequest(Method.POST);
            //时间戳
            string strBoundary = "---------------------------" + DateTime.Now.Ticks.ToString("x");
            request.AddHeader("Content-Type", "multipart/form-data; boundary=" + strBoundary);
            request.AddFile("file1", filePath);
            request.AddParameter("userId", userId, ParameterType.GetOrPost);

            //calling server with restClient
            var restClient = new RestClient
            {
                BaseUrl = new Uri(Applicate.URLDATA.data.uploadUrl + "upload/UploadAvatarServlet")
            };
            restClient.ExecuteAsync(request, (response) =>
            {

                if (response.StatusCode == HttpStatusCode.OK)
                {
                    HttpUtils.Instance.Invoke(action, true);
                }
                else
                {
                    HttpUtils.Instance.Invoke(action, false);
                }
            });
        }
        catch (Exception)
        {
            action(false);
        }
    }



    private void UploadFileAsyc(Action<bool, string> action)
    {
        try
        {
            var request = new RestRequest(Method.POST);
            //时间戳
            string strBoundary = "---------------------------" + DateTime.Now.Ticks.ToString("x");
            request.AddHeader("Content-Type", "multipart/form-data; boundary=" + strBoundary);
            request.AddFile("file", filePath);

            //calling server with restClient
            var restClient = new RestClient
            {
                BaseUrl = new Uri(Applicate.URLDATA.data.uploadUrl + "upload/UploadServlet")
            };
            restClient.ExecuteAsync(request, (response) =>
            {
                if (response.StatusCode == HttpStatusCode.OK)
                {
                    var result = JsonConvert.DeserializeObject<JsonFileinfo>(response.Content);

                    if (result.resultCode == BaseCall.CODE_SUCCESS && result.data != null)
                    {
                        string path = GetFileUpPath(result);
                        action(true, path);
                    }
                    else
                    {
                        action(false, "文件上传失败服务器报错");
                    }
                }
                else
                {
                    action(false, "文件上传失败解析出错");
                }
            });
        }
        catch (Exception)
        {
            action(false, "文件上传失败网络原因");
        }
    }

    private void HttpUploadFile(Action<bool, string> action)
    {
        

        Task.Factory.StartNew(() =>
        {
            if (SpeedTime != null)
            {
                SpeedTime.Start();
            }

            string saveName = FileUtils.GetFileName(filePath);
            FileStream fs = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
            BinaryReader r = new BinaryReader(fs);
            // 时间戳
            string strBoundary = "--------------" + DateTime.Now.Ticks.ToString("x");
            byte[] boundaryBytes = Encoding.ASCII.GetBytes("\r\n--" + strBoundary + "--\r\n");     //请求头部信息   
            StringBuilder sb = new StringBuilder();
            sb.Append("--");
            sb.Append(strBoundary);
            sb.Append("\r\n");
            sb.Append("Content-Disposition: form-data; name=\"");
            sb.Append("file");
            sb.Append("\"; filename=\"");
            sb.Append(saveName);
            sb.Append("\";");
            sb.Append("\r\n");
            sb.Append("Content-Type: ");
            //sb.Append("text/plain");
            sb.Append("application/octet-stream");
            sb.Append("\r\n");
            sb.Append("\r\n");
            string strPostHeader = sb.ToString();
            byte[] postHeaderBytes = Encoding.UTF8.GetBytes(strPostHeader);     // 根据uri创建HttpWebRequest对象   

            var BaseUrl = new Uri(Applicate.URLDATA.data.uploadUrl + "upload/UploadServlet");
            HttpWebRequest httpReq = (HttpWebRequest)WebRequest.Create(BaseUrl);
            httpReq.Method = "POST";     //对发送的数据不使用缓存   
            httpReq.AllowWriteStreamBuffering = false;     //设置获得响应的超时时间（300秒）   
            httpReq.Timeout = 300000;
            httpReq.ContentType = "multipart/form-data; boundary=" + strBoundary;
            long length = fs.Length + postHeaderBytes.Length + boundaryBytes.Length;
            long fileLength = fs.Length;
            httpReq.ContentLength = length;

            long total = 0;
            try
            {
                //每次上传4k  
                int bufferLength = 2048 * 10;
                byte[] buffer = new byte[bufferLength];
                int size = r.Read(buffer, 0, bufferLength);
                Stream postStream = httpReq.GetRequestStream();         //发送请求头部消息   
                postStream.Write(postHeaderBytes, 0, postHeaderBytes.Length);

                while (size > 0)
                {
                    postStream.Write(buffer, 0, size);
                    size = r.Read(buffer, 0, bufferLength);

                    lastupsize += size;
                    if (size > 0 && progressListener != null)
                    {
                        total += size;
                        int pro = (int)(total / (float)fileLength * 100);
                        HttpUtils.Instance.Invoke(progressListener, pro);
                    }
                }

                //添加尾部的时间戳   
                postStream.Write(boundaryBytes, 0, boundaryBytes.Length);
                postStream.Close();     //获取服务器端的响应   

                HttpUtils.Instance.Invoke(progressListener, 100);
                WebResponse webRespon = httpReq.GetResponse();
                Stream s = webRespon.GetResponseStream();
                //读取服务器端返回的消息  
                StreamReader sr = new StreamReader(s);

                string response = sr.ReadLine().Replace("\\\"", "'");

                var result = JsonConvert.DeserializeObject<JsonFileinfo>(response);
                if (result.resultCode == BaseCall.CODE_SUCCESS && result.data != null)
                {
                    string path = GetFileUpPath(result);
                    HttpUtils.Instance.Invoke(action, true, path);
                }
                else
                {
                    HttpUtils.Instance.Invoke(action, false, "");
                }

                s.Close();
                sr.Close();

            }
            catch (Exception ex)
            {
                HttpUtils.Instance.Invoke(action, false, ex.Message);
            }
            finally
            {
                fs.Close();
                r.Close();

                DisposeTimer();
            }
        });
    }

    private void DisposeTimer()
    {
        LogUtils.Log("DisposeTimer");

        if (SpeedTime != null)
        {
            SpeedTime.Stop();
            SpeedTime.Dispose();
        }
    }

    private string GetFileUpPath(JsonFileinfo result)
    {

        if (result.data.images.Count > 0)
        {
            return result.getImageUpPath();
        }

        if (result.data.videos.Count > 0)
        {
            return result.data.videos[0].oUrl;
        }

        if (result.data.audios.Count > 0)
        {
            return result.data.audios[0].oUrl;
        }

        if (result.data.others.Count > 0)
        {
            return result.data.others[0].oUrl;
        }

        return "不可能到这里";

    }

}
