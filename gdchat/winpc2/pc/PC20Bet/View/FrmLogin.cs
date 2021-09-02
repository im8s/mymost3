
namespace WinFrmTalk
{
    using Newtonsoft.Json;
    using PBMessage;

    using System;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Configuration;
    using System.Diagnostics;
    using System.Drawing;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Threading;
    using System.Windows.Forms;

    using WinFrmTalk.Dictionarys;
    using WinFrmTalk.View;
    using WinFrmTalk.secure;


    /// <summary>
    /// 登录窗口
    /// </summary>
    public partial class FrmLogin : FrmBase
    {
        private bool isEnter;

        private delegate void DelegateString(string msg);

        private bool isUpdateConfig;

        public FrmBetMain BetMainForm { get; set; }
        
        public FrmLogin()
        {
            InitializeComponent();

            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标

            Messenger.Default.Register<string>(this, MessageActions.UPDATE_CONFIG, item => NeedUpdateConfig(item));
            Messenger.Default.Register<string>(this, MessageActions.SHOW_LOGINFORM, item => OnRecvShow(item));
            GetHttpConfig();
            picServer.Visible = Applicate.ToggleService;
        }
        
        public override void OnResume()
        {
            base.OnResume();

            if (isUpdateConfig)
            {
                GetHttpConfig();
            }
        }

        /// <summary>
        /// 是否需要更新config接口
        /// </summary>
        private void NeedUpdateConfig(string str)
        {
            isUpdateConfig = true;
        }

        /// <summary>
        /// 显示登陆窗口，从注册，忘记密码返回登陆窗口事件
        /// </summary>
        private void OnRecvShow(string str)
        {
            if (Thread.CurrentThread.IsBackground)
            {
                var main = new DelegateString(OnRecvShow);
                Invoke(main, str);
                return;
            }

            isUpdateConfig = false;
            this.Show();

            if ("regist_success".Equals(str))
            {
                ShowTip("注册成功");

                if (!string.IsNullOrEmpty(Applicate.MyAccount.areaCode))
                {
                    lblContry.Text = "+" + Applicate.MyAccount.areaCode;
                }

                txtTelephone.Text = Applicate.MyAccount.Telephone;
                txtPassword.Text = Applicate.MyAccount.password;
                chkRememberPwd.Checked = true;

                return;
            }

            if ("reset_success".Equals(str))
            {
                ShowTip("找回密码成功");
                return;
            }

            if ("regist_err".Equals(str))
            {
                ShowTip("注册失败");
                return;
            }
        }

