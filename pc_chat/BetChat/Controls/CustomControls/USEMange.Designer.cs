namespace WinFrmTalk.Controls.CustomControls
{
    partial class USEMange
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
            this.lab_name = new System.Windows.Forms.Label();
            this.pic_head = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).BeginInit();
            this.SuspendLayout();
            // 
            // lblName
            // 
            this.lblName.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblName.BackColor = System.Drawing.Color.Transparent;
            this.lblName.Font = new System.Drawing.Font("微软雅黑", 11.25F);
            this.lblName.Location = new System.Drawing.Point(170, 13);
            this.lblName.Name = "lblName";
            this.lblName.Size = new System.Drawing.Size(103, 25);
            this.lblName.TabIndex = 1;
            this.lblName.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.lblName.TextChanged += new System.EventHandler(this.lblName_TextChanged);
            this.lblName.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lblName_MouseDown);
            this.lblName.MouseEnter += new System.EventHandler(this.lblName_MouseEnter);
            // 
            // lab_name
            // 
            this.lab_name.AutoSize = true;
            this.lab_name.BackColor = System.Drawing.Color.Transparent;
            this.lab_name.Font = new System.Drawing.Font("微软雅黑", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_name.Location = new System.Drawing.Point(44, 18);
            this.lab_name.Name = "lab_name";
            this.lab_name.Size = new System.Drawing.Size(48, 20);
            this.lab_name.TabIndex = 3;
            this.lab_name.Text = "NULL";
            this.lab_name.UseMnemonic = false;
            this.lab_name.TextChanged += new System.EventHandler(this.lab_name_TextChanged);
            this.lab_name.Click += new System.EventHandler(this.lab_name_Click);
            this.lab_name.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lab_name_MouseDown);
            this.lab_name.MouseEnter += new System.EventHandler(this.lab_name_MouseEnter);
            // 
            // pic_head
            // 
            this.pic_head.isDrawRound = true;
            this.pic_head.Location = new System.Drawing.Point(6, 8);
            this.pic_head.Name = "pic_head";
            this.pic_head.Size = new System.Drawing.Size(35, 35);
            this.pic_head.TabIndex = 0;
            this.pic_head.TabStop = false;
            this.pic_head.Click += new System.EventHandler(this.pic_head_Click);
            this.pic_head.MouseDown += new System.Windows.Forms.MouseEventHandler(this.pic_head_MouseDown);
            this.pic_head.MouseEnter += new System.EventHandler(this.pic_head_MouseEnter);
            // 
            // USEMange
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Transparent;
            this.Controls.Add(this.pic_head);
            this.Controls.Add(this.lab_name);
            this.Controls.Add(this.lblName);
            this.Name = "USEMange";
            this.Size = new System.Drawing.Size(288, 50);
            this.MouseEnter += new System.EventHandler(this.USEMange_MouseEnter);
            this.MouseLeave += new System.EventHandler(this.USEMange_MouseLeave);
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        public System.Windows.Forms.Label lblName;
        public System.Windows.Forms.Label lab_name;
    
        public RoundPicBox pic_head;
    }
}
