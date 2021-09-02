namespace WinFrmTalk.View
{
    partial class FrmSeparateChat
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
            WinFrmTalk.Model.Friend friend1 = new WinFrmTalk.Model.Friend();
            this.sendMsgPanel = new WinFrmTalk.Controls.CustomControls.SendMsgPanel();
            this.SuspendLayout();
            // 
            // sendMsgPanel
            // 
            this.sendMsgPanel.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            friend1.AllowConference = 0;
            friend1.AllowInviteFriend = 0;
            friend1.AllowSendCard = 0;
            friend1.AllowSpeakCourse = 0;
            friend1.AllowUploadFile = 0;
            friend1.AreaCode = null;
            friend1.AreaId = 0;
            friend1.Birthday = ((long)(0));
            friend1.CityId = 0;
            friend1.Content = null;
            friend1.CreateTime = 0;
            friend1.Description = null;
            friend1.DownloadRoamEndTime = 0D;
            friend1.DownloadRoamStartTime = 0D;
            friend1.IsAtMe = 0;
            friend1.IsDevice = 0;
            friend1.IsGroup = 0;
            friend1.IsNeedVerify = 0;
            friend1.IsOnLine = 0;
            friend1.IsOpenReadDel = 0;
            friend1.IsSendRecipt = 0;
            friend1.LastInput = null;
            friend1.LastMsgTime = 0D;
            friend1.LastMsgType = 0;
            friend1.MsgNum = 0;
            friend1.NickName = null;
            friend1.ProvinceId = 0;
            friend1.RemarkName = null;
            friend1.Role = null;
            friend1.RoomId = null;
            friend1.Sex = 0;
            friend1.ShowMember = 0;
            friend1.ShowRead = 0;
            friend1.Status = 0;
            friend1.Telephone = null;
            friend1.TopTime = 0;
            friend1.UserId = null;
            this.sendMsgPanel.choose_target = friend1;
            this.sendMsgPanel.Location = new System.Drawing.Point(0, 26);
            this.sendMsgPanel.Name = "sendMsgPanel";
            this.sendMsgPanel.Size = new System.Drawing.Size(550, 614);
            this.sendMsgPanel.TabIndex = 0;
            this.sendMsgPanel.TabStop = false;
            // 
            // FrmSeparateChat
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(550, 640);
            this.Controls.Add(this.sendMsgPanel);
            this.Name = "FrmSeparateChat";
            this.Text = "";
            this.Load += new System.EventHandler(this.FrmSeparateChat_Load);
            this.ResumeLayout(false);

        }

        #endregion

        public Controls.CustomControls.SendMsgPanel sendMsgPanel;
    }
}