        /// <summary>
        /// 获取配置
        /// </summary>
        private void GetHttpConfig()
        {
            if (!UIUtils.GetDotNetVersion(Applicate.CURRET_VERSION.ToString()))
            {
                ShowTip("当前 windows 缺少.net 运行库，不能运行此版本，请前往官网下载新版本");
                return;
            }

            isUpdateConfig = false;

            var url = UIUtils.GetServer();

            HttpUtils.Instance.Get().Url(url).Build()
                .AddErrorListener((code, msg) =>
                {
                    ShowTip("服务器设置错误，请重新设置");

                    Applicate.URLDATA = new JsonConfigData();
                    Applicate.URLDATA.data = Applicate.GetDefConfig();
                    btnLogin.Enabled = true; //完成获取配置后启用登录按钮
                    btnLogin.ForeColor = Color.White;
                    isEnter = true;
                    lblRegister.Enabled = true;
                    btnForgetPwd.Enabled = true;

                    // 用户名登录
                    if (Applicate.URLDATA.data.regeditPhoneOrName == 1)
                    {
                        lblContry.Visible = false;
                        txtTelephone.Size = txtPassword.Size;
                        panel2.Size = panel3.Size;
                        panel2.Location = new Point(86, 196);
                        txtTelephone.Location = new Point(86, 177);
                    }

                    if (Applicate.URLDATA.data.regeditPhoneOrName == 0)
                    {
                        lblContry.Visible = true;
                        txtTelephone.Size = new Size(111, 16);
                        panel2.Size = new Size(111, 1);
                        panel2.Location = new Point(153, 196);
                        txtTelephone.Location = new Point(153, 177);
                    }
                })
                .ExecuteJson<ConfigData>((resultstatu, config) =>
                {
                    if (resultstatu)
                    {
                        Applicate.URLDATA = new JsonConfigData();
                        Applicate.URLDATA.data = config;

                        LogUtils.Log("配置获取成功   " + Applicate.URLDATA.data.apiUrl);

                        btnLogin.Enabled = true; //完成获取配置后启用登录按钮
                        btnLogin.ForeColor = Color.White;
                        isEnter = true;
                        lblRegister.Enabled = true;
                        btnForgetPwd.Enabled = true;

                        //用户名登录
                        if (Applicate.URLDATA.data.regeditPhoneOrName == 1)
                        {
                            lblContry.Visible = false;
                            txtTelephone.Size = txtPassword.Size;
                            panel2.Size = panel3.Size;
                            panel2.Location = new Point(86, 196);
                            txtTelephone.Location = new Point(86, 177);
                        }
                        if (Applicate.URLDATA.data.regeditPhoneOrName == 0)
                        {
                            lblContry.Visible = true;
                            txtTelephone.Size = new Size(111, 16);
                            panel2.Size = new Size(111, 1);
                            panel2.Location = new Point(153, 196);
                            txtTelephone.Location = new Point(153, 177);
                        }
                        if (!string.IsNullOrEmpty(config.pcVersion))
                        {
                            //检测更新
                            if (string.IsNullOrEmpty(config.pcVersion) && Applicate.APP_VERSION.Replace(".", "") != config.pcVersion && string.IsNullOrEmpty(Applicate.URLDATA.data.pcAppUrl) &&
                                MessageBox.Show("有新的版本是否需要进行更新", "系统更新", MessageBoxButtons.YesNo) == DialogResult.Yes)
                            {
                                File.Delete("Download.config");
                                FileStream fsWrite = new FileStream("Download.config", FileMode.OpenOrCreate);
                                byte[] buffer = Encoding.Default.GetBytes(config.pcAppUrl);
                                fsWrite.Write(buffer, 0, buffer.Length);
                                fsWrite.Close();
                                string path = Environment.CurrentDirectory;
                                Process process = new Process();
                                process.StartInfo.FileName = "update.exe";
                                process.StartInfo.WorkingDirectory = path; //要掉用得exe路径例如:"C:\windows";               
                                process.StartInfo.CreateNoWindow = true;
                                process.Start();
                                Application.Exit();
                            }
                        }
                    }
                });
        }

        #region 窗口加载事件
        private void FrmLogin_Load(object sender, EventArgs e)
        {
            ShowUserAccess();

            if (string.IsNullOrEmpty(txtTelephone.Text))
            {
                this.ActiveControl = this.txtTelephone;// 获取输入账号焦点
                txtTelephone.Select(txtTelephone.TextLength, 0);
            }
            else if (string.IsNullOrEmpty(txtPassword.Text))
            {
                this.ActiveControl = txtPassword; // 获取输入密码焦点
                txtPassword.Select(txtPassword.TextLength, 0);
            }
            else
            {
                this.ActiveControl = txtPassword;
            }
            txtPassword.Select(txtPassword.TextLength, 0);

            if (Applicate.URLDATA.data.apiUrl != null)
            {
                btnLogin.Enabled = true;//完成获取配置后启用登录按钮
                isEnter = true;
                lblRegister.Enabled = true;
                btnForgetPwd.Enabled = true;
            }

            EmojiCodeDictionary.GetEmojiDataNotMine();//延时操作
        }
        #endregion

        #region 加载字体图标
        /// <summary>
        /// 加载字体图标
        /// </summary>
        private void LoadIconFonts()
        {
            var iconfont = Program.ApplicationFontCollection.Families.Last();
            lbliconAccount.Font = new Font(iconfont, 15f);
            lbliconPassword.Font = new Font(iconfont, 15f);
        }
        #endregion

        #region 登录按钮点击

