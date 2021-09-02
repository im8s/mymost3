
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
    /// ��¼����
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

            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//����iconͼ��

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
        /// �Ƿ���Ҫ����config�ӿ�
        /// </summary>
        private void NeedUpdateConfig(string str)
        {
            isUpdateConfig = true;
        }

        /// <summary>
        /// ��ʾ��½���ڣ���ע�ᣬ�������뷵�ص�½�����¼�
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
                ShowTip("ע��ɹ�");

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
                ShowTip("�һ�����ɹ�");
                return;
            }

            if ("regist_err".Equals(str))
            {
                ShowTip("ע��ʧ��");
                return;
            }
        }

        /// <summary>
        /// ��ȡ����
        /// </summary>
        private void GetHttpConfig()
        {
            if (!UIUtils.GetDotNetVersion(Applicate.CURRET_VERSION.ToString()))
            {
                ShowTip("��ǰ windows ȱ��.net ���п⣬�������д˰汾����ǰ�����������°汾");
                return;
            }

            isUpdateConfig = false;

            var url = UIUtils.GetServer();

            HttpUtils.Instance.Get().Url(url).Build()
                .AddErrorListener((code, msg) =>
                {
                    ShowTip("���������ô�������������");

                    Applicate.URLDATA = new JsonConfigData();
                    Applicate.URLDATA.data = Applicate.GetDefConfig();
                    btnLogin.Enabled = true; //��ɻ�ȡ���ú����õ�¼��ť
                    btnLogin.ForeColor = Color.White;
                    isEnter = true;
                    lblRegister.Enabled = true;
                    btnForgetPwd.Enabled = true;

                    // �û�����¼
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

                        LogUtils.Log("���û�ȡ�ɹ�   " + Applicate.URLDATA.data.apiUrl);

                        btnLogin.Enabled = true; //��ɻ�ȡ���ú����õ�¼��ť
                        btnLogin.ForeColor = Color.White;
                        isEnter = true;
                        lblRegister.Enabled = true;
                        btnForgetPwd.Enabled = true;

                        //�û�����¼
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
                            //������
                            if (string.IsNullOrEmpty(config.pcVersion) && Applicate.APP_VERSION.Replace(".", "") != config.pcVersion && string.IsNullOrEmpty(Applicate.URLDATA.data.pcAppUrl) &&
                                MessageBox.Show("���µİ汾�Ƿ���Ҫ���и���", "ϵͳ����", MessageBoxButtons.YesNo) == DialogResult.Yes)
                            {
                                File.Delete("Download.config");
                                FileStream fsWrite = new FileStream("Download.config", FileMode.OpenOrCreate);
                                byte[] buffer = Encoding.Default.GetBytes(config.pcAppUrl);
                                fsWrite.Write(buffer, 0, buffer.Length);
                                fsWrite.Close();
                                string path = Environment.CurrentDirectory;
                                Process process = new Process();
                                process.StartInfo.FileName = "update.exe";
                                process.StartInfo.WorkingDirectory = path; //Ҫ���õ�exe·������:"C:\windows";               
                                process.StartInfo.CreateNoWindow = true;
                                process.Start();
                                Application.Exit();
                            }
                        }
                    }
                });
        }

        #region ���ڼ����¼�
        private void FrmLogin_Load(object sender, EventArgs e)
        {
            ShowUserAccess();

            if (string.IsNullOrEmpty(txtTelephone.Text))
            {
                this.ActiveControl = this.txtTelephone;// ��ȡ�����˺Ž���
                txtTelephone.Select(txtTelephone.TextLength, 0);
            }
            else if (string.IsNullOrEmpty(txtPassword.Text))
            {
                this.ActiveControl = txtPassword; // ��ȡ�������뽹��
                txtPassword.Select(txtPassword.TextLength, 0);
            }
            else
            {
                this.ActiveControl = txtPassword;
            }
            txtPassword.Select(txtPassword.TextLength, 0);

            if (Applicate.URLDATA.data.apiUrl != null)
            {
                btnLogin.Enabled = true;//��ɻ�ȡ���ú����õ�¼��ť
                isEnter = true;
                lblRegister.Enabled = true;
                btnForgetPwd.Enabled = true;
            }

            EmojiCodeDictionary.GetEmojiDataNotMine();//��ʱ����
        }
        #endregion

        #region ��������ͼ��
        /// <summary>
        /// ��������ͼ��
        /// </summary>
        private void LoadIconFonts()
        {
            var iconfont = Program.ApplicationFontCollection.Families.Last();
            lbliconAccount.Font = new Font(iconfont, 15f);
            lbliconPassword.Font = new Font(iconfont, 15f);
        }
        #endregion

        #region ��¼��ť���

        private void btnLogin_Click(object sender, EventArgs e)
        {
            if (!UIUtils.GetDotNetVersion(Applicate.CURRET_VERSION.ToString()))
            {
                ShowTip("��ǰ windows ȱ��.net ���п⣬����������");
                return;
            }

            if (!isEnter)
            {
                ShowTip("��ȡ������Ϣʧ�ܣ�����ϵ����Ա");
                return;
            }

            //if (Math.Abs(TimeUtils.SyncTimeDiff()) > 10)
            //{
            //    ShowTip("����ʱ��ͷ�����ʱ������������ϵ����Ա");
            //    return;
            //}

            if (string.IsNullOrEmpty(txtTelephone.Text))
            {
                ShowTip("�˺Ų���Ϊ��");
                return;
            }

            if (string.IsNullOrEmpty(txtPassword.Text))
            {
                ShowTip("���벻��Ϊ��");
                return;
            }

            btnLogin.Visible = false;
            lblRegister.Visible = false;

            // ��ʾ�ȴ���
            OpenLoading();

            // �����°��½�ӹ�ϵͳ
            RequestLoginCode();
        }

        #region �����¼��

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
                    Console.WriteLine("��ȡcodeʧ��");
                    loding.stop();
                    btnLogin.Visible = true;
                    lblRegister.Visible = true;

                }).Execute((sccess, data) =>
                {
                    if (sccess)
                    {
                        // ���ߵ�����˵����½�˺ź����붼û����
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
                        Console.WriteLine("��ȡcodeʧ��");
                        loding.stop();
                        btnLogin.Visible = true;
                        lblRegister.Visible = true;
                    }
                });
        }

        // ������û�е�½code��Ҫ�ϴ�һ��
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
                    Console.WriteLine("��ȡcodeʧ��");

                }).Execute((sccess, data) =>
                {
                    if (sccess)
                    {
                        // ����ȥ����
                        RequestLoginCode();
                    }
                    else
                    {
                        Console.WriteLine("��ȡcodeʧ��");
                    }
                });
        }
        #endregion

        #region �����¼��˽Կ
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
                    Console.WriteLine("ʧ��");

                }).Execute((sccess, data) =>
                {
                    if (sccess)
                    {
                        string aeskey = UIUtils.DecodeString(data, "privateKey");

                        // ����code
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
                            Console.WriteLine("����ʧ��");
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

        #region ��¼��˽Կ��½ϵͳ

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

            // ������
            string mac = MAC.EncodeBase64((Applicate.API_KEY + userId + Parameter.JoinValues(pairs) + salt + hexpwd), logincode);

            // aes ����
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
                   Console.WriteLine("ʧ��");

               }).Execute((sccess, resultdata) =>
               {
                   if (sccess)
                   {
                       content = UIUtils.DecodeString(resultdata, "data");
                       string result = AES.NewString(AES.DecryptBase64(content, logincode));

                       if (!UIUtils.IsNull(result))
                       {
                           // ���ܳɹ�
                           var userinfo = JsonConvert.DeserializeObject<UserInfo>(result);

                           Applicate.InitAccountData(userinfo, txtTelephone.Text, txtPassword.Text, true);
                           string areaCode = lblContry.Text.ToString().Remove(0, 1);
                           Applicate.MyAccount.areaCode = areaCode;

                           SaveAccountInfo();

                           if (userinfo.isupdate == 1 || IsNeedUpdateData(Applicate.MyAccount.userId))
                           {
                               login_tip.Visible = true;
                               // �����������أ�ȥͬ���ҵĺ��Ѻ�Ⱥ��
                               SyncDataDownlad download = new SyncDataDownlad();
                               download.StartDown((success) =>
                               {
                                   // ͬ�����, ��ת��������
                               
                                   login_tip.Visible = false;
                                   LogUtils.Log("����ͬ����� ��ת��������");
                               });
                           }
                          
                           {
                               loding.stop();
                               //JumpMainUI();
                               this.Close();

                               this.BetMainForm.JumpMainUI();
                           }
                       }

                       Console.WriteLine("��¼�ɹ�" + result);
                   }
                   else
                   {

                   }
               });

        }

        #endregion

        /// <summary>
        /// �Ƿ���Ҫ�����˺�����
        /// </summary>
        private bool IsNeedUpdateData(string userId)
        {
            // �û����ݿ�����λ��
            string dbPaht = Environment.CurrentDirectory + "\\db\\" + userId + ".db";
            if (!File.Exists(dbPaht))
            {
                return true;
            }

            // �����û��˳�ʱ��
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

            // �л��˷�������ַҲҪ��������
            string lasturl = LocalDataUtils.GetStringData("last_login_service");
            if (!string.Equals(lasturl, UIUtils.GetServer()))
            {
                return true;
            }
            return false;
        }

        #endregion

        #region ��¼�򿪵ȴ���

        /// <summary>
        /// ��¼�򿪵ȴ���
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

        #region ���ڹر�ʱע��Messenger
        /// <summary>
        /// ���ڹر�ʱע��Messenger
        /// </summary>
        /// <param name="e"></param>
        protected override void OnClosing(CancelEventArgs e)
        {
            base.OnClosing(e);
        }
        #endregion

        #region ע�ᰴť����¼�

        /// <summary>
        /// ע�ᰴť����¼�
        /// </summary>
        private void lblRegister_Click(object sender, EventArgs e)
        {
            FrmRegister frm = new FrmRegister();
            this.Hide();
            frm.Show();
        }

        #endregion

        #region �л���������ť����¼�
        /// <summary>
        /// �л���������ť����¼�
        /// </summary>
        private void picServer_Click(object sender, EventArgs e)
        {
            FrmServerSwit frm = new FrmServerSwit();
            frm.Location = new Point(this.Location.X - frm.Width, this.Location.Y);
            frm.ShowDialog();
        }

        #endregion

        #region �˺ſ�ȫѡ�����ơ�ճ���������¼�����

        /// <summary>
        /// �ı����ʹ��ȫѡ�����ơ�ճ��������
        /// </summary>
        private void txtTelephone_KeyUp(object sender, KeyEventArgs e)
        {
            TextBox tvBox = ((TextBox)sender);

            if (e.Modifiers.Equals(Keys.Control))
            {
                switch (e.KeyCode)
                {
                    case Keys.A:
                        // ȫѡ
                        tvBox.SelectAll();
                        break;
                    case Keys.C:
                        // ����
                        Clipboard.SetDataObject(tvBox.SelectedText);
                        break;
                    case Keys.V:
                        // ճ��
                        if (Clipboard.ContainsText())
                        {
                            try
                            {
                                // ����Ƿ����֣�ֻ��ճ�����֣�����ճ���ı�
                                Convert.ToInt64(Clipboard.GetText());
                                tvBox.SelectedText = Clipboard.GetText().Trim(); //Ctrl+V ճ��  
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

        #region �˺ſ��ı������¼�

        /// <summary>
        /// �˺���������
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
                // ��Χ��0x4e00��0x9fa5��ת����int��chfrom��chend��
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

        #region �˺ſ��ı���������
        private void txtTelephone_TextChanged(object sender, EventArgs e)
        {
            //�û�����¼���Ƴ���
            //if (txtTelephone.TextLength > 10 && Applicate.URLDATA.data.regeditPhoneOrName == 1)
            //{
            //    txtTelephone.Text = txtTelephone.Text.Remove(10, 1);
            //    txtTelephone.Select(10, 0);
            //    ShowTip("�˺Ų���Ϊ����10λ");
            //}
        }

        #endregion

        #region �������밴ť����¼�

        /// <summary>
        /// ��������
        /// </summary>
        private void btnForgetPwd_Click(object sender, EventArgs e)
        {
            FrmForgetPwd frm = new FrmForgetPwd();
            this.Hide();
            frm.Show();
        }
        #endregion

        #region ���ŵ���¼�
        /// <summary>
        /// ����ѡ���¼�
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

        #region �س�������

        /// <summary>
        /// �����س���
        /// </summary>
        private void LoginKeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                if (!string.IsNullOrEmpty(Applicate.URLDATA.data.apiUrl))
                {
                    this.btnLogin_Click(btnLogin, e); //Enter����¼
                }
            }
        }

        #endregion

        #region ��½�����ת������
        private void JumpMainUI()
        {
            LogUtils.Save("=============================" + TimeUtils.FromatCurrtTime() + "=============================\r\n");
            LogUtils.Save("=====��¼�˺�:" + (lblContry.Text + txtTelephone.Text) + "======\r\n");
            LogUtils.Save("=====�û���  :" + Applicate.MyAccount.nickname + "======\r\n");
            LogUtils.Save("=====�û�id  :" + Applicate.MyAccount.userId + "======\r\n");
            LogUtils.Save("=====ϵͳ.net�汾:" + UIUtils.GetDotNetVersion() + "======\r\n");
            LogUtils.Save("=====����汾:" + Applicate.APP_VERSION + "-" + Applicate.CURRET_VERSION + "======\r\n");

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

        #region ��ס����&�����˺�
        /// <summary>
        /// �����½�˺�����,��ס�˺�
        /// </summary>
        private void SaveAccountInfo()
        {
            Configuration cfa = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

            cfa.AppSettings.Settings["areaCodeIndex"].Value = lblContry.Text.ToString(); // �˺ţ�Ĭ�ϼ�ס��
            cfa.AppSettings.Settings["userId"].Value = txtTelephone.Text.Trim(); // �˺ţ�Ĭ�ϼ�ס��
            cfa.AppSettings.Settings["passWord"].Value = chkRememberPwd.Checked ? txtPassword.Text.Trim() : String.Empty;
            cfa.AppSettings.Settings["rememberPwd"].Value = (this.chkRememberPwd.Checked.ToString()); // �Զ���ֵ

            cfa.Save();
        }

        /// <summary>
        /// �������һ�ε�½���˺�
        /// </summary>
        private void ShowUserAccess()
        {
            string userphone = ConfigurationManager.AppSettings["userId"];
            if (!string.IsNullOrEmpty(userphone))
            {
                lblContry.Text = ConfigurationManager.AppSettings["areaCodeIndex"];
                txtTelephone.Text = userphone;
                //�����ס����Ϊtrue ��ô��ֵ�����ı���
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

