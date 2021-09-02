namespace WinFrmTalk
{
    partial class USEFriendShow
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
            this.lblNickname = new System.Windows.Forms.Label();
            this.chkSelect = new System.Windows.Forms.CheckBox();
            this.picHead = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.picHead)).BeginInit();
            this.SuspendLayout();
            // 
            // lblNickname
            // 
            this.lblNickname.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.lblNickname.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblNickname.Location = new System.Drawing.Point(70, 24);
            this.lblNickname.Name = "lblNickname";
            this.lblNickname.Size = new System.Drawing.Size(100, 16);
            this.lblNickname.TabIndex = 1;
            this.lblNickname.Text = "深圳市视酷信息";
            this.lblNickname.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.lblNickname.Click += new System.EventHandler(this.uscFriendShow_Click);
            this.lblNickname.MouseEnter += new System.EventHandler(this.uscFriendShow_MouseEnter);
            this.lblNickname.MouseLeave += new System.EventHandler(this.uscFriendShow_MouseLeave);
            // 
            // chkSelect
            // 
            this.chkSelect.AutoSize = true;
            this.chkSelect.Location = new System.Drawing.Point(217, 26);
            this.chkSelect.Name = "chkSelect";
            this.chkSelect.Size = new System.Drawing.Size(15, 14);
            this.chkSelect.TabIndex = 5;
            this.chkSelect.UseVisualStyleBackColor = true;
            this.chkSelect.CheckedChanged += new System.EventHandler(this.chkSelect_CheckedChanged);
            // 
            // picHead
            // 
            this.picHead.BackColor = System.Drawing.Color.WhiteSmoke;
            this.picHead.Image = global::WinFrmTalk.Properties.Resources.account;
            this.picHead.Location = new System.Drawing.Point(15, 15);
            this.picHead.Name = "picHead";
            this.picHead.Size = new System.Drawing.Size(35, 35);
            this.picHead.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.picHead.TabIndex = 4;
            this.picHead.TabStop = false;
            this.picHead.Click += new System.EventHandler(this.uscFriendShow_Click);
            this.picHead.MouseEnter += new System.EventHandler(this.uscFriendShow_MouseEnter);
            this.picHead.MouseLeave += new System.EventHandler(this.uscFriendShow_MouseLeave);
            // 
            // USEFriendShow
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.Controls.Add(this.chkSelect);
            this.Controls.Add(this.picHead);
            this.Controls.Add(this.lblNickname);
            this.Name = "USEFriendShow";
            this.Size = new System.Drawing.Size(255, 60);
            this.Load += new System.EventHandler(this.uscFriendShow_Load);
            this.Click += new System.EventHandler(this.uscFriendShow_Click);
            this.MouseEnter += new System.EventHandler(this.uscFriendShow_MouseEnter);
            this.MouseLeave += new System.EventHandler(this.uscFriendShow_MouseLeave);
            ((System.ComponentModel.ISupportInitialize)(this.picHead)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label lblNickname;
        private System.Windows.Forms.PictureBox picHead;
        private System.Windows.Forms.CheckBox chkSelect;
    }
}
