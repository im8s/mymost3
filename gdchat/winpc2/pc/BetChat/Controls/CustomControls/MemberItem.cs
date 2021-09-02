using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class MemberItem : UserControl
    {
        Action<bool> checkedListen;    //复选框监听

        /// <summary>
        /// 保存整个群成员实体类
        /// </summary>
        public RoomMember roomMember { get; set; }

        /// <summary>
        /// 昵称
        /// </summary>
        public string nickName
        {
            get { return lab_name.Text; }
            set { lab_name.Text = value; }
        }
        /// <summary>
        /// 是否勾选
        /// </summary>
        public bool checkState
        {
            get { return chb.Checked; }
            set { chb.Checked = value; }
        }
        /// <summary>
        /// 是否显示复选框
        /// </summary>
        public bool checkVisible
        {
            get { return chb.Visible; }
            set { chb.Visible = value; }
        }

        public MemberItem()
        {
            InitializeComponent();
        }

        private void lab_name_TextChanged(object sender, EventArgs e)
        {
            if (((Label)sender).Text.Length > 12)
                ((Label)sender).Text = ((Label)sender).Text.ToString().Remove(10) + "...";
        }

        #region 事件由父级处理
        private void lab_name_Click(object sender, EventArgs e)
        {
            this.OnClick(e);
        }

        private void pic_head_Click(object sender, EventArgs e)
        {
            this.OnClick(e);
        }

        private void lab_name_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }

        private void chb_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }

        private void pic_head_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }
        #endregion

        private void UserItem_MouseEnter(object sender, EventArgs e)
        {
            //如果选中状态，背景色不改变
            if (checkState)
                return;

            this.BackColor = Color.WhiteSmoke;
        }

        private void UserItem_MouseLeave(object sender, EventArgs e)
        {
            //如果选中状态，背景色不改变
            if (checkState)
                return;

            //离开时变回默认的颜色
            this.BackColor = Color.White;
        }

        private void chb_CheckedChanged(object sender, EventArgs e)
        {
            //已选中
            if (chb.Checked)
                this.BackColor = Color.Gainsboro;
            else
                this.BackColor = Color.WhiteSmoke;

            //如果不为空则执行
            checkedListen?.Invoke(chb.Checked);
        }

        /// <summary>
        /// 添加复选框监听
        /// </summary>
        /// <param name="checkedListen">复选框监听</param>
        public void AddCheckedListen(Action<bool> checkedListen)
        {
            this.checkedListen = checkedListen;
        }
    }
}
