namespace WinFrmTalk.Controls
{
    partial class FriendItem
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
            this.pic_head = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).BeginInit();
            this.SuspendLayout();
            // 
            // lab_name
            // 
            this.lab_name.AutoSize = true;
            this.lab_name.BackColor = System.Drawing.Color.Transparent;
            this.lab_name.Font = new System.Drawing.Font("微软雅黑", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_name.Location = new System.Drawing.Point(50, 18);
            this.lab_name.Name = "lab_name";
            this.lab_name.Size = new System.Drawing.Size(48, 20);
            this.lab_name.TabIndex = 1;
            this.lab_name.Text = "NULL";
            this.lab_name.UseMnemonic = false;
            this.lab_name.TextChanged += new System.EventHandler(this.lab_name_TextChanged);
            // 
            // pic_head
            // 
            this.pic_head.isDrawRound = true;
            this.pic_head.Location = new System.Drawing.Point(6, 8);
            this.pic_head.Name = "pic_head";
            this.pic_head.Size = new System.Drawing.Size(35, 35);
            this.pic_head.TabIndex = 0;
            this.pic_head.TabStop = false;
            // 
            // FriendItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Transparent;
            this.Controls.Add(this.pic_head);
            this.Controls.Add(this.lab_name);
            this.Margin = new System.Windows.Forms.Padding(0);
            this.Name = "FriendItem";
            this.Size = new System.Drawing.Size(240, 50);
            this.MouseEnter += new System.EventHandler(this.FriendItem_MouseEnter);
            this.MouseLeave += new System.EventHandler(this.FriendItem_MouseLeave);
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        public System.Windows.Forms.Label lab_name;
        public RoundPicBox pic_head;
    }
}
