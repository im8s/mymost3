using System;

namespace WinFrmTalk
{
    partial class FrmBetMain
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmBetMain));
            this.axBetWidget1 = new AxBetApp_ocxLib.AxBetWidget();
            ((System.ComponentModel.ISupportInitialize)(this.axBetWidget1)).BeginInit();
            this.SuspendLayout();
            // 
            // axBetWidget1
            // 
            this.axBetWidget1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.axBetWidget1.Enabled = true;
            this.axBetWidget1.Location = new System.Drawing.Point(0, 0);
            this.axBetWidget1.Name = "axBetWidget1";
            this.axBetWidget1.OcxState = ((System.Windows.Forms.AxHost.State)(resources.GetObject("axBetWidget1.OcxState")));
            this.axBetWidget1.Size = new System.Drawing.Size(1374, 802);
            this.axBetWidget1.TabIndex = 0;
            // 
            // FrmBetMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1374, 790);
            this.Controls.Add(this.axBetWidget1);
            this.DoubleBuffered = true;
            this.Name = "FrmBetMain";
            this.Text = "PC28猜彩娱乐";
            ((System.ComponentModel.ISupportInitialize)(this.axBetWidget1)).EndInit();
            this.ResumeLayout(false);

        }
        
        private FrmLogin frmLogin;

        #endregion

        private AxBetApp_ocxLib.AxBetWidget axBetWidget1;
    }
}