namespace WinFrmTalk.View
{
    partial class FrmTransferReceive
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
            this.lab_received = new System.Windows.Forms.Label();
            this.lab_money = new System.Windows.Forms.Label();
            this.lab_transfertime = new System.Windows.Forms.Label();
            this.lab_Receivetime = new System.Windows.Forms.Label();
            this.pics = new System.Windows.Forms.PictureBox();
            this.btn_sure = new System.Windows.Forms.Button();
            this.lab_tips = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.pics)).BeginInit();
            this.SuspendLayout();
            // 
            // lab_received
            // 
            this.lab_received.Font = new System.Drawing.Font("微软雅黑", 15F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_received.Location = new System.Drawing.Point(17, 142);
            this.lab_received.Name = "lab_received";
            this.lab_received.Size = new System.Drawing.Size(267, 28);
            this.lab_received.TabIndex = 6;
            this.lab_received.Text = "已收钱";
            this.lab_received.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lab_money
            // 
            this.lab_money.Font = new System.Drawing.Font("微软雅黑", 26.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_money.Location = new System.Drawing.Point(12, 174);
            this.lab_money.Name = "lab_money";
            this.lab_money.Size = new System.Drawing.Size(276, 45);
            this.lab_money.TabIndex = 7;
            this.lab_money.Text = "￥22";
            this.lab_money.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lab_transfertime
            // 
            this.lab_transfertime.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_transfertime.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(185)))), ((int)(((byte)(183)))), ((int)(((byte)(192)))));
            this.lab_transfertime.Location = new System.Drawing.Point(12, 357);
            this.lab_transfertime.Name = "lab_transfertime";
            this.lab_transfertime.Size = new System.Drawing.Size(276, 17);
            this.lab_transfertime.TabIndex = 8;
            this.lab_transfertime.Text = "转账时间：";
            this.lab_transfertime.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lab_Receivetime
            // 
            this.lab_Receivetime.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_Receivetime.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(185)))), ((int)(((byte)(183)))), ((int)(((byte)(192)))));
            this.lab_Receivetime.Location = new System.Drawing.Point(18, 381);
            this.lab_Receivetime.Name = "lab_Receivetime";
            this.lab_Receivetime.Size = new System.Drawing.Size(265, 17);
            this.lab_Receivetime.TabIndex = 9;
            this.lab_Receivetime.Text = "收钱时间：";
            this.lab_Receivetime.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // pics
            // 
            this.pics.BackgroundImage = global::WinFrmTalk.Properties.Resources.ic_transfer_compt;
            this.pics.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.pics.Location = new System.Drawing.Point(112, 50);
            this.pics.Name = "pics";
            this.pics.Size = new System.Drawing.Size(77, 77);
            this.pics.TabIndex = 10;
            this.pics.TabStop = false;
            // 
            // btn_sure
            // 
            this.btn_sure.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.btn_sure.FlatAppearance.BorderSize = 0;
            this.btn_sure.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btn_sure.Font = new System.Drawing.Font("微软雅黑", 15F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btn_sure.ForeColor = System.Drawing.Color.White;
            this.btn_sure.Location = new System.Drawing.Point(60, 242);
            this.btn_sure.Name = "btn_sure";
            this.btn_sure.Size = new System.Drawing.Size(180, 40);
            this.btn_sure.TabIndex = 11;
            this.btn_sure.Text = "确认收钱";
            this.btn_sure.UseVisualStyleBackColor = false;
            this.btn_sure.Visible = false;
            // 
            // lab_tips
            // 
            this.lab_tips.BackColor = System.Drawing.Color.Transparent;
            this.lab_tips.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lab_tips.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(185)))), ((int)(((byte)(183)))), ((int)(((byte)(192)))));
            this.lab_tips.Location = new System.Drawing.Point(19, 305);
            this.lab_tips.Name = "lab_tips";
            this.lab_tips.Size = new System.Drawing.Size(263, 22);
            this.lab_tips.TabIndex = 12;
            this.lab_tips.Text = "1天内未确认，将退还给对方 ";
            this.lab_tips.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lab_tips.Visible = false;
            // 
            // FrmTransferReceive
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(300, 430);
            this.Controls.Add(this.lab_tips);
            this.Controls.Add(this.btn_sure);
            this.Controls.Add(this.pics);
            this.Controls.Add(this.lab_Receivetime);
            this.Controls.Add(this.lab_transfertime);
            this.Controls.Add(this.lab_money);
            this.Controls.Add(this.lab_received);
            this.Name = "FrmTransferReceive";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "转账";
            ((System.ComponentModel.ISupportInitialize)(this.pics)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label lab_received;
        private System.Windows.Forms.Label lab_money;
        private System.Windows.Forms.Label lab_Receivetime;
        private System.Windows.Forms.PictureBox pics;
        public System.Windows.Forms.Label lab_transfertime;
        private System.Windows.Forms.Button btn_sure;
        public System.Windows.Forms.Label lab_tips;
    }
}