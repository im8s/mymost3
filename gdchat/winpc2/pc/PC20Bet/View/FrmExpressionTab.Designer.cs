namespace WinFrmTalk.View
{
    partial class FrmExpressionTab
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmExpressionTab));
            this.tabExpression = new CCWin.SkinControl.SkinTabControl();
            this.tabPageEmoji = new CCWin.SkinControl.SkinTabPage();
            this.flpEmoji = new CCWin.SkinControl.SkinFlowLayoutPanel();
            this.panel1 = new System.Windows.Forms.Panel();
            this.tabPagGif = new CCWin.SkinControl.SkinTabPage();
            this.flpGifTab = new CCWin.SkinControl.SkinFlowLayoutPanel();
            this.tabPageCollection = new CCWin.SkinControl.SkinTabPage();
            this.flpCustomize = new CCWin.SkinControl.SkinFlowLayoutPanel();
            this.cmsCustomizeMenu = new CCWin.SkinControl.SkinContextMenuStrip();
            this.menuItem_deleted = new System.Windows.Forms.ToolStripMenuItem();
            this.tabExpression.SuspendLayout();
            this.tabPageEmoji.SuspendLayout();
            this.tabPagGif.SuspendLayout();
            this.tabPageCollection.SuspendLayout();
            this.cmsCustomizeMenu.SuspendLayout();
            this.SuspendLayout();
            // 
            // tabExpression
            // 
            this.tabExpression.Alignment = System.Windows.Forms.TabAlignment.Bottom;
            this.tabExpression.AnimatorType = CCWin.SkinControl.AnimationType.HorizSlide;
            this.tabExpression.ArrowBaseColor = System.Drawing.Color.White;
            this.tabExpression.ArrowBorderColor = System.Drawing.Color.White;
            this.tabExpression.CloseRect = new System.Drawing.Rectangle(2, 2, 12, 12);
            this.tabExpression.Controls.Add(this.tabPageEmoji);
            this.tabExpression.Controls.Add(this.tabPagGif);
            //this.tabExpression.Controls.Add(this.tabPageCollection);
            this.tabExpression.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabExpression.HeadBack = ((System.Drawing.Image)(resources.GetObject("tabExpression.HeadBack")));
            this.tabExpression.ImgTxtOffset = new System.Drawing.Point(0, 0);
            this.tabExpression.ItemSize = new System.Drawing.Size(70, 36);
            this.tabExpression.Location = new System.Drawing.Point(0, 0);
            this.tabExpression.Name = "tabExpression";
            this.tabExpression.PageArrowDown = ((System.Drawing.Image)(resources.GetObject("tabExpression.PageArrowDown")));
            this.tabExpression.PageArrowHover = ((System.Drawing.Image)(resources.GetObject("tabExpression.PageArrowHover")));
            this.tabExpression.PageBaseColor = System.Drawing.Color.White;
            this.tabExpression.PageBorderColor = System.Drawing.Color.White;
            this.tabExpression.PageCloseHover = ((System.Drawing.Image)(resources.GetObject("tabExpression.PageCloseHover")));
            this.tabExpression.PageCloseNormal = ((System.Drawing.Image)(resources.GetObject("tabExpression.PageCloseNormal")));
            this.tabExpression.PageDown = ((System.Drawing.Image)(resources.GetObject("tabExpression.PageDown")));
            this.tabExpression.PageHover = ((System.Drawing.Image)(resources.GetObject("tabExpression.PageHover")));
            this.tabExpression.PageImagePosition = CCWin.SkinControl.SkinTabControl.ePageImagePosition.Left;
            this.tabExpression.PageNorml = null;
            this.tabExpression.SelectedIndex = 0;
            this.tabExpression.Size = new System.Drawing.Size(450, 300);
            this.tabExpression.SizeMode = System.Windows.Forms.TabSizeMode.FillToRight;
            this.tabExpression.TabIndex = 0;
            this.tabExpression.SelectedIndexChanged += new System.EventHandler(this.tabExpression_SelectedIndexChanged);
            // 
            // tabPageEmoji
            // 
            this.tabPageEmoji.BackColor = System.Drawing.Color.White;
            this.tabPageEmoji.Controls.Add(this.flpEmoji);
            this.tabPageEmoji.Controls.Add(this.panel1);
            this.tabPageEmoji.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabPageEmoji.Location = new System.Drawing.Point(0, 0);
            this.tabPageEmoji.Name = "tabPageEmoji";
            this.tabPageEmoji.Size = new System.Drawing.Size(450, 264);
            this.tabPageEmoji.TabIndex = 0;
            this.tabPageEmoji.TabItemImage = null;
            this.tabPageEmoji.Text = "表情";
            // 
            // flpEmoji
            // 
            this.flpEmoji.BackColor = System.Drawing.Color.Transparent;
            this.flpEmoji.ControlState = CCWin.SkinClass.ControlState.Normal;
            this.flpEmoji.DownBack = null;
            this.flpEmoji.Location = new System.Drawing.Point(10, 20);
            this.flpEmoji.MouseBack = null;
            this.flpEmoji.Name = "flpEmoji";
            this.flpEmoji.NormlBack = null;
            this.flpEmoji.Size = new System.Drawing.Size(438, 244);
            this.flpEmoji.TabIndex = 1;
            // 
            // panel1
            // 
            this.panel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(450, 20);
            this.panel1.TabIndex = 0;
            // 
            // tabPagGif
            // 
            this.tabPagGif.BackColor = System.Drawing.Color.White;
            this.tabPagGif.Controls.Add(this.flpGifTab);
            this.tabPagGif.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabPagGif.Location = new System.Drawing.Point(0, 0);
            this.tabPagGif.Name = "tabPagGif";
            this.tabPagGif.Size = new System.Drawing.Size(450, 264);
            this.tabPagGif.TabIndex = 1;
            this.tabPagGif.TabItemImage = null;
            this.tabPagGif.Text = "动画表情";
            // 
            // flpGifTab
            // 
            this.flpGifTab.AutoScroll = true;
            this.flpGifTab.BackColor = System.Drawing.Color.Transparent;
            this.flpGifTab.ControlState = CCWin.SkinClass.ControlState.Normal;
            this.flpGifTab.DownBack = null;
            this.flpGifTab.Location = new System.Drawing.Point(10, 20);
            this.flpGifTab.MouseBack = null;
            this.flpGifTab.Name = "flpGifTab";
            this.flpGifTab.NormlBack = null;
            this.flpGifTab.Size = new System.Drawing.Size(438, 241);
            this.flpGifTab.TabIndex = 0;
            // 
            // tabPageCollection
            // 
            this.tabPageCollection.BackColor = System.Drawing.Color.White;
            this.tabPageCollection.Controls.Add(this.flpCustomize);
            this.tabPageCollection.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabPageCollection.Location = new System.Drawing.Point(0, 0);
            this.tabPageCollection.Name = "tabPageCollection";
            this.tabPageCollection.Size = new System.Drawing.Size(450, 264);
            this.tabPageCollection.TabIndex = 2;
            this.tabPageCollection.TabItemImage = null;
            this.tabPageCollection.Text = "自定义表情";
            // 
            // flpCustomize
            // 
            this.flpCustomize.AutoScroll = true;
            this.flpCustomize.BackColor = System.Drawing.Color.Transparent;
            this.flpCustomize.ControlState = CCWin.SkinClass.ControlState.Normal;
            this.flpCustomize.DownBack = null;
            this.flpCustomize.Location = new System.Drawing.Point(10, 20);
            this.flpCustomize.MouseBack = null;
            this.flpCustomize.Name = "flpCustomize";
            this.flpCustomize.NormlBack = null;
            this.flpCustomize.Size = new System.Drawing.Size(438, 241);
            this.flpCustomize.TabIndex = 1;
            // 
            // cmsCustomizeMenu
            // 
            this.cmsCustomizeMenu.Arrow = System.Drawing.Color.Black;
            this.cmsCustomizeMenu.Back = System.Drawing.Color.White;
            this.cmsCustomizeMenu.BackRadius = 4;
            this.cmsCustomizeMenu.Base = System.Drawing.Color.White;
            this.cmsCustomizeMenu.DropDownImageSeparator = System.Drawing.Color.FromArgb(((int)(((byte)(197)))), ((int)(((byte)(197)))), ((int)(((byte)(197)))));
            this.cmsCustomizeMenu.Fore = System.Drawing.Color.Black;
            this.cmsCustomizeMenu.HoverFore = System.Drawing.Color.Black;
            this.cmsCustomizeMenu.ItemAnamorphosis = false;
            this.cmsCustomizeMenu.ItemBorder = System.Drawing.Color.White;
            this.cmsCustomizeMenu.ItemBorderShow = false;
            this.cmsCustomizeMenu.ItemHover = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(226)))), ((int)(((byte)(226)))));
            this.cmsCustomizeMenu.ItemPressed = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(226)))), ((int)(((byte)(226)))));
            this.cmsCustomizeMenu.ItemRadius = 4;
            this.cmsCustomizeMenu.ItemRadiusStyle = CCWin.SkinClass.RoundStyle.All;
            this.cmsCustomizeMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menuItem_deleted});
            this.cmsCustomizeMenu.ItemSplitter = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(226)))), ((int)(((byte)(226)))));
            this.cmsCustomizeMenu.Name = "cmsCustomizeMenu";
            this.cmsCustomizeMenu.RadiusStyle = CCWin.SkinClass.RoundStyle.All;
            this.cmsCustomizeMenu.Size = new System.Drawing.Size(101, 26);
            this.cmsCustomizeMenu.SkinAllColor = true;
            this.cmsCustomizeMenu.TitleAnamorphosis = false;
            this.cmsCustomizeMenu.TitleColor = System.Drawing.Color.White;
            this.cmsCustomizeMenu.TitleRadius = 4;
            this.cmsCustomizeMenu.TitleRadiusStyle = CCWin.SkinClass.RoundStyle.All;
            // 
            // menuItem_deleted
            // 
            this.menuItem_deleted.Name = "menuItem_deleted";
            this.menuItem_deleted.Size = new System.Drawing.Size(100, 22);
            this.menuItem_deleted.Text = "删除";
            this.menuItem_deleted.Click += new System.EventHandler(this.menuItem_deleted_Click);
            // 
            // FrmExpressionTab
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(450, 300);
            this.Controls.Add(this.tabExpression);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmExpressionTab";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Load += new System.EventHandler(this.FrmExpressionTab_Load);
            this.tabExpression.ResumeLayout(false);
            this.tabPageEmoji.ResumeLayout(false);
            this.tabPagGif.ResumeLayout(false);
            this.tabPageCollection.ResumeLayout(false);
            this.cmsCustomizeMenu.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion
        private CCWin.SkinControl.SkinTabPage tabPageEmoji;
        private CCWin.SkinControl.SkinTabPage tabPagGif;
        private CCWin.SkinControl.SkinTabPage tabPageCollection;
        private CCWin.SkinControl.SkinFlowLayoutPanel flpGifTab;
        private System.Windows.Forms.Panel panel1;
        private CCWin.SkinControl.SkinFlowLayoutPanel flpEmoji;
        private CCWin.SkinControl.SkinFlowLayoutPanel flpCustomize;
        private CCWin.SkinControl.SkinContextMenuStrip cmsCustomizeMenu;
        private System.Windows.Forms.ToolStripMenuItem menuItem_deleted;
        public CCWin.SkinControl.SkinTabControl tabExpression;
    }
}