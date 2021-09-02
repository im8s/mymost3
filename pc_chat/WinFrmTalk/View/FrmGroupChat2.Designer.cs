namespace WinFrmTalk.View
{
    partial class FrmGroupChat2
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
            this.panel1 = new System.Windows.Forms.Panel();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.panel1.Location = new System.Drawing.Point(4, 28);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(588, 348);
            this.panel1.TabIndex = 0;
            // 
            // FrmGroupChat2
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.BorderRectangle = new System.Drawing.Rectangle(0, 0, 0, 0);
            this.ClientSize = new System.Drawing.Size(596, 553);
            this.CloseBoxSize = new System.Drawing.Size(34, 24);
            this.ControlBoxOffset = new System.Drawing.Point(0, 0);
            this.Controls.Add(this.panel1);
            this.MaxSize = new System.Drawing.Size(34, 24);
            this.MiniSize = new System.Drawing.Size(34, 24);
            this.Name = "FrmGroupChat2";
            this.Radius = 3;
            this.ShadowColor = System.Drawing.Color.Silver;
            this.ShadowWidth = 6;
            this.ShowDrawIcon = false;
            this.ShowIcon = false;
            this.Special = false;
            this.Text = "";
            this.Load += new System.EventHandler(this.FrmGroupChat_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
    }
}