using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Security.Permissions;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using agsXMPP.protocol.iq.vcard;
using CefSharp;
using CefSharp.WinForms;
using WinFrmTalk.Helper;
using WinFrmTalk.Model;

namespace WinFrmTalk.View
{
    [PermissionSet(SecurityAction.Demand, Name = "FullTrust")]
    [System.Runtime.InteropServices.ComVisibleAttribute(true)]
    public partial class FrmBrowser : FrmBase
    {
        #region 全局变量
        private ChromiumWebBrowser webView;
        private bool isMessobject;
        private MessageObject messageList;
        public static string Url;
        //默认浏览器
        public readonly string Default = "http://www.google.com/";
        private static readonly bool DebuggingSub = Debugger.IsAttached;
        //验证窗体被动打开事件
        public static bool isInitSet;
        //经纬度
        public double Longitude;
        private double Latitude;
        private string Locadpath;
        private bool isMapLocation;

        public string Userid { get; private set; }
        #endregion
        #region 窗体加载
        public FrmBrowser()
        {
            InitializeComponent();

        }
        private void FrmBrowser_Load(object sender, EventArgs e)
        {
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
        }

        #endregion
        #region 浏览器配置
        public static void Init()
        {
            //默认为true
            isInitSet = true;
            var setting = new CefSettings();
            //端口号
            setting.RemoteDebuggingPort = 8080;
            //语言
            setting.Locale = "zh-CN";
            setting.AcceptLanguageList = "zh-CN";
            //开启音视频
            setting.CefCommandLineArgs.Add("enable-media-stream", "enable-media-stream");
            // setting.CefCommandLineArgs.Add("enable-speech-input", "enable-speech-input");
            //验证书
            setting.IgnoreCertificateErrors = true;
            //日志
            setting.LogSeverity = CefSharp.LogSeverity.Verbose;
            if (!Cef.Initialize(setting))
            {
                if (Environment.GetCommandLineArgs().Contains("--type=renderer"))
                {
                    Environment.Exit(0);
                }
                else
                {
                    return;
                }
            }
        }
        #endregion
        #region 窗体传递
        /// <summary>
        /// 初始化加载
        /// </summary>
        /// <param name="url"></param>
        public void BrowserShow(MessageObject message)
        {
            isMessobject = true;
            messageList = message;
            if (message.type == kWCMessageType.Location)
            {
                isMapLocation = true;
                pboxcollect.Visible = false;
                Url = "https://www.shiku.co/BaiDuMap.html?Longitude=" + message.location_y + "&Latitude=" + message.location_x + "";
            }
            else
            {
                isMapLocation = false;
                Url = message.content;
            }
            BrowsserSetting();
        }
        private void BrowsserSetting()
        {
            Control.CheckForIllegalCrossThreadCalls = false;
            webView = new CefSharp.WinForms.ChromiumWebBrowser(Url);
            panel1.Controls.Add(webView);
            //窗体完毕
            webView.FrameLoadEnd += (hhh, kkk) =>
            {
                timer.Stop();
            };
            //窗体加载
            webView.LoadingStateChanged += (hhh, kkk) =>
            {
                timer.Start();
            };
            Font font = new Font("宋体", 20.5f);
            webView.Dock = DockStyle.Fill;
            webView.Font = font;
            webView.LifeSpanHandler = new OpenPageSelf();
            panel1.Controls.Add(webView);
            //选择事件
            webView.AddressChanged += ((hhh, kkk) =>
            {
                //当前页面的Url
                Url = webView.Address;
               LogUtils.Log(webView.Address);
                timer.Start();
            });
            this.Show();
        }
        //打开链接
        public void OpenUrl(string url,string userid)
        {
            isMessobject = false;
            Url = url;
            Userid = userid;
            BrowsserSetting();
        }
        #region 地图
        public void initCefSharp()
        {
            string path = Environment.CurrentDirectory + "\\BaiDuMap.html";
            webView = new ChromiumWebBrowser(path);
            Locadpath = path;
            Url = path;
            webView.Dock = DockStyle.Fill;
            panel1.Controls.Add(webView);
          
        }

        public void ShowMap(double longitude, double latitude)
        {
            initCefSharp();
            Longitude = longitude;
            Latitude = latitude;
            this.Show();
        }
        #endregion
        #endregion
        #region 同窗体新链接
        /// <summary>
        /// 在自己窗口打开链接
        /// </summary>
        internal class OpenPageSelf : ILifeSpanHandler
        {
            public bool DoClose(IWebBrowser browserControl, IBrowser browser)
            {
                return false;
            }

