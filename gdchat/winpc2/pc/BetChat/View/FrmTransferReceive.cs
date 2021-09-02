using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Helper;
using WinFrmTalk.Model;

namespace WinFrmTalk.View
{
    public partial class FrmTransferReceive : FrmSuspension
    {
        public TransferInfo TransferInfo { get; set; }

        public HaveReceived HaveReceived { get; set; }

        public FrmTransferReceive()
        {
            InitializeComponent();
            
            // 加载icon图标
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);
        }


        /// <summary>
        /// 带确认收钱
        /// </summary>
        public void waiteReceived()
        {
            pics.BackgroundImage = WinFrmTalk.Properties.Resources.ic_transfer_wait;
            lab_received.Text = "待确认收钱";
            lab_money.Text = "￥" + TransferInfo.money.ToString();
            lab_tips.Visible = true;

            if (TransferInfo.userId.ToString() != Applicate.MyAccount.userId)
            {
                btn_sure.Visible = true;
            }
            lab_Receivetime.Visible = false;
            btn_sure.Click += Btn_sure_Click;
            lab_transfertime.Text = "转账时间：" + TimeUtils.FromatTime(TransferInfo.createTime, "yyyy-MM-dd HH: mm:ss ");
            this.Location = MousePosition;
            this.Show();
        }
        public void SureReceived()
        {
            pics.BackgroundImage = WinFrmTalk.Properties.Resources.ic_transfer_compt;
            lab_received.Text = "已收钱";
            lab_money.Text = "￥" + HaveReceived.money.ToString();
            lab_tips.Visible = false;

            btn_sure.Visible = false;
            if (!UIUtils.IsNull(HaveReceived.Time.ToString()) && (HaveReceived.Time.ToString() != "0"))
            {
                lab_transfertime.Text = "转账时间：" + TimeUtils.FromatTime(HaveReceived.Time, "yyyy-MM-dd HH: mm:ss");//转账时间
                lab_Receivetime.Text = "收钱时间：" + TimeUtils.FromatTime(TimeUtils.CurrentTime(), "yyyy-MM-dd HH: mm:ss");//转账时间
            }
            else
            {

                lab_transfertime.Text = "转账时间：" + TimeUtils.FromatTime(HaveReceived.createTime, "yyyy-MM-dd HH: mm:ss");//转账时间
                lab_Receivetime.Text = "收钱时间：" + TimeUtils.FromatTime(HaveReceived.receiptTime, "yyyy-MM-dd HH: mm:ss");//转账时间
            }


            this.Location = MousePosition;
            this.Show();
        }
        public void ExiteTransfer()
        {
            pics.BackgroundImage = WinFrmTalk.Properties.Resources.ic_transfer_back;
            lab_received.Text = "已退还";
            lab_money.Text = "￥" + HaveReceived.money.ToString();
            lab_tips.Visible = false;

            btn_sure.Visible = false;
            lab_transfertime.Text = "转账时间：" + TimeUtils.FromatTime(HaveReceived.Time, "yyyy-MM-dd HH: mm:ss");//转账时间
            lab_Receivetime.Text = "收钱时间：" + TimeUtils.FromatTime(HaveReceived.Time, "yyyy-MM-dd HH: mm:ss");//转账时间
            this.Location = MousePosition;
            this.Show();
        }
        /// <summary>
        /// 确认收钱
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Btn_sure_Click(object sender, EventArgs e)
        {
            this.Close();
            RedpaperUIUtils.ReceiveTranfser(TransferInfo.id);
        }
        /// <summary>
        /// 退还
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void lab_exite_Click(object sender, EventArgs e)
        {
            if (HttpUtils.Instance.ShowPromptBox("是否退还" + HaveReceived.sendName + "的转账"))
            {

            }
        }
    }
}
