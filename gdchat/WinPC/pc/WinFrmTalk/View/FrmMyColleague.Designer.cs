namespace WinFrmTalk
{
    partial class FrmMyColleague
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmMyColleague));
            this.cmsCompany = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.AddDepartment = new System.Windows.Forms.ToolStripMenuItem();
            this.EditCompany = new System.Windows.Forms.ToolStripMenuItem();
            this.QuitCompany = new System.Windows.Forms.ToolStripMenuItem();
            this.DeleteCompany = new System.Windows.Forms.ToolStripMenuItem();
            this.cmsDepartment = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.AddSubdivisions = new System.Windows.Forms.ToolStripMenuItem();
            this.AddMember = new System.Windows.Forms.ToolStripMenuItem();
            this.EditDepartmentName = new System.Windows.Forms.ToolStripMenuItem();
            this.DeleteDepartment = new System.Windows.Forms.ToolStripMenuItem();
            this.cmsStaff = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.tsmDetails = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmReplaceDepar = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmEditPosition = new System.Windows.Forms.ToolStripMenuItem();
            this.tsmDeleteStaff = new System.Windows.Forms.ToolStripMenuItem();
            this.btnCreate = new System.Windows.Forms.Button();
            this.pnlMyColleague = new WinFrmTalk.MyTabLayoutPanel();
            this.lblNodeName = new System.Windows.Forms.Label();
            this.tvwColleague = new WinFrmTalk.NewTreeView();
            this.label1 = new System.Windows.Forms.Label();
            this.cmsCompany.SuspendLayout();
            this.cmsDepartment.SuspendLayout();
            this.cmsStaff.SuspendLayout();
            this.SuspendLayout();
            // 
            // cmsCompany
            // 
            this.cmsCompany.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.cmsCompany.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.AddDepartment,
            this.EditCompany,
            this.QuitCompany,
            this.DeleteCompany});
            this.cmsCompany.Name = "contextMenuStrip1";
            this.cmsCompany.Size = new System.Drawing.Size(149, 92);
            // 
            // AddDepartment
            // 
            this.AddDepartment.Name = "AddDepartment";
            this.AddDepartment.Size = new System.Drawing.Size(148, 22);
            this.AddDepartment.Text = "添加部门";
            this.AddDepartment.Click += new System.EventHandler(this.AddDepartment_Click);
            // 
            // EditCompany
            // 
            this.EditCompany.Name = "EditCompany";
            this.EditCompany.Size = new System.Drawing.Size(148, 22);
            this.EditCompany.Text = "修改公司名称";
            this.EditCompany.Click += new System.EventHandler(this.EditCompany_Click);
            // 
            // QuitCompany
            // 
            this.QuitCompany.Name = "QuitCompany";
            this.QuitCompany.Size = new System.Drawing.Size(148, 22);
            this.QuitCompany.Text = "退出公司";
            this.QuitCompany.Click += new System.EventHandler(this.QuitCompany_Click);
            // 
            // DeleteCompany
            // 
            this.DeleteCompany.Name = "DeleteCompany";
            this.DeleteCompany.Size = new System.Drawing.Size(148, 22);
            this.DeleteCompany.Text = "删除公司";
            this.DeleteCompany.Click += new System.EventHandler(this.DeleteCompany_Click);
            // 
            // cmsDepartment
            // 
            this.cmsDepartment.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.cmsDepartment.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.AddSubdivisions,
            this.AddMember,
            this.EditDepartmentName,
            this.DeleteDepartment});
            this.cmsDepartment.Name = "contextMenuStrip2";
            this.cmsDepartment.Size = new System.Drawing.Size(149, 92);
            // 
            // AddSubdivisions
            // 
            this.AddSubdivisions.Name = "AddSubdivisions";
            this.AddSubdivisions.Size = new System.Drawing.Size(148, 22);
            this.AddSubdivisions.Text = "添加子部门";
            this.AddSubdivisions.Click += new System.EventHandler(this.AddSubdivisions_Click);
            // 
            // AddMember
            // 
            this.AddMember.Name = "AddMember";
            this.AddMember.Size = new System.Drawing.Size(148, 22);
            this.AddMember.Text = "添加成员";
            this.AddMember.Click += new System.EventHandler(this.AddMember_Click);
            // 
            // EditDepartmentName
            // 
            this.EditDepartmentName.Name = "EditDepartmentName";
            this.EditDepartmentName.Size = new System.Drawing.Size(148, 22);
            this.EditDepartmentName.Text = "修改部门名称";
            this.EditDepartmentName.Click += new System.EventHandler(this.EditDepartmentName_Click);
            // 
            // DeleteDepartment
            // 
            this.DeleteDepartment.Name = "DeleteDepartment";
            this.DeleteDepartment.Size = new System.Drawing.Size(148, 22);
            this.DeleteDepartment.Text = "删除部门";
            this.DeleteDepartment.Click += new System.EventHandler(this.DeleteDepartment_Click);
            // 
            // cmsStaff
            // 
            this.cmsStaff.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.cmsStaff.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.tsmDetails,
            this.tsmReplaceDepar,
            this.tsmEditPosition,
            this.tsmDeleteStaff});
            this.cmsStaff.Name = "cmsStaff";
            this.cmsStaff.Size = new System.Drawing.Size(125, 92);
            // 
            // tsmDetails
            // 
            this.tsmDetails.Name = "tsmDetails";
            this.tsmDetails.Size = new System.Drawing.Size(124, 22);
            this.tsmDetails.Text = "详情";
            this.tsmDetails.Click += new System.EventHandler(this.tsmDetails_Click);
            // 
            // tsmReplaceDepar
            // 
            this.tsmReplaceDepar.Name = "tsmReplaceDepar";
            this.tsmReplaceDepar.Size = new System.Drawing.Size(124, 22);
            this.tsmReplaceDepar.Text = "更换部门";
            // 
            // tsmEditPosition
            // 
            this.tsmEditPosition.Name = "tsmEditPosition";
            this.tsmEditPosition.Size = new System.Drawing.Size(124, 22);
            this.tsmEditPosition.Text = "修改职位";
            this.tsmEditPosition.Click += new System.EventHandler(this.tsmEditPosition_Click);
            // 
            // tsmDeleteStaff
            // 
            this.tsmDeleteStaff.Name = "tsmDeleteStaff";
            this.tsmDeleteStaff.Size = new System.Drawing.Size(124, 22);
            this.tsmDeleteStaff.Text = "删除员工";
            this.tsmDeleteStaff.Click += new System.EventHandler(this.tsmDeleteStaff_Click);
            // 
            // btnCreate
            // 
            this.btnCreate.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(140)))), ((int)(((byte)(213)))), ((int)(((byte)(140)))));
            this.btnCreate.FlatAppearance.BorderSize = 0;
            this.btnCreate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCreate.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.btnCreate.ForeColor = System.Drawing.Color.White;
            this.btnCreate.Location = new System.Drawing.Point(94, 557);
            this.btnCreate.Name = "btnCreate";
            this.btnCreate.Size = new System.Drawing.Size(68, 25);
            this.btnCreate.TabIndex = 25;
            this.btnCreate.Text = "创建公司";
            this.btnCreate.UseVisualStyleBackColor = false;
            this.btnCreate.Click += new System.EventHandler(this.btnCreate_Click);
            // 
            // pnlMyColleague
            // 
            this.pnlMyColleague.BackColor = System.Drawing.Color.White;
            this.pnlMyColleague.Location = new System.Drawing.Point(274, 72);
            this.pnlMyColleague.Name = "pnlMyColleague";
            this.pnlMyColleague.Size = new System.Drawing.Size(260, 510);
            this.pnlMyColleague.TabIndex = 6;
            this.pnlMyColleague.v_scale = 30;
            // 
            // lblNodeName
            // 
            this.lblNodeName.AutoSize = true;
            this.lblNodeName.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.lblNodeName.Location = new System.Drawing.Point(50, 37);
            this.lblNodeName.Name = "lblNodeName";
            this.lblNodeName.Size = new System.Drawing.Size(39, 17);
            this.lblNodeName.TabIndex = 7;
            this.lblNodeName.Text = "NULL";
            this.lblNodeName.UseMnemonic = false;
            this.lblNodeName.Click += new System.EventHandler(this.lblNodeName_Click);
            // 
            // tvwColleague
            // 
            this.tvwColleague.BackColor = System.Drawing.Color.White;
            this.tvwColleague.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.tvwColleague.DrawMode = System.Windows.Forms.TreeViewDrawMode.OwnerDrawAll;
            this.tvwColleague.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Bold);
            this.tvwColleague.HotTracking = true;
            this.tvwColleague.Indent = 20;
            this.tvwColleague.ItemHeight = 30;
            this.tvwColleague.Location = new System.Drawing.Point(7, 72);
            this.tvwColleague.Name = "tvwColleague";
            this.tvwColleague.Size = new System.Drawing.Size(260, 464);
            this.tvwColleague.TabIndex = 13;
            this.tvwColleague.NodeMouseClick += new System.Windows.Forms.TreeNodeMouseClickEventHandler(this.newTreeView1_NodeMouseClick);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label1.Location = new System.Drawing.Point(7, 37);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(44, 17);
            this.label1.TabIndex = 19;
            this.label1.Text = "层次：";
            this.label1.UseMnemonic = false;
            this.label1.Click += new System.EventHandler(this.label1_Click);
            // 
            // FrmMyColleague
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(546, 598);
            this.Controls.Add(this.btnCreate);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.tvwColleague);
            this.Controls.Add(this.lblNodeName);
            this.Controls.Add(this.pnlMyColleague);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.Name = "FrmMyColleague";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "我的同事";
            this.TitleColor = System.Drawing.Color.Gray;
            this.cmsCompany.ResumeLayout(false);
            this.cmsDepartment.ResumeLayout(false);
            this.cmsStaff.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.ContextMenuStrip cmsCompany;
        private System.Windows.Forms.ToolStripMenuItem AddDepartment;
        private System.Windows.Forms.ToolStripMenuItem EditCompany;
        private System.Windows.Forms.ToolStripMenuItem QuitCompany;
        private System.Windows.Forms.ToolStripMenuItem DeleteCompany;
        private System.Windows.Forms.ContextMenuStrip cmsDepartment;
        private System.Windows.Forms.ToolStripMenuItem AddSubdivisions;
        private System.Windows.Forms.ToolStripMenuItem AddMember;
        private System.Windows.Forms.ToolStripMenuItem EditDepartmentName;
        private System.Windows.Forms.ToolStripMenuItem DeleteDepartment;
        private System.Windows.Forms.ContextMenuStrip cmsStaff;
        private System.Windows.Forms.ToolStripMenuItem tsmDetails;
        private System.Windows.Forms.ToolStripMenuItem tsmReplaceDepar;
        private System.Windows.Forms.ToolStripMenuItem tsmEditPosition;
        private System.Windows.Forms.ToolStripMenuItem tsmDeleteStaff;
        private System.Windows.Forms.Button btnCreate;
        private MyTabLayoutPanel pnlMyColleague;
        private System.Windows.Forms.Label lblNodeName;
        private NewTreeView tvwColleague;
        private System.Windows.Forms.Label label1;
    }
}