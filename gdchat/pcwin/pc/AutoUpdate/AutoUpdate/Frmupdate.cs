using ICSharpCode.SharpZipLib.Zip;
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;


namespace AutoUpdate
{
    public partial class Frmupdate : Form
    {
        [DllImport("zipfile.dll")]
        public static extern int MyZip_ExtractFileAll(string zipfile, string pathname);
        public Frmupdate()
        {
            InitializeComponent();
        }

        private void Download()
        {
            string savePaht = Application.StartupPath + "\\IM.zip";//下载到哪个路径
            //读取下载地址
            FileStream fsRead = new FileStream("Download.config", FileMode.OpenOrCreate);
            int fsLen = (int)fsRead.Length;
            byte[] heByte = new byte[fsLen];
            int r = fsRead.Read(heByte, 0, heByte.Length);
            string myStr = System.Text.Encoding.UTF8.GetString(heByte);
            fsRead.Close();
            if (string.IsNullOrEmpty(myStr))
            {
               // myStr = Applicate.URLDATA.data.pcAppUrl;
            }
            //开始下载
            DownloadEngine.Instance.DownUrl(myStr).SetMainControl(this)
              .DownProgress((pro) => {
                  progressBar1.Value = pro;
                  label1.Text = pro + "%";
              }).SavePath(savePaht).Down(
                  (path) =>
                  {
                      if (path.Equals(savePaht))
                      {
                          label2.Text = "下载成功，正在解压";
                          Thread t = new Thread(() =>
                          {
                              string err = String.Empty;

                              //FastZip fastZip = new FastZip();
                              //fastZip.ExtractZip(savePaht, Application.StartupPath, "");
                              app_UpdateFinish(savePaht);
                              //将下载下来的文件进行替换
                              //  string exepath=  ZipToFile(savePaht, Application.StartupPath, out err);//解压
                              //      if (!string.IsNullOrEmpty(err))
                              //    {
                              //        MessageBox.Show("解压出错,原因：" + err);
                              //    }

                              //    this.Invoke(new Action(() => { label2.Text = "解压成功，启动中。。。"; }));

                              //    System.Diagnostics.Process process = new System.Diagnostics.Process();
                              //    process.StartInfo.FileName = "WinFrmTalk.exe";
                              //    process.StartInfo.WorkingDirectory = exepath;//要掉用得exe路径例如:"C:\windows";               
                              //    process.StartInfo.CreateNoWindow = true;
                              //    process.Start();
                              //    this.Invoke(new Action(() =>
                              //    {
                              //        this.Close();
                              //        File.Delete(savePaht);

                              //    }));
                              });
                              t.Start();
                      }

                  });
        }

        /// <summary>
        /// 下载完成后
        /// </summary>
        /// <param name="path">解压后的路径</param>
        void app_UpdateFinish(string path)
        {
            //解压下载后的文件
            

            if (File.Exists(path))
            {
                //后改的 先解压滤波zip植入ini然后再重新压缩
                string dirEcgPath = Application.StartupPath + "\\" + "autoupload";
                if (!Directory.Exists(dirEcgPath))
                {
                    Directory.CreateDirectory(dirEcgPath);
                }
                //开始解压压缩包
                //MyZip_ExtractFileAll(path, dirEcgPath);
                FastZip fastZip = new FastZip();
                fastZip.ExtractZip(path, dirEcgPath, "");

            

                try
                {
                    //复制新文件替换旧文件
                    dirEcgPath += "\\"+ "im_pc";
                    DirectoryInfo TheFolder = new DirectoryInfo(dirEcgPath);
                    //如果文件被占用就不复制
                    foreach (FileInfo NextFile in TheFolder.GetFiles())
                    {
                        if(!IsFileInUse(Application.StartupPath + "\\" + NextFile.Name))
                        File.Copy(NextFile.FullName, Application.StartupPath + "\\" + NextFile.Name, true);
                        else
                        {

                        }
                    }
                    Directory.Delete(dirEcgPath, true);
                    File.Delete(path);
                    //覆盖完成 重新启动程序
                    path = Application.StartupPath;
                    System.Diagnostics.Process process = new System.Diagnostics.Process();
                    process.StartInfo.FileName = "WinFrmTalk.exe";
                    process.StartInfo.WorkingDirectory = path;//要掉用得exe路径例如:"C:\windows";               
                    process.StartInfo.CreateNoWindow = true;
                    process.Start();

                    Application.Exit();
                }
                catch (Exception e)
                {
                    MessageBox.Show("请关闭系统在执行更新操作!");
                    Console.WriteLine(e.Message);
                    Application.Exit();
                }




            }
        }
        public static bool IsFileInUse(string fileName)
        {
            bool inUse = true;

            if (fileName.Contains("WinFrmTalk.exe"))
            {
                int i = 0;
                var v = fileName;
            }

            FileStream fs = null;
            try
            {

                fs = new FileStream(fileName, FileMode.Open, FileAccess.Read,

                FileShare.None);

                inUse = false;
            }
            catch
            {
            }
            finally
            {
                if (fs != null)

                    fs.Close();
            }
            return inUse;//true表示正在使用,false没有使用  
        }
        private void Frmupdate_Load(object sender, EventArgs e)
        {
            Download();
        }
    }
}
