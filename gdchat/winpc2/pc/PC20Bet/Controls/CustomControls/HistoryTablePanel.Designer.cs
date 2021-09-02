namespace WinFrmTalk.Controls.CustomControls
{
    partial class HistoryTablePanel
    {
        /// <summary> 
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region 组件设计器生成的代码

        /// <summary> 
        /// 设计器支持所需的方法 - 不要修改
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.tlpHistoryTable = new WinFrmTalk.TableLayoutPanelEx();
            this.historyTabVScroll = new WinFrmTalk.Controls.CustomControls.HistoryTabVScroll();
            this.SuspendLayout();
            // 
            // tlpHistoryTable
            // 
            this.tlpHistoryTable.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tlpHistoryTable.AutoSize = true;
            this.tlpHistoryTable.ColumnCount = 1;
            this.tlpHistoryTable.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tlpHistoryTable.Location = new System.Drawing.Point(27, 0);
            this.tlpHistoryTable.Name = "tlpHistoryTable";
            this.tlpHistoryTable.RowCount = 1;
            this.tlpHistoryTable.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 126F));
            this.tlpHistoryTable.Size = new System.Drawing.Size(490, 126);
            this.tlpHistoryTable.TabIndex = 1;
            // 
            // historyTabVScroll
            // 
            this.historyTabVScroll.canAdd = 0;
            this.historyTabVScroll.Dock = System.Windows.Forms.DockStyle.Right;
            this.historyTabVScroll.Location = new System.Drawing.Point(535, 0);
            this.historyTabVScroll.Name = "historyTabVScroll";
            this.historyTabVScroll.Size = new System.Drawing.Size(10, 537);
            this.historyTabVScroll.TabIndex = 2;
            // 
            // HistoryTablePanel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Controls.Add(this.historyTabVScroll);
            this.Controls.Add(this.tlpHistoryTable);
            this.Name = "HistoryTablePanel";
            this.Size = new System.Drawing.Size(545, 537);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private WinFrmTalk.TableLayoutPanelEx tlpHistoryTable;
        private HistoryTabVScroll historyTabVScroll;
    }
}
