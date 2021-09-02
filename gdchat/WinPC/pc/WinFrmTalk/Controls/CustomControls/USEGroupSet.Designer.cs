namespace WinFrmTalk.Controls.CustomControls
{
    partial class USEGroupSet
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
            this.btnseemore = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.panel2 = new System.Windows.Forms.Panel();
            this.tabMember = new System.Windows.Forms.FlowLayoutPanel();
            this.btnAdd = new WinFrmTalk.Controls.CustomControls.USEpicAddName();
            this.btnDel = new WinFrmTalk.Controls.CustomControls.USEpicAddName();
            this.palgroupCtl = new System.Windows.Forms.FlowLayoutPanel();
            this.infoName = new WinFrmTalk.InfoCard();
            this.infoNotice = new WinFrmTalk.InfoCard();
            this.infoMenge = new WinFrmTalk.InfoCard();
            this.infonickname = new WinFrmTalk.InfoCard();
            this.infoGroupQRCode = new WinFrmTalk.InfoCard();
            this.infoFile = new WinFrmTalk.InfoCard();
            this.infoDes = new WinFrmTalk.InfoCard();
            this.panel3 = new System.Windows.Forms.Panel();
            this.lblNews = new System.Windows.Forms.Label();
            this.lblOverdueDate = new System.Windows.Forms.Label();
            this.lblSpiltLine = new System.Windows.Forms.Label();
            this.infoNoExe = new WinFrmTalk.Controls.CustomControls.USeCheckData();
            this.infoTop = new WinFrmTalk.Controls.CustomControls.USeCheckData();
            this.btnclear = new System.Windows.Forms.Button();
            this.btnexite = new System.Windows.Forms.Button();
            this.cmsOverdueDate = new CCWin.SkinControl.SkinContextMenuStrip();
            this.tsmForever = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmHour = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmDay = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmWeek = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmMonth = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmSeason = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmYear = new System.Windows.Forms.ToolStripMenuItem();
            this.lblLeftLine = new System.Windows.Forms.Label();
            this.showInfoVScroll = new WinFrmTalk.MyVScrollBar();
            this.panel1.SuspendLayout();
            this.panel2.SuspendLayout();
            this.tabMember.SuspendLayout();
            this.palgroupCtl.SuspendLayout();
            this.panel3.SuspendLayout();
            this.cmsOverdueDate.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnseemore
            // 
            this.btnseemore.AutoSize = true;
            this.btnseemore.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnseemore.Location = new System.Drawing.Point(60, 0);
            this.btnseemore.Margin = new System.Windows.Forms.Padding(60, 0, 3, 0);
            this.btnseemore.Name = "btnseemore";
            this.btnseemore.Size = new System.Drawing.Size(92, 17);
            this.btnseemore.TabIndex = 2;
            this.btnseemore.Text = "查看更多群成员";
            this.btnseemore.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.btnseemore.Click += new System.EventHandler(this.btnSeeMore_Click);
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.White;
            this.panel1.Controls.Add(this.panel2);
            this.panel1.Controls.Add(this.palgroupCtl);
            this.panel1.Location = new System.Drawing.Point(2, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(232, 689);
            this.panel1.TabIndex = 1;
            // 
            // panel2
            // 
            this.panel2.AutoSize = true;
            this.panel2.Controls.Add(this.tabMember);
            this.panel2.Location = new System.Drawing.Point(3, 3);
            this.panel2.MaximumSize = new System.Drawing.Size(230, 137);
            this.panel2.MinimumSize = new System.Drawing.Size(230, 68);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(230, 72);
            this.panel2.TabIndex = 62;
            // 
            // tabMember
            // 
            this.tabMember.AutoSize = true;
            this.tabMember.Controls.Add(this.btnAdd);
            this.tabMember.Controls.Add(this.btnDel);
            this.tabMember.Location = new System.Drawing.Point(3, 0);
            this.tabMember.MaximumSize = new System.Drawing.Size(225, 137);
            this.tabMember.MinimumSize = new System.Drawing.Size(225, 68);
            this.tabMember.Name = "tabMember";
            this.tabMember.Size = new System.Drawing.Size(225, 69);
            this.tabMember.TabIndex = 60;
            // 
            // btnAdd
            // 
            this.btnAdd.CurrentRole = 0;
            this.btnAdd.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnAdd.Location = new System.Drawing.Point(10, 8);
            this.btnAdd.Margin = new System.Windows.Forms.Padding(10, 8, 3, 3);
            this.btnAdd.Name = "btnAdd";
            this.btnAdd.NickName = "";
            this.btnAdd.roomjid = null;
            this.btnAdd.Size = new System.Drawing.Size(42, 57);
            this.btnAdd.TabIndex = 1;
            this.btnAdd.Userid = null;
            this.btnAdd.Visible = false;
            // 
            // btnDel
            // 
            this.btnDel.CurrentRole = 0;
            this.btnDel.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnDel.Location = new System.Drawing.Point(65, 8);
            this.btnDel.Margin = new System.Windows.Forms.Padding(10, 8, 3, 3);
            this.btnDel.Name = "btnDel";
            this.btnDel.NickName = "";
            this.btnDel.roomjid = null;
            this.btnDel.Size = new System.Drawing.Size(42, 57);
            this.btnDel.TabIndex = 2;
            this.btnDel.Userid = null;
            this.btnDel.Visible = false;
            // 
            // palgroupCtl
            // 
            this.palgroupCtl.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.palgroupCtl.AutoSize = true;
            this.palgroupCtl.Controls.Add(this.btnseemore);
            this.palgroupCtl.Controls.Add(this.infoName);
            this.palgroupCtl.Controls.Add(this.infoNotice);
            this.palgroupCtl.Controls.Add(this.infoMenge);
            this.palgroupCtl.Controls.Add(this.infonickname);
            this.palgroupCtl.Controls.Add(this.infoGroupQRCode);
            //this.palgroupCtl.Controls.Add(this.infoFile);
            this.palgroupCtl.Controls.Add(this.infoDes);
            this.palgroupCtl.Controls.Add(this.panel3);
            this.palgroupCtl.Controls.Add(this.lblSpiltLine);
            this.palgroupCtl.Controls.Add(this.infoNoExe);
            this.palgroupCtl.Controls.Add(this.infoTop);
            this.palgroupCtl.Controls.Add(this.btnclear);
            this.palgroupCtl.Controls.Add(this.btnexite);
            this.palgroupCtl.Location = new System.Drawing.Point(5, 82);
            this.palgroupCtl.MaximumSize = new System.Drawing.Size(225, 550);
            this.palgroupCtl.MinimumSize = new System.Drawing.Size(225, 479);
            this.palgroupCtl.Name = "palgroupCtl";
            this.palgroupCtl.Size = new System.Drawing.Size(225, 550);
            this.palgroupCtl.TabIndex = 61;
            this.palgroupCtl.Visible = false;
            // 
            // infoName
            // 
            this.infoName.BackColor = System.Drawing.Color.White;
            this.infoName.btnImage = null;
            this.infoName.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.infoName.FunctionInfo = "";
            this.infoName.FunctionName = "群组名称";
            this.infoName.IsButtonShow = false;
            this.infoName.ISFunctionInfo = true;
            this.infoName.IsShowTxtBox = true;
            this.infoName.Location = new System.Drawing.Point(2, 20);
            this.infoName.Margin = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.infoName.Name = "infoName";
            this.infoName.Size = new System.Drawing.Size(206, 35);
            this.infoName.TabIndex = 46;
            this.infoName.Tag = "1";
            this.infoName.TagValue = 0;
            // 
            // infoNotice
            // 
            this.infoNotice.BackColor = System.Drawing.Color.White;
            this.infoNotice.btnImage = null;
            this.infoNotice.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.infoNotice.FunctionInfo = "";
            this.infoNotice.FunctionName = "群公告";
            this.infoNotice.IsButtonShow = false;
            this.infoNotice.ISFunctionInfo = true;
            this.infoNotice.IsShowTxtBox = false;
            this.infoNotice.Location = new System.Drawing.Point(3, 62);
            this.infoNotice.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.infoNotice.Name = "infoNotice";
            this.infoNotice.Size = new System.Drawing.Size(206, 35);
            this.infoNotice.TabIndex = 65;
            this.infoNotice.Tag = "2";
            this.infoNotice.TagValue = 0;
            this.infoNotice.MouseDown += new System.Windows.Forms.MouseEventHandler(this.infoNotice_MouseDown);
            // 
            // infoMenge
            // 
            this.infoMenge.BackColor = System.Drawing.Color.White;
            this.infoMenge.btnImage = null;
            this.infoMenge.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.infoMenge.FunctionInfo = "";
            this.infoMenge.FunctionName = "群管理";
            this.infoMenge.IsButtonShow = true;
            this.infoMenge.ISFunctionInfo = false;
            this.infoMenge.IsShowTxtBox = false;
            this.infoMenge.Location = new System.Drawing.Point(3, 105);
            this.infoMenge.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.infoMenge.Name = "infoMenge";
            this.infoMenge.Size = new System.Drawing.Size(206, 35);
            this.infoMenge.TabIndex = 66;
            this.infoMenge.TagValue = 0;
            this.infoMenge.MouseDown += new System.Windows.Forms.MouseEventHandler(this.infoMenge_MouseDown);
            // 
            // infonickname
            // 
            this.infonickname.BackColor = System.Drawing.Color.White;
            this.infonickname.btnImage = null;
            this.infonickname.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.infonickname.FunctionInfo = "";
            this.infonickname.FunctionName = "我在群里的昵称";
            this.infonickname.IsButtonShow = false;
            this.infonickname.ISFunctionInfo = true;
            this.infonickname.IsShowTxtBox = true;
            this.infonickname.Location = new System.Drawing.Point(3, 148);
            this.infonickname.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.infonickname.Name = "infonickname";
            this.infonickname.Size = new System.Drawing.Size(206, 35);
            this.infonickname.TabIndex = 3;
            this.infonickname.Tag = "3";
            this.infonickname.TagValue = 0;
            // 
            // infoGroupQRCode
            // 
            this.infoGroupQRCode.BackColor = System.Drawing.Color.White;
            this.infoGroupQRCode.btnImage = null;
            this.infoGroupQRCode.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.infoGroupQRCode.FunctionInfo = "";
            this.infoGroupQRCode.FunctionName = "群二维码";
            this.infoGroupQRCode.IsButtonShow = true;
            this.infoGroupQRCode.ISFunctionInfo = false;
            this.infoGroupQRCode.IsShowTxtBox = false;
            this.infoGroupQRCode.Location = new System.Drawing.Point(3, 190);
            this.infoGroupQRCode.Name = "infoGroupQRCode";
            this.infoGroupQRCode.Size = new System.Drawing.Size(206, 35);
            this.infoGroupQRCode.TabIndex = 68;
            this.infoGroupQRCode.Tag = "4";
            this.infoGroupQRCode.TagValue = 0;
            this.infoGroupQRCode.MouseDown += new System.Windows.Forms.MouseEventHandler(this.infoGroupQRCode_MouseDown);
            // 
            // infoFile
            // 
            this.infoFile.BackColor = System.Drawing.Color.White;
            this.infoFile.btnImage = global::WinFrmTalk.Properties.Resources.Rig;
            this.infoFile.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.infoFile.FunctionInfo = "";
            this.infoFile.FunctionName = "群文件";
            this.infoFile.IsButtonShow = true;
            this.infoFile.ISFunctionInfo = false;
            this.infoFile.IsShowTxtBox = false;
            this.infoFile.Location = new System.Drawing.Point(3, 232);
            this.infoFile.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.infoFile.Name = "infoFile";
            this.infoFile.Size = new System.Drawing.Size(206, 35);
            this.infoFile.TabIndex = 64;
            this.infoFile.TagValue = 2;
            this.infoFile.MouseDown += new System.Windows.Forms.MouseEventHandler(this.infoCard18_MouseDown);
            // 
            // infoDes
            // 
            this.infoDes.BackColor = System.Drawing.Color.White;
            this.infoDes.btnImage = null;
            this.infoDes.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.infoDes.FunctionInfo = "";
            this.infoDes.FunctionName = "群组描述";
            this.infoDes.IsButtonShow = false;
            this.infoDes.ISFunctionInfo = true;
            this.infoDes.IsShowTxtBox = true;
            this.infoDes.Location = new System.Drawing.Point(3, 275);
            this.infoDes.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.infoDes.Name = "infoDes";
            this.infoDes.Size = new System.Drawing.Size(206, 35);
            this.infoDes.TabIndex = 67;
            this.infoDes.Tag = "4";
            this.infoDes.TagValue = 0;
            // 
            // panel3
            // 
            this.panel3.Controls.Add(this.lblNews);
            this.panel3.Controls.Add(this.lblOverdueDate);
            this.panel3.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.panel3.Location = new System.Drawing.Point(3, 317);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(206, 35);
            this.panel3.TabIndex = 69;
            this.panel3.MouseLeave += new System.EventHandler(this.panel1_MouseLeave);
            this.panel3.MouseMove += new System.Windows.Forms.MouseEventHandler(this.panel3_MouseMove);
            // 
            // lblNews
            // 
            this.lblNews.AutoSize = true;
            this.lblNews.ForeColor = System.Drawing.Color.Black;
            this.lblNews.Location = new System.Drawing.Point(12, 11);
            this.lblNews.Name = "lblNews";
            this.lblNews.Size = new System.Drawing.Size(80, 17);
            this.lblNews.TabIndex = 57;
            this.lblNews.Text = "消息过期时间";
            // 
            // lblOverdueDate
            // 
            this.lblOverdueDate.ForeColor = System.Drawing.Color.Black;
            this.lblOverdueDate.Location = new System.Drawing.Point(108, 9);
            this.lblOverdueDate.Name = "lblOverdueDate";
            this.lblOverdueDate.Size = new System.Drawing.Size(86, 19);
            this.lblOverdueDate.TabIndex = 56;
            this.lblOverdueDate.Text = "永久";
            this.lblOverdueDate.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.lblOverdueDate.Click += new System.EventHandler(this.lblOverdueDate_Click);
            // 
            // lblSpiltLine
            // 
            this.lblSpiltLine.BackColor = System.Drawing.Color.LightGray;
            this.lblSpiltLine.Location = new System.Drawing.Point(3, 355);
            this.lblSpiltLine.Name = "lblSpiltLine";
            this.lblSpiltLine.Size = new System.Drawing.Size(205, 1);
            this.lblSpiltLine.TabIndex = 70;
            this.lblSpiltLine.Text = "label1";
            // 
            // infoNoExe
            // 
            this.infoNoExe.FunctionName = "消息免打扰";
            this.infoNoExe.Location = new System.Drawing.Point(3, 359);
            this.infoNoExe.Name = "infoNoExe";
            this.infoNoExe.Size = new System.Drawing.Size(206, 35);
            this.infoNoExe.TabIndex = 73;
            this.infoNoExe.Tag = "2";
            // 
            // infoTop
            // 
            this.infoTop.FunctionName = "置顶聊天";
            this.infoTop.Location = new System.Drawing.Point(3, 400);
            this.infoTop.Name = "infoTop";
            this.infoTop.Size = new System.Drawing.Size(206, 35);
            this.infoTop.TabIndex = 71;
            this.infoTop.Tag = "3";
            // 
            // btnclear
            // 
            this.btnclear.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.btnclear.FlatAppearance.BorderSize = 0;
            this.btnclear.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnclear.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnclear.ForeColor = System.Drawing.Color.White;
            this.btnclear.Location = new System.Drawing.Point(63, 446);
            this.btnclear.Margin = new System.Windows.Forms.Padding(63, 8, 3, 3);
            this.btnclear.Name = "btnclear";
            this.btnclear.Size = new System.Drawing.Size(110, 30);
            this.btnclear.TabIndex = 74;
            this.btnclear.Text = "清空聊天记录";
            this.btnclear.UseVisualStyleBackColor = false;
            this.btnclear.Click += new System.EventHandler(this.lblClearChat_Click);
            // 
            // btnexite
            // 
            this.btnexite.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.btnexite.FlatAppearance.BorderSize = 0;
            this.btnexite.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnexite.Font = new System.Drawing.Font("微软雅黑", 10.5F);
            this.btnexite.ForeColor = System.Drawing.Color.White;
            this.btnexite.Location = new System.Drawing.Point(63, 489);
            this.btnexite.Margin = new System.Windows.Forms.Padding(63, 10, 3, 3);
            this.btnexite.Name = "btnexite";
            this.btnexite.Size = new System.Drawing.Size(110, 30);
            this.btnexite.TabIndex = 75;
            this.btnexite.Text = "删除并并退出";
            this.btnexite.UseVisualStyleBackColor = false;
            this.btnexite.Click += new System.EventHandler(this.btnDelAndExite_Click);
            // 
            // cmsOverdueDate
            // 
            this.cmsOverdueDate.Arrow = System.Drawing.Color.Black;
            this.cmsOverdueDate.Back = System.Drawing.Color.White;
            this.cmsOverdueDate.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsOverdueDate.BackRadius = 4;
            this.cmsOverdueDate.Base = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsOverdueDate.DropDownImageSeparator = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
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
            this.cmsOverdueDate.TitleColor = System.Drawing.Color.White;
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
            // lblLeftLine
            // 
            this.lblLeftLine.BackColor = System.Drawing.SystemColors.ControlLight;
            this.lblLeftLine.Dock = System.Windows.Forms.DockStyle.Left;
            this.lblLeftLine.Location = new System.Drawing.Point(0, 0);
            this.lblLeftLine.Name = "lblLeftLine";
            this.lblLeftLine.Size = new System.Drawing.Size(1, 584);
            this.lblLeftLine.TabIndex = 3;
            this.lblLeftLine.Text = "label2";
            // 
            // showInfoVScroll
            // 
            this.showInfoVScroll.BackColor = System.Drawing.Color.Transparent;
            this.showInfoVScroll.canAdd = 0;
            this.showInfoVScroll.canTop = 0;
            this.showInfoVScroll.Dock = System.Windows.Forms.DockStyle.Right;
            this.showInfoVScroll.Location = new System.Drawing.Point(241, 0);
            this.showInfoVScroll.Name = "showInfoVScroll";
            this.showInfoVScroll.Size = new System.Drawing.Size(12, 584);
            this.showInfoVScroll.TabIndex = 2;
            // 
            // USEGroupSet
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.lblLeftLine);
            this.Controls.Add(this.showInfoVScroll);
            this.Controls.Add(this.panel1);
            this.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.Name = "USEGroupSet";
            this.Size = new System.Drawing.Size(253, 584);
            this.Load += new System.EventHandler(this.USEGroupSet_Load);
            this.Click += new System.EventHandler(this.txtRemarks_Leave);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            this.tabMember.ResumeLayout(false);
            this.palgroupCtl.ResumeLayout(false);
            this.palgroupCtl.PerformLayout();
            this.panel3.ResumeLayout(false);
            this.panel3.PerformLayout();
            this.cmsOverdueDate.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Label btnseemore;
        private CCWin.SkinControl.SkinContextMenuStrip cmsOverdueDate;
        private System.Windows.Forms.ToolStripMenuItem tsmForever;
        private System.Windows.Forms.ToolStripMenuItem tsmHour;
        private System.Windows.Forms.ToolStripMenuItem tsmDay;
        private System.Windows.Forms.ToolStripMenuItem tsmWeek;
        private System.Windows.Forms.ToolStripMenuItem tsmMonth;
        private System.Windows.Forms.ToolStripMenuItem tsmSeason;
        private System.Windows.Forms.ToolStripMenuItem tsmYear;
        private System.Windows.Forms.FlowLayoutPanel tabMember;
        private USEpicAddName btnAdd;
        private USEpicAddName btnDel;
        private USeCheckData infoNoExe;
        private USeCheckData infoTop;
        private System.Windows.Forms.FlowLayoutPanel palgroupCtl;
        public InfoCard infoName;
        private InfoCard infoMenge;
        private InfoCard infoGroupQRCode;
        private InfoCard infoFile;
        private InfoCard infoDes;
        private InfoCard infoNotice;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.Label lblNews;
        private System.Windows.Forms.Label lblOverdueDate;
        private System.Windows.Forms.Label lblSpiltLine;
        public MyVScrollBar showInfoVScroll;
        public System.Windows.Forms.Panel panel1;
        private InfoCard infonickname;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.Label lblLeftLine;
        private System.Windows.Forms.Button btnclear;
        private System.Windows.Forms.Button btnexite;
    }
}
