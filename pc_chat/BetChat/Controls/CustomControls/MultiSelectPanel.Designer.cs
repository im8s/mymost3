namespace WinFrmTalk.Controls.CustomControls
{
    partial class MultiSelectPanel
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MultiSelectPanel));
            this.lblDelete = new System.Windows.Forms.Label();
            this.lblSaveAs = new System.Windows.Forms.Label();
            this.lblCollect = new System.Windows.Forms.Label();
            this.lblCombineRelay = new System.Windows.Forms.Label();
            this.lblOneRelay = new System.Windows.Forms.Label();
            this.picDelete = new CCWin.SkinControl.SkinPictureBox();
            this.picSaveAs = new CCWin.SkinControl.SkinPictureBox();
            this.picCollect = new CCWin.SkinControl.SkinPictureBox();
            this.picCombineRelay = new CCWin.SkinControl.SkinPictureBox();
            this.picOneRelay = new CCWin.SkinControl.SkinPictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.picDelete)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picSaveAs)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picCollect)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picCombineRelay)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picOneRelay)).BeginInit();
            this.SuspendLayout();
            // 
            // lblDelete
            // 
            this.lblDelete.BackColor = System.Drawing.Color.Transparent;
            this.lblDelete.Location = new System.Drawing.Point(243, 67);
            this.lblDelete.Name = "lblDelete";
            this.lblDelete.Size = new System.Drawing.Size(55, 20);
            this.lblDelete.TabIndex = 19;
            this.lblDelete.Text = "删除";
            this.lblDelete.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblSaveAs
            // 
            this.lblSaveAs.BackColor = System.Drawing.Color.Transparent;
            this.lblSaveAs.Location = new System.Drawing.Point(243, 67);
            this.lblSaveAs.Name = "lblSaveAs";
            this.lblSaveAs.Size = new System.Drawing.Size(55, 20);
            this.lblSaveAs.TabIndex = 17;
            this.lblSaveAs.Text = "保存";
            this.lblSaveAs.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblCollect
            // 
            this.lblCollect.BackColor = System.Drawing.Color.Transparent;
            this.lblCollect.Location = new System.Drawing.Point(163, 67);
            this.lblCollect.Name = "lblCollect";
            this.lblCollect.Size = new System.Drawing.Size(55, 20);
            this.lblCollect.TabIndex = 15;
            this.lblCollect.Text = "收藏";
            this.lblCollect.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblCombineRelay
            // 
            this.lblCombineRelay.BackColor = System.Drawing.Color.Transparent;
            this.lblCombineRelay.Location = new System.Drawing.Point(83, 67);
            this.lblCombineRelay.Name = "lblCombineRelay";
            this.lblCombineRelay.Size = new System.Drawing.Size(55, 20);
            this.lblCombineRelay.TabIndex = 13;
            this.lblCombineRelay.Text = "合并转发";
            this.lblCombineRelay.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblOneRelay
            // 
            this.lblOneRelay.BackColor = System.Drawing.Color.Transparent;
            this.lblOneRelay.Location = new System.Drawing.Point(3, 67);
            this.lblOneRelay.Name = "lblOneRelay";
            this.lblOneRelay.Size = new System.Drawing.Size(55, 20);
            this.lblOneRelay.TabIndex = 11;
            this.lblOneRelay.Text = "逐条转发";
            this.lblOneRelay.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // picDelete
            // 
            this.picDelete.BackColor = System.Drawing.Color.Transparent;
            this.picDelete.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("picDelete.BackgroundImage")));
            this.picDelete.Cursor = System.Windows.Forms.Cursors.Hand;
            this.picDelete.Location = new System.Drawing.Point(243, 3);
            this.picDelete.Name = "picDelete";
            this.picDelete.Size = new System.Drawing.Size(55, 55);
            this.picDelete.TabIndex = 18;
            this.picDelete.TabStop = false;
            this.picDelete.MouseDown += new System.Windows.Forms.MouseEventHandler(this.picDelete_MouseDown);
            // 
            // picSaveAs
            // 
            this.picSaveAs.BackColor = System.Drawing.Color.Transparent;
            this.picSaveAs.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("picSaveAs.BackgroundImage")));
            this.picSaveAs.Cursor = System.Windows.Forms.Cursors.Hand;
            this.picSaveAs.Location = new System.Drawing.Point(243, 3);
            this.picSaveAs.Name = "picSaveAs";
            this.picSaveAs.Size = new System.Drawing.Size(55, 55);
            this.picSaveAs.TabIndex = 16;
            this.picSaveAs.TabStop = false;
            // 
            // picCollect
            // 
            this.picCollect.BackColor = System.Drawing.Color.Transparent;
            this.picCollect.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("picCollect.BackgroundImage")));
            this.picCollect.Cursor = System.Windows.Forms.Cursors.Hand;
            this.picCollect.Location = new System.Drawing.Point(163, 3);
            this.picCollect.Name = "picCollect";
            this.picCollect.Size = new System.Drawing.Size(55, 55);
            this.picCollect.TabIndex = 14;
            this.picCollect.TabStop = false;
            this.picCollect.Click += new System.EventHandler(this.picCollect_Click);
            // 
            // picCombineRelay
            // 
            this.picCombineRelay.BackColor = System.Drawing.Color.Transparent;
            this.picCombineRelay.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("picCombineRelay.BackgroundImage")));
            this.picCombineRelay.Cursor = System.Windows.Forms.Cursors.Hand;
            this.picCombineRelay.Location = new System.Drawing.Point(83, 3);
            this.picCombineRelay.Name = "picCombineRelay";
            this.picCombineRelay.Size = new System.Drawing.Size(55, 55);
            this.picCombineRelay.TabIndex = 12;
            this.picCombineRelay.TabStop = false;
            this.picCombineRelay.MouseDown += new System.Windows.Forms.MouseEventHandler(this.picCombineRelay_MouseDown);
            // 
            // picOneRelay
            // 
            this.picOneRelay.BackColor = System.Drawing.Color.Transparent;
            this.picOneRelay.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("picOneRelay.BackgroundImage")));
            this.picOneRelay.Cursor = System.Windows.Forms.Cursors.Hand;
            this.picOneRelay.Location = new System.Drawing.Point(3, 3);
            this.picOneRelay.Name = "picOneRelay";
            this.picOneRelay.Size = new System.Drawing.Size(55, 55);
            this.picOneRelay.TabIndex = 10;
            this.picOneRelay.TabStop = false;
            this.picOneRelay.MouseDown += new System.Windows.Forms.MouseEventHandler(this.picOneRelay_MouseDown);
            // 
            // MultiSelectPanel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Transparent;
            this.Controls.Add(this.lblDelete);
            this.Controls.Add(this.picDelete);
            this.Controls.Add(this.lblSaveAs);
            this.Controls.Add(this.picSaveAs);
            this.Controls.Add(this.lblCollect);
            this.Controls.Add(this.picCollect);
            this.Controls.Add(this.lblCombineRelay);
            this.Controls.Add(this.picCombineRelay);
            this.Controls.Add(this.lblOneRelay);
            this.Controls.Add(this.picOneRelay);
            this.Name = "MultiSelectPanel";
            this.Size = new System.Drawing.Size(300, 92);
            ((System.ComponentModel.ISupportInitialize)(this.picDelete)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picSaveAs)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picCollect)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picCombineRelay)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picOneRelay)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label lblDelete;
        private CCWin.SkinControl.SkinPictureBox picDelete;
        private System.Windows.Forms.Label lblSaveAs;
        private CCWin.SkinControl.SkinPictureBox picSaveAs;
        private System.Windows.Forms.Label lblCollect;
        private CCWin.SkinControl.SkinPictureBox picCollect;
        private System.Windows.Forms.Label lblCombineRelay;
        private CCWin.SkinControl.SkinPictureBox picCombineRelay;
        private System.Windows.Forms.Label lblOneRelay;
        private CCWin.SkinControl.SkinPictureBox picOneRelay;
    }
}