        private void btnLogin_Click(object sender, EventArgs e)
        {
            if (!UIUtils.GetDotNetVersion(Applicate.CURRET_VERSION.ToString()))
            {
                ShowTip("当前 windows 缺少.net 运行库，程序不能运行");
                return;
            }

            if (!isEnter)
            {
                ShowTip("获取配置信息失败，请联系管理员");
                return;
            }

            //if (Math.Abs(TimeUtils.SyncTimeDiff()) > 10)
            //{
            //    ShowTip("本地时间和服务器时间差异过大，请联系管理员");
            //    return;
            //}

            if (string.IsNullOrEmpty(txtTelephone.Text))
            {
                ShowTip("账号不能为空");
                return;
            }

            if (string.IsNullOrEmpty(txtPassword.Text))
            {
                ShowTip("密码不能为空");
                return;
            }

            btnLogin.Visible = false;
            lblRegister.Visible = false;

            // 显示等待符
            OpenLoading();

            // 启用新版登陆加固系统
            RequestLoginCode();
        }

        #region 请求登录码

        private void RequestLoginCode()
        {
            string password = txtPassword.Text.Trim();
            string account = txtTelephone.Text.Trim();

            string areaCode = lblContry.Text.ToString().Remove(0, 1);
            string salt = TimeUtils.CurrentTimeMillis().ToString();

            string hexpwd = SkSSLUtils.CiphertextPwd(password);
            string mac = MAC.EncodeBase64((Applicate.API_KEY + areaCode + account + salt), hexpwd);

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "auth/getLoginCode")
                .AddParams("areaCode", areaCode)
                .AddParams("account", account)
                .AddParams("mac", mac)
                .AddParams("salt", salt)
                .AddParams("deviceId", "pc")
                .Build(true).AddErrorListener((code, msg) =>
                {
                    Console.WriteLine("获取code失败");
                    loding.stop();
                    btnLogin.Visible = true;
                    lblRegister.Visible = true;

                }).Execute((sccess, data) =>
                {
                    if (sccess)
                    {
                        // 能走到这里说明登陆账号和密码都没问题
                        string loginuser = UIUtils.DecodeString(data, "userId");

                        string code = UIUtils.DecodeString(data, "code");
                        if (UIUtils.IsNull(code))
                        {
                            UpLoadRsaKeypair(loginuser);
                        }
                        else
                        {
                            RequestCodePrivateKey(code, loginuser);
                        }
                    }
                    else
                    {
                        Console.WriteLine("获取code失败");
                        loding.stop();
                        btnLogin.Visible = true;
                        lblRegister.Visible = true;
                    }
                });
        }

