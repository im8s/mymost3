namespace WinFrmTalk.View
{
    partial class FrmTakeVideo
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
            this.btnstart = new System.Windows.Forms.Button();
            this.btnstop = new System.Windows.Forms.Button();
            this.lbltime = new System.Windows.Forms.Label();
            this.btnpuse = new System.Windows.Forms.Button();
            this.btnreturn = new System.Windows.Forms.Button();
            this.btnsend = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // photo
            // 
            this.photo.Dock = System.Windows.Forms.DockStyle.Fill;
            this.photo.Location = new System.Drawing.Point(4, 28);
            this.photo.Name = "photo";
            this.photo.Size = new System.Drawing.Size(801, 451);
            this.photo.TabIndex = 11;
            this.photo.Text = "的收费方式";
            this.photo.VideoSource = null;
            // 
            // btnstart
            // 
            this.btnstart.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.btnstart.BackgroundImage = global::WinFrmTalk.Properties.Resources.videoStart;
            this.btnstart.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnstart.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.btnstart.FlatAppearance.BorderSize = 0;
            this.btnstart.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnstart.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnstart.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnstart.Location = new System.Drawing.Point(371, 377);
            this.btnstart.Name = "btnstart";
            this.btnstart.Size = new System.Drawing.Size(60, 60);
            this.btnstart.TabIndex = 12;
            this.btnstart.UseVisualStyleBackColor = true;
            this.btnstart.Click += new System.EventHandler(this.btnstart_Click);
            // 
            // btnstop
            // 
            this.btnstop.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.btnstop.BackgroundImage = global::WinFrmTalk.Properties.Resources.videoStop;
            this.btnstop.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnstop.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.btnstop.FlatAppearance.BorderSize = 0;
            this.btnstop.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnstop.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnstop.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnstop.Location = new System.Drawing.Point(371, 377);
            this.btnstop.Name = "btnstop";
            this.btnstop.Size = new System.Drawing.Size(60, 60);
            this.btnstop.TabIndex = 13;
            this.btnstop.UseVisualStyleBackColor = true;
            this.btnstop.Visible = false;
            this.btnstop.Click += new System.EventHandler(this.btnstop_Click);
            // 
            // lbltime
            // 
            this.lbltime.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.lbltime.AutoSize = true;
            this.lbltime.Location = new System.Drawing.Point(379, 353);
            this.lbltime.Name = "lbltime";
            this.lbltime.Size = new System.Drawing.Size(41, 12);
            this.lbltime.TabIndex = 19;
            this.lbltime.Text = "label1";
            this.lbltime.Visible = false;
            // 
            // btnpuse
            // 
            this.btnpuse.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.btnpuse.BackgroundImage = global::WinFrmTalk.Properties.Resources.videoSpuse;
            this.btnpuse.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnpuse.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.btnpuse.FlatAppearance.BorderSize = 0;
            this.btnpuse.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnpuse.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnpuse.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnpuse.Location = new System.Drawing.Point(510, 407);
            this.btnpuse.Name = "btnpuse";
            this.btnpuse.Size = new System.Drawing.Size(30, 30);
            this.btnpuse.TabIndex = 20;
            this.btnpuse.Tag = "暂停";
            this.btnpuse.UseVisualStyleBackColor = true;
            this.btnpuse.Visible = false;
            this.btnpuse.Click += new System.EventHandler(this.btnpuse_Click);
            // 
            // btnreturn
            // 
            this.btnreturn.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.btnreturn.BackgroundImage = global::WinFrmTalk.Properties.Resources.photoReten;
            this.btnreturn.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnreturn.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.btnreturn.FlatAppearance.BorderSize = 0;
            this.btnreturn.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnreturn.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnreturn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnreturn.Location = new System.Drawing.Point(256, 407);
            this.btnreturn.Name = "btnreturn";
            this.btnreturn.Size = new System.Drawing.Size(30, 30);
            this.btnreturn.TabIndex = 26;
            this.btnreturn.UseVisualStyleBackColor = true;
            this.btnreturn.Click += new System.EventHandler(this.btnreturn_Click);
            // 
            // btnsend
            // 
            this.btnsend.BackgroundImage = global::WinFrmTalk.Properties.Resources.photoSend;
            this.btnsend.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnsend.FlatAppearance.BorderSize = 0;
            this.btnsend.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnsend.Location = new System.Drawing.Point(510, 407);
            this.btnsend.Name = "btnsend";
            this.btnsend.Size = new System.Drawing.Size(30, 30);
            this.btnsend.TabIndex = 32;
            this.btnsend.UseVisualStyleBackColor = true;
            this.btnsend.Visible = false;
            this.btnsend.Click += new System.EventHandler(this.btnsend_Click);
            // 
            // FrmTakeVideo
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.BorderColor = System.Drawing.Color.Black;
            this.ClientSize = new System.Drawing.Size(809, 483);
            this.Controls.Add(this.btnsend);
            this.Controls.Add(this.btnreturn);
            this.Controls.Add(this.btnpuse);
            this.Controls.Add(this.lbltime);
            this.Controls.Add(this.btnstop);
            this.Controls.Add(this.btnstart);
            this.Controls.Add(this.photo);
            this.Name = "FrmTakeVideo";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "录像";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmTakeVideo_FormClosed);
            this.Load += new System.EventHandler(this.FrmTakeVideo_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private AForge.Controls.VideoSourcePlayer photo;
        private System.Windows.Forms.Button btnstart;
        private System.Windows.Forms.Button btnstop;
        private System.Windows.Forms.Label lbltime;
        private System.Windows.Forms.Button btnpuse;
        private System.Windows.Forms.Button btnreturn;
        private System.Windows.Forms.Button btnsend;
    }
}