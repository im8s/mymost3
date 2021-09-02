namespace WinFrmTalk.View
{
    partial class Frmreceivemony
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
            this.panel1 = new System.Windows.Forms.Panel();
            this.lblreplay = new System.Windows.Forms.Label();
            this.lab_text = new System.Windows.Forms.Label();
            this.lab_fromname = new System.Windows.Forms.Label();
            this.lab_totalaccount = new System.Windows.Forms.Label();
            this.pic_head = new WinFrmTalk.RoundPicBox();
            this.lab_finishcount = new System.Windows.Forms.Label();
            this.receiveinfopal = new TestListView.XListView();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).BeginInit();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.Transparent;
            this.panel1.BackgroundImage = global::WinFrmTalk.Properties.Resources.ic_redpacked_head;
            this.panel1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.panel1.Controls.Add(this.lblreplay);
            this.panel1.Controls.Add(this.lab_text);
            this.panel1.Controls.Add(this.lab_fromname);
            this.panel1.Controls.Add(this.lab_totalaccount);
            this.panel1.Controls.Add(this.pic_head);
            this.panel1.Controls.Add(this.lab_finishcount);
            this.panel1.Location = new System.Drawing.Point(0, -1);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(309, 181);
            this.panel1.TabIndex = 6;
            // 
            // lblreplay
            // 
            this.lblreplay.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblreplay.ForeColor = System.Drawing.Color.White;
            this.lblreplay.Location = new System.Drawing.Point(22, 115);
            this.lblreplay.Name = "lblreplay";
            this.lblreplay.Size = new System.Drawing.Size(257, 17);
            this.lblreplay.TabIndex = 5;
            this.lblreplay.Text = "回复一句话表示感谢吧";
            this.lblreplay.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblreplay.Visible = false;
            this.lblreplay.Click += new System.EventHandler(this.lblreplay_Click);
            // 
            // lab_text
            // 
            this.lab_text.AutoSize = true;
            this.lab_text.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_text.ForeColor = System.Drawing.Color.White;
            this.lab_text.Location = new System.Drawing.Point(90, 88);
            this.lab_text.Name = "lab_text";
            this.lab_text.Size = new System.Drawing.Size(43, 17);
            this.lab_text.TabIndex = 4;
            this.lab_text.Text = "label4";
            // 
            // lab_fromname
            // 
            this.lab_fromname.AutoSize = true;
            this.lab_fromname.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_fromname.ForeColor = System.Drawing.Color.White;
            this.lab_fromname.Location = new System.Drawing.Point(89, 60);
            this.lab_fromname.Name = "lab_fromname";
            this.lab_fromname.Size = new System.Drawing.Size(55, 21);
            this.lab_fromname.TabIndex = 3;
            this.lab_fromname.Text = "label3";
            // 
            // lab_totalaccount
            // 
            this.lab_totalaccount.AutoSize = true;
            this.lab_totalaccount.Font = new System.Drawing.Font("微软雅黑", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_totalaccount.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(220)))), ((int)(((byte)(115)))));
            this.lab_totalaccount.Location = new System.Drawing.Point(87, 31);
            this.lab_totalaccount.Name = "lab_totalaccount";
            this.lab_totalaccount.Size = new System.Drawing.Size(67, 25);
            this.lab_totalaccount.TabIndex = 2;
            this.lab_totalaccount.Text = "label2";
            // 
            // pic_head
            // 
            this.pic_head.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.pic_head.isDrawRound = true;
            this.pic_head.Location = new System.Drawing.Point(22, 31);
            this.pic_head.Name = "pic_head";
            this.pic_head.Size = new System.Drawing.Size(54, 57);
            this.pic_head.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pic_head.TabIndex = 1;
            this.pic_head.TabStop = false;
            // 
            // lab_finishcount
            // 
            this.lab_finishcount.AutoSize = true;
            this.lab_finishcount.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_finishcount.Location = new System.Drawing.Point(19, 155);
            this.lab_finishcount.Name = "lab_finishcount";
            this.lab_finishcount.Size = new System.Drawing.Size(44, 17);
            this.lab_finishcount.TabIndex = 0;
            this.lab_finishcount.Text = "已领取";
            // 
            // receiveinfopal
            // 
            this.receiveinfopal.BackColor = System.Drawing.Color.White;
            this.receiveinfopal.Location = new System.Drawing.Point(2, 186);
            this.receiveinfopal.Name = "receiveinfopal";
            this.receiveinfopal.ScrollBarWidth = 10;
            this.receiveinfopal.Size = new System.Drawing.Size(307, 265);
            this.receiveinfopal.TabIndex = 7;
            // 
            // Frmreceivemony
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(308, 450);
            this.Controls.Add(this.receiveinfopal);
            this.Controls.Add(this.panel1);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Frmreceivemony";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "领取详情";
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pic_head)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Label lab_finishcount;
        private TestListView.XListView receiveinfopal;
        private System.Windows.Forms.Label lab_fromname;
        private System.Windows.Forms.Label lab_totalaccount;
        public RoundPicBox pic_head;
        public System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label lblreplay;
        private System.Windows.Forms.Label lab_text;
    }
}