namespace WinFrmTalk
{
    partial class FriendListItem
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
            this.lblname = new System.Windows.Forms.Label();
            this.pbAvator = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.pbAvator)).BeginInit();
            this.SuspendLayout();
            // 
            // lblname
            // 
            this.lblname.AutoSize = true;
            this.lblname.Enabled = false;
            this.lblname.Font = new System.Drawing.Font(Applicate.SetFont, 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblname.ForeColor = System.Drawing.Color.Black;
            this.lblname.Location = new System.Drawing.Point(52, 15);
            this.lblname.Name = "lblname";
            this.lblname.Size = new System.Drawing.Size(81, 20);
            this.lblname.TabIndex = 0;
            this.lblname.Text = "Nickname";
            // 
            // pbAvator
            // 
            this.pbAvator.Location = new System.Drawing.Point(8, 5);
            this.pbAvator.Name = "pbAvator";
            this.pbAvator.Size = new System.Drawing.Size(36, 36);
            this.pbAvator.TabIndex = 1;
            this.pbAvator.TabStop = false;
            // 
            // FriendListItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.BackColor = System.Drawing.Color.Transparent;
            this.Controls.Add(this.pbAvator);
            this.Controls.Add(this.lblname);
            this.DoubleBuffered = true;
            this.Margin = new System.Windows.Forms.Padding(0);
            this.Name = "FriendListItem";
            this.Size = new System.Drawing.Size(173, 46);
            this.Load += new System.EventHandler(this.FriendListItem_Load);
            this.Click += new System.EventHandler(this.FriendListItem_Click);
            this.MouseEnter += new System.EventHandler(this.FriendListItem_MouseEnter);
            this.MouseLeave += new System.EventHandler(this.FriendListItem_MouseLeave);
            ((System.ComponentModel.ISupportInitialize)(this.pbAvator)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        public System.Windows.Forms.Label lblname;
        private System.Windows.Forms.PictureBox pbAvator;
    }
}
