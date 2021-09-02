using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk
{

    /// <summary>
    /// 
    /// </summary>
    public partial class BlackItem : UserControl
    {

        private Friend _datacontext;

        /// <summary>
        /// 黑名单好友
        /// </summary>
        public Friend DataContext
        {
            get { return _datacontext; }
            set
            {
                _datacontext = value;
                ImageLoader.Instance.DisplayAvatar(_datacontext.UserId, this.picAvator);//设置头像
                lblTitle.Text = _datacontext.NickName;
                lblSubTitle.Text = "我已拉黑" + _datacontext.NickName;
            }
        }



        /// <summary>
        /// 移出黑名单操作
        /// </summary>
        public Action<BlackItem> CancelBlockCommand { get; set; }

        /// <summary>
        /// 删除好友操作
        /// </summary>
        public Action DeleteFriendCommand { get; set; }

        public BlackItem()
        {
            InitializeComponent();
        }

        #region 加载时
        private void BlackItem_Load(object sender, EventArgs e)
        {

        }
        #endregion

        #region 移出黑名单
        private void BtnMainRaiseButtonClick(object sender, EventArgs e)
        {
            CancelBlockCommand?.Invoke(this);//执行取消黑名单

        }
        #endregion

    }
}