            public void OnAfterCreated(IWebBrowser browserControl, IBrowser browser)
            {

            }

            public void OnBeforeClose(IWebBrowser browserControl, IBrowser browser)
            {

            }

            public bool OnBeforePopup(IWebBrowser browserControl, IBrowser browser, IFrame frame, string targetUrl,
    string targetFrameName, WindowOpenDisposition targetDisposition, bool userGesture, IPopupFeatures popupFeatures,
    IWindowInfo windowInfo, IBrowserSettings browserSettings, ref bool noJavascriptAccess, out IWebBrowser newBrowser)
            {
                newBrowser = null;
                var chromiumWebBrowser = (ChromiumWebBrowser)browserControl;
                chromiumWebBrowser.Load(targetUrl);
                return true; //Return true to cancel the popup creation copyright by codebye.com.
            }
        }
        #endregion
        #region 图标功能
        /// <summary>
        /// 进度条
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void timer_Tick(object sender, EventArgs e)
        {
            if (progressBrows.Value < progressBrows.Maximum)
            {
                progressBrows.Value++;
            }
            else
            {
                progressBrows.Value = 0;
                timer.Stop();
            }
        }
        /// <summary>
        /// 刷新
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxrefresh_Click(object sender, EventArgs e)
        {
            webView.Load(Url);
        }
        /// <summary>
        /// 返回
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>

        private void pboxBack_Click_1(object sender, EventArgs e)
        {
            webView.Back();
        }
        /// <summary>
        /// 复制
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxCopy_Click(object sender, EventArgs e)
        {
            //获取当前的链接
            //清空剪切板，防止里面之前有内容
            Clipboard.Clear();
            //给剪切板设置图片对象
            Clipboard.SetText(Url);
            HttpUtils.Instance.ShowTip("复制成功");
        }
        /// <summary>
        /// 默认系统浏览器打开
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxOpen_Click(object sender, EventArgs e)
        {
            //系统默认浏览器
            System.Diagnostics.Process.Start(Url);
        }
        /// <summary>
        /// 转发
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxZhuang_Click(object sender, EventArgs e)
        {
            //打开好友选择器
            var frm = new FrmFriendSelect();
            frm.LoadFriendsData();
            frm.AddConfrmListener((UserData) =>
            {
                foreach (var item in UserData)
                {
                    if (isMessobject)
                    {
                        MessageObject msg = messageList.CopyMessage();
                        if (!isMapLocation)
                        {
                          
                            msg.content = Url;
                            messageList = msg;
                        }
                        //调用xmpp
                      MessageObject messImgs=ShiKuManager.SendForwardMessage(item.Value, messageList);
                        Messenger.Default.Send(messImgs, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                        return;
                    }
                    MessageObject messImg = ShiKuManager.SendTextMessage(item.Value, Url);
                    Messenger.Default.Send(messImg, token: MessageActions.XMPP_UPDATE_NORMAL_MESSAGE);
                }
            });
        }
        /// <summary>
        /// 收藏
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pboxcollect_Click(object sender, EventArgs e)
        {
            if (!isMessobject)
            {
                CollectUtils.CollectLink(Url,Userid);
                return;
            }
            CollectUtils.CollectMessage(messageList);
        }
        #endregion
        #region 图标提示
        private void pboxCopy_MouseEnter(object sender, EventArgs e)
        {
            string str = "复制链接地址";
            toolTip1.SetToolTip(pboxCopy, str);
        }

        private void pboxrefresh_MouseEnter(object sender, EventArgs e)
        {
            string str = "刷新";
            toolTip1.SetToolTip(pboxrefresh, str);
        }

        private void pboxOpen_MouseEnter(object sender, EventArgs e)
        {
            string str = "用默认浏览器打开";
            toolTip1.SetToolTip(pboxOpen, str);
        }

        private void pboxZhuang_MouseEnter(object sender, EventArgs e)
        {
            string str = "转发";
            toolTip1.SetToolTip(pboxZhuang, str);
        }

        private void pboxcollect_MouseEnter(object sender, EventArgs e)
        {
            string str = "收藏";
            toolTip1.SetToolTip(pboxcollect, str);
        }
        #endregion
        #region 窗体关闭
        /// <summary>
        /// 释放资源
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrmBrowser_FormClosed(object sender, FormClosedEventArgs e)
        {
            //释放
            this.Dispose();
        }
        #endregion

    }
}
