using System;
using System.IO;
using System.Windows.Forms;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQFileControl : EQBaseControl
    {
        public bool isDownloading
        {
            get => panel_file == null ? false : panel_file.isDownloading;
            set => panel_file.isDownloading = value;
        }
        public EQFileControl(string strJson) : base(strJson)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public EQFileControl(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = true;
            isRemindMessage = false;
        }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleWidth = control.Width;
            BubbleHeight = control.Height;
        }

        FilePanelLeft panel_file = new FilePanelLeft();
        public override Control ContentControl()
        {
            panel_file.Name = "panel_file";
            panel_file.BackColor = bg_color;
            panel_file.Cursor = Cursors.Hand;
            panel_file.lab_lineLime.Width = 0;
            panel_file.Tag = messageObject.messageId;
            panel_file.isDownloading = false;   //默认为不是正在下载

            string fileName = FileUtils.GetFileName(messageObject.fileName);
            //    messageObject.fileName.Substring(messageObject.content.LastIndexOf("/") + 1);
            panel_file.lab_fileName.Text = fileName;
            panel_file.lab_fileSize.Text = UIUtils.FromatFileSize(messageObject.fileSize);

            //点击下载
            panel_file.Click += PanelFile_Click;
            foreach (Control crl in panel_file.Controls)
            {
                crl.Click += PanelFile_Click;
                if (crl.Controls.Count > 0)
                    foreach (Control item in crl.Controls)
                        item.Click += PanelFile_Click;
            }

            //设置气泡大小
            Calc_PanelWidth(panel_file);

            return panel_file;
        }

        private void PanelFile_Click(object sender, EventArgs e)
        {
            //MessageObject msg = MessageObjectDataDictionary.GetMsg(panel_file.Tag != null ? panel_file.Tag.ToString() : "");
            MessageObject msg = this.messageObject;

            //文件的本地路径
            string localPath = Applicate.LocalConfigData.FileFolderPath + FileUtils.GetFileName(msg.fileName);
            string sname = FileUtils.GetFileName(msg.content);
            bool isAlike = sname.Equals(msg.objectId);

            //本地已存在该文件，并且不是下载中   这样会有一个bug,就是服务器的文件和实际下载的文件不一样
            if (File.Exists(localPath) && !panel_file.isDownloading && isAlike)
            {
                try
                {
                    //打开文件
                    System.Diagnostics.Process.Start(localPath);
                }
                catch (Exception)
                {
                    HttpUtils.Instance.ShowTip("不能打开此类型文件");
                }

                var crl_msg = panel_file.Parent.Parent.Controls["lab_redPoint"];
                if (crl_msg != null && crl_msg is Label lab_redPoint && lab_redPoint.Image != null)
                {
                    //去除红点
                    DrawIsReceive(lab_redPoint, 1);
                }
            }
            #region download file
            else
            {
                //正在下载
                if (panel_file.isDownloading)
                    return;

                string sname1 = FileUtils.GetFileName(msg.content);
                if (!sname1.Equals(msg.objectId))
                {
                   
                    var r = new Random(Guid.NewGuid().GetHashCode());//产生不重复的随机数
                    string filename = FileUtils.GetFileName(msg.fileName);
                    string suffix = FileUtils.GetFileExtension(msg.fileName);//取出后缀
                    string filename1 = filename.Replace(suffix, "") + "(" + r.Next(0, 1000) + ")" + suffix;//合成名称
                    localPath = Applicate.LocalConfigData.FileFolderPath + filename1;//重新赋值
                    msg.fileName = filename1;
                    msg.UpdateFilename();
                }


                if (File.Exists(localPath))//如果对应文件存在 先删除文件(再下载文件)
                {

                    var r = new Random(Guid.NewGuid().GetHashCode());//产生不重复的随机数
                    string filename = FileUtils.GetFileName(msg.fileName);
                    string suffix = FileUtils.GetFileExtension(msg.fileName);//取出后缀
                    string filename1 = filename.Replace(suffix, "") + "(" + r.Next(0, 1000) + ")" + suffix;//合成名称
                    localPath = Applicate.LocalConfigData.FileFolderPath + filename1;//重新赋值
                    msg.fileName = filename1;
                    msg.UpdateFilename();
                }


                //开始下载

                panel_file.isDownloading = true;
                //下载文件
                DownloadEngine.Instance.DownUrl(msg.content)
                .DownProgress((progress) =>
                {
                    panel_file.lab_lineLime.BringToFront();
                    panel_file.lab_lineLime.Width = Convert.ToInt32(panel_file.lab_lineSilver.Width * ((decimal)progress / 100));
                    if ((progress / 100) == 1)
                        panel_file.lab_lineLime.Width = 0;
                }).
                DownSpeed((speed) =>
                {
                    panel_file.lblSpeed.Visible = true;
                    panel_file.lblSpeed.BringToFront();
                    panel_file.lblSpeed.Text = speed + @"/s";
                })
                .SavePath(localPath)
                .Down((path) =>
                {
                    if (string.IsNullOrEmpty(path))
                        return;


                    msg.objectId = sname1;
                    msg.UpdateObject();
                    //下载完成
                    panel_file.lblSpeed.Visible = false;
                    panel_file.isDownloading = false;
                    //打开文件
                    System.Diagnostics.Process.Start(localPath);

                    var crl_msg = panel_file.Parent.Parent.Controls["lab_redPoint"];
                    if (crl_msg != null && crl_msg is Label lab_redPoint && lab_redPoint.Image != null)
                    {
                        //去除红点
                        DrawIsReceive(lab_redPoint, 1);
                    }
                });
            }
            //发送已读通知
            if (msg.isRead == 0)
                ShiKuManager.SendReadMessage(msg.GetFriend(), msg);
            #endregion
        }
    }
}
