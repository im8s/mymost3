using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Helper;
using WinFrmTalk.Model;
using WinFrmTalk.Properties;
using WinFrmTalk.View.list;

namespace WinFrmTalk.View
{
    // 群文件窗口

    public partial class FrmGroupFileList : FrmBase
    {
        #region 全局变量

        private delegate void DelegateString(string msg);

        public string mRoomId;//房间Id
        private GroupFileItem mCurrtItem;   //被选中的项
        private GroupFileAdapter mAdapter;
        #endregion

        public FrmGroupFileList()
        {
            mAdapter = new GroupFileAdapter();

            InitializeComponent();

            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            //注册消息通知
            Messenger.Default.Register<string>(this, MessageActions.FILE_DOWN_COMPT, RefreshFileDown);
            Messenger.Default.Register<MessageObject>(this, MessageActions.XMPP_UPDATE_ROOM_CHANGE_MESSAGE, ProcessGroupFileMsg);
        }

        // 入口方法 
        public void ShowRoomFileList(string roomId, Friend mFriend)
        {
            this.mRoomId = roomId;

            // 修改文件上传权限
            RefreshUpPermissions(mFriend.AllowUploadFile.ToString());

            // 加载文件列表
            LoadRoomFileList();

            this.Show();
        }

        #region 处理群文件相关消息
        private void ProcessGroupFileMsg(MessageObject msg)
        {
            // 更新最后一条消息内容，通知UI刷新
            switch (msg.type)
            {
                case kWCMessageType.RoomFileUpload://上传群文件
                    LoadRoomFileList();
                    break;
                case kWCMessageType.RoomFileDelete://删除群文件
                    LoadRoomFileList();
                    break;
                case kWCMessageType.RoomFileDownload://下载群文件
                    break;
                case kWCMessageType.RoomAllowUploadFile://是否允许成员上传群文件
                    RefreshUpPermissions(msg.content);
                    break;
                default:
                    break;
            }
        }

        #endregion

        #region 刷新文件下载状态
        public void RefreshFileDown(string url)
        {
            if (Thread.CurrentThread.IsBackground)
            {
                var main = new DelegateString(RefreshFileDown);
                Invoke(main, url);
                return;
            }

            int index = -1;
            for (int i = 0; i < mAdapter.GetItemCount(); i++)
            {
                RoomFileBean data = mAdapter.GetDatas(i);
                if (data.url.Equals(url))
                {
                    index = i;
                    break;
                }
            }

            if (index > -1)
            {
                xListView1.RefreshItem(index);
            }
        }
        #endregion

        #region 刷新上传权限
        private void RefreshUpPermissions(string allow)
        {
            // 允许上传群文件，或者我是管理员
            if ("1".Equals(allow) || IsGroupManager(mRoomId))
            {
                btnUploading.Enabled = true;
                btnUploading.BackColor = ColorTranslator.FromHtml("#1AAD19");
            }
            else
            {
                btnUploading.Enabled = false;
                btnUploading.BackColor = Color.Gray;
            }
        }

        public bool IsGroupManager(string roomId)
        {
            RoomMember member = new RoomMember() { roomId = roomId, userId = Applicate.MyAccount.userId };
            RoomMember member1 = member.GetRommMember();
            return member1.role == 1 || member1.role == 2;

        }
        #endregion

        #region 从服务器加载数据
        public void LoadRoomFileList()
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/share/find")
                 .AddParams("access_token", Applicate.Access_Token)
                 .AddParams("roomId", mRoomId)
                 .AddParams("pageSize", "200")
                 .Build().ExecuteList<JsonRoomFileList>((sccess, list) =>
                 {
                     if (sccess)
                     {
                         SetDataToList(false, list.data);
                     }
                 });
        }
        #endregion

        #region 把数据显示到列表
        public void SetDataToList(bool append, List<RoomFileBean> data)
        {
            mAdapter.FrmGroupFile = this;
            mAdapter.BindFriendData(data);
            xListView1.SetAdapter(mAdapter);

        }
        #endregion

