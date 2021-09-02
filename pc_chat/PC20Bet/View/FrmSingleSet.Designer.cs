namespace WinFrmTalk.View
{
    partial class FrmSingleSet
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
            this.useSingleSet1 = new WinFrmTalk.Controls.CustomControls.USESingleSet();
            this.SuspendLayout();
            // 
            // useSingleSet1
            // 
            this.useSingleSet1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.useSingleSet1.Location = new System.Drawing.Point(0, 0);
            this.useSingleSet1.Margin = new System.Windows.Forms.Padding(0);
            this.useSingleSet1.Name = "useSingleSet1";
            this.useSingleSet1.Nickname = "昵称";
            this.useSingleSet1.Remarks = "备注";
            this.useSingleSet1.Size = new System.Drawing.Size(250, 578);
            this.useSingleSet1.TabIndex = 0;
            // 
            // FrmSingleSet
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(250, 578);
            this.Controls.Add(this.useSingleSet1);
            this.Name = "FrmSingleSet";
            this.ShowInTaskbar = false;
            this.Text = "FrmSingleSet";
            this.Load += new System.EventHandler(this.FrmSingleSet_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private Controls.CustomControls.USESingleSet useSingleSet1;
    }
}