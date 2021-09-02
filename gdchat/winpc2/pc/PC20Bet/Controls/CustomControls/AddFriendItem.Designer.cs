using WinFrmTalk.Controls;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    partial class AddFriendItem
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
            WinFrmTalk.Model.Friend friend2 = new WinFrmTalk.Model.Friend();
            this.btnAction = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.friendItem = new WinFrmTalk.Controls.FriendItem();
            this.SuspendLayout();
            // 
            // btnAction
            // 
            this.btnAction.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.btnAction.FlatAppearance.BorderSize = 0;
            this.btnAction.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnAction.ForeColor = System.Drawing.Color.White;
            this.btnAction.Location = new System.Drawing.Point(194, 13);
            this.btnAction.Name = "btnAction";
            this.btnAction.Size = new System.Drawing.Size(64, 25);
            this.btnAction.TabIndex = 8;
            this.btnAction.Text = "添加";
            this.btnAction.UseVisualStyleBackColor = false;
            this.btnAction.Click += new System.EventHandler(this.btnAdd_Click);
            this.btnAction.MouseEnter += new System.EventHandler(this.btnAdd_MouseEnter);
            this.btnAction.MouseLeave += new System.EventHandler(this.btnAdd_MouseLeave);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.BackColor = System.Drawing.Color.Transparent;
            this.label1.Font = new System.Drawing.Font(Applicate.SetFont, 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label1.Location = new System.Drawing.Point(204, 19);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(44, 17);
            this.label1.TabIndex = 9;
            this.label1.Text = "已添加";
            this.label1.Visible = false;
            // 
            // friendItem
            // 
            this.friendItem.BackColor = System.Drawing.Color.Transparent;
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
            friend2.IsAtMe = 0;
            friend2.UserType = 0;
            friend2.IsGroup = 0;
            friend2.IsNeedVerify = 0;
            friend2.IsOnLine = 0;
            friend2.IsOpenReadDel = 0;
            friend2.IsSendRecipt = 0;
            friend2.LastInput = null;
            friend2.LastMsgTime = 0;
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
            this.friendItem.FriendData = friend2;
            this.friendItem.IsSelected = false;
            this.friendItem.Location = new System.Drawing.Point(0, 0);
            this.friendItem.Margin = new System.Windows.Forms.Padding(0);
            this.friendItem.Name = "friendItem";
            this.friendItem.Size = new System.Drawing.Size(276, 50);
            this.friendItem.TabIndex = 7;
            this.friendItem.MouseEnter += new System.EventHandler(this.friendItem_MouseEnter);
            this.friendItem.MouseLeave += new System.EventHandler(this.friendItem_MouseLeave);
            // 
            // AddFriendItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.label1);
            this.Controls.Add(this.btnAction);
            this.Controls.Add(this.friendItem);
            this.Font = new System.Drawing.Font("宋体", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.Name = "AddFriendItem";
            this.Size = new System.Drawing.Size(276, 50);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private FriendItem friendItem;
        public System.Windows.Forms.Label label1;
        public System.Windows.Forms.Button btnAction;
    }
}
