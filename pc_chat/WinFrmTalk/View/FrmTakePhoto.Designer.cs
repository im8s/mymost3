namespace WinFrmTalk.View
{
    partial class FrmTakePhoto
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
            this.btnsurue = new System.Windows.Forms.Button();
            this.picimage = new System.Windows.Forms.PictureBox();
            this.btnreturntophoto = new System.Windows.Forms.Button();
            this.btnsave = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.picimage)).BeginInit();
            this.SuspendLayout();
            // 
            // photo
            // 
            this.photo.BackColor = System.Drawing.Color.White;
            this.photo.Dock = System.Windows.Forms.DockStyle.Fill;
            this.photo.Location = new System.Drawing.Point(4, 28);
            this.photo.Name = "photo";
            this.photo.Size = new System.Drawing.Size(801, 451);
            this.photo.TabIndex = 10;
            this.photo.Text = "的收费方式";
            this.photo.VideoSource = null;
            // 
            // btnsurue
            // 
            this.btnsurue.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.btnsurue.BackColor = System.Drawing.Color.Transparent;
            this.btnsurue.BackgroundImage = global::WinFrmTalk.Properties.Resources.photostart;
            this.btnsurue.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnsurue.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.btnsurue.FlatAppearance.BorderSize = 0;
            this.btnsurue.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnsurue.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnsurue.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnsurue.Location = new System.Drawing.Point(358, 372);
            this.btnsurue.Name = "btnsurue";
            this.btnsurue.Size = new System.Drawing.Size(60, 60);
            this.btnsurue.TabIndex = 11;
            this.btnsurue.UseVisualStyleBackColor = false;
            this.btnsurue.Click += new System.EventHandler(this.btnsurue_Click);
            // 
            // picimage
            // 
            this.picimage.BackColor = System.Drawing.Color.Transparent;
            this.picimage.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.picimage.Dock = System.Windows.Forms.DockStyle.Fill;
            this.picimage.Location = new System.Drawing.Point(4, 28);
            this.picimage.Name = "picimage";
            this.picimage.Size = new System.Drawing.Size(801, 451);
            this.picimage.TabIndex = 16;
            this.picimage.TabStop = false;
            this.picimage.Visible = false;
            // 
            // btnreturntophoto
            // 
            this.btnreturntophoto.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.btnreturntophoto.BackColor = System.Drawing.Color.Transparent;
            this.btnreturntophoto.BackgroundImage = global::WinFrmTalk.Properties.Resources.photoReten;
            this.btnreturntophoto.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnreturntophoto.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.btnreturntophoto.FlatAppearance.BorderSize = 0;
            this.btnreturntophoto.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnreturntophoto.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnreturntophoto.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnreturntophoto.Location = new System.Drawing.Point(220, 387);
            this.btnreturntophoto.Name = "btnreturntophoto";
            this.btnreturntophoto.Size = new System.Drawing.Size(30, 30);
            this.btnreturntophoto.TabIndex = 17;
            this.btnreturntophoto.Tag = "关闭";
            this.btnreturntophoto.UseVisualStyleBackColor = false;
            this.btnreturntophoto.Click += new System.EventHandler(this.btnreturntophoto_Click);
            // 
            // btnsave
            // 
            this.btnsave.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.btnsave.BackColor = System.Drawing.Color.Transparent;
            this.btnsave.BackgroundImage = global::WinFrmTalk.Properties.Resources.photoSend;
            this.btnsave.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnsave.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.btnsave.FlatAppearance.BorderSize = 0;
            this.btnsave.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnsave.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnsave.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnsave.Location = new System.Drawing.Point(525, 387);
            this.btnsave.Name = "btnsave";
            this.btnsave.Size = new System.Drawing.Size(30, 30);
            this.btnsave.TabIndex = 18;
            this.btnsave.UseVisualStyleBackColor = false;
            this.btnsave.Visible = false;
            this.btnsave.Click += new System.EventHandler(this.btnsave_Click);
            // 
            // FrmTakePhoto
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(809, 483);
            this.Controls.Add(this.btnsave);
            this.Controls.Add(this.btnreturntophoto);
            this.Controls.Add(this.btnsurue);
            this.Controls.Add(this.photo);
            this.Controls.Add(this.picimage);
            this.MaximizeBox = false;
            this.Name = "FrmTakePhoto";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "拍照";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmTakePhoto_FormClosed);
            this.Load += new System.EventHandler(this.FrmTakePhoto_Load);
            ((System.ComponentModel.ISupportInitialize)(this.picimage)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private AForge.Controls.VideoSourcePlayer photo;
        private System.Windows.Forms.Button btnsurue;
        private System.Windows.Forms.PictureBox picimage;
        private System.Windows.Forms.Button btnreturntophoto;
        private System.Windows.Forms.Button btnsave;
    }
}