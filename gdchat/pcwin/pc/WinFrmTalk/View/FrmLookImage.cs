using CCWin;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Threading;
using System.Windows.Forms;
using WinFrmTalk.Helper;
using WinFrmTalk.Helper.MVVM;
using WinFrmTalk.Model;
using WinFrmTalk.Properties;
using WinFrmTalk.View;
namespace WinFrmTalk
{
    public partial class FrmLookImage : FrmBase
    {
        #region 全局变量
        Point mouseDownPoint = new Point(); //记录拖拽过程鼠标位置
        bool isMove = false;    //判断鼠标在picturebox上移动时，是否处于拖拽过程(鼠标左键是否按下)
        //定义全局变量接收传递过来的数据
        private List<string> mImages = new List<string>();
        private List<RoomFileBean> listRoomFile;
        //当前索引
        private int mIndex;
        //网络地址
        public string httpUrl { get; internal set; }
        //文件大小
        public string fielSize { get; internal set; }
        //文件名
        public string FileName { get; internal set; }
        private bool isMessageObject;
        private double zoomStep = 1.2;//放大倍数
        private Bitmap myBmp;
        private bool isLocaHeade;
        public string filePath;
        public List<MessageObject> mMessageList { get; private set; }
        #endregion
        #region 窗体加载
        public FrmLookImage()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
        }


        public void pictureBox1_SetImage(string image_path, bool isReadDel = false)
        {
            this.Show();
            pictureBox1.BackgroundImageLayout = ImageLayout.Zoom;

            //判断是否为阅后即焚
            if (isReadDel)
            {
                // 通知界面刷新，我已经看了这条消息
                Messenger.Default.Send<string>(mMessageList[mIndex].messageId, token: EQFrmInteraction.RemoveMsgOfPanel);
                ShiKuManager.SendReadMessage(mMessageList[mIndex].GetFriend(), mMessageList[mIndex]);
            }


            if (isMessageObject)
            {
                //名称
                FileName = FileUtils.GetFileName(image_path);
            }


            //// 从内存加载
            Bitmap bitmap = ImageCacheManager.Instance.GetCacheImage(image_path);
            if (bitmap != null)
            {
                // 存在于本地
                if (File.Exists(image_path))
                {
                    pictureBox1.Image = Image.FromFile(image_path);
                    return;
                }


                string file_name = FileUtils.GetFileName(image_path);
                string file_path = Applicate.LocalConfigData.ImageFolderPath + FileName;
                // 存在于本地
                if (File.Exists(file_path))
                {
                    pictureBox1.Image = Image.FromFile(file_path);
                    return;
                }

                // 说明本地没有，把文件保存到本地
                bitmap.Save(file_path);

                // 存在于本地
                if (File.Exists(file_path))
                {
                    pictureBox1.Image = Image.FromFile(file_path);
                    return;
                }
            }

            // 从本地加载
            //D:\\loadSVN\\WinFrmTalk\\bin\\x86\\Debug\\Downloads\\ShikuIM\\Image\\tom.gif
            //D:\\loadSVN\\WinFrmTalk\\bin\\x86\\Debug\\Downloads\\ShikuIM\\Image\\tom.gif
            string filePath = Applicate.LocalConfigData.ImageFolderPath + FileName;
            bitmap = FileUtils.FileToBitmap(filePath);
            if (bitmap != null)
            {
                pictureBox1.Image = Image.FromFile(filePath);
                return;
            }


            //等待符
            LodingUtils loding = new LodingUtils();
            loding.parent = pictureBox1;
            loding.size = pictureBox1.Size;
            loding.start();
            ImageLoader.Instance.Load(image_path).Into((img, str) =>
            {
                ResumeLayout();
                pictureBox1.Image = img;
                loding.stop();
            });
            //pictureBox1.SizeMode = PictureBoxSizeMode.StretchImage;
        }


