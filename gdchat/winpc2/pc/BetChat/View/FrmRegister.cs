
using System;
using System.Drawing;
using System.Windows.Forms;
using WinFrmTalk.View;

namespace WinFrmTalk
{
    /// <summary>
    /// 注册页面
    /// </summary>
    public partial class FrmRegister : FrmBase
    {
        private int countdown = 60;
        private bool State = true;

        public FrmRegister()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标

            //使用用户名注册
            if (Applicate.URLDATA.data.regeditPhoneOrName == 1)
            {
                label1.Text = "用 户 名：";
                lblContry.Visible = false;
                txtTel.Size = txtPassword.Size;
                txtTel.Location = new Point(100, 155);
            }

            if (Applicate.URLDATA.data.registerInviteCode == 1)
            {
                label3.Text = "邀 请 码：";
                picImgCode.Visible = false;
                txtImgCode.Size = txtPassword.Size;
                label4.Visible = false;
                txtCode.Visible = false;
                txtCode.Text = "不为空";
                btnSendCode.Visible = false;
            }

            if (Applicate.URLDATA.data.isOpenSMSCode == 0)
            {
                label3.Visible = false;
                txtImgCode.Visible = false;
                picImgCode.Visible = false;
                label4.Visible = false;
                txtCode.Visible = false;
                btnSendCode.Visible = false;
                label2.Location = label3.Location;
                txtPassword.Location = txtImgCode.Location;
            }
            else
            {
                if (Applicate.URLDATA.data.regeditPhoneOrName == 1)
                {
                    label3.Visible = false;
                    txtImgCode.Visible = false;
                    picImgCode.Visible = false;
                    label4.Visible = false;
                    txtCode.Visible = false;
                    btnSendCode.Visible = false;
                    label2.Location = label3.Location;
                    txtPassword.Location = txtImgCode.Location;
                }
            }
        }

        /// <summary>
        /// 初始化注册界面数据
        /// </summary>
        public void InitData(string phone, string pwd, string areaCode, string inviteCode)
        {
            //this.Tel = phone;
            //this.Password = pwd;
            //this.AreaCode = areaCode;
            //this.InviteCode = inviteCode;

            txtTel.Text = phone;
            txtPassword.Text = pwd;
            txtImgCode.Text = inviteCode;

            if (!UIUtils.IsNull(areaCode))
            {
                lblContry.Text = "+" + areaCode;
            }
        }

        /// <summary>
        /// 判断账号是否是数字
        /// </summary>
        private void TxtTel_KeyPress(object sender, KeyPressEventArgs e)
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
                int chfrom = Convert.ToInt32("4e00", 16);    //范围（0x4e00～0x9fa5）转换成int（chfrom～chend）
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

