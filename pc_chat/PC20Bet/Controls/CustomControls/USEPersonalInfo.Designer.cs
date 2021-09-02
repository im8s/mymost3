namespace WinFrmTalk.Controls.CustomControls
{
    partial class USEPersonalInfo
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
            this.button1 = new System.Windows.Forms.Button();
            this.lblAddress = new System.Windows.Forms.Label();
            this.blbBirthday = new System.Windows.Forms.Label();
            this.lblSex = new System.Windows.Forms.Label();
            this.lblnickname = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.picChangeControl1 = new WinFrmTalk.PicChangeControl();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(191)))), ((int)(((byte)(165)))));
            this.button1.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button1.Font = new System.Drawing.Font("宋体", 11F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.button1.ForeColor = System.Drawing.Color.White;
            this.button1.Location = new System.Drawing.Point(97, 421);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(140, 43);
            this.button1.TabIndex = 30;
            this.button1.Text = "修改";
            this.button1.UseVisualStyleBackColor = true;
            // 
            // lblAddress
            // 
            this.lblAddress.AutoSize = true;
            this.lblAddress.Location = new System.Drawing.Point(146, 325);
            this.lblAddress.Name = "lblAddress";
            this.lblAddress.Size = new System.Drawing.Size(29, 12);
            this.lblAddress.TabIndex = 28;
            this.lblAddress.Text = "null";
            // 
            // blbBirthday
            // 
            this.blbBirthday.AutoSize = true;
            this.blbBirthday.Location = new System.Drawing.Point(146, 282);
            this.blbBirthday.Name = "blbBirthday";
            this.blbBirthday.Size = new System.Drawing.Size(29, 12);
            this.blbBirthday.TabIndex = 29;
            this.blbBirthday.Text = "null";
            // 
            // lblSex
            // 
            this.lblSex.AutoSize = true;
            this.lblSex.Location = new System.Drawing.Point(146, 240);
            this.lblSex.Name = "lblSex";
            this.lblSex.Size = new System.Drawing.Size(29, 12);
            this.lblSex.TabIndex = 27;
            this.lblSex.Text = "null";
            // 
            // lblnickname
            // 
            this.lblnickname.AutoSize = true;
            this.lblnickname.Location = new System.Drawing.Point(146, 198);
            this.lblnickname.Name = "lblnickname";
            this.lblnickname.Size = new System.Drawing.Size(29, 12);
            this.lblnickname.TabIndex = 26;
            this.lblnickname.Text = "null";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.ForeColor = System.Drawing.Color.Gray;
            this.label4.Location = new System.Drawing.Point(94, 325);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(29, 12);
            this.label4.TabIndex = 24;
            this.label4.Text = "地址";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.ForeColor = System.Drawing.Color.Gray;
            this.label3.Location = new System.Drawing.Point(94, 282);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(29, 12);
            this.label3.TabIndex = 25;
            this.label3.Text = "生日";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.ForeColor = System.Drawing.Color.Gray;
            this.label2.Location = new System.Drawing.Point(94, 240);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(29, 12);
            this.label2.TabIndex = 23;
            this.label2.Text = "性别";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.ForeColor = System.Drawing.Color.Gray;
            this.label1.Location = new System.Drawing.Point(94, 198);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(29, 12);
            this.label1.TabIndex = 22;
            this.label1.Text = "昵称";
            // 
            // picChangeControl1
            // 
            this.picChangeControl1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.picChangeControl1.Location = new System.Drawing.Point(97, 32);
            this.picChangeControl1.Name = "picChangeControl1";
            this.picChangeControl1.PersonPic = null;
            this.picChangeControl1.Size = new System.Drawing.Size(117, 117);
            this.picChangeControl1.TabIndex = 31;
            this.picChangeControl1.UserName = null;
            // 
            // uscPersonalInfo
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.picChangeControl1);
            this.Controls.Add(this.button1);
            this.Controls.Add(this.lblAddress);
            this.Controls.Add(this.blbBirthday);
            this.Controls.Add(this.lblSex);
            this.Controls.Add(this.lblnickname);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Name = "uscPersonalInfo";
            this.Size = new System.Drawing.Size(324, 499);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Label lblAddress;
        private System.Windows.Forms.Label blbBirthday;
        private System.Windows.Forms.Label lblSex;
        private System.Windows.Forms.Label lblnickname;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private PicChangeControl picChangeControl1;
    }
}
