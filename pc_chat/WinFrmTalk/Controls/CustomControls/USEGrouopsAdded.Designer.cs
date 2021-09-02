namespace WinFrmTalk.Controls.CustomControls
{
    partial class USEGrouopsAdded
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
            this.btnCancel = new System.Windows.Forms.Button();
            this.lblName = new System.Windows.Forms.Label();
            this.picGroups = new WinFrmTalk.PicChangeControl();
            this.SuspendLayout();
            // 
            // btnCancel
            // 
            this.btnCancel.BackColor = System.Drawing.Color.Transparent;
            this.btnCancel.FlatAppearance.BorderSize = 0;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Location = new System.Drawing.Point(235, 13);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(35, 23);
            this.btnCancel.TabIndex = 2;
            this.btnCancel.Text = "×";
            this.btnCancel.UseVisualStyleBackColor = false;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // lblName
            // 
            this.lblName.AutoSize = true;
            this.lblName.Location = new System.Drawing.Point(120, 22);
            this.lblName.Name = "lblName";
            this.lblName.Size = new System.Drawing.Size(0, 12);
            this.lblName.TabIndex = 4;
            // 
            // picGroups
            // 
            this.picGroups.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.picGroups.Location = new System.Drawing.Point(8, 6);
            this.picGroups.Name = "picGroups";
            this.picGroups.PersonPic = null;
            this.picGroups.Size = new System.Drawing.Size(40, 40);
            this.picGroups.TabIndex = 5;
            this.picGroups.UserName = null;
            this.picGroups.Load += new System.EventHandler(this.picGroups_Load);
            // 
            // USEGrouopsAdded
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.picGroups);
            this.Controls.Add(this.lblName);
            this.Controls.Add(this.btnCancel);
            this.Name = "USEGrouopsAdded";
            this.Size = new System.Drawing.Size(273, 51);
            this.Load += new System.EventHandler(this.USEGrouopsAdded_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        public System.Windows.Forms.Label lblName;
        public System.Windows.Forms.Button btnCancel;
        public PicChangeControl picGroups;
    }
}
