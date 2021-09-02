namespace WinFrmTalk.Controls.CustomControls
{
    partial class USEGroupCard
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
            this.chkSelects = new System.Windows.Forms.CheckBox();
            this.lblNames = new System.Windows.Forms.Label();
            this.pics = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.pics)).BeginInit();
            this.SuspendLayout();
            // 
            // chkSelects
            // 
            this.chkSelects.AutoSize = true;
            this.chkSelects.Location = new System.Drawing.Point(242, 18);
            this.chkSelects.Name = "chkSelects";
            this.chkSelects.Size = new System.Drawing.Size(15, 14);
            this.chkSelects.TabIndex = 1;
            this.chkSelects.UseVisualStyleBackColor = true;
            this.chkSelects.CheckedChanged += new System.EventHandler(this.chkSelect_CheckedChanged);
            this.chkSelects.MouseEnter += new System.EventHandler(this.USEGroupCard_MouseEnter);
            this.chkSelects.MouseLeave += new System.EventHandler(this.USEGroupCard_MouseLeave);
            // 
            // lblNames
            // 
            this.lblNames.AutoSize = true;
            this.lblNames.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblNames.Location = new System.Drawing.Point(85, 20);
            this.lblNames.Name = "lblNames";
            this.lblNames.Size = new System.Drawing.Size(43, 17);
            this.lblNames.TabIndex = 2;
            this.lblNames.Text = "label1";
            this.lblNames.UseMnemonic = false;
            // 
            // pics
            // 
            this.pics.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.pics.Location = new System.Drawing.Point(8, 6);
            this.pics.Name = "pics";
            this.pics.Size = new System.Drawing.Size(40, 40);
            this.pics.TabIndex = 0;
            this.pics.TabStop = false;
            this.pics.Click += new System.EventHandler(this.pics_Click);
            this.pics.Paint += new System.Windows.Forms.PaintEventHandler(this.pictureBox1_Paint);
            this.pics.MouseDown += new System.Windows.Forms.MouseEventHandler(this.USEGroupCard_MouseDown);
            this.pics.MouseEnter += new System.EventHandler(this.USEGroupCard_MouseEnter);
            this.pics.MouseLeave += new System.EventHandler(this.USEGroupCard_MouseLeave);
            // 
            // USEGroupCard
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.Controls.Add(this.lblNames);
            this.Controls.Add(this.chkSelects);
            this.Controls.Add(this.pics);
            this.Name = "USEGroupCard";
            this.Size = new System.Drawing.Size(273, 51);
            this.Load += new System.EventHandler(this.USEGroupCard_Load);
            this.MouseDown += new System.Windows.Forms.MouseEventHandler(this.USEGroupCard_MouseDown);
            this.MouseEnter += new System.EventHandler(this.USEGroupCard_MouseEnter);
            this.MouseLeave += new System.EventHandler(this.USEGroupCard_MouseLeave);
            ((System.ComponentModel.ISupportInitialize)(this.pics)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

    
        public LollipopCheckBox chkSelect;
        public LollipopLabel lblName;
        public System.Windows.Forms.PictureBox pics;
        public System.Windows.Forms.Label lblNames;
        public System.Windows.Forms.CheckBox chkSelects;
    }
}
