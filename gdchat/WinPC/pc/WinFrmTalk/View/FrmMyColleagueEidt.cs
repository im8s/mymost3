using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk
{
    public partial class FrmMyColleagueEidt : FrmBase
    {
        private Action<string> ColleagueCallback;
        public string NameEdit;

        public FrmMyColleagueEidt()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
        }

        internal void ColleagueName(Action<string> p)
        {
            ColleagueCallback = p;
        }
        /// <summary>
        /// 确定
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnConfirm_Click(object sender, EventArgs e)
        {

            string input = txtName.Text.TrimStart().Trim();

            if (UIUtils.IsNull(input))
            {
                ShowTip("不能只输入空格");
                return;
            }

            if (!input.Equals(NameEdit))
            {
                ColleagueCallback?.Invoke(txtName.Text);
            }
            else
            {
                MessageBox.Show("未修改过");
            }

        }

        private void FrmMyColleagueEidt_Load(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(NameEdit))
            {
                txtName.Text = NameEdit;
            }
        }
        /// <summary>
        /// 传递参数修改界面UI
        /// </summary>
        /// <param name="title">窗体标题</param>
        /// <param name="Name">文本框名称</param>
        public void ShowThis(string title,string Name)
        {
            this.Text = title;
            lblName.Text = Name+"：";
            var parent = Applicate.GetWindow<FrmMain>();
            this.Location = new Point(parent.Location.X + (parent.Width - this.Width) / 2, parent.Location.Y + (parent.Height - this.Height) / 2);//居中
            this.ShowDialog();
        }

        private void txtName_KeyPress(object sender, KeyPressEventArgs e)
        {
             if (txtName.Text.Length <= 0)
            { //空格不能在第一位
                if ((int)e.KeyChar == 32)
                {
                    e.Handled = true;
                }
            }
                if (e.KeyChar == '\r')
            {
                btnConfirm_Click(sender, e);
            }
        }
    }
}
