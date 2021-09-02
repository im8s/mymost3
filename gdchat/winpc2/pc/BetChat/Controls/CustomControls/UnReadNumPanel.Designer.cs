namespace WinFrmTalk.Controls.CustomControls
{
    partial class UnReadNumPanel
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
            this.panUp = new System.Windows.Forms.Panel();
            this.lblUnReadNum = new System.Windows.Forms.Label();
            this.picIcon = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.picClose)).BeginInit();
            this.panUp.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picIcon)).BeginInit();
            this.SuspendLayout();
            // 
            // lblLine
            // 
            this.lblLine.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(225)))), ((int)(((byte)(225)))), ((int)(((byte)(225)))));
            this.lblLine.Location = new System.Drawing.Point(120, 7);
            this.lblLine.Name = "lblLine";
            this.lblLine.Size = new System.Drawing.Size(1, 18);
            this.lblLine.TabIndex = 1;
            // 
            // picClose
            // 
            this.picClose.Cursor = System.Windows.Forms.Cursors.Hand;
            this.picClose.Image = global::WinFrmTalk.Properties.Resources.ClosFrom;
            this.picClose.Location = new System.Drawing.Point(127, 4);
            this.picClose.Name = "picClose";
            this.picClose.Size = new System.Drawing.Size(25, 25);
            this.picClose.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.picClose.TabIndex = 2;
            this.picClose.TabStop = false;
            this.picClose.Click += new System.EventHandler(this.picClose_Click);
            // 
            // panUp
            // 
            this.panUp.Controls.Add(this.lblUnReadNum);
            this.panUp.Controls.Add(this.picIcon);
            this.panUp.Cursor = System.Windows.Forms.Cursors.Hand;
            this.panUp.Location = new System.Drawing.Point(3, 1);
            this.panUp.Name = "panUp";
            this.panUp.Size = new System.Drawing.Size(115, 30);
            this.panUp.TabIndex = 3;
            this.panUp.Click += new System.EventHandler(this.panUp_Click);
            // 
            // lblUnReadNum
            // 
            this.lblUnReadNum.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblUnReadNum.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(140)))), ((int)(((byte)(230)))), ((int)(((byte)(140)))));
            this.lblUnReadNum.Location = new System.Drawing.Point(26, 5);
            this.lblUnReadNum.Name = "lblUnReadNum";
            this.lblUnReadNum.Size = new System.Drawing.Size(83, 23);
            this.lblUnReadNum.TabIndex = 5;
            this.lblUnReadNum.Text = "100条新消息";
            this.lblUnReadNum.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // picIcon
            // 
            this.picIcon.Image = global::WinFrmTalk.Properties.Resources.up;
            this.picIcon.Location = new System.Drawing.Point(5, 8);
            this.picIcon.Name = "picIcon";
            this.picIcon.Size = new System.Drawing.Size(15, 15);
            this.picIcon.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.picIcon.TabIndex = 4;
            this.picIcon.TabStop = false;
            // 
            // UnReadNumPanel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Transparent;
            this.Controls.Add(this.panUp);
            this.Controls.Add(this.picClose);
            this.Controls.Add(this.lblLine);
            this.Name = "UnReadNumPanel";
            this.Size = new System.Drawing.Size(156, 32);
            this.Load += new System.EventHandler(this.UnReadNumPanel_Load);
            this.Paint += new System.Windows.Forms.PaintEventHandler(this.UnReadNumPanel_Paint);
            ((System.ComponentModel.ISupportInitialize)(this.picClose)).EndInit();
            this.panUp.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.picIcon)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Label lblLine;
        private System.Windows.Forms.PictureBox picClose;
        private System.Windows.Forms.Panel panUp;
        private System.Windows.Forms.Label lblUnReadNum;
        private System.Windows.Forms.PictureBox picIcon;
    }
}
