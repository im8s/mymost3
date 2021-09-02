using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public partial class UseRoleMember : UserControl
    {
        public UseRoleMember()
        {
            InitializeComponent();
            #region 继承父类的方法
            lab_name.MouseEnter += Parent_MouseEnter;
            pic_head.MouseEnter += Parent_MouseEnter;
            lab_Role.MouseEnter += Parent_MouseEnter;

            lab_name.MouseLeave += Parent_MouseLeave;
            pic_head.MouseLeave += Parent_MouseLeave;
            lab_Role.MouseLeave += Parent_MouseLeave;

            lab_name.Click += Parent_Click;
            lab_Role.Click += Parent_Click;
            #endregion
        }
        private bool isSelected;
        //private bool isfirst;

        private string _roomjid;

        public string roomjid
        {
            get { return _roomjid; }
            set { _roomjid = value; }
        }
        /// <summary>
        /// 是否选中 
        /// </summary>
        public bool IsSelected
        {
            get { return isSelected; }
            set
            {
                isSelected = value;
                if (IsSelected)
                {
                    this.BackColor = ColorTranslator.FromHtml("#CAC8C6");
                }
                else
                {
                    this.BackColor = Color.Transparent;
                }
            }
        }

        public bool isFirst
        {
            get { return lblLine.Visible; }
            set { lblLine.Visible = value; }
        }
       

        #region Parent Event
        private void Parent_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }
        private void Parent_MouseLeave(object sender, EventArgs e)
        {
            this.OnMouseLeave(e);
        }
        private void Parent_Click(object sender, EventArgs e)
        {
            this.OnClick(e);

        }
        #endregion

        #region Private Member
        private Friend frienddata;

        #endregion

        /// <summary>
        /// 保存整个好友实体类
        /// </summary>
        public Friend friendData
        {
            get { return frienddata; }
            set
            {
                frienddata = value;

                lab_name.Text = frienddata.RemarkName == "" || frienddata.RemarkName == null ? frienddata.NickName : frienddata.RemarkName;

            }
        }
        
        public string  CurrentRole
        {
            get {return  lab_Role.Text; }
            set
            {
                lab_Role.Text = value;
                if(lab_Role.Text =="群主")
                {
                    lab_Role.ForeColor = ColorTranslator.FromHtml("#F9CC07");

                }
                else if(lab_Role.Text == "管理员")
                {
                    lab_Role.ForeColor = ColorTranslator.FromHtml("#36D55C");
                }
                else
                {
                    lab_Role.ForeColor = ColorTranslator.FromHtml("#54BCFE");
                }
            }

        }

        private void lab_name_TextChanged(object sender, EventArgs e)
        {
            if (((Label)sender).Text.Length > 14)
            {
                ((Label)sender).Text = ((Label)sender).Text.ToString().Remove(13) + "...";
            }
        }

        #region 事件由父级处理
        private void lab_name_Click(object sender, EventArgs e)
        {
            this.OnClick(e);
        }

        private void lab_name_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }

        private void pic_head_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }
        #endregion

        private void FriendItem_MouseEnter(object sender, EventArgs e)
        {
            if (!IsSelected)
            {
                this.BackColor = ColorTranslator.FromHtml("#D8D8D9");//悬浮颜色
            }
        }

        private void FriendItem_MouseLeave(object sender, EventArgs e)
        {

            //非选中状态
            if (!IsSelected)
            {
                //离开时变回默认的颜色
                this.BackColor = Color.Transparent;
            }
        }
        public void pic_head_Click(object sender, EventArgs e)
        {
            FrmFriendsBasic frmFriendsBasic = new FrmFriendsBasic();
            frmFriendsBasic.ShowUserInfoById(friendData.UserId);

            frmFriendsBasic.Show();
        }
    }
}
