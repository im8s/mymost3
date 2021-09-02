namespace WinFrmTalk.Controls.CustomControls
{
    partial class USERemindMe
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
            this.lblLine = new System.Windows.Forms.Label();
            this.picClose = new System.Windows.Forms.PictureBox();
            this.panRemind = new System.Windows.Forms.Panel();
            this.lblpic = new System.Windows.Forms.PictureBox();
            this.lblRemaidme = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.picClose)).BeginInit();
            this.panRemind.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.lblpic)).BeginInit();
            this.SuspendLayout();
            // 
            // lblLine
            // 
            this.lblLine.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(225)))), ((int)(((byte)(225)))), ((int)(((byte)(225)))));
            this.lblLine.Location = new System.Drawing.Point(120, 7);
            this.lblLine.Name = "lblLine";
            this.lblLine.Size = new System.Drawing.Size(1, 18);
            this.lblLine.TabIndex = 6;
            // 
            // picClose
            // 
            this.picClose.Cursor = System.Windows.Forms.Cursors.Hand;
            this.picClose.Image = global::WinFrmTalk.Properties.Resources.ClosFrom;
            this.picClose.Location = new System.Drawing.Point(127, 4);
            this.picClose.Name = "picClose";
            this.picClose.Size = new System.Drawing.Size(25, 25);
            this.picClose.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.picClose.TabIndex = 7;
            this.picClose.TabStop = false;
            this.picClose.Click += new System.EventHandler(this.picClose_Click);
            // 
            // panRemind
            // 
            this.panRemind.BackColor = System.Drawing.Color.Transparent;
            this.panRemind.Controls.Add(this.lblpic);
            this.panRemind.Controls.Add(this.lblRemaidme);
            this.panRemind.Cursor = System.Windows.Forms.Cursors.Hand;
            this.panRemind.Location = new System.Drawing.Point(3, 1);
            this.panRemind.Name = "panRemind";
            this.panRemind.Size = new System.Drawing.Size(115, 30);
            this.panRemind.TabIndex = 8;
            this.panRemind.Click += new System.EventHandler(this.panRemind_Click);
            // 
            // lblpic
            // 
            this.lblpic.Location = new System.Drawing.Point(5, 8);
            this.lblpic.Name = "lblpic";
            this.lblpic.Size = new System.Drawing.Size(15, 15);
            this.lblpic.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.lblpic.TabIndex = 7;
            this.lblpic.TabStop = false;
            // 
            // lblRemaidme
            // 
            this.lblRemaidme.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblRemaidme.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Bold);
            this.lblRemaidme.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(140)))), ((int)(((byte)(230)))), ((int)(((byte)(140)))));
            this.lblRemaidme.Location = new System.Drawing.Point(42, 5);
            this.lblRemaidme.Name = "lblRemaidme";
            this.lblRemaidme.Size = new System.Drawing.Size(69, 23);
            this.lblRemaidme.TabIndex = 6;
            this.lblRemaidme.Text = "有人@我";
            this.lblRemaidme.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // USERemindMe
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.Controls.Add(this.panRemind);
            this.Controls.Add(this.picClose);
            this.Controls.Add(this.lblLine);
            this.Name = "USERemindMe";
            this.Size = new System.Drawing.Size(156, 32);
            this.Load += new System.EventHandler(this.USERemindMe_Load);
            this.Paint += new System.Windows.Forms.PaintEventHandler(this.USERemindMe_Paint);
            ((System.ComponentModel.ISupportInitialize)(this.picClose)).EndInit();
            this.panRemind.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.lblpic)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Label lblLine;
        private System.Windows.Forms.PictureBox picClose;
        private System.Windows.Forms.Panel panRemind;
        private System.Windows.Forms.PictureBox lblpic;
        private System.Windows.Forms.Label lblRemaidme;
    }
}
