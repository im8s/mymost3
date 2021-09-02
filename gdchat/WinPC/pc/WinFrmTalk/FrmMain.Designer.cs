namespace WinFrmTalk
{
    partial class FrmMain
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
            this.leftlayout = new WinFrmTalk.LeftLayout();
            this.lblSessionSubTitle = new System.Windows.Forms.Label();
            this.NotifyControl = new System.Windows.Forms.NotifyIcon(this.components);
            this.cmsTrayMenu = new CCWin.SkinControl.SkinContextMenuStrip();
            this.tsbManin = new System.Windows.Forms.ToolStripMenuItem();
            this.tsbCloseFlicker = new System.Windows.Forms.ToolStripMenuItem();
            this.tsbClosevoice = new System.Windows.Forms.ToolStripMenuItem();
            this.tsbSet = new System.Windows.Forms.ToolStripMenuItem();
            this.tsbExit = new System.Windows.Forms.ToolStripMenuItem();
            this.ColleagueList = new WinFrmTalk.Controls.UserMyColleague();
            this.plList = new System.Windows.Forms.Panel();
            this.recentListLayout = new WinFrmTalk.RecentListLayout();
            this.groupListLayout = new WinFrmTalk.GroupListLayout();
            this.friendListLayout = new WinFrmTalk.FriendListLayout();
            this.mainPageLayout = new WinFrmTalk.Controls.LayouotControl.MainPageLayout();
            this.MyCollection = new WinFrmTalk.Controls.CustomControls.UserCollection();
            this.UserTagPage = new WinFrmTalk.Controls.CustomControls.UserLabel();
            this.cmsTrayMenu.SuspendLayout();
            this.plList.SuspendLayout();
            this.SuspendLayout();
            // 
            // leftlayout
            // 
            this.leftlayout.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.leftlayout.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(42)))), ((int)(((byte)(44)))));
            this.leftlayout.Location = new System.Drawing.Point(0, -1);
            this.leftlayout.MainForm = null;
            this.leftlayout.Margin = new System.Windows.Forms.Padding(0);
            this.leftlayout.Name = "leftlayout";
            this.leftlayout.SelectIndex = WinFrmTalk.MainTabIndex.RecentListPage;
            this.leftlayout.Size = new System.Drawing.Size(60, 661);
            this.leftlayout.TabIndex = 14;
            this.leftlayout.Load += new System.EventHandler(this.leftlayout_Load);
            // 
            // lblSessionSubTitle
            // 
            this.lblSessionSubTitle.AutoSize = true;
            this.lblSessionSubTitle.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblSessionSubTitle.Location = new System.Drawing.Point(325, 34);
            this.lblSessionSubTitle.Name = "lblSessionSubTitle";
            this.lblSessionSubTitle.Size = new System.Drawing.Size(32, 17);
            this.lblSessionSubTitle.TabIndex = 18;
            this.lblSessionSubTitle.Text = "在线";
            this.lblSessionSubTitle.Visible = false;
            // 
            // NotifyControl
            // 
            this.NotifyControl.BalloonTipIcon = System.Windows.Forms.ToolTipIcon.Info;
            this.NotifyControl.BalloonTipText = "IM";
            this.NotifyControl.BalloonTipTitle = "IM";
            this.NotifyControl.ContextMenuStrip = this.cmsTrayMenu;
            this.NotifyControl.Visible = true;
            // 
            // cmsTrayMenu
            // 
            this.cmsTrayMenu.Arrow = System.Drawing.Color.Black;
            this.cmsTrayMenu.Back = System.Drawing.Color.White;
            this.cmsTrayMenu.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsTrayMenu.BackRadius = 4;
            this.cmsTrayMenu.Base = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsTrayMenu.DropDownImageSeparator = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.cmsTrayMenu.Fore = System.Drawing.Color.Black;
            this.cmsTrayMenu.HoverFore = System.Drawing.Color.Black;
            this.cmsTrayMenu.ItemAnamorphosis = false;
            this.cmsTrayMenu.ItemBorder = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsTrayMenu.ItemBorderShow = false;
            this.cmsTrayMenu.ItemHover = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsTrayMenu.ItemPressed = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsTrayMenu.ItemRadius = 4;
            this.cmsTrayMenu.ItemRadiusStyle = CCWin.SkinClass.RoundStyle.None;
            this.cmsTrayMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.tsbManin,
            this.tsbCloseFlicker,
            this.tsbClosevoice,
            this.tsbSet,
            this.tsbExit});
            this.cmsTrayMenu.ItemSplitter = System.Drawing.Color.Silver;
            this.cmsTrayMenu.Name = "contextMenuStrip1";
            this.cmsTrayMenu.RadiusStyle = CCWin.SkinClass.RoundStyle.None;
            this.cmsTrayMenu.Size = new System.Drawing.Size(137, 114);
            this.cmsTrayMenu.SkinAllColor = true;
            this.cmsTrayMenu.Tag = "";
            this.cmsTrayMenu.TitleAnamorphosis = true;
            this.cmsTrayMenu.TitleColor = System.Drawing.Color.White;
            this.cmsTrayMenu.TitleRadius = 4;
            this.cmsTrayMenu.TitleRadiusStyle = CCWin.SkinClass.RoundStyle.None;
            // 
            // tsbManin
            // 
            this.tsbManin.Name = "tsbManin";
            this.tsbManin.Size = new System.Drawing.Size(136, 22);
            this.tsbManin.Text = "显示主界面";
            this.tsbManin.Click += new System.EventHandler(this.tsbManin_Click);
            // 
            // tsbCloseFlicker
            // 
            this.tsbCloseFlicker.Name = "tsbCloseFlicker";
            this.tsbCloseFlicker.Size = new System.Drawing.Size(136, 22);
            this.tsbCloseFlicker.Text = "关闭闪动";
            this.tsbCloseFlicker.Click += new System.EventHandler(this.tsbCloseFlicker_Click);
            // 
            // tsbClosevoice
            // 
            this.tsbClosevoice.Name = "tsbClosevoice";
            this.tsbClosevoice.Size = new System.Drawing.Size(136, 22);
            this.tsbClosevoice.Text = "关闭声音";
            this.tsbClosevoice.Click += new System.EventHandler(this.tsbClosevoice_Click);
            // 
            // tsbSet
            // 
            this.tsbSet.Name = "tsbSet";
            this.tsbSet.Size = new System.Drawing.Size(136, 22);
            this.tsbSet.Text = "设置";
            this.tsbSet.Click += new System.EventHandler(this.tsbSet_Click);
            // 
            // tsbExit
            // 
            this.tsbExit.Name = "tsbExit";
            this.tsbExit.Size = new System.Drawing.Size(136, 22);
            this.tsbExit.Text = "退出";
            this.tsbExit.Click += new System.EventHandler(this.tsbExit_Click);
            // 
            // ColleagueList
            // 
            this.ColleagueList.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.ColleagueList.BackColor = System.Drawing.Color.Transparent;
            this.ColleagueList.Location = new System.Drawing.Point(61, 30);
            this.ColleagueList.Margin = new System.Windows.Forms.Padding(0);
            this.ColleagueList.Name = "ColleagueList";
            this.ColleagueList.SendAction = null;
            this.ColleagueList.Size = new System.Drawing.Size(797, 630);
            this.ColleagueList.TabIndex = 54;
            this.ColleagueList.Visible = false;
            // 
            // plList
            // 
            this.plList.Controls.Add(this.recentListLayout);
            this.plList.Controls.Add(this.groupListLayout);
            this.plList.Controls.Add(this.friendListLayout);
            this.plList.Location = new System.Drawing.Point(61, -1);
            this.plList.Margin = new System.Windows.Forms.Padding(0);
            this.plList.Name = "plList";
            this.plList.Size = new System.Drawing.Size(261, 639);
            this.plList.TabIndex = 55;
            // 
            // recentListLayout
            // 
            this.recentListLayout.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.recentListLayout.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(231)))), ((int)(((byte)(231)))));
            this.recentListLayout.Location = new System.Drawing.Point(0, 0);
            this.recentListLayout.MainForm = null;
            this.recentListLayout.Margin = new System.Windows.Forms.Padding(0);
            this.recentListLayout.Name = "recentListLayout";
            this.recentListLayout.Size = new System.Drawing.Size(261, 639);
            this.recentListLayout.TabIndex = 17;
            // 
            // groupListLayout
            // 
            this.groupListLayout.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(231)))), ((int)(((byte)(231)))));
            this.groupListLayout.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupListLayout.Location = new System.Drawing.Point(0, 0);
            this.groupListLayout.MainForm = null;
            this.groupListLayout.Margin = new System.Windows.Forms.Padding(0);
            this.groupListLayout.Name = "groupListLayout";
            this.groupListLayout.Size = new System.Drawing.Size(261, 639);
            this.groupListLayout.TabIndex = 16;
            // 
            // friendListLayout
            // 
            this.friendListLayout.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.friendListLayout.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(231)))), ((int)(((byte)(231)))));
            this.friendListLayout.Location = new System.Drawing.Point(0, 0);
            this.friendListLayout.MainForm = null;
            this.friendListLayout.Margin = new System.Windows.Forms.Padding(0);
            this.friendListLayout.Name = "friendListLayout";
            this.friendListLayout.SelectedItem = null;
            this.friendListLayout.Size = new System.Drawing.Size(261, 639);
            this.friendListLayout.TabIndex = 15;
            // 
            // mainPageLayout
            // 
            this.mainPageLayout.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.mainPageLayout.AutoSize = true;
            this.mainPageLayout.Location = new System.Drawing.Point(323, 24);
            this.mainPageLayout.MainForm = null;
            this.mainPageLayout.Margin = new System.Windows.Forms.Padding(0);
            this.mainPageLayout.Name = "mainPageLayout";
            this.mainPageLayout.SelectedIndex = WinFrmTalk.MainTabIndex.RecentListPage_null;
            this.mainPageLayout.Size = new System.Drawing.Size(533, 636);
            this.mainPageLayout.TabIndex = 56;
            // 
            // MyCollection
            // 
            this.MyCollection.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.MyCollection.BackColor = System.Drawing.Color.WhiteSmoke;
            this.MyCollection.Location = new System.Drawing.Point(61, 24);
            this.MyCollection.Margin = new System.Windows.Forms.Padding(0);
            this.MyCollection.Name = "MyCollection";
            this.MyCollection.Size = new System.Drawing.Size(799, 636);
            this.MyCollection.TabIndex = 69;
            this.MyCollection.Visible = false;
            // 
            // UserTagPage
            // 
            this.UserTagPage.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.UserTagPage.BackColor = System.Drawing.Color.WhiteSmoke;
            this.UserTagPage.Location = new System.Drawing.Point(61, 24);
            this.UserTagPage.Name = "UserTagPage";
            this.UserTagPage.SendAction = null;
            this.UserTagPage.Size = new System.Drawing.Size(799, 636);
            this.UserTagPage.TabIndex = 95;
            this.UserTagPage.Visible = false;
            // 
            // FrmMain
            // 
            this.AllowDrop = true;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.BorderRectangle = new System.Drawing.Rectangle(0, 0, 0, 0);
            this.CaptionHeight = 36;
            this.ClientSize = new System.Drawing.Size(860, 660);
            this.CloseBoxSize = new System.Drawing.Size(34, 24);
            this.ControlBoxOffset = new System.Drawing.Point(0, 0);
            this.Controls.Add(this.UserTagPage);
            this.Controls.Add(this.MyCollection);
            this.Controls.Add(this.ColleagueList);
            this.Controls.Add(this.mainPageLayout);
            this.Controls.Add(this.plList);
            this.Controls.Add(this.leftlayout);
            this.Controls.Add(this.lblSessionSubTitle);
            this.ImeMode = System.Windows.Forms.ImeMode.On;
            this.isClose = false;
            this.KeyPreview = true;
            this.MaxSize = new System.Drawing.Size(34, 24);
            this.MinimumSize = new System.Drawing.Size(710, 500);
            this.MiniSize = new System.Drawing.Size(34, 24);
            this.Name = "FrmMain";
            this.Radius = 3;
            this.ShadowColor = System.Drawing.Color.Gray;
            this.ShadowWidth = 6;
            this.ShowBorder = false;
            this.ShowDrawIcon = false;
            this.ShowIcon = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "咕喃";
            this.TitleNeed = false;
            this.Activated += new System.EventHandler(this.FrmMain_Activated);
            this.Deactivate += new System.EventHandler(this.FrmMain_Deactivate);
            this.Load += new System.EventHandler(this.FrmMain_Load);
            this.ResizeEnd += new System.EventHandler(this.FrmMain_ResizeEnd);
            this.SizeChanged += new System.EventHandler(this.FrmMain_SizeChanged);
            this.DoubleClick += new System.EventHandler(this.FrmMain_DoubleClick);
            this.KeyDown += new System.Windows.Forms.KeyEventHandler(this.FrmMain_KeyDown);
            this.Leave += new System.EventHandler(this.FrmMain_Leave);
            this.cmsTrayMenu.ResumeLayout(false);
            this.plList.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private LeftLayout leftlayout;
        private System.Windows.Forms.Label lblSessionSubTitle;
        private System.Windows.Forms.NotifyIcon NotifyControl;
        public Controls.UserMyColleague ColleagueList;
        private System.Windows.Forms.Panel plList;
        private RecentListLayout recentListLayout;
        private GroupListLayout groupListLayout;
        private FriendListLayout friendListLayout;
        public Controls.LayouotControl.MainPageLayout mainPageLayout;
        public Controls.CustomControls.UserCollection MyCollection;
        public Controls.CustomControls.UserLabel UserTagPage;
        private CCWin.SkinControl.SkinContextMenuStrip cmsTrayMenu;
        private System.Windows.Forms.ToolStripMenuItem tsbManin;
        private System.Windows.Forms.ToolStripMenuItem tsbCloseFlicker;
        private System.Windows.Forms.ToolStripMenuItem tsbClosevoice;
        private System.Windows.Forms.ToolStripMenuItem tsbSet;
        private System.Windows.Forms.ToolStripMenuItem tsbExit;
    }
}