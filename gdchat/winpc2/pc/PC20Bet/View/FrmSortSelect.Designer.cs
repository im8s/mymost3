namespace WinFrmTalk.Controls.CustomControls
{
    partial class FrmSortSelect
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
            this.skinLine2 = new CCWin.SkinControl.SkinLine();
            this.rightList = new TestListView.XListView();
            this.btnClose = new System.Windows.Forms.Button();
            this.btnConfirm = new System.Windows.Forms.Button();
            this.txtSearch = new System.Windows.Forms.TextBox();
            this.lbltips = new System.Windows.Forms.Label();
            this.lblCount = new System.Windows.Forms.Label();
            this.tvwColleague = new WinFrmTalk.Controls.CustomControls.newtreenode();
            this.leftList = new TestListView.XListView();
            this.SuspendLayout();
            // 
            // skinLine2
            // 
            this.skinLine2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.skinLine2.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.skinLine2.LineColor = System.Drawing.Color.DimGray;
            this.skinLine2.LineHeight = 1;
            this.skinLine2.Location = new System.Drawing.Point(285, 0);
            this.skinLine2.Name = "skinLine2";
            this.skinLine2.Size = new System.Drawing.Size(1, 574);
            this.skinLine2.TabIndex = 21;
            this.skinLine2.Text = "skinLine2";
            // 
            // rightList
            // 
            this.rightList.BackColor = System.Drawing.Color.White;
            this.rightList.Location = new System.Drawing.Point(294, 67);
            this.rightList.Name = "rightList";
            this.rightList.ScrollBarWidth = 10;
            this.rightList.Size = new System.Drawing.Size(266, 454);
            this.rightList.TabIndex = 19;
            // 
            // btnClose
            // 
            this.btnClose.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(140)))), ((int)(((byte)(213)))), ((int)(((byte)(140)))));
            this.btnClose.FlatAppearance.BorderSize = 0;
            this.btnClose.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnClose.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnClose.ForeColor = System.Drawing.Color.White;
            this.btnClose.Location = new System.Drawing.Point(474, 527);
            this.btnClose.Name = "btnClose";
            this.btnClose.Size = new System.Drawing.Size(68, 25);
            this.btnClose.TabIndex = 17;
            this.btnClose.Text = "取消";
            this.btnClose.UseVisualStyleBackColor = false;
            this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
            // 
            // btnConfirm
            // 
            this.btnConfirm.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(140)))), ((int)(((byte)(213)))), ((int)(((byte)(140)))));
            this.btnConfirm.FlatAppearance.BorderSize = 0;
            this.btnConfirm.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnConfirm.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnConfirm.ForeColor = System.Drawing.Color.White;
            this.btnConfirm.Location = new System.Drawing.Point(387, 527);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.Size = new System.Drawing.Size(68, 25);
            this.btnConfirm.TabIndex = 16;
            this.btnConfirm.Text = "确定";
            this.btnConfirm.UseVisualStyleBackColor = false;
            this.btnConfirm.Click += new System.EventHandler(this.btnConfirm_Click);
            // 
            // txtSearch
            // 
            this.txtSearch.BackColor = System.Drawing.Color.WhiteSmoke;
            this.txtSearch.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.txtSearch.Font = new System.Drawing.Font("宋体", 9F);
            this.txtSearch.ImeMode = System.Windows.Forms.ImeMode.On;
            this.txtSearch.Location = new System.Drawing.Point(23, 40);
            this.txtSearch.Name = "txtSearch";
            this.txtSearch.Size = new System.Drawing.Size(230, 21);
            this.txtSearch.TabIndex = 20;
            this.txtSearch.TextChanged += new System.EventHandler(this.txtSearch_TextChanged);
            // 
            // lbltips
            // 
            this.lbltips.AutoSize = true;
            this.lbltips.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lbltips.ForeColor = System.Drawing.Color.Gray;
            this.lbltips.Location = new System.Drawing.Point(342, 44);
            this.lbltips.Name = "lbltips";
            this.lbltips.Size = new System.Drawing.Size(140, 17);
            this.lbltips.TabIndex = 15;
            this.lbltips.Text = "请勾选需要添加的联系人";
            // 
            // lblCount
            // 
            this.lblCount.AutoSize = true;
            this.lblCount.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblCount.ForeColor = System.Drawing.Color.Gray;
            this.lblCount.Location = new System.Drawing.Point(295, 44);
            this.lblCount.Name = "lblCount";
            this.lblCount.Size = new System.Drawing.Size(46, 17);
            this.lblCount.TabIndex = 14;
            this.lblCount.Text = "0/15人";
            // 
            // tvwColleague
            // 
            this.tvwColleague.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.tvwColleague.BackColor = System.Drawing.Color.WhiteSmoke;
            this.tvwColleague.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.tvwColleague.DrawMode = System.Windows.Forms.TreeViewDrawMode.OwnerDrawAll;
            this.tvwColleague.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Bold);
            this.tvwColleague.HotTracking = true;
            this.tvwColleague.Indent = 20;
            this.tvwColleague.ItemHeight = 30;
            this.tvwColleague.Location = new System.Drawing.Point(10, 67);
            this.tvwColleague.Name = "tvwColleague";
            this.tvwColleague.Size = new System.Drawing.Size(267, 480);
            this.tvwColleague.TabIndex = 29;
            this.tvwColleague.NodeMouseClick += new System.Windows.Forms.TreeNodeMouseClickEventHandler(this.tvwColleague_NodeMouseClick);
            // 
            // leftList
            // 
            this.leftList.BackColor = System.Drawing.Color.White;
            this.leftList.Location = new System.Drawing.Point(6, 67);
            this.leftList.Name = "leftList";
            this.leftList.ScrollBarWidth = 10;
            this.leftList.Size = new System.Drawing.Size(273, 480);
            this.leftList.TabIndex = 35;
            this.leftList.Visible = false;
            // 
            // FrmSortSelect
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(564, 573);
            this.Controls.Add(this.leftList);
            this.Controls.Add(this.tvwColleague);
            this.Controls.Add(this.skinLine2);
            this.Controls.Add(this.rightList);
            this.Controls.Add(this.btnClose);
            this.Controls.Add(this.btnConfirm);
            this.Controls.Add(this.txtSearch);
            this.Controls.Add(this.lbltips);
            this.Controls.Add(this.lblCount);
            this.Name = "FrmSortSelect";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "好友选择器";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private CCWin.SkinControl.SkinLine skinLine2;
        private TestListView.XListView rightList;
        private System.Windows.Forms.Button btnClose;
        private System.Windows.Forms.Button btnConfirm;
        private System.Windows.Forms.TextBox txtSearch;
        private System.Windows.Forms.Label lbltips;
        private System.Windows.Forms.Label lblCount;
        public newtreenode tvwColleague;
        private TestListView.XListView leftList;
    }
}