using TestListView;

namespace WinFrmTalk.Controls.CustomControls
{
    partial class UserLabel
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
            this.btnCreate = new System.Windows.Forms.Button();
            this.lblTitle = new System.Windows.Forms.Label();
            this.pnlLabel = new TestListView.XListView();
            this.pnlFriend = new TestListView.XListView();
            this.SuspendLayout();
            // 
            // btnCreate
            // 
            this.btnCreate.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnCreate.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.btnCreate.FlatAppearance.BorderSize = 0;
            this.btnCreate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCreate.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnCreate.ForeColor = System.Drawing.Color.White;
            this.btnCreate.Location = new System.Drawing.Point(73, 530);
            this.btnCreate.Name = "btnCreate";
            this.btnCreate.Size = new System.Drawing.Size(68, 25);
            this.btnCreate.TabIndex = 31;
            this.btnCreate.Text = "创建标签";
            this.btnCreate.UseVisualStyleBackColor = false;
            this.btnCreate.Click += new System.EventHandler(this.OnCreateLable);
            // 
            // lblTitle
            // 
            this.lblTitle.Font = new System.Drawing.Font("微软雅黑", 15F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblTitle.Location = new System.Drawing.Point(17, 0);
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(92, 27);
            this.lblTitle.TabIndex = 32;
            this.lblTitle.Text = "好友标签";
            this.lblTitle.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // pnlLabel
            // 
            this.pnlLabel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.pnlLabel.BackColor = System.Drawing.Color.WhiteSmoke;
            this.pnlLabel.Location = new System.Drawing.Point(3, 35);
            this.pnlLabel.Name = "pnlLabel";
            this.pnlLabel.ScrollBarWidth = 10;
            this.pnlLabel.Size = new System.Drawing.Size(250, 438);
            this.pnlLabel.TabIndex = 27;
            // 
            // pnlFriend
            // 
            this.pnlFriend.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.pnlFriend.BackColor = System.Drawing.Color.WhiteSmoke;
            this.pnlFriend.Location = new System.Drawing.Point(259, 35);
            this.pnlFriend.Name = "pnlFriend";
            this.pnlFriend.ScrollBarWidth = 10;
            this.pnlFriend.Size = new System.Drawing.Size(222, 520);
            this.pnlFriend.TabIndex = 27;
            // 
            // UserLabel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.Controls.Add(this.lblTitle);
            this.Controls.Add(this.btnCreate);
            this.Controls.Add(this.pnlLabel);
            this.Controls.Add(this.pnlFriend);
            this.Name = "UserLabel";
            this.Size = new System.Drawing.Size(493, 598);
            this.ResumeLayout(false);

        }

        #endregion

        private XListView pnlFriend;
        private XListView pnlLabel;
        private System.Windows.Forms.Button btnCreate;
        private System.Windows.Forms.Label lblTitle;
    }
}
