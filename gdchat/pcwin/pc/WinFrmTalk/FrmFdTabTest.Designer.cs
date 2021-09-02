namespace WinFrmTalk
{
    partial class FrmFdTabTest
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmFdTabTest));
            this.skinTabControl1 = new CCWin.SkinControl.SkinTabControl();
            this.skinTabPage1 = new CCWin.SkinControl.SkinTabPage();
            this.myTabLayoutPanel1 = new WinFrmTalk.MyTabLayoutPanel();
            this.newsItem1 = new WinFrmTalk.Controls.CustomControls.NewsItem();
            this.userItem1 = new WinFrmTalk.Controls.CustomControls.UserItem();
            this.friendItem1 = new WinFrmTalk.Controls.FriendItem();
            this.skinTabControl1.SuspendLayout();
            this.skinTabPage1.SuspendLayout();
            this.SuspendLayout();
            // 
            // skinTabControl1
            // 
            this.skinTabControl1.Alignment = System.Windows.Forms.TabAlignment.Left;
            this.skinTabControl1.AnimatorType = CCWin.SkinControl.AnimationType.HorizSlide;
            this.skinTabControl1.CloseRect = new System.Drawing.Rectangle(2, 2, 12, 12);
            this.skinTabControl1.Controls.Add(this.skinTabPage1);
            this.skinTabControl1.HeadBack = null;
            this.skinTabControl1.ImgTxtOffset = new System.Drawing.Point(0, 0);
            this.skinTabControl1.ItemSize = new System.Drawing.Size(70, 36);
            this.skinTabControl1.Location = new System.Drawing.Point(12, 12);
            this.skinTabControl1.Multiline = true;
            this.skinTabControl1.Name = "skinTabControl1";
            this.skinTabControl1.PageArrowDown = ((System.Drawing.Image)(resources.GetObject("skinTabControl1.PageArrowDown")));
            this.skinTabControl1.PageArrowHover = ((System.Drawing.Image)(resources.GetObject("skinTabControl1.PageArrowHover")));
            this.skinTabControl1.PageCloseHover = ((System.Drawing.Image)(resources.GetObject("skinTabControl1.PageCloseHover")));
            this.skinTabControl1.PageCloseNormal = ((System.Drawing.Image)(resources.GetObject("skinTabControl1.PageCloseNormal")));
            this.skinTabControl1.PageDown = ((System.Drawing.Image)(resources.GetObject("skinTabControl1.PageDown")));
            this.skinTabControl1.PageHover = ((System.Drawing.Image)(resources.GetObject("skinTabControl1.PageHover")));
            this.skinTabControl1.PageImagePosition = CCWin.SkinControl.SkinTabControl.ePageImagePosition.Left;
            this.skinTabControl1.PageNorml = null;
            this.skinTabControl1.SelectedIndex = 0;
            this.skinTabControl1.Size = new System.Drawing.Size(496, 370);
            this.skinTabControl1.SizeMode = System.Windows.Forms.TabSizeMode.Fixed;
            this.skinTabControl1.TabIndex = 1;
            // 
            // skinTabPage1
            // 
            this.skinTabPage1.BackColor = System.Drawing.Color.White;
            this.skinTabPage1.Controls.Add(this.myTabLayoutPanel1);
            this.skinTabPage1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.skinTabPage1.Location = new System.Drawing.Point(36, 0);
            this.skinTabPage1.Name = "skinTabPage1";
            this.skinTabPage1.Size = new System.Drawing.Size(460, 370);
            this.skinTabPage1.TabIndex = 0;
            this.skinTabPage1.TabItemImage = null;
            this.skinTabPage1.Text = "Page1";
            // 
            // myTabLayoutPanel1
            // 
            this.myTabLayoutPanel1.Location = new System.Drawing.Point(3, 0);
            this.myTabLayoutPanel1.Name = "myTabLayoutPanel1";
            this.myTabLayoutPanel1.Size = new System.Drawing.Size(261, 370);
            this.myTabLayoutPanel1.TabIndex = 1;
            // 
            // newsItem1
            // 
            this.newsItem1.content = "content";
            this.newsItem1.Location = new System.Drawing.Point(533, 118);
            this.newsItem1.Name = "newsItem1";
            this.newsItem1.nickName = "Name";
            this.newsItem1.picHead = ((System.Drawing.Image)(resources.GetObject("newsItem1.picHead")));
            this.newsItem1.Size = new System.Drawing.Size(250, 60);
            this.newsItem1.TabIndex = 2;
            this.newsItem1.time = "13:14";
            // 
            // userItem1
            // 
            this.userItem1.BackColor = System.Drawing.Color.White;
            this.userItem1.checkState = false;
            this.userItem1.Location = new System.Drawing.Point(553, 52);
            this.userItem1.Name = "userItem1";
            this.userItem1.nickName = "张三";
            this.userItem1.Size = new System.Drawing.Size(270, 60);
            this.userItem1.TabIndex = 3;
            // 
            // friendItem1
            // 
            this.friendItem1.BackColor = System.Drawing.Color.Transparent;
            this.friendItem1.Location = new System.Drawing.Point(553, 210);
            this.friendItem1.Name = "friendItem1";
            this.friendItem1.Size = new System.Drawing.Size(240, 50);
            this.friendItem1.TabIndex = 4;
            // 
            // FrmFdTabTest
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(909, 394);
            this.Controls.Add(this.friendItem1);
            this.Controls.Add(this.userItem1);
            this.Controls.Add(this.newsItem1);
            this.Controls.Add(this.skinTabControl1);
            this.DoubleBuffered = true;
            this.Name = "FrmFdTabTest";
            this.Text = "FrmFdTabTest";
            this.Load += new System.EventHandler(this.FrmFdTabTest_Load);
            this.skinTabControl1.ResumeLayout(false);
            this.skinTabPage1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private CCWin.SkinControl.SkinTabControl skinTabControl1;
        private CCWin.SkinControl.SkinTabPage skinTabPage1;
        private WinFrmTalk.MyTabLayoutPanel myTabLayoutPanel1;
        private Controls.CustomControls.NewsItem newsItem1;
        private Controls.CustomControls.UserItem userItem1;
        private Controls.FriendItem friendItem1;
    }
}