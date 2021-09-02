namespace WinFrmTalk
{
    partial class MyTabLayoutPanel
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
            this.showInfoVScroll = new WinFrmTalk.MyVScrollBar();
            this.showInfo_Panel = new WinFrmTalk.TableLayoutPanelEx();
            this.SuspendLayout();
            // 
            // showInfoVScroll
            // 
            this.showInfoVScroll.BackColor = System.Drawing.Color.Transparent;
            this.showInfoVScroll.canAdd = 0;
            this.showInfoVScroll.canTop = 0;
            this.showInfoVScroll.Dock = System.Windows.Forms.DockStyle.Right;
            this.showInfoVScroll.Location = new System.Drawing.Point(600, 0);
            this.showInfoVScroll.Name = "showInfoVScroll";
            this.showInfoVScroll.Size = new System.Drawing.Size(12, 334);
            this.showInfoVScroll.TabIndex = 7;
            // 
            // showInfo_Panel
            // 
            this.showInfo_Panel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.showInfo_Panel.BackColor = System.Drawing.Color.Transparent;
            this.showInfo_Panel.ColumnCount = 1;
            this.showInfo_Panel.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.showInfo_Panel.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.showInfo_Panel.Location = new System.Drawing.Point(3, 0);
            this.showInfo_Panel.Name = "showInfo_Panel";
            this.showInfo_Panel.RowCount = 1;
            this.showInfo_Panel.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.showInfo_Panel.Size = new System.Drawing.Size(589, 100);
            this.showInfo_Panel.TabIndex = 6;
            this.showInfo_Panel.SizeChanged += new System.EventHandler(this.showInfo_Panel_SizeChanged);
            this.showInfo_Panel.ControlAdded += new System.Windows.Forms.ControlEventHandler(this.showInfo_Panel_ControlAdded);
            this.showInfo_Panel.ControlRemoved += new System.Windows.Forms.ControlEventHandler(this.showInfo_Panel_ControlRemoved);
            this.showInfo_Panel.Paint += new System.Windows.Forms.PaintEventHandler(this.showInfo_Panel_Paint);
            // 
            // MyTabLayoutPanel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.Controls.Add(this.showInfoVScroll);
            this.Controls.Add(this.showInfo_Panel);
            this.DoubleBuffered = true;
            this.Name = "MyTabLayoutPanel";
            this.Size = new System.Drawing.Size(612, 334);
            this.Load += new System.EventHandler(this.MyTabLayoutPanel_Load);
            this.ResumeLayout(false);

        }

        #endregion
        public TableLayoutPanelEx showInfo_Panel;
        public MyVScrollBar showInfoVScroll;
    }
}
