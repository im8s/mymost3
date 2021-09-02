using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using CCWin;
using CCWin.SkinControl;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using WinFrmTalk.Helper;
using WinFrmTalk.Helper.MVVM;
using WinFrmTalk.Model;
using WinFrmTalk.View;
using Timer = System.Windows.Forms.Timer;

namespace WinFrmTalk
{
    /// <summary>
    /// ���ô���
    /// <para>lxq-3.12</para>
    /// </summary>
    public partial class FrmSet : FrmBase
    {
        List<string> FriendFromLst = new List<string>();
        public FrmSet()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//����iconͼ��
            lblCompanyName.Text = Applicate.URLDATA.data.companyName;
            lblCopyright.Text = Applicate.URLDATA.data.copyright;
            HttpUtils.Instance.InitHttp(this);
            lblEdition.Text = Applicate.APP_VERSION;
            if (!Applicate.IsInputChatList)
            {
                btninputAllfriendtxt.Visible = false;
                btninputAllfriendxls.Visible = false;
                btninputAllroomtxt.Visible = false;
                btninputAllroomxls.Visible = false;
                btnDeleteCache.Visible = true;
                btnDeleteChat.Visible = true;
                btnDeleteChat.Location = new System.Drawing.Point(184, 215);
                btnDeleteCache.Location = new System.Drawing.Point(184, 142);
            }
            
        }

        private void tabControl1_DrawItem(object sender, DrawItemEventArgs e)
        {
            StringFormat sf = new StringFormat();
            // ���������Ǿ��е�
            sf.LineAlignment = StringAlignment.Center;
            sf.Alignment = StringAlignment.Center;
            //����ѡ�����
            e.Graphics.DrawString(((TabControl)sender).TabPages[e.Index].Text, System.Windows.Forms.SystemInformation.MenuFont, new SolidBrush(Color.Black), e.Bounds, sf);
        }

        private bool state = false;//�����Ƿ���سɹ�
        private void FrmSet_Load(object sender, EventArgs e)
        {

            //����DrawMode Ϊ OwnerDrawFixed �����ٿ��ӻ��༭������
            this.tabSet.DrawMode = System.Windows.Forms.TabDrawMode.OwnerDrawFixed;
            //����ѡ���С
            this.tabSet.ItemSize = new Size(30, 70);
            //����Alignment Ϊ Left/Right �����ٿ��ӻ��༭������
            this.tabSet.Alignment = System.Windows.Forms.TabAlignment.Left;
            //��tabcontrol��drawitem ��д �����Լ�д��DrawItem����
            this.tabSet.DrawItem += new System.Windows.Forms.DrawItemEventHandler(this.tabControl1_DrawItem);

            ImageLoader.Instance.DisplayAvatar(Applicate.MyAccount.userId, false, (bitmap) =>
            {
                Bitmap size = BitmapUtils.ChangeSize(bitmap, picHead.Width, picHead.Height);
                picHead.BackgroundImage = BitmapUtils.GetRoundImage(size);
            });

            //��˽���û�ȡ��������֤����Ϣ���ܡ���������
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("userId", Applicate.MyAccount.userId).
                Build().Execute((suss, data) =>
                {
                    if (suss)
                    {
                        Applicate.MyAccount.settings.friendsVerify = UIUtils.DecodeInt(data, "friendsVerify");//������֤
                        chkPrivacy.Checked = Applicate.MyAccount.settings.friendsVerify == 1 ? true : false;
                        Applicate.MyAccount.isEncrypt = UIUtils.DecodeInt(data, "isEncrypt");//��Ϣ����
                        chkIsEncrypt.Checked = Applicate.MyAccount.isEncrypt == 1 ? true : false;
                        Applicate.MyAccount.sendInput = UIUtils.DecodeInt(data, "isTyping") == 1 ? true : false;//��������
                        chkSendInput.Checked = Applicate.MyAccount.sendInput;
                        MultiDeviceManager.Instance.IsEnable = UIUtils.DecodeString(data, "multipleDevices") == "1";
                        chkMultipleDevices.Checked = MultiDeviceManager.Instance.IsEnable;
                        OverdueDate(UIUtils.DecodeString(data, "chatSyncTimeLen"), false);
                        AddToway(UIUtils.DecodeString(data, "friendFromList"));
                        chkAllowtoPhone.Checked = UIUtils.DecodeInt(data, "phoneSearch") == 1 ? true : false;
                        chkAllowtoNickname.Checked = UIUtils.DecodeInt(data, "nameSearch") == 1 ? true : false;

                        chkAllowtoCustomer.Checked = UIUtils.DecodeInt(data, "openService") == 1 ? true : false;
                        state = true;
                    }
                    else
                    {
                        ShowTip("���û�ȡ�����쳣");
                    }
                });

            #region ˢ��ͷ��
            Messenger.Default.Register<string>(this, MessageActions.UPDATE_HEAD, (userid) =>
            {

                if (Applicate.MyAccount.userId.Equals(userid))
                {
                    picHead.isDrawRound = true;
                    ImageLoader.Instance.DisplayAvatar(Applicate.MyAccount.userId, picHead);
                }

            });
            #endregion
        }

