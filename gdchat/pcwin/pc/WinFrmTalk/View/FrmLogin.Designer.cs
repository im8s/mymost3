using WinFrmTalk.Controls.SystemControls;
using WinFrmTalk.Properties;

namespace WinFrmTalk
{
    partial class FrmLogin
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmLogin));
            this.lbliconAccount = new System.Windows.Forms.Label();
            this.lbliconPassword = new System.Windows.Forms.Label();
            this.lblRegister = new LollipopFlatButton();
            this.txtTelephone = new System.Windows.Forms.TextBox();
            this.txtPassword = new System.Windows.Forms.TextBox();
            this.btnLogin = new System.Windows.Forms.Button();
            this.panel1 = new System.Windows.Forms.Panel();
            this.chkRememberPwd = new LollipopCheckBox();
            this.panel2 = new System.Windows.Forms.Panel();
            this.panel3 = new System.Windows.Forms.Panel();
            this.btnForgetPwd = new LollipopFlatButton();
            this.lblContry = new System.Windows.Forms.Label();
            this.login_tip = new LollipopFlatButton();
            this.picServer = new System.Windows.Forms.PictureBox();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picServer)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // lbliconAccount
            // 
            this.lbliconAccount.AutoSize = true;
            this.lbliconAccount.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lbliconAccount.ForeColor = System.Drawing.SystemColors.ControlDarkDark;
            this.lbliconAccount.Location = new System.Drawing.Point(45, 177);
            this.lbliconAccount.Name = "lbliconAccount";
            this.lbliconAccount.Size = new System.Drawing.Size(44, 17);
            this.lbliconAccount.TabIndex = 20;
            this.lbliconAccount.Text = "账号：";
            // 
            // lbliconPassword
            // 
            this.lbliconPassword.AutoSize = true;
            this.lbliconPassword.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lbliconPassword.ForeColor = System.Drawing.SystemColors.ControlDarkDark;
            this.lbliconPassword.Location = new System.Drawing.Point(45, 225);
            this.lbliconPassword.Name = "lbliconPassword";
            this.lbliconPassword.Size = new System.Drawing.Size(44, 17);
            this.lbliconPassword.TabIndex = 20;
            this.lbliconPassword.Text = "密码：";
            // 
            // lblRegister
            // 
            this.lblRegister.BackColor = System.Drawing.Color.Transparent;
            this.lblRegister.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblRegister.Enabled = false;
            this.lblRegister.Font = new System.Drawing.Font("微软雅黑", 9F);
            this.lblRegister.FontColor = "#1AAD19";
            this.lblRegister.Location = new System.Drawing.Point(127, 368);
            this.lblRegister.Name = "lblRegister";
            this.lblRegister.Size = new System.Drawing.Size(61, 20);
            this.lblRegister.TabIndex = 19;
            this.lblRegister.Text = "账号注册";
            this.lblRegister.Click += new System.EventHandler(this.lblRegister_Click);
            // 
            // txtTelephone
            // 
            this.txtTelephone.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.txtTelephone.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.txtTelephone.Location = new System.Drawing.Point(153, 177);
            this.txtTelephone.Name = "txtTelephone";
            this.txtTelephone.ShortcutsEnabled = false;
            this.txtTelephone.Size = new System.Drawing.Size(111, 16);
            this.txtTelephone.TabIndex = 0;
            this.txtTelephone.TextChanged += new System.EventHandler(this.txtTelephone_TextChanged);
            this.txtTelephone.KeyDown += new System.Windows.Forms.KeyEventHandler(this.LoginKeyDown);
            this.txtTelephone.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtTelephone_KeyPress);
            this.txtTelephone.KeyUp += new System.Windows.Forms.KeyEventHandler(this.txtTelephone_KeyUp);
            // 
            // txtPassword
            // 
            this.txtPassword.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.txtPassword.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.txtPassword.Location = new System.Drawing.Point(86, 222);
            this.txtPassword.Name = "txtPassword";
            this.txtPassword.PasswordChar = '●';
            this.txtPassword.Size = new System.Drawing.Size(178, 16);
            this.txtPassword.TabIndex = 1;
            this.txtPassword.KeyDown += new System.Windows.Forms.KeyEventHandler(this.LoginKeyDown);
            // 
            // btnLogin
            // 
            this.btnLogin.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.btnLogin.FlatAppearance.BorderSize = 0;
            this.btnLogin.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnLogin.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnLogin.ForeColor = System.Drawing.Color.Black;
            this.btnLogin.Location = new System.Drawing.Point(0, 0);
            this.btnLogin.Name = "btnLogin";
            this.btnLogin.Size = new System.Drawing.Size(161, 38);
            this.btnLogin.TabIndex = 23;
            this.btnLogin.Text = "登录";
            this.btnLogin.UseVisualStyleBackColor = false;
            this.btnLogin.Click += new System.EventHandler(this.btnLogin_Click);
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.btnLogin);
            this.panel1.Location = new System.Drawing.Point(77, 314);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(161, 38);
            this.panel1.TabIndex = 27;
            // 
            // chkRememberPwd
            // 
            this.chkRememberPwd.AutoSize = true;
            this.chkRememberPwd.CheckColor = "#1AAD19";
            this.chkRememberPwd.Font = new System.Drawing.Font("微软雅黑", 8F);
            this.chkRememberPwd.Location = new System.Drawing.Point(86, 258);
            this.chkRememberPwd.Name = "chkRememberPwd";
            this.chkRememberPwd.Size = new System.Drawing.Size(84, 20);
            this.chkRememberPwd.TabIndex = 33;
            this.chkRememberPwd.Text = "记住密码";
            this.chkRememberPwd.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.chkRememberPwd.UseVisualStyleBackColor = true;
            // 
            // panel2
            // 
            this.panel2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(210)))), ((int)(((byte)(210)))), ((int)(((byte)(210)))), ((int)(((byte)(210)))));
            this.panel2.Location = new System.Drawing.Point(153, 196);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(111, 1);
            this.panel2.TabIndex = 39;
            // 
            // panel3
            // 
            this.panel3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(210)))), ((int)(((byte)(210)))), ((int)(((byte)(210)))), ((int)(((byte)(210)))));
            this.panel3.Location = new System.Drawing.Point(86, 241);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(178, 1);
            this.panel3.TabIndex = 40;
            // 
            // btnForgetPwd
            // 
            this.btnForgetPwd.BackColor = System.Drawing.Color.Transparent;
            this.btnForgetPwd.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnForgetPwd.Enabled = false;
            this.btnForgetPwd.Font = new System.Drawing.Font("微软雅黑", 9F);
            this.btnForgetPwd.FontColor = "#1AAD19";
            this.btnForgetPwd.Location = new System.Drawing.Point(203, 258);
            this.btnForgetPwd.Name = "btnForgetPwd";
            this.btnForgetPwd.Size = new System.Drawing.Size(61, 20);
            this.btnForgetPwd.TabIndex = 19;
            this.btnForgetPwd.Text = "忘记密码";
            this.btnForgetPwd.Click += new System.EventHandler(this.btnForgetPwd_Click);
            // 
            // lblContry
            // 
            this.lblContry.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lblContry.Location = new System.Drawing.Point(86, 176);
            this.lblContry.Name = "lblContry";
            this.lblContry.Size = new System.Drawing.Size(58, 21);
            this.lblContry.TabIndex = 45;
            this.lblContry.Text = "+86";
            this.lblContry.Click += new System.EventHandler(this.cmbAreaCode_Click);
            // 
            // login_tip
            // 
            this.login_tip.BackColor = System.Drawing.Color.Transparent;
            this.login_tip.Cursor = System.Windows.Forms.Cursors.Hand;
            this.login_tip.Enabled = false;
            this.login_tip.Font = new System.Drawing.Font("微软雅黑", 9F);
            this.login_tip.FontColor = "#000000";
            this.login_tip.Location = new System.Drawing.Point(48, 382);
            this.login_tip.Name = "login_tip";
            this.login_tip.Size = new System.Drawing.Size(216, 20);
            this.login_tip.TabIndex = 50;
            this.login_tip.Text = "正在下载数据";
            this.login_tip.Visible = false;
            // 
            // picServer
            // 
            this.picServer.Cursor = System.Windows.Forms.Cursors.Hand;
            this.picServer.Location = new System.Drawing.Point(0, 0);
            this.picServer.Name = "picServer";
            this.picServer.Size = new System.Drawing.Size(20, 20);
            this.picServer.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.picServer.TabIndex = 30;
            this.picServer.TabStop = false;
            this.picServer.Click += new System.EventHandler(this.picServer_Click);
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = global::WinFrmTalk.Properties.Resources.Logo;
            this.pictureBox1.Location = new System.Drawing.Point(123, 58);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(68, 68);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pictureBox1.TabIndex = 1;
            this.pictureBox1.TabStop = false;
            this.pictureBox1.Click += new System.EventHandler(this.pictureBox1_Click);
            // 
            // FrmLogin
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 17F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(314, 435);
            this.Controls.Add(this.login_tip);
            this.Controls.Add(this.lblContry);
            this.Controls.Add(this.panel3);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.chkRememberPwd);
            this.Controls.Add(this.picServer);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.txtPassword);
            this.Controls.Add(this.txtTelephone);
            this.Controls.Add(this.lbliconPassword);
            this.Controls.Add(this.lbliconAccount);
            this.Controls.Add(this.btnForgetPwd);
            this.Controls.Add(this.lblRegister);
            this.Controls.Add(this.pictureBox1);
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.Name = "FrmLogin";
            this.ShowBorder = false;
            this.ShowDrawIcon = false;
            this.ShowIcon = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "登录";
            this.TitleColor = System.Drawing.Color.Gray;
            this.TitleNeed = false;
            this.Load += new System.EventHandler(this.FrmLogin_Load);
            this.KeyDown += new System.Windows.Forms.KeyEventHandler(this.LoginKeyDown);
            this.panel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.picServer)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.PictureBox pictureBox1;
        private LollipopFlatButton lblRegister;
        private System.Windows.Forms.Label lbliconAccount;
        private System.Windows.Forms.Label lbliconPassword;
        private System.Windows.Forms.TextBox txtTelephone;
        private System.Windows.Forms.TextBox txtPassword;
        private System.Windows.Forms.Button btnLogin;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.PictureBox picServer;
        private LollipopCheckBox chkRememberPwd;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.Panel panel3;
        private LollipopFlatButton btnForgetPwd;
        private System.Windows.Forms.Label lblContry;
        private LollipopFlatButton login_tip;
    }
}