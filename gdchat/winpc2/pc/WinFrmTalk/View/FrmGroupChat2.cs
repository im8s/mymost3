using CCWin;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.View
{
    public partial class FrmGroupChat2 : CCSkinMain
    {
        public FrmGroupChat2()
        {
            CCWin.SkinControl.ScrollBarDrawImage.ScrollVertThumb = Properties.Resources.vista_ScrollVertShaft;
            CCWin.SkinControl.ScrollBarDrawImage.Fader = Properties.Resources.fader;
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
        }

        private void FrmGroupChat_Load(object sender, EventArgs e)
        {

        }
    }
}
