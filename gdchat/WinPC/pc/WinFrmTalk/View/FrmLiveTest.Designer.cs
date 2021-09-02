namespace WinFrmTalk.View
{
    partial class FrmLiveTest
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
           
            this.SuspendLayout();
            // 
            // userLiveChat1
            // 
            this.userLiveChat1.BackColor = System.Drawing.Color.White;
            this.userLiveChat1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.userLiveChat1.Location = new System.Drawing.Point(4, 28);
            this.userLiveChat1.Name = "userLiveChat1";
            this.userLiveChat1.Size = new System.Drawing.Size(592, 608);
            this.userLiveChat1.TabIndex = 6;
            // 
            // FrmLiveTest
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(600, 640);
            this.Controls.Add(this.userLiveChat1);
            this.Name = "FrmLiveTest";
            this.Text = "FrmLiveTest";
            this.ResumeLayout(false);

        }

        #endregion

        public Controls.CustomControls.UserLiveChat userLiveChat1;
    }
}