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
            this.lblfeatures = new System.Windows.Forms.Label();
            this.checkData = new WinFrmTalk.Controls.CustomControls.USEToggle();
            this.SuspendLayout();
            // 
            // lblfeatures
            // 
            this.lblfeatures.AutoSize = true;
            this.lblfeatures.Font = new System.Drawing.Font(Applicate.SetFont, 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblfeatures.Location = new System.Drawing.Point(12, 12);
            this.lblfeatures.Margin = new System.Windows.Forms.Padding(3, 0, 0, 0);
            this.lblfeatures.Name = "lblfeatures";
            this.lblfeatures.Size = new System.Drawing.Size(0, 17);
            this.lblfeatures.TabIndex = 9;
            // 
            // checkData
            // 
            this.checkData.BackColor = System.Drawing.Color.Transparent;
            this.checkData.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.checkData.Checked = false;
            this.checkData.checkStyle = WinFrmTalk.Controls.CustomControls.CheckStyle.style1;
            this.checkData.Cursor = System.Windows.Forms.Cursors.Hand;
            this.checkData.Location = new System.Drawing.Point(165, 5);
            this.checkData.Name = "checkData";
            this.checkData.Size = new System.Drawing.Size(31, 30);
            this.checkData.TabIndex = 11;
            // 
            // USeCheckData
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.checkData);
            this.Controls.Add(this.lblfeatures);
            this.Name = "USeCheckData";
            this.Size = new System.Drawing.Size(206, 35);
            this.MouseEnter += new System.EventHandler(this.panel1_MouseHover);
            this.MouseLeave += new System.EventHandler(this.panel1_MouseLeave);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label lblfeatures;
        public USEToggle checkData;
    }
}
