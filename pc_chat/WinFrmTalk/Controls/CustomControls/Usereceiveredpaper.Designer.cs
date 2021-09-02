namespace WinFrmTalk.Controls.CustomControls
{
    partial class Usereceiveredpaper
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
            this.lab_name = new System.Windows.Forms.Label();
            this.lab_time = new System.Windows.Forms.Label();
            this.lab_money = new System.Windows.Forms.Label();
            this.lab_me = new System.Windows.Forms.Label();
            this.pictips = new System.Windows.Forms.PictureBox();
            this.lblThanks = new System.Windows.Forms.Label();
            this.pic_head = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.pictips)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).BeginInit();
            this.SuspendLayout();
            // 
            // lab_name
            // 
            this.lab_name.AutoSize = true;
            this.lab_name.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_name.Location = new System.Drawing.Point(82, 18);
            this.lab_name.Name = "lab_name";
            this.lab_name.Size = new System.Drawing.Size(50, 20);
            this.lab_name.TabIndex = 1;
            this.lab_name.Text = "label1";
            // 
            // lab_time
            // 
            this.lab_time.AutoSize = true;
            this.lab_time.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_time.ForeColor = System.Drawing.SystemColors.ControlDark;
            this.lab_time.Location = new System.Drawing.Point(83, 42);
            this.lab_time.Name = "lab_time";
            this.lab_time.Size = new System.Drawing.Size(43, 17);
            this.lab_time.TabIndex = 2;
            this.lab_time.Text = "label2";
            // 
            // lab_money
            // 
            this.lab_money.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lab_money.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_money.Location = new System.Drawing.Point(152, 17);
            this.lab_money.Name = "lab_money";
            this.lab_money.Size = new System.Drawing.Size(131, 17);
            this.lab_money.TabIndex = 3;
            this.lab_money.Text = "label3";
            this.lab_money.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // lab_me
            // 
            this.lab_me.AutoSize = true;
            this.lab_me.BackColor = System.Drawing.Color.Transparent;
            this.lab_me.ForeColor = System.Drawing.Color.White;
            this.lab_me.Location = new System.Drawing.Point(7, 4);
            this.lab_me.Name = "lab_me";
            this.lab_me.Size = new System.Drawing.Size(17, 12);
            this.lab_me.TabIndex = 6;
            this.lab_me.Text = "我";
            this.lab_me.Visible = false;
            // 
            // pictips
            // 
            this.pictips.BackColor = System.Drawing.Color.Transparent;
            this.pictips.BackgroundImage = global::WinFrmTalk.Properties.Resources.ic_readpack_me;
            this.pictips.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.pictips.Location = new System.Drawing.Point(0, 2);
            this.pictips.Name = "pictips";
            this.pictips.Size = new System.Drawing.Size(34, 14);
            this.pictips.TabIndex = 5;
            this.pictips.TabStop = false;
            this.pictips.Visible = false;
            this.pictips.Click += new System.EventHandler(this.pictureBox1_Click);
            // 
            // lblThanks
            // 
            this.lblThanks.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblThanks.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblThanks.Location = new System.Drawing.Point(149, 41);
            this.lblThanks.Name = "lblThanks";
            this.lblThanks.Size = new System.Drawing.Size(134, 17);
            this.lblThanks.TabIndex = 7;
            this.lblThanks.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // pic_head
            // 
            this.pic_head.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.pic_head.isDrawRound = true;
            this.pic_head.Location = new System.Drawing.Point(27, 17);
            this.pic_head.Name = "pic_head";
            this.pic_head.Size = new System.Drawing.Size(42, 42);
            this.pic_head.TabIndex = 0;
            this.pic_head.TabStop = false;
            // 
            // Usereceiveredpaper
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Transparent;
            this.Controls.Add(this.lblThanks);
            this.Controls.Add(this.lab_me);
            this.Controls.Add(this.pictips);
            this.Controls.Add(this.lab_money);
            this.Controls.Add(this.lab_time);
            this.Controls.Add(this.lab_name);
            this.Controls.Add(this.pic_head);
            this.Name = "Usereceiveredpaper";
            this.Size = new System.Drawing.Size(286, 67);
            ((System.ComponentModel.ISupportInitialize)(this.pictips)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        public System.Windows.Forms.Label lab_money;
        public System.Windows.Forms.Label lab_name;
        public System.Windows.Forms.Label lab_time;
        public System.Windows.Forms.PictureBox pictips;
        public System.Windows.Forms.Label lab_me;
        public RoundPicBox pic_head;
        public System.Windows.Forms.Label lblThanks;
    }
}
