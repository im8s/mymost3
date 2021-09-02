using TestListView;

namespace WinFrmTalk.View
{
    partial class FrmHistoryMsg
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmHistoryMsg));
            this.searchTextBox = new WinFrmTalk.Controls.CustomControls.SearchTextBox();
            this.historyTablePanel = new TestListView.XListView();
            this.lblTitlt = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // searchTextBox
            // 
            this.searchTextBox.BackColor = System.Drawing.Color.Gainsboro;
            this.searchTextBox.Context = "";
            this.searchTextBox.Location = new System.Drawing.Point(47, 66);
            this.searchTextBox.Margin = new System.Windows.Forms.Padding(4);
            this.searchTextBox.Name = "searchTextBox";
            this.searchTextBox.Size = new System.Drawing.Size(467, 21);
            this.searchTextBox.TabIndex = 1;
            this.searchTextBox.Load += new System.EventHandler(this.searchTextBox_Load);
            // 
            // historyTablePanel
            // 
            this.historyTablePanel.BackColor = System.Drawing.Color.White;
            this.historyTablePanel.Location = new System.Drawing.Point(39, 93);
            this.historyTablePanel.Margin = new System.Windows.Forms.Padding(4);
            this.historyTablePanel.Name = "historyTablePanel";
            this.historyTablePanel.ScrollBarWidth = 10;
            this.historyTablePanel.Size = new System.Drawing.Size(506, 582);
            this.historyTablePanel.TabIndex = 9;
            // 
            // lblTitlt
            // 
            this.lblTitlt.AutoSize = true;
            this.lblTitlt.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblTitlt.Location = new System.Drawing.Point(18, 13);
            this.lblTitlt.Name = "lblTitlt";
            this.lblTitlt.Size = new System.Drawing.Size(43, 17);
            this.lblTitlt.TabIndex = 12;
            this.lblTitlt.Text = "label1";
            this.lblTitlt.UseMnemonic = false;
            // 
            // FrmHistoryMsg
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(553, 682);
            this.CloseBoxSize = new System.Drawing.Size(34, 24);
            this.CloseMouseBack = ((System.Drawing.Image)(resources.GetObject("$this.CloseMouseBack")));
            this.CloseNormlBack = ((System.Drawing.Image)(resources.GetObject("$this.CloseNormlBack")));
            this.ControlBoxOffset = new System.Drawing.Point(0, 0);
            this.Controls.Add(this.lblTitlt);
            this.Controls.Add(this.historyTablePanel);
            this.Controls.Add(this.searchTextBox);
            this.MaximizeBox = false;
            this.MaxNormlBack = ((System.Drawing.Image)(resources.GetObject("$this.MaxNormlBack")));
            this.MaxSize = new System.Drawing.Size(34, 24);
            this.MinimizeBox = false;
            this.MinimumSize = new System.Drawing.Size(553, 682);
            this.MiniNormlBack = ((System.Drawing.Image)(resources.GetObject("$this.MiniNormlBack")));
            this.MiniSize = new System.Drawing.Size(34, 24);
            this.Name = "FrmHistoryMsg";
            this.ShowDrawIcon = false;
            this.ShowIcon = false;
            this.Special = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "";
            this.Load += new System.EventHandler(this.FrmHistoryMsg_Load);
            this.Shown += new System.EventHandler(this.FrmHistoryMsg_Shown);
            this.MouseDown += new System.Windows.Forms.MouseEventHandler(this.FrmHistoryMsg_MouseDown);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        
        private Controls.CustomControls.SearchTextBox searchTextBox;
        private XListView historyTablePanel;
        private System.Windows.Forms.Label lblTitlt;
    }
}