namespace WinFrmTalk.View
{
    partial class FrmLiveStreaming
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
            this.photo = new AForge.Controls.VideoSourcePlayer();
            this.SuspendLayout();
            // 
            // photo
            // 
            this.photo.Dock = System.Windows.Forms.DockStyle.Fill;
            this.photo.Location = new System.Drawing.Point(4, 28);
            this.photo.Name = "photo";
            this.photo.Size = new System.Drawing.Size(792, 418);
            this.photo.TabIndex = 12;
            this.photo.Text = "的收费方式";
            this.photo.VideoSource = null;
            // 
            // FrmLiveStreaming
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.photo);
            this.Name = "FrmLiveStreaming";
            this.Text = "";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmLiveStreaming_FormClosed);
            this.Load += new System.EventHandler(this.FrmLiveStreaming_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private AForge.Controls.VideoSourcePlayer photo;
    }
}