        private void FrmSet_Paint(object sender, PaintEventArgs e)
        {
            Graphics graphics = e.Graphics;
            //������
            Pen pen = new Pen(Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197))))), 1);
            Point point1 = new Point(82, 0);
            Point point2 = new Point(82, 467);
            graphics.DrawLine(pen, point1, point2);
        }
        /// <summary>
        /// �޸�����
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnRevise_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtOldPwd.Text))
            {
                ShowTip("�����벻��Ϊ��");
            }

            if (string.IsNullOrEmpty(txtNewPwd.Text))
            {
                ShowTip("�����벻��Ϊ��");
            }
            if (txtNewPwd.Text != txtConfirmPwd.Text)
            {
                ShowTip("�������벻һ��");
            }

            if (!string.IsNullOrEmpty(txtOldPwd.Text) && !string.IsNullOrEmpty(txtNewPwd.Text) && txtNewPwd.Text == txtConfirmPwd.Text)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/password/update")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("oldPassword", txtOldPwd.Text.MD5create())
                    .AddParams("newPassword", txtNewPwd.Text.MD5create())
                    .Build().Execute((sccess, data) =>
                    {
                        if (sccess)
                        {
                            ShowTip("�����޸ĳɹ�,�����µ�¼,������������");
                            //��¼��ס�������
                            Configuration cfa = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                            cfa.AppSettings.Settings["passWord"].Value = String.Empty;
                            cfa.Save();
                            Timer timer = new Timer() { Interval = 3000 };
                            timer.Start();
                            timer.Tick += (sen, eve) =>
                            {
                                btnCancel_Click(sender, e);
                                timer.Stop();
                            };

                            LogUtils.Log(data.ToString());
                        }
                        else
                        {
                            ShowTip("�����޸�ʧ��");
                            LogUtils.Log(data.ToString());
                        }
                    });
            }

        }
        /// <summary>
        /// �򿪱༭���ϴ���
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnEdit_Click(object sender, EventArgs e)
        {
            var tmpset = Applicate.GetWindow<FrmRegisterInfo>();
            if (tmpset == null)
            {
                var query = new FrmRegisterInfo();
                query.Location = new Point(this.Location.X + (this.Width - query.Width) / 2, this.Location.Y + (this.Height - query.Height) / 2);//����
                query.LoadShow();
                query.Text = "�༭����";
            }
            else
            {
                tmpset.Activate();
            }

        }
        /// <summary>
        /// ��������¼
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnDeleteChat_Click(object sender, EventArgs e)
        {
            if (DialogResult.OK == MessageBox.Show("ȷ����������¼��", "��ʾ", MessageBoxButtons.OKCancel))
            {

                var frmSchedule = new FrmSchedule();
                frmSchedule.ClearAllMsgRecord();
                LocalDataUtils.SetLongData(Constants.KEY_CLEAR_ALL_MSG_TIME, TimeUtils.CurrentTimeMillis());
                //���ﲻ��ִ�����Compte�ص��ˣ���Ϊ��FrmSchedule��Invoke(Compte)�������Լ���try catch��
                frmSchedule.Compte = () =>
                {
                    HttpUtils.Instance.PopView(frmSchedule);
                    ShowTip("ɾ�������¼�ɹ�");

                };

            }

        }
        /// <summary>
        /// ��˽����
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void chkPrivacy_CheckedChanged(object sender, EventArgs e)
        {
            if (state)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings/update")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("friendsVerify", chkPrivacy.Checked ? "1" : "0")
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            ShowTip("�޸ĺ�����֤���óɹ�");
                        }
                        else
                        {
                            ShowTip("���ú�����֤�����쳣");
                        }
                    });
            }
        }
        /// <summary>
        /// ���ܴ�������
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void chkIsEncrypt_CheckedChanged(object sender, EventArgs e)
        {
            if (state)
            {

                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings/update")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("isEncrypt", chkIsEncrypt.Checked ? "1" : "0")
                    .Build().Execute((suus, data) =>
                    {
                        if (suus)
                        {
                            Applicate.MyAccount.isEncrypt = chkIsEncrypt.Checked ? 1 : 0;
                            ShowTip("�޸ļ��ܴ������óɹ�");
                        }
                        else
                        {
                            ShowTip("���ü��ܴ�������쳣");
                        }
                    });
            }
        }
        /// <summary>
        /// ��ʾ������������
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void chkSendInput_CheckedChanged(object sender, EventArgs e)
        {
            if (state)
            {

                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings/update")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("isTyping", chkSendInput.Checked ? "1" : "0")
                    .Build().Execute((suus, data) =>
                    {
                        if (suus)
                        {
                            Applicate.MyAccount.sendInput = chkSendInput.Checked;
                            ShowTip("�޸���ʾ�����������óɹ�");
                        }
                        else
                        {
                            ShowTip("������ʾ������������쳣");
                        }
                    });
            }
        }
        /// <summary>
        /// ����¼����
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void chkMultipleDevices_CheckedChanged(object sender, EventArgs e)
        {
            if (state)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings/update")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("multipleDevices", chkMultipleDevices.Checked ? "1" : "0")
                    .Build().Execute((suus, data) =>
                    {
                        if (suus)
                        {
                            MessageBox.Show("���豸��¼���óɹ�,������������Ч", "ϵͳ��ʾ", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                            MultiDeviceManager.Instance.IsEnable = chkMultipleDevices.Checked;
                        }
                        else
                        {
                            ShowTip("���ö��豸��¼�����쳣");
                        }
                    });
            }
        }
        /// <summary>
        /// �������
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnDeleteCache_Click(object sender, EventArgs e)
        {
            string result = FileUtils.ClearAppCacheFile(Applicate.LocalConfigData.CatchPath);
            if (!string.IsNullOrEmpty(result))
            {
                ShowTip(result);
            }
        }
        /// <summary>
        /// �˳���¼
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.ShowTip("�����˳���¼...");
            ShiKuManager.ApplicationExit();
            LocalDataUtils.SetStringData(Applicate.QUIT_TIME, TimeUtils.CurrentIntTime().ToString());
            //�˴������˳��ӿ�
            Application.ExitThread();
            Application.Exit();
            Application.Restart();
            Process.GetCurrentProcess().Kill();
        }

        private void lblOverdueDate_Click(object sender, EventArgs e)
        {
            cmsOverdueDate.Show(lblOverdueDate, 0, lblOverdueDate.Height);
        }
        /// <summary>
        /// ������
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnUpdate_Click(object sender, EventArgs e)
        {

            if (Applicate.APP_VERSION.Replace(".", "") != Applicate.URLDATA.data.pcVersion && !string.IsNullOrEmpty(Applicate.URLDATA.data.pcAppUrl))
            {
                if (MessageBox.Show("���µİ汾�Ƿ���Ҫ���и���", "ϵͳ����", MessageBoxButtons.YesNo, MessageBoxIcon.Asterisk) == DialogResult.Yes)
                {
                    File.Delete("Download.config");
                    FileStream fsWrite = new FileStream("Download.config", FileMode.OpenOrCreate);
                    byte[] buffer = Encoding.Default.GetBytes(Applicate.URLDATA.data.pcAppUrl);
                    fsWrite.Write(buffer, 0, buffer.Length);
                    fsWrite.Close();
                    string path = Environment.CurrentDirectory;
                    Process process = new Process();
                    process.StartInfo.FileName = "update.exe";
                    process.StartInfo.WorkingDirectory = path; //Ҫ���õ�exe·������:"C:\windows";               
                    process.StartInfo.CreateNoWindow = true;
                    if (File.Exists(process.StartInfo.FileName))
                    {
                        process.Start();
                        Application.ExitThread();
                        Application.Exit();
                    }
                    Application.Exit();
                    System.Environment.Exit(0);
                }
            }
            else
            {

                HttpUtils.Instance.ShowTip("���޸���");

                //if (string.IsNullOrEmpty(Applicate.URLDATA.data.pcAppUrl))
                //{
                //    HttpUtils.Instance.ShowPromptBox("������������ص�ַ");
                //}
                //else
                //{
                //    HttpUtils.Instance.ShowPromptBox("���޸���");
                //}

            }




        }

        private void FrmSet_FormClosed(object sender, FormClosedEventArgs e)
        {
            Messenger.Default.Unregister(this);
        }

        /// <summary>
        /// ����ʱ��
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>

        private void HttpSubDate(string date)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings/update")
                .AddParams("access_token", Applicate.Access_Token)
               .AddParams("userId", Applicate.MyAccount.userId)
                .AddParams("chatSyncTimeLen", date)

                .Build().Execute((sucess, data) =>
                {
                    if (sucess)
                    {
                        OverdueDate(date, true);
                        LogUtils.Log("�޸ĳɹ�");
                    }
                });
        }


        /// <summary>
        /// ������Ϣ��������
        /// </summary>
        /// <param name="date"></param>
        private void OverdueDate(string date, bool a)
        {

            string save = date;
            switch (date)
            {
                case "-1":
                    lblOverdueDate.Text = "����";
                    save = "0";
                    break;
                case "0":
                    lblOverdueDate.Text = "����";
                    break;
                case "0.04":
                    lblOverdueDate.Text = "1Сʱ";
                    break;
                case "1.0":
                case "1":
                    lblOverdueDate.Text = "1��";
                    break;
                case "7.0":
                case "7":
                    lblOverdueDate.Text = "1��";
                    break;
                case "30.0":
                case "30":
                    lblOverdueDate.Text = "1��";
                    break;
                case "90.0":
                case "90":
                    lblOverdueDate.Text = "1��";
                    break;
                case "365.0":
                case "365":
                    lblOverdueDate.Text = "1��";
                    break;
                default:
                    LogUtils.Log("�޸�ʧ��");
                    save = "0";
                    break;
            }
            //if (a)
            //{
            //    LocalDataUtils.SetStringData(mFriend.userId + "chatRecordTimeOut" + Applicate.MyAccount.userId, save);
            //}

        }
        /// <summary>
        /// ����
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmForever_Click(object sender, EventArgs e)
        {
            HttpSubDate("-1");
        }
        /// <summary>
        /// 1Сʱ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmHour_Click(object sender, EventArgs e)
        {
            HttpSubDate("0.04");
        }
        /// <summary>
        /// һ��
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmDay_Click(object sender, EventArgs e)
        {
            HttpSubDate("1.0");
        }
        /// <summary>
        /// һ��
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmWeek_Click(object sender, EventArgs e)
        {
            HttpSubDate("7.0");
        }
        /// <summary>
        /// һ��
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmMonth_Click(object sender, EventArgs e)
        {
            HttpSubDate("30.0");
        }
        /// <summary>
        /// һ��
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmSeason_Click(object sender, EventArgs e)
        {
            HttpSubDate("90.0");
        }
        /// <summary>
        /// һ��
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmYear_Click(object sender, EventArgs e)
        {
            HttpSubDate("365.0");
        }
        /// <summary>
        /// ��ӷ�ʽ����
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void allowtoway_Click(object sender, EventArgs e)
        {
            //FriendFromLst = new List<string>();
            //FriendFromLst.Add("1");
            //httpaddtoway();
            FrmAddstate frmAddstate = new FrmAddstate();
            frmAddstate.FriendFromLst = FriendFromLst;
            frmAddstate.ShowDialog();
            if (frmAddstate.DialogResult == DialogResult.OK)
            {
                FriendFromLst = frmAddstate.FriendFromLst;
                httpaddtoway();
            }
        }
        /// <summary>
        /// ��ȡ�ӿڸ��·�ʽ
        /// </summary>
        /// <param name="value"></param>
        private void httpsettoway(string value)
        {
            if (state)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings/update")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("FriendFromList", value)
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            var setting = JsonConvert.DeserializeObject<object>(data["settings"].ToString());

                            var member = JsonConvert.DeserializeObject<Dictionary<string, object>>(setting.ToString());

                            string ways = UIUtils.DecodeString(member, "friendFromList");
                            AddToway(ways);
                        }
                        else
                        {
                            ShowTip("���ú�����֤�����쳣");
                        }
                    });
            }
        }
        /// <summary>
        /// ������ӷ�ʽ
        /// </summary>
        /// <param name="date"></param>
        private void AddToway(string date)
        {

            if (date == null || date == "")
            {
                lblallowtoway.Text = "";
                return;
            }
            int length = (date.Length + 1) / 2;
            string[] value = new string[length];
            if (date.Contains(','))
            {

                value = date.Split(',');
            }
            else
            {
                value[0] = date;
            }
            string towaytext = string.Empty;
            FriendFromLst = new List<string>();
            for (int i = 0; i < value.Length; i++)
            {
                string save = date;
                if (value[i] == "0")
                {
                    continue;
                }
                FriendFromLst.Add(value[i]);
                //switch (value[i])
                //{
                //    case "0":
                //        towaytext += "ϵͳ��Ӻ���" + ",";
                //        save = "0";
                //        break;
                //    case "1":
                //        towaytext += "��ά��" + ",";
                //        save = "0";
                //        break;
                //    case "2":
                //        towaytext += "��Ƭ" + ",";
                //        break;
                //    case "3":
                //        towaytext += "Ⱥ��" + ",";
                //        break;
                //    case "4":
                //        towaytext += "�ֻ�������" + ",";
                //        break;
                //    case "5":
                //        towaytext += "�ǳ�����" + ",";
                //        break;
                //    default:
                //        LogUtils.Log("�޸�ʧ��");
                //        save = "0";
                //        break;
                //}
            }
            lblallowtoway.Text = value.Length + "��";
        }



        /// <summary>
        /// �����ֻ�������
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void chkAllowtoPhone_Click(object sender, EventArgs e)
        {
            if (state)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings/update")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("phoneSearch", chkAllowtoPhone.Checked ? "1" : "0")
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            ShowTip("�޸��ֻ����������óɹ�");
                        }
                        else
                        {
                            ShowTip("�����ֻ����������ó����쳣");
                        }
                    });
            }

        }
        /// <summary>
        /// �ǳ�
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void chkAllowtoNickname_Click(object sender, EventArgs e)
        {
            if (state)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings/update")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("nameSearch", chkAllowtoNickname.Checked ? "1" : "0")
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            ShowTip("�޸��ǳ��������óɹ�");
                        }
                        else
                        {
                            ShowTip("�����ǳ��������ó����쳣");
                        }
                    });
            }
        }
        /// <summary>
        /// �������к��������¼��xls��ʽ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btninputAllfriendxls_Click(object sender, EventArgs e)
        {
            string personImgPath = "";
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            dialog.Description = "��ѡ���ļ�·��";

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                personImgPath = dialog.SelectedPath;

            }
            else
            {
                return;
            }
            if (!btninputAllfriendxls.Enabled)
            { return; }
            btninputAllfriendxls.Enabled = false;
            //�ҽ�ҵ������߳��ﴦ��,���������߳���,this.btnConfirm.Enabled = false;�����н�ֹЧ��,��Ϊ�������߳�û����ɡ�
            Task task = new Task(() =>
            {
                savetoExcel(getfriendorroomLst(0), personImgPath);
                btninputAllfriendxls.Enabled = true;
            }
            );
            task.Start();
        }
        /// <summary>
        /// ��ȡ���к��������¼
        /// </summary>
        /// <returns></returns>
        private List<MessageObject> friendlistchat(string toUserid)
        {
            List<MessageObject> messages = new MessageObject()
            {
                FromId = Applicate.MyAccount.userId,
                ToId = toUserid
            }.LoadRecordMsg();
            return messages;
        }
        /// <summary>
        /// ��ȡȺ������������¼
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btninputAllroomxls_Click(object sender, EventArgs e)
        {
            string personImgPath = "";
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            dialog.Description = "��ѡ���ļ�·��";

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                personImgPath = dialog.SelectedPath;

            }
            else
            {
                return;
            }
            if (!btninputAllroomxls.Enabled)
            { return; }
            btninputAllroomxls.Enabled = false;
            //�ҽ�ҵ������߳��ﴦ��,���������߳���,this.btnConfirm.Enabled = false;�����н�ֹЧ��,��Ϊ�������߳�û����ɡ�
            Task task = new Task(() =>
            {
                savetoExcel(getfriendorroomLst(1), personImgPath);
                btninputAllroomxls.Enabled = true;
            }
            );
            task.Start();

        }
        /// <summary>
        /// ������ݿ�ĺ��ѻ���Ⱥ���б�
        /// </summary>
        /// <param name="flag">0��ʾ���ѣ�1��ʾȺ��</param>
        private List<Friend> getfriendorroomLst(int flag)
        {
            Friend friend = new Friend { UserId = Applicate.MyAccount.userId };
            List<Friend> friendlst = new List<Friend>();
            if (flag == 0)
            {
                return friendlst = friend.GetFriendsList();//�����б�
            }
            else
            {
                return friendlst = friend.GetGroupsList();//Ⱥ���б�
            }
        }
        /// <summary>
        /// ����Ϊexcel
        /// </summary>
        /// <param name="friendlst">���ѻ�Ⱥ���б�</param>

        private void savetoExcel(List<Friend> friendlst, string personImgPath)
        {

            List<MessageObject> Alllist = new List<MessageObject>();
            for (int i = 0; i < friendlst.Count; i++)
            {
                Alllist = new List<MessageObject>();
                Alllist = friendlistchat(friendlst[i].UserId);
                string filepath = string.Empty;
                if (friendlst[i].IsGroup == 0)
                {
                    filepath = personImgPath + "\\" + friendlst[i].NickName + "��" + Applicate.MyAccount.nickname + "�������¼" + (friendlst[i].UserId).Substring(friendlst[i].UserId.Length - 4, 4) + ".xlsx"; //�ļ�·��(����)
                }
                else
                {
                    filepath = personImgPath + "\\" + friendlst[i].NickName + "�������¼" + (friendlst[i].UserId).Substring(friendlst[i].UserId.Length - 4, 4) + ".xlsx"; //�ļ�·����Ⱥ�飩
                }
                if (File.Exists(filepath))
                {
                    File.Delete(filepath);
                }
                DataTable dt = new DataTable();
                dt.Columns.Add("������");//��

                dt.Columns.Add("����");
                dt.Columns.Add("ʱ��");
                dt.Columns.Add("����");

                for (int j = 0; j < Alllist.Count; j++)
                {
                    DataRow dr2 = dt.NewRow();//��
                    dr2[0] = Alllist[j].fromUserName;
                    if (Alllist[j].content == null)
                    {
                        Alllist[j].content = "";
                    }
                    dr2[1] = Alllist[j].content;
                    dr2[2] = TimeUtils.FromatTime(Convert.ToInt64(Alllist[j].timeSend), "yyyy / MM / dd HH: mm:ss");
                    dr2[3] = UIUtils.NewstypeTostring(Alllist[j].type);
                    dt.Rows.Add(dr2);
                }
                InputFileUtils.DataTableToExcel(filepath, dt, false);//����exele,
            }

        }
        /// <summary>
        /// ȫ�����ѵ���txt
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btninputAllfriendtxt_Click(object sender, EventArgs e)
        {
            string personImgPath = "";
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            dialog.Description = "��ѡ���ļ�·��";

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                personImgPath = dialog.SelectedPath;

            }

            else
            {
                return;
            }
            if (!btninputAllfriendtxt.Enabled)
            { return; }
            btninputAllfriendtxt.Enabled = false;
            //�ҽ�ҵ������߳��ﴦ��,���������߳���,this.btnConfirm.Enabled = false;�����н�ֹЧ��,��Ϊ�������߳�û����ɡ�
            Task task = new Task(() =>
            {
                SaveTotxt(getfriendorroomLst(0), personImgPath);
                btninputAllfriendtxt.Enabled = true;
            }
            );
            task.Start();
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="friendlst">Ⱥ���б������б�</param>
        private void SaveTotxt(List<Friend> friendlst, string personImgPath)
        {
            List<MessageObject> Alllist = new List<MessageObject>();
            for (int i = 0; i < friendlst.Count; i++)
            {
                Alllist = new List<MessageObject>();
                Alllist = friendlistchat(friendlst[i].UserId);
                string filepath = string.Empty;
                if (friendlst[i].IsGroup == 0)
                {
                    filepath = personImgPath + "\\" + friendlst[i].NickName + "��" + Applicate.MyAccount.nickname + "�������¼" + (friendlst[i].UserId).Substring(friendlst[i].UserId.Length - 4, 4) + ".txt"; //�ļ�·��(����)
                }
                else
                {
                    filepath = personImgPath + "\\" + friendlst[i].NickName + "�������¼" + (friendlst[i].UserId).Substring(friendlst[i].UserId.Length - 4, 4) + ".txt"; //�ļ�·����Ⱥ�飩
                }
                if (File.Exists(filepath))
                {
                    File.Delete(filepath);
                }
                InputFileUtils.SaveTxtFile(Alllist, filepath);//�����ļ�
            }

        }
        /// <summary>
        /// Ⱥ��txt�ļ�
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btninputAllroomtxt_Click(object sender, EventArgs e)
        {
            string personImgPath = "";
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            dialog.Description = "��ѡ���ļ�·��";

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                personImgPath = dialog.SelectedPath;

            }

            else
            {
                return;
            }
            if (!btninputAllroomtxt.Enabled)
            { return; }
            btninputAllroomtxt.Enabled = false;
            //�ҽ�ҵ������߳��ﴦ��,���������߳���,this.btnConfirm.Enabled = false;�����н�ֹЧ��,��Ϊ�������߳�û����ɡ�
            Task task = new Task(() =>
            {
                SaveTotxt(getfriendorroomLst(1), personImgPath);
                btninputAllroomtxt.Enabled = true;
            }
            );
            task.Start();
        }
        /// <summary>
        /// �������߹رտͷ�ģʽ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void chkAllowtoCustomer_Click(object sender, EventArgs e)
        {
            if (state)
            {
                SetCustomer();
            }
        }
        /// <summary>
        /// ���ÿͷ�ģʽ�����ʧ�ܾͱ���ԭ�������ã�
        /// </summary>
        private void SetCustomer()
        {
            string openSerivice = chkAllowtoCustomer.Checked ? "1" : "0";
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/employee/findEmployee")
              .AddParams("access_token", Applicate.Access_Token)
              .AddParams("companyId", "5cd2fdfd0c03d03c19a109c7")
              .AddParams("departmentId", "5cd2fdfd0c03d03c19a109c9")
                .AddParams("openService", openSerivice)
                  .AddParams("userId", Applicate.MyAccount.userId)
               .Build().Execute((suss, data) =>
               {
                   if (suss)
                   {
                       HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/employee/updateEmployee")
               .AddParams("access_token", Applicate.Access_Token)
               .AddParams("companyId", "5cd2fdfd0c03d03c19a109c7")
                 .AddParams("isPause", openSerivice)
               .AddParams("departmentId", "5cd2fdfd0c03d03c19a109c9")
               .AddParams("userId", Applicate.MyAccount.userId)
                .Build().Execute((sucess, result) =>
                {
                    if (sucess)
                    {
                        HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings/update")
                   .AddParams("access_token", Applicate.Access_Token)
                   .AddParams("openService", chkAllowtoCustomer.Checked ? "1" : "0")
                   .Build().Execute((s, dt) =>
                   {
                       if (s)
                       {
                           if (chkAllowtoCustomer.Checked)
                           {
                               Applicate.ServiceMode = true;
                               ShowTip("�ͻ�ģʽ����");
                           }
                           else
                           {
                               Applicate.ServiceMode = true;
                               ShowTip("�ͻ�ģʽ�ر�");
                           }
                           string value = chkAllowtoCustomer.Checked ? "1" : "0";
                           Messenger.Default.Send(value, MessageActions.XMPP_UPDATE_CUSTOMERSERVICE);// ����UI��Ϣ
                       }
                       else
                       {
                           ShowTip("���ÿͻ�ģʽʧ��");
                           if (openSerivice == "0")
                           {
                               chkAllowtoCustomer.Checked = true;
                           }
                           else
                           {
                               chkAllowtoCustomer.Checked = false;
                           }
                       }
                   });
                    }
                    else
                    {
                        if (openSerivice == "0")
                        {
                            chkAllowtoCustomer.Checked = true;
                        }
                        else
                        {
                            chkAllowtoCustomer.Checked = false;
                        }
                    }
                });
                   }
                   else
                   {
                       if (openSerivice == "0")
                       {
                           chkAllowtoCustomer.Checked = true;
                       }
                       else
                       {
                           chkAllowtoCustomer.Checked = false;
                       }
                   }
               });
        }


        private void httpaddtoway()
        {
            string value = string.Empty;
            for (int i = 0; i < FriendFromLst.Count; i++)
            {
                if (i != (FriendFromLst.Count - 1))
                    value += FriendFromLst[i] + ",";
                else
                {
                    value += FriendFromLst[i];
                }
            }
            if (state)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/settings/update")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("FriendFromList", value)
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            var setting = JsonConvert.DeserializeObject<object>(data["settings"].ToString());

                            var member = JsonConvert.DeserializeObject<Dictionary<string, object>>(setting.ToString());

                            string ways = UIUtils.DecodeString(member, "friendFromList");
                            AddToway(ways);
                        }
                        else
                        {
                            ShowTip("���ú�����֤�����쳣");
                        }
                    });
            }
        }

        private void txtNewPwd_KeyPress(object sender, KeyPressEventArgs e)
        {

            if ((int)e.KeyChar == 32)
            {
                e.Handled = true;
            }

        }


    }
}

