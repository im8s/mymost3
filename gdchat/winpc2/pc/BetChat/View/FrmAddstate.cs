using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;

namespace WinFrmTalk.View
{
    public partial class FrmAddstate : FrmBase
    {
        public List<string> FriendFromLst { get; set; }
     
        public FrmAddstate()
        {
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            InitializeComponent();
        }

        private void btnsure_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        private void chkother_CheckedChanged(object sender, EventArgs e)
        {
            CheckBoxEx chk = (CheckBoxEx)sender;
            string tag = chk.Tag.ToString();
           switch(tag)
            {
                case "1":
                    AddToLst(chk.Checked, tag);
                    break;
                case "2":
                    AddToLst(chk.Checked, tag);
                    break;
                case "3":
                    AddToLst(chk.Checked, tag);
                    break;
                case "4":
                    AddToLst(chk.Checked, tag);
                    break;
                case "5":
                    AddToLst(chk.Checked, tag);
                    break;
                case "6":
                    AddToLst(chk.Checked, tag);
                    break;
                   
            }

        }
        private void AddToLst(bool Checked, string value)
        {
            if (Checked)
            {
                FriendFromLst.Add(value);
            }
            else
            {
                FriendFromLst.Remove(value);
            }
        }

        private void FrmAddstate_Load(object sender, EventArgs e)
        {
            if(FriendFromLst.Contains("1"))
            {
                chkeq.Checked = true;
            }
            if(FriendFromLst.Contains("2"))
            {
                chkcard.Checked = true;
            }
            if (FriendFromLst.Contains("3"))
            {
                chkgroup.Checked = true;
            }
            if (FriendFromLst.Contains("4"))
            {
                chktel.Checked = true;
            }
            if (FriendFromLst.Contains("5"))
            {
                chknick.Checked = true;
            }
            if (FriendFromLst.Contains("6"))
            {
                chkother.Checked = true;
            }
            chkeq.CheckedChanged += new System.EventHandler(this.chkother_CheckedChanged);
            this.chkgroup.CheckedChanged += new System.EventHandler(this.chkother_CheckedChanged);
            this.chkcard.CheckedChanged += new System.EventHandler(this.chkother_CheckedChanged);
            this.chktel.CheckedChanged += new System.EventHandler(this.chkother_CheckedChanged);
            this.chknick.CheckedChanged += new System.EventHandler(this.chkother_CheckedChanged);
            this.chkother.CheckedChanged += new System.EventHandler(this.chkother_CheckedChanged);
        }
    }
}
