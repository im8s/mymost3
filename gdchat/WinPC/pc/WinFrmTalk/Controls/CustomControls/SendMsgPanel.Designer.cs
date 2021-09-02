namespace WinFrmTalk.Controls.CustomControls
{
    partial class SendMsgPanel
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(SendMsgPanel));
            WinFrmTalk.Model.MessageObject messageObject1 = new WinFrmTalk.Model.MessageObject();
            this.pnlMain = new System.Windows.Forms.Panel();
            this.Message_panel = new System.Windows.Forms.Panel();
            this.Takeconter_panel = new System.Windows.Forms.Panel();
            this.ShowInfoVScroll = new WinFrmTalk.Controls.CustomControls.MsgTabVScroll();
            this.showInfo_Panel = new WinFrmTalk.TableLayoutPanelEx();
            this.Bottom_Panel = new System.Windows.Forms.Panel();
            this.btnSend = new System.Windows.Forms.Button();
            this.txtSend = new System.Windows.Forms.RichTextBox();
            this.Tool_Panel = new System.Windows.Forms.Panel();
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
            this.panMultiSelect = new System.Windows.Forms.Panel();
            this.lab_splitMultiSelect = new System.Windows.Forms.Label();
            this.multiSelectPanel1 = new WinFrmTalk.Controls.CustomControls.MultiSelectPanel();
            this.lblClose = new System.Windows.Forms.Label();
            this.panTitle = new System.Windows.Forms.Panel();
            this.lab_splitTitle = new System.Windows.Forms.Label();
            this.lab_detial = new System.Windows.Forms.Label();
            this.labName = new System.Windows.Forms.Label();
            this.roomNotice = new WinFrmTalk.Controls.Roomannounce();
            this.replyPanel = new WinFrmTalk.Controls.CustomControls.ReplyPanel();
            this.userSoundRecording = new WinFrmTalk.Controls.CustomControls.UserSoundRecording();
            this.AtMePanel = new WinFrmTalk.Controls.CustomControls.USERemindMe();
            this.unReadNumPanel = new WinFrmTalk.Controls.CustomControls.UnReadNumPanel();
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
            this.toolTip = new System.Windows.Forms.ToolTip(this.components);
            this.pnlMain.SuspendLayout();
            this.Message_panel.SuspendLayout();
            this.Takeconter_panel.SuspendLayout();
            this.Bottom_Panel.SuspendLayout();
            this.Tool_Panel.SuspendLayout();
            this.panMultiSelect.SuspendLayout();
            this.panTitle.SuspendLayout();
            this.cmsMsgMenu.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlMain
            // 
            this.pnlMain.Controls.Add(this.Message_panel);
            this.pnlMain.Controls.Add(this.panTitle);
            this.pnlMain.Controls.Add(this.roomNotice);
            this.pnlMain.Controls.Add(this.replyPanel);
            this.pnlMain.Controls.Add(this.userSoundRecording);
            this.pnlMain.Controls.Add(this.AtMePanel);
            this.pnlMain.Controls.Add(this.unReadNumPanel);
            this.pnlMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlMain.Location = new System.Drawing.Point(0, 0);
            this.pnlMain.Name = "pnlMain";
            this.pnlMain.Size = new System.Drawing.Size(725, 658);
            this.pnlMain.TabIndex = 4;
            // 
            // Message_panel
            // 
            this.Message_panel.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Message_panel.Controls.Add(this.Takeconter_panel);
            this.Message_panel.Controls.Add(this.Bottom_Panel);
            this.Message_panel.Controls.Add(this.panMultiSelect);
            this.Message_panel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.Message_panel.Location = new System.Drawing.Point(0, 35);
            this.Message_panel.Name = "Message_panel";
            this.Message_panel.Size = new System.Drawing.Size(725, 623);
            this.Message_panel.TabIndex = 10;
            // 
            // Takeconter_panel
            // 
            this.Takeconter_panel.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.Takeconter_panel.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Takeconter_panel.Controls.Add(this.ShowInfoVScroll);
            this.Takeconter_panel.Controls.Add(this.showInfo_Panel);
            this.Takeconter_panel.Location = new System.Drawing.Point(0, 0);
            this.Takeconter_panel.Name = "Takeconter_panel";
            this.Takeconter_panel.Size = new System.Drawing.Size(725, 455);
            this.Takeconter_panel.TabIndex = 2;
            // 
            // ShowInfoVScroll
            // 
            this.ShowInfoVScroll.canAdd = 0;
            this.ShowInfoVScroll.Dock = System.Windows.Forms.DockStyle.Right;
            this.ShowInfoVScroll.Location = new System.Drawing.Point(713, 0);
            this.ShowInfoVScroll.Name = "ShowInfoVScroll";
            this.ShowInfoVScroll.Size = new System.Drawing.Size(12, 455);
            this.ShowInfoVScroll.TabIndex = 7;
            // 
            // showInfo_Panel
            // 
            this.showInfo_Panel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.showInfo_Panel.BackColor = System.Drawing.Color.Transparent;
            this.showInfo_Panel.ColumnCount = 2;
            this.showInfo_Panel.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 0F));
            this.showInfo_Panel.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.showInfo_Panel.Location = new System.Drawing.Point(6, 3);
            this.showInfo_Panel.Margin = new System.Windows.Forms.Padding(3, 3, 20, 3);
            this.showInfo_Panel.Name = "showInfo_Panel";
            this.showInfo_Panel.RowCount = 1;
            this.showInfo_Panel.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 100F));
            this.showInfo_Panel.Size = new System.Drawing.Size(699, 100);
            this.showInfo_Panel.TabIndex = 5;
            this.showInfo_Panel.SizeChanged += new System.EventHandler(this.showInfo_Panel_SizeChanged);
            this.showInfo_Panel.ControlAdded += new System.Windows.Forms.ControlEventHandler(this.showInfo_Panel_ControlAdded);
            this.showInfo_Panel.ControlRemoved += new System.Windows.Forms.ControlEventHandler(this.showInfo_Panel_ControlRemoved);
            // 
            // Bottom_Panel
            // 
            this.Bottom_Panel.BackColor = System.Drawing.Color.White;
            this.Bottom_Panel.Controls.Add(this.btnSend);
            this.Bottom_Panel.Controls.Add(this.txtSend);
            this.Bottom_Panel.Controls.Add(this.Tool_Panel);
            this.Bottom_Panel.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.Bottom_Panel.Location = new System.Drawing.Point(0, 463);
            this.Bottom_Panel.Name = "Bottom_Panel";
            this.Bottom_Panel.Size = new System.Drawing.Size(725, 160);
            this.Bottom_Panel.TabIndex = 3;
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
            this.btnSend.Click += new System.EventHandler(this.btnSend_Click);
            this.btnSend.MouseEnter += new System.EventHandler(this.btnSend_MouseEnter);
            this.btnSend.MouseLeave += new System.EventHandler(this.btnSend_MouseLeave);
            // 
            // txtSend
            // 
            this.txtSend.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtSend.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.txtSend.EnableAutoDragDrop = true;
            this.txtSend.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.txtSend.Location = new System.Drawing.Point(16, 46);
            this.txtSend.Name = "txtSend";
            this.txtSend.Size = new System.Drawing.Size(696, 77);
            this.txtSend.TabIndex = 15;
            this.txtSend.Text = "";
            this.txtSend.TextChanged += new System.EventHandler(this.txtSend_TextChanged);
            this.txtSend.KeyDown += new System.Windows.Forms.KeyEventHandler(this.txtSend_KeyDown);
            this.txtSend.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtSend_KeyPress);
            this.txtSend.MouseDown += new System.Windows.Forms.MouseEventHandler(this.txtSend_MouseDown);
            // 
            // Tool_Panel
            // 
            this.Tool_Panel.Controls.Add(this.lblSoundRecord);
            this.Tool_Panel.Controls.Add(this.lblPhotography);
            this.Tool_Panel.Controls.Add(this.lblCamera);
            this.Tool_Panel.Controls.Add(this.lblLocation);
            this.Tool_Panel.Controls.Add(this.lblAudio);
            this.Tool_Panel.Controls.Add(this.lblVideo);
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
            // lblSoundRecord
            // 
            this.lblSoundRecord.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblSoundRecord.Image = ((System.Drawing.Image)(resources.GetObject("lblSoundRecord.Image")));
            this.lblSoundRecord.Location = new System.Drawing.Point(186, 1);
            this.lblSoundRecord.Name = "lblSoundRecord";
            this.lblSoundRecord.Size = new System.Drawing.Size(34, 34);
            this.lblSoundRecord.TabIndex = 13;
            this.lblSoundRecord.Click += new System.EventHandler(this.lblSoundRecord_Click);
            // 
            // lblPhotography
            // 
            this.lblPhotography.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblPhotography.Image = ((System.Drawing.Image)(resources.GetObject("lblPhotography.Image")));
            this.lblPhotography.Location = new System.Drawing.Point(254, 1);
            this.lblPhotography.Name = "lblPhotography";
            this.lblPhotography.Size = new System.Drawing.Size(34, 34);
            this.lblPhotography.TabIndex = 12;
            this.lblPhotography.Click += new System.EventHandler(this.lblPhotography_Click);
            // 
            // lblCamera
            // 
            this.lblCamera.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblCamera.Image = ((System.Drawing.Image)(resources.GetObject("lblCamera.Image")));
            this.lblCamera.Location = new System.Drawing.Point(220, 1);
            this.lblCamera.Name = "lblCamera";
            this.lblCamera.Size = new System.Drawing.Size(34, 34);
            this.lblCamera.TabIndex = 11;
            this.lblCamera.Click += new System.EventHandler(this.lblCamera_Click);
            // 
            // lblLocation
            // 
            this.lblLocation.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblLocation.Image = ((System.Drawing.Image)(resources.GetObject("lblLocation.Image")));
            this.lblLocation.Location = new System.Drawing.Point(152, 1);
            this.lblLocation.Name = "lblLocation";
            this.lblLocation.Size = new System.Drawing.Size(34, 34);
            this.lblLocation.TabIndex = 10;
            this.lblLocation.Click += new System.EventHandler(this.lblLocation_Click);
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
            this.lblAudio.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lblAudio_MouseDown);
            this.lblAudio.MouseHover += new System.EventHandler(this.lblAudio_MouseHover);
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
            this.lblVideo.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lblVideo_MouseDown);
            this.lblVideo.MouseHover += new System.EventHandler(this.lblVideo_MouseHover);
            // 
            // lblHistory
            // 
            this.lblHistory.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblHistory.Image = ((System.Drawing.Image)(resources.GetObject("lblHistory.Image")));
            this.lblHistory.Location = new System.Drawing.Point(118, 1);
            this.lblHistory.Name = "lblHistory";
            this.lblHistory.Size = new System.Drawing.Size(34, 34);
            this.lblHistory.TabIndex = 7;
            this.lblHistory.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lblHistory_MouseDown);
            this.lblHistory.MouseHover += new System.EventHandler(this.lblHistory_MouseHover);
            // 
            // lblScreen
            // 
            this.lblScreen.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblScreen.Image = ((System.Drawing.Image)(resources.GetObject("lblScreen.Image")));
            this.lblScreen.Location = new System.Drawing.Point(84, 1);
            this.lblScreen.Name = "lblScreen";
            this.lblScreen.Size = new System.Drawing.Size(34, 34);
            this.lblScreen.TabIndex = 6;
            this.lblScreen.Click += new System.EventHandler(this.lblScreen_Click);
            this.lblScreen.MouseHover += new System.EventHandler(this.lblScreen_MouseHover);
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
            this.lblSendFile.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lblSendFile_MouseDown);
            this.lblSendFile.MouseHover += new System.EventHandler(this.lblSendFile_MouseHover);
            // 
            // lblExpression
            // 
            this.lblExpression.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblExpression.Image = global::WinFrmTalk.Properties.Resources.ExpressionNormal;
            this.lblExpression.Location = new System.Drawing.Point(16, 0);
            this.lblExpression.Name = "lblExpression";
            this.lblExpression.Size = new System.Drawing.Size(34, 34);
            this.lblExpression.TabIndex = 0;
            this.lblExpression.MouseClick += new System.Windows.Forms.MouseEventHandler(this.lblExpression_MouseClick);
            this.lblExpression.MouseHover += new System.EventHandler(this.lblExpression_MouseHover);
            // 
            // panMultiSelect
            // 
            this.panMultiSelect.BackColor = System.Drawing.Color.WhiteSmoke;
            this.panMultiSelect.Controls.Add(this.lab_splitMultiSelect);
            this.panMultiSelect.Controls.Add(this.multiSelectPanel1);
            this.panMultiSelect.Controls.Add(this.lblClose);
            this.panMultiSelect.Location = new System.Drawing.Point(0, 463);
            this.panMultiSelect.Name = "panMultiSelect";
            this.panMultiSelect.Size = new System.Drawing.Size(725, 160);
            this.panMultiSelect.TabIndex = 18;
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
            // multiSelectPanel1
            // 
            this.multiSelectPanel1.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.multiSelectPanel1.BackColor = System.Drawing.Color.WhiteSmoke;
            this.multiSelectPanel1.FdTalking = null;
            this.multiSelectPanel1.List_Msgs = null;
            this.multiSelectPanel1.Location = new System.Drawing.Point(212, 40);
            this.multiSelectPanel1.Name = "multiSelectPanel1";
            this.multiSelectPanel1.showInfo_panel = null;
            this.multiSelectPanel1.Size = new System.Drawing.Size(300, 92);
            this.multiSelectPanel1.TabIndex = 11;
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
            this.lblClose.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lblClose_MouseDown);
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
            this.panTitle.TabIndex = 0;
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
            this.lab_detial.MouseClick += new System.Windows.Forms.MouseEventHandler(this.lab_detial_MouseClick);
            // 
            // labName
            // 
            this.labName.AutoSize = true;
            this.labName.BackColor = System.Drawing.Color.Transparent;
            this.labName.Cursor = System.Windows.Forms.Cursors.Hand;
            this.labName.Font = new System.Drawing.Font("微软雅黑", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.labName.Location = new System.Drawing.Point(27, 4);
            this.labName.Name = "labName";
            this.labName.Size = new System.Drawing.Size(126, 25);
            this.labName.TabIndex = 2;
            this.labName.Text = "我是默认名称";
            this.labName.MouseDown += new System.Windows.Forms.MouseEventHandler(this.labName_MouseDown);
            // 
            // roomNotice
            // 
            this.roomNotice.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.roomNotice.BackColor = System.Drawing.Color.White;
            this.roomNotice.Location = new System.Drawing.Point(0, 35);
            this.roomNotice.Name = "roomNotice";
            this.roomNotice.RoomData = null;
            this.roomNotice.Size = new System.Drawing.Size(725, 33);
            this.roomNotice.TabIndex = 0;
            // 
            // replyPanel
            // 
            this.replyPanel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.replyPanel.BackColor = System.Drawing.Color.White;
            this.replyPanel.Location = new System.Drawing.Point(0, 464);
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
            messageObject1.isRead = 0;
            messageObject1.isReadDel = 0;
            messageObject1.isRecall = 0;
            messageObject1.isSend = 0;
            messageObject1.isUpload = 0;
            messageObject1.location_x = 0D;
            messageObject1.location_y = 0D;
            messageObject1.messageId = null;
            messageObject1.myUserId = null;
            messageObject1.objectId = null;
            messageObject1.PlatformType = 0;
            messageObject1.ReadDelTime = 0;
            messageObject1.readPersons = 0;
            //messageObject1.readTime = 0;
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
            this.replyPanel.TabIndex = 0;
            // 
            // userSoundRecording
            // 
            this.userSoundRecording.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.userSoundRecording.BackColor = System.Drawing.Color.White;
            this.userSoundRecording.Location = new System.Drawing.Point(0, 464);
            this.userSoundRecording.Name = "userSoundRecording";
            this.userSoundRecording.PathCallback = null;
            this.userSoundRecording.Size = new System.Drawing.Size(725, 33);
            this.userSoundRecording.TabIndex = 8;
            // 
            // AtMePanel
            // 
            this.AtMePanel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.AtMePanel.BackColor = System.Drawing.Color.White;
            this.AtMePanel.Location = new System.Drawing.Point(545, 420);
            this.AtMePanel.Name = "AtMePanel";
            this.AtMePanel.Size = new System.Drawing.Size(156, 32);
            this.AtMePanel.TabIndex = 0;
            this.AtMePanel.Visible = false;
            // 
            // unReadNumPanel
            // 
            this.unReadNumPanel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.unReadNumPanel.BackColor = System.Drawing.Color.White;
            this.unReadNumPanel.Location = new System.Drawing.Point(545, 50);
            this.unReadNumPanel.Name = "unReadNumPanel";
            this.unReadNumPanel.Size = new System.Drawing.Size(156, 32);
            this.unReadNumPanel.TabIndex = 0;
            this.unReadNumPanel.Visible = false;
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
            this.menuItem_Transcribe,
            this.menuItem_NoneSound,
            this.separator_one,
            this.menuItem_Copy,
            this.separator_two,
            this.menuItem_Recall,
            this.menuItem_Relay,
            this.menuItem_Collect,
            this.menuItem_SaveCustomize,
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
            this.menuItem_Transcribe.Click += new System.EventHandler(this.menuItem_Transcribe_Click);
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
            this.menuItem_Copy.Click += new System.EventHandler(this.menuItem_Copy_Click);
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
            this.menuItem_Recall.Click += new System.EventHandler(this.menuItem_Recall_Click);
            // 
            // menuItem_Relay
            // 
            this.menuItem_Relay.Name = "menuItem_Relay";
            this.menuItem_Relay.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Relay.Text = "转发";
            this.menuItem_Relay.Click += new System.EventHandler(this.menuItem_Relay_Click);
            // 
            // menuItem_Collect
            // 
            this.menuItem_Collect.Name = "menuItem_Collect";
            this.menuItem_Collect.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Collect.Text = "收藏";
            this.menuItem_Collect.Click += new System.EventHandler(this.menuItem_Collect_Click);
            // 
            // menuItem_SaveCustomize
            // 
            this.menuItem_SaveCustomize.Name = "menuItem_SaveCustomize";
            this.menuItem_SaveCustomize.Size = new System.Drawing.Size(154, 22);
            this.menuItem_SaveCustomize.Text = "存表情";
            this.menuItem_SaveCustomize.Click += new System.EventHandler(this.menuItem_SaveCustomize_Click);
            // 
            // menuItem_MultiSelect
            // 
            this.menuItem_MultiSelect.Name = "menuItem_MultiSelect";
            this.menuItem_MultiSelect.Size = new System.Drawing.Size(154, 22);
            this.menuItem_MultiSelect.Text = "多选";
            this.menuItem_MultiSelect.Click += new System.EventHandler(this.menuItem_MultiSelect_Click);
            // 
            // menuItem_Reply
            // 
            this.menuItem_Reply.Name = "menuItem_Reply";
            this.menuItem_Reply.Size = new System.Drawing.Size(154, 22);
            this.menuItem_Reply.Text = "回复";
            this.menuItem_Reply.Click += new System.EventHandler(this.menuItem_Reply_Click);
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
            this.menuItem_Dowmload.Click += new System.EventHandler(this.menuItem_Dowmload_Click);
            // 
            // menuItem_SaveAs
            // 
            this.menuItem_SaveAs.Name = "menuItem_SaveAs";
            this.menuItem_SaveAs.Size = new System.Drawing.Size(154, 22);
            this.menuItem_SaveAs.Text = "另存为...";
            this.menuItem_SaveAs.Click += new System.EventHandler(this.menuItem_SaveAs_Click);
            // 
            // menuItem_OpenFileFolder
            // 
            this.menuItem_OpenFileFolder.Name = "menuItem_OpenFileFolder";
            this.menuItem_OpenFileFolder.Size = new System.Drawing.Size(154, 22);
            this.menuItem_OpenFileFolder.Text = "在文件夹中显示";
            this.menuItem_OpenFileFolder.Click += new System.EventHandler(this.menuItem_OpenFileFolder_Click);
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
            this.menuItem_Delete.Click += new System.EventHandler(this.menuItem_Delete_Click);
            // 
            // SendMsgPanel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.pnlMain);
            this.DoubleBuffered = true;
            this.Name = "SendMsgPanel";
            this.Size = new System.Drawing.Size(725, 658);
            this.Load += new System.EventHandler(this.SendMsgPanel_Load);
            this.pnlMain.ResumeLayout(false);
            this.Message_panel.ResumeLayout(false);
            this.Takeconter_panel.ResumeLayout(false);
            this.Bottom_Panel.ResumeLayout(false);
            this.Tool_Panel.ResumeLayout(false);
            this.panMultiSelect.ResumeLayout(false);
            this.panTitle.ResumeLayout(false);
            this.panTitle.PerformLayout();
            this.cmsMsgMenu.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel pnlMain;
        private System.Windows.Forms.Panel Message_panel;
        private System.Windows.Forms.Panel Takeconter_panel;
        private WinFrmTalk.TableLayoutPanelEx showInfo_Panel;
        private System.Windows.Forms.Panel panTitle;
        private System.Windows.Forms.Label lab_detial;
        private System.Windows.Forms.Label labName;
        private System.Windows.Forms.Label lab_splitTitle;
        internal CCWin.SkinControl.SkinContextMenuStrip cmsMsgMenu;
        private System.Windows.Forms.ToolStripMenuItem menuItem_NoneSound;
        private System.Windows.Forms.ToolStripSeparator separator_one;
        private System.Windows.Forms.ToolStripMenuItem menuItem_Copy;
        private System.Windows.Forms.ToolStripSeparator separator_two;
        private System.Windows.Forms.ToolStripMenuItem menuItem_Recall;
        private System.Windows.Forms.ToolStripMenuItem menuItem_Relay;
        private System.Windows.Forms.ToolStripMenuItem menuItem_Collect;
        private System.Windows.Forms.ToolStripMenuItem menuItem_MultiSelect;
        private System.Windows.Forms.ToolStripMenuItem menuItem_Translate;
        private System.Windows.Forms.ToolStripMenuItem menuItem_AudioToText;
        private System.Windows.Forms.ToolStripSeparator separator_three;
        private System.Windows.Forms.ToolStripMenuItem menuItem_SaveAs;
        private System.Windows.Forms.ToolStripSeparator separator_four;
        private System.Windows.Forms.ToolStripMenuItem menuItem_Delete;
        public MsgTabVScroll ShowInfoVScroll;
        private System.Windows.Forms.Panel panMultiSelect;
        private System.Windows.Forms.Label lblClose;
        private MultiSelectPanel multiSelectPanel1;
        private System.Windows.Forms.Panel Bottom_Panel;
        private System.Windows.Forms.Button btnSend;
        private System.Windows.Forms.RichTextBox txtSend;
        private System.Windows.Forms.Panel Tool_Panel;
        private System.Windows.Forms.Label lblHistory;
        private System.Windows.Forms.Label lblScreen;
        private System.Windows.Forms.Label lab_splitTool;
        private System.Windows.Forms.Label lblSendFile;
        private System.Windows.Forms.Label lblExpression;
        private System.Windows.Forms.Label lab_splitMultiSelect;
        private System.Windows.Forms.Label lblVideo;
        private System.Windows.Forms.Label lblAudio;
        private Roomannounce roomNotice;
        private System.Windows.Forms.ToolStripMenuItem menuItem_OpenFileFolder;
        private ReplyPanel replyPanel;
        private System.Windows.Forms.ToolStripMenuItem menuItem_SaveCustomize;
        private System.Windows.Forms.ToolStripMenuItem menuItem_Transcribe;
        private USERemindMe AtMePanel;
        private UnReadNumPanel unReadNumPanel;
        private System.Windows.Forms.ToolTip toolTip;
        private System.Windows.Forms.ToolStripMenuItem menuItem_Dowmload;
        private System.Windows.Forms.Label lblPhotography;
        private System.Windows.Forms.Label lblCamera;
        private System.Windows.Forms.Label lblLocation;
        private System.Windows.Forms.Label lblSoundRecord;
        private UserSoundRecording userSoundRecording;
        public System.Windows.Forms.ToolStripMenuItem menuItem_Reply;
    }
}
