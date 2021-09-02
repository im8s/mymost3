namespace WinFrmTalk
{
    partial class InfoCard
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
            this.lblInfo = new System.Windows.Forms.Label();
            this.txtinfo = new System.Windows.Forms.TextBox();
            this.lblfeatures = new System.Windows.Forms.Label();
            this.lblleft = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // lblInfo
            // 
            this.lblInfo.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblInfo.BackColor = System.Drawing.Color.Transparent;
            this.lblInfo.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.lblInfo.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblInfo.Location = new System.Drawing.Point(224, 12);
            this.lblInfo.Margin = new System.Windows.Forms.Padding(3);
            this.lblInfo.Name = "lblInfo";
            this.lblInfo.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.lblInfo.Size = new System.Drawing.Size(94, 16);
            this.lblInfo.TabIndex = 4;
            this.lblInfo.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.lblInfo.UseMnemonic = false;
            this.lblInfo.SizeChanged += new System.EventHandler(this.lblInfo_SizeChanged);
            this.lblInfo.Click += new System.EventHandler(this.lblInfo_Click);
            this.lblInfo.MouseEnter += new System.EventHandler(this.panel1_MouseHover);
            this.lblInfo.MouseLeave += new System.EventHandler(this.panel1_MouseLeave);
            // 
            // txtinfo
            // 
            this.txtinfo.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.txtinfo.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.txtinfo.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.txtinfo.Location = new System.Drawing.Point(224, 12);
            this.txtinfo.Name = "txtinfo";
            this.txtinfo.Size = new System.Drawing.Size(94, 16);
            this.txtinfo.TabIndex = 0;
            this.txtinfo.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.txtinfo.Visible = false;
            this.txtinfo.TextChanged += new System.EventHandler(this.txtinfo_TextChanged);
            this.txtinfo.MouseEnter += new System.EventHandler(this.txtinfo_MouseEnter);
            this.txtinfo.MouseLeave += new System.EventHandler(this.panel1_MouseLeave);
            // 
            // lblfeatures
            // 
            this.lblfeatures.AutoSize = true;
            this.lblfeatures.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblfeatures.Location = new System.Drawing.Point(12, 12);
            this.lblfeatures.Margin = new System.Windows.Forms.Padding(3, 0, 0, 0);
            this.lblfeatures.Name = "lblfeatures";
            this.lblfeatures.Size = new System.Drawing.Size(0, 17);
            this.lblfeatures.TabIndex = 0;
            this.lblfeatures.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblfeatures.MouseEnter += new System.EventHandler(this.panel1_MouseHover);
            this.lblfeatures.MouseLeave += new System.EventHandler(this.panel1_MouseLeave);
            // 
            // lblleft
            // 
            this.lblleft.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblleft.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblleft.ForeColor = System.Drawing.Color.Black;
            this.lblleft.Location = new System.Drawing.Point(309, 9);
            this.lblleft.Name = "lblleft";
            this.lblleft.Size = new System.Drawing.Size(19, 23);
            this.lblleft.TabIndex = 6;
            this.lblleft.Text = "";
            this.lblleft.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.lblleft.Click += new System.EventHandler(this.panel1_Click);
            this.lblleft.MouseEnter += new System.EventHandler(this.panel1_MouseHover);
            this.lblleft.MouseLeave += new System.EventHandler(this.panel1_MouseLeave);
            // 
            // InfoCard
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.Controls.Add(this.txtinfo);
            this.Controls.Add(this.lblleft);
            this.Controls.Add(this.lblfeatures);
            this.Controls.Add(this.lblInfo);
            this.Name = "InfoCard";
            this.Size = new System.Drawing.Size(331, 41);
            this.Load += new System.EventHandler(this.InfoCard_Load);
            this.Click += new System.EventHandler(this.panel1_Click);
            this.MouseEnter += new System.EventHandler(this.panel1_MouseHover);
            this.MouseLeave += new System.EventHandler(this.InfoCard_MouseLeave);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        public System.Windows.Forms.Label lblInfo;
        public System.Windows.Forms.Label lblleft;
        public System.Windows.Forms.TextBox txtinfo;
        public System.Windows.Forms.Label lblfeatures;
    }
}
