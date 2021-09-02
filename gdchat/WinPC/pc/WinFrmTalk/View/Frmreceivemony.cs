using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.View.list;

namespace WinFrmTalk.View
{
    public partial class Frmreceivemony : FrmSuspension
    {
        RedReciviceAdapter mAdapter;
        /// <summary>
        ///领取人集合
        /// </summary>
        public List<Receivers>  receivelst
        {
            get;set;
        }
        public Redpackges reapackgeinfo
        {
            get;set;
        }
        public string datatime { get; set; }
        public Frmreceivemony()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            mAdapter = new RedReciviceAdapter();
        }
        /// <summary>
        ///绑定数据
        /// </summary>
        public void BindTodata()
        {
            panel1.BackgroundImage = global::WinFrmTalk.Properties.Resources.ic_redpacked_head;
            lab_totalaccount.Text ="共"+ reapackgeinfo.money+"元";
            lab_fromname.Text = "来自" + reapackgeinfo.userName;
            lab_text.Text= reapackgeinfo.greetings;
            lab_finishcount.Text = "已领取" + reapackgeinfo.receiveCount + "/" + reapackgeinfo.count + "个";
            for (int i = 0; i < receivelst.Count; i++)
            {
                if(receivelst[i].userId == Applicate.MyAccount.userId)
                {
                    if (receivelst[i].reply!=null)
                    {
                        lblreplay.Visible = false;
                    }
                    else
                    {
                        lblreplay.Visible = true;
                    }

                    break;
                }
                
            }
           
            mAdapter.Roomjid = reapackgeinfo.roomJid;
            mAdapter.BindDatas(receivelst);
            receiveinfopal.SetAdapter(mAdapter);
           // this.Show();
        }
        /// <summary>
        /// 红包回复
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void lblreplay_Click(object sender, EventArgs e)
        {
            lblreplay.Visible = true;
            FrmRedpReplay frmRedpReplay = new FrmRedpReplay();
            frmRedpReplay.RedPaperId = reapackgeinfo.id;//红包id
            this.IsClose = false;
            frmRedpReplay.BringToFront();
            frmRedpReplay.ShowDialog();
            if (frmRedpReplay.DialogResult == DialogResult.OK)
            {
                lblreplay.Text = frmRedpReplay.ReplayText;
                lblreplay.Click -= lblreplay_Click;
            }
            this.IsClose = true;
        }
    }
}
