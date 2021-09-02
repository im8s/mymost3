namespace WinFrmTalk.View
{
    partial class FrmAddstate
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmAddstate));
            this.chkeq = new WinFrmTalk.Controls.CustomControls.CheckBoxEx();
            this.chkgroup = new WinFrmTalk.Controls.CustomControls.CheckBoxEx();
            this.chkcard = new WinFrmTalk.Controls.CustomControls.CheckBoxEx();
            this.chktel = new WinFrmTalk.Controls.CustomControls.CheckBoxEx();
            this.chknick = new WinFrmTalk.Controls.CustomControls.CheckBoxEx();
            this.chkother = new WinFrmTalk.Controls.CustomControls.CheckBoxEx();
            this.label1 = new System.Windows.Forms.Label();
            this.btnsure = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // chkeq
            // 
            this.chkeq.AutoSize = true;
            this.chkeq.BackColor = System.Drawing.Color.Transparent;
            this.chkeq.BaseColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.chkeq.ControlState = CCWin.SkinClass.ControlState.Normal;
            this.chkeq.DefaultCheckButtonWidth = 19;
            this.chkeq.DownBack = null;
            this.chkeq.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.chkeq.Location = new System.Drawing.Point(32, 35);
            this.chkeq.MouseBack = ((System.Drawing.Image)(resources.GetObject("chkeq.MouseBack")));
            this.chkeq.Name = "chkeq";
            this.chkeq.NormlBack = ((System.Drawing.Image)(resources.GetObject("chkeq.NormlBack")));
            this.chkeq.SelectedDownBack = ((System.Drawing.Image)(resources.GetObject("chkeq.SelectedDownBack")));
            this.chkeq.SelectedMouseBack = ((System.Drawing.Image)(resources.GetObject("chkeq.SelectedMouseBack")));
            this.chkeq.SelectedNormlBack = ((System.Drawing.Image)(resources.GetObject("chkeq.SelectedNormlBack")));
            this.chkeq.Size = new System.Drawing.Size(63, 21);
            this.chkeq.TabIndex = 1;
            this.chkeq.Tag = "1";
            this.chkeq.Text = "二维码";
            this.chkeq.UseVisualStyleBackColor = false;
            // 
            // chkgroup
            // 
            this.chkgroup.AutoSize = true;
            this.chkgroup.BackColor = System.Drawing.Color.Transparent;
            this.chkgroup.BaseColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.chkgroup.ControlState = CCWin.SkinClass.ControlState.Normal;
            this.chkgroup.DefaultCheckButtonWidth = 19;
            this.chkgroup.DownBack = null;
            this.chkgroup.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.chkgroup.Location = new System.Drawing.Point(32, 102);
            this.chkgroup.MouseBack = ((System.Drawing.Image)(resources.GetObject("chkgroup.MouseBack")));
            this.chkgroup.Name = "chkgroup";
            this.chkgroup.NormlBack = ((System.Drawing.Image)(resources.GetObject("chkgroup.NormlBack")));
            this.chkgroup.SelectedDownBack = ((System.Drawing.Image)(resources.GetObject("chkgroup.SelectedDownBack")));
            this.chkgroup.SelectedMouseBack = ((System.Drawing.Image)(resources.GetObject("chkgroup.SelectedMouseBack")));
            this.chkgroup.SelectedNormlBack = ((System.Drawing.Image)(resources.GetObject("chkgroup.SelectedNormlBack")));
            this.chkgroup.Size = new System.Drawing.Size(51, 21);
            this.chkgroup.TabIndex = 2;
            this.chkgroup.Tag = "3";
            this.chkgroup.Text = "群组";
            this.chkgroup.UseVisualStyleBackColor = false;
            // 
            // chkcard
            // 
            this.chkcard.AutoSize = true;
            this.chkcard.BackColor = System.Drawing.Color.Transparent;
            this.chkcard.BaseColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.chkcard.ControlState = CCWin.SkinClass.ControlState.Normal;
            this.chkcard.DefaultCheckButtonWidth = 19;
            this.chkcard.DownBack = null;
            this.chkcard.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.chkcard.Location = new System.Drawing.Point(32, 66);
            this.chkcard.MouseBack = ((System.Drawing.Image)(resources.GetObject("chkcard.MouseBack")));
            this.chkcard.Name = "chkcard";
            this.chkcard.NormlBack = ((System.Drawing.Image)(resources.GetObject("chkcard.NormlBack")));
            this.chkcard.SelectedDownBack = ((System.Drawing.Image)(resources.GetObject("chkcard.SelectedDownBack")));
            this.chkcard.SelectedMouseBack = ((System.Drawing.Image)(resources.GetObject("chkcard.SelectedMouseBack")));
            this.chkcard.SelectedNormlBack = ((System.Drawing.Image)(resources.GetObject("chkcard.SelectedNormlBack")));
            this.chkcard.Size = new System.Drawing.Size(51, 21);
            this.chkcard.TabIndex = 3;
            this.chkcard.Tag = "2";
            this.chkcard.Text = "名片";
            this.chkcard.UseVisualStyleBackColor = false;
            // 
            // chktel
            // 
            this.chktel.AutoSize = true;
            this.chktel.BackColor = System.Drawing.Color.Transparent;
            this.chktel.BaseColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.chktel.ControlState = CCWin.SkinClass.ControlState.Normal;
            this.chktel.DefaultCheckButtonWidth = 19;
            this.chktel.DownBack = null;
            this.chktel.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.chktel.Location = new System.Drawing.Point(32, 137);
            this.chktel.MouseBack = ((System.Drawing.Image)(resources.GetObject("chktel.MouseBack")));
            this.chktel.Name = "chktel";
            this.chktel.NormlBack = ((System.Drawing.Image)(resources.GetObject("chktel.NormlBack")));
            this.chktel.SelectedDownBack = ((System.Drawing.Image)(resources.GetObject("chktel.SelectedDownBack")));
            this.chktel.SelectedMouseBack = ((System.Drawing.Image)(resources.GetObject("chktel.SelectedMouseBack")));
            this.chktel.SelectedNormlBack = ((System.Drawing.Image)(resources.GetObject("chktel.SelectedNormlBack")));
            this.chktel.Size = new System.Drawing.Size(63, 21);
            this.chktel.TabIndex = 4;
            this.chktel.Tag = "4";
            this.chktel.Text = "手机号";
            this.chktel.UseVisualStyleBackColor = false;
            // 
            // chknick
            // 
            this.chknick.AutoSize = true;
            this.chknick.BackColor = System.Drawing.Color.Transparent;
            this.chknick.BaseColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.chknick.ControlState = CCWin.SkinClass.ControlState.Normal;
            this.chknick.DefaultCheckButtonWidth = 19;
            this.chknick.DownBack = null;
            this.chknick.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.chknick.Location = new System.Drawing.Point(32, 175);
            this.chknick.MouseBack = ((System.Drawing.Image)(resources.GetObject("chknick.MouseBack")));
            this.chknick.Name = "chknick";
            this.chknick.NormlBack = ((System.Drawing.Image)(resources.GetObject("chknick.NormlBack")));
            this.chknick.SelectedDownBack = ((System.Drawing.Image)(resources.GetObject("chknick.SelectedDownBack")));
            this.chknick.SelectedMouseBack = ((System.Drawing.Image)(resources.GetObject("chknick.SelectedMouseBack")));
            this.chknick.SelectedNormlBack = ((System.Drawing.Image)(resources.GetObject("chknick.SelectedNormlBack")));
            this.chknick.Size = new System.Drawing.Size(51, 21);
            this.chknick.TabIndex = 5;
            this.chknick.Tag = "5";
            this.chknick.Text = "昵称";
            this.chknick.UseVisualStyleBackColor = false;
            // 
            // chkother
            // 
            this.chkother.AutoSize = true;
            this.chkother.BackColor = System.Drawing.Color.Transparent;
            this.chkother.BaseColor = System.Drawing.Color.FromArgb(((int)(((byte)(26)))), ((int)(((byte)(173)))), ((int)(((byte)(25)))));
            this.chkother.ControlState = CCWin.SkinClass.ControlState.Normal;
            this.chkother.DefaultCheckButtonWidth = 19;
            this.chkother.DownBack = null;
            this.chkother.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.chkother.Location = new System.Drawing.Point(32, 214);
            this.chkother.MouseBack = ((System.Drawing.Image)(resources.GetObject("chkother.MouseBack")));
            this.chkother.Name = "chkother";
            this.chkother.NormlBack = ((System.Drawing.Image)(resources.GetObject("chkother.NormlBack")));
            this.chkother.SelectedDownBack = ((System.Drawing.Image)(resources.GetObject("chkother.SelectedDownBack")));
            this.chkother.SelectedMouseBack = ((System.Drawing.Image)(resources.GetObject("chkother.SelectedMouseBack")));
            this.chkother.SelectedNormlBack = ((System.Drawing.Image)(resources.GetObject("chkother.SelectedNormlBack")));
            this.chkother.Size = new System.Drawing.Size(51, 21);
            this.chkother.TabIndex = 6;
            this.chkother.Tag = "6";
            this.chkother.Text = "其它";
            this.chkother.UseVisualStyleBackColor = false;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label1.Location = new System.Drawing.Point(29, 4);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(92, 17);
            this.label1.TabIndex = 7;
            this.label1.Text = "允许加我的方式";
            // 
            // btnsure
            // 
            this.btnsure.Location = new System.Drawing.Point(114, 262);
            this.btnsure.Name = "btnsure";
            this.btnsure.Size = new System.Drawing.Size(75, 23);
            this.btnsure.TabIndex = 8;
            this.btnsure.Text = "确定";
            this.btnsure.UseVisualStyleBackColor = true;
            this.btnsure.Click += new System.EventHandler(this.btnsure_Click);
            // 
            // FrmAddstate
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(217, 302);
            this.CloseBoxSize = new System.Drawing.Size(0, 0);
            this.ControlBox = false;
            this.Controls.Add(this.btnsure);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.chkother);
            this.Controls.Add(this.chknick);
            this.Controls.Add(this.chktel);
            this.Controls.Add(this.chkcard);
            this.Controls.Add(this.chkgroup);
            this.Controls.Add(this.chkeq);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmAddstate";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "";
            this.Load += new System.EventHandler(this.FrmAddstate_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Controls.CustomControls.CheckBoxEx chkeq;
        private Controls.CustomControls.CheckBoxEx chkgroup;
        private Controls.CustomControls.CheckBoxEx chkcard;
        private Controls.CustomControls.CheckBoxEx chktel;
        private Controls.CustomControls.CheckBoxEx chknick;
        private Controls.CustomControls.CheckBoxEx chkother;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnsure;
    }
}