namespace WinFrmTalk.Controls.CustomControls
{
    partial class AddGroupItem
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
            this.btnAdd = new System.Windows.Forms.Button();
            this.lblNickName = new System.Windows.Forms.Label();
            this.lblDes = new System.Windows.Forms.Label();
            this.picHead = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.picHead)).BeginInit();
            this.SuspendLayout();
            // 
            // btnAdd
            // 
            this.btnAdd.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.btnAdd.FlatAppearance.BorderSize = 0;
            this.btnAdd.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnAdd.ForeColor = System.Drawing.Color.White;
            this.btnAdd.Location = new System.Drawing.Point(189, 24);
            this.btnAdd.Name = "btnAdd";
            this.btnAdd.Size = new System.Drawing.Size(64, 25);
            this.btnAdd.TabIndex = 9;
            this.btnAdd.Text = "加群";
            this.btnAdd.UseVisualStyleBackColor = false;
            this.btnAdd.MouseEnter += new System.EventHandler(this.btnAdd_MouseEnter);
            this.btnAdd.MouseLeave += new System.EventHandler(this.btnAdd_MouseLeave);
            // 
            // lblNickName
            // 
            this.lblNickName.AutoSize = true;
            this.lblNickName.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblNickName.Location = new System.Drawing.Point(60, 9);
            this.lblNickName.Name = "lblNickName";
            this.lblNickName.Size = new System.Drawing.Size(50, 20);
            this.lblNickName.TabIndex = 11;
            this.lblNickName.Text = "label1";
            // 
            // lblDes
            // 
            this.lblDes.AutoSize = true;
            this.lblDes.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblDes.Location = new System.Drawing.Point(61, 32);
            this.lblDes.Name = "lblDes";
            this.lblDes.Size = new System.Drawing.Size(43, 17);
            this.lblDes.TabIndex = 12;
            this.lblDes.Text = "label1";
            // 
            // picHead
            // 
            this.picHead.Image = global::WinFrmTalk.Properties.Resources.avatar_group;
            this.picHead.isDrawRound = true;
            this.picHead.Location = new System.Drawing.Point(6, 6);
            this.picHead.Name = "picHead";
            this.picHead.Size = new System.Drawing.Size(40, 40);
            this.picHead.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.picHead.TabIndex = 10;
            this.picHead.TabStop = false;
            // 
            // AddGroupItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.lblDes);
            this.Controls.Add(this.lblNickName);
            this.Controls.Add(this.picHead);
            this.Controls.Add(this.btnAdd);
            this.Name = "AddGroupItem";
            this.Size = new System.Drawing.Size(276, 57);
            this.MouseEnter += new System.EventHandler(this.AddGroupItem_MouseEnter);
            this.MouseLeave += new System.EventHandler(this.AddGroupItem_MouseLeave);
            ((System.ComponentModel.ISupportInitialize)(this.picHead)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        public System.Windows.Forms.Button btnAdd;
        private RoundPicBox picHead;
        public System.Windows.Forms.Label lblNickName;
        public System.Windows.Forms.Label lblDes;
    }
}
