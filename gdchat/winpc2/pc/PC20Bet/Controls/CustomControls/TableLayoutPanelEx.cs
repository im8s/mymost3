using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk
{
    public class TableLayoutPanelEx : TableLayoutPanel
    {
        public TableLayoutPanelEx()
        {
            // 打开控件的双缓冲
            SetStyle(ControlStyles.OptimizedDoubleBuffer | ControlStyles.AllPaintingInWmPaint, true);
            this.UpdateStyles();
            
        }

        protected override void OnControlAdded(ControlEventArgs e)
        {
            e.Control.MouseWheel += (sender, ev) => { this.OnMouseWheel(ev); };
            base.OnControlAdded(e);
        }

        protected override void WndProc(ref Message m)
        {
            base.WndProc(ref m);
        }
    }
}
