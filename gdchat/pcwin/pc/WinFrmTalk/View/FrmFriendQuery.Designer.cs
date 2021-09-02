namespace WinFrmTalk
{
    partial class FrmFriendQuery
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
            this.palFriendItem = new WinFrmTalk.MyTabLayoutPanel();
            this.txtKeyWord = new System.Windows.Forms.TextBox();
            this.btnQuery = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // palFriendItem
            // 
            this.palFriendItem.BackColor = System.Drawing.Color.White;
            this.palFriendItem.Location = new System.Drawing.Point(13, 71);
            this.palFriendItem.Name = "palFriendItem";
            this.palFriendItem.Size = new System.Drawing.Size(300, 404);
            this.palFriendItem.TabIndex = 3;
            // 
            // txtKeyWord
            // 
            this.txtKeyWord.Font = new System.Drawing.Font("宋体", 10F);
            this.txtKeyWord.ImeMode = System.Windows.Forms.ImeMode.Hangul;
            this.txtKeyWord.Location = new System.Drawing.Point(13, 31);
            this.txtKeyWord.Name = "txtKeyWord";
            this.txtKeyWord.Size = new System.Drawing.Size(229, 23);
            this.txtKeyWord.TabIndex = 4;
            this.txtKeyWord.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtKeyWord_KeyPress);
            // 
            // btnQuery
            // 
            this.btnQuery.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.btnQuery.FlatAppearance.BorderSize = 0;
            this.btnQuery.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnQuery.ForeColor = System.Drawing.Color.White;
            this.btnQuery.Location = new System.Drawing.Point(249, 31);
            this.btnQuery.Name = "btnQuery";
            this.btnQuery.Size = new System.Drawing.Size(64, 23);
            this.btnQuery.TabIndex = 5;
            this.btnQuery.Text = "查找";
            this.btnQuery.UseVisualStyleBackColor = false;
            this.btnQuery.Click += new System.EventHandler(this.btnQuery_Click);
            // 
            // FrmFriendQuery
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(320, 485);
            this.Controls.Add(this.btnQuery);
            this.Controls.Add(this.txtKeyWord);
            this.Controls.Add(this.palFriendItem);
            this.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "FrmFriendQuery";
            this.ShowDrawIcon = false;
            this.ShowIcon = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "查找好友";
            this.TitleColor = System.Drawing.SystemColors.GrayText;
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmFriendQuery_FormClosed);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private MyTabLayoutPanel palFriendItem;
        private System.Windows.Forms.TextBox txtKeyWord;
        private System.Windows.Forms.Button btnQuery;
    }
}