        #region 根据数据创建项
        public GroupFileItem NewGroupFileItem(RoomFileBean item)
        {
            GroupFileItem groupFileItem = new GroupFileItem();
            //数据
            groupFileItem.data = item;
            //文件名
            groupFileItem.fileName = item.name;
            //大小
            groupFileItem.Legth = UIUtils.FromatFileSize(item.size);
            //时间
            groupFileItem.Time = item.time.StampToDatetime().ToString("yyyy-MM-dd HH:mm");
            //上传者
            groupFileItem.nickName = item.nickname;
            //地址
            groupFileItem.Url = item.url;
            //文件id
            groupFileItem.ShareId = item.shareId;
            //群id
            groupFileItem.roomJid = item.roomId;
            //下载状态
            groupFileItem.isDown = IsFileExists(groupFileItem.fileName);
            groupFileItem.Staue = groupFileItem.isDown ? "已下载" : "未下载";
            //头像
            groupFileItem.FillFileIcon();

            //添加点击事件
            groupFileItem.MouseDown += MouseDownItem;

            // 绑定右键菜单
            BindContextMenu(groupFileItem);

            return groupFileItem;
        }
        #endregion

        #region 绑定右键菜单

        public void BindContextMenu(GroupFileItem item)
        {
            // 下载
            string open_str = item.isDown ? "打开" : "下载";
            MenuItem open = new MenuItem(open_str, (sen, e) => {
                OnDownRoomFile(item);
            });

            // 转发
            MenuItem forward = new MenuItem("转发", (sen, e) => {
                ForwardRoomFile(item);
            });

            // 删除
            MenuItem del = new MenuItem("删除", (sen, e) => {
                DeleteRoomFile(item);
            });

            // 另存为
            MenuItem save = new MenuItem("另存为", (sen, e) => {
                SaveAsRoomFile(item);
            });

            ContextMenu menu = new ContextMenu();
            menu.MenuItems.Add(open);
            menu.MenuItems.Add(forward);
            menu.MenuItems.Add(del);
            menu.MenuItems.Add(save);

            //设置右键菜单
            item.ContextMenu = menu;
        }
        #endregion

        #region 鼠标左右键选中
        public void MouseDownItem(object sender, MouseEventArgs e)
        {
            GroupFileItem current = sender as GroupFileItem;
            
            // 改变选中项颜色
            current.IsSelect = true;
          
            // 改变上一个选中项的颜色
            if (mCurrtItem != null)
            {

                mCurrtItem.IsSelect = false;
            }

            mCurrtItem = current;
        }


        #endregion

        #region 文件是否存在
        private bool IsFileExists(string name)
        {
            // 本地变量判断是否下载过存在

            // 判断下载地址是否有这个文件
            string filePath = Applicate.LocalConfigData.RoomFileFolderPath + name;
            return File.Exists(filePath);
        }
        #endregion

