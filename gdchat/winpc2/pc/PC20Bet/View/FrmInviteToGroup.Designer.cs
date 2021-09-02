namespace WinFrmTalk.View
{
    partial class FrmInviteToGroup
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
            this.lblTitle = new System.Windows.Forms.Label();
            this.btnSure = new System.Windows.Forms.Button();
            this.tabPal = new System.Windows.Forms.TableLayoutPanel();
            this.lblReson = new System.Windows.Forms.Label();
            this.usEpicAddName1 = new WinFrmTalk.Controls.CustomControls.USEpicAddName();
            this.lblGroupName = new LollipopLabel();
            this.lblInviterInfo = new LollipopLabel();
            this.lblNick = new LollipopLabel();
            this.pic = new WinFrmTalk.RoundPicBox();
            this.lblInvited = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.pic)).BeginInit();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.AutoSize = true;
            this.lblTitle.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblTitle.ForeColor = System.Drawing.Color.Black;
            this.lblTitle.Location = new System.Drawing.Point(23, 23);
            this.lblTitle.Margin = new System.Windows.Forms.Padding(3);
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(56, 17);
            this.lblTitle.TabIndex = 0;
            this.lblTitle.Text = "邀请详情";
            // 
            // btnSure
            // 
            this.btnSure.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(24)))));
            this.btnSure.FlatAppearance.BorderSize = 0;
            this.btnSure.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSure.Font = new System.Drawing.Font("宋体", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnSure.ForeColor = System.Drawing.Color.White;
            this.btnSure.Location = new System.Drawing.Point(199, 364);
            this.btnSure.Name = "btnSure";
            this.btnSure.Size = new System.Drawing.Size(165, 38);
            this.btnSure.TabIndex = 8;
            this.btnSure.Text = "确认邀请";
            this.btnSure.UseVisualStyleBackColor = false;
            this.btnSure.Click += new System.EventHandler(this.btnSure_Click);
            // 
            // tabPal
            // 
            this.tabPal.ColumnCount = 8;
            this.tabPal.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 48.86364F));
            this.tabPal.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 51.13636F));
            this.tabPal.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 46F));
            this.tabPal.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 49F));
            this.tabPal.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 55F));
            this.tabPal.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 49F));
            this.tabPal.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 54F));
            this.tabPal.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 58F));
            this.tabPal.Location = new System.Drawing.Point(79, 258);
            this.tabPal.Name = "tabPal";
            this.tabPal.RowCount = 1;
            this.tabPal.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tabPal.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tabPal.Size = new System.Drawing.Size(405, 80);
            this.tabPal.TabIndex = 11;
            // 
            // lblReson
            // 
            this.lblReson.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblReson.Location = new System.Drawing.Point(79, 207);
            this.lblReson.Name = "lblReson";
            this.lblReson.Size = new System.Drawing.Size(405, 34);
            this.lblReson.TabIndex = 12;
            this.lblReson.Text = "label1";
            this.lblReson.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblReson.UseMnemonic = false;
            // 
            // usEpicAddName1
            // 
            this.usEpicAddName1.CurrentRole = 0;
            this.usEpicAddName1.Location = new System.Drawing.Point(99, 238);
            this.usEpicAddName1.Name = "usEpicAddName1";
            this.usEpicAddName1.NickName = "";
            this.usEpicAddName1.roomjid = null;
            this.usEpicAddName1.Size = new System.Drawing.Size(40, 55);
            this.usEpicAddName1.TabIndex = 0;
            this.usEpicAddName1.Userid = null;
            // 
            // lblGroupName
            // 
            this.lblGroupName.AutoSize = true;
            this.lblGroupName.BackColor = System.Drawing.Color.Transparent;
            this.lblGroupName.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.lblGroupName.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(153)))), ((int)(((byte)(153)))), ((int)(((byte)(153)))));
            this.lblGroupName.Location = new System.Drawing.Point(196, 238);
            this.lblGroupName.Name = "lblGroupName";
            this.lblGroupName.Size = new System.Drawing.Size(0, 20);
            this.lblGroupName.TabIndex = 5;
            // 
            // lblInviterInfo
            // 
            this.lblInviterInfo.BackColor = System.Drawing.Color.Transparent;
            this.lblInviterInfo.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblInviterInfo.ForeColor = System.Drawing.Color.Black;
            this.lblInviterInfo.Location = new System.Drawing.Point(79, 166);
            this.lblInviterInfo.Name = "lblInviterInfo";
            this.lblInviterInfo.Size = new System.Drawing.Size(405, 34);
            this.lblInviterInfo.TabIndex = 4;
            this.lblInviterInfo.Text = "想邀请";
            this.lblInviterInfo.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblInviterInfo.UseMnemonic = false;
            // 
            // lblNick
            // 
            this.lblNick.BackColor = System.Drawing.Color.Transparent;
            this.lblNick.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblNick.ForeColor = System.Drawing.Color.Black;
            this.lblNick.Location = new System.Drawing.Point(79, 133);
            this.lblNick.Name = "lblNick";
            this.lblNick.Size = new System.Drawing.Size(405, 34);
            this.lblNick.TabIndex = 2;
            this.lblNick.Text = "i";
            this.lblNick.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblNick.UseMnemonic = false;
            // 
            // pic
            // 
            this.pic.isDrawRound = true;
            this.pic.Location = new System.Drawing.Point(264, 92);
            this.pic.Name = "pic";
            this.pic.Size = new System.Drawing.Size(35, 35);
            this.pic.TabIndex = 13;
            this.pic.TabStop = false;
            // 
            // lblInvited
            // 
            this.lblInvited.BackColor = System.Drawing.Color.LightGray;
            this.lblInvited.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblInvited.ForeColor = System.Drawing.Color.White;
            this.lblInvited.Location = new System.Drawing.Point(198, 364);
            this.lblInvited.Name = "lblInvited";
            this.lblInvited.Size = new System.Drawing.Size(167, 38);
            this.lblInvited.TabIndex = 14;
            this.lblInvited.Text = "确认邀请";
            this.lblInvited.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblInvited.Visible = false;
            // 
            // FrmInviteToGroup
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(560, 485);
            this.Controls.Add(this.lblInvited);
            this.Controls.Add(this.pic);
            this.Controls.Add(this.lblReson);
            this.Controls.Add(this.tabPal);
            this.Controls.Add(this.usEpicAddName1);
            this.Controls.Add(this.btnSure);
            this.Controls.Add(this.lblGroupName);
            this.Controls.Add(this.lblInviterInfo);
            this.Controls.Add(this.lblNick);
            this.Controls.Add(this.lblTitle);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmInviteToGroup";
            this.ShowDrawIcon = false;
            this.ShowIcon = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "";
            this.Load += new System.EventHandler(this.FrmInviteToGroup_Load);
            ((System.ComponentModel.ISupportInitialize)(this.pic)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblTitle;
        private LollipopLabel lblNick;
        private LollipopLabel lblInviterInfo;
        private LollipopLabel lblGroupName;
        private System.Windows.Forms.Button btnSure;
        private Controls.CustomControls.USEpicAddName usEpicAddName1;
        private System.Windows.Forms.TableLayoutPanel tabPal;
        private System.Windows.Forms.Label lblReson;
        private RoundPicBox pic;
        private System.Windows.Forms.Label lblInvited;
    }
}