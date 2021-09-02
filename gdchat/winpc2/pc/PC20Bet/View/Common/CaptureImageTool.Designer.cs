namespace WinFrmTalk
{
    partial class CaptureImageTool
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

        #region Windows 窗体设计器生成的代码

        /// <summary>
        /// 设计器支持所需的方法 - 不要
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.toolTip = new System.Windows.Forms.ToolTip(this.components);
            this.saveFileDialog = new System.Windows.Forms.SaveFileDialog();
            this.textBox = new System.Windows.Forms.TextBox();
            this.colorSelector = new ColorSelector();
            this.drawToolsControl = new DrawToolsControl();
            this.SuspendLayout();
            // 
            // saveFileDialog
            // 
            this.saveFileDialog.DefaultExt = "bmp";
            this.saveFileDialog.Filter = "BMP 文件(*.bmp)|*.bmp|JPEG 文件(*.jpg,*.jpeg)|*.jpg,*.jpeg|PNG 文件(*.png)|*.png|GIF 文件" +
    "(*.gif)|*.gif";
            // 
            // textBox
            // 
            this.textBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.textBox.ImeMode = System.Windows.Forms.ImeMode.On;
            this.textBox.Location = new System.Drawing.Point(2, 233);
            this.textBox.Multiline = true;
            this.textBox.Name = "textBox";
            this.textBox.Size = new System.Drawing.Size(100, 21);
            this.textBox.TabIndex = 4;
            // 
            // colorSelector
            // 
            this.colorSelector.BackColor = System.Drawing.SystemColors.ActiveCaptionText;
            this.colorSelector.Location = new System.Drawing.Point(2, 189);
            this.colorSelector.Margin = new System.Windows.Forms.Padding(4);
            this.colorSelector.Name = "colorSelector";
            this.colorSelector.Padding = new System.Windows.Forms.Padding(2);
            this.colorSelector.Size = new System.Drawing.Size(189, 38);
            this.colorSelector.TabIndex = 3;
            // 
            // drawToolsControl
            // 
            this.drawToolsControl.AutoValidate = System.Windows.Forms.AutoValidate.EnableAllowFocusChange;
            this.drawToolsControl.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(245)))), ((int)(((byte)(245)))), ((int)(((byte)(245)))));
            this.drawToolsControl.Location = new System.Drawing.Point(2, 141);
            this.drawToolsControl.Margin = new System.Windows.Forms.Padding(4);
            this.drawToolsControl.Name = "drawToolsControl";
            this.drawToolsControl.Padding = new System.Windows.Forms.Padding(2);
            this.drawToolsControl.Size = new System.Drawing.Size(417, 40);
            this.drawToolsControl.TabIndex = 0;
            // 
            // CaptureImageTool
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.ClientSize = new System.Drawing.Size(319, 266);
            this.Controls.Add(this.textBox);
            this.Controls.Add(this.colorSelector);
            this.Controls.Add(this.drawToolsControl);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.MinimizeBox = false;
            this.Name = "CaptureImageTool";
            this.Text = "CaptureImageTool";
            this.TopMost = true;
            this.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.CaptureImageTool_KeyPress);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ToolTip toolTip;
        private DrawToolsControl drawToolsControl;
        private System.Windows.Forms.SaveFileDialog saveFileDialog;
        private ColorSelector colorSelector;
        private System.Windows.Forms.TextBox textBox;
    }
}