namespace WinFrmTalk.View
{
    partial class FrmControl
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
            this.palCountry = new WinFrmTalk.MyTabLayoutPanel();
            this.SuspendLayout();
            // 
            // palCountry
            // 
            this.palCountry.BackColor = System.Drawing.Color.White;
            this.palCountry.Dock = System.Windows.Forms.DockStyle.Fill;
            this.palCountry.Location = new System.Drawing.Point(0, 0);
            this.palCountry.Name = "palCountry";
            this.palCountry.Size = new System.Drawing.Size(331, 781);
            this.palCountry.TabIndex = 0;
            this.palCountry.v_scale = 30;
            // 
            // FrmControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(331, 781);
            this.Controls.Add(this.palCountry);
            this.Name = "FrmControl";
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "FrmControl";
            this.ResumeLayout(false);

        }

        #endregion

        private MyTabLayoutPanel palCountry;
    }
}