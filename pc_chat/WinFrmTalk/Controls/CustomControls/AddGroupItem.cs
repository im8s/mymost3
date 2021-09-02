using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.View;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class AddGroupItem : UserControl
    {
        public Friend _datacontext;
        public AddGroupItem()
        {
            InitializeComponent();
            #region 子控件事件传递
            picHead.MouseEnter += Parent_MouseEnter;
            lblNickName.MouseEnter += Parent_MouseEnter;
            picHead.MouseLeave += Parent_MouseLeave;
            lblNickName.MouseLeave += Parent_MouseLeave;
            #endregion
        }


        #region Parent Event
        private void Parent_MouseLeave(object sender, EventArgs e)
        {
            this.OnMouseLeave(e);
        }
        private void Parent_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }
        #endregion


        public FrmGroupQuery.ProcesOnClickItem OnClickSend { get; set; }

        public FrmGroupQuery.ProcesOnClickItem OnClickJoin { get; set; }

        public Friend DataContext
        {
            get { return _datacontext; }
            set
            {
                _datacontext = value;
                string name = UIUtils.LimitTextLength(_datacontext.NickName, 8, true);
                lblNickName.Text = name;
                string dec = UIUtils.LimitTextLength(_datacontext.Description, 5, true);
                lblDes.Text = "群描述：" + dec;

                ChangeButtonState();
            }
        }

        private void ChangeButtonState()
        {
            bool isExistsRoom = DataContext.ExistsFriend();

            // 已经加入过群组
            if (isExistsRoom)
            {
                btnAdd.Text = "发消息";
                btnAdd.Click += (sen, eve) =>
                {
                    OnClickSend?.Invoke(this);
                };
            }
            else
            {
                btnAdd.Text = "加群";
                btnAdd.Click += (sen, eve) =>
                {
                    OnClickJoin?.Invoke(this);
                };
            }
        }


        public void InvalidBtn()
        {
            btnAdd.Enabled = false;
        }

        /// <summary>
        /// 鼠标悬浮
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void AddGroupItem_MouseEnter(object sender, EventArgs e)
        {
            this.BackColor = ColorTranslator.FromHtml("#D8D8D9");
        }
        /// <summary>
        /// 鼠标离开
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void AddGroupItem_MouseLeave(object sender, EventArgs e)
        {
            this.BackColor = Color.Transparent;
        }

        private void btnAdd_MouseEnter(object sender, EventArgs e)
        {
            this.BackColor = ColorTranslator.FromHtml("#D8D8D9");
        }

        private void btnAdd_MouseLeave(object sender, EventArgs e)
        {
            this.BackColor = Color.Transparent;
        }
    }
}
