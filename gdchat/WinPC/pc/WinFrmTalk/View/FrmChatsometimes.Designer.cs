namespace WinFrmTalk.View
{
    partial class FrmChatsometimes
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
            this.txtsometime = new System.Windows.Forms.TextBox();
            this.btnset = new System.Windows.Forms.Button();
            this.pnlcommmtext = new System.Windows.Forms.FlowLayoutPanel();
            this.SuspendLayout();
            // 
            // txtsometime
            // 
            this.txtsometime.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtsometime.Location = new System.Drawing.Point(33, 138);
            this.txtsometime.Multiline = true;
            this.txtsometime.Name = "txtsometime";
            this.txtsometime.Size = new System.Drawing.Size(614, 104);
            this.txtsometime.TabIndex = 6;
            this.txtsometime.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtsometime_KeyPress);
            // 
            // btnset
            // 
            this.btnset.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnset.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(22)))), ((int)(((byte)(151)))), ((int)(((byte)(22)))));
            this.btnset.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnset.FlatAppearance.BorderSize = 0;
            this.btnset.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnset.Location = new System.Drawing.Point(572, 261);
            this.btnset.Name = "btnset";
            this.btnset.Size = new System.Drawing.Size(75, 23);
            this.btnset.TabIndex = 13;
            this.btnset.Text = "设置";
            this.btnset.UseVisualStyleBackColor = false;
            this.btnset.Click += new System.EventHandler(this.btnset_Click);
            // 
            // pnlcommmtext
            // 
            this.pnlcommmtext.AutoScroll = true;
            this.pnlcommmtext.Location = new System.Drawing.Point(33, 23);
            this.pnlcommmtext.Name = "pnlcommmtext";
            this.pnlcommmtext.Size = new System.Drawing.Size(614, 109);
            this.pnlcommmtext.TabIndex = 26;
            // 
            // FrmChatsometimes
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(684, 291);
            this.Controls.Add(this.pnlcommmtext);
            this.Controls.Add(this.btnset);
            this.Controls.Add(this.txtsometime);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.MinimumSize = new System.Drawing.Size(684, 291);
            this.Name = "FrmChatsometimes";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox txtsometime;
        private System.Windows.Forms.Button btnset;
        private System.Windows.Forms.FlowLayoutPanel pnlcommmtext;
    }
}