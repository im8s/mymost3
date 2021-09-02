namespace WinFrmTalk.View
{
    partial class FrmBrowser
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmBrowser));
            this.timer = new System.Windows.Forms.Timer(this.components);
            this.progressBrows = new System.Windows.Forms.ProgressBar();
            this.pboxcollect = new System.Windows.Forms.PictureBox();
            this.pboxZhuang = new System.Windows.Forms.PictureBox();
            this.pboxOpen = new System.Windows.Forms.PictureBox();
            this.pboxBack = new System.Windows.Forms.PictureBox();
            this.pboxCopy = new System.Windows.Forms.PictureBox();
            this.pboxrefresh = new System.Windows.Forms.PictureBox();
            this.panel1 = new System.Windows.Forms.Panel();
            this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.pboxcollect)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxZhuang)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxOpen)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxBack)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxCopy)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxrefresh)).BeginInit();
            this.SuspendLayout();
            // 
            // timer
            // 
            this.timer.Interval = 10;
            this.timer.Tick += new System.EventHandler(this.timer_Tick);
            // 
            // progressBrows
            // 
            this.progressBrows.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.progressBrows.Location = new System.Drawing.Point(1, 58);
            this.progressBrows.Name = "progressBrows";
            this.progressBrows.Size = new System.Drawing.Size(803, 2);
            this.progressBrows.TabIndex = 6;
            // 
            // pboxcollect
            // 
            this.pboxcollect.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.pboxcollect.Image = ((System.Drawing.Image)(resources.GetObject("pboxcollect.Image")));
            this.pboxcollect.Location = new System.Drawing.Point(745, 29);
            this.pboxcollect.Name = "pboxcollect";
            this.pboxcollect.Size = new System.Drawing.Size(27, 24);
            this.pboxcollect.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxcollect.TabIndex = 18;
            this.pboxcollect.TabStop = false;
            this.pboxcollect.Click += new System.EventHandler(this.pboxcollect_Click);
            this.pboxcollect.MouseEnter += new System.EventHandler(this.pboxcollect_MouseEnter);
            // 
            // pboxZhuang
            // 
            this.pboxZhuang.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.pboxZhuang.Image = ((System.Drawing.Image)(resources.GetObject("pboxZhuang.Image")));
            this.pboxZhuang.Location = new System.Drawing.Point(697, 29);
            this.pboxZhuang.Name = "pboxZhuang";
            this.pboxZhuang.Size = new System.Drawing.Size(27, 24);
            this.pboxZhuang.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxZhuang.TabIndex = 17;
            this.pboxZhuang.TabStop = false;
            this.pboxZhuang.Click += new System.EventHandler(this.pboxZhuang_Click);
            this.pboxZhuang.MouseEnter += new System.EventHandler(this.pboxZhuang_MouseEnter);
            // 
            // pboxOpen
            // 
            this.pboxOpen.Image = ((System.Drawing.Image)(resources.GetObject("pboxOpen.Image")));
            this.pboxOpen.Location = new System.Drawing.Point(181, 29);
            this.pboxOpen.Name = "pboxOpen";
            this.pboxOpen.Size = new System.Drawing.Size(27, 24);
            this.pboxOpen.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxOpen.TabIndex = 7;
            this.pboxOpen.TabStop = false;
            this.pboxOpen.Click += new System.EventHandler(this.pboxOpen_Click);
            this.pboxOpen.MouseEnter += new System.EventHandler(this.pboxOpen_MouseEnter);
            // 
            // pboxBack
            // 
            this.pboxBack.Image = ((System.Drawing.Image)(resources.GetObject("pboxBack.Image")));
            this.pboxBack.Location = new System.Drawing.Point(34, 29);
            this.pboxBack.Name = "pboxBack";
            this.pboxBack.Size = new System.Drawing.Size(27, 24);
            this.pboxBack.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxBack.TabIndex = 12;
            this.pboxBack.TabStop = false;
            this.pboxBack.Click += new System.EventHandler(this.pboxBack_Click_1);
            // 
            // pboxCopy
            // 
            this.pboxCopy.Image = ((System.Drawing.Image)(resources.GetObject("pboxCopy.Image")));
            this.pboxCopy.Location = new System.Drawing.Point(83, 29);
            this.pboxCopy.Name = "pboxCopy";
            this.pboxCopy.Size = new System.Drawing.Size(27, 24);
            this.pboxCopy.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxCopy.TabIndex = 15;
            this.pboxCopy.TabStop = false;
            this.pboxCopy.Click += new System.EventHandler(this.pboxCopy_Click);
            this.pboxCopy.MouseEnter += new System.EventHandler(this.pboxCopy_MouseEnter);
            // 
            // pboxrefresh
            // 
            this.pboxrefresh.Image = ((System.Drawing.Image)(resources.GetObject("pboxrefresh.Image")));
            this.pboxrefresh.Location = new System.Drawing.Point(132, 29);
            this.pboxrefresh.Name = "pboxrefresh";
            this.pboxrefresh.Size = new System.Drawing.Size(27, 24);
            this.pboxrefresh.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pboxrefresh.TabIndex = 14;
            this.pboxrefresh.TabStop = false;
            this.pboxrefresh.Click += new System.EventHandler(this.pboxrefresh_Click);
            this.pboxrefresh.MouseEnter += new System.EventHandler(this.pboxrefresh_MouseEnter);
            // 
            // panel1
            // 
            this.panel1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.panel1.Location = new System.Drawing.Point(1, 63);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(802, 543);
            this.panel1.TabIndex = 24;
            // 
            // FrmBrowser
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(803, 607);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.pboxcollect);
            this.Controls.Add(this.pboxZhuang);
            this.Controls.Add(this.pboxCopy);
            this.Controls.Add(this.pboxrefresh);
            this.Controls.Add(this.pboxBack);
            this.Controls.Add(this.pboxOpen);
            this.Controls.Add(this.progressBrows);
            this.MdiBackColor = System.Drawing.Color.AliceBlue;
            this.Name = "FrmBrowser";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmBrowser_FormClosed);
            this.Load += new System.EventHandler(this.FrmBrowser_Load);
            ((System.ComponentModel.ISupportInitialize)(this.pboxcollect)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxZhuang)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxOpen)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxBack)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxCopy)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pboxrefresh)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Timer timer;
        private System.Windows.Forms.ProgressBar progressBrows;
        private System.Windows.Forms.PictureBox pboxcollect;
        private System.Windows.Forms.PictureBox pboxZhuang;
        private System.Windows.Forms.PictureBox pboxOpen;
        private System.Windows.Forms.PictureBox pboxBack;
        private System.Windows.Forms.PictureBox pboxCopy;
        private System.Windows.Forms.PictureBox pboxrefresh;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.ToolTip toolTip1;
    }
}