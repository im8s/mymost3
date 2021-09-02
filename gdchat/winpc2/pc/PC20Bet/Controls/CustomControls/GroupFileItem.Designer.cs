namespace WinFrmTalk
{
    partial class GroupFileItem
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
            this.lblDown = new System.Windows.Forms.Label();
            this.lblDatime = new System.Windows.Forms.Label();
            this.lblLength = new System.Windows.Forms.Label();
            this.lblNickName = new System.Windows.Forms.Label();
            this.lblName = new System.Windows.Forms.Label();
            this.skp = new CCWin.SkinControl.SkinProgressBar();
            this.pboxIcon = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.pboxIcon)).BeginInit();
            this.SuspendLayout();
            // 
            // lblDown
            // 
            this.lblDown.AutoSize = true;
            this.lblDown.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblDown.ForeColor = System.Drawing.SystemColors.ButtonShadow;
            this.lblDown.Location = new System.Drawing.Point(452, 56);
            this.lblDown.Name = "lblDown";
            this.lblDown.Size = new System.Drawing.Size(37, 20);
            this.lblDown.TabIndex = 11;
            this.lblDown.Text = "上传";
            this.lblDown.UseMnemonic = false;
            // 
            // lblDatime
            // 
            this.lblDatime.AutoSize = true;
            this.lblDatime.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblDatime.ForeColor = System.Drawing.SystemColors.ButtonShadow;
            this.lblDatime.Location = new System.Drawing.Point(396, 10);
            this.lblDatime.Name = "lblDatime";
            this.lblDatime.Size = new System.Drawing.Size(124, 20);
            this.lblDatime.TabIndex = 10;
            this.lblDatime.Text = "2019-03-22 12:09";
            this.lblDatime.UseMnemonic = false;
            // 
            // lblLength
            // 
            this.lblLength.AutoSize = true;
            this.lblLength.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblLength.ForeColor = System.Drawing.SystemColors.ButtonShadow;
            this.lblLength.Location = new System.Drawing.Point(88, 56);
            this.lblLength.Name = "lblLength";
            this.lblLength.Size = new System.Drawing.Size(36, 20);
            this.lblLength.TabIndex = 9;
            this.lblLength.Text = "4.6k";
            this.lblLength.UseMnemonic = false;
            // 
            // lblNickName
            // 
            this.lblNickName.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblNickName.ForeColor = System.Drawing.SystemColors.ButtonShadow;
            this.lblNickName.Location = new System.Drawing.Point(88, 33);
            this.lblNickName.Name = "lblNickName";
            this.lblNickName.Size = new System.Drawing.Size(91, 20);
            this.lblNickName.TabIndex = 8;
            this.lblNickName.Text = "上传人名称";
            this.lblNickName.UseMnemonic = false;
            // 
            // lblName
            // 
            this.lblName.AutoSize = true;
            this.lblName.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblName.Location = new System.Drawing.Point(88, 10);
            this.lblName.Name = "lblName";
            this.lblName.Size = new System.Drawing.Size(93, 20);
            this.lblName.TabIndex = 6;
            this.lblName.Text = "文件名文件名";
            this.lblName.UseMnemonic = false;
            // 
            // skp
            // 
            this.skp.Back = null;
            this.skp.BackColor = System.Drawing.Color.Transparent;
            this.skp.BarBack = null;
            this.skp.BarRadiusStyle = CCWin.SkinClass.RoundStyle.All;
            this.skp.ForeColor = System.Drawing.Color.Black;
            this.skp.FormatString = "";
            this.skp.Location = new System.Drawing.Point(15, 80);
            this.skp.Name = "skp";
            this.skp.RadiusStyle = CCWin.SkinClass.RoundStyle.All;
            this.skp.Size = new System.Drawing.Size(500, 4);
            this.skp.TabIndex = 12;
            // 
            // pboxIcon
            // 
            this.pboxIcon.Location = new System.Drawing.Point(22, 10);
            this.pboxIcon.Name = "pboxIcon";
            this.pboxIcon.Size = new System.Drawing.Size(60, 60);
            this.pboxIcon.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pboxIcon.TabIndex = 7;
            this.pboxIcon.TabStop = false;
            // 
            // GroupFileItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.skp);
            this.Controls.Add(this.lblDown);
            this.Controls.Add(this.lblDatime);
            this.Controls.Add(this.lblLength);
            this.Controls.Add(this.lblNickName);
            this.Controls.Add(this.pboxIcon);
            this.Controls.Add(this.lblName);
            this.Name = "GroupFileItem";
            this.Size = new System.Drawing.Size(526, 87);
            this.MouseEnter += new System.EventHandler(this.GroupFileItem_MouseEnter);
            this.MouseLeave += new System.EventHandler(this.GroupFileItem_MouseLeave);
            ((System.ComponentModel.ISupportInitialize)(this.pboxIcon)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblDown;
        private System.Windows.Forms.Label lblDatime;
        private System.Windows.Forms.Label lblLength;
        private System.Windows.Forms.Label lblNickName;
        private System.Windows.Forms.PictureBox pboxIcon;
        private System.Windows.Forms.Label lblName;
        private CCWin.SkinControl.SkinProgressBar skp;
    }
}
