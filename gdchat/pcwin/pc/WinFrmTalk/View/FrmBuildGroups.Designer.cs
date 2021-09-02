namespace WinFrmTalk.View
{
    partial class FrmBuildGroups:FrmBase
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmBuildGroups));
            this.lblTitle = new System.Windows.Forms.Label();
            this.lblGn = new System.Windows.Forms.Label();
            this.lblgb = new System.Windows.Forms.Label();
            this.btnInviteFrds = new LollipopButton();
            this.txtGroupName = new System.Windows.Forms.TextBox();
            this.txtGroupDis = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            resources.ApplyResources(this.lblTitle, "lblTitle");
            this.lblTitle.Name = "lblTitle";
            // 
            // lblGn
            // 
            resources.ApplyResources(this.lblGn, "lblGn");
            this.lblGn.Name = "lblGn";
            // 
            // lblgb
            // 
            resources.ApplyResources(this.lblgb, "lblgb");
            this.lblgb.Name = "lblgb";
            // 
            // btnInviteFrds
            // 
            this.btnInviteFrds.BackColor = System.Drawing.Color.Transparent;
            this.btnInviteFrds.BGColor = "26,181,26";
            resources.ApplyResources(this.btnInviteFrds, "btnInviteFrds");
            this.btnInviteFrds.FontColor = "#ffffff";
            this.btnInviteFrds.Name = "btnInviteFrds";
            this.btnInviteFrds.Click += new System.EventHandler(this.btnInviteFrds_Click);
            // 
            // txtGroupName
            // 
            resources.ApplyResources(this.txtGroupName, "txtGroupName");
            this.txtGroupName.Name = "txtGroupName";
            this.txtGroupName.TextChanged += new System.EventHandler(this.txtGroupName_TextChanged);
            this.txtGroupName.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtGroupName_KeyPress);
            // 
            // txtGroupDis
            // 
            resources.ApplyResources(this.txtGroupDis, "txtGroupDis");
            this.txtGroupDis.Name = "txtGroupDis";
            this.txtGroupDis.TextChanged += new System.EventHandler(this.txtGroupName_TextChanged);
            this.txtGroupDis.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtGroupName_KeyPress);
            // 
            // FrmBuildGroups
            // 
            resources.ApplyResources(this, "$this");
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.Controls.Add(this.txtGroupDis);
            this.Controls.Add(this.txtGroupName);
            this.Controls.Add(this.btnInviteFrds);
            this.Controls.Add(this.lblgb);
            this.Controls.Add(this.lblGn);
            this.Controls.Add(this.lblTitle);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmBuildGroups";
            this.ShowDrawIcon = false;
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmBuildGroups_FormClosed);
            this.Load += new System.EventHandler(this.FrmBuildGroups_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblTitle;
        private System.Windows.Forms.Label lblGn;
        private System.Windows.Forms.Label lblgb;
        private LollipopButton btnInviteFrds;
        private System.Windows.Forms.TextBox txtGroupName;
        private System.Windows.Forms.TextBox txtGroupDis;
    }
}