        #region 文件上传
        private void btnUploading_Click(object sender, EventArgs e)
        {

            OpenFileDialog openFile = new OpenFileDialog();
            //打开跟目录
            openFile.InitialDirectory = @"C:\Users\Administrator\Documents";
            //名称
            openFile.Title = "请选择";
            if (openFile.ShowDialog() == DialogResult.OK)
            {
                RoomFileBean roomFile = new RoomFileBean();
                //路径
                roomFile.url = openFile.FileName;
                //名称
                roomFile.name = openFile.SafeFileName;
                //时间
                roomFile.time = TimeUtils.CurrentIntTime();
                //文件类型
                int type = FileUtils.GetFileTypeByNanme(roomFile.name);
                //长度
                FileInfo file = new FileInfo(openFile.FileName);
                roomFile.size = file.Length;
                //昵称
                roomFile.nickname = Applicate.MyAccount.nickname;
                roomFile.roomId = mRoomId;
                if (!FileIsUsed(openFile.FileName))
                {
                    //添加
                    GroupFileItem groupFileItem = NewGroupFileItem(roomFile);
                    //增加项
                    groupFileItem.DownState = 2;
                    mAdapter.InsertData(0, roomFile);
                    xListView1.InsertItem(0);
                    // 上传文件
                    NewMethodSchangChuang(roomFile, type, file, groupFileItem);
                    string filePath = Applicate.LocalConfigData.RoomFileFolderPath + roomFile.name;
                    //上传成功
                    FileInfo fileInfo = new FileInfo(roomFile.url);
                    if (!IsFileExists(roomFile.url))
                    {
                        file.CopyTo(filePath, true);
                    }
                    //关闭预览按钮
                    groupFileItem.isDown = IsFileExists(groupFileItem.fileName);
                    // groupFileItem.Staue = groupFileItem.isDown ? "已下载" : "未下载";
                }
            }
        }
        /// <summary>
        /// 文件是否正在由另一个进程打开
        /// </summary>
        /// <param name="fileFullName"></param>
        /// <returns></returns>
        public static Boolean FileIsUsed(string fileFullName)
        {
            Boolean result = false;
            //判断文件是否存在
            if (!File.Exists(fileFullName))
            {
                return false;
            }
            else
            {
                //验证文件是否打开
                System.IO.FileStream fileStream = null;
                try
                {
                    fileStream = System.IO.File.Open(fileFullName, System.IO.FileMode.Open, System.IO.FileAccess.ReadWrite, System.IO.FileShare.None);

                    result = false;

                }
                catch (System.Exception ex)
                {
                    MessageBox.Show(ex.Message);
                    result = true;
                }
                finally
                {
                    if (fileStream != null)
                    {
                        fileStream.Close();
                    }
                }
            }
            return result;
        }
        private void NewMethodSchangChuang(RoomFileBean roomFile, int type, FileInfo file, GroupFileItem groupFileItem)
        {
            //进度条
            UploadEngine.Instance.From(roomFile.url).UpProgress((pro) =>
            {
                groupFileItem.SetProgress(pro);
            }).UploadFile((success, sPath) =>
            {
                if (success)
                {
                    HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/add/share")
                     .AddParams("access_token", Applicate.Access_Token)
                     .AddParams("roomId", mRoomId)
                     .AddParams("size", file.Length.ToString())
                     .AddParams("name", roomFile.name)
                     .AddParams("url", sPath)
                     .AddParams("userId", Applicate.MyAccount.userId)
                     .AddParams("type", type.ToString())
                     .Build().Execute((sccess, list) =>
                     {
                         //上传成功
                         if (sccess)
                         {
                             groupFileItem.DownState = 0;
                             //群文件id
                             groupFileItem.ShareId = list["shareId"].ToString();
                             //下载地址
                             groupFileItem.Url = list["url"].ToString();
                             groupFileItem.Staue = "上传成功";

                         }
                         //上传失败
                         else
                         {
                             groupFileItem.DownState = 0;
                             groupFileItem.Staue = "上传失败";

                         }

                     });
                }
                else
                {
                    //网络断掉
                    groupFileItem.DownState = 0;
                    groupFileItem.Staue = "上传失败";
                }

            });
        }
        #endregion

        #region 文件下载
        public void OnDownRoomFile(GroupFileItem item)
        {
            if (item.isDown)
            {
                // 去打开
                OpenRoomFile(item);
            }
            else
            {
                if (item.DownState == 1)
                {
                    // 正在下载中
                }
                else
                {
                    // 去下载
                    item.DownState = 1;
                    DownRoomFile(item);
                }
            }
        }

        // 打开文件
        public void OpenRoomFile(GroupFileItem openItem)
        {
            string filePath = Applicate.LocalConfigData.RoomFileFolderPath + openItem.fileName;

            //图片
            if (openItem.data.type == 1)
            {
                int index = 0;
                List<RoomFileBean> images = new List<RoomFileBean>();

                #region 生成图片数据

                for (int i = 0; i < mAdapter.GetItemCount(); i++)
                {
                    RoomFileBean data = mAdapter.GetDatas(i);
                    if (data.type == 1)
                    {
                        images.Add(data);

                        if (openItem.data.url.Equals(data.url))
                        {
                            index = i;
                        }
                    }
                }


                #endregion

                FrmLookImage frm = new FrmLookImage();
                //将集合赋值
                frm.ShowImage(images, index);

            }
            //视频
            else if (openItem.data.type == 3)
            {
                FrmVideoFlash frmVideo = FrmVideoFlash.CreateInstrance();
                frmVideo.VidoShow(filePath);
                frmVideo.FilePath = filePath;
                frmVideo.LocationPath = openItem.Url;
                frmVideo.fileSize = openItem.data.size;
                frmVideo.fileName = openItem.data.name;
                frmVideo.Show();
            }
            //系统资源打开
            else
            {
                //打开此文件
                System.Diagnostics.Process.Start(filePath);
            }
        }

