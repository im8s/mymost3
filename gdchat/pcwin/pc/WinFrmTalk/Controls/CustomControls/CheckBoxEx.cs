using CCWin.SkinControl;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.Controls.CustomControls
{
    public class CheckBoxEx : SkinCheckBox
    {
        public CheckBoxEx()
        {
            this.BackColor = System.Drawing.Color.Transparent;
            this.BaseColor = System.Drawing.Color.FromArgb(26, 173, 25);
            this.ControlState = CCWin.SkinClass.ControlState.Normal;
            this.DefaultCheckButtonWidth = 19;
            this.DownBack = null;
            this.Font = new System.Drawing.Font(Applicate.SetFont, 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.MouseBack = Properties.Resources.ic_radio_normal;
            this.NormlBack = Properties.Resources.ic_radio_normal;
            this.SelectedDownBack = Properties.Resources.ic_radio_check;
            this.SelectedMouseBack = Properties.Resources.ic_radio_check;
            this.SelectedNormlBack = Properties.Resources.ic_radio_check;
            this.Size = new System.Drawing.Size(21, 21);
            this.UseVisualStyleBackColor = false;
            this.CheckAlign = System.Drawing.ContentAlignment.MiddleLeft;
        }
    }
}
