namespace WinFrmTalk.View
{
    partial class FrmopenRedpaper
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.label1 = new System.Windows.Forms.Label();
            this.lab_seeinfo = new System.Windows.Forms.Label();
            this.lab_tips = new System.Windows.Forms.Label();
            this.lab_money = new System.Windows.Forms.Label();
            this.lab_text = new System.Windows.Forms.Label();
            this.lab_froamname = new System.Windows.Forms.Label();
            this.pic_head = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).BeginInit();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.BackColor = System.Drawing.Color.Transparent;
            this.label1.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(220)))), ((int)(((byte)(115)))));
            this.label1.Location = new System.Drawing.Point(218, 248);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(23, 20);
            this.label1.TabIndex = 14;
            this.label1.Text = "元";
            // 
            // lab_seeinfo
            // 
            this.lab_seeinfo.BackColor = System.Drawing.Color.Transparent;
            this.lab_seeinfo.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.lab_seeinfo.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(220)))), ((int)(((byte)(115)))));
            this.lab_seeinfo.Location = new System.Drawing.Point(98, 373);
            this.lab_seeinfo.Name = "lab_seeinfo";
            this.lab_seeinfo.Size = new System.Drawing.Size(106, 21);
            this.lab_seeinfo.TabIndex = 13;
            this.lab_seeinfo.Text = "查看领取详情";
            this.lab_seeinfo.Click += new System.EventHandler(this.lab_seeinfo_Click);
            // 
            // lab_tips
            // 
            this.lab_tips.BackColor = System.Drawing.Color.Transparent;
            this.lab_tips.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_tips.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(149)))), ((int)(((byte)(39)))), ((int)(((byte)(51)))));
            this.lab_tips.Location = new System.Drawing.Point(61, 287);
            this.lab_tips.Name = "lab_tips";
            this.lab_tips.Size = new System.Drawing.Size(180, 21);
            this.lab_tips.TabIndex = 12;
            this.lab_tips.Text = "已存入手机端钱包余额";
            // 
            // lab_money
            // 
            this.lab_money.AutoSize = true;
            this.lab_money.BackColor = System.Drawing.Color.Transparent;
            this.lab_money.Font = new System.Drawing.Font("微软雅黑", 36F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_money.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(220)))), ((int)(((byte)(115)))));
            this.lab_money.Location = new System.Drawing.Point(90, 214);
            this.lab_money.Name = "lab_money";
            this.lab_money.Size = new System.Drawing.Size(123, 62);
            this.lab_money.TabIndex = 11;
            this.lab_money.Text = "0.08";
            this.lab_money.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lab_text
            // 
            this.lab_text.BackColor = System.Drawing.Color.Transparent;
            this.lab_text.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_text.ForeColor = System.Drawing.Color.White;
            this.lab_text.Location = new System.Drawing.Point(7, 192);
            this.lab_text.Name = "lab_text";
            this.lab_text.Size = new System.Drawing.Size(289, 17);
            this.lab_text.TabIndex = 10;
            this.lab_text.Text = "label2";
            this.lab_text.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lab_froamname
            // 
            this.lab_froamname.BackColor = System.Drawing.Color.Transparent;
            this.lab_froamname.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_froamname.ForeColor = System.Drawing.Color.White;
            this.lab_froamname.Location = new System.Drawing.Point(7, 154);
            this.lab_froamname.Name = "lab_froamname";
            this.lab_froamname.Size = new System.Drawing.Size(289, 21);
            this.lab_froamname.TabIndex = 7;
            this.lab_froamname.Text = "label1";
            this.lab_froamname.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // pic_head
            // 
            this.pic_head.BackColor = System.Drawing.Color.Transparent;
            this.pic_head.isDrawRound = true;
            this.pic_head.Location = new System.Drawing.Point(117, 56);
            this.pic_head.Name = "pic_head";
            this.pic_head.Size = new System.Drawing.Size(70, 70);
            this.pic_head.TabIndex = 6;
            this.pic_head.TabStop = false;
            // 
            // FrmopenRedpaper
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.BackgroundImage = global::WinFrmTalk.Properties.Resources.openredpaper;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.ClientSize = new System.Drawing.Size(303, 414);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.lab_seeinfo);
            this.Controls.Add(this.lab_tips);
            this.Controls.Add(this.lab_money);
            this.Controls.Add(this.lab_text);
            this.Controls.Add(this.lab_froamname);
            this.Controls.Add(this.pic_head);
            this.DoubleBuffered = true;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmopenRedpaper";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "领取红包";
            this.Load += new System.EventHandler(this.FrmopenRedpaper_Load);
            this.Resize += new System.EventHandler(this.FrmExpressionTab_Resize);
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private RoundPicBox pic_head;
        private System.Windows.Forms.Label lab_froamname;
        private System.Windows.Forms.Label lab_text;
        private System.Windows.Forms.Label lab_money;
        private System.Windows.Forms.Label lab_tips;
        private System.Windows.Forms.Label lab_seeinfo;
        private System.Windows.Forms.Label label1;
    }
}