        private void FrmLookImage_Load(object sender, EventArgs e)
        {
            List<MessageObject> listObjest = mMessageList;
            skbtnLeft.Image = Resources.LookLeft;
            skbtnRight.Image = Resources.LookRight;
            pictureBox1.MouseWheel += new MouseEventHandler(pictureBox1_MouseWheel);
            //验证文件是否存在
            if (IsFileExists(FileName))
            {
                pboxOpenFile.Visible = true;
                pboxDown.Visible = false;
                pboxOpenFile.Location = pboxDown.Location;
            }

        }
        #endregion
        #region 图片是否存在
        //左右图片切换下载与打开图片的切换
        private void IfixisteImage()
        {
            if (isMessageObject)
            {
                string url = File.Exists(mMessageList[mIndex].fileName) ? mMessageList[mIndex].fileName : mMessageList[mIndex].content;
                //下好的图片如果路径传的是网络就去读本地的
                FileName = FileUtils.GetFileName(url);
                // 从本地加载
                string filePath = Applicate.LocalConfigData.ImageFolderPath + FileName;
                if (IsFileExists(FileName))
                {
                    pboxOpenFile.Visible = true;
                    pboxDown.Visible = false;
                    pboxOpenFile.Location = pboxDown.Location;
                }
                else
                {
                    pboxOpenFile.Visible = false;
                    pboxDown.Visible = true;
                }
                if (url == mMessageList[mIndex].fileName)
                {
                    if (IsFileExists(FileName))
                    {
                        pboxOpenFile.Visible = true;
                        pboxDown.Visible = false;
                        pboxOpenFile.Location = pboxDown.Location;
                    }
                    else
                    {
                        pboxOpenFile.Visible = false;
                        pboxDown.Visible = true;
                    }
                }
                return;
            }
            if (IsFileExists(FileName))
            {
                pboxOpenFile.Visible = true;
                pboxDown.Visible = false;
                pboxOpenFile.Location = pboxDown.Location;
            }
            else
            {
                pboxOpenFile.Visible = false;
                pboxDown.Visible = true;
            }

        }
#endregion
        #region 图片放大与缩小
        private void SetSizeForm(string path)
        {
            myBmp = new Bitmap(path);
            pictureBox1.BackgroundImage = myBmp;
            pictureBox1.BackgroundImageLayout = ImageLayout.Zoom;
            pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
            pictureBox1.Width = myBmp.Width;
            pictureBox1.Height = myBmp.Height;
            pictureBox1.Location = new Point((panel1.Width - myBmp.Width) / 2, (panel1.Height - myBmp.Height) / 2);

        }
        //鼠标滚轮
        private void pictureBox1_MouseWheel(object sender, MouseEventArgs e)
        {
            pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
            Cursor = Cursors.SizeAll;//设置鼠标光标
            int x = e.Location.X;
            int y = e.Location.Y;
            //图片宽度与高度
            int ow = pictureBox1.Width;
            int oh = pictureBox1.Height;
            int vx, vy;
            //放大
            if (e.Delta > 0)
            {
                //超过最大缩放比例
                if (Math.Ceiling((double)pictureBox1.Width / 395) >= 20)
                    return;
                //缩放比例
                pictureBox1.Width =(int) (pictureBox1.Width * zoomStep);
                pictureBox1.Height=(int)(pictureBox1.Height * zoomStep);
                //去除黑色背景
                PropertyInfo pInfo = pictureBox1.GetType().GetProperty("ImageRectangle", BindingFlags.Instance |
                 BindingFlags.NonPublic);
                Rectangle rect = (Rectangle)pInfo.GetValue(pictureBox1, null);
                pictureBox1.Width = rect.Width;
                pictureBox1.Height = rect.Height;
            }
            if (e.Delta < 0)
            {
                // 缩小到最小值
                if (pictureBox1.Width < 50 || pictureBox1.Height < 50)
                {
                    return;
                }
                pictureBox1.Width = (int)(pictureBox1.Width / zoomStep);
                pictureBox1.Height = (int)(pictureBox1.Height /zoomStep);
                PropertyInfo pInfo = pictureBox1.GetType().GetProperty("ImageRectangle", BindingFlags.Instance |
                 BindingFlags.NonPublic);
                Rectangle rect = (Rectangle)pInfo.GetValue(pictureBox1, null);
                pictureBox1.Width = rect.Width;
                pictureBox1.Height = rect.Height;
            }
            //移动的位移
            vx = (int)((double)x * (ow - pictureBox1.Width) / ow);
            vy = (int)((double)y * (oh - pictureBox1.Height) / oh);
            pictureBox1.Location = new Point(pictureBox1.Location.X + vx, pictureBox1.Location.Y + vy);
        }
        //移动
        private void pictureBox1_MouseMove(object sender, MouseEventArgs e)
        {
            pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
            if (isMove)
            {
                int x, y;
                int moveX, moveY;
                //计算移动距离
                moveX = Cursor.Position.X - mouseDownPoint.X;
                moveY = Cursor.Position.Y - mouseDownPoint.Y;
                x = pictureBox1.Location.X + moveX;
                y = pictureBox1.Location.Y + moveY;
                pictureBox1.Location = new Point(x, y);
                mouseDownPoint.X = Cursor.Position.X;
                mouseDownPoint.Y = Cursor.Position.Y;

            }
        }
        private void panel1_MouseMove(object sender, MouseEventArgs e)
        {
            panel1.Focus(); //鼠标不在picturebox上时焦点给别的控件，此时无法缩放   
            if (isMove)
            {
                int x, y;   //新的 pictureBox1.Location(x,y)
                int moveX, moveY; //X方向，Y方向移动大小。
                moveX = Cursor.Position.X - mouseDownPoint.X;
                moveY = Cursor.Position.Y - mouseDownPoint.Y;
                x = pictureBox1.Location.X + moveX;
                y = pictureBox1.Location.Y + moveY;
                pictureBox1.Location = new Point(x, y);
                mouseDownPoint.X = Cursor.Position.X;
                mouseDownPoint.Y = Cursor.Position.Y;
            }
        }
        private void panel1_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                //鼠标当前位置
                mouseDownPoint.X = Cursor.Position.X;
                mouseDownPoint.Y = Cursor.Position.Y;
                isMove = true;
                pictureBox1.Focus();
            }
        }
        //图片按下
        private void pictureBox1_MouseDown(object sender, MouseEventArgs e)
        {
            pictureBox1.Focus();
            if (e.Button == MouseButtons.Left)
            {
                //鼠标当前位置
                mouseDownPoint.X = Cursor.Position.X;
                mouseDownPoint.Y = Cursor.Position.Y;
                isMove = true;
                pictureBox1.Focus();
            }
        }
        //鼠标进入
        private void pictureBox1_MouseEnter_1(object sender, EventArgs e)
        {
            string locaUrl = Applicate.LocalConfigData.RoomFileFolderPath + FileName;
            if (!File.Exists(locaUrl))
            {
                //打开下载按钮
                tsmLoca.Visible = true;
            }
            else
            {
                tsmLoca.Visible = false;
            }
        }
        private void pictureBox1_MouseUp(object sender, MouseEventArgs e)
        {
            isMove = false;
            Cursor = Cursors.Default;
        }
        private void panel1_MouseUp(object sender, MouseEventArgs e)
        {
            isMove = false;
            Cursor = Cursors.Default;
        }
        //窗体选中事件
        private void FrmLookImage_SizeChanged(object sender, EventArgs e)
        {
            if (this.WindowState == FormWindowState.Maximized)
            {
                //最大化时所需的操作 
                panel2.Visible = false;
                panel1.Location = new Point(4, 18);
                panel1.Size = new Size(this.Width, this.Height);
            }
            if (this.WindowState == FormWindowState.Normal)
            {
                if (isLocaHeade)
                {
                    panel2.Visible = false;
                }
                else
                {
                    panel2.Visible = true;
                }
                panel1.Location = new Point(4, 74);
                pictureBox1.Location = new Point((panel1.Width - pictureBox1.Width) / 2, (panel1.Height - pictureBox1.Height) / 2);
            }
        }
        private void pictureBox1_MouseLeave(object sender, EventArgs e)
        {
            pictureBox1.MouseWheel += null;
            isMove = false;
            Cursor = Cursors.Default;
        }
        #endregion
        #region 窗体传递过来值
        //群文件图片
        public virtual void ShowImage(List<RoomFileBean> datas, int index)
        {
            pictureBox1.BackgroundImageLayout = ImageLayout.Zoom;
            pictureBox1.SizeMode = PictureBoxSizeMode.AutoSize;
            pboxColle.Visible = false;
            RoomFileBean room = datas[index];
            mIndex = index;
            listRoomFile = datas;
            FileName = datas[index].name;
            pictureBox1_SetImage(datas[index].url);
            pictureBox1.Location = new Point((panel1.Width - pictureBox1.Width) / 2, (panel1.Height - pictureBox1.Height) / 2);
            ChangeLeftRightBtn();
            IfixisteImage();
            //传递参数
            httpUrl = datas[index].url;
        }
        //头像
        
        public virtual void ShowImage(string url)
        {
            if(!Applicate. imageisopen )
            {
                return;
            }
            this.Show();
            Applicate.imageisopen = false;
            Applicate.imagelist.Add(url);
            isLocaHeade = true;
            panel2.Visible = false;
            //等待符
            LodingUtils loding = new LodingUtils();
            loding.parent = pictureBox1;
            loding.size = pictureBox1.Size;
            loding.start();
            string LocadImage = "";
            FileName = FileUtils.GetFileName(url);
            string filePath = Applicate.LocalConfigData.ImageFolderPath + FileName;
            if (!File.Exists(url))
            {
                HttpDownloader.DownloadFile(url, filePath, (path) =>
                 {
                     if (!string.IsNullOrEmpty(path) && File.Exists(path))
                     {
                       SetSizeForm(path);
                         loding.stop();
                     }
                     else
                     {
                         switch (url)
                         {
                             case "ios":
                                 LocadImage = Environment.CurrentDirectory + "\\Resource\\HeadPic\\ic_head_phone.png";
                                 break;
                             case "android":
                                 LocadImage = Environment.CurrentDirectory + "\\Resource\\HeadPic\\ic_head_android.png";
                                 break;
                             case "web":
                                 LocadImage = Environment.CurrentDirectory + "\\Resource\\HeadPic\\ic_head_pc.png";
                                 break;
                             case "mac":
                                 LocadImage = Environment.CurrentDirectory + "\\Resource\\HeadPic\\ic_head_pc.png";
                                 break;
                             case "10000":
                                 LocadImage = Environment.CurrentDirectory + "\\Resource\\HeadPic\\avatar_notice.png";
                                 break;
                             default:
                                 LocadImage = Environment.CurrentDirectory + "\\Resource\\avatar_default.png";
                                 break;
                                 
                         }
                         bool a = File.Exists(LocadImage);
                         SetSizeForm(LocadImage);
                         loding.stop();
                     }
                 });
            }

        }
        //聊天窗体图片
        internal void ShowImageList(List<MessageObject> datas, int index)
        {
            pictureBox1.BackgroundImageLayout = ImageLayout.Zoom;
            pictureBox1.SizeMode = PictureBoxSizeMode.AutoSize;
            pboxColle.Visible = true;
            isMessageObject = true;
            MessageObject message = datas[index];
            //判断文件是否在本地存在
            string url = File.Exists(message.fileName) ? message.fileName : message.content;
            //判断是否为阅后即焚
            if (message.isReadDel == 1)
            {
                mIndex = 0;
                mMessageList = new List<MessageObject>();
                mMessageList.Add(message);//图片添加到集合
                //显示图片
                pictureBox1_SetImage(url, !message.IsMySend());
            }
            else
            {
                mIndex = index;
                mMessageList = datas;
                FileName = message.fileName;
                pictureBox1_SetImage(url);
            }
            pictureBox1.Location = new Point((panel1.Width - pictureBox1.Width) / 2, (panel1.Height - pictureBox1.Height) / 2);
            //左右翻动
            ChangeLeftRightBtn();
            IfixisteImage();
            //传递参数
            httpUrl = datas[index].content;
        }
        /// <summary>
        /// 左右查看
        /// </summary>
        public void ChangeLeftRightBtn()
        {
            if (isMessageObject)
            {
                //显示为一张图片
                if (mMessageList == null || mMessageList.Count < 2)
                {
                    skbtnRight.Image = Resources.UnRight;
                    skbtnLeft.Image = Resources.UnLeft;
                    skbtnRight.Enabled = false;
                    skbtnLeft.Enabled = false;
                    return;
                }
                //显示为第一张图片
                if (mIndex == 0)
                {
                    skbtnLeft.Image = Resources.UnLeft;
                    skbtnLeft.Enabled = false;

                    skbtnRight.Image = Resources.LookRight;
                    skbtnRight.Enabled = true;

                }
                //显示为最后一张图片
                else if (mIndex + 1 == mMessageList.Count)
                {
                    skbtnRight.Image = Resources.UnRight;
                    skbtnRight.Enabled = false;

                    skbtnLeft.Image = Resources.LookLeft;
                    skbtnLeft.Enabled = true;
                }
                //中间的图片
                else
                {
                    skbtnRight.Image = Resources.LookRight;
                    skbtnLeft.Image = Resources.LookLeft;
                    skbtnRight.Enabled = true;
                    skbtnLeft.Enabled = true;
                }
                return;
            }
            if (listRoomFile == null || listRoomFile.Count < 2)
            {
                skbtnRight.Image = Resources.UnRight;
                skbtnLeft.Image = Resources.UnLeft;
                skbtnRight.Enabled = false;
                skbtnLeft.Enabled = false;
                return;
            }
            //显示为第一张图片
            if (mIndex == 0)
            {
                skbtnLeft.Image = Resources.UnLeft;
                skbtnLeft.Enabled = false;

                skbtnRight.Image = Resources.LookRight;
                skbtnRight.Enabled = true;

            }
            else if (mIndex + 1 == listRoomFile.Count)
            {
                skbtnRight.Image = Resources.UnRight;
                skbtnRight.Enabled = false;

                skbtnLeft.Image = Resources.LookLeft;
                skbtnLeft.Enabled = true;
            }
            //中间的图片
            else
            {
                skbtnRight.Image = Resources.LookRight;
                skbtnLeft.Image = Resources.LookLeft;
                skbtnRight.Enabled = true;
                skbtnLeft.Enabled = true;
            }
        }
        #endregion
        #region 右键菜单
        //转发
        private void tsmTranspond_Click(object sender, EventArgs e)
        {
            if (isMessageObject)
            {
                MessageObject message = mMessageList[mIndex];
                fielSize = message.fileSize.ToString();
            }
            string url = mImages[mIndex];
            //服务器地址
            string path = httpUrl;
            //文件大小
            string size = fielSize.Substring(0, fielSize.Length - 1);
            //调用好友选择器
            var frmFriend = new FrmFriendSelect();
            //数据加载
            frmFriend.LoadFriendsData();
            frmFriend.AddConfrmListener((userLiser) =>
            {
                //添加
                foreach (var item in userLiser)
                {
                    //调研xmpp
                    ShiKuManager.SendFileMessage(item.Value, path, url, Convert.ToInt32(size));
                }
                //打开主窗体
                var frmMain = new FrmMain();
                //        frmMain.Show();
            });

        }
        //删除
        private void tsmDelete_Click(object sender, EventArgs e)
        {
            //获取当前的索引
            string url = mImages[mIndex];
            //删除
            mImages.RemoveAt(mIndex);
            if (mIndex > mImages.Count - 1)
            {
                mIndex--;
            }
            ////mIndex--;
            if (mImages.Count == 0)
            {
                this.Close();
                return;
            }
            //显示图片
            pictureBox1_SetImage(mImages[mIndex]);

        }
        //收藏
        private void tsmCollect_Click(object sender, EventArgs e)
        {
            if (isMessageObject)
            {
                MessageObject msg = mMessageList[mIndex];
                CollectUtils.CollectMessage(msg);
            }
        }
        //另存为
        private void tsmSave_Click(object sender, EventArgs e)
        {
            //获取地址
            string url = mImages[mIndex];
            string path = "";
            string filePath = "";
            string name = Path.GetFileName(url);
            //打开页面
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            if (dialog.ShowDialog() == DialogResult.OK)
            {
                if (!File.Exists(url))
                {
                    filePath = Applicate.LocalConfigData.RoomFileFolderPath + FileName;
                    FileInfo fileInfo = new FileInfo(filePath);
                    //获取用户当前选中的路径
                    path = dialog.SelectedPath + "\\" + name;
                    DownFile(path, url);
                }
                else
                {
                    filePath = FileName;
                    FileInfo fileInfo = new FileInfo(url);
                    //获取用户当前选中的路径
                    path = dialog.SelectedPath + "\\" + name;
                    fileInfo.CopyTo(path, true);

                }
            }
        }
        /// <summary>
        /// 下载
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmLoca_Click(object sender, EventArgs e)
        {
            string url = mImages[mIndex];
            //下载地址
            string name = FileUtils.GetFileName(url);
            string locaUrl = Applicate.LocalConfigData.RoomFileFolderPath + name;
            //不存在去下载
            if (!File.Exists(url))
            {
                //下载
                DownFile(locaUrl, url);
            }
            //存在本地就copy过去
            else
            {
                string filePath = Applicate.LocalConfigData.RoomFileFolderPath + name;
                FileInfo fileInfo = new FileInfo(url);
                fileInfo.CopyTo(filePath, true);
                tsmLoca.Visible = false;
            }
            SendDownFileCompt(url);
        }
        #endregion 
        #region 验证
        /// <summary>
        /// 文件是否存在
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        private bool IsFileExists(string name)
        {
            // 判断下载地址是否有这个文件
            string filePath = Applicate.LocalConfigData.RoomFileFolderPath + name;
            return File.Exists(filePath);
        }
        /// <summary>
        /// 文件下载
        /// </summary>
        /// <param name="toFilePath"></param>
        /// <param name="fileUrl"></param>
        private void DownFile(string toFilePath, string fileUrl)
        {
            HttpDownloader.DownloadFile(fileUrl, toFilePath, (path) =>
            {
                if (!string.IsNullOrEmpty(path))
                {
                    FileName = path;
                    // 下载成功
                   LogUtils.Log("下载成功！" + path);

                }
            });
        }

        private void SendDownFileCompt(string url)
        {
            Messenger.Default.Send(url, MessageActions.FILE_DOWN_COMPT);//更新UI送达标志 消息已发送成功
        }
        #endregion
        #region 提示
        private void pboxZhuan_MouseEnter(object sender, EventArgs e)
        {
            string msg = "转发";
            toolTip1.SetToolTip(pboxZhuan, msg);
        }
        //另存为
        private void pboxFile_MouseEnter(object sender, EventArgs e)
        {
            string msg = "另存为";
            toolTip1.SetToolTip(pboxFile, msg);
        }
        //收藏
        private void pboxColle_MouseEnter(object sender, EventArgs e)
        {
            string msg = "收藏";
            toolTip1.SetToolTip(pboxColle, msg);
        }
        private void pboxMax_MouseEnter(object sender, EventArgs e)
        {
            string msg = "最大化";
            toolTip1.SetToolTip(pboxMax, msg);
        }
        private void skbtnLeft_MouseEnter(object sender, EventArgs e)
        {
            string msg = "上一张";
            toolTip1.SetToolTip(skbtnLeft, msg);
        }

        private void skbtnRight_MouseEnter(object sender, EventArgs e)
        {
            string msg = "下一张";
            toolTip1.SetToolTip(skbtnRight, msg);
        }
        //放大
        private void pobxMagnify_MouseEnter(object sender, EventArgs e)
        {
            string msg = "放大";
            toolTip1.SetToolTip(pobxMagnify, msg);
        }
        //缩小
        private void pboxShrink_MouseEnter(object sender, EventArgs e)
        {
            string msg = "缩小";
            toolTip1.SetToolTip(pboxShrink, msg);
        }
        //下载
        private void pboxDown_MouseEnter(object sender, EventArgs e)
        {
            string msg = "下载";
            toolTip1.SetToolTip(pboxDown, msg);
        }
        private void pboxOpenFile_MouseEnter(object sender, EventArgs e)
        {
            string str = "打开";
            toolTip1.SetToolTip(pboxOpenFile, str);
        }

        #endregion
        #region  图标功能
        /// <summary>
        /// 下载
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxDown_Click(object sender, EventArgs e)
        {
            string url = "";
            string name = "";
            if (isMessageObject)
            {
                url = File.Exists(mMessageList[mIndex].fileName) ? mMessageList[mIndex].fileName : mMessageList[mIndex].content;
                name = FileUtils.GetFileName(url);
            }
            else
            {
                url = listRoomFile[mIndex].url;
                name = listRoomFile[mIndex].name;
            }
            //下载地址
            FileName = Applicate.LocalConfigData.RoomFileFolderPath + name;
            //不存在去下载
            if (!File.Exists(url))
            {
                //下载
                DownFile(FileName, url);
            }
            //存在本地就copy过去
            else
            {
                FileName = Applicate.LocalConfigData.RoomFileFolderPath + name;
                FileInfo fileInfo = new FileInfo(url);
                fileInfo.CopyTo(FileName, true);
            }
            SendDownFileCompt(FileName);
            HttpUtils.Instance.ShowTip("下载成功");
            pboxOpenFile.Visible = true;
            pboxDown.Visible = false;
            pboxOpenFile.Location = pboxDown.Location;
        }
        /// <summary>
        /// 转发
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxZhuan_Click(object sender, EventArgs e)
        {
            string url = "";
            string path = "";
            if (isMessageObject)
            {
                MessageObject message = mMessageList[mIndex];
                fielSize = message.fileSize.ToString();
                url = mMessageList[mIndex].content;
                path = mMessageList[mIndex].fileName;
            }
            else
            {
                fielSize = listRoomFile[mIndex].size.ToString();
                url = listRoomFile[mIndex].url;
                path = Applicate.LocalConfigData.ImageFolderPath + listRoomFile[mIndex].name;
            }
            string size = fielSize;
            //调用好友选择器
            var frmFriend = new FrmFriendSelect();
            //数据加载
            frmFriend.LoadFriendsData();
            frmFriend.AddConfrmListener((userLiser) =>
            {
                //添加
                foreach (var item in userLiser)
                {
                    //调研xmpp
                    MessageObject messImg= ShiKuManager.SendImageMessage(item.Value, url, path, Convert.ToInt32(size));
                    Messenger.Default.Send(messImg, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                }
            });
        }
        //另存为
        private void pboxFile_Click(object sender, EventArgs e)
        {
            string url = "";
            string path = "";
            string filePath = "";
            string name = "";
            if (isMessageObject)
            {
                //获取地址
                url = File.Exists(mMessageList[mIndex].fileName) ? mMessageList[mIndex].fileName : mMessageList[mIndex].content;
                name = Path.GetFileName(url);
            }
            else
            {
                url = listRoomFile[mIndex].url;
                name = listRoomFile[mIndex].name;
            }
            //打开页面
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            if (dialog.ShowDialog() == DialogResult.OK)
            {
                if (!File.Exists(url))
                {
                    filePath = Applicate.LocalConfigData.RoomFileFolderPath + FileName;
                    FileInfo fileInfo = new FileInfo(filePath);
                    //获取用户当前选中的路径
                    path = dialog.SelectedPath + "\\" + name;
                    DownFile(path, url);
                }
                else
                {
                    filePath = FileName;
                    FileInfo fileInfo = new FileInfo(url);
                    //获取用户当前选中的路径
                    path = dialog.SelectedPath + "\\" + name;
                    fileInfo.CopyTo(path, true);

                }
                HttpUtils.Instance.ShowTip("保存成功");
            }
        }
        /// <summary>
        /// 收藏
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxColle_Click(object sender, EventArgs e)
        {
            if (isMessageObject)
            {
                MessageObject msg = mMessageList[mIndex];
                CollectUtils.CollectMessage(msg);
            }
        }
        /// <summary>
        /// 最大化
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxMax_Click(object sender, EventArgs e)
        {
            FrmMaxLookImage frm = new FrmMaxLookImage();
            frm.Pictbix_Image(httpUrl);
            frm.Show();

        }
        //左移动
        private void skbtnLeft_Click_1(object sender, EventArgs e)
        {
            if (isMessageObject)
            {
                ShowImageList(mMessageList, --mIndex);
            }
            else
            {
                ShowImage(listRoomFile, --mIndex);
            }
            IfixisteImage();
        }
        //右边移动
        private void skbtnRight_Click_1(object sender, EventArgs e)
        {

            if (isMessageObject)
            {
                ShowImageList(mMessageList, ++mIndex);
            }
            else
            {
                ShowImage(listRoomFile, ++mIndex);
            }
            IfixisteImage();
        }
        //首次按下
        private void FrmLookImage_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)27)
            {
                this.WindowState = FormWindowState.Normal;
                if (isLocaHeade)
                {
                    panel2.Visible = false;
                    this.ControlBox = true;
                }
                else
                {
                    panel2.Visible = true;
                }
                panel1.Location = new Point(4, 74);
                panel1.Size = new Size(this.Width, this.Height);
                pictureBox1.Location = new Point((panel1.Width - pictureBox1.Width) / 2, (panel1.Height - pictureBox1.Height) / 2);
            }
        }
        //按下时发生的事件
        private void FrmLookImage_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Left)
            {
                if (mIndex == 0)
                {
                    return;
                }
                skbtnLeft_Click_1(sender, e);
            }
             if (e.KeyCode == Keys.Right)
            {
                if (isMessageObject)
                {
                    if (mIndex + 1 == mMessageList.Count)
                    {
                        return;
                    }
                    skbtnRight_Click_1(sender, e);
                    return;
                }
                if (mIndex + 1 == listRoomFile.Count)
                {
                    skbtnRight_Click_1(sender, e);
                    return;
                }
           
            }
            if (this.WindowState == FormWindowState.Normal)
            {
                if (e.KeyCode == Keys.Escape)
                    this.Close();
            }
        }
        //放大
        private void pobxMagnify_Click(object sender, EventArgs e)
        {
            pictureBox1.Size = new Size(pictureBox1.Width + 150, pictureBox1.Height + 150);
            pictureBox1.Location = new System.Drawing.Point((panel1.Width - pictureBox1.Width) / 2, (panel1.Height - pictureBox1.Height) / 2);
        }
        //缩小
        private void pboxShrink_Click(object sender, EventArgs e)
        {
            // 缩小到最小值
            if (pictureBox1.Width < 50 || pictureBox1.Height < 50)
            {
                return;
            }
            pictureBox1.Size = new Size(pictureBox1.Width - 150, pictureBox1.Height - 150);
            pictureBox1.Location = new System.Drawing.Point((panel1.Width - pictureBox1.Width) / 2, (panel1.Height - pictureBox1.Height) / 2);
        }
        //打开
        private void pboxOpenFile_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFile = new OpenFileDialog();
            openFile.InitialDirectory = Applicate.LocalConfigData.RoomFileFolderPath;
            if (openFile.ShowDialog() == DialogResult.OK)
            {
                FileName = openFile.FileName;
                System.Diagnostics.Process.Start(FileName);
            }

        }
        #endregion

        private void FrmLookImage_FormClosing(object sender, FormClosingEventArgs e)
        {
            Applicate.imageisopen = true;
        }
    }
}
