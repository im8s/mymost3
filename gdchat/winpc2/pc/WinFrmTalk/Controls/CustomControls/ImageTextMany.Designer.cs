namespace WinFrmTalk.Controls.CustomControls
{
    partial class ImageTextMany
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
            this.pan_content = new System.Windows.Forms.Panel();
            this.picImg = new System.Windows.Forms.PictureBox();
            this.lblTitle = new System.Windows.Forms.Label();
            this.pan_content.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picImg)).BeginInit();
            this.SuspendLayout();
            // 
            // pan_content
            // 
            this.pan_content.Controls.Add(this.picImg);
            this.pan_content.Controls.Add(this.lblTitle);
            this.pan_content.Location = new System.Drawing.Point(15, 10);
            this.pan_content.Name = "pan_content";
            this.pan_content.Size = new System.Drawing.Size(270, 125);
            this.pan_content.TabIndex = 4;
            // 
            // picImg
            // 
            this.picImg.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.picImg.Location = new System.Drawing.Point(0, 25);
            this.picImg.Name = "picImg";
            this.picImg.Size = new System.Drawing.Size(270, 100);
            this.picImg.TabIndex = 5;
            this.picImg.TabStop = false;
            // 
            // lblTitle
            // 
            this.lblTitle.AutoSize = true;
            this.lblTitle.Cursor = System.Windows.Forms.Cursors.Hand;
            this.lblTitle.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblTitle.Location = new System.Drawing.Point(0, 0);
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(0, 17);
            this.lblTitle.TabIndex = 4;
            // 
            // ImageTextMany
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.Controls.Add(this.pan_content);
            this.Cursor = System.Windows.Forms.Cursors.Hand;
            this.Name = "ImageTextMany";
            this.Size = new System.Drawing.Size(300, 140);
            this.pan_content.ResumeLayout(false);
            this.pan_content.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picImg)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel pan_content;
        public System.Windows.Forms.PictureBox picImg;
        public System.Windows.Forms.Label lblTitle;
    }
}
