using System.Drawing;

namespace WinFrmTalk
{
    partial class FrmSet
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmSet));
            this.tabSet = new CCWin.SkinControl.SkinTabControl();
            this.skinTabPage1 = new CCWin.SkinControl.SkinTabPage();
            this.picHead = new WinFrmTalk.RoundPicBox();
            this.skinLine2 = new CCWin.SkinControl.SkinLine();
            this.btnEdit = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.skinTabPage2 = new CCWin.SkinControl.SkinTabPage();
            this.btninputAllroomtxt = new System.Windows.Forms.Button();
            this.btninputAllfriendtxt = new System.Windows.Forms.Button();
            this.btninputAllroomxls = new System.Windows.Forms.Button();
            this.btninputAllfriendxls = new System.Windows.Forms.Button();
            this.skinLine5 = new CCWin.SkinControl.SkinLine();
            this.btnDeleteChat = new System.Windows.Forms.Button();
            this.btnDeleteCache = new System.Windows.Forms.Button();
            this.skinTabPage3 = new CCWin.SkinControl.SkinTabPage();
            this.picallowtoway = new System.Windows.Forms.PictureBox();
            this.chkAllowtoCustomer = new WinFrmTalk.Controls.CustomControls.USEToggle();
            this.label4 = new System.Windows.Forms.Label();
            this.chkAllowtoNickname = new WinFrmTalk.Controls.CustomControls.USEToggle();
            this.chkAllowtoPhone = new WinFrmTalk.Controls.CustomControls.USEToggle();
            this.label10 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.lblallowtoway = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.chkPrivacy = new WinFrmTalk.Controls.CustomControls.USEToggle();
            this.chkIsEncrypt = new WinFrmTalk.Controls.CustomControls.USEToggle();
            this.chkSendInput = new WinFrmTalk.Controls.CustomControls.USEToggle();
            this.chkMultipleDevices = new WinFrmTalk.Controls.CustomControls.USEToggle();
            this.picnewstime = new System.Windows.Forms.PictureBox();
            this.lblOverdueDate = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.label8 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.skinLine4 = new CCWin.SkinControl.SkinLine();
            this.skinTabPage4 = new CCWin.SkinControl.SkinTabPage();
            this.txtConfirmPwd = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.txtNewPwd = new System.Windows.Forms.TextBox();
            this.txtOldPwd = new System.Windows.Forms.TextBox();
            this.lbliconPassword = new System.Windows.Forms.Label();
            this.lbliconAccount = new System.Windows.Forms.Label();
            this.btnRevise = new LollipopButton();
            this.skinLine3 = new CCWin.SkinControl.SkinLine();
            this.skinTabPage5 = new CCWin.SkinControl.SkinTabPage();
            this.lblCompanyName = new System.Windows.Forms.Label();
            this.lblCopyright = new System.Windows.Forms.Label();
            this.skinLine1 = new CCWin.SkinControl.SkinLine();
            this.btnUpdate = new System.Windows.Forms.Button();
            this.lblEdition = new System.Windows.Forms.Label();
            this.picLogo = new System.Windows.Forms.PictureBox();
            this.cmsOverdueDate = new CCWin.SkinControl.SkinContextMenuStrip();
            this.tsmForever = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmHour = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmDay = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmWeek = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmMonth = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmSeason = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmYear = new System.Windows.Forms.ToolStripMenuItem();
            this.contextMenuStrip1 = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.toolStripComboBox2 = new System.Windows.Forms.ToolStripComboBox();
            this.toolStripComboBox3 = new System.Windows.Forms.ToolStripComboBox();
            this.toolStripComboBox1 = new System.Windows.Forms.ToolStripComboBox();
            this.toolStripComboBox4 = new System.Windows.Forms.ToolStripComboBox();
            this.toolStripComboBox5 = new System.Windows.Forms.ToolStripComboBox();
            this.toolStripComboBox6 = new System.Windows.Forms.ToolStripComboBox();
            this.tabSet.SuspendLayout();
            this.skinTabPage1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picHead)).BeginInit();
            this.skinTabPage2.SuspendLayout();
            this.skinTabPage3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picallowtoway)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picnewstime)).BeginInit();
            this.skinTabPage4.SuspendLayout();
            this.skinTabPage5.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picLogo)).BeginInit();
            this.cmsOverdueDate.SuspendLayout();
            this.contextMenuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // tabSet
            // 
            this.tabSet.AnimatorType = CCWin.SkinControl.AnimationType.HorizSlide;
            this.tabSet.ArrowBaseColor = System.Drawing.SystemColors.Control;
            this.tabSet.ArrowBorderColor = System.Drawing.SystemColors.Control;
            this.tabSet.ArrowColor = System.Drawing.SystemColors.Control;
            this.tabSet.BackColor = System.Drawing.SystemColors.Control;
            this.tabSet.CloseRect = new System.Drawing.Rectangle(2, 2, 12, 12);
            this.tabSet.Controls.Add(this.skinTabPage1);
            this.tabSet.Controls.Add(this.skinTabPage2);
            this.tabSet.Controls.Add(this.skinTabPage3);
            this.tabSet.Controls.Add(this.skinTabPage4);
            this.tabSet.Controls.Add(this.skinTabPage5);
            this.tabSet.Cursor = System.Windows.Forms.Cursors.Default;
            this.tabSet.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.tabSet.HeadBack = null;
            this.tabSet.ImgTxtOffset = new System.Drawing.Point(0, 0);
            this.tabSet.ItemSize = new System.Drawing.Size(80, 36);
            this.tabSet.Location = new System.Drawing.Point(12, 46);
            this.tabSet.Name = "tabSet";
            this.tabSet.PageArrowDown = null;
            this.tabSet.PageArrowHover = null;
            this.tabSet.PageBaseColor = System.Drawing.SystemColors.Control;
            this.tabSet.PageBorderColor = System.Drawing.Color.White;
            this.tabSet.PageCloseHover = ((System.Drawing.Image)(resources.GetObject("tabSet.PageCloseHover")));
            this.tabSet.PageCloseNormal = ((System.Drawing.Image)(resources.GetObject("tabSet.PageCloseNormal")));
            this.tabSet.PageDown = null;
            this.tabSet.PageHover = ((System.Drawing.Image)(resources.GetObject("tabSet.PageHover")));
            this.tabSet.PageHoverTxtColor = System.Drawing.Color.DimGray;
            this.tabSet.PageImagePosition = CCWin.SkinControl.SkinTabControl.ePageImagePosition.Left;
            this.tabSet.PageNorml = null;
            this.tabSet.PageNormlTxtColor = System.Drawing.Color.Gray;
            this.tabSet.SelectedIndex = 0;
            this.tabSet.Size = new System.Drawing.Size(518, 404);
            this.tabSet.SizeMode = System.Windows.Forms.TabSizeMode.Fixed;
            this.tabSet.TabIndex = 0;
            // 
            // skinTabPage1
            // 
            this.skinTabPage1.BackColor = System.Drawing.SystemColors.Control;
            this.skinTabPage1.Controls.Add(this.picHead);
            this.skinTabPage1.Controls.Add(this.skinLine2);
            this.skinTabPage1.Controls.Add(this.btnEdit);
            this.skinTabPage1.Controls.Add(this.btnCancel);
            this.skinTabPage1.Cursor = System.Windows.Forms.Cursors.Arrow;
            this.skinTabPage1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.skinTabPage1.Location = new System.Drawing.Point(0, 36);
            this.skinTabPage1.Name = "skinTabPage1";
            this.skinTabPage1.Size = new System.Drawing.Size(518, 368);
            this.skinTabPage1.TabIndex = 4;
            this.skinTabPage1.TabItemImage = null;
            this.skinTabPage1.Text = "账号设置";
            // 
            // picHead
            // 
            this.picHead.BackColor = System.Drawing.Color.Transparent;
            this.picHead.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.picHead.isDrawRound = true;
            this.picHead.Location = new System.Drawing.Point(190, 45);
            this.picHead.Name = "picHead";
            this.picHead.Size = new System.Drawing.Size(100, 100);
            this.picHead.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.picHead.TabIndex = 7;
            this.picHead.TabStop = false;
            // 
            // skinLine2
            // 
            this.skinLine2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.skinLine2.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.skinLine2.LineColor = System.Drawing.Color.DimGray;
            this.skinLine2.LineHeight = 1;
            this.skinLine2.Location = new System.Drawing.Point(0, 0);
            this.skinLine2.Name = "skinLine2";
            this.skinLine2.Size = new System.Drawing.Size(1, 405);
            this.skinLine2.TabIndex = 6;
            this.skinLine2.Text = "skinLine2";
            // 
            // btnEdit
            // 
            this.btnEdit.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnEdit.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnEdit.Location = new System.Drawing.Point(184, 172);
            this.btnEdit.Name = "btnEdit";
            this.btnEdit.Size = new System.Drawing.Size(120, 28);
            this.btnEdit.TabIndex = 1;
            this.btnEdit.Text = "编辑资料";
            this.btnEdit.UseVisualStyleBackColor = true;
            this.btnEdit.Click += new System.EventHandler(this.btnEdit_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.FlatAppearance.BorderSize = 0;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnCancel.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnCancel.Location = new System.Drawing.Point(184, 215);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(120, 28);
            this.btnCancel.TabIndex = 1;
            this.btnCancel.Text = "退出登录";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // skinTabPage2
            // 
            this.skinTabPage2.BackColor = System.Drawing.SystemColors.Control;
            this.skinTabPage2.Controls.Add(this.btninputAllroomtxt);
            this.skinTabPage2.Controls.Add(this.btninputAllfriendtxt);
            this.skinTabPage2.Controls.Add(this.btninputAllroomxls);
            this.skinTabPage2.Controls.Add(this.btninputAllfriendxls);
            this.skinTabPage2.Controls.Add(this.skinLine5);
            this.skinTabPage2.Controls.Add(this.btnDeleteChat);
            this.skinTabPage2.Controls.Add(this.btnDeleteCache);
            this.skinTabPage2.Cursor = System.Windows.Forms.Cursors.Default;
            this.skinTabPage2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.skinTabPage2.Location = new System.Drawing.Point(0, 36);
            this.skinTabPage2.Name = "skinTabPage2";
            this.skinTabPage2.Size = new System.Drawing.Size(518, 368);
            this.skinTabPage2.TabIndex = 0;
            this.skinTabPage2.TabItemImage = null;
            this.skinTabPage2.Text = "通用设置";
            // 
            // btninputAllroomtxt
            // 
            this.btninputAllroomtxt.FlatAppearance.BorderSize = 0;
            this.btninputAllroomtxt.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btninputAllroomtxt.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btninputAllroomtxt.Location = new System.Drawing.Point(184, 171);
            this.btninputAllroomtxt.Name = "btninputAllroomtxt";
            this.btninputAllroomtxt.Size = new System.Drawing.Size(168, 28);
            this.btninputAllroomtxt.TabIndex = 11;
            this.btninputAllroomtxt.Text = "导出所有群组聊天记录txt";
            this.btninputAllroomtxt.UseVisualStyleBackColor = true;
            this.btninputAllroomtxt.Click += new System.EventHandler(this.btninputAllroomtxt_Click);
            // 
            // btninputAllfriendtxt
            // 
            this.btninputAllfriendtxt.FlatAppearance.BorderSize = 0;
            this.btninputAllfriendtxt.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btninputAllfriendtxt.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btninputAllfriendtxt.Location = new System.Drawing.Point(184, 122);
            this.btninputAllfriendtxt.Name = "btninputAllfriendtxt";
            this.btninputAllfriendtxt.Size = new System.Drawing.Size(168, 28);
            this.btninputAllfriendtxt.TabIndex = 10;
            this.btninputAllfriendtxt.Text = "导出全部好友聊天记录txt";
            this.btninputAllfriendtxt.UseVisualStyleBackColor = true;
            this.btninputAllfriendtxt.Click += new System.EventHandler(this.btninputAllfriendtxt_Click);
            // 
            // btninputAllroomxls
            // 
            this.btninputAllroomxls.FlatAppearance.BorderSize = 0;
            this.btninputAllroomxls.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btninputAllroomxls.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btninputAllroomxls.Location = new System.Drawing.Point(184, 68);
            this.btninputAllroomxls.Name = "btninputAllroomxls";
            this.btninputAllroomxls.Size = new System.Drawing.Size(168, 28);
            this.btninputAllroomxls.TabIndex = 9;
            this.btninputAllroomxls.Text = "导出所有群组聊天记录xls";
            this.btninputAllroomxls.UseVisualStyleBackColor = true;
            this.btninputAllroomxls.Click += new System.EventHandler(this.btninputAllroomxls_Click);
            // 
            // btninputAllfriendxls
            // 
            this.btninputAllfriendxls.FlatAppearance.BorderSize = 0;
            this.btninputAllfriendxls.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btninputAllfriendxls.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btninputAllfriendxls.Location = new System.Drawing.Point(184, 20);
            this.btninputAllfriendxls.Name = "btninputAllfriendxls";
            this.btninputAllfriendxls.Size = new System.Drawing.Size(168, 28);
            this.btninputAllfriendxls.TabIndex = 8;
            this.btninputAllfriendxls.Text = "导出全部好友聊天记录xls";
            this.btninputAllfriendxls.UseVisualStyleBackColor = true;
            this.btninputAllfriendxls.Click += new System.EventHandler(this.btninputAllfriendxls_Click);
            // 
            // skinLine5
            // 
            this.skinLine5.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.skinLine5.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.skinLine5.LineColor = System.Drawing.Color.DimGray;
            this.skinLine5.LineHeight = 1;
            this.skinLine5.Location = new System.Drawing.Point(0, 0);
            this.skinLine5.Name = "skinLine5";
            this.skinLine5.Size = new System.Drawing.Size(1, 405);
            this.skinLine5.TabIndex = 7;
            this.skinLine5.Text = "skinLine5";
            // 
            // btnDeleteChat
            // 
            this.btnDeleteChat.FlatAppearance.BorderSize = 0;
            this.btnDeleteChat.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnDeleteChat.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnDeleteChat.Location = new System.Drawing.Point(184, 270);
            this.btnDeleteChat.Name = "btnDeleteChat";
            this.btnDeleteChat.Size = new System.Drawing.Size(168, 28);
            this.btnDeleteChat.TabIndex = 1;
            this.btnDeleteChat.Text = "清除聊天记录";
            this.btnDeleteChat.UseVisualStyleBackColor = true;
            this.btnDeleteChat.Click += new System.EventHandler(this.btnDeleteChat_Click);
            // 
            // btnDeleteCache
            // 
            this.btnDeleteCache.FlatAppearance.BorderSize = 0;
            this.btnDeleteCache.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnDeleteCache.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnDeleteCache.Location = new System.Drawing.Point(184, 222);
            this.btnDeleteCache.Name = "btnDeleteCache";
            this.btnDeleteCache.Size = new System.Drawing.Size(168, 28);
            this.btnDeleteCache.TabIndex = 0;
            this.btnDeleteCache.Text = "清除缓存";
            this.btnDeleteCache.UseVisualStyleBackColor = true;
            this.btnDeleteCache.Click += new System.EventHandler(this.btnDeleteCache_Click);
            // 
            // skinTabPage3
            // 
            this.skinTabPage3.BackColor = System.Drawing.SystemColors.Control;
            this.skinTabPage3.Controls.Add(this.picallowtoway);
            this.skinTabPage3.Controls.Add(this.chkAllowtoCustomer);
            this.skinTabPage3.Controls.Add(this.label4);
            this.skinTabPage3.Controls.Add(this.chkAllowtoNickname);
            this.skinTabPage3.Controls.Add(this.chkAllowtoPhone);
            this.skinTabPage3.Controls.Add(this.label10);
            this.skinTabPage3.Controls.Add(this.label9);
            this.skinTabPage3.Controls.Add(this.lblallowtoway);
            this.skinTabPage3.Controls.Add(this.label5);
            this.skinTabPage3.Controls.Add(this.chkPrivacy);
            this.skinTabPage3.Controls.Add(this.chkIsEncrypt);
            this.skinTabPage3.Controls.Add(this.chkSendInput);
            this.skinTabPage3.Controls.Add(this.chkMultipleDevices);
            this.skinTabPage3.Controls.Add(this.picnewstime);
            this.skinTabPage3.Controls.Add(this.lblOverdueDate);
            this.skinTabPage3.Controls.Add(this.label7);
            this.skinTabPage3.Controls.Add(this.label8);
            this.skinTabPage3.Controls.Add(this.label6);
            this.skinTabPage3.Controls.Add(this.label3);
            this.skinTabPage3.Controls.Add(this.label2);
            this.skinTabPage3.Controls.Add(this.skinLine4);
            this.skinTabPage3.Cursor = System.Windows.Forms.Cursors.Default;
            this.skinTabPage3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.skinTabPage3.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.skinTabPage3.Location = new System.Drawing.Point(0, 36);
            this.skinTabPage3.Name = "skinTabPage3";
            this.skinTabPage3.Size = new System.Drawing.Size(518, 368);
            this.skinTabPage3.TabIndex = 1;
            this.skinTabPage3.TabItemImage = null;
            this.skinTabPage3.Text = "隐私设置";
            // 
            // picallowtoway
            // 
            this.picallowtoway.BackColor = System.Drawing.Color.Transparent;
            this.picallowtoway.Image = global::WinFrmTalk.Properties.Resources.right;
            this.picallowtoway.Location = new System.Drawing.Point(406, 292);
            this.picallowtoway.Name = "picallowtoway";
            this.picallowtoway.Size = new System.Drawing.Size(12, 12);
            this.picallowtoway.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.picallowtoway.TabIndex = 42;
            this.picallowtoway.TabStop = false;
            this.picallowtoway.Click += new System.EventHandler(this.allowtoway_Click);
            // 
            // chkAllowtoCustomer
            // 
            this.chkAllowtoCustomer.BackColor = System.Drawing.Color.Transparent;
            this.chkAllowtoCustomer.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.chkAllowtoCustomer.Checked = false;
            this.chkAllowtoCustomer.checkStyle = WinFrmTalk.Controls.CustomControls.CheckStyle.style1;
            this.chkAllowtoCustomer.Cursor = System.Windows.Forms.Cursors.Hand;
            this.chkAllowtoCustomer.Location = new System.Drawing.Point(330, 318);
            this.chkAllowtoCustomer.Margin = new System.Windows.Forms.Padding(3, 11, 3, 11);
            this.chkAllowtoCustomer.Name = "chkAllowtoCustomer";
            this.chkAllowtoCustomer.Size = new System.Drawing.Size(31, 30);
            this.chkAllowtoCustomer.TabIndex = 41;
            this.chkAllowtoCustomer.Click += new System.EventHandler(this.chkAllowtoCustomer_Click);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label4.ForeColor = System.Drawing.Color.Gray;
            this.label4.Location = new System.Drawing.Point(97, 330);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(56, 17);
            this.label4.TabIndex = 40;
            this.label4.Text = "客服模式";
            // 
            // chkAllowtoNickname
            // 
            this.chkAllowtoNickname.BackColor = System.Drawing.Color.Transparent;
            this.chkAllowtoNickname.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.chkAllowtoNickname.Checked = false;
            this.chkAllowtoNickname.checkStyle = WinFrmTalk.Controls.CustomControls.CheckStyle.style1;
            this.chkAllowtoNickname.Cursor = System.Windows.Forms.Cursors.Hand;
            this.chkAllowtoNickname.Location = new System.Drawing.Point(330, 207);
            this.chkAllowtoNickname.Margin = new System.Windows.Forms.Padding(3, 8, 3, 8);
            this.chkAllowtoNickname.Name = "chkAllowtoNickname";
            this.chkAllowtoNickname.Size = new System.Drawing.Size(31, 30);
            this.chkAllowtoNickname.TabIndex = 39;
            this.chkAllowtoNickname.Click += new System.EventHandler(this.chkAllowtoNickname_Click);
            // 
            // chkAllowtoPhone
            // 
            this.chkAllowtoPhone.BackColor = System.Drawing.Color.Transparent;
            this.chkAllowtoPhone.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.chkAllowtoPhone.Checked = false;
            this.chkAllowtoPhone.checkStyle = WinFrmTalk.Controls.CustomControls.CheckStyle.style1;
            this.chkAllowtoPhone.Cursor = System.Windows.Forms.Cursors.Hand;
            this.chkAllowtoPhone.Location = new System.Drawing.Point(330, 169);
            this.chkAllowtoPhone.Margin = new System.Windows.Forms.Padding(3, 8, 3, 8);
            this.chkAllowtoPhone.Name = "chkAllowtoPhone";
            this.chkAllowtoPhone.Size = new System.Drawing.Size(31, 30);
            this.chkAllowtoPhone.TabIndex = 38;
            this.chkAllowtoPhone.Click += new System.EventHandler(this.chkAllowtoPhone_Click);
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label10.ForeColor = System.Drawing.Color.Gray;
            this.label10.Location = new System.Drawing.Point(97, 214);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(116, 17);
            this.label10.TabIndex = 37;
            this.label10.Text = "允许通过昵称搜索我";
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label9.ForeColor = System.Drawing.Color.Gray;
            this.label9.Location = new System.Drawing.Point(97, 176);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(128, 17);
            this.label9.TabIndex = 36;
            this.label9.Text = "允许通过手机号搜索我";
            // 
            // lblallowtoway
            // 
            this.lblallowtoway.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblallowtoway.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblallowtoway.ForeColor = System.Drawing.Color.Gray;
            this.lblallowtoway.Location = new System.Drawing.Point(327, 288);
            this.lblallowtoway.Name = "lblallowtoway";
            this.lblallowtoway.Size = new System.Drawing.Size(114, 19);
            this.lblallowtoway.TabIndex = 33;
            this.lblallowtoway.Text = "二维码";
            this.lblallowtoway.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.lblallowtoway.Click += new System.EventHandler(this.allowtoway_Click);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label5.ForeColor = System.Drawing.Color.Gray;
            this.label5.Location = new System.Drawing.Point(97, 290);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(92, 17);
            this.label5.TabIndex = 34;
            this.label5.Text = "允许加我的方式";
            // 
            // chkPrivacy
            // 
            this.chkPrivacy.BackColor = System.Drawing.Color.Transparent;
            this.chkPrivacy.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.chkPrivacy.Checked = false;
            this.chkPrivacy.checkStyle = WinFrmTalk.Controls.CustomControls.CheckStyle.style1;
            this.chkPrivacy.Cursor = System.Windows.Forms.Cursors.Hand;
            this.chkPrivacy.Location = new System.Drawing.Point(330, 17);
            this.chkPrivacy.Margin = new System.Windows.Forms.Padding(3, 8, 3, 8);
            this.chkPrivacy.Name = "chkPrivacy";
            this.chkPrivacy.Size = new System.Drawing.Size(31, 30);
            this.chkPrivacy.TabIndex = 32;
            this.chkPrivacy.Click += new System.EventHandler(this.chkPrivacy_CheckedChanged);
            // 
            // chkIsEncrypt
            // 
            this.chkIsEncrypt.BackColor = System.Drawing.Color.Transparent;
            this.chkIsEncrypt.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.chkIsEncrypt.Checked = false;
            this.chkIsEncrypt.checkStyle = WinFrmTalk.Controls.CustomControls.CheckStyle.style1;
            this.chkIsEncrypt.Cursor = System.Windows.Forms.Cursors.Hand;
            this.chkIsEncrypt.Location = new System.Drawing.Point(330, 55);
            this.chkIsEncrypt.Margin = new System.Windows.Forms.Padding(3, 6, 3, 6);
            this.chkIsEncrypt.Name = "chkIsEncrypt";
            this.chkIsEncrypt.Size = new System.Drawing.Size(31, 30);
            this.chkIsEncrypt.TabIndex = 31;
            this.chkIsEncrypt.Click += new System.EventHandler(this.chkIsEncrypt_CheckedChanged);
            // 
            // chkSendInput
            // 
            this.chkSendInput.BackColor = System.Drawing.Color.Transparent;
            this.chkSendInput.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.chkSendInput.Checked = false;
            this.chkSendInput.checkStyle = WinFrmTalk.Controls.CustomControls.CheckStyle.style1;
            this.chkSendInput.Cursor = System.Windows.Forms.Cursors.Hand;
            this.chkSendInput.Location = new System.Drawing.Point(330, 93);
            this.chkSendInput.Margin = new System.Windows.Forms.Padding(3, 6, 3, 6);
            this.chkSendInput.Name = "chkSendInput";
            this.chkSendInput.Size = new System.Drawing.Size(31, 30);
            this.chkSendInput.TabIndex = 30;
            this.chkSendInput.Click += new System.EventHandler(this.chkSendInput_CheckedChanged);
            // 
            // chkMultipleDevices
            // 
            this.chkMultipleDevices.BackColor = System.Drawing.Color.Transparent;
            this.chkMultipleDevices.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.chkMultipleDevices.Checked = false;
            this.chkMultipleDevices.checkStyle = WinFrmTalk.Controls.CustomControls.CheckStyle.style1;
            this.chkMultipleDevices.Cursor = System.Windows.Forms.Cursors.Hand;
            this.chkMultipleDevices.Location = new System.Drawing.Point(330, 130);
            this.chkMultipleDevices.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.chkMultipleDevices.Name = "chkMultipleDevices";
            this.chkMultipleDevices.Size = new System.Drawing.Size(31, 30);
            this.chkMultipleDevices.TabIndex = 29;
            this.chkMultipleDevices.Click += new System.EventHandler(this.chkMultipleDevices_CheckedChanged);
            // 
            // picnewstime
            // 
            this.picnewstime.BackColor = System.Drawing.Color.Transparent;
            this.picnewstime.Image = global::WinFrmTalk.Properties.Resources.right;
            this.picnewstime.Location = new System.Drawing.Point(406, 254);
            this.picnewstime.Name = "picnewstime";
            this.picnewstime.Size = new System.Drawing.Size(12, 12);
            this.picnewstime.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.picnewstime.TabIndex = 28;
            this.picnewstime.TabStop = false;
            this.picnewstime.Click += new System.EventHandler(this.lblOverdueDate_Click);
            // 
            // lblOverdueDate
            // 
            this.lblOverdueDate.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblOverdueDate.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblOverdueDate.ForeColor = System.Drawing.Color.Gray;
            this.lblOverdueDate.Location = new System.Drawing.Point(327, 253);
            this.lblOverdueDate.Name = "lblOverdueDate";
            this.lblOverdueDate.Size = new System.Drawing.Size(100, 14);
            this.lblOverdueDate.TabIndex = 26;
            this.lblOverdueDate.Text = "永久";
            this.lblOverdueDate.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.lblOverdueDate.Click += new System.EventHandler(this.lblOverdueDate_Click);
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label7.ForeColor = System.Drawing.Color.Gray;
            this.label7.Location = new System.Drawing.Point(97, 252);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(80, 17);
            this.label7.TabIndex = 27;
            this.label7.Text = "消息漫游时长";
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label8.ForeColor = System.Drawing.Color.Gray;
            this.label8.Location = new System.Drawing.Point(97, 138);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(92, 17);
            this.label8.TabIndex = 8;
            this.label8.Text = "支持多设备登录";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label6.ForeColor = System.Drawing.Color.Gray;
            this.label6.Location = new System.Drawing.Point(97, 100);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(128, 17);
            this.label6.TabIndex = 8;
            this.label6.Text = "让对方知道我正在输入";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label3.ForeColor = System.Drawing.Color.Gray;
            this.label3.Location = new System.Drawing.Point(97, 62);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(56, 17);
            this.label3.TabIndex = 8;
            this.label3.Text = "消息加密";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label2.ForeColor = System.Drawing.Color.Gray;
            this.label2.Location = new System.Drawing.Point(97, 24);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(56, 17);
            this.label2.TabIndex = 8;
            this.label2.Text = "好友验证";
            // 
            // skinLine4
            // 
            this.skinLine4.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.skinLine4.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.skinLine4.LineColor = System.Drawing.Color.DimGray;
            this.skinLine4.LineHeight = 1;
            this.skinLine4.Location = new System.Drawing.Point(0, 0);
            this.skinLine4.Name = "skinLine4";
            this.skinLine4.Size = new System.Drawing.Size(1, 405);
            this.skinLine4.TabIndex = 6;
            this.skinLine4.Text = "skinLine4";
            // 
            // skinTabPage4
            // 
            this.skinTabPage4.BackColor = System.Drawing.SystemColors.Control;
            this.skinTabPage4.Controls.Add(this.txtConfirmPwd);
            this.skinTabPage4.Controls.Add(this.label1);
            this.skinTabPage4.Controls.Add(this.txtNewPwd);
            this.skinTabPage4.Controls.Add(this.txtOldPwd);
            this.skinTabPage4.Controls.Add(this.lbliconPassword);
            this.skinTabPage4.Controls.Add(this.lbliconAccount);
            this.skinTabPage4.Controls.Add(this.btnRevise);
            this.skinTabPage4.Controls.Add(this.skinLine3);
            this.skinTabPage4.Cursor = System.Windows.Forms.Cursors.Default;
            this.skinTabPage4.Dock = System.Windows.Forms.DockStyle.Fill;
            this.skinTabPage4.Location = new System.Drawing.Point(0, 36);
            this.skinTabPage4.Name = "skinTabPage4";
            this.skinTabPage4.Size = new System.Drawing.Size(518, 368);
            this.skinTabPage4.TabIndex = 2;
            this.skinTabPage4.TabItemImage = null;
            this.skinTabPage4.Text = "修改密码";
            // 
            // txtConfirmPwd
            // 
            this.txtConfirmPwd.Font = new System.Drawing.Font("等线", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.txtConfirmPwd.Location = new System.Drawing.Point(199, 188);
            this.txtConfirmPwd.Name = "txtConfirmPwd";
            this.txtConfirmPwd.PasswordChar = '●';
            this.txtConfirmPwd.Size = new System.Drawing.Size(120, 21);
            this.txtConfirmPwd.TabIndex = 2;
            this.txtConfirmPwd.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtNewPwd_KeyPress);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label1.ForeColor = System.Drawing.SystemColors.ControlDarkDark;
            this.label1.Location = new System.Drawing.Point(116, 191);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(68, 17);
            this.label1.TabIndex = 27;
            this.label1.Text = "确认密码：";
            // 
            // txtNewPwd
            // 
            this.txtNewPwd.Font = new System.Drawing.Font("等线", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.txtNewPwd.Location = new System.Drawing.Point(199, 151);
            this.txtNewPwd.Name = "txtNewPwd";
            this.txtNewPwd.PasswordChar = '●';
            this.txtNewPwd.Size = new System.Drawing.Size(120, 21);
            this.txtNewPwd.TabIndex = 1;
            this.txtNewPwd.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtNewPwd_KeyPress);
            // 
            // txtOldPwd
            // 
            this.txtOldPwd.Font = new System.Drawing.Font("等线", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.txtOldPwd.Location = new System.Drawing.Point(199, 114);
            this.txtOldPwd.Name = "txtOldPwd";
            this.txtOldPwd.PasswordChar = '●';
            this.txtOldPwd.Size = new System.Drawing.Size(120, 21);
            this.txtOldPwd.TabIndex = 0;
            this.txtOldPwd.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtNewPwd_KeyPress);
            // 
            // lbliconPassword
            // 
            this.lbliconPassword.AutoSize = true;
            this.lbliconPassword.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lbliconPassword.ForeColor = System.Drawing.SystemColors.ControlDarkDark;
            this.lbliconPassword.Location = new System.Drawing.Point(130, 154);
            this.lbliconPassword.Name = "lbliconPassword";
            this.lbliconPassword.Size = new System.Drawing.Size(56, 17);
            this.lbliconPassword.TabIndex = 23;
            this.lbliconPassword.Text = "新密码：";
            // 
            // lbliconAccount
            // 
            this.lbliconAccount.AutoSize = true;
            this.lbliconAccount.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lbliconAccount.ForeColor = System.Drawing.SystemColors.ControlDarkDark;
            this.lbliconAccount.Location = new System.Drawing.Point(130, 117);
            this.lbliconAccount.Name = "lbliconAccount";
            this.lbliconAccount.Size = new System.Drawing.Size(56, 17);
            this.lbliconAccount.TabIndex = 24;
            this.lbliconAccount.Text = "旧密码：";
            // 
            // btnRevise
            // 
            this.btnRevise.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.btnRevise.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(41)))), ((int)(((byte)(97)))), ((int)(((byte)(1)))));
            this.btnRevise.BGColor = "#1AAD19";
            this.btnRevise.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnRevise.FontColor = "#ffffff";
            this.btnRevise.Location = new System.Drawing.Point(234, 251);
            this.btnRevise.Name = "btnRevise";
            this.btnRevise.Size = new System.Drawing.Size(120, 38);
            this.btnRevise.TabIndex = 22;
            this.btnRevise.Text = "修改密码";
            this.btnRevise.Click += new System.EventHandler(this.btnRevise_Click);
            // 
            // skinLine3
            // 
            this.skinLine3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.skinLine3.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.skinLine3.LineColor = System.Drawing.Color.DimGray;
            this.skinLine3.LineHeight = 1;
            this.skinLine3.Location = new System.Drawing.Point(0, 0);
            this.skinLine3.Name = "skinLine3";
            this.skinLine3.Size = new System.Drawing.Size(1, 405);
            this.skinLine3.TabIndex = 6;
            this.skinLine3.Text = "skinLine3";
            // 
            // skinTabPage5
            // 
            this.skinTabPage5.BackColor = System.Drawing.SystemColors.Control;
            this.skinTabPage5.Controls.Add(this.lblCompanyName);
            this.skinTabPage5.Controls.Add(this.lblCopyright);
            this.skinTabPage5.Controls.Add(this.skinLine1);
            this.skinTabPage5.Controls.Add(this.btnUpdate);
            this.skinTabPage5.Controls.Add(this.lblEdition);
            this.skinTabPage5.Controls.Add(this.picLogo);
            this.skinTabPage5.Cursor = System.Windows.Forms.Cursors.Default;
            this.skinTabPage5.Dock = System.Windows.Forms.DockStyle.Fill;
            this.skinTabPage5.Location = new System.Drawing.Point(0, 36);
            this.skinTabPage5.Name = "skinTabPage5";
            this.skinTabPage5.Size = new System.Drawing.Size(518, 368);
            this.skinTabPage5.TabIndex = 3;
            this.skinTabPage5.TabItemImage = null;
            this.skinTabPage5.Text = "关于我们";
            // 
            // lblCompanyName
            // 
            this.lblCompanyName.BackColor = System.Drawing.SystemColors.Control;
            this.lblCompanyName.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblCompanyName.ForeColor = System.Drawing.Color.Gray;
            this.lblCompanyName.Location = new System.Drawing.Point(40, 308);
            this.lblCompanyName.Name = "lblCompanyName";
            this.lblCompanyName.Size = new System.Drawing.Size(400, 17);
            this.lblCompanyName.TabIndex = 10;
            this.lblCompanyName.Text = "NULL";
            this.lblCompanyName.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblCopyright
            // 
            this.lblCopyright.BackColor = System.Drawing.SystemColors.Control;
            this.lblCopyright.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblCopyright.ForeColor = System.Drawing.Color.Gray;
            this.lblCopyright.Location = new System.Drawing.Point(40, 351);
            this.lblCopyright.Name = "lblCopyright";
            this.lblCopyright.Size = new System.Drawing.Size(400, 17);
            this.lblCopyright.TabIndex = 9;
            this.lblCopyright.Text = "NULL";
            this.lblCopyright.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // skinLine1
            // 
            this.skinLine1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.skinLine1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.skinLine1.LineColor = System.Drawing.Color.DimGray;
            this.skinLine1.LineHeight = 1;
            this.skinLine1.Location = new System.Drawing.Point(0, 0);
            this.skinLine1.Name = "skinLine1";
            this.skinLine1.Size = new System.Drawing.Size(1, 405);
            this.skinLine1.TabIndex = 5;
            this.skinLine1.Text = "skinLine1";
            // 
            // btnUpdate
            // 
            this.btnUpdate.FlatAppearance.BorderSize = 0;
            this.btnUpdate.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnUpdate.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnUpdate.Location = new System.Drawing.Point(190, 197);
            this.btnUpdate.Name = "btnUpdate";
            this.btnUpdate.Size = new System.Drawing.Size(100, 23);
            this.btnUpdate.TabIndex = 3;
            this.btnUpdate.Text = "检查更新";
            this.btnUpdate.UseVisualStyleBackColor = true;
            this.btnUpdate.Click += new System.EventHandler(this.btnUpdate_Click);
            // 
            // lblEdition
            // 
            this.lblEdition.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblEdition.Location = new System.Drawing.Point(190, 165);
            this.lblEdition.Name = "lblEdition";
            this.lblEdition.Size = new System.Drawing.Size(100, 20);
            this.lblEdition.TabIndex = 1;
            this.lblEdition.Text = "NULL";
            this.lblEdition.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // picLogo
            // 
            this.picLogo.Image = global::WinFrmTalk.Properties.Resources.Logo;
            this.picLogo.Location = new System.Drawing.Point(190, 45);
            this.picLogo.Name = "picLogo";
            this.picLogo.Size = new System.Drawing.Size(100, 100);
            this.picLogo.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.picLogo.TabIndex = 0;
            this.picLogo.TabStop = false;
            // 
            // cmsOverdueDate
            // 
            this.cmsOverdueDate.Arrow = System.Drawing.Color.Black;
            this.cmsOverdueDate.Back = System.Drawing.Color.WhiteSmoke;
            this.cmsOverdueDate.BackColor = System.Drawing.Color.WhiteSmoke;
            this.cmsOverdueDate.BackRadius = 4;
            this.cmsOverdueDate.Base = System.Drawing.Color.WhiteSmoke;
            this.cmsOverdueDate.DropDownImageSeparator = System.Drawing.Color.Silver;
            this.cmsOverdueDate.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.cmsOverdueDate.Fore = System.Drawing.Color.Black;
            this.cmsOverdueDate.HoverFore = System.Drawing.Color.Black;
            this.cmsOverdueDate.ItemAnamorphosis = false;
            this.cmsOverdueDate.ItemBorder = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsOverdueDate.ItemBorderShow = false;
            this.cmsOverdueDate.ItemHover = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsOverdueDate.ItemPressed = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsOverdueDate.ItemRadius = 4;
            this.cmsOverdueDate.ItemRadiusStyle = CCWin.SkinClass.RoundStyle.None;
            this.cmsOverdueDate.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.tsmForever,
            this.tsmHour,
            this.tsmDay,
            this.tsmWeek,
            this.tsmMonth,
            this.tsmSeason,
            this.tsmYear});
            this.cmsOverdueDate.ItemSplitter = System.Drawing.Color.Silver;
            this.cmsOverdueDate.Name = "contextMenuStrip1";
            this.cmsOverdueDate.RadiusStyle = CCWin.SkinClass.RoundStyle.None;
            this.cmsOverdueDate.Size = new System.Drawing.Size(108, 158);
            this.cmsOverdueDate.SkinAllColor = true;
            this.cmsOverdueDate.Tag = "";
            this.cmsOverdueDate.TitleAnamorphosis = true;
            this.cmsOverdueDate.TitleColor = System.Drawing.Color.WhiteSmoke;
            this.cmsOverdueDate.TitleRadius = 4;
            this.cmsOverdueDate.TitleRadiusStyle = CCWin.SkinClass.RoundStyle.None;
            // 
            // tsmForever
            // 
            this.tsmForever.Name = "tsmForever";
            this.tsmForever.Size = new System.Drawing.Size(107, 22);
            this.tsmForever.Text = "永久";
            this.tsmForever.Click += new System.EventHandler(this.tsmForever_Click);
            // 
            // tsmHour
            // 
            this.tsmHour.Name = "tsmHour";
            this.tsmHour.Size = new System.Drawing.Size(107, 22);
            this.tsmHour.Text = "1小时";
            this.tsmHour.Click += new System.EventHandler(this.tsmHour_Click);
            // 
            // tsmDay
            // 
            this.tsmDay.Name = "tsmDay";
            this.tsmDay.Size = new System.Drawing.Size(107, 22);
            this.tsmDay.Text = "1天";
            this.tsmDay.Click += new System.EventHandler(this.tsmDay_Click);
            // 
            // tsmWeek
            // 
            this.tsmWeek.Name = "tsmWeek";
            this.tsmWeek.Size = new System.Drawing.Size(107, 22);
            this.tsmWeek.Text = "1周";
            this.tsmWeek.Click += new System.EventHandler(this.tsmWeek_Click);
            // 
            // tsmMonth
            // 
            this.tsmMonth.Name = "tsmMonth";
            this.tsmMonth.Size = new System.Drawing.Size(107, 22);
            this.tsmMonth.Text = "1月";
            this.tsmMonth.Click += new System.EventHandler(this.tsmMonth_Click);
            // 
            // tsmSeason
            // 
            this.tsmSeason.Name = "tsmSeason";
            this.tsmSeason.Size = new System.Drawing.Size(107, 22);
            this.tsmSeason.Text = "1季";
            this.tsmSeason.Click += new System.EventHandler(this.tsmSeason_Click);
            // 
            // tsmYear
            // 
            this.tsmYear.Name = "tsmYear";
            this.tsmYear.Size = new System.Drawing.Size(107, 22);
            this.tsmYear.Text = "1年";
            this.tsmYear.Click += new System.EventHandler(this.tsmYear_Click);
            // 
            // contextMenuStrip1
            // 
            this.contextMenuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripComboBox2,
            this.toolStripComboBox3,
            this.toolStripComboBox1,
            this.toolStripComboBox4,
            this.toolStripComboBox5,
            this.toolStripComboBox6});
            this.contextMenuStrip1.Name = "contextMenuStrip1";
            this.contextMenuStrip1.Size = new System.Drawing.Size(182, 178);
            // 
            // toolStripComboBox2
            // 
            this.toolStripComboBox2.Name = "toolStripComboBox2";
            this.toolStripComboBox2.Size = new System.Drawing.Size(121, 25);
            this.toolStripComboBox2.Text = "名片";
            // 
            // toolStripComboBox3
            // 
            this.toolStripComboBox3.Name = "toolStripComboBox3";
            this.toolStripComboBox3.Size = new System.Drawing.Size(121, 25);
            this.toolStripComboBox3.Text = "名片";
            // 
            // toolStripComboBox1
            // 
            this.toolStripComboBox1.Name = "toolStripComboBox1";
            this.toolStripComboBox1.Size = new System.Drawing.Size(121, 25);
            this.toolStripComboBox1.Text = "群组";
            // 
            // toolStripComboBox4
            // 
            this.toolStripComboBox4.Name = "toolStripComboBox4";
            this.toolStripComboBox4.Size = new System.Drawing.Size(121, 25);
            this.toolStripComboBox4.Text = "手机号搜索";
            // 
            // toolStripComboBox5
            // 
            this.toolStripComboBox5.Name = "toolStripComboBox5";
            this.toolStripComboBox5.Size = new System.Drawing.Size(121, 25);
            this.toolStripComboBox5.Text = "昵称搜索";
            // 
            // toolStripComboBox6
            // 
            this.toolStripComboBox6.Name = "toolStripComboBox6";
            this.toolStripComboBox6.Size = new System.Drawing.Size(121, 25);
            this.toolStripComboBox6.Text = "其他";
            // 
            // FrmSet
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(550, 470);
            this.Controls.Add(this.tabSet);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "FrmSet";
            this.ShowBorder = false;
            this.ShowDrawIcon = false;
            this.ShowIcon = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "设置";
            this.TitleColor = System.Drawing.Color.Gray;
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmSet_FormClosed);
            this.Load += new System.EventHandler(this.FrmSet_Load);
            this.Paint += new System.Windows.Forms.PaintEventHandler(this.FrmSet_Paint);
            this.tabSet.ResumeLayout(false);
            this.skinTabPage1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.picHead)).EndInit();
            this.skinTabPage2.ResumeLayout(false);
            this.skinTabPage3.ResumeLayout(false);
            this.skinTabPage3.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picallowtoway)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picnewstime)).EndInit();
            this.skinTabPage4.ResumeLayout(false);
            this.skinTabPage4.PerformLayout();
            this.skinTabPage5.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.picLogo)).EndInit();
            this.cmsOverdueDate.ResumeLayout(false);
            this.contextMenuStrip1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private CCWin.SkinControl.SkinTabControl tabSet;
        private CCWin.SkinControl.SkinTabPage skinTabPage2;
        private CCWin.SkinControl.SkinTabPage skinTabPage3;
        private CCWin.SkinControl.SkinTabPage skinTabPage4;
        private CCWin.SkinControl.SkinTabPage skinTabPage5;
        private System.Windows.Forms.Button btnDeleteChat;
        private System.Windows.Forms.Button btnDeleteCache;
        private System.Windows.Forms.PictureBox picLogo;
        private CCWin.SkinControl.SkinTabPage skinTabPage1;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnUpdate;
        private System.Windows.Forms.Label lblEdition;
        private CCWin.SkinControl.SkinLine skinLine1;
        private CCWin.SkinControl.SkinLine skinLine2;
        private CCWin.SkinControl.SkinLine skinLine4;
        private CCWin.SkinControl.SkinLine skinLine3;
        private CCWin.SkinControl.SkinLine skinLine5;
        private System.Windows.Forms.Label lblCompanyName;
        private System.Windows.Forms.Label lblCopyright;
        private System.Windows.Forms.TextBox txtConfirmPwd;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtNewPwd;
        private System.Windows.Forms.TextBox txtOldPwd;
        private System.Windows.Forms.Label lbliconPassword;
        private System.Windows.Forms.Label lbliconAccount;
        public LollipopButton btnRevise;
        private System.Windows.Forms.Button btnEdit;
        private RoundPicBox picHead;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.PictureBox picnewstime;
        private System.Windows.Forms.Label lblOverdueDate;
        private System.Windows.Forms.Label label7;
        private CCWin.SkinControl.SkinContextMenuStrip cmsOverdueDate;
        private System.Windows.Forms.ToolStripMenuItem tsmForever;
        private System.Windows.Forms.ToolStripMenuItem tsmHour;
        private System.Windows.Forms.ToolStripMenuItem tsmDay;
        private System.Windows.Forms.ToolStripMenuItem tsmWeek;
        private System.Windows.Forms.ToolStripMenuItem tsmMonth;
        private System.Windows.Forms.ToolStripMenuItem tsmSeason;
        private System.Windows.Forms.ToolStripMenuItem tsmYear;
        private Controls.CustomControls.USEToggle chkMultipleDevices;
        private Controls.CustomControls.USEToggle chkSendInput;
        private Controls.CustomControls.USEToggle chkPrivacy;
        private Controls.CustomControls.USEToggle chkIsEncrypt;
        private System.Windows.Forms.Label lblallowtoway;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.Label label9;
        private Controls.CustomControls.USEToggle chkAllowtoNickname;
        private Controls.CustomControls.USEToggle chkAllowtoPhone;
        private System.Windows.Forms.Button btninputAllroomxls;
        private System.Windows.Forms.Button btninputAllfriendxls;
        private System.Windows.Forms.Button btninputAllroomtxt;
        private System.Windows.Forms.Button btninputAllfriendtxt;
        private System.Windows.Forms.ContextMenuStrip contextMenuStrip1;
        private System.Windows.Forms.ToolStripComboBox toolStripComboBox2;
        private System.Windows.Forms.ToolStripComboBox toolStripComboBox3;
        private System.Windows.Forms.ToolStripComboBox toolStripComboBox1;
        private System.Windows.Forms.ToolStripComboBox toolStripComboBox4;
        private System.Windows.Forms.ToolStripComboBox toolStripComboBox5;
        private System.Windows.Forms.ToolStripComboBox toolStripComboBox6;
        private Controls.CustomControls.USEToggle chkAllowtoCustomer;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.PictureBox picallowtoway;
    }
}