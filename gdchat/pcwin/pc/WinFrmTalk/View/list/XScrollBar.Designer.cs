namespace TestListView
{
    partial class XScrollBar
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(XScrollBar));
            this.XSlider = new System.Windows.Forms.Panel();
            this.SuspendLayout();
            // 
            // XSlider
            // 
            this.XSlider.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("XSlider.BackgroundImage")));
            this.XSlider.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.XSlider.Location = new System.Drawing.Point(0, 0);
            this.XSlider.Name = "XSlider";
            this.XSlider.Size = new System.Drawing.Size(15, 54);
            this.XSlider.TabIndex = 0;
            this.XSlider.MouseDown += new System.Windows.Forms.MouseEventHandler(this.XSlider_MouseDown);
            this.XSlider.MouseMove += new System.Windows.Forms.MouseEventHandler(this.XSlider_MouseMove);
            this.XSlider.MouseUp += new System.Windows.Forms.MouseEventHandler(this.XSlider_MouseUp);
            // 
            // XScrollBar
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("$this.BackgroundImage")));
            this.Controls.Add(this.XSlider);
            this.Cursor = System.Windows.Forms.Cursors.Hand;
            this.Name = "XScrollBar";
            this.Size = new System.Drawing.Size(15, 150);
            this.Load += new System.EventHandler(this.XScrollBar_Load);
            this.SizeChanged += new System.EventHandler(this.XScrollBar_SizeChanged);
            this.MouseUp += new System.Windows.Forms.MouseEventHandler(this.XScrollBar_MouseUp);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel XSlider;
    }
}
