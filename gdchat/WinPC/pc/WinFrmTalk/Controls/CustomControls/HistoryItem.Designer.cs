namespace WinFrmTalk.Controls.CustomControls
{
    partial class HistoryItem
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
            this.lab_time = new System.Windows.Forms.Label();
            this.lab_name = new System.Windows.Forms.Label();
            this.lblLine = new System.Windows.Forms.Label();
            this.pic_head = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).BeginInit();
            this.SuspendLayout();
            // 
            // lab_time
            // 
            this.lab_time.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lab_time.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_time.ForeColor = System.Drawing.Color.DimGray;
            this.lab_time.Location = new System.Drawing.Point(516, 23);
            this.lab_time.Name = "lab_time";
            this.lab_time.Size = new System.Drawing.Size(104, 19);
            this.lab_time.TabIndex = 12;
            this.lab_time.Text = "2019/11/11";
            this.lab_time.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.lab_time.UseMnemonic = false;
            // 
            // lab_name
            // 
            this.lab_name.AutoSize = true;
            this.lab_name.Font = new System.Drawing.Font("微软雅黑", 11.5F);
            this.lab_name.Location = new System.Drawing.Point(50, 21);
            this.lab_name.Name = "lab_name";
            this.lab_name.Size = new System.Drawing.Size(56, 21);
            this.lab_name.TabIndex = 13;
            this.lab_name.Text = "Name";
            this.lab_name.UseMnemonic = false;
            // 
            // lblLine
            // 
            this.lblLine.BackColor = System.Drawing.Color.Gainsboro;
            this.lblLine.Location = new System.Drawing.Point(50, 0);
            this.lblLine.Name = "lblLine";
            this.lblLine.Size = new System.Drawing.Size(420, 1);
            this.lblLine.TabIndex = 16;
            this.lblLine.Text = "label1";
            // 
            // pic_head
            // 
            this.pic_head.isDrawRound = true;
            this.pic_head.Location = new System.Drawing.Point(5, 21);
            this.pic_head.Name = "pic_head";
            this.pic_head.Size = new System.Drawing.Size(35, 35);
            this.pic_head.TabIndex = 15;
            this.pic_head.TabStop = false;
            // 
            // HistoryItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSize = true;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Controls.Add(this.lblLine);
            this.Controls.Add(this.lab_time);
            this.Controls.Add(this.pic_head);
            this.Controls.Add(this.lab_name);
            this.Name = "HistoryItem";
            this.Size = new System.Drawing.Size(633, 90);
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lab_time;
        public RoundPicBox pic_head;
        private System.Windows.Forms.Label lab_name;
        private System.Windows.Forms.Label lblLine;
    }
}
