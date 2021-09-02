using TestListView;

namespace WinFrmTalk.Controls.CustomControls
{
    partial class UserCollection
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
            this.txtSearch = new System.Windows.Forms.TextBox();
            this.panel1 = new System.Windows.Forms.Panel();
            this.skinLine2 = new CCWin.SkinControl.SkinLine();
            this.btnWhole = new System.Windows.Forms.Button();
            this.btnLecture = new System.Windows.Forms.Button();
            this.btnVideo = new System.Windows.Forms.Button();
            this.btnImg = new System.Windows.Forms.Button();
            this.btnText = new System.Windows.Forms.Button();
            this.lblTitle = new System.Windows.Forms.Label();
            this.skinLine1 = new CCWin.SkinControl.SkinLine();
            this.cmsLecture = new CCWin.SkinControl.SkinContextMenuStrip();
            this.tsmEdit = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmSendLecture = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmDelete = new System.Windows.Forms.ToolStripMenuItem();
            this.cmsCollection = new CCWin.SkinControl.SkinContextMenuStrip();
            this.tsmForward = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmDel = new System.Windows.Forms.ToolStripMenuItem();
            this.myTabLayoutPanel1 = new TestListView.XListView();
            this.panel1.SuspendLayout();
            this.cmsLecture.SuspendLayout();
            this.cmsCollection.SuspendLayout();
            this.SuspendLayout();
            // 
            // txtSearch
            // 
            this.txtSearch.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(219)))), ((int)(((byte)(217)))), ((int)(((byte)(217)))));
            this.txtSearch.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.txtSearch.Location = new System.Drawing.Point(10, 17);
            this.txtSearch.Name = "txtSearch";
            this.txtSearch.Size = new System.Drawing.Size(230, 21);
            this.txtSearch.TabIndex = 4;
            this.txtSearch.WordWrap = false;
            this.txtSearch.TextChanged += new System.EventHandler(this.txtSearch_TextChanged);
            // 
            // panel1
            // 
            this.panel1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.panel1.BackColor = System.Drawing.Color.WhiteSmoke;
            //this.panel1.Controls.Add(this.skinLine2);
            this.panel1.Controls.Add(this.txtSearch);
            this.panel1.Controls.Add(this.btnWhole);
            //this.panel1.Controls.Add(this.btnLecture);
            this.panel1.Controls.Add(this.btnVideo);
            this.panel1.Controls.Add(this.btnImg);
            this.panel1.Controls.Add(this.btnText);
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(250, 568);
            this.panel1.TabIndex = 5;
            // 
            // skinLine2
            // 
            this.skinLine2.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.skinLine2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(231)))), ((int)(((byte)(231)))));
            this.skinLine2.LineColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.skinLine2.LineHeight = 1;
            this.skinLine2.Location = new System.Drawing.Point(0, 218);
            this.skinLine2.Name = "skinLine2";
            this.skinLine2.Size = new System.Drawing.Size(250, 1);
            this.skinLine2.TabIndex = 5;
            this.skinLine2.Text = "skinLine2";
            // 
            // btnWhole
            // 
            this.btnWhole.BackColor = System.Drawing.Color.WhiteSmoke;
            this.btnWhole.FlatAppearance.BorderSize = 0;
            this.btnWhole.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnWhole.Font = new System.Drawing.Font("微软雅黑", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnWhole.Image = global::WinFrmTalk.Properties.Resources.Whole;
            this.btnWhole.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnWhole.Location = new System.Drawing.Point(0, 57);
            this.btnWhole.Name = "btnWhole";
            this.btnWhole.Size = new System.Drawing.Size(245, 40);
            this.btnWhole.TabIndex = 0;
            this.btnWhole.Text = "          全部收藏";
            this.btnWhole.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnWhole.UseVisualStyleBackColor = false;
            this.btnWhole.Click += new System.EventHandler(this.btnWhole_Click);
            // 
            // btnLecture
            // 
            this.btnLecture.BackColor = System.Drawing.Color.WhiteSmoke;
            this.btnLecture.FlatAppearance.BorderSize = 0;
            this.btnLecture.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnLecture.Font = new System.Drawing.Font("微软雅黑", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnLecture.Image = global::WinFrmTalk.Properties.Resources.Lecture;
            this.btnLecture.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnLecture.Location = new System.Drawing.Point(0, 219);
            this.btnLecture.Name = "btnLecture";
            this.btnLecture.Size = new System.Drawing.Size(245, 40);
            this.btnLecture.TabIndex = 2;
            this.btnLecture.Text = "          我的课件";
            this.btnLecture.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnLecture.UseVisualStyleBackColor = false;
            this.btnLecture.Click += new System.EventHandler(this.btnLecture_Click);
            // 
            // btnVideo
            // 
            this.btnVideo.BackColor = System.Drawing.Color.WhiteSmoke;
            this.btnVideo.FlatAppearance.BorderSize = 0;
            this.btnVideo.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnVideo.Font = new System.Drawing.Font("微软雅黑", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnVideo.Image = global::WinFrmTalk.Properties.Resources.video;
            this.btnVideo.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnVideo.Location = new System.Drawing.Point(0, 177);
            this.btnVideo.Name = "btnVideo";
            this.btnVideo.Size = new System.Drawing.Size(245, 40);
            this.btnVideo.TabIndex = 2;
            this.btnVideo.Text = "          视频";
            this.btnVideo.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnVideo.UseVisualStyleBackColor = false;
            this.btnVideo.Click += new System.EventHandler(this.btnVideo_Click);
            // 
            // btnImg
            // 
            this.btnImg.BackColor = System.Drawing.Color.WhiteSmoke;
            this.btnImg.FlatAppearance.BorderSize = 0;
            this.btnImg.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnImg.Font = new System.Drawing.Font("微软雅黑", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnImg.Image = global::WinFrmTalk.Properties.Resources.Imag;
            this.btnImg.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnImg.Location = new System.Drawing.Point(0, 137);
            this.btnImg.Name = "btnImg";
            this.btnImg.Size = new System.Drawing.Size(245, 40);
            this.btnImg.TabIndex = 2;
            this.btnImg.Text = "          图片";
            this.btnImg.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnImg.UseVisualStyleBackColor = false;
            this.btnImg.Click += new System.EventHandler(this.btnImg_Click);
            // 
            // btnText
            // 
            this.btnText.BackColor = System.Drawing.Color.WhiteSmoke;
            this.btnText.FlatAppearance.BorderSize = 0;
            this.btnText.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnText.Font = new System.Drawing.Font("微软雅黑", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnText.Image = global::WinFrmTalk.Properties.Resources.Note;
            this.btnText.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnText.Location = new System.Drawing.Point(0, 97);
            this.btnText.Name = "btnText";
            this.btnText.Size = new System.Drawing.Size(245, 40);
            this.btnText.TabIndex = 1;
            this.btnText.Text = "          文本";
            this.btnText.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnText.UseVisualStyleBackColor = false;
            this.btnText.Click += new System.EventHandler(this.btnText_Click);
            // 
            // lblTitle
            // 
            this.lblTitle.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblTitle.Location = new System.Drawing.Point(276, 11);
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(92, 27);
            this.lblTitle.TabIndex = 6;
            this.lblTitle.Text = "全部收藏";
            this.lblTitle.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // skinLine1
            // 
            this.skinLine1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.skinLine1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(231)))), ((int)(((byte)(231)))));
            this.skinLine1.LineColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.skinLine1.LineHeight = 1;
            this.skinLine1.Location = new System.Drawing.Point(248, 54);
            this.skinLine1.Name = "skinLine1";
            this.skinLine1.Size = new System.Drawing.Size(526, 1);
            this.skinLine1.TabIndex = 2;
            this.skinLine1.Text = "skinLine1";
            // 
            // cmsLecture
            // 
            this.cmsLecture.Arrow = System.Drawing.Color.Black;
            this.cmsLecture.Back = System.Drawing.Color.White;
            this.cmsLecture.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsLecture.BackRadius = 4;
            this.cmsLecture.Base = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsLecture.DropDownImageSeparator = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.cmsLecture.Fore = System.Drawing.Color.Black;
            this.cmsLecture.HoverFore = System.Drawing.Color.Black;
            this.cmsLecture.ItemAnamorphosis = false;
            this.cmsLecture.ItemBorder = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsLecture.ItemBorderShow = false;
            this.cmsLecture.ItemHover = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsLecture.ItemPressed = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsLecture.ItemRadius = 4;
            this.cmsLecture.ItemRadiusStyle = CCWin.SkinClass.RoundStyle.None;
            this.cmsLecture.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.tsmEdit,
            this.tsmSendLecture,
            this.tsmDelete});
            this.cmsLecture.ItemSplitter = System.Drawing.Color.Silver;
            this.cmsLecture.Name = "cmsStaff";
            this.cmsLecture.RadiusStyle = CCWin.SkinClass.RoundStyle.None;
            this.cmsLecture.Size = new System.Drawing.Size(125, 70);
            this.cmsLecture.SkinAllColor = true;
            this.cmsLecture.TitleAnamorphosis = true;
            this.cmsLecture.TitleColor = System.Drawing.Color.White;
            this.cmsLecture.TitleRadius = 4;
            this.cmsLecture.TitleRadiusStyle = CCWin.SkinClass.RoundStyle.None;
            // 
            // tsmEdit
            // 
            this.tsmEdit.Name = "tsmEdit";
            this.tsmEdit.Size = new System.Drawing.Size(124, 22);
            this.tsmEdit.Text = "修改名称";
            this.tsmEdit.Click += new System.EventHandler(this.tsmEdit_Click);
            // 
            // tsmSendLecture
            // 
            this.tsmSendLecture.Name = "tsmSendLecture";
            this.tsmSendLecture.Size = new System.Drawing.Size(124, 22);
            this.tsmSendLecture.Text = "发送课件";
            this.tsmSendLecture.Click += new System.EventHandler(this.tsmSendLecture_Click);
            // 
            // tsmDelete
            // 
            this.tsmDelete.Name = "tsmDelete";
            this.tsmDelete.Size = new System.Drawing.Size(124, 22);
            this.tsmDelete.Text = "删除课件";
            this.tsmDelete.Click += new System.EventHandler(this.tsmDelete_Click);
            // 
            // cmsCollection
            // 
            this.cmsCollection.Arrow = System.Drawing.Color.Black;
            this.cmsCollection.Back = System.Drawing.Color.White;
            this.cmsCollection.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsCollection.BackRadius = 4;
            this.cmsCollection.Base = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsCollection.DropDownImageSeparator = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.cmsCollection.Fore = System.Drawing.Color.Black;
            this.cmsCollection.HoverFore = System.Drawing.Color.Black;
            this.cmsCollection.ItemAnamorphosis = false;
            this.cmsCollection.ItemBorder = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsCollection.ItemBorderShow = false;
            this.cmsCollection.ItemHover = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsCollection.ItemPressed = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(233)))), ((int)(((byte)(237)))));
            this.cmsCollection.ItemRadius = 4;
            this.cmsCollection.ItemRadiusStyle = CCWin.SkinClass.RoundStyle.None;
            this.cmsCollection.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.tsmForward,
            this.tsmDel});
            this.cmsCollection.ItemSplitter = System.Drawing.Color.Silver;
            this.cmsCollection.Name = "cmsStaff";
            this.cmsCollection.RadiusStyle = CCWin.SkinClass.RoundStyle.None;
            this.cmsCollection.Size = new System.Drawing.Size(101, 48);
            this.cmsCollection.SkinAllColor = true;
            this.cmsCollection.TitleAnamorphosis = true;
            this.cmsCollection.TitleColor = System.Drawing.Color.White;
            this.cmsCollection.TitleRadius = 4;
            this.cmsCollection.TitleRadiusStyle = CCWin.SkinClass.RoundStyle.None;
            // 
            // tsmForward
            // 
            this.tsmForward.Name = "tsmForward";
            this.tsmForward.Size = new System.Drawing.Size(100, 22);
            this.tsmForward.Text = "转发";
            this.tsmForward.Click += new System.EventHandler(this.tsmForward_Click);
            // 
            // tsmDel
            // 
            this.tsmDel.Name = "tsmDel";
            this.tsmDel.Size = new System.Drawing.Size(100, 22);
            this.tsmDel.Text = "删除";
            this.tsmDel.Click += new System.EventHandler(this.tsmDel_Click);
            // 
            // myTabLayoutPanel1
            // 
            this.myTabLayoutPanel1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.myTabLayoutPanel1.BackColor = System.Drawing.Color.WhiteSmoke;
            this.myTabLayoutPanel1.Location = new System.Drawing.Point(251, 60);
            this.myTabLayoutPanel1.Name = "myTabLayoutPanel1";
            this.myTabLayoutPanel1.ScrollBarWidth = 10;
            this.myTabLayoutPanel1.Size = new System.Drawing.Size(526, 505);
            this.myTabLayoutPanel1.TabIndex = 3;
            // 
            // UserCollection
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Controls.Add(this.skinLine1);
            this.Controls.Add(this.lblTitle);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.myTabLayoutPanel1);
            this.Name = "UserCollection";
            this.Size = new System.Drawing.Size(777, 571);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.cmsLecture.ResumeLayout(false);
            this.cmsCollection.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnWhole;
        private System.Windows.Forms.Button btnText;
        private System.Windows.Forms.Button btnImg;
        private XListView myTabLayoutPanel1;
        private System.Windows.Forms.TextBox txtSearch;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label lblTitle;
        private CCWin.SkinControl.SkinLine skinLine1;
        private CCWin.SkinControl.SkinLine skinLine2;
        private System.Windows.Forms.Button btnLecture;
        public CCWin.SkinControl.SkinContextMenuStrip cmsLecture;
        private System.Windows.Forms.ToolStripMenuItem tsmEdit;
        private System.Windows.Forms.ToolStripMenuItem tsmDelete;
        private CCWin.SkinControl.SkinContextMenuStrip cmsCollection;
        private System.Windows.Forms.ToolStripMenuItem tsmForward;
        private System.Windows.Forms.ToolStripMenuItem tsmDel;
        private System.Windows.Forms.ToolStripMenuItem tsmSendLecture;
        private System.Windows.Forms.Button btnVideo;
    }
}
