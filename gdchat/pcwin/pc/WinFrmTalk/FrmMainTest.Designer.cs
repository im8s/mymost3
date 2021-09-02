namespace WinFrmTalk
{
    partial class FrmMainTest
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
            this.sendMsgPanel1 = new WinFrmTalk.Controls.CustomControls.SendMsgPanel();
            this.btnSetFd = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // sendMsgPanel1
            // 
            this.sendMsgPanel1.Location = new System.Drawing.Point(140, 1);
            this.sendMsgPanel1.Name = "sendMsgPanel1";
            this.sendMsgPanel1.Size = new System.Drawing.Size(695, 583);
            this.sendMsgPanel1.TabIndex = 0;
            // 
            // btnSetFd
            // 
            this.btnSetFd.Location = new System.Drawing.Point(29, 96);
            this.btnSetFd.Name = "btnSetFd";
            this.btnSetFd.Size = new System.Drawing.Size(75, 23);
            this.btnSetFd.TabIndex = 1;
            this.btnSetFd.Text = "切换好友";
            this.btnSetFd.UseVisualStyleBackColor = true;
            this.btnSetFd.Click += new System.EventHandler(this.btnSetFd_Click);
            // 
            // FrmMainTest
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(834, 582);
            this.ControlBox = false;
            this.Controls.Add(this.btnSetFd);
            this.Controls.Add(this.sendMsgPanel1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "FrmMainTest";
            this.ShowDrawIcon = false;
            this.ShowIcon = false;
            this.Text = "";
            this.Load += new System.EventHandler(this.FrmMainTest_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private Controls.CustomControls.SendMsgPanel sendMsgPanel1;
        private System.Windows.Forms.Button btnSetFd;
    }
}