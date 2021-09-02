namespace WinFrmTalk.View
{
    partial class FrmRedpReplay
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
            this.txtthanks = new System.Windows.Forms.TextBox();
            this.btnsure = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(125, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(29, 12);
            this.label1.TabIndex = 0;
            this.label1.Text = "回复";
            // 
            // txtthanks
            // 
            this.txtthanks.Location = new System.Drawing.Point(31, 34);
            this.txtthanks.MaxLength = 10;
            this.txtthanks.Multiline = true;
            this.txtthanks.Name = "txtthanks";
            this.txtthanks.Size = new System.Drawing.Size(231, 28);
            this.txtthanks.TabIndex = 1;
            // 
            // btnsure
            // 
            this.btnsure.FlatAppearance.BorderSize = 0;
            this.btnsure.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnsure.Location = new System.Drawing.Point(31, 68);
            this.btnsure.Name = "btnsure";
            this.btnsure.Size = new System.Drawing.Size(231, 25);
            this.btnsure.TabIndex = 2;
            this.btnsure.Text = "确定";
            this.btnsure.UseVisualStyleBackColor = true;
            this.btnsure.Click += new System.EventHandler(this.btnsure_Click);
            // 
            // FrmRedpReplay
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(296, 105);
            this.Controls.Add(this.btnsure);
            this.Controls.Add(this.txtthanks);
            this.Controls.Add(this.label1);
            this.Name = "FrmRedpReplay";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnsure;
        public System.Windows.Forms.TextBox txtthanks;
    }
}