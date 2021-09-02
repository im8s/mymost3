using System;
using System.Configuration;
using System.Drawing;
using System.Windows.Forms;
using WinFrmTalk.View;

namespace WinFrmTalk
{
    public partial class FrmForgetPwd : FrmBase
    {
        private int countdown = 60;

        public FrmForgetPwd()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
        }

        private void FrmForgetPwd_Load(object sender, EventArgs e)
        {
            txtTelephone.Text = ConfigurationManager.AppSettings["userId"];
        }

        private void FrmForgetPwd_FormClosing(object sender, FormClosingEventArgs e)
        {
            Messenger.Default.Send("regist_back", MessageActions.SHOW_LOGINFORM);
            this.Dispose();
        }


        /// <summary>
        /// 刷新图形码
        /// </summary>
        private void PicImgCode_Click(object sender, EventArgs e)
        {
            string phone = txtTelephone.Text;

            if (UIUtils.IsNull(phone))
            {
                ShowTip("账号不能为空");
                return;
            }

            string code = lblContry.Text.ToString().Remove(0, 1);

            // 获取验证码url
            string url = HttpUtils.Instance.Get()
                .Url(Applicate.URLDATA.data.apiUrl + "getImgCode")
                .AddParams("telephone", code + phone)
                .Build(true).BuildUrl();

            // 显示验证码
            ImageLoader.Instance.DisplayImage(url, picImgCode, false);

            // 激活显示发送按钮
            btnSendCode.Enabled = true;
            btnSendCode.BackColor = ColorTranslator.FromHtml("#1AAD19");
            btnSendCode.Text = "发送";

            countdown = 60;
            tmrCode.Stop();
        }


        #region 发送短信验证码
        /// <summary>
        /// 发送短信验证码
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void BtnSendCode_Click(object sender, EventArgs e)
        {
            string phone = txtTelephone.Text.Trim();
            string imgCode = txtImgCode.Text.Trim();
            string areaCode = lblContry.Text.Remove(0, 1).Trim();


            if (string.IsNullOrEmpty(phone))
            {
                ShowTip("手机号码不能为空");
                return;
            }

            if (string.IsNullOrEmpty(imgCode))
            {
                ShowTip("图片验证码不能为空");
                return;
            }

            if (UIUtils.IsNull(txtNewPwd.Text))
            {
                ShowTip("新密码不能为空");
                return;
            }

            if (!string.Equals(txtNewPwd.Text, txtConfirmPwd.Text))
            {
                ShowTip("新密码和确认密码不一致");
                return;
            }

            // 请求发送短信验证码
            RequestSendRandCode(phone, areaCode, imgCode);
        }

        /// <summary>
        /// 请求服务器发送短信验证码
        /// </summary>
        /// <param name="phone"></param>
        /// <param name="areaCode"></param>
        /// <param name="imgCode"></param>
        public void RequestSendRandCode(string phone, string areaCode, string imgCode)
        {
            // 请求服务器发送验证码
            tmrCode.Start();
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "basic/randcode/sendSms")
                .AddParams("language", "zh")
                .AddParams("areaCode", areaCode)
                .AddParams("telephone", phone)
                .AddParams("imgCode", imgCode)
                .AddParams("isRegister", "0")
                .AddParams("version", "1")
                .AddErrorListener((code, msg) =>
                {
                    ShowTip(msg);
                    btnSendCode.Enabled = true;
                    btnSendCode.BackColor = ColorTranslator.FromHtml("#1AAD19");
                    btnSendCode.Text = "发送";
                    countdown = 60;
                    tmrCode.Stop();
                })
                .Build().Execute((s, msg) =>
                {
                    if (s)
                    {
                        txtCode.Focus();
                        string rcode = UIUtils.DecodeString(msg, "code");
                        LogUtils.Log("服务端验证码:" + rcode);
                    }
                    else
                    {
                        btnSendCode.Enabled = true;
                        btnSendCode.BackColor = ColorTranslator.FromHtml("#1AAD19");
                        btnSendCode.Text = "发送";
                        countdown = 60;
                        tmrCode.Stop();
                    }
                });
        }

        #endregion

        #region 重置密码
        private void BtnChangePwd_Click(object sender, EventArgs e)
        {
            string phone = txtTelephone.Text.Trim();
            string pwd = txtNewPwd.Text.Trim();
            string areaCode = lblContry.Text.ToString().Remove(0, 1);
            string rcode = txtCode.Text.Trim();

            if (string.IsNullOrEmpty(phone))
            {
                ShowTip("手机号码不能为空");
                return;
            }

            if (string.IsNullOrEmpty(pwd))
            {
                ShowTip("新密码不能为空");
                return;
            }

            if (string.IsNullOrEmpty(rcode))
            {
                ShowTip("验证码不能为空");
                return;
            }

            if (rcode.Length != 6)
            {
                ShowTip("验证码长度不正确");
                return;
            }

            if (!string.Equals(txtNewPwd.Text, txtConfirmPwd.Text))
            {
                ShowTip("新密码和确认密码不一致");
                return;
            }

            // 请求重置密码
            RequestResetPassword(phone, MD5.MD5Hex(pwd), areaCode, rcode);
        }



        /// <summary>
        /// 请求重置密码
        /// </summary>
        /// <param name="phone"></param>
        /// <param name="areaCode"></param>
        /// <param name="pwd"></param>
        /// <param name="rcode"></param>
        private void RequestResetPassword(string phone, string pwd, string areaCode, string rcode, bool isSupportSecureChat = false)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/password/reset")
                .AddParams("telephone", phone)
                .AddParams("areaCode", areaCode)
                .AddParams("newPassword", pwd)
                .AddParams("randcode", rcode)
                .AddErrorListener((ecode, msg) =>
                {
                    ShowTip(msg);
                })
                .Build()
                .Execute((suss, ResultData) =>
                {
                    if (suss)
                    {
                        // 保存账号信息
                        SaveAccountInfo();

                        Messenger.Default.Send("reset_success", MessageActions.SHOW_LOGINFORM);
                        this.Dispose();
                    }
                });
        }

        #endregion

        #region 记住账号
        /// <summary>
        /// 保存账号信息
        /// </summary>
        private void SaveAccountInfo()
        {
            Configuration cfa = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            cfa.AppSettings.Settings["areaCodeIndex"].Value = lblContry.Text.ToString(); // 账号（默认记住）
            cfa.AppSettings.Settings["userId"].Value = txtTelephone.Text; // 账号（默认记住）
            cfa.AppSettings.Settings["passWord"].Value = string.Empty;
            cfa.AppSettings.Settings["rememberPwd"].Value = "False"; // 自动赋值
            cfa.Save();
        }

        #endregion


        private void tmrCode_Tick(object sender, EventArgs e)
        {
            if (countdown > 0)
            {
                btnSendCode.Enabled = false;
                btnSendCode.BackColor = Color.White;
                btnSendCode.Text = countdown + "s";
                countdown--;
            }
            else
            {
                btnSendCode.Enabled = true;
                btnSendCode.Text = "发送";
                btnSendCode.BackColor = ColorTranslator.FromHtml("#1AAD19");
                countdown = 60;
                tmrCode.Stop();
            }
        }

        private void lblContry_Click(object sender, EventArgs e)
        {
            FrmControl frmControl = new FrmControl();
            frmControl.loadData();
            frmControl.prefix = (prefix) =>
            {
                lblContry.Text = prefix.ToString();
                lblContry.Text = "+" + prefix.ToString();
            };
        }
    }
}
