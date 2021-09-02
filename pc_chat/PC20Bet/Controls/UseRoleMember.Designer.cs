namespace WinFrmTalk.Controls
{
    partial class UseRoleMember
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(UseRoleMember));
            this.lab_name = new System.Windows.Forms.Label();
            this.lab_Role = new System.Windows.Forms.Label();
            this.lblLine = new System.Windows.Forms.Label();
            this.pic_head = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).BeginInit();
            this.SuspendLayout();
            // 
            // lab_name
            // 
            this.lab_name.AutoSize = true;
            this.lab_name.BackColor = System.Drawing.Color.Transparent;
            this.lab_name.Font = new System.Drawing.Font("微软雅黑", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_name.Location = new System.Drawing.Point(59, 7);
            this.lab_name.Name = "lab_name";
            this.lab_name.Size = new System.Drawing.Size(48, 20);
            this.lab_name.TabIndex = 3;
            this.lab_name.Text = "NULL";
            this.lab_name.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.lab_name.TextChanged += new System.EventHandler(this.lab_name_TextChanged);
            // 
            // lab_Role
            // 
            this.lab_Role.AutoSize = true;
            this.lab_Role.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_Role.ForeColor = System.Drawing.Color.White;
            this.lab_Role.Location = new System.Drawing.Point(59, 30);
            this.lab_Role.Name = "lab_Role";
            this.lab_Role.Size = new System.Drawing.Size(0, 17);
            this.lab_Role.TabIndex = 4;
            this.lab_Role.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // lblLine
            // 
            this.lblLine.BackColor = System.Drawing.Color.WhiteSmoke;
            this.lblLine.Location = new System.Drawing.Point(62, 0);
            this.lblLine.Name = "lblLine";
            this.lblLine.Size = new System.Drawing.Size(356, 1);
            this.lblLine.TabIndex = 17;
            this.lblLine.Text = "label1";
            // 
            // pic_head
            // 
            this.pic_head.BackColor = System.Drawing.Color.Transparent;
            this.pic_head.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("pic_head.BackgroundImage")));
            this.pic_head.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.pic_head.isDrawRound = true;
            this.pic_head.Location = new System.Drawing.Point(6, 7);
            this.pic_head.Name = "pic_head";
            this.pic_head.Size = new System.Drawing.Size(35, 35);
            this.pic_head.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pic_head.TabIndex = 2;
            this.pic_head.TabStop = false;
            this.pic_head.Click += new System.EventHandler(this.pic_head_Click);
            // 
            // UseRoleMember
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Transparent;
            this.Controls.Add(this.lblLine);
            this.Controls.Add(this.lab_Role);
            this.Controls.Add(this.lab_name);
            this.Controls.Add(this.pic_head);
            this.Name = "UseRoleMember";
            this.Size = new System.Drawing.Size(383, 50);
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lab_name;
        public System.Windows.Forms.Label lab_Role;
        public RoundPicBox pic_head;
        public System.Windows.Forms.Label lblLine;
    }
}
