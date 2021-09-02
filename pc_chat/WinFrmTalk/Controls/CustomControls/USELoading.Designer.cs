using System.Drawing;

namespace WinFrmTalk
{
    partial class USELoading
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
            this.loadBox1 = new WinFrmTalk.LoadBox();
            this.SuspendLayout();
            // 
            // loadBox1
            // 
            this.loadBox1.Active = true;
            this.loadBox1.BackColor = System.Drawing.Color.Transparent;
            this.loadBox1.Color = System.Drawing.Color.Black;
            this.loadBox1.InnerCircleRadius = 5;
            this.loadBox1.Location = new System.Drawing.Point(58, 55);
            this.loadBox1.Margin = new System.Windows.Forms.Padding(0);
            this.loadBox1.Name = "loadBox1";
            this.loadBox1.NumberSpoke = 12;
            this.loadBox1.OuterCircleRadius = 11;
            this.loadBox1.RotationSpeed = 154;
            this.loadBox1.Size = new System.Drawing.Size(37, 34);
            this.loadBox1.SpokeThickness = 2;
            this.loadBox1.StylePreset = WinFrmTalk.LoadBox.StylePresets.MacOSX;
            this.loadBox1.TabIndex = 1;
            this.loadBox1.Text = "loadBox1";
            // 
            // USELoading
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = Color.FromArgb(206, 94, 94, 94);
            this.Controls.Add(this.loadBox1);
            this.Margin = new System.Windows.Forms.Padding(0);
            this.Name = "USELoading";
            this.ResumeLayout(false);

        }

        #endregion

        private LoadBox loadBox1;
    }
}
