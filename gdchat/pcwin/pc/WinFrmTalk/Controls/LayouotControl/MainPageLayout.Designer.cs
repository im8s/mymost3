namespace WinFrmTalk.Controls.LayouotControl
{
    partial class MainPageLayout
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
            WinFrmTalk.Model.Friend friend1 = new WinFrmTalk.Model.Friend();
            WinFrmTalk.Model.Friend friend2 = new WinFrmTalk.Model.Friend();
            this.UserVerifyPage = new WinFrmTalk.USEUserVerifyPage();
            this.groupInfo = new WinFrmTalk.Controls.CustomControls.UseGroupInfo();
            this.sendMsgPanel = new WinFrmTalk.Controls.CustomControls.ShowMsgPanel();
            this.FriendInfo = new WinFrmTalk.Controls.CustomControls.USEFriendInfo();
            this.BlockPage = new WinFrmTalk.BlockListPage();
            this.SuspendLayout();
            // 
            // UserVerifyPage
            // 
            this.UserVerifyPage.BackColor = System.Drawing.Color.Transparent;
            this.UserVerifyPage.Dock = System.Windows.Forms.DockStyle.Fill;
            this.UserVerifyPage.Location = new System.Drawing.Point(0, 0);
            this.UserVerifyPage.Margin = new System.Windows.Forms.Padding(0);
            this.UserVerifyPage.Name = "UserVerifyPage";
            this.UserVerifyPage.Size = new System.Drawing.Size(740, 547);
            this.UserVerifyPage.TabIndex = 3;
            // 
            // groupInfo
            // 
            this.groupInfo.AutoSize = true;
            this.groupInfo.Dock = System.Windows.Forms.DockStyle.Fill;
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
            this.groupInfo.GroupInfo = friend1;
            this.groupInfo.Location = new System.Drawing.Point(0, 0);
            this.groupInfo.Name = "groupInfo";
            this.groupInfo.SendAction = null;
            this.groupInfo.Size = new System.Drawing.Size(740, 547);
            this.groupInfo.TabIndex = 0;
            // 
            // sendMsgPanel
            // 
            this.sendMsgPanel.AutoSize = true;
            friend2.AllowConference = 0;
            friend2.AllowInviteFriend = 0;
            friend2.AllowSendCard = 0;
            friend2.AllowSpeakCourse = 0;
            friend2.AllowUploadFile = 0;
            friend2.AreaCode = null;
            friend2.AreaId = 0;
            friend2.Birthday = ((long)(0));
            friend2.CityId = 0;
            friend2.Content = null;
            friend2.CreateTime = 0;
            friend2.Description = null;
            friend2.DownloadRoamEndTime = 0D;
            friend2.DownloadRoamStartTime = 0D;
            friend2.IsAtMe = 0;
            friend2.UserType = 0;
            friend2.IsGroup = 0;
            friend2.IsNeedVerify = 0;
            friend2.IsOnLine = 0;
            friend2.IsOpenReadDel = 0;
            friend2.IsSendRecipt = 0;
            friend2.LastInput = null;
            friend2.LastMsgTime = 0D;
            friend2.LastMsgType = 0;
            friend2.MsgNum = 0;
            friend2.NickName = null;
            friend2.ProvinceId = 0;
            friend2.RemarkName = null;
            friend2.Role = null;
            friend2.RoomId = null;
            friend2.Sex = 0;
            friend2.ShowMember = 0;
            friend2.ShowRead = 0;
            friend2.Status = 0;
            friend2.Telephone = null;
            friend2.TopTime = 0;
            friend2.UserId = null;
            this.sendMsgPanel.ChooseTarget = friend2;
            this.sendMsgPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.sendMsgPanel.Location = new System.Drawing.Point(0, 0);
            this.sendMsgPanel.Name = "sendMsgPanel";
            this.sendMsgPanel.Size = new System.Drawing.Size(740, 547);
            this.sendMsgPanel.TabIndex = 2;
            this.sendMsgPanel.TabStop = false;
            // 
            // FriendInfo
            // 
            this.FriendInfo.AutoSize = true;
            this.FriendInfo.BackColor = System.Drawing.Color.WhiteSmoke;
            this.FriendInfo.Birthday = "2019-00-00";
            this.FriendInfo.Dock = System.Windows.Forms.DockStyle.Fill;
            this.FriendInfo.Friend = null;
            this.FriendInfo.Location = new System.Drawing.Point(0, 0);
            this.FriendInfo.LocationName = "广东省深圳市";
            this.FriendInfo.Name = "FriendInfo";
            this.FriendInfo.Nickname = "I N S O";
            this.FriendInfo.Remarks = "视酷";
            this.FriendInfo.SendAction = null;
            this.FriendInfo.Sex = "男";
            this.FriendInfo.Size = new System.Drawing.Size(740, 547);
            this.FriendInfo.TabIndex = 1;
            // 
            // BlockPage
            // 
            this.BlockPage.BackColor = System.Drawing.Color.Transparent;
            this.BlockPage.Dock = System.Windows.Forms.DockStyle.Fill;
            this.BlockPage.Location = new System.Drawing.Point(0, 0);
            this.BlockPage.Margin = new System.Windows.Forms.Padding(0);
            this.BlockPage.Name = "BlockPage";
            this.BlockPage.Size = new System.Drawing.Size(740, 547);
            this.BlockPage.TabIndex = 4;
            // 
            // MainPageLayout
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSize = true;
            this.Controls.Add(this.BlockPage);
            this.Controls.Add(this.UserVerifyPage);
            this.Controls.Add(this.groupInfo);
            this.Controls.Add(this.sendMsgPanel);
            this.Controls.Add(this.FriendInfo);
            this.Name = "MainPageLayout";
            this.Size = new System.Drawing.Size(740, 547);
            this.Load += new System.EventHandler(this.MainPageLayout_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private CustomControls.UseGroupInfo groupInfo;
        private CustomControls.USEFriendInfo FriendInfo;
        private USEUserVerifyPage UserVerifyPage;
        private BlockListPage BlockPage;
        public CustomControls.ShowMsgPanel sendMsgPanel;
    }
}
