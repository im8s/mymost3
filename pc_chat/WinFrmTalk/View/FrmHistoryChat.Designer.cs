namespace WinFrmTalk.View
{
    partial class FrmHistoryChat
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmHistoryChat));
            this.searchTextBox = new WinFrmTalk.Controls.CustomControls.SearchTextBox();
            this.lblAll = new System.Windows.Forms.Label();
            this.lblFile = new System.Windows.Forms.Label();
            this.lblPicBox = new System.Windows.Forms.Label();
            this.lblLink = new System.Windows.Forms.Label();
            this.lblNickName = new System.Windows.Forms.Label();
            this.xListView1 = new TestListView.XListView();
            this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
            this.btninpuexcel = new System.Windows.Forms.Button();
            this.btninputtxt = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // searchTextBox
            // 
            this.searchTextBox.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.searchTextBox.BackColor = System.Drawing.Color.Gainsboro;
            this.searchTextBox.Context = "";
            this.searchTextBox.Location = new System.Drawing.Point(55, 64);
            this.searchTextBox.Name = "searchTextBox";
            this.searchTextBox.Size = new System.Drawing.Size(554, 21);
            this.searchTextBox.TabIndex = 5;
            this.searchTextBox.Load += new System.EventHandler(this.searchTextBox_Load);
            // 
            // lblAll
            // 
            this.lblAll.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
            this.lblAll.AutoSize = true;
            this.lblAll.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblAll.ForeColor = System.Drawing.Color.Black;
            this.lblAll.Location = new System.Drawing.Point(169, 107);
            this.lblAll.Name = "lblAll";
            this.lblAll.Size = new System.Drawing.Size(42, 21);
            this.lblAll.TabIndex = 0;
            this.lblAll.Text = "全部";
            this.lblAll.Click += new System.EventHandler(this.lblAll_Click);
            // 
            // lblFile
            // 
            this.lblFile.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
            this.lblFile.AutoSize = true;
            this.lblFile.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblFile.Location = new System.Drawing.Point(254, 107);
            this.lblFile.Name = "lblFile";
            this.lblFile.Size = new System.Drawing.Size(42, 21);
            this.lblFile.TabIndex = 9;
            this.lblFile.Text = "文件";
            this.lblFile.Click += new System.EventHandler(this.lblAll_Click);
            // 
            // lblPicBox
            // 
            this.lblPicBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
            this.lblPicBox.AutoSize = true;
            this.lblPicBox.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblPicBox.Location = new System.Drawing.Point(339, 107);
            this.lblPicBox.Name = "lblPicBox";
            this.lblPicBox.Size = new System.Drawing.Size(42, 21);
            this.lblPicBox.TabIndex = 10;
            this.lblPicBox.Text = "图片";
            this.lblPicBox.Click += new System.EventHandler(this.lblAll_Click);
            // 
            // lblLink
            // 
            this.lblLink.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
            this.lblLink.AutoSize = true;
            this.lblLink.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblLink.Location = new System.Drawing.Point(424, 107);
            this.lblLink.Name = "lblLink";
            this.lblLink.Size = new System.Drawing.Size(42, 21);
            this.lblLink.TabIndex = 11;
            this.lblLink.Text = "视频";
            this.lblLink.Click += new System.EventHandler(this.lblAll_Click);
            // 
            // lblNickName
            // 
            this.lblNickName.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblNickName.Location = new System.Drawing.Point(8, 8);
            this.lblNickName.Name = "lblNickName";
            this.lblNickName.Size = new System.Drawing.Size(547, 21);
            this.lblNickName.TabIndex = 14;
            this.lblNickName.Text = "label1";
            this.lblNickName.UseMnemonic = false;
            this.lblNickName.TextChanged += new System.EventHandler(this.lblNickName_TextChanged);
            // 
            // xListView1
            // 
            this.xListView1.BackColor = System.Drawing.Color.White;
            this.xListView1.Location = new System.Drawing.Point(55, 141);
            this.xListView1.Name = "xListView1";
            this.xListView1.ScrollBarWidth = 10;
            this.xListView1.Size = new System.Drawing.Size(584, 440);
            this.xListView1.TabIndex = 17;
            // 
            // flowLayoutPanel1
            // 
            this.flowLayoutPanel1.Location = new System.Drawing.Point(55, 144);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(583, 409);
            this.flowLayoutPanel1.TabIndex = 18;
            this.flowLayoutPanel1.Visible = false;
            // 
            // btninpuexcel
            // 
            this.btninpuexcel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(181)))), ((int)(((byte)(26)))));
            this.btninpuexcel.FlatAppearance.BorderSize = 0;
            this.btninpuexcel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btninpuexcel.ForeColor = System.Drawing.Color.White;
            this.btninpuexcel.Location = new System.Drawing.Point(317, 33);
            this.btninpuexcel.Name = "btninpuexcel";
            this.btninpuexcel.Size = new System.Drawing.Size(75, 23);
            this.btninpuexcel.TabIndex = 22;
            this.btninpuexcel.Text = "导出execl";
            this.btninpuexcel.UseVisualStyleBackColor = false;
            this.btninpuexcel.Click += new System.EventHandler(this.button1_Click);
            // 
            // btninputtxt
            // 
            this.btninputtxt.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(181)))), ((int)(((byte)(26)))));
            this.btninputtxt.FlatAppearance.BorderSize = 0;
            this.btninputtxt.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btninputtxt.ForeColor = System.Drawing.Color.White;
            this.btninputtxt.Location = new System.Drawing.Point(469, 33);
            this.btninputtxt.Name = "btninputtxt";
            this.btninputtxt.Size = new System.Drawing.Size(75, 23);
            this.btninputtxt.TabIndex = 25;
            this.btninputtxt.Text = "导出文本";
            this.btninputtxt.UseVisualStyleBackColor = false;
            this.btninputtxt.Click += new System.EventHandler(this.btninputtxt_Click);
            // 
            // FrmHistoryChat
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(640, 598);
            //this.Controls.Add(this.btninputtxt);
            //this.Controls.Add(this.btninpuexcel);
            this.Controls.Add(this.flowLayoutPanel1);
            this.Controls.Add(this.xListView1);
            this.Controls.Add(this.lblNickName);
            this.Controls.Add(this.lblLink);
            this.Controls.Add(this.lblPicBox);
            this.Controls.Add(this.lblFile);
            this.Controls.Add(this.lblAll);
            this.Controls.Add(this.searchTextBox);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.MinimumSize = new System.Drawing.Size(640, 598);
            this.Name = "FrmHistoryChat";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "";
            this.TitleNeed = false;
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmHistoryChat_FormClosed);
            this.Load += new System.EventHandler(this.FrmHistoryChat_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label lblAll;
        private System.Windows.Forms.Label lblFile;
        private System.Windows.Forms.Label lblPicBox;
        private System.Windows.Forms.Label lblLink;
        public Controls.CustomControls.SearchTextBox searchTextBox;
        private System.Windows.Forms.Label lblNickName;
        private TestListView.XListView xListView1;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
        private System.Windows.Forms.Button btninpuexcel;
        private System.Windows.Forms.Button btninputtxt;
    }
}