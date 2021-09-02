namespace WinFrmTalk
{
    partial class LeftLayout
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
            this.btnCollect = new System.Windows.Forms.PictureBox();
            this.btnColleague = new System.Windows.Forms.PictureBox();
            this.btnGroup = new System.Windows.Forms.PictureBox();
            this.btnTags = new System.Windows.Forms.PictureBox();
            this.btnContacts = new System.Windows.Forms.PictureBox();
            this.btnRecent = new System.Windows.Forms.PictureBox();
            this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
            this.pic_myIcon = new WinFrmTalk.RoundPicBox();
            this.btnSettings = new LollipopFlatButton();
            ((System.ComponentModel.ISupportInitialize)(this.btnCollect)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnColleague)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnGroup)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnTags)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnContacts)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnRecent)).BeginInit();
            this.flowLayoutPanel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pic_myIcon)).BeginInit();
            this.SuspendLayout();
            // 
            // btnCollect
            // 
            this.btnCollect.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCollect.BackgroundImage = global::WinFrmTalk.Properties.Resources.ic_collect;
            this.btnCollect.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnCollect.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnCollect.Location = new System.Drawing.Point(0, 328);
            this.btnCollect.Margin = new System.Windows.Forms.Padding(0);
            this.btnCollect.Name = "btnCollect";
            this.btnCollect.Size = new System.Drawing.Size(90, 82);
            this.btnCollect.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
            this.btnCollect.TabIndex = 13;
            this.btnCollect.TabStop = false;
            this.btnCollect.Click += new System.EventHandler(this.BtnCollect_Click);
            // 
            // btnColleague
            // 
            this.btnColleague.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnColleague.BackgroundImage = global::WinFrmTalk.Properties.Resources.ic_colleage;
            this.btnColleague.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnColleague.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnColleague.Location = new System.Drawing.Point(0, 246);
            this.btnColleague.Margin = new System.Windows.Forms.Padding(0);
            this.btnColleague.Name = "btnColleague";
            this.btnColleague.Size = new System.Drawing.Size(90, 82);
            this.btnColleague.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
            this.btnColleague.TabIndex = 12;
            this.btnColleague.TabStop = false;
            this.btnColleague.Click += new System.EventHandler(this.BtnCon_Click);
            // 
            // btnGroup
            // 
            this.btnGroup.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnGroup.BackgroundImage = global::WinFrmTalk.Properties.Resources.ic_group;
            this.btnGroup.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnGroup.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnGroup.Location = new System.Drawing.Point(0, 164);
            this.btnGroup.Margin = new System.Windows.Forms.Padding(0);
            this.btnGroup.Name = "btnGroup";
            this.btnGroup.Size = new System.Drawing.Size(90, 82);
            this.btnGroup.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
            this.btnGroup.TabIndex = 11;
            this.btnGroup.TabStop = false;
            this.btnGroup.Click += new System.EventHandler(this.btnGroup_Click);
            // 
            // btnTags
            // 
            this.btnTags.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnTags.BackgroundImage = global::WinFrmTalk.Properties.Resources.ic_Tags;
            this.btnTags.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnTags.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnTags.Location = new System.Drawing.Point(0, 410);
            this.btnTags.Margin = new System.Windows.Forms.Padding(0);
            this.btnTags.Name = "btnTags";
            this.btnTags.Size = new System.Drawing.Size(90, 82);
            this.btnTags.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
            this.btnTags.TabIndex = 11;
            this.btnTags.TabStop = false;
            this.btnTags.Click += new System.EventHandler(this.BtnTags_Click);
            // 
            // btnContacts
            // 
            this.btnContacts.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnContacts.BackgroundImage = global::WinFrmTalk.Properties.Resources.ic_contact;
            this.btnContacts.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnContacts.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnContacts.Location = new System.Drawing.Point(0, 82);
            this.btnContacts.Margin = new System.Windows.Forms.Padding(0);
            this.btnContacts.Name = "btnContacts";
            this.btnContacts.Size = new System.Drawing.Size(90, 82);
            this.btnContacts.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
            this.btnContacts.TabIndex = 11;
            this.btnContacts.TabStop = false;
            this.btnContacts.Click += new System.EventHandler(this.btnContacts_Click);
            // 
            // btnRecent
            // 
            this.btnRecent.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnRecent.BackgroundImage = global::WinFrmTalk.Properties.Resources.ic_recent;
            this.btnRecent.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnRecent.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnRecent.Location = new System.Drawing.Point(0, 0);
            this.btnRecent.Margin = new System.Windows.Forms.Padding(0);
            this.btnRecent.Name = "btnRecent";
            this.btnRecent.Size = new System.Drawing.Size(90, 82);
            this.btnRecent.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
            this.btnRecent.TabIndex = 11;
            this.btnRecent.TabStop = false;
            this.btnRecent.Click += new System.EventHandler(this.btnRecent_Click);
            this.btnRecent.DoubleClick += new System.EventHandler(this.OnDoubleClickRecent);
            // 
            // flowLayoutPanel1
            // 
            this.flowLayoutPanel1.Controls.Add(this.btnRecent);
            this.flowLayoutPanel1.Controls.Add(this.btnContacts);
            this.flowLayoutPanel1.Controls.Add(this.btnGroup);
            this.flowLayoutPanel1.Controls.Add(this.btnColleague);
            this.flowLayoutPanel1.Controls.Add(this.btnCollect);
            this.flowLayoutPanel1.Controls.Add(this.btnTags);
            this.flowLayoutPanel1.Location = new System.Drawing.Point(0, 112);
            this.flowLayoutPanel1.Margin = new System.Windows.Forms.Padding(0);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(88, 507);
            this.flowLayoutPanel1.TabIndex = 14;
            // 
            // pic_myIcon
            // 
            this.pic_myIcon.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.pic_myIcon.isDrawRound = true;
            this.pic_myIcon.Location = new System.Drawing.Point(14, 20);
            this.pic_myIcon.Margin = new System.Windows.Forms.Padding(0);
            this.pic_myIcon.Name = "pic_myIcon";
            this.pic_myIcon.Size = new System.Drawing.Size(63, 63);
            this.pic_myIcon.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pic_myIcon.TabIndex = 10;
            this.pic_myIcon.TabStop = false;
            this.pic_myIcon.Click += new System.EventHandler(this.pic_myIcon_Click);
            this.pic_myIcon.Paint += new System.Windows.Forms.PaintEventHandler(this.pic_myIcon_Paint);
            // 
            // btnSettings
            // 
            this.btnSettings.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnSettings.BackColor = System.Drawing.Color.Transparent;
            this.btnSettings.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnSettings.FontColor = "#508ef5";
            this.btnSettings.Location = new System.Drawing.Point(0, 693);
            this.btnSettings.Margin = new System.Windows.Forms.Padding(4);
            this.btnSettings.Name = "btnSettings";
            this.btnSettings.Size = new System.Drawing.Size(90, 93);
            this.btnSettings.TabIndex = 9;
            this.btnSettings.Text = "";
            this.btnSettings.Click += new System.EventHandler(this.Settings_Click);
            // 
            // LeftLayout
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 18F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(42)))), ((int)(((byte)(44)))));
            this.Controls.Add(this.flowLayoutPanel1);
            this.Controls.Add(this.pic_myIcon);
            this.Controls.Add(this.btnSettings);
            this.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Name = "LeftLayout";
            this.Size = new System.Drawing.Size(90, 786);
            this.Load += new System.EventHandler(this.LeftLayout_Load);
            ((System.ComponentModel.ISupportInitialize)(this.btnCollect)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnColleague)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnGroup)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnTags)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnContacts)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnRecent)).EndInit();
            this.flowLayoutPanel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.pic_myIcon)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private LollipopFlatButton btnSettings;
        private RoundPicBox pic_myIcon;
        private System.Windows.Forms.PictureBox btnRecent;
        private System.Windows.Forms.PictureBox btnContacts;
        private System.Windows.Forms.PictureBox btnGroup;
        private System.Windows.Forms.PictureBox btnColleague;
        private System.Windows.Forms.PictureBox btnCollect;
        private System.Windows.Forms.PictureBox btnTags;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
    }
}
