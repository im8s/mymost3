namespace WinFrmTalk.View
{
    partial class FrmTipsEdite
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
            this.textEdite = new RichTextBoxLinks.RichTextBoxEx();
            this.btnsure = new LollipopButton();
            this.btnCancel = new LollipopButton();
            this.SuspendLayout();
            // 
            // textEdite
            // 
            this.textEdite.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.textEdite.DetectUrls = false;
            this.textEdite.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.textEdite.Location = new System.Drawing.Point(60, 60);
            this.textEdite.Name = "textEdite";
            this.textEdite.Size = new System.Drawing.Size(597, 490);
            this.textEdite.TabIndex = 6;
            this.textEdite.Text = "";
            this.textEdite.KeyDown += new System.Windows.Forms.KeyEventHandler(this.textEdite_KeyDown);
            // 
            // btnsure
            // 
            this.btnsure.BackColor = System.Drawing.Color.Transparent;
            this.btnsure.BGColor = "26,181,26";
            this.btnsure.Font = new System.Drawing.Font("微软雅黑", 9F);
            this.btnsure.FontColor = "#ffffff";
            this.btnsure.Location = new System.Drawing.Point(130, 565);
            this.btnsure.Name = "btnsure";
            this.btnsure.Size = new System.Drawing.Size(100, 38);
            this.btnsure.TabIndex = 8;
            this.btnsure.Text = "确定";
            this.btnsure.Click += new System.EventHandler(this.btnsure_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.BackColor = System.Drawing.Color.Transparent;
            this.btnCancel.BGColor = "26,181,26";
            this.btnCancel.Font = new System.Drawing.Font("微软雅黑", 9F);
            this.btnCancel.FontColor = "#ffffff";
            this.btnCancel.Location = new System.Drawing.Point(453, 565);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(100, 38);
            this.btnCancel.TabIndex = 14;
            this.btnCancel.Text = "取消";
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // FrmTipsEdite
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(697, 631);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnsure);
            this.Controls.Add(this.textEdite);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmTipsEdite";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "编辑";
            this.ResumeLayout(false);

        }

        #endregion

        private RichTextBoxLinks.RichTextBoxEx textEdite;
        private LollipopButton btnsure;
        private LollipopButton btnCancel;
    }
}