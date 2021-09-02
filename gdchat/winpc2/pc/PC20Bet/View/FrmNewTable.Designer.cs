namespace WinFrmTalk.View
{
    partial class FrmNewTable
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
            this.showMsgPanel = new WinFrmTalk.Controls.CustomControls.ShowMsgPanel();
            this.SuspendLayout();
            // 
            // showMsgPanel
            // 
            this.showMsgPanel.BackColor = System.Drawing.Color.WhiteSmoke;
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
            friend1.UserType = 0;
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
            this.showMsgPanel.ChooseTarget = friend1;
            this.showMsgPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.showMsgPanel.Location = new System.Drawing.Point(4, 28);
            this.showMsgPanel.Name = "showMsgPanel";
            this.showMsgPanel.Size = new System.Drawing.Size(592, 608);
            this.showMsgPanel.TabIndex = 6;
            // 
            // FrmNewTable
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(600, 640);
            this.Controls.Add(this.showMsgPanel);
            this.Name = "FrmNewTable";
            this.ShowDrawIcon = false;
            this.ShowIcon = false;
            this.Text = "";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmNewTable_FormClosed);
            this.Load += new System.EventHandler(this.FrmNewTable_Load);
            this.ResumeLayout(false);

        }

        #endregion

        public Controls.CustomControls.ShowMsgPanel showMsgPanel;
    }
}