namespace WinFrmTalk.View
{
    partial class FrmGroupChose
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
            this.panel1 = new System.Windows.Forms.Panel();
            this.panel3 = new System.Windows.Forms.Panel();
            this.btnCan = new LollipopButton();
            this.btnSure = new LollipopButton();
            this.lollipopLabel1 = new LollipopLabel();
            this.panel2 = new System.Windows.Forms.Panel();
            this.panel4 = new System.Windows.Forms.Panel();
            this.palGroups = new WinFrmTalk.MyTabLayoutPanel();
            this.searchControl1 = new WinFrmTalk.SearchControl();
            this.pangropsAdd = new System.Windows.Forms.FlowLayoutPanel();
            this.panel1.SuspendLayout();
            this.panel3.SuspendLayout();
            this.panel2.SuspendLayout();
            this.panel4.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.panel3);
            this.panel1.Controls.Add(this.panel2);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel1.Location = new System.Drawing.Point(4, 28);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(642, 526);
            this.panel1.TabIndex = 1;
            // 
            // panel3
            // 
            this.panel3.Controls.Add(this.pangropsAdd);
            this.panel3.Controls.Add(this.btnCan);
            this.panel3.Controls.Add(this.btnSure);
            this.panel3.Controls.Add(this.lollipopLabel1);
            this.panel3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel3.Location = new System.Drawing.Point(311, 0);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(331, 526);
            this.panel3.TabIndex = 1;
            // 
            // btnCan
            // 
            this.btnCan.BackColor = System.Drawing.Color.Transparent;
            this.btnCan.BGColor = "#508ef5";
            this.btnCan.FontColor = "#ffffff";
            this.btnCan.Location = new System.Drawing.Point(144, 482);
            this.btnCan.Name = "btnCan";
            this.btnCan.Size = new System.Drawing.Size(70, 34);
            this.btnCan.TabIndex = 3;
            this.btnCan.Text = "取消";
            this.btnCan.Click += new System.EventHandler(this.btnCan_Click);
            // 
            // btnSure
            // 
            this.btnSure.BackColor = System.Drawing.Color.Transparent;
            this.btnSure.BGColor = "#508ef5";
            this.btnSure.FontColor = "#ffffff";
            this.btnSure.Location = new System.Drawing.Point(57, 482);
            this.btnSure.Name = "btnSure";
            this.btnSure.Size = new System.Drawing.Size(70, 34);
            this.btnSure.TabIndex = 2;
            this.btnSure.Text = "确定";
            // 
            // lollipopLabel1
            // 
            this.lollipopLabel1.AutoSize = true;
            this.lollipopLabel1.BackColor = System.Drawing.Color.Transparent;
            this.lollipopLabel1.Font = new System.Drawing.Font(Applicate.SetFont, 10F);
            this.lollipopLabel1.ForeColor = System.Drawing.Color.Black;
            this.lollipopLabel1.Location = new System.Drawing.Point(35, 14);
            this.lollipopLabel1.Name = "lollipopLabel1";
            this.lollipopLabel1.Size = new System.Drawing.Size(148, 17);
            this.lollipopLabel1.TabIndex = 0;
            this.lollipopLabel1.Text = "请选择需要添加的群组";
            // 
            // panel2
            // 
            this.panel2.Controls.Add(this.panel4);
            this.panel2.Controls.Add(this.searchControl1);
            this.panel2.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel2.Location = new System.Drawing.Point(0, 0);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(311, 526);
            this.panel2.TabIndex = 0;
            // 
            // panel4
            // 
            this.panel4.AutoScroll = true;
            this.panel4.Controls.Add(this.palGroups);
            this.panel4.Location = new System.Drawing.Point(3, 46);
            this.panel4.Name = "panel4";
            this.panel4.Size = new System.Drawing.Size(308, 470);
            this.panel4.TabIndex = 1;
            this.panel4.MouseDown += new System.Windows.Forms.MouseEventHandler(this.panel4_MouseDown);
            // 
            // palGroups
            // 
            this.palGroups.Dock = System.Windows.Forms.DockStyle.Fill;
            this.palGroups.Location = new System.Drawing.Point(0, 0);
            this.palGroups.Name = "palGroups";
            this.palGroups.Size = new System.Drawing.Size(308, 470);
            this.palGroups.TabIndex = 0;
            // 
            // searchControl1
            // 
            this.searchControl1.Font = new System.Drawing.Font("宋体", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.searchControl1.InputGrayString = "1243";
            this.searchControl1.Location = new System.Drawing.Point(3, 3);
            this.searchControl1.Name = "searchControl1";
            this.searchControl1.Radius = 0;
            this.searchControl1.Size = new System.Drawing.Size(259, 28);
            this.searchControl1.TabIndex = 0;
            // 
            // pangropsAdd
            // 
            this.pangropsAdd.AutoScroll = true;
            this.pangropsAdd.Location = new System.Drawing.Point(6, 56);
            this.pangropsAdd.Name = "pangropsAdd";
            this.pangropsAdd.Size = new System.Drawing.Size(318, 420);
            this.pangropsAdd.TabIndex = 0;
            this.pangropsAdd.Paint += new System.Windows.Forms.PaintEventHandler(this.pangropsAdd_Paint);
            // 
            // FrmGroupChose
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(650, 558);
            this.Controls.Add(this.panel1);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmGroupChose";
            this.ShowDrawIcon = false;
            this.Special = false;
            this.Text = "";
            this.Load += new System.EventHandler(this.FrmGroupChose_Load);
            this.panel1.ResumeLayout(false);
            this.panel3.ResumeLayout(false);
            this.panel3.PerformLayout();
            this.panel2.ResumeLayout(false);
            this.panel4.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private SearchControl searchControl1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.Panel panel2;
       
        private LollipopLabel lollipopLabel1;
        private LollipopButton btnCan;
        private LollipopButton btnSure;
        private System.Windows.Forms.Panel panel4;
        public WinFrmTalk.MyTabLayoutPanel palGroups;
        private System.Windows.Forms.FlowLayoutPanel pangropsAdd;
    }
}