namespace WinFrmTalk
{
    partial class FriendListLayout
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
            this.txtSearch = new System.Windows.Forms.TextBox();
            this.btnPlus = new System.Windows.Forms.Button();
            //this.tlpFriends = new WinFrmTalk.MyTabLayoutPanel();
            this.searchTime = new System.Windows.Forms.Timer(this.components);
            this.xListView = new TestListView.XListView();
            this.SuspendLayout();
            // 
            // txtSearch
            // 
            this.txtSearch.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtSearch.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(219)))), ((int)(((byte)(217)))), ((int)(((byte)(217)))));
            this.txtSearch.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.txtSearch.Font = new System.Drawing.Font("黑体", 14F);
            this.txtSearch.ForeColor = System.Drawing.Color.Silver;
            this.txtSearch.Location = new System.Drawing.Point(13, 15);
            this.txtSearch.Name = "txtSearch";
            this.txtSearch.Size = new System.Drawing.Size(173, 22);
            this.txtSearch.TabIndex = 16;
            this.txtSearch.WordWrap = false;
            this.txtSearch.TextChanged += new System.EventHandler(this.SearchTextChanged);
            // 
            // btnPlus
            // 
            this.btnPlus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnPlus.BackgroundImage = global::WinFrmTalk.Properties.Resources.ic_friend_add_normal;
            this.btnPlus.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnPlus.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(231)))), ((int)(((byte)(231)))));
            this.btnPlus.FlatAppearance.BorderSize = 0;
            this.btnPlus.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(231)))), ((int)(((byte)(231)))));
            this.btnPlus.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(231)))), ((int)(((byte)(231)))));
            this.btnPlus.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnPlus.Location = new System.Drawing.Point(195, 13);
            this.btnPlus.Name = "btnPlus";
            this.btnPlus.Size = new System.Drawing.Size(25, 25);
            this.btnPlus.TabIndex = 23;
            this.btnPlus.UseVisualStyleBackColor = true;
            this.btnPlus.Click += new System.EventHandler(this.btnPlus_Click);
            // 
            // tlpFriends
            // 
            //this.tlpFriends.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            //| System.Windows.Forms.AnchorStyles.Left) 
            //| System.Windows.Forms.AnchorStyles.Right)));
            //this.tlpFriends.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(230)))), ((int)(((byte)(229)))), ((int)(((byte)(229)))));
            //this.tlpFriends.Location = new System.Drawing.Point(0, 48);
            //this.tlpFriends.Margin = new System.Windows.Forms.Padding(0);
            //this.tlpFriends.Name = "tlpFriends";
            //this.tlpFriends.Size = new System.Drawing.Size(235, 389);
            //this.tlpFriends.TabIndex = 14;
            //this.tlpFriends.v_scale = 30;
            //this.tlpFriends.Visible = false;
            // 
            // searchTime
            // 
            this.searchTime.Interval = 300;
            this.searchTime.Tick += new System.EventHandler(this.searchTime_Tick);
            // 
            // xListView
            // 
            this.xListView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            //this.xListView.BackColor = System.Drawing.SystemColors.Window;
            this.xListView.BackColor = System.Drawing.Color.FromArgb(230,229,229);
            this.xListView.Location = new System.Drawing.Point(0, 48);
            this.xListView.Name = "xListView";
            this.xListView.Size = new System.Drawing.Size(235, 389);
            this.xListView.TabIndex = 24;
            // 
            // FriendListLayout
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(231)))), ((int)(((byte)(231)))));
            this.Controls.Add(this.xListView);
            this.Controls.Add(this.btnPlus);
            this.Controls.Add(this.txtSearch);
            //this.Controls.Add(this.tlpFriends);
            this.Margin = new System.Windows.Forms.Padding(0);
            this.Name = "FriendListLayout";
            this.Size = new System.Drawing.Size(235, 437);
            this.Load += new System.EventHandler(this.MainListLayout_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

       //private MyTabLayoutPanel tlpFriends;
        private System.Windows.Forms.TextBox txtSearch;
        private System.Windows.Forms.Button btnPlus;
        private System.Windows.Forms.Timer searchTime;
        private TestListView.XListView xListView;
    }
}