        // 服务器没有登陆code需要上传一对
        private void UpLoadRsaKeypair(string userId)
        {
            string password = txtPassword.Text.Trim();

            string hexpwd = SkSSLUtils.CiphertextPwd(password);
            byte[] obviouspwd = SkSSLUtils.ObviousPwd(password);

            string salt = TimeUtils.CurrentTimeMillis().ToString();

            var rsaKeyPair = RSA.CreateRsaKey();

            string encryptedPrivateKeyBase64 = AES.EncryptBase64(rsaKeyPair.PrivateKey, obviouspwd);
            string publicKeyBase64 = rsaKeyPair.ToPublicString();
            string macContent = (Applicate.API_KEY + userId + encryptedPrivateKeyBase64 + publicKeyBase64 + salt);

            string mac = MAC.EncodeBase64(macContent, hexpwd);

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "authkeys/uploadLoginKey")
                .AddParams("userId", userId)
                .AddParams("publicKey", publicKeyBase64)
                .AddParams("privateKey", encryptedPrivateKeyBase64)
                .AddParams("salt", salt)
                .AddParams("mac", mac)
                .Build(true).AddErrorListener((code, msg) =>
                {
                    Console.WriteLine("获取code失败");

                }).Execute((sccess, data) =>
                {
                    if (sccess)
                    {
                        // 重新去请求
                        RequestLoginCode();
                    }
                    else
                    {
                        Console.WriteLine("获取code失败");
                    }
                });
        }
        #endregion

        #region 请求登录码私钥
        private void RequestCodePrivateKey(string encryptCode, string userId)
        {
            string password = txtPassword.Text.Trim();
            string salt = TimeUtils.CurrentTimeMillis().ToString();
            string hexpwd = SkSSLUtils.CiphertextPwd(password);
            string mac = MAC.EncodeBase64((Applicate.API_KEY + userId + salt), hexpwd);

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "authkeys/getLoginPrivateKey")
                .AddParams("userId", userId)
                .AddParams("mac", mac)
                .AddParams("salt", salt)
                .Build(true).AddErrorListener((code, msg) =>
                {
                    Console.WriteLine("失败");

                }).Execute((sccess, data) =>
                {
                    if (sccess)
                    {
                        string aeskey = UIUtils.DecodeString(data, "privateKey");

                        // 解密code
                        byte[] logincode;
                        try
                        {
                            byte[] obviouspwd = SkSSLUtils.ObviousPwd(password);
                            byte[] privatekey = AES.DecryptBase64(aeskey, obviouspwd);
                            logincode = RSA.DecryptFromBase64Pk1(encryptCode, privatekey);
                        }
                        catch (Exception)
                        {
                            logincode = null;
                            Console.WriteLine("解密失败");
                            return;
                        }

                        RequestLoginChat(logincode, userId);
                    }
                    else
                    {

                    }
                });

        }
        #endregion

        #region 登录码私钥登陆系统

        public void RequestLoginChat(byte[] logincode, string userId)
        {
            string password = txtPassword.Text.Trim();
            string salt = TimeUtils.CurrentTimeMillis().ToString();
            string hexpwd = SkSSLUtils.CiphertextPwd(password);

            Dictionary<string, string> pairs = new Dictionary<string, string>();
            pairs.Add("latitude", "0");
            pairs.Add("longitude", "0");
            pairs.Add("model", UIUtils.Getpcid());
            pairs.Add("xmppVersion", "1");

            // 组合验参
            string mac = MAC.EncodeBase64((Applicate.API_KEY + userId + Parameter.JoinValues(pairs) + salt + hexpwd), logincode);

            // aes 加密
            pairs.Add("mac", mac);
            string content = JsonConvert.SerializeObject(pairs);
            string data = AES.EncryptBase64(content, logincode);


            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/login/v1")
               .AddParams("deviceId", "pc")
               .AddParams("data", data)
               .AddParams("userId", userId)
               .AddParams("salt", salt)
               .Build(true).AddErrorListener((code, msg) =>
               {
                   Console.WriteLine("失败");

               }).Execute((sccess, resultdata) =>
               {
                   if (sccess)
                   {
                       content = UIUtils.DecodeString(resultdata, "data");
                       string result = AES.NewString(AES.DecryptBase64(content, logincode));

                       if (!UIUtils.IsNull(result))
                       {
                           // 解密成功
                           var userinfo = JsonConvert.DeserializeObject<UserInfo>(result);

                           Applicate.InitAccountData(userinfo, txtTelephone.Text, txtPassword.Text, true);
                           string areaCode = lblContry.Text.ToString().Remove(0, 1);
                           Applicate.MyAccount.areaCode = areaCode;

                           SaveAccountInfo();

                           if (userinfo.isupdate == 1 || IsNeedUpdateData(Applicate.MyAccount.userId))
                           {
                               login_tip.Visible = true;
                               // 调用数据下载，去同步我的好友和群组
                               SyncDataDownlad download = new SyncDataDownlad();
                               download.StartDown((success) =>
                               {
                                   // 同步完成, 跳转到主界面
                               
                                   login_tip.Visible = false;
                                   LogUtils.Log("数据同步完成 跳转到主界面");
                               });
                           }
                          
                           {
                               loding.stop();
                               //JumpMainUI();
                               this.Close();

                               this.BetMainForm.JumpMainUI();
                           }
                       }

                       Console.WriteLine("登录成功" + result);
                   }
                   else
                   {

                   }
               });

        }

        #endregion

        /// <summary>
        /// 是否需要更新账号数据
        /// </summary>
        private bool IsNeedUpdateData(string userId)
        {
            // 用户数据库所在位置
            string dbPaht = Environment.CurrentDirectory + "\\db\\" + userId + ".db";
            if (!File.Exists(dbPaht))
            {
                return true;
            }

            // 保存用户退出时间
            string quitTime = LocalDataUtils.GetStringData(Applicate.QUIT_TIME);
            if (UIUtils.IsNull(quitTime))
            {
                return true;
            }

            bool iscache = LocalDataUtils.GetBoolData("clearcache");
            if (iscache)
            {
                LocalDataUtils.SetBoolData("clearcache", false);
                return true;
            }

            // 切换了服务器地址也要更新数据
            string lasturl = LocalDataUtils.GetStringData("last_login_service");
            if (!string.Equals(lasturl, UIUtils.GetServer()))
            {
                return true;
            }
            return false;
        }

        #endregion

        #region 登录打开等待符

        /// <summary>
        /// 登录打开等待符
        /// </summary>
        private LodingUtils loding = new LodingUtils();
        private void OpenLoading()
        {
            loding.size = new Size(btnLogin.Size.Height, btnLogin.Size.Height);
            loding.parent = panel1;
            loding.BgColor = Color.Transparent;
            loding.start();
        }

        #endregion

        #region 窗口关闭时注销Messenger
        /// <summary>
        /// 窗口关闭时注销Messenger
        /// </summary>
        /// <param name="e"></param>
        protected override void OnClosing(CancelEventArgs e)
        {
            base.OnClosing(e);
        }
        #endregion

        #region 注册按钮点击事件

        /// <summary>
        /// 注册按钮点击事件
        /// </summary>
        private void lblRegister_Click(object sender, EventArgs e)
        {
            FrmRegister frm = new FrmRegister();
            this.Hide();
            frm.Show();
        }

        #endregion

        #region 切换服务器按钮点击事件
        /// <summary>
        /// 切换服务器按钮点击事件
        /// </summary>
        private void picServer_Click(object sender, EventArgs e)
        {
            FrmServerSwit frm = new FrmServerSwit();
            frm.Location = new Point(this.Location.X - frm.Width, this.Location.Y);
            frm.ShowDialog();
        }

        #endregion

        #region 账号框全选、复制、粘贴、剪切事件监听

        /// <summary>
        /// 文本框可使用全选、复制、粘贴、剪切
        /// </summary>
        private void txtTelephone_KeyUp(object sender, KeyEventArgs e)
        {
            TextBox tvBox = ((TextBox)sender);

            if (e.Modifiers.Equals(Keys.Control))
            {
                switch (e.KeyCode)
                {
                    case Keys.A:
                        // 全选
                        tvBox.SelectAll();
                        break;
                    case Keys.C:
                        // 复制
                        Clipboard.SetDataObject(tvBox.SelectedText);
                        break;
                    case Keys.V:
                        // 粘贴
                        if (Clipboard.ContainsText())
                        {
                            try
                            {
                                // 检查是否数字，只能粘贴数字，不能粘贴文本
                                Convert.ToInt64(Clipboard.GetText());
                                tvBox.SelectedText = Clipboard.GetText().Trim(); //Ctrl+V 粘贴  
                            }
                            catch (Exception)
                            {
                                e.Handled = true;
                            }
                        }
                        break;
                    case Keys.X:
                        if (!string.IsNullOrEmpty(txtTelephone.Text))
                        {
                            Clipboard.SetDataObject(tvBox.SelectedText);
                            tvBox.Text = String.Empty;
                        }
                        break;
                    default:
                        break;
                }
            }
        }

        #endregion

        #region 账号框文本限制事件

        /// <summary>
        /// 账号限制数字
        /// </summary>
        private void txtTelephone_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (Applicate.URLDATA.data.regeditPhoneOrName == 0)
            {
                if (!(Char.IsNumber(e.KeyChar)) && e.KeyChar != (char)8)
                {
                    e.Handled = true;
                }
            }

            if (Applicate.URLDATA.data.regeditPhoneOrName == 1)
            {
                // 范围（0x4e00～0x9fa5）转换成int（chfrom～chend）
                int chfrom = Convert.ToInt32("4e00", 16);
                int chend = Convert.ToInt32("9fa5", 16);
                if (e.KeyChar >= (Char)chfrom && e.KeyChar <= (Char)chend)
                {
                    e.Handled = true;
                }
                if (e.KeyChar >= (Char)65281 & (int)e.KeyChar <= (Char)65374)
                {
                    e.Handled = true;
                }
            }
        }

        #endregion

        #region 账号框文本长度限制
        private void txtTelephone_TextChanged(object sender, EventArgs e)
        {
            //用户名登录限制长度
            //if (txtTelephone.TextLength > 10 && Applicate.URLDATA.data.regeditPhoneOrName == 1)
            //{
            //    txtTelephone.Text = txtTelephone.Text.Remove(10, 1);
            //    txtTelephone.Select(10, 0);
            //    ShowTip("账号不能为超过10位");
            //}
        }

        #endregion

        #region 忘记密码按钮点击事件

        /// <summary>
        /// 忘记密码
        /// </summary>
        private void btnForgetPwd_Click(object sender, EventArgs e)
        {
            FrmForgetPwd frm = new FrmForgetPwd();
            this.Hide();
            frm.Show();
        }
        #endregion

        #region 区号点击事件
        /// <summary>
        /// 区号选中事件
        /// </summary>
        private void cmbAreaCode_Click(object sender, EventArgs e)
        {
            FrmControl frmControl = new FrmControl();
            frmControl.loadData();
            frmControl.prefix = (prefix) =>
            {
                lblContry.Text = prefix.ToString();
                lblContry.Text = "+" + prefix.ToString();
            };
        }

        #endregion

        #region 回车键监听

        /// <summary>
        /// 监听回车键
        /// </summary>
        private void LoginKeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                if (!string.IsNullOrEmpty(Applicate.URLDATA.data.apiUrl))
                {
                    this.btnLogin_Click(btnLogin, e); //Enter键登录
                }
            }
        }

        #endregion

        #region 登陆完成跳转主窗口
        private void JumpMainUI()
        {
            LogUtils.Save("=============================" + TimeUtils.FromatCurrtTime() + "=============================\r\n");
            LogUtils.Save("=====登录账号:" + (lblContry.Text + txtTelephone.Text) + "======\r\n");
            LogUtils.Save("=====用户名  :" + Applicate.MyAccount.nickname + "======\r\n");
            LogUtils.Save("=====用户id  :" + Applicate.MyAccount.userId + "======\r\n");
            LogUtils.Save("=====系统.net版本:" + UIUtils.GetDotNetVersion() + "======\r\n");
            LogUtils.Save("=====程序版本:" + Applicate.APP_VERSION + "-" + Applicate.CURRET_VERSION + "======\r\n");

            LocalDataUtils.SetStringData("last_login_service", UIUtils.GetServer());

            var frmMain = new FrmMain(this.BetMainForm);

            loding.stop();
            this.Close();

            frmMain.Show();
            frmMain.MainLoadData();

            if (this.BetMainForm != null)
            {
                this.BetMainForm.notifyGroupsInfo();
            }
        }
        #endregion

        #region 记住密码&回显账号
        /// <summary>
        /// 保存登陆账号数据,记住账号
        /// </summary>
        private void SaveAccountInfo()
        {
            Configuration cfa = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

            cfa.AppSettings.Settings["areaCodeIndex"].Value = lblContry.Text.ToString(); // 账号（默认记住）
            cfa.AppSettings.Settings["userId"].Value = txtTelephone.Text.Trim(); // 账号（默认记住）
            cfa.AppSettings.Settings["passWord"].Value = chkRememberPwd.Checked ? txtPassword.Text.Trim() : String.Empty;
            cfa.AppSettings.Settings["rememberPwd"].Value = (this.chkRememberPwd.Checked.ToString()); // 自动赋值

            cfa.Save();
        }

        /// <summary>
        /// 回显最后一次登陆的账号
        /// </summary>
        private void ShowUserAccess()
        {
            string userphone = ConfigurationManager.AppSettings["userId"];
            if (!string.IsNullOrEmpty(userphone))
            {
                lblContry.Text = ConfigurationManager.AppSettings["areaCodeIndex"];
                txtTelephone.Text = userphone;
                //如果记住密码为true 那么把值赋给文本框
                if (ConfigurationManager.AppSettings["rememberPwd"].Equals("True"))
                {
                    txtPassword.Text = ConfigurationManager.AppSettings["passWord"];
                    chkRememberPwd.Checked = true;
                }
            }
        }
        #endregion


        private void pictureBox1_Click(object sender, EventArgs e)
        {
            // hello
        }
    }
}

