using WinFrmTalk.Properties;

namespace WinFrmTalk
{
    partial class UserSelectItem
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
            this.lblNickname = new System.Windows.Forms.Label();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.picHead = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picHead)).BeginInit();
            this.SuspendLayout();
            // 
            // lblNickname
            // 
            this.lblNickname.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.lblNickname.AutoEllipsis = true;
            this.lblNickname.BackColor = System.Drawing.Color.Transparent;
            this.lblNickname.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblNickname.Location = new System.Drawing.Point(65, 24);
            this.lblNickname.Name = "lblNickname";
            this.lblNickname.Size = new System.Drawing.Size(147, 15);
            this.lblNickname.TabIndex = 6;
            this.lblNickname.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.lblNickname.MouseEnter += new System.EventHandler(this.uscFriendShow_MouseEnter);
            this.lblNickname.MouseLeave += new System.EventHandler(this.uscFriendShow_MouseLeave);
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = global::WinFrmTalk.Properties.Resources.CloseZh;
            this.pictureBox1.Location = new System.Drawing.Point(218, 24);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(15, 15);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pictureBox1.TabIndex = 8;
            this.pictureBox1.TabStop = false;
            this.pictureBox1.Click += new System.EventHandler(this.pictureBox1_Click);
            this.pictureBox1.MouseEnter += new System.EventHandler(this.pictureBox1_MouseEnter);
            this.pictureBox1.MouseLeave += new System.EventHandler(this.pictureBox1_MouseLeave);
            // 
            // picHead
            // 
            this.picHead.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.picHead.isDrawRound = true;
            this.picHead.Location = new System.Drawing.Point(15, 14);
            this.picHead.Name = "picHead";
            this.picHead.Size = new System.Drawing.Size(35, 35);
            this.picHead.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
            this.picHead.TabIndex = 24;
            this.picHead.TabStop = false;
            // 
            // UserSelectItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Controls.Add(this.picHead);
            this.Controls.Add(this.pictureBox1);
            this.Controls.Add(this.lblNickname);
            this.Name = "UserSelectItem";
            this.Size = new System.Drawing.Size(255, 60);
            this.Load += new System.EventHandler(this.USEFriendClose_Load);
            this.MouseEnter += new System.EventHandler(this.uscFriendShow_MouseEnter);
            this.MouseLeave += new System.EventHandler(this.uscFriendShow_MouseLeave);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picHead)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Label lblNickname;
        private System.Windows.Forms.PictureBox pictureBox1;
        private RoundPicBox picHead;
    }
}
