namespace WinFrmTalk.Controls.CustomControls
{
    partial class Useaccounts
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
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.lab_name = new System.Windows.Forms.Label();
            this.lab_money = new System.Windows.Forms.Label();
            this.panel_file.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // panel_file
            // 
            this.panel_file.BackColor = System.Drawing.Color.Transparent;
            this.panel_file.BackgroundImage = global::WinFrmTalk.Properties.Resources.oronge;
            this.panel_file.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.panel_file.Controls.Add(this.pictureBox1);
            this.panel_file.Controls.Add(this.lab_name);
            this.panel_file.Controls.Add(this.lab_money);
            this.panel_file.Location = new System.Drawing.Point(3, 4);
            this.panel_file.Name = "panel_file";
            this.panel_file.Size = new System.Drawing.Size(233, 137);
            this.panel_file.TabIndex = 15;
            // 
            // pictureBox1
            // 
            this.pictureBox1.BackColor = System.Drawing.Color.Transparent;
            this.pictureBox1.BackgroundImage = global::WinFrmTalk.Properties.Resources.transfer_two_icon;
            this.pictureBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.pictureBox1.Location = new System.Drawing.Point(17, 28);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(55, 57);
            this.pictureBox1.TabIndex = 15;
            this.pictureBox1.TabStop = false;
            // 
            // lab_name
            // 
            this.lab_name.AutoSize = true;
            this.lab_name.BackColor = System.Drawing.Color.Transparent;
            this.lab_name.Font = new System.Drawing.Font("微软雅黑", 9.75F);
            this.lab_name.ForeColor = System.Drawing.Color.White;
            this.lab_name.Location = new System.Drawing.Point(82, 57);
            this.lab_name.Name = "lab_name";
            this.lab_name.Size = new System.Drawing.Size(35, 19);
            this.lab_name.TabIndex = 14;
            this.lab_name.Text = "红包";
            // 
            // lab_money
            // 
            this.lab_money.BackColor = System.Drawing.Color.Transparent;
            this.lab_money.Font = new System.Drawing.Font("微软雅黑", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_money.ForeColor = System.Drawing.Color.White;
            this.lab_money.Location = new System.Drawing.Point(82, 34);
            this.lab_money.Name = "lab_money";
            this.lab_money.Size = new System.Drawing.Size(127, 23);
            this.lab_money.TabIndex = 13;
            this.lab_money.Text = "22222";
            // 
            // Useaccounts
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Transparent;
            this.Controls.Add(this.panel_file);
            this.Name = "Useaccounts";
            this.Size = new System.Drawing.Size(241, 137);
            this.panel_file.ResumeLayout(false);
            this.panel_file.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.PictureBox pictureBox1;
        public System.Windows.Forms.Label lab_name;
        public System.Windows.Forms.Label lab_money;
        public System.Windows.Forms.Panel panel_file;
    }
}
