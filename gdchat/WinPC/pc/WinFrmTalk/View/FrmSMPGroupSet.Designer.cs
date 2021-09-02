namespace WinFrmTalk.View
{
    partial class FrmSMPGroupSet
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
            this.useGroupSet1 = new WinFrmTalk.Controls.CustomControls.USEGroupSet();
            this.SuspendLayout();
            // 
            // useGroupSet1
            // 
            this.useGroupSet1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.useGroupSet1.Location = new System.Drawing.Point(0, 0);
            this.useGroupSet1.Name = "useGroupSet1";
            this.useGroupSet1.Size = new System.Drawing.Size(250, 580);
            this.useGroupSet1.TabIndex = 0;
            // 
            // FrmSMPGroupSet
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(250, 580);
            this.Controls.Add(this.useGroupSet1);
            this.Name = "FrmSMPGroupSet";
            this.ShowInTaskbar = false;
            this.Text = "FrmSMPGroupSet";
            this.Deactivate += new System.EventHandler(this.FrmSMPGroupSet_Deactivate);
            this.Load += new System.EventHandler(this.FrmSMPGroupSet_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private Controls.CustomControls.USEGroupSet useGroupSet1;
    }
}