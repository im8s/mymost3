using TestListView;

namespace WinFrmTalk.View
{
    partial class FrmGrouptips
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
            this.btnannounce = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.palTab = new TestListView.XListView();
            this.ContextDel = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.menuitemDel = new System.Windows.Forms.ToolStripMenuItem();
            this.menuitemEdi = new System.Windows.Forms.ToolStripMenuItem();
            this.ContextDel.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnannounce
            // 
            this.btnannounce.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(181)))), ((int)(((byte)(26)))));
            this.btnannounce.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnannounce.FlatAppearance.BorderSize = 0;
            this.btnannounce.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnannounce.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnannounce.ForeColor = System.Drawing.Color.White;
            this.btnannounce.Location = new System.Drawing.Point(229, 446);
            this.btnannounce.Margin = new System.Windows.Forms.Padding(3, 3, 15, 15);
            this.btnannounce.Name = "btnannounce";
            this.btnannounce.Size = new System.Drawing.Size(66, 25);
            this.btnannounce.TabIndex = 17;
            this.btnannounce.Text = "发布";
            this.btnannounce.UseVisualStyleBackColor = false;
            this.btnannounce.Click += new System.EventHandler(this.btnannounce_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label1.Location = new System.Drawing.Point(15, 15);
            this.label1.Margin = new System.Windows.Forms.Padding(15, 15, 3, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(44, 17);
            this.label1.TabIndex = 19;
            this.label1.Text = "群公告";
            // 
            // palTab
            // 
            this.palTab.BackColor = System.Drawing.Color.WhiteSmoke;
            this.palTab.Location = new System.Drawing.Point(18, 45);
            this.palTab.Name = "palTab";
            this.palTab.ScrollBarWidth = 10;
            this.palTab.Size = new System.Drawing.Size(488, 383);
            this.palTab.TabIndex = 20;
            // 
            // ContextDel
            // 
            this.ContextDel.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menuitemDel,
            this.menuitemEdi});
            this.ContextDel.Name = "ContextDel";
            this.ContextDel.Size = new System.Drawing.Size(101, 48);
            // 
            // menuitemDel
            // 
            this.menuitemDel.Name = "menuitemDel";
            this.menuitemDel.Size = new System.Drawing.Size(100, 22);
            this.menuitemDel.Text = "删除";
            this.menuitemDel.Click += new System.EventHandler(this.menuitemDel_Click);
            // 
            // menuitemEdi
            // 
            this.menuitemEdi.Name = "menuitemEdi";
            this.menuitemEdi.Size = new System.Drawing.Size(100, 22);
            this.menuitemEdi.Text = "编辑";
            this.menuitemEdi.Click += new System.EventHandler(this.menuitemEdi_Click);
            // 
            // Grouptips2
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(513, 485);
            this.Controls.Add(this.palTab);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.btnannounce);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Grouptips2";
            this.ShowDrawIcon = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.Grouptips2_FormClosed);
            this.ContextDel.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        public System.Windows.Forms.Button btnannounce;
        private System.Windows.Forms.Label label1;
        private XListView palTab;
        public System.Windows.Forms.ContextMenuStrip ContextDel;
        private System.Windows.Forms.ToolStripMenuItem menuitemDel;
        private System.Windows.Forms.ToolStripMenuItem menuitemEdi;
    }
}