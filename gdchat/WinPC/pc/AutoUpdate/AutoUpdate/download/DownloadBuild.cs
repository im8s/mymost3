using System;
using System.IO;
using System.Net;
using System.Windows.Forms;

public class DownloadBuild
{
    private string filePath;
    private string downUrl;
    private Action<int> progress;
    private Action<string> downListener;
    private HttpWebRequest webRequest;
    private Control mControl;

    public DownloadBuild(string url)
    {
        downUrl = url;
    }

    public DownloadBuild SavePath(string path)
    {
        filePath = path;
        return this;
    }


    public DownloadBuild DownProgress(Action<int> action)
    {
        progress = action;
        return this;
    }


    public DownloadBuild SetMainControl(Control action)
    {
        mControl = action;
        return this;
    }



    public void Down(Action<string> action)
    {
        downListener = action;
        Down();
    }

    private void OnSuccess()
    {

    }

    private void OnError()
    {

    }


    public void Down()
    {

        if (string.IsNullOrEmpty(downUrl))
        {
            Console.WriteLine("下载地址为空");
            OnError();
            return;
        }

        //if (string.IsNullOrEmpty(filePath))
        //{
        //    filePath = "/123.zip"; // 写死路径和文件名
        //}


        if (File.Exists(filePath))//如果对应文件存在 先删除文件(再下载文件)
        {
            File.Delete(filePath);
        }

        StartDown();
    }



    private void StartDown()
    {
        HttpWebRequest Request = (HttpWebRequest)WebRequest.Create(downUrl);
        this.webRequest = Request;
        Request.BeginGetResponse(BeginResponseCallback, this);
    }



    private void BeginResponseCallback(IAsyncResult result)
    {
        DownloadBuild downloadInfo = (DownloadBuild)result.AsyncState;
        HttpWebResponse Response = (HttpWebResponse)downloadInfo.webRequest.EndGetResponse(result);

        if (Response.StatusCode == HttpStatusCode.OK || Response.StatusCode == HttpStatusCode.Created)
        {
            string filePath = downloadInfo.filePath;


            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }
            //FileStream fs = new FileStream(filePath, FileMode.Create, FileAccess.Write);
            FileStream fs = File.OpenWrite(filePath);

            Stream stream = Response.GetResponseStream();

            int count = 0;
            int num = 0;
            if (Response.ContentLength > 0)
            {
                var buffer = new byte[2048 * 10];
                int lastPro = 0;
                do
                {
                    num++;
                    count = stream.Read(buffer, 0, buffer.Length);
                    fs.Write(buffer, 0, count);


                    int pro = (int)((float)fs.Length / Response.ContentLength * 100);
                    if (downloadInfo.progress != null && pro != lastPro)
                    {
                        lastPro = pro;
                        mControl.Invoke(downloadInfo.progress, pro);
                        //Console.WriteLine("下载进度" + pro);
                    }

                } while (count > 0);
            }

            fs.Close();
            Response.Close();

            if (downloadInfo.downListener != null)
            {
                mControl.Invoke(downloadInfo.downListener, filePath);
            }
        }
        else
        {
            Response.Close();
            if (downloadInfo.downListener != null)
            {
                mControl.Invoke(downloadInfo.downListener, "");
            }
        }
    }

}