        /// <summary>
        /// 倒计时事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void TmrCode_Tick(object sender, EventArgs e)
        {
            if (countdown != 0)
            {
                btnSendCode.Enabled = false;
                btnSendCode.BackColor = Color.White;
                btnSendCode.Text = countdown + "s";
                countdown--;
                if (countdown == 30)
                {
                    lblnocode.Visible = true;
                }
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

        /// <summary>
        /// 选择区号点击
        /// </summary>
        private void LblContry_Click(object sender, EventArgs e)
        {
            FrmControl frmControl = new FrmControl();
            frmControl.loadData();
            frmControl.prefix = (prefix) =>
            {
                lblContry.Text = prefix.ToString();
                lblContry.Text = "+" + prefix.ToString();
            };
        }

        /// <summary>
        /// 注册界面关闭事件
        /// </summary>
        private void FrmRegister_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (State)
            {
                Messenger.Default.Send("regist_back", MessageActions.SHOW_LOGINFORM);
                this.Dispose();
            }
        }


        #region 发送短信验证码

        private void BtnSendCode_Click(object sender, EventArgs e)
        {
            string phone = txtTel.Text.Trim();
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
                .AddParams("isRegister", "1")
                .AddParams("version", "1")
                .AddErrorListener((code, msg) =>
                {
                    ShowTip(msg);
                    btnSendCode.Enabled = true;
                    btnSendCode.BackColor = ColorTranslator.FromHtml("#1AAD19");
                    btnSendCode.Text = "发送";
                    countdown = 60;
                    tmrCode.Stop();
                    string defPath = Environment.CurrentDirectory + "\\Resource\\Refresh.png";
                    ImageLoader.Instance.Load(defPath).Into(picImgCode);
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

        #region 刷新图形码
        /// <summary>
        /// 刷新图形码
        /// </summary>
        private void PicImgCode_Click(object sender, EventArgs e)
        {
            string phone = txtTel.Text;

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

        #endregion

        #region 注册账号
        /// <summary>
        /// 注册按钮点击事件
        /// </summary>
        private void BtnRegister_Click(object sender, EventArgs e)
        {

            string phone = txtTel.Text.Trim();
            string pwd = txtPassword.Text.Trim();
            string imgCode = txtImgCode.Text.Trim();
            string rcode = txtCode.Text.Trim();


            if (txtImgCode.Visible && txtCode.Visible)
            {
                if (string.IsNullOrEmpty(imgCode) && string.IsNullOrEmpty(rcode))
                {
                    ShowTip("信息不能为空");
                    return;
                }
            }

            if (Applicate.URLDATA.data.isOpenSMSCode == 1)
            {
                if (UIUtils.IsNull(txtCode.Text))
                {
                    ShowTip("验证码不能为空");
                    return;
                }

                // 新版本不在本地校验短信码
                //if (!Code.Equals(RequestCode))
                //{
                //    ShowTip("验证码不正确");
                //    return;
                //}
            }

            if (UIUtils.IsNull(phone) || UIUtils.IsNull(pwd))
            {
                ShowTip("账号或密码不能为空");
                return;
            }

            if (pwd.Length < 6)
            {
                ShowTip("密码长度应大于6位");
                return;
            }

            if (pwd.Length > 18)
            {
                ShowTip("密码长度应小于18位");
                return;
            }

            // 是否跳过验证码
            bool skipverify = !txtCode.Visible;

            RequesVerifyPhone(phone, pwd, skipverify);
        }


        /// <summary>
        /// 收不到验证码直接登录
        /// </summary>
        private void Lblnocode_Click(object sender, EventArgs e)
        {
            string phone = txtTel.Text.Trim();
            string pwd = txtPassword.Text.Trim();

            if (UIUtils.IsNull(phone) || UIUtils.IsNull(pwd))
            {
                ShowTip("账号或密码不能为空");
                return;
            }

            if (pwd.Length < 6)
            {
                ShowTip("密码长度应大于6位");
                return;
            }

            if (pwd.Length > 18)
            {
                ShowTip("密码长度应小于18位");
                return;
            }

            // 验证手机号
            RequesVerifyPhone(phone, pwd, true);
        }

        /// <summary>
        /// 请求验证手机号
        /// </summary>
        /// <param name="phone"></param>
        /// <param name="pwd"></param>
        /// <param name="skipverify"></param>
        private void RequesVerifyPhone(string phone, string pwd, bool skipverify)
        {
            string areaCode = lblContry.Text.Remove(0, 1).Trim();
            string inviteCode = txtImgCode.Text.Trim();
            string rcode = txtCode.Text.Trim();

            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "verify/telephone")
                  .AddParams("areaCode", areaCode)
                  .AddParams("telephone", phone)
                  .Build()
                  .AddErrorListener((code, msg) =>
                  {
                      ShowTip(msg);
                  }).
                  Execute((susse, data) =>
                  {
                      if (susse)
                      {
                          if (data["resultCode"].ToString() == "1")
                          {
                              FrmRegisterInfo frm = new FrmRegisterInfo();
                              frm.InitData(phone, pwd, areaCode, rcode, inviteCode);

                              this.Dispose();
                              State = false;//防止登录界面闪烁打开
                              frm.Location = this.Location;
                              frm.ShowDialog();
                          }
                          else
                          {
                              ShowTip(phone + "已被注册");
                          }
                          LogUtils.Log(data.ToString());
                      }
                      else
                      {
                          ShowTip(label1.Text.Replace(" ", "").Replace("：", "") + "已注册");
                      }
                  });
        }

        #endregion


    }
}
