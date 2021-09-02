using TestListView;

namespace WinFrmTalk.View
{
    partial class FrmMoreMember
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
            this.searchControl1 = new System.Windows.Forms.TextBox();
            this.palGroupMenber = new XListView();
            this.palLoading = new System.Windows.Forms.Panel();
            this.btnAdd = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // searchControl1
            // 
            this.searchControl1.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.searchControl1.Location = new System.Drawing.Point(7, 31);
            this.searchControl1.Name = "searchControl1";
            this.searchControl1.Size = new System.Drawing.Size(290, 29);
            this.searchControl1.TabIndex = 2;
            this.searchControl1.TextChanged += new System.EventHandler(this.searchControl1_TextChanged);
            // 
            // palGroupMenber
            // 
            this.palGroupMenber.BackColor = System.Drawing.Color.White;
            this.palGroupMenber.Location = new System.Drawing.Point(3, 65);
            this.palGroupMenber.Name = "palGroupMenber";
            this.palGroupMenber.Size = new System.Drawing.Size(300, 447);
            this.palGroupMenber.TabIndex = 1;
           
            this.palGroupMenber.Load += new System.EventHandler(this.palGroupMenber_Load);
            // 
            // palLoading
            // 
            this.palLoading.Location = new System.Drawing.Point(3, 65);
            this.palLoading.Name = "palLoading";
            this.palLoading.Size = new System.Drawing.Size(300, 80);
            this.palLoading.TabIndex = 8;
            this.palLoading.Visible = false;
            // 
            // btnAdd
            // 
            this.btnAdd.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnAdd.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.btnAdd.FlatAppearance.BorderSize = 0;
            this.btnAdd.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnAdd.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnAdd.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnAdd.Location = new System.Drawing.Point(123, 518);
            this.btnAdd.Name = "btnAdd";
            this.btnAdd.Size = new System.Drawing.Size(35, 35);
            this.btnAdd.TabIndex = 11;
            this.btnAdd.UseVisualStyleBackColor = true;
            this.btnAdd.Visible = false;
            // 
            // FrmMoreMember
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(304, 561);
            this.Controls.Add(this.btnAdd);
            this.Controls.Add(this.palLoading);
            this.Controls.Add(this.searchControl1);
            this.Controls.Add(this.palGroupMenber);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmMoreMember";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "群成员";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmMoreMember_FormClosed);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private XListView palGroupMenber;
        private System.Windows.Forms.TextBox searchControl1;
        private System.Windows.Forms.Panel palLoading;
        public System.Windows.Forms.Button btnAdd;
    }
}