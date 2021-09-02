namespace WinFrmTalk.Controls
{
    partial class USEReaded
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
            this.lab_time = new System.Windows.Forms.Label();
            this.lab_name = new System.Windows.Forms.Label();
            this.lab_ReaddTime = new System.Windows.Forms.Label();
            this.pic_head = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).BeginInit();
            this.SuspendLayout();
            // 
            // lblLine
            // 
            this.lblLine.BackColor = System.Drawing.Color.Gainsboro;
            this.lblLine.Location = new System.Drawing.Point(50, 0);
            this.lblLine.Name = "lblLine";
            this.lblLine.Size = new System.Drawing.Size(424, 1);
            this.lblLine.TabIndex = 20;
            this.lblLine.Text = "label1";
            // 
            // lab_time
            // 
            this.lab_time.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lab_time.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_time.ForeColor = System.Drawing.Color.DimGray;
            this.lab_time.Location = new System.Drawing.Point(359, 16);
            this.lab_time.Name = "lab_time";
            this.lab_time.Size = new System.Drawing.Size(70, 15);
            this.lab_time.TabIndex = 17;
            this.lab_time.Text = "2019/11/11";
            this.lab_time.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // lab_name
            // 
            this.lab_name.AutoSize = true;
            this.lab_name.Font = new System.Drawing.Font("微软雅黑", 11.5F);
            this.lab_name.Location = new System.Drawing.Point(61, 10);
            this.lab_name.Name = "lab_name";
            this.lab_name.Size = new System.Drawing.Size(56, 21);
            this.lab_name.TabIndex = 18;
            this.lab_name.Text = "Name";
            // 
            // lab_ReaddTime
            // 
            this.lab_ReaddTime.AutoSize = true;
            this.lab_ReaddTime.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_ReaddTime.ForeColor = System.Drawing.Color.DimGray;
            this.lab_ReaddTime.Location = new System.Drawing.Point(62, 31);
            this.lab_ReaddTime.Name = "lab_ReaddTime";
            this.lab_ReaddTime.Size = new System.Drawing.Size(43, 17);
            this.lab_ReaddTime.TabIndex = 21;
            this.lab_ReaddTime.Text = "label1";
            // 
            // pic_head
            // 
            this.pic_head.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.pic_head.isDrawRound = true;
            this.pic_head.Location = new System.Drawing.Point(20, 16);
            this.pic_head.Name = "pic_head";
            this.pic_head.Size = new System.Drawing.Size(35, 35);
            this.pic_head.TabIndex = 19;
            this.pic_head.TabStop = false;
            // 
            // USEReaded
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.lab_ReaddTime);
            this.Controls.Add(this.lblLine);
            this.Controls.Add(this.lab_time);
            this.Controls.Add(this.pic_head);
            this.Controls.Add(this.lab_name);
            this.Name = "USEReaded";
            this.Size = new System.Drawing.Size(432, 60);
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblLine;
        private System.Windows.Forms.Label lab_time;
        public RoundPicBox pic_head;
        private System.Windows.Forms.Label lab_name;
        private System.Windows.Forms.Label lab_ReaddTime;
    }
}
