namespace WinFrmTalk
{
    partial class BlackItem
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
            this.lblTitle = new System.Windows.Forms.Label();
            this.lblSubTitle = new System.Windows.Forms.Label();
            this.skinLine2 = new CCWin.SkinControl.SkinLine();
            this.BtnMainRaiseButton = new LollipopButton();
            this.picAvator = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.picAvator)).BeginInit();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.AutoSize = true;
            this.lblTitle.Font = new System.Drawing.Font(Applicate.SetFont, 12F);
            this.lblTitle.Location = new System.Drawing.Point(88, 11);
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(43, 21);
            this.lblTitle.TabIndex = 3;
            this.lblTitle.Text = "TItle";
            // 
            // lblSubTitle
            // 
            this.lblSubTitle.AutoSize = true;
            this.lblSubTitle.Font = new System.Drawing.Font(Applicate.SetFont, 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblSubTitle.ForeColor = System.Drawing.Color.DimGray;
            this.lblSubTitle.Location = new System.Drawing.Point(88, 37);
            this.lblSubTitle.Name = "lblSubTitle";
            this.lblSubTitle.Size = new System.Drawing.Size(64, 20);
            this.lblSubTitle.TabIndex = 4;
            this.lblSubTitle.Text = "SubTitle";
            // 
            // skinLine2
            // 
            this.skinLine2.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.skinLine2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(212)))), ((int)(((byte)(212)))), ((int)(((byte)(212)))));
            this.skinLine2.LineColor = System.Drawing.Color.Black;
            this.skinLine2.LineHeight = 1;
            this.skinLine2.Location = new System.Drawing.Point(32, 71);
            this.skinLine2.Name = "skinLine2";
            this.skinLine2.Size = new System.Drawing.Size(400, 1);
            this.skinLine2.TabIndex = 11;
            this.skinLine2.Text = "skinLine2";
            // 
            // BtnMainRaiseButton
            // 
            this.BtnMainRaiseButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.BtnMainRaiseButton.BackColor = System.Drawing.Color.Red;
            this.BtnMainRaiseButton.BGColor = "#0AD007";
            this.BtnMainRaiseButton.Font = new System.Drawing.Font(Applicate.SetFont, 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.BtnMainRaiseButton.FontColor = "#ffffff";
            this.BtnMainRaiseButton.ForeColor = System.Drawing.Color.Transparent;
            this.BtnMainRaiseButton.Location = new System.Drawing.Point(353, 18);
            this.BtnMainRaiseButton.Margin = new System.Windows.Forms.Padding(0);
            this.BtnMainRaiseButton.Name = "BtnMainRaiseButton";
            this.BtnMainRaiseButton.Size = new System.Drawing.Size(80, 36);
            this.BtnMainRaiseButton.TabIndex = 3;
            this.BtnMainRaiseButton.Text = "移出黑名单";
            this.BtnMainRaiseButton.Click += new System.EventHandler(this.BtnMainRaiseButtonClick);
            // 
            // picAvator
            // 
            this.picAvator.isDrawRound = true;
            this.picAvator.Location = new System.Drawing.Point(32, 12);
            this.picAvator.Margin = new System.Windows.Forms.Padding(0);
            this.picAvator.Name = "picAvator";
            this.picAvator.Size = new System.Drawing.Size(48, 48);
            this.picAvator.TabIndex = 0;
            this.picAvator.TabStop = false;
            // 
            // BlackItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Controls.Add(this.skinLine2);
            this.Controls.Add(this.lblSubTitle);
            this.Controls.Add(this.lblTitle);
            this.Controls.Add(this.BtnMainRaiseButton);
            this.Controls.Add(this.picAvator);
            this.Margin = new System.Windows.Forms.Padding(0);
            this.Name = "BlackItem";
            this.Size = new System.Drawing.Size(462, 72);
            this.Load += new System.EventHandler(this.BlackItem_Load);
            ((System.ComponentModel.ISupportInitialize)(this.picAvator)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private RoundPicBox picAvator;
        private LollipopButton BtnMainRaiseButton;
        private System.Windows.Forms.Label lblTitle;
        private System.Windows.Forms.Label lblSubTitle;
        private CCWin.SkinControl.SkinLine skinLine2;
    }
}
