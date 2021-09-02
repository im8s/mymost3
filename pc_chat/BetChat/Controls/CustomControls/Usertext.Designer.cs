namespace WinFrmTalk.Controls.CustomControls
{
    partial class Usertext
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
            this.lbltext = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // lbltext
            // 
            this.lbltext.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lbltext.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lbltext.Location = new System.Drawing.Point(17, 9);
            this.lbltext.Name = "lbltext";
            this.lbltext.Size = new System.Drawing.Size(275, 17);
            this.lbltext.TabIndex = 0;
            this.lbltext.Text = "label1";
            this.lbltext.UseMnemonic = false;
            this.lbltext.TextChanged += new System.EventHandler(this.lbltext_TextChanged);
            // 
            // Usertext
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.lbltext);
            this.Name = "Usertext";
            this.Size = new System.Drawing.Size(307, 32);
            this.MouseEnter += new System.EventHandler(this.FriendItem_MouseEnter);
            this.MouseLeave += new System.EventHandler(this.FriendItem_MouseLeave);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label lbltext;
    }
}
