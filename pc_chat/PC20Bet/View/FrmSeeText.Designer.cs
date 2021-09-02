namespace WinFrmTalk.View
{
    partial class FrmSeeText
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
            this.label1 = new System.Windows.Forms.Label();
            this.contextMenu = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.ToolMenuCopy = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStrip1 = new System.Windows.Forms.ToolStrip();
            this.btnShare = new System.Windows.Forms.ToolStripButton();
            this.btnCollection = new System.Windows.Forms.ToolStripButton();
            this.txttext = new RichTextBoxLinks.RichTextBoxEx();
            this.contextMenu.SuspendLayout();
            this.toolStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.label1.BackColor = System.Drawing.Color.Gainsboro;
            this.label1.Location = new System.Drawing.Point(0, 55);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(427, 1);
            this.label1.TabIndex = 7;
            this.label1.Text = "label1";
            // 
            // contextMenu
            // 
            this.contextMenu.Font = new System.Drawing.Font("Microsoft YaHei UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.contextMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.ToolMenuCopy});
            this.contextMenu.Name = "contextMenu";
            this.contextMenu.Size = new System.Drawing.Size(101, 26);
            // 
            // ToolMenuCopy
            // 
            this.ToolMenuCopy.Name = "ToolMenuCopy";
            this.ToolMenuCopy.Size = new System.Drawing.Size(100, 22);
            this.ToolMenuCopy.Text = "复制";
            this.ToolMenuCopy.Click += new System.EventHandler(this.ToolMenuCopy_Click);
            // 
            // toolStrip1
            // 
            this.toolStrip1.BackColor = System.Drawing.Color.White;
            this.toolStrip1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.toolStrip1.Dock = System.Windows.Forms.DockStyle.None;
            this.toolStrip1.GripStyle = System.Windows.Forms.ToolStripGripStyle.Hidden;
            this.toolStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.btnShare,
            this.btnCollection});
            this.toolStrip1.Location = new System.Drawing.Point(175, 20);
            this.toolStrip1.Name = "toolStrip1";
            this.toolStrip1.RenderMode = System.Windows.Forms.ToolStripRenderMode.System;
            this.toolStrip1.Size = new System.Drawing.Size(67, 35);
            this.toolStrip1.TabIndex = 40;
            this.toolStrip1.Text = "toolStrip1";
            this.toolStrip1.Paint += new System.Windows.Forms.PaintEventHandler(this.toolStrip1_Paint);
            // 
            // btnShare
            // 
            this.btnShare.AutoSize = false;
            this.btnShare.BackgroundImage = global::WinFrmTalk.Properties.Resources.forward;
            this.btnShare.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnShare.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.btnShare.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnShare.Name = "btnShare";
            this.btnShare.Size = new System.Drawing.Size(32, 32);
            this.btnShare.Text = "转发";
            this.btnShare.Click += new System.EventHandler(this.btnShare_Click);
            // 
            // btnCollection
            // 
            this.btnCollection.AutoSize = false;
            this.btnCollection.BackgroundImage = global::WinFrmTalk.Properties.Resources.Collection;
            this.btnCollection.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnCollection.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.btnCollection.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnCollection.Name = "btnCollection";
            this.btnCollection.Size = new System.Drawing.Size(32, 32);
            this.btnCollection.Text = "收藏";
            this.btnCollection.Click += new System.EventHandler(this.btnCollection_Click);
            // 
            // txttext
            // 
            this.txttext.BackColor = System.Drawing.Color.White;
            this.txttext.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.txttext.DetectUrls = false;
            this.txttext.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.txttext.Location = new System.Drawing.Point(28, 71);
            this.txttext.Name = "txttext";
            this.txttext.ReadOnly = true;
            this.txttext.Size = new System.Drawing.Size(379, 406);
            this.txttext.TabIndex = 43;
            this.txttext.Text = "";
            // 
            // FrmSeeText
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(427, 484);
            this.Controls.Add(this.txttext);
            this.Controls.Add(this.toolStrip1);
            this.Controls.Add(this.label1);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmSeeText";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "详情";
            this.contextMenu.ResumeLayout(false);
            this.toolStrip1.ResumeLayout(false);
            this.toolStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ToolStrip toolStrip1;
        private System.Windows.Forms.ToolStripButton btnShare;
        private System.Windows.Forms.ToolStripButton btnCollection;
        private System.Windows.Forms.ContextMenuStrip contextMenu;
        private System.Windows.Forms.ToolStripMenuItem ToolMenuCopy;
        private RichTextBoxLinks.RichTextBoxEx txttext;
    }
}