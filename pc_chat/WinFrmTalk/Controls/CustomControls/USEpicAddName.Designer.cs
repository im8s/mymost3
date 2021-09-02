namespace WinFrmTalk.Controls.CustomControls
{
    partial class USEpicAddName
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
            this.lblName = new System.Windows.Forms.Label();
            this.pics = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.pics)).BeginInit();
            this.SuspendLayout();
            // 
            // lblName
            // 
            this.lblName.AutoSize = true;
            this.lblName.Font = new System.Drawing.Font(Applicate.SetFont, 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblName.Location = new System.Drawing.Point(15, 38);
            this.lblName.Name = "lblName";
            this.lblName.Size = new System.Drawing.Size(0, 20);
            this.lblName.TabIndex = 1;
            this.lblName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // pics
            // 
            this.pics.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;

            this.pics.isDrawRound = true;
            this.pics.Location = new System.Drawing.Point(6, 3);
            this.pics.Name = "pics";
            this.pics.Size = new System.Drawing.Size(35, 35);
            this.pics.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pics.TabIndex = 4;
            this.pics.TabStop = false;
            this.pics.Click += new System.EventHandler(this.pics_Click);
            this.pics.MouseHover += new System.EventHandler(this.pics_MouseHover);
            // 
            // USEpicAddName
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.pics);
            this.Controls.Add(this.lblName);
            this.Name = "USEpicAddName";
            this.Size = new System.Drawing.Size(50, 58);
            this.Load += new System.EventHandler(this.USEpicAddName_Load);
            ((System.ComponentModel.ISupportInitialize)(this.pics)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        public System.Windows.Forms.Label lblName;
        public RoundPicBox pics;
    }
}
