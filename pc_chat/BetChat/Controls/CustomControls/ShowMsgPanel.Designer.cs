namespace WinFrmTalk.Controls.CustomControls
{
    partial class ShowMsgPanel
    {
        /// <summary> 
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region 组件设计器生成的代码

        /// <summary> 
        /// 设计器支持所需的方法 - 不要修改
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ShowMsgPanel));
            WinFrmTalk.Model.MessageObject messageObject1 = new WinFrmTalk.Model.MessageObject();
            this.panTitle = new System.Windows.Forms.Panel();
            this.lab_splitTitle = new System.Windows.Forms.Label();
            this.lab_detial = new System.Windows.Forms.Label();
            this.labName = new System.Windows.Forms.Label();
            this.Bottom_Panel = new System.Windows.Forms.Panel();
            this.btnEnding = new System.Windows.Forms.Button();
            this.btnSend = new System.Windows.Forms.Button();
            this.txtSend = new System.Windows.Forms.RichTextBox();
            this.menuTxtSend = new CCWin.SkinControl.SkinContextMenuStrip();
            this.menuItem_paste = new System.Windows.Forms.ToolStripMenuItem();
            this.Tool_Panel = new System.Windows.Forms.Panel();
            this.lblLive = new System.Windows.Forms.Label();
            this.lbl_qreply = new System.Windows.Forms.Label();
            this.lblSoundRecord = new System.Windows.Forms.Label();
            this.lblPhotography = new System.Windows.Forms.Label();
            this.lblCamera = new System.Windows.Forms.Label();
            this.lblLocation = new System.Windows.Forms.Label();
            this.lblAudio = new System.Windows.Forms.Label();
            this.lblVideo = new System.Windows.Forms.Label();
            this.lblHistory = new System.Windows.Forms.Label();
            this.lblScreen = new System.Windows.Forms.Label();
            this.lab_splitTool = new System.Windows.Forms.Label();
            this.lblSendFile = new System.Windows.Forms.Label();
            this.lblExpression = new System.Windows.Forms.Label();
            this.toolTip = new System.Windows.Forms.ToolTip(this.components);
            this.cmsMsgMenu = new CCWin.SkinControl.SkinContextMenuStrip();
            this.menuItem_Transcribe = new System.Windows.Forms.ToolStripMenuItem();
            this.menuItem_NoneSound = new System.Windows.Forms.ToolStripMenuItem();
            this.separator_one = new System.Windows.Forms.ToolStripSeparator();
            this.menuItem_Copy = new System.Windows.Forms.ToolStripMenuItem();
            this.separator_two = new System.Windows.Forms.ToolStripSeparator();
            this.menuItem_Recall = new System.Windows.Forms.ToolStripMenuItem();
            this.menuItem_Relay = new System.Windows.Forms.ToolStripMenuItem();
            this.menuItem_Collect = new System.Windows.Forms.ToolStripMenuItem();
            this.menuItem_SaveCustomize = new System.Windows.Forms.ToolStripMenuItem();
            this.menuItem_MultiSelect = new System.Windows.Forms.ToolStripMenuItem();
            this.menuItem_Reply = new System.Windows.Forms.ToolStripMenuItem();
            this.menuItem_Translate = new System.Windows.Forms.ToolStripMenuItem();
            this.menuItem_AudioToText = new System.Windows.Forms.ToolStripMenuItem();
            this.separator_three = new System.Windows.Forms.ToolStripSeparator();
            this.menuItem_Dowmload = new System.Windows.Forms.ToolStripMenuItem();
            this.menuItem_SaveAs = new System.Windows.Forms.ToolStripMenuItem();
            this.menuItem_OpenFileFolder = new System.Windows.Forms.ToolStripMenuItem();
            this.separator_four = new System.Windows.Forms.ToolStripSeparator();
            this.menuItem_Delete = new System.Windows.Forms.ToolStripMenuItem();
            this.panMultiSelect = new System.Windows.Forms.Panel();
            this.lab_splitMultiSelect = new System.Windows.Forms.Label();
            this.multiSelectPanel = new WinFrmTalk.Controls.CustomControls.MultiSelectPanel();
            this.lblClose = new System.Windows.Forms.Label();
            this.xListView = new TestListView.XListView();
            this.replyPanel = new WinFrmTalk.Controls.CustomControls.ReplyPanel();
            this.roomNotice = new WinFrmTalk.Controls.Roomannounce();
            this.unReadNumPanel = new WinFrmTalk.Controls.CustomControls.UnReadNumPanel();
            this.userSoundRecording = new WinFrmTalk.Controls.CustomControls.UserSoundRecording();
            this.AtMePanel = new WinFrmTalk.Controls.CustomControls.USERemindMe();
            this.panTitle.SuspendLayout();
            this.Bottom_Panel.SuspendLayout();
            this.menuTxtSend.SuspendLayout();
            this.Tool_Panel.SuspendLayout();
            this.cmsMsgMenu.SuspendLayout();
            this.panMultiSelect.SuspendLayout();
            this.SuspendLayout();
            // 
            // panTitle
            // 
            this.panTitle.BackColor = System.Drawing.Color.WhiteSmoke;
            this.panTitle.Controls.Add(this.lab_splitTitle);
            this.panTitle.Controls.Add(this.lab_detial);
            this.panTitle.Controls.Add(this.labName);
            this.panTitle.Dock = System.Windows.Forms.DockStyle.Top;
            this.panTitle.Location = new System.Drawing.Point(0, 0);
            this.panTitle.Name = "panTitle";
            this.panTitle.Size = new System.Drawing.Size(725, 35);
            this.panTitle.TabIndex = 1;
            // 
            // lab_splitTitle
            // 
            this.lab_splitTitle.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lab_splitTitle.BackColor = System.Drawing.Color.Gainsboro;
            this.lab_splitTitle.Location = new System.Drawing.Point(0, 34);
            this.lab_splitTitle.Name = "lab_splitTitle";
            this.lab_splitTitle.Size = new System.Drawing.Size(725, 1);
            this.lab_splitTitle.TabIndex = 4;
            // 
            // lab_detial
            // 
            this.lab_detial.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lab_detial.BackColor = System.Drawing.Color.Transparent;
            this.lab_detial.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lab_detial.Image = ((System.Drawing.Image)(resources.GetObject("lab_detial.Image")));
            this.lab_detial.Location = new System.Drawing.Point(674, 3);
            this.lab_detial.Name = "lab_detial";
            this.lab_detial.Size = new System.Drawing.Size(48, 30);
            this.lab_detial.TabIndex = 3;
            this.lab_detial.MouseClick += new System.Windows.Forms.MouseEventHandler(this.Lab_detial_MouseClick);
            // 
            // labName
            // 
            this.labName.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.labName.AutoEllipsis = true;
            this.labName.BackColor = System.Drawing.Color.Transparent;
            this.labName.Cursor = System.Windows.Forms.Cursors.Hand;
            this.labName.Font = new System.Drawing.Font("微软雅黑", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.labName.Location = new System.Drawing.Point(27, 4);
            this.labName.Name = "labName";
            this.labName.Size = new System.Drawing.Size(641, 25);
            this.labName.TabIndex = 2;
            this.labName.Text = "我是默认名称";
            this.labName.UseMnemonic = false;
            this.labName.TextChanged += new System.EventHandler(this.LabName_TextChanged);
            this.labName.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LabName_MouseClick);
            // 
            // Bottom_Panel
            // 
            this.Bottom_Panel.BackColor = System.Drawing.Color.White;
            this.Bottom_Panel.Controls.Add(this.btnEnding);
            this.Bottom_Panel.Controls.Add(this.btnSend);
            this.Bottom_Panel.Controls.Add(this.txtSend);
            this.Bottom_Panel.Controls.Add(this.Tool_Panel);
            this.Bottom_Panel.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.Bottom_Panel.Location = new System.Drawing.Point(0, 496);
            this.Bottom_Panel.Name = "Bottom_Panel";
            this.Bottom_Panel.Size = new System.Drawing.Size(725, 160);
            this.Bottom_Panel.TabIndex = 4;
            // 
            // btnEnding
            // 
            this.btnEnding.BackColor = System.Drawing.Color.WhiteSmoke;
            this.btnEnding.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnEnding.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnEnding.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(18)))), ((int)(((byte)(150)))), ((int)(((byte)(37)))));
            this.btnEnding.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnEnding.Font = new System.Drawing.Font("宋体", 9F);
            this.btnEnding.Location = new System.Drawing.Point(32, 129);
            this.btnEnding.Name = "btnEnding";
            this.btnEnding.Size = new System.Drawing.Size(75, 23);
            this.btnEnding.TabIndex = 18;
            this.btnEnding.Text = "结束会话(S)";
            this.btnEnding.UseVisualStyleBackColor = false;
            this.btnEnding.Visible = false;
            this.btnEnding.Click += new System.EventHandler(this.btnEnding_Click);
            // 
            // btnSend
            // 
            this.btnSend.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnSend.BackColor = System.Drawing.Color.WhiteSmoke;
            this.btnSend.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnSend.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnSend.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(18)))), ((int)(((byte)(150)))), ((int)(((byte)(37)))));
            this.btnSend.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSend.Font = new System.Drawing.Font("宋体", 9F);
            this.btnSend.Location = new System.Drawing.Point(644, 129);
            this.btnSend.Name = "btnSend";
            this.btnSend.Size = new System.Drawing.Size(68, 23);
            this.btnSend.TabIndex = 17;
            this.btnSend.Text = "发送(S)";
            this.btnSend.UseVisualStyleBackColor = false;
            this.btnSend.Click += new System.EventHandler(this.BtnSend_Click);
            // 
            // txtSend
            // 
            this.txtSend.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtSend.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.txtSend.ContextMenuStrip = this.menuTxtSend;
            this.txtSend.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.txtSend.Location = new System.Drawing.Point(16, 46);
            this.txtSend.Name = "txtSend";
            this.txtSend.Size = new System.Drawing.Size(696, 77);
            this.txtSend.TabIndex = 15;
            this.txtSend.Text = "";
            this.txtSend.TextChanged += new System.EventHandler(this.TxtSend_TextChanged);
            this.txtSend.DoubleClick += new System.EventHandler(this.TxtSend_DoubleClick);
            this.txtSend.KeyDown += new System.Windows.Forms.KeyEventHandler(this.TxtSend_KeyDown);
            this.txtSend.KeyUp += new System.Windows.Forms.KeyEventHandler(this.TxtSend_KeyUp);
            this.txtSend.MouseDown += new System.Windows.Forms.MouseEventHandler(this.TxtSend_MouseDown);
            // 
            // menuTxtSend
            // 
            this.menuTxtSend.Arrow = System.Drawing.Color.Black;
            this.menuTxtSend.Back = System.Drawing.Color.White;
            this.menuTxtSend.BackRadius = 1;
            this.menuTxtSend.Base = System.Drawing.Color.White;
            this.menuTxtSend.DropDownImageSeparator = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.menuTxtSend.Font = new System.Drawing.Font("宋体", 9F);
            this.menuTxtSend.Fore = System.Drawing.Color.Black;
            this.menuTxtSend.HoverFore = System.Drawing.Color.Black;
            this.menuTxtSend.ItemAnamorphosis = false;
            this.menuTxtSend.ItemBorder = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.menuTxtSend.ItemBorderShow = false;
            this.menuTxtSend.ItemHover = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.menuTxtSend.ItemPressed = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.menuTxtSend.ItemRadius = 1;
            this.menuTxtSend.ItemRadiusStyle = CCWin.SkinClass.RoundStyle.All;
            this.menuTxtSend.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menuItem_paste});
            this.menuTxtSend.ItemSplitter = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.menuTxtSend.Name = "contentMenuStrip";
            this.menuTxtSend.RadiusStyle = CCWin.SkinClass.RoundStyle.All;
            this.menuTxtSend.Size = new System.Drawing.Size(95, 26);
            this.menuTxtSend.SkinAllColor = true;
            this.menuTxtSend.TitleAnamorphosis = false;
            this.menuTxtSend.TitleColor = System.Drawing.Color.White;
            this.menuTxtSend.TitleRadius = 4;
            this.menuTxtSend.TitleRadiusStyle = CCWin.SkinClass.RoundStyle.All;
            // 
            // menuItem_paste
            // 
            this.menuItem_paste.Name = "menuItem_paste";
            this.menuItem_paste.Size = new System.Drawing.Size(94, 22);
            this.menuItem_paste.Text = "粘贴";
            this.menuItem_paste.Click += new System.EventHandler(this.MenuItem_paste_Click);
            // 
            // Tool_Panel
            // 
            this.Tool_Panel.Controls.Add(this.lblLive);
            this.Tool_Panel.Controls.Add(this.lbl_qreply);
            //this.Tool_Panel.Controls.Add(this.lblSoundRecord);
            //this.Tool_Panel.Controls.Add(this.lblPhotography);
            //this.Tool_Panel.Controls.Add(this.lblCamera);
            //this.Tool_Panel.Controls.Add(this.lblLocation);
            //this.Tool_Panel.Controls.Add(this.lblAudio);
            //this.Tool_Panel.Controls.Add(this.lblVideo);
            this.Tool_Panel.Controls.Add(this.lblHistory);
            this.Tool_Panel.Controls.Add(this.lblScreen);
            this.Tool_Panel.Controls.Add(this.lab_splitTool);
            this.Tool_Panel.Controls.Add(this.lblSendFile);
            this.Tool_Panel.Controls.Add(this.lblExpression);
            this.Tool_Panel.Dock = System.Windows.Forms.DockStyle.Top;
            this.Tool_Panel.Location = new System.Drawing.Point(0, 0);
            this.Tool_Panel.Name = "Tool_Panel";
            this.Tool_Panel.Size = new System.Drawing.Size(725, 34);
            this.Tool_Panel.TabIndex = 16;
            // 
            // lblLive
            // 
            this.lblLive.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblLive.Image = ((System.Drawing.Image)(resources.GetObject("lblLive.Image")));
            this.lblLive.Location = new System.Drawing.Point(345, 1);
            this.lblLive.Name = "lblLive";
            this.lblLive.Size = new System.Drawing.Size(34, 34);
            this.lblLive.TabIndex = 15;
            this.lblLive.Visible = false;
            this.lblLive.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LblLive_MouseClick);
            // 
            // lbl_qreply
            // 
            this.lbl_qreply.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lbl_qreply.Image = global::WinFrmTalk.Properties.Resources.ic_qreply;
            this.lbl_qreply.Location = new System.Drawing.Point(288, 1);
            this.lbl_qreply.Name = "lbl_qreply";
            this.lbl_qreply.Size = new System.Drawing.Size(34, 34);
            this.lbl_qreply.TabIndex = 14;
            this.lbl_qreply.Visible = false;
            this.lbl_qreply.MouseClick += new System.Windows.Forms.MouseEventHandler(this.Lbl_qreply_MouseClick);
            // 
            // lblSoundRecord
            // 
            this.lblSoundRecord.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblSoundRecord.Image = ((System.Drawing.Image)(resources.GetObject("lblSoundRecord.Image")));
            this.lblSoundRecord.Location = new System.Drawing.Point(186, 1);
            this.lblSoundRecord.Name = "lblSoundRecord";
            this.lblSoundRecord.Size = new System.Drawing.Size(34, 34);
            this.lblSoundRecord.TabIndex = 13;
            this.lblSoundRecord.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LblSoundRecord_MouseClick);
            this.lblSoundRecord.MouseHover += new System.EventHandler(this.LblSoundRecord_MouseHover);
            // 
            // lblPhotography
            // 
            this.lblPhotography.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblPhotography.Image = ((System.Drawing.Image)(resources.GetObject("lblPhotography.Image")));
            this.lblPhotography.Location = new System.Drawing.Point(254, 1);
            this.lblPhotography.Name = "lblPhotography";
            this.lblPhotography.Size = new System.Drawing.Size(34, 34);
            this.lblPhotography.TabIndex = 12;
            this.lblPhotography.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LblPhotography_MouseClick);
            this.lblPhotography.MouseHover += new System.EventHandler(this.LblPhotography_MouseHover);
            // 
            // lblCamera
            // 
            this.lblCamera.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblCamera.Image = ((System.Drawing.Image)(resources.GetObject("lblCamera.Image")));
            this.lblCamera.Location = new System.Drawing.Point(220, 1);
            this.lblCamera.Name = "lblCamera";
            this.lblCamera.Size = new System.Drawing.Size(34, 34);
            this.lblCamera.TabIndex = 11;
            this.lblCamera.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LblCamera_MouseClick);
            this.lblCamera.MouseHover += new System.EventHandler(this.LblCamera_MouseHover);
            // 
            // lblLocation
            // 
            this.lblLocation.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblLocation.Image = ((System.Drawing.Image)(resources.GetObject("lblLocation.Image")));
            this.lblLocation.Location = new System.Drawing.Point(152, 1);
            this.lblLocation.Name = "lblLocation";
            this.lblLocation.Size = new System.Drawing.Size(34, 34);
            this.lblLocation.TabIndex = 10;
            this.lblLocation.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LblLocation_MouseClick);
            this.lblLocation.MouseHover += new System.EventHandler(this.LblLocation_MouseHover);
            // 
            // lblAudio
            // 
            this.lblAudio.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblAudio.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblAudio.Image = ((System.Drawing.Image)(resources.GetObject("lblAudio.Image")));
            this.lblAudio.Location = new System.Drawing.Point(656, 1);
            this.lblAudio.Name = "lblAudio";
            this.lblAudio.Size = new System.Drawing.Size(34, 34);
            this.lblAudio.TabIndex = 9;
            this.lblAudio.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LblAudio_MouseClick);
            // 
            // lblVideo
            // 
            this.lblVideo.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblVideo.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblVideo.Image = ((System.Drawing.Image)(resources.GetObject("lblVideo.Image")));
            this.lblVideo.Location = new System.Drawing.Point(690, 1);
            this.lblVideo.Name = "lblVideo";
            this.lblVideo.Size = new System.Drawing.Size(34, 34);
            this.lblVideo.TabIndex = 8;
            this.lblVideo.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LblVideo_MouseClick);
            // 
            // lblHistory
            // 
            this.lblHistory.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblHistory.Image = ((System.Drawing.Image)(resources.GetObject("lblHistory.Image")));
            this.lblHistory.Location = new System.Drawing.Point(118, 1);
            this.lblHistory.Name = "lblHistory";
            this.lblHistory.Size = new System.Drawing.Size(34, 34);
            this.lblHistory.TabIndex = 7;
            this.lblHistory.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LblHistory_MoseClick);
            this.lblHistory.MouseHover += new System.EventHandler(this.LblHistory_MouseHover);
            // 
            // lblScreen
            // 
            this.lblScreen.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblScreen.Image = ((System.Drawing.Image)(resources.GetObject("lblScreen.Image")));
            this.lblScreen.Location = new System.Drawing.Point(84, 1);
            this.lblScreen.Name = "lblScreen";
            this.lblScreen.Size = new System.Drawing.Size(34, 34);
            this.lblScreen.TabIndex = 6;
            this.lblScreen.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LblScreen_MouseClick);
            this.lblScreen.MouseHover += new System.EventHandler(this.LblScreen_MouseHover);
            // 
            // lab_splitTool
            // 
            this.lab_splitTool.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lab_splitTool.BackColor = System.Drawing.Color.Gainsboro;
            this.lab_splitTool.Location = new System.Drawing.Point(0, 0);
            this.lab_splitTool.Name = "lab_splitTool";
            this.lab_splitTool.Size = new System.Drawing.Size(725, 1);
            this.lab_splitTool.TabIndex = 5;
            // 
            // lblSendFile
            // 
            this.lblSendFile.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblSendFile.Image = ((System.Drawing.Image)(resources.GetObject("lblSendFile.Image")));
            this.lblSendFile.Location = new System.Drawing.Point(50, 0);
            this.lblSendFile.Name = "lblSendFile";
            this.lblSendFile.Size = new System.Drawing.Size(34, 34);
            this.lblSendFile.TabIndex = 1;
            this.lblSendFile.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LblSendFile_MouseClick);
            this.lblSendFile.MouseHover += new System.EventHandler(this.LblSendFile_MouseHover);
            // 
            // lblExpression
            // 
            this.lblExpression.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblExpression.Image = global::WinFrmTalk.Properties.Resources.ExpressionNormal;
            this.lblExpression.Location = new System.Drawing.Point(16, 0);
            this.lblExpression.Name = "lblExpression";
            this.lblExpression.Size = new System.Drawing.Size(34, 34);
            this.lblExpression.TabIndex = 0;
            this.lblExpression.MouseClick += new System.Windows.Forms.MouseEventHandler(this.LblExpression_MouseClick);
            this.lblExpression.MouseHover += new System.EventHandler(this.LblExpression_MouseHover);
            // 
            // cmsMsgMenu
            // 
            this.cmsMsgMenu.Arrow = System.Drawing.Color.Black;
            this.cmsMsgMenu.Back = System.Drawing.Color.White;
            this.cmsMsgMenu.BackRadius = 1;
            this.cmsMsgMenu.Base = System.Drawing.Color.White;
            this.cmsMsgMenu.DropDownImageSeparator = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.cmsMsgMenu.Font = new System.Drawing.Font("宋体", 9F);
            this.cmsMsgMenu.Fore = System.Drawing.Color.Black;
            this.cmsMsgMenu.HoverFore = System.Drawing.Color.Black;
            this.cmsMsgMenu.ItemAnamorphosis = false;
            this.cmsMsgMenu.ItemBorder = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.cmsMsgMenu.ItemBorderShow = false;
            this.cmsMsgMenu.ItemHover = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.cmsMsgMenu.ItemPressed = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.cmsMsgMenu.ItemRadius = 1;
            this.cmsMsgMenu.ItemRadiusStyle = CCWin.SkinClass.RoundStyle.All;
            this.cmsMsgMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            //this.menuItem_Transcribe,
            this.menuItem_NoneSound,
            this.separator_one,
            this.menuItem_Copy,
            this.separator_two,
            this.menuItem_Recall,
            this.menuItem_Relay,
            this.menuItem_Collect,
            //this.menuItem_SaveCustomize,
            this.menuItem_MultiSelect,
            this.menuItem_Reply,
            this.menuItem_Translate,
            this.menuItem_AudioToText,
            this.separator_three,
            this.menuItem_Dowmload,
            this.menuItem_SaveAs,
            this.menuItem_OpenFileFolder,
            this.separator_four,
            this.menuItem_Delete});
            this.cmsMsgMenu.ItemSplitter = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.cmsMsgMenu.Name = "contentMenuStrip";
            this.cmsMsgMenu.RadiusStyle = CCWin.SkinClass.RoundStyle.All;
            this.cmsMsgMenu.Size = new System.Drawing.Size(155, 358);
            this.cmsMsgMenu.SkinAllColor = true;
            this.cmsMsgMenu.TitleAnamorphosis = false;
            this.cmsMsgMenu.TitleColor = System.Drawing.Color.White;
            this.cmsMsgMenu.TitleRadius = 4;
            this.cmsMsgMenu.TitleRadiusStyle = CCWin.SkinClass.RoundStyle.All;
            // 
            // menuItem_Transcribe
            // 
            this.menuItem_Transcribe.Name = "menuItem_Transcribe";
            this.menuItem_Transcribe.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Transcribe.Text = "开始录制";
            this.menuItem_Transcribe.Click += new System.EventHandler(this.MenuItem_Transcribe_Click);
            // 
            // menuItem_NoneSound
            // 
            this.menuItem_NoneSound.Name = "menuItem_NoneSound";
            this.menuItem_NoneSound.Size = new System.Drawing.Size(154, 22);
            this.menuItem_NoneSound.Text = "静音播放";
            // 
            // separator_one
            // 
            this.separator_one.Name = "separator_one";
            this.separator_one.Size = new System.Drawing.Size(151, 6);
            // 
            // menuItem_Copy
            // 
            this.menuItem_Copy.Name = "menuItem_Copy";
            this.menuItem_Copy.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Copy.Text = "复制";
            this.menuItem_Copy.Click += new System.EventHandler(this.MenuItem_Copy_Click);
            // 
            // separator_two
            // 
            this.separator_two.Name = "separator_two";
            this.separator_two.Size = new System.Drawing.Size(151, 6);
            // 
            // menuItem_Recall
            // 
            this.menuItem_Recall.Name = "menuItem_Recall";
            this.menuItem_Recall.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Recall.Text = "撤回";
            this.menuItem_Recall.Click += new System.EventHandler(this.MenuItem_Recall_Click);
            // 
            // menuItem_Relay
            // 
            this.menuItem_Relay.Name = "menuItem_Relay";
            this.menuItem_Relay.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Relay.Text = "转发";
            this.menuItem_Relay.Click += new System.EventHandler(this.MenuItem_Relay_Click);
            // 
            // menuItem_Collect
            // 
            this.menuItem_Collect.Name = "menuItem_Collect";
            this.menuItem_Collect.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Collect.Text = "收藏";
            this.menuItem_Collect.Click += new System.EventHandler(this.MenuItem_Collect_Click);
            // 
            // menuItem_SaveCustomize
            // 
            this.menuItem_SaveCustomize.Name = "menuItem_SaveCustomize";
            this.menuItem_SaveCustomize.Size = new System.Drawing.Size(154, 22);
            this.menuItem_SaveCustomize.Text = "存表情";
            this.menuItem_SaveCustomize.Click += new System.EventHandler(this.MenuItem_SaveCustomize_Click);
            // 
            // menuItem_MultiSelect
            // 
            this.menuItem_MultiSelect.Name = "menuItem_MultiSelect";
            this.menuItem_MultiSelect.Size = new System.Drawing.Size(154, 22);
            this.menuItem_MultiSelect.Text = "多选";
            this.menuItem_MultiSelect.Click += new System.EventHandler(this.MenuItem_MultiSelect_Click);
            // 
            // menuItem_Reply
            // 
            this.menuItem_Reply.Name = "menuItem_Reply";
            this.menuItem_Reply.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Reply.Text = "回复";
            this.menuItem_Reply.Click += new System.EventHandler(this.MenuItem_Reply_Click);
            // 
            // menuItem_Translate
            // 
            this.menuItem_Translate.Name = "menuItem_Translate";
            this.menuItem_Translate.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Translate.Text = "翻译";
            // 
            // menuItem_AudioToText
            // 
            this.menuItem_AudioToText.Name = "menuItem_AudioToText";
            this.menuItem_AudioToText.Size = new System.Drawing.Size(154, 22);
            this.menuItem_AudioToText.Text = "语音转文字";
            // 
            // separator_three
            // 
            this.separator_three.Name = "separator_three";
            this.separator_three.Size = new System.Drawing.Size(151, 6);
            // 
            // menuItem_Dowmload
            // 
            this.menuItem_Dowmload.Name = "menuItem_Dowmload";
            this.menuItem_Dowmload.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Dowmload.Text = "下载";
            this.menuItem_Dowmload.Click += new System.EventHandler(this.MenuItem_Dowmload_Click);
            // 
            // menuItem_SaveAs
            // 
            this.menuItem_SaveAs.Name = "menuItem_SaveAs";
            this.menuItem_SaveAs.Size = new System.Drawing.Size(154, 22);
            this.menuItem_SaveAs.Text = "另存为...";
            this.menuItem_SaveAs.Click += new System.EventHandler(this.MenuItem_SaveAs_Click);
            // 
            // menuItem_OpenFileFolder
            // 
            this.menuItem_OpenFileFolder.Name = "menuItem_OpenFileFolder";
            this.menuItem_OpenFileFolder.Size = new System.Drawing.Size(154, 22);
            this.menuItem_OpenFileFolder.Text = "在文件夹中显示";
            this.menuItem_OpenFileFolder.Click += new System.EventHandler(this.MenuItem_OpenFileFolder_Click);
            // 
            // separator_four
            // 
            this.separator_four.Name = "separator_four";
            this.separator_four.Size = new System.Drawing.Size(151, 6);
            // 
            // menuItem_Delete
            // 
            this.menuItem_Delete.Name = "menuItem_Delete";
            this.menuItem_Delete.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Delete.Text = "删除";
            this.menuItem_Delete.Click += new System.EventHandler(this.MenuItem_Delete_Click);
            // 
            // panMultiSelect
            // 
            this.panMultiSelect.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.panMultiSelect.BackColor = System.Drawing.Color.WhiteSmoke;
            this.panMultiSelect.Controls.Add(this.lab_splitMultiSelect);
            this.panMultiSelect.Controls.Add(this.multiSelectPanel);
            this.panMultiSelect.Controls.Add(this.lblClose);
            this.panMultiSelect.Location = new System.Drawing.Point(0, 496);
            this.panMultiSelect.Name = "panMultiSelect";
            this.panMultiSelect.Size = new System.Drawing.Size(725, 160);
            this.panMultiSelect.TabIndex = 19;
            this.panMultiSelect.Visible = false;
            // 
            // lab_splitMultiSelect
            // 
            this.lab_splitMultiSelect.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lab_splitMultiSelect.BackColor = System.Drawing.Color.Gainsboro;
            this.lab_splitMultiSelect.Location = new System.Drawing.Point(0, 0);
            this.lab_splitMultiSelect.Name = "lab_splitMultiSelect";
            this.lab_splitMultiSelect.Size = new System.Drawing.Size(725, 1);
            this.lab_splitMultiSelect.TabIndex = 12;
            // 
            // multiSelectPanel
            // 
            this.multiSelectPanel.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.multiSelectPanel.BackColor = System.Drawing.Color.WhiteSmoke;
            this.multiSelectPanel.FdTalking = null;
            this.multiSelectPanel.List_Msgs = null;
            this.multiSelectPanel.Location = new System.Drawing.Point(212, 40);
            this.multiSelectPanel.Name = "multiSelectPanel";
            this.multiSelectPanel.showInfo_panel = null;
            this.multiSelectPanel.Size = new System.Drawing.Size(300, 92);
            this.multiSelectPanel.TabIndex = 11;
            // 
            // lblClose
            // 
            this.lblClose.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblClose.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblClose.Image = ((System.Drawing.Image)(resources.GetObject("lblClose.Image")));
            this.lblClose.Location = new System.Drawing.Point(700, 1);
            this.lblClose.Name = "lblClose";
            this.lblClose.Size = new System.Drawing.Size(25, 25);
            this.lblClose.TabIndex = 10;
            this.lblClose.Click += new System.EventHandler(this.LblClose_Click);
            // 
            // xListView
            // 
            this.xListView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.xListView.BackColor = System.Drawing.Color.WhiteSmoke;
            this.xListView.Location = new System.Drawing.Point(0, 35);
            this.xListView.Name = "xListView";
            this.xListView.ScrollBarWidth = 10;
            this.xListView.Size = new System.Drawing.Size(725, 460);
            this.xListView.TabIndex = 2;
            // 
            // replyPanel
            // 
            this.replyPanel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.replyPanel.BackColor = System.Drawing.Color.White;
            this.replyPanel.Location = new System.Drawing.Point(0, 461);
            this.replyPanel.Name = "replyPanel";
            messageObject1.BubbleHeight = 0;
            messageObject1.BubbleWidth = 0;
            messageObject1.content = null;
            messageObject1.deleteTime = -1D;
            messageObject1.fileName = null;
            messageObject1.fileSize = ((long)(0));
            messageObject1.FromId = null;
            messageObject1.fromUserId = null;
            messageObject1.fromUserName = null;
            messageObject1.isDownload = 0;
            messageObject1.isEncrypt = 0;
            messageObject1.isGroup = 0;
            messageObject1.isLoading = 0;
            messageObject1.isRead = 0;
            messageObject1.isReadDel = 0;
            messageObject1.isRecall = 0;
            messageObject1.isRefresh = false;
            messageObject1.isSend = 0;
            messageObject1.isUpload = 0;
            messageObject1.location_x = 0D;
            messageObject1.location_y = 0D;
            messageObject1.messageId = null;
            messageObject1.myUserId = null;
            messageObject1.Nodisturb = 0;
            messageObject1.objectId = null;
            messageObject1.PlatformType = 0;
            messageObject1.ReadDelTime = 0;
            messageObject1.readPersons = 0;
            messageObject1.reSendCount = 0;
            messageObject1.roomJid = null;
            messageObject1.rowIndex = 0;
            messageObject1.timeLen = 0;
            messageObject1.timeSend = 0D;
            messageObject1.ToId = null;
            messageObject1.toUserId = null;
            messageObject1.toUserName = null;
            messageObject1.type = WinFrmTalk.kWCMessageType.kWCMessageTypeNone;
            this.replyPanel.ReplyMsg = messageObject1;
            this.replyPanel.Size = new System.Drawing.Size(725, 33);
            this.replyPanel.TabIndex = 5;
            this.replyPanel.Visible = false;
            // 
            // roomNotice
            // 
            this.roomNotice.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.roomNotice.BackColor = System.Drawing.Color.White;
            this.roomNotice.Location = new System.Drawing.Point(0, 35);
            this.roomNotice.Name = "roomNotice";
            this.roomNotice.RoomData = null;
            this.roomNotice.Size = new System.Drawing.Size(712, 33);
            this.roomNotice.TabIndex = 20;
            this.roomNotice.Visible = false;
            // 
            // unReadNumPanel
            // 
            this.unReadNumPanel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.unReadNumPanel.BackColor = System.Drawing.Color.White;
            this.unReadNumPanel.Location = new System.Drawing.Point(545, 70);
            this.unReadNumPanel.Name = "unReadNumPanel";
            this.unReadNumPanel.Size = new System.Drawing.Size(156, 32);
            this.unReadNumPanel.TabIndex = 21;
            this.unReadNumPanel.Visible = false;
            // 
            // userSoundRecording
            // 
            this.userSoundRecording.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.userSoundRecording.BackColor = System.Drawing.Color.White;
            this.userSoundRecording.Location = new System.Drawing.Point(0, 461);
            this.userSoundRecording.Name = "userSoundRecording";
            this.userSoundRecording.PathCallback = null;
            this.userSoundRecording.Size = new System.Drawing.Size(725, 33);
            this.userSoundRecording.TabIndex = 23;
            this.userSoundRecording.Visible = false;
            // 
            // AtMePanel
            // 
            this.AtMePanel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.AtMePanel.BackColor = System.Drawing.Color.White;
            this.AtMePanel.Location = new System.Drawing.Point(545, 420);
            this.AtMePanel.Name = "AtMePanel";
            this.AtMePanel.Size = new System.Drawing.Size(156, 32);
            this.AtMePanel.TabIndex = 22;
            this.AtMePanel.Visible = false;
            // 
            // ShowMsgPanel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Controls.Add(this.Bottom_Panel);
            this.Controls.Add(this.xListView);
            this.Controls.Add(this.panTitle);
            this.Controls.Add(this.replyPanel);
            this.Controls.Add(this.panMultiSelect);
            this.Controls.Add(this.roomNotice);
            this.Controls.Add(this.unReadNumPanel);
            this.Controls.Add(this.userSoundRecording);
            this.Controls.Add(this.AtMePanel);
            this.Name = "ShowMsgPanel";
            this.Size = new System.Drawing.Size(725, 656);
            this.Load += new System.EventHandler(this.ShowMsgPanel_Load);
            this.SizeChanged += new System.EventHandler(this.ShowMsgPanel_SizeChanged);
            this.panTitle.ResumeLayout(false);
            this.Bottom_Panel.ResumeLayout(false);
            this.menuTxtSend.ResumeLayout(false);
            this.Tool_Panel.ResumeLayout(false);
            this.cmsMsgMenu.ResumeLayout(false);
            this.panMultiSelect.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panTitle;
        private System.Windows.Forms.Label lab_splitTitle;
        private System.Windows.Forms.Label lab_detial;
        private System.Windows.Forms.Label labName;
        private System.Windows.Forms.Panel Bottom_Panel;
        private System.Windows.Forms.Button btnSend;
        private System.Windows.Forms.RichTextBox txtSend;
        private System.Windows.Forms.Panel Tool_Panel;
        private System.Windows.Forms.Label lblSoundRecord;
        private System.Windows.Forms.Label lblPhotography;
        private System.Windows.Forms.Label lblCamera;
        private System.Windows.Forms.Label lblLocation;
        private System.Windows.Forms.Label lblAudio;
        private System.Windows.Forms.Label lblVideo;
        private System.Windows.Forms.Label lblHistory;
        private System.Windows.Forms.Label lblScreen;
        private System.Windows.Forms.Label lab_splitTool;
        private System.Windows.Forms.Label lblSendFile;
        private System.Windows.Forms.Label lblExpression;
        private System.Windows.Forms.ToolTip toolTip;
        internal CCWin.SkinControl.SkinContextMenuStrip cmsMsgMenu;
        private System.Windows.Forms.ToolStripMenuItem menuItem_NoneSound;
        private System.Windows.Forms.ToolStripMenuItem menuItem_Copy;
        private System.Windows.Forms.ToolStripSeparator separator_two;
        public System.Windows.Forms.ToolStripMenuItem menuItem_Reply;
        private System.Windows.Forms.ToolStripMenuItem menuItem_Translate;
        private System.Windows.Forms.ToolStripMenuItem menuItem_AudioToText;
        private System.Windows.Forms.ToolStripSeparator separator_three;
        private System.Windows.Forms.ToolStripSeparator separator_four;
        private ReplyPanel replyPanel;
        public System.Windows.Forms.ToolStripMenuItem menuItem_Dowmload;
        public System.Windows.Forms.ToolStripMenuItem menuItem_SaveAs;
        public System.Windows.Forms.ToolStripMenuItem menuItem_OpenFileFolder;
        public System.Windows.Forms.ToolStripMenuItem menuItem_Delete;
        public System.Windows.Forms.ToolStripMenuItem menuItem_Transcribe;
        public System.Windows.Forms.ToolStripMenuItem menuItem_Recall;
        public System.Windows.Forms.ToolStripMenuItem menuItem_Relay;
        public System.Windows.Forms.ToolStripMenuItem menuItem_Collect;
        public System.Windows.Forms.ToolStripMenuItem menuItem_SaveCustomize;
        public System.Windows.Forms.ToolStripMenuItem menuItem_MultiSelect;
        private System.Windows.Forms.Panel panMultiSelect;
        private System.Windows.Forms.Label lab_splitMultiSelect;
        private System.Windows.Forms.Label lblClose;
        private Roomannounce roomNotice;
        private UnReadNumPanel unReadNumPanel;
        private USERemindMe AtMePanel;
        private UserSoundRecording userSoundRecording;
        public MultiSelectPanel multiSelectPanel;
        internal CCWin.SkinControl.SkinContextMenuStrip menuTxtSend;
        private System.Windows.Forms.ToolStripMenuItem menuItem_paste;
        public TestListView.XListView xListView;
        public System.Windows.Forms.ToolStripSeparator separator_one;
        private System.Windows.Forms.Label lbl_qreply;
        private System.Windows.Forms.Button btnEnding;
        private System.Windows.Forms.Label lblLive;
    }
}
