namespace WinFrmTalk.Controls
{
    partial class ChatItem
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
            this.skinLine1 = new CCWin.SkinControl.SkinLine();
            this.lblName = new System.Windows.Forms.Label();
            this.lblDatime = new System.Windows.Forms.Label();
            this.pboxHead = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.pboxHead)).BeginInit();
            this.SuspendLayout();
            // 
            // skinLine1
            // 
            this.skinLine1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.skinLine1.BackColor = System.Drawing.Color.Gainsboro;
            this.skinLine1.LineColor = System.Drawing.Color.Black;
            this.skinLine1.LineHeight = 1;
            this.skinLine1.Location = new System.Drawing.Point(64, 74);
            this.skinLine1.Name = "skinLine1";
            this.skinLine1.Size = new System.Drawing.Size(495, 1);
            this.skinLine1.TabIndex = 23;
            this.skinLine1.Text = "skinLine1";
            // 
            // lblName
            // 
            this.lblName.AutoSize = true;
            this.lblName.Font = new System.Drawing.Font("微软雅黑", 11.5F);
            this.lblName.Location = new System.Drawing.Point(70, 12);
            this.lblName.Name = "lblName";
            this.lblName.Size = new System.Drawing.Size(56, 21);
            this.lblName.TabIndex = 20;
            this.lblName.Text = "Name";
            // 
            // lblDatime
            // 
            this.lblDatime.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblDatime.AutoSize = true;
            this.lblDatime.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblDatime.ForeColor = System.Drawing.Color.DimGray;
            this.lblDatime.Location = new System.Drawing.Point(487, 17);
            this.lblDatime.Name = "lblDatime";
            this.lblDatime.Size = new System.Drawing.Size(74, 17);
            this.lblDatime.TabIndex = 19;
            this.lblDatime.Text = "2019/11/11";
            this.lblDatime.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // pboxHead
            // 
            this.pboxHead.isDrawRound = true;
            this.pboxHead.Location = new System.Drawing.Point(9, 8);
            this.pboxHead.Name = "pboxHead";
            this.pboxHead.Size = new System.Drawing.Size(50, 50);
            this.pboxHead.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxHead.TabIndex = 21;
            this.pboxHead.TabStop = false;
            // 
            // ChatItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.skinLine1);
            this.Controls.Add(this.lblDatime);
            this.Controls.Add(this.pboxHead);
            this.Controls.Add(this.lblName);
            this.Name = "ChatItem";
            this.Size = new System.Drawing.Size(564, 80);
            ((System.ComponentModel.ISupportInitialize)(this.pboxHead)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private CCWin.SkinControl.SkinLine skinLine1;
        public RoundPicBox pboxHead;
        public System.Windows.Forms.Label lblDatime;
        public System.Windows.Forms.Label lblName;
    }
}
