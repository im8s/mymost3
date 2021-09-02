namespace WinFrmTalk.Controls.CustomControls
{
    partial class USETranChantinfo
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
            this.lab_text = new System.Windows.Forms.Label();
            this.pic_head = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).BeginInit();
            this.SuspendLayout();
            // 
            // lblLine
            // 
            this.lblLine.BackColor = System.Drawing.Color.Gainsboro;
            this.lblLine.Location = new System.Drawing.Point(50, 0);
            this.lblLine.Name = "lblLine";
            this.lblLine.Size = new System.Drawing.Size(410, 1);
            this.lblLine.TabIndex = 20;
            this.lblLine.Text = "label1";
            // 
            // lab_time
            // 
            this.lab_time.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lab_time.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_time.ForeColor = System.Drawing.Color.DimGray;
            this.lab_time.Location = new System.Drawing.Point(355, 23);
            this.lab_time.Name = "lab_time";
            this.lab_time.Size = new System.Drawing.Size(70, 15);
            this.lab_time.TabIndex = 17;
            this.lab_time.Text = "2019/11/11";
            this.lab_time.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // lab_name
            // 
            this.lab_name.AutoSize = true;
            this.lab_name.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_name.Location = new System.Drawing.Point(50, 21);
            this.lab_name.Name = "lab_name";
            this.lab_name.Size = new System.Drawing.Size(43, 17);
            this.lab_name.TabIndex = 18;
            this.lab_name.Text = "Name";
            this.lab_name.UseMnemonic = false;
            this.lab_name.Click += new System.EventHandler(this.lab_name_Click);
            // 
            // lab_text
            // 
            this.lab_text.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lab_text.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_text.Location = new System.Drawing.Point(51, 51);
            this.lab_text.Name = "lab_text";
            this.lab_text.Size = new System.Drawing.Size(421, 16);
            this.lab_text.TabIndex = 21;
            this.lab_text.Text = "label1";
            this.lab_text.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.lab_text.UseMnemonic = false;
            this.lab_text.Click += new System.EventHandler(this.lab_text_Click);
            // 
            // pic_head
            // 
            this.pic_head.isDrawRound = true;
            this.pic_head.Location = new System.Drawing.Point(5, 21);
            this.pic_head.Name = "pic_head";
            this.pic_head.Size = new System.Drawing.Size(35, 35);
            this.pic_head.TabIndex = 19;
            this.pic_head.TabStop = false;
            // 
            // USETranChantinfo
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Controls.Add(this.lab_text);
            this.Controls.Add(this.lblLine);
            this.Controls.Add(this.lab_time);
            this.Controls.Add(this.pic_head);
            this.Controls.Add(this.lab_name);
            this.Name = "USETranChantinfo";
            this.Size = new System.Drawing.Size(475, 80);
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblLine;
        private System.Windows.Forms.Label lab_time;
        public RoundPicBox pic_head;
        private System.Windows.Forms.Label lab_name;
        public System.Windows.Forms.Label lab_text;
    }
}
