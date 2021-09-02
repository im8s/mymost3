namespace WinFrmTalk.Controls.CustomControls
{
    partial class USeCheckData
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
            this.checkData = new LollipopToggle();
            this.lblfeatures = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // checkData
            // 
            this.checkData.AutoSize = true;
            this.checkData.EllipseBorderColor = "26,181,26";
            this.checkData.EllipseColor = "26,181,26";
            this.checkData.Location = new System.Drawing.Point(154, 10);
            this.checkData.Margin = new System.Windows.Forms.Padding(0);
            this.checkData.Name = "checkData";
            this.checkData.Size = new System.Drawing.Size(47, 19);
            this.checkData.TabIndex = 10;
            this.checkData.Text = "lollipopToggle1";
            this.checkData.UseVisualStyleBackColor = true;
            // 
            // lblfeatures
            // 
            this.lblfeatures.AutoSize = true;
            this.lblfeatures.Location = new System.Drawing.Point(12, 12);
            this.lblfeatures.Margin = new System.Windows.Forms.Padding(3, 0, 0, 0);
            this.lblfeatures.Name = "lblfeatures";
            this.lblfeatures.Size = new System.Drawing.Size(0, 12);
            this.lblfeatures.TabIndex = 9;
            // 
            // USeCheckData
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.checkData);
            this.Controls.Add(this.lblfeatures);
            this.Name = "USeCheckData";
            this.Size = new System.Drawing.Size(206, 35);
            this.Load += new System.EventHandler(this.InfoCard_Load);
            this.MouseEnter += new System.EventHandler(this.panel1_MouseHover);
            this.MouseLeave += new System.EventHandler(this.panel1_MouseLeave);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        public LollipopToggle checkData;
        private System.Windows.Forms.Label lblfeatures;
    }
}
