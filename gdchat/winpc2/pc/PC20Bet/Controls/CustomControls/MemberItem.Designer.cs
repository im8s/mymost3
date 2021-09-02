namespace WinFrmTalk.Controls.CustomControls
{
    partial class MemberItem
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
            this.chb = new CCWin.SkinControl.SkinCheckBox();
            this.pic_head = new CCWin.SkinControl.SkinPictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).BeginInit();
            this.SuspendLayout();
            // 
            // lab_name
            // 
            this.lab_name.AutoSize = true;
            this.lab_name.BackColor = System.Drawing.Color.Transparent;
            this.lab_name.Font = new System.Drawing.Font("微软雅黑", 11.25F);
            this.lab_name.Location = new System.Drawing.Point(69, 23);
            this.lab_name.Name = "lab_name";
            this.lab_name.Size = new System.Drawing.Size(39, 20);
            this.lab_name.TabIndex = 6;
            this.lab_name.Text = "张三";
            this.lab_name.UseMnemonic = false;
            // 
            // chb
            // 
            this.chb.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.chb.BackColor = System.Drawing.Color.Transparent;
            this.chb.BaseColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.chb.ControlState = CCWin.SkinClass.ControlState.Normal;
            this.chb.DefaultCheckButtonWidth = 19;
            this.chb.DownBack = null;
            this.chb.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.chb.Location = new System.Drawing.Point(224, 20);
            this.chb.MouseBack = global::WinFrmTalk.Properties.Resources.ic_radio_normal;
            this.chb.Name = "chb";
            this.chb.NormlBack = global::WinFrmTalk.Properties.Resources.ic_radio_normal;
            this.chb.SelectedDownBack = global::WinFrmTalk.Properties.Resources.ic_radio_check;
            this.chb.SelectedMouseBack = global::WinFrmTalk.Properties.Resources.ic_radio_check;
            this.chb.SelectedNormlBack = global::WinFrmTalk.Properties.Resources.ic_radio_check;
            this.chb.Size = new System.Drawing.Size(21, 21);
            this.chb.TabIndex = 5;
            this.chb.UseVisualStyleBackColor = false;
            // 
            // pic_head
            // 
            this.pic_head.BackColor = System.Drawing.Color.Transparent;
            this.pic_head.BackgroundImage = global::WinFrmTalk.Properties.Resources.avatar_default;
            this.pic_head.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.pic_head.Location = new System.Drawing.Point(24, 13);
            this.pic_head.Name = "pic_head";
            this.pic_head.Size = new System.Drawing.Size(35, 35);
            this.pic_head.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pic_head.TabIndex = 4;
            this.pic_head.TabStop = false;
            // 
            // MemberItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.Controls.Add(this.lab_name);
            this.Controls.Add(this.chb);
            this.Controls.Add(this.pic_head);
            this.Name = "MemberItem";
            this.Size = new System.Drawing.Size(270, 60);
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lab_name;
        public CCWin.SkinControl.SkinCheckBox chb;
        public CCWin.SkinControl.SkinPictureBox pic_head;
    }
}
