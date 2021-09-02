using System;
using System.Drawing;
using System.Linq;
using System.Threading;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk
{

    /// <summary>
    /// 好友验证UI项
    /// </summary>
    public partial class VerifyItem : UserControl
    {

        #region Private Members
        private VerifingFriend datacontext;
        //private Action<bool> SetVisible;
        #endregion


        #region Public Properties
        /// <summary>
        /// 通过验证
        /// </summary>
        public Action<VerifingFriend> AcceptCommand { get; set; }

        /// <summary>
        /// 回话
        /// </summary>
        public Action<VerifingFriend, string> AnswerCommand { get; set; }

        /// <summary>
        /// 数据上下文(验证好友对象)
        /// </summary>
        public VerifingFriend DataContext
        {
            get { return datacontext; }
            set
            {
                datacontext = value;
                this.picAvator.isDrawRound = true;
                ImageLoader.Instance.DisplayAvatar(datacontext.userId, this.picAvator);//设置头像
                lblNickname.Text = datacontext.nickName;//昵称
                lblContent.Text = UIUtils.LimitTextLength(datacontext.Content, 16, true);//验证消息内容
                btnAccept.Text = datacontext.StatusTag;
                RefreshBtnState(datacontext.VerifyStatus);
            }
        }
        #endregion




        private void RefreshBtnState(int state)
        {
            btnAccept.Visible = state == -4;
            btnAnswer.Visible = state == -4;

            if (btnAccept.Visible)
            {
                btnAccept.Enabled = true;
            }

            if (state == 5)
            {
                btnAnswer.Visible = true;
            }

            tvShortTip.Visible = !btnAnswer.Visible;

            if (tvShortTip.Visible)
            {
                string str = datacontext.StatusTag;
                if (!UIUtils.IsNull(str) && str.Length == 3)
                {
                    str = "    " + datacontext.StatusTag;
                }

                tvShortTip.Text = str;
            }
        }


        #region Contructor
        public VerifyItem()
        {
            InitializeComponent();
        }
        #endregion



        #region 接受
        private void BtnAccept_Click(object sender, EventArgs e)
        {
            AcceptCommand?.Invoke(datacontext);//执行确认操作
            btnAccept.Enabled = false;
        }
        #endregion

        #region 显示回话文本框
        private void btnStartAnswer_Click(object sender, EventArgs e)
        {
            FrmMyColleagueEidt answerform = new FrmMyColleagueEidt();
            answerform.ColleagueName((result) =>
            {
                AnswerCommand?.Invoke(datacontext, result);//执行回话操作
                answerform.Close();
            });
            answerform.ShowThis("回话", "回话内容");
        }
        #endregion

    }
}
