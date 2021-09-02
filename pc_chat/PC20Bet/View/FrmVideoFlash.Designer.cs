namespace WinFrmTalk.View
{
    partial class FrmVideoFlash
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmVideoFlash));
            this.panel1 = new System.Windows.Forms.Panel();
            this.musicBar1 = new WinFrmTalk.Controls.MusicBar();
            this.pboxStar = new System.Windows.Forms.PictureBox();
            this.pboxSound = new System.Windows.Forms.PictureBox();
            this.pboxStop = new System.Windows.Forms.PictureBox();
            this.lblStartTime = new System.Windows.Forms.Label();
            this.lblEndTime = new System.Windows.Forms.Label();
            this.tmrVideo = new System.Windows.Forms.Timer(this.components);
            this.panel3 = new System.Windows.Forms.Panel();
            this.pboxDown = new System.Windows.Forms.PictureBox();
            this.pboxColle = new System.Windows.Forms.PictureBox();
            this.pboxFile = new System.Windows.Forms.PictureBox();
            this.pboxZhuan = new System.Windows.Forms.PictureBox();
            this.pboxVideo = new System.Windows.Forms.PictureBox();
            this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pboxStar)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxSound)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxStop)).BeginInit();
            this.panel3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pboxDown)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxColle)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxFile)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxZhuan)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxVideo)).BeginInit();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.panel1.BackColor = System.Drawing.SystemColors.ActiveCaptionText;
            this.panel1.Controls.Add(this.musicBar1);
            this.panel1.Controls.Add(this.pboxStar);
            this.panel1.Controls.Add(this.pboxSound);
            this.panel1.Controls.Add(this.pboxStop);
            this.panel1.Controls.Add(this.lblStartTime);
            this.panel1.Controls.Add(this.lblEndTime);
            this.panel1.Location = new System.Drawing.Point(1, 461);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(557, 29);
            this.panel1.TabIndex = 10;
            // 
            // musicBar1
            // 
            this.musicBar1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
            this.musicBar1.BackColor = System.Drawing.Color.Transparent;
            this.musicBar1.BarWidth = 4;
            this.musicBar1.Location = new System.Drawing.Point(156, 0);
            this.musicBar1.MaxValue = 100D;
            this.musicBar1.Name = "musicBar1";
            this.musicBar1.Size = new System.Drawing.Size(309, 25);
            this.musicBar1.TabIndex = 25;
            this.musicBar1.Value = 0D;
            this.musicBar1.MouseClick += new System.Windows.Forms.MouseEventHandler(this.musicBar1_MouseClick);
            // 
            // pboxStar
            // 
            this.pboxStar.Image = ((System.Drawing.Image)(resources.GetObject("pboxStar.Image")));
            this.pboxStar.Location = new System.Drawing.Point(70, -2);
            this.pboxStar.Name = "pboxStar";
            this.pboxStar.Size = new System.Drawing.Size(28, 28);
            this.pboxStar.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxStar.TabIndex = 7;
            this.pboxStar.TabStop = false;
            this.pboxStar.Click += new System.EventHandler(this.pboxStar_Click);
            // 
            // pboxSound
            // 
            this.pboxSound.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.pboxSound.Image = ((System.Drawing.Image)(resources.GetObject("pboxSound.Image")));
            this.pboxSound.Location = new System.Drawing.Point(21, 1);
            this.pboxSound.Name = "pboxSound";
            this.pboxSound.Size = new System.Drawing.Size(32, 27);
            this.pboxSound.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxSound.TabIndex = 6;
            this.pboxSound.TabStop = false;
            this.pboxSound.Click += new System.EventHandler(this.pboxVoice_Click);
            // 
            // pboxStop
            // 
            this.pboxStop.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.pboxStop.Image = ((System.Drawing.Image)(resources.GetObject("pboxStop.Image")));
            this.pboxStop.Location = new System.Drawing.Point(513, 0);
            this.pboxStop.Name = "pboxStop";
            this.pboxStop.Size = new System.Drawing.Size(28, 28);
            this.pboxStop.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxStop.TabIndex = 5;
            this.pboxStop.TabStop = false;
            this.pboxStop.Visible = false;
            this.pboxStop.Click += new System.EventHandler(this.pboStop_Click);
            // 
            // lblStartTime
            // 
            this.lblStartTime.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.lblStartTime.AutoSize = true;
            this.lblStartTime.ForeColor = System.Drawing.Color.White;
            this.lblStartTime.Location = new System.Drawing.Point(115, 10);
            this.lblStartTime.Name = "lblStartTime";
            this.lblStartTime.Size = new System.Drawing.Size(35, 12);
            this.lblStartTime.TabIndex = 4;
            this.lblStartTime.Text = "00:00";
            this.lblStartTime.Visible = false;
            // 
            // lblEndTime
            // 
            this.lblEndTime.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.lblEndTime.AutoSize = true;
            this.lblEndTime.ForeColor = System.Drawing.Color.White;
            this.lblEndTime.Location = new System.Drawing.Point(472, 10);
            this.lblEndTime.Name = "lblEndTime";
            this.lblEndTime.Size = new System.Drawing.Size(35, 12);
            this.lblEndTime.TabIndex = 3;
            this.lblEndTime.Text = "00:00";
            // 
            // tmrVideo
            // 
            this.tmrVideo.Tick += new System.EventHandler(this.tmrVideo_Tick);
            // 
            // panel3
            // 
            this.panel3.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.panel3.Controls.Add(this.pboxDown);
            this.panel3.Controls.Add(this.pboxColle);
            this.panel3.Controls.Add(this.pboxFile);
            this.panel3.Controls.Add(this.pboxZhuan);
            this.panel3.Location = new System.Drawing.Point(1, 486);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(557, 36);
            this.panel3.TabIndex = 32;
            // 
            // pboxDown
            // 
            this.pboxDown.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.pboxDown.Image = ((System.Drawing.Image)(resources.GetObject("pboxDown.Image")));
            this.pboxDown.Location = new System.Drawing.Point(242, 3);
            this.pboxDown.Name = "pboxDown";
            this.pboxDown.Size = new System.Drawing.Size(32, 30);
            this.pboxDown.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxDown.TabIndex = 22;
            this.pboxDown.TabStop = false;
            this.pboxDown.Click += new System.EventHandler(this.pboxDown_Click_1);
            this.pboxDown.MouseEnter += new System.EventHandler(this.pboxDown_MouseEnter);
            // 
            // pboxColle
            // 
            this.pboxColle.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.pboxColle.Image = ((System.Drawing.Image)(resources.GetObject("pboxColle.Image")));
            this.pboxColle.Location = new System.Drawing.Point(346, 3);
            this.pboxColle.Name = "pboxColle";
            this.pboxColle.Size = new System.Drawing.Size(32, 30);
            this.pboxColle.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxColle.TabIndex = 24;
            this.pboxColle.TabStop = false;
            this.pboxColle.Click += new System.EventHandler(this.pboxColle_Click);
            this.pboxColle.MouseEnter += new System.EventHandler(this.pboxColle_MouseEnter);
            // 
            // pboxFile
            // 
            this.pboxFile.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.pboxFile.Image = ((System.Drawing.Image)(resources.GetObject("pboxFile.Image")));
            this.pboxFile.Location = new System.Drawing.Point(398, 3);
            this.pboxFile.Name = "pboxFile";
            this.pboxFile.Size = new System.Drawing.Size(32, 30);
            this.pboxFile.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxFile.TabIndex = 23;
            this.pboxFile.TabStop = false;
            this.pboxFile.Visible = false;
            this.pboxFile.Click += new System.EventHandler(this.pboxFile_Click_1);
            this.pboxFile.MouseEnter += new System.EventHandler(this.pboxFile_MouseEnter);
            // 
            // pboxZhuan
            // 
            this.pboxZhuan.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.pboxZhuan.Image = ((System.Drawing.Image)(resources.GetObject("pboxZhuan.Image")));
            this.pboxZhuan.Location = new System.Drawing.Point(294, 3);
            this.pboxZhuan.Name = "pboxZhuan";
            this.pboxZhuan.Size = new System.Drawing.Size(32, 30);
            this.pboxZhuan.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxZhuan.TabIndex = 21;
            this.pboxZhuan.TabStop = false;
            this.pboxZhuan.Click += new System.EventHandler(this.pboxZhuan_Click);
            this.pboxZhuan.MouseEnter += new System.EventHandler(this.pboxZhuan_MouseEnter);
            // 
            // pboxVideo
            // 
            this.pboxVideo.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.pboxVideo.BackColor = System.Drawing.Color.Black;
            this.pboxVideo.Location = new System.Drawing.Point(1, 33);
            this.pboxVideo.Name = "pboxVideo";
            this.pboxVideo.Size = new System.Drawing.Size(557, 428);
            this.pboxVideo.TabIndex = 38;
            this.pboxVideo.TabStop = false;
            // 
            // toolTip1
            // 
            this.toolTip1.Draw += new System.Windows.Forms.DrawToolTipEventHandler(this.toolTip1_Draw_1);
            // 
            // FrmVideoFlash
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Black;
            this.ClientSize = new System.Drawing.Size(560, 526);
            this.Controls.Add(this.pboxVideo);
            this.Controls.Add(this.panel3);
            this.Controls.Add(this.panel1);
            this.EffectBack = System.Drawing.Color.Black;
            this.Name = "FrmVideoFlash";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmVideoFlash_FormClosed);
            this.Load += new System.EventHandler(this.FrmVideoFlash_Load);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pboxStar)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxSound)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxStop)).EndInit();
            this.panel3.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.pboxDown)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxColle)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxFile)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxZhuan)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxVideo)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.PictureBox pboxSound;
        private System.Windows.Forms.PictureBox pboxStop;
        private System.Windows.Forms.Label lblStartTime;
        private System.Windows.Forms.Label lblEndTime;
        private System.Windows.Forms.PictureBox pboxStar;
        private System.Windows.Forms.Timer tmrVideo;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.PictureBox pboxDown;
        private System.Windows.Forms.PictureBox pboxColle;
        private System.Windows.Forms.PictureBox pboxFile;
        private System.Windows.Forms.PictureBox pboxZhuan;
        private System.Windows.Forms.PictureBox pboxVideo;
        private System.Windows.Forms.ToolTip toolTip1;
        private Controls.MusicBar musicBar1;
    }
}