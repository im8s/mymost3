namespace WinFrmTalk.Controls.CustomControls
{
    partial class UserCollectionItem
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
            this.lblTime = new System.Windows.Forms.Label();
            this.lblComeFrom = new System.Windows.Forms.Label();
            this.skinLine1 = new CCWin.SkinControl.SkinLine();
            this.panel = new System.Windows.Forms.Panel();
            this.SuspendLayout();
            // 
            // lblTime
            // 
            this.lblTime.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.lblTime.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblTime.ForeColor = System.Drawing.Color.Gray;
            this.lblTime.Location = new System.Drawing.Point(347, 20);
            this.lblTime.Name = "lblTime";
            this.lblTime.Size = new System.Drawing.Size(113, 15);
            this.lblTime.TabIndex = 1;
            this.lblTime.Text = "NULL";
            this.lblTime.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.lblTime.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lblTime_MouseDown);
            // 
            // lblComeFrom
            // 
            this.lblComeFrom.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.lblComeFrom.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblComeFrom.ForeColor = System.Drawing.Color.Gray;
            this.lblComeFrom.Location = new System.Drawing.Point(347, 45);
            this.lblComeFrom.Name = "lblComeFrom";
            this.lblComeFrom.Size = new System.Drawing.Size(113, 15);
            this.lblComeFrom.TabIndex = 2;
            this.lblComeFrom.Text = "NULL";
            this.lblComeFrom.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.lblComeFrom.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lblTime_MouseDown);
            // 
            // skinLine1
            // 
            this.skinLine1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
            this.skinLine1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(231)))), ((int)(((byte)(231)))));
            this.skinLine1.LineColor = System.Drawing.Color.FromArgb(((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))), ((int)(((byte)(220)))));
            this.skinLine1.LineHeight = 1;
            this.skinLine1.Location = new System.Drawing.Point(60, 79);
            this.skinLine1.Name = "skinLine1";
            this.skinLine1.Size = new System.Drawing.Size(400, 1);
            this.skinLine1.TabIndex = 3;
            this.skinLine1.Text = "skinLine1";
            // 
            // panel
            // 
            this.panel.Location = new System.Drawing.Point(0, 0);
            this.panel.Name = "panel";
            this.panel.Size = new System.Drawing.Size(341, 80);
            this.panel.TabIndex = 4;
            this.panel.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lblTime_MouseDown);
            // 
            // UserCollectionItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Controls.Add(this.skinLine1);
            this.Controls.Add(this.panel);
            this.Controls.Add(this.lblComeFrom);
            this.Controls.Add(this.lblTime);
            this.Name = "UserCollectionItem";
            this.Size = new System.Drawing.Size(500, 80);
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Label lblTime;
        private System.Windows.Forms.Label lblComeFrom;
        private CCWin.SkinControl.SkinLine skinLine1;
        public System.Windows.Forms.Panel panel;
    }
}
