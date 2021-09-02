namespace WinFrmTalk.Controls.CustomControls
{
    partial class UserChatSometime
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
            this.picdeleate = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.picdeleate)).BeginInit();
            this.SuspendLayout();
            // 
            // lbltext
            // 
            this.lbltext.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lbltext.Location = new System.Drawing.Point(19, 14);
            this.lbltext.Name = "lbltext";
            this.lbltext.Size = new System.Drawing.Size(442, 17);
            this.lbltext.TabIndex = 0;
            this.lbltext.Text = "label1";
            this.lbltext.UseMnemonic = false;
            this.lbltext.TextChanged += new System.EventHandler(this.lbltext_TextChanged);
            // 
            // picdeleate
            // 
            this.picdeleate.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.picdeleate.Image = global::WinFrmTalk.Properties.Resources.CloseZh;
            this.picdeleate.Location = new System.Drawing.Point(467, 12);
            this.picdeleate.Name = "picdeleate";
            this.picdeleate.Size = new System.Drawing.Size(20, 20);
            this.picdeleate.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.picdeleate.TabIndex = 1;
            this.picdeleate.TabStop = false;
            // 
            // UserChatSometime
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.picdeleate);
            this.Controls.Add(this.lbltext);
            this.Name = "UserChatSometime";
            this.Size = new System.Drawing.Size(496, 48);
            this.MouseEnter += new System.EventHandler(this.FriendItem_MouseEnter);
            this.MouseLeave += new System.EventHandler(this.FriendItem_MouseLeave);
            ((System.ComponentModel.ISupportInitialize)(this.picdeleate)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label lbltext;
        public System.Windows.Forms.PictureBox picdeleate;
    }
}
