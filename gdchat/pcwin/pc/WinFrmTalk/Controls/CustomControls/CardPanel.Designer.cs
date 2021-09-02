namespace WinFrmTalk.Controls
{
    partial class CardPanel
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
            this.panel_file = new System.Windows.Forms.Panel();
            this.lab_icon = new System.Windows.Forms.PictureBox();
            this.lab_txt = new System.Windows.Forms.Label();
            this.lab_lineSilver = new System.Windows.Forms.Label();
            this.lab_content = new System.Windows.Forms.Label();
            this.panel_file.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.lab_icon)).BeginInit();
            this.SuspendLayout();
            // 
            // panel_file
            // 
            this.panel_file.Controls.Add(this.lab_icon);
            this.panel_file.Controls.Add(this.lab_txt);
            this.panel_file.Controls.Add(this.lab_lineSilver);
            this.panel_file.Controls.Add(this.lab_content);
            this.panel_file.Cursor = System.Windows.Forms.Cursors.Hand;
            this.panel_file.Location = new System.Drawing.Point(0, 0);
            this.panel_file.Name = "panel_file";
            this.panel_file.Size = new System.Drawing.Size(225, 76);
            this.panel_file.TabIndex = 14;
            // 
            // lab_icon
            // 
            this.lab_icon.Location = new System.Drawing.Point(7, 6);
            this.lab_icon.Name = "lab_icon";
            this.lab_icon.Size = new System.Drawing.Size(35, 35);
            this.lab_icon.TabIndex = 16;
            this.lab_icon.TabStop = false;
            // 
            // lab_txt
            // 
            this.lab_txt.Font = new System.Drawing.Font(Applicate.SetFont, 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_txt.ForeColor = System.Drawing.Color.Gray;
            this.lab_txt.Location = new System.Drawing.Point(6, 55);
            this.lab_txt.Name = "lab_txt";
            this.lab_txt.Size = new System.Drawing.Size(41, 19);
            this.lab_txt.TabIndex = 0;
            this.lab_txt.Text = "名片";
            // 
            // lab_lineSilver
            // 
            this.lab_lineSilver.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lab_lineSilver.BackColor = System.Drawing.Color.Silver;
            this.lab_lineSilver.Location = new System.Drawing.Point(6, 50);
            this.lab_lineSilver.Name = "lab_lineSilver";
            this.lab_lineSilver.Size = new System.Drawing.Size(212, 1);
            this.lab_lineSilver.TabIndex = 15;
            // 
            // lab_content
            // 
            this.lab_content.AutoSize = true;
            this.lab_content.Font = new System.Drawing.Font(Applicate.SetFont, 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_content.Location = new System.Drawing.Point(52, 10);
            this.lab_content.Name = "lab_content";
            this.lab_content.Size = new System.Drawing.Size(44, 17);
            this.lab_content.TabIndex = 13;
            this.lab_content.Text = "我是谁";
            // 
            // CardPanel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Transparent;
            this.Controls.Add(this.panel_file);
            this.Name = "CardPanel";
            this.Size = new System.Drawing.Size(227, 78);
            this.panel_file.ResumeLayout(false);
            this.panel_file.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.lab_icon)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panel_file;
        private System.Windows.Forms.Label lab_txt;
        private System.Windows.Forms.Label lab_lineSilver;
        public System.Windows.Forms.Label lab_content;
        public System.Windows.Forms.PictureBox lab_icon;
    }
}