        public void DownRoomFile(GroupFileItem item)
        {
            string savePath = Applicate.LocalConfigData.RoomFileFolderPath + item.fileName;
            string downPath = item.Url;
            DownloadEngine.Instance.DownUrl(downPath)
              .DownProgress((progress) =>
              {
                  item.SetProgress(progress);

              })
              .SavePath(savePath)
              .Down((path) =>
              {
                  if (savePath.Equals(path))
                  {
                      item.DownState = 0;
                      RefreshFileDown(item.Url);
                  }
              });
        }


        #endregion

        #region 转发文件
        private void ForwardRoomFile(GroupFileItem chooseItem)
        {
            //本地地址
            string filePath = Applicate.LocalConfigData.RoomFileFolderPath + chooseItem.fileName;
            //网络地址
            string url = chooseItem.Url;
            //长度
            long lenth = chooseItem.data.size;
            //打开好友选择器
            var frm = new FrmFriendSelect();
            frm.LoadFriendsData();
            frm.AddConfrmListener((UserData) =>
            {
                foreach (var item in UserData)
                {
                    //调用xmpp
                    ShiKuManager.SendFileMessage(item.Value, url, filePath, lenth);
                }
            });
        }
        #endregion

        #region 删除文件
        private void DeleteRoomFile(GroupFileItem chooseItem)
        {
            //获取当前文件路径
            string filePath = Applicate.LocalConfigData.RoomFileFolderPath + chooseItem.fileName;
            //文件url
            string shareId = chooseItem.ShareId;
            mRoomId = chooseItem.roomJid;

            //本地删除
            //验证本地文件是否存在
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }
            //从服务器删除
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/share/delete")
                  .AddParams("access_token", Applicate.Access_Token)
                 .AddParams("roomId", mRoomId)
                 .AddParams("userId", Applicate.MyAccount.userId)
                 .AddParams("shareId", shareId)
                 .Build().Execute(null);

            // 服务器删除成功后会用xmpp消息推送过来所以不用单独移除项了
        }
        #endregion

        #region 另存为文件
        private void SaveAsRoomFile(GroupFileItem chooseItem)
        {
            string foldPath = "";
            //文件路径
            string filePath = Applicate.LocalConfigData.RoomFileFolderPath + chooseItem.fileName;
            //选择框
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            dialog.Description = "请选择文件路径";
            //确认选择
            if (dialog.ShowDialog() == DialogResult.OK)
            {
                foldPath = dialog.SelectedPath + "\\" + chooseItem.fileName;
                //验证路径
                FileInfo file = new FileInfo(filePath);
                if (!file.Exists)
                {
                    string fileurl = chooseItem.Url;
                    DownFile(foldPath, fileurl);
                }
                else
                {
                    file.CopyTo(foldPath, true);

                }
            }

        }

        private void DownFile(string toFilePath, string fileUrl)
        {
            HttpDownloader.DownloadFile(fileUrl, toFilePath, (path) =>
            {
                if (!string.IsNullOrEmpty(path))
                {
                    // 下载成功
                   LogUtils.Log("下载成功！" + path);
                }
            });
        }
        #endregion

        #region 窗体关闭
        private void FrmGroupFileList_FormClosed(object sender, FormClosedEventArgs e)
        {
            Applicate.Filesuseridlst.Remove(mRoomId);
            Messenger.Default.Unregister(this);//反注册
        }
        #endregion
    }
}
