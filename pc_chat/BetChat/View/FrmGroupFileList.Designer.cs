namespace WinFrmTalk.View
{
    partial class FrmGroupFileList
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmGroupFileList));

            this.btnUploading = new System.Windows.Forms.Button();
            this.skinLine1 = new CCWin.SkinControl.SkinLine();
            this.xListView1 = new TestListView.XListView();
            this.SuspendLayout();
            
            // 
            // btnUploading
            // 
            this.btnUploading.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(24)))));
            this.btnUploading.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnUploading.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnUploading.ForeColor = System.Drawing.Color.Transparent;
            this.btnUploading.Location = new System.Drawing.Point(467, 455);
            this.btnUploading.Name = "btnUploading";
            this.btnUploading.Size = new System.Drawing.Size(86, 28);
            this.btnUploading.TabIndex = 3;
            this.btnUploading.Text = "上传文件";
            this.btnUploading.UseVisualStyleBackColor = false;
            this.btnUploading.Click += new System.EventHandler(this.btnUploading_Click);
            // 
            // skinLine1
            // 
            this.skinLine1.BackColor = System.Drawing.Color.WhiteSmoke;
            this.skinLine1.LineColor = System.Drawing.Color.Black;
            this.skinLine1.LineHeight = 1;
            this.skinLine1.Location = new System.Drawing.Point(0, 60);
            this.skinLine1.Name = "skinLine1";
            this.skinLine1.Size = new System.Drawing.Size(560, 1);
            this.skinLine1.TabIndex = 5;
            this.skinLine1.Text = "skinLine1";
            // 
            // xListView1
            // 
            this.xListView1.BackColor = System.Drawing.Color.White;
            this.xListView1.Location = new System.Drawing.Point(4, 60);
            this.xListView1.Name = "xListView1";
            this.xListView1.ScrollBarWidth = 10;
            this.xListView1.Size = new System.Drawing.Size(556, 389);
            this.xListView1.TabIndex = 9;
            // 
            // FrmGroupFileList
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(560, 485);
            this.Controls.Add(this.xListView1);
            this.Controls.Add(this.skinLine1);
            this.Controls.Add(this.btnUploading);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
         
            this.MaximizeBox = false;
            this.Name = "FrmGroupFileList";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "群文件";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmGroupFileList_FormClosed);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnUploading;
        private CCWin.SkinControl.SkinLine skinLine1;
        private TestListView.XListView xListView1;
    }
}