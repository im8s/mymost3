using System.Drawing;

namespace TestListView
{
    partial class XListView
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(XListView));
            this.panel1 = new System.Windows.Forms.Panel();
            this.vScrollBar = new TestListView.XScrollBar();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(130, 390);
            this.panel1.TabIndex = 0;
            // 
            // vScrollBar
            // 
            this.vScrollBar.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("vScrollBar.BackgroundImage")));
            this.vScrollBar.Cursor = System.Windows.Forms.Cursors.Hand;
            this.vScrollBar.Dock = System.Windows.Forms.DockStyle.Right;
            this.vScrollBar.Location = new System.Drawing.Point(140, 0);
            this.vScrollBar.Name = "vScrollBar";
            this.vScrollBar.Size = new System.Drawing.Size(10, 150);
            this.vScrollBar.TabIndex = 0;
            this.vScrollBar.ScrollChangeListener += new TestListView.XScrollBar.EventProgressHandler(this.vScrollBar_Scroll);
            // 
            // XListView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Red;
            this.Controls.Add(this.vScrollBar);
            this.Controls.Add(this.panel1);
            this.Name = "XListView";
            this.Load += new System.EventHandler(this.XListView_Load);
            this.SizeChanged += new System.EventHandler(this.XListView_SizeChanged);
            this.MouseWheel += new System.Windows.Forms.MouseEventHandler(this.View_MouseWheel);
            this.Click += new System.EventHandler(this.View_CurMouseClick);
            this.ResumeLayout(false);

        }

        #endregion
        public System.Windows.Forms.Panel panel1;
        public XScrollBar vScrollBar;
    }
}
