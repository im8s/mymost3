using System.Drawing;
using System.Linq;
using System.Windows.Forms;

namespace WinFrmTalk
{
    partial class VerifyItem
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
            this.lblNickname = new System.Windows.Forms.Label();
            this.lblContent = new System.Windows.Forms.Label();
            this.skinLine2 = new CCWin.SkinControl.SkinLine();
            this.tvShortTip = new System.Windows.Forms.Label();
            this.btnAnswer = new LollipopFlatButton();
            this.btnAccept = new LollipopButton();
            this.picAvator = new WinFrmTalk.RoundPicBox();
            ((System.ComponentModel.ISupportInitialize)(this.picAvator)).BeginInit();
            this.SuspendLayout();
            // 
            // lblNickname
            // 
            this.lblNickname.AutoSize = true;
            this.lblNickname.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.lblNickname.Location = new System.Drawing.Point(88, 12);
            this.lblNickname.Margin = new System.Windows.Forms.Padding(0);
            this.lblNickname.Name = "lblNickname";
            this.lblNickname.Size = new System.Drawing.Size(64, 21);
            this.lblNickname.TabIndex = 1;
            this.lblNickname.Text = "111111";
            this.lblNickname.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // lblContent
            // 
            this.lblContent.AutoSize = true;
            this.lblContent.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.lblContent.ForeColor = System.Drawing.Color.DimGray;
            this.lblContent.Location = new System.Drawing.Point(88, 40);
            this.lblContent.Margin = new System.Windows.Forms.Padding(0);
            this.lblContent.Name = "lblContent";
            this.lblContent.Size = new System.Drawing.Size(73, 20);
            this.lblContent.TabIndex = 2;
            this.lblContent.Text = "11111111";
            this.lblContent.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
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
            this.skinLine2.Size = new System.Drawing.Size(1822, 1);
            this.skinLine2.TabIndex = 6;
            this.skinLine2.Text = "skinLine2";
            // 
            // tvShortTip
            // 
            this.tvShortTip.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.tvShortTip.AutoSize = true;
            this.tvShortTip.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.tvShortTip.ForeColor = System.Drawing.Color.DimGray;
            this.tvShortTip.Location = new System.Drawing.Point(1795, 29);
            this.tvShortTip.Margin = new System.Windows.Forms.Padding(0);
            this.tvShortTip.Name = "tvShortTip";
            this.tvShortTip.Size = new System.Drawing.Size(51, 20);
            this.tvShortTip.TabIndex = 7;
            this.tvShortTip.Text = "已添加";
            this.tvShortTip.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // btnAnswer
            // 
            this.btnAnswer.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnAnswer.BackColor = System.Drawing.Color.Transparent;
            this.btnAnswer.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnAnswer.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnAnswer.FontColor = "#0AD007";
            this.btnAnswer.Location = new System.Drawing.Point(1329, 24);
            this.btnAnswer.Margin = new System.Windows.Forms.Padding(0);
            this.btnAnswer.Name = "btnAnswer";
            this.btnAnswer.Size = new System.Drawing.Size(80, 36);
            this.btnAnswer.TabIndex = 4;
            this.btnAnswer.Text = "回话";
            this.btnAnswer.Click += new System.EventHandler(this.btnStartAnswer_Click);
            // 
            // btnAccept
            // 
            this.btnAccept.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnAccept.BackColor = System.Drawing.Color.WhiteSmoke;
            this.btnAccept.BGColor = "#0AD007";
            this.btnAccept.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnAccept.FontColor = "#ffffff";
            this.btnAccept.Location = new System.Drawing.Point(1231, 24);
            this.btnAccept.Margin = new System.Windows.Forms.Padding(0);
            this.btnAccept.Name = "btnAccept";
            this.btnAccept.Size = new System.Drawing.Size(80, 36);
            this.btnAccept.TabIndex = 3;
            this.btnAccept.Text = "通过验证";
            this.btnAccept.Click += new System.EventHandler(this.BtnAccept_Click);
            // 
            // picAvator
            // 
            this.picAvator.isDrawRound = true;
            this.picAvator.Location = new System.Drawing.Point(32, 11);
            this.picAvator.Margin = new System.Windows.Forms.Padding(0);
            this.picAvator.Name = "picAvator";
            this.picAvator.Size = new System.Drawing.Size(48, 48);
            this.picAvator.TabIndex = 0;
            this.picAvator.TabStop = false;
            // 
            // VerifyItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Controls.Add(this.tvShortTip);
            this.Controls.Add(this.skinLine2);
            this.Controls.Add(this.btnAnswer);
            this.Controls.Add(this.btnAccept);
            this.Controls.Add(this.lblContent);
            this.Controls.Add(this.lblNickname);
            this.Controls.Add(this.picAvator);
            this.Margin = new System.Windows.Forms.Padding(0);
            this.Name = "VerifyItem";
            this.Size = new System.Drawing.Size(1432, 72);
            ((System.ComponentModel.ISupportInitialize)(this.picAvator)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private RoundPicBox picAvator;
        private System.Windows.Forms.Label lblNickname;
        private System.Windows.Forms.Label lblContent;
        private LollipopButton btnAccept;
        private LollipopFlatButton btnAnswer;
        private CCWin.SkinControl.SkinLine skinLine2;
        private Label tvShortTip;
    }
}
