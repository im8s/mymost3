using CCWin.SkinControl;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk
{
    public class ContextMenuStripEx : SkinContextMenuStrip
    {
        public ContextMenuStripEx()
        {
            this.Arrow = System.Drawing.Color.Black;
            this.Back = System.Drawing.Color.White;
            this.BackRadius = 1;
            this.Base = System.Drawing.Color.White;
            this.DropDownImageSeparator = System.Drawing.Color.FromArgb(197, 197, 197);
            this.Font = new System.Drawing.Font("宋体", 9F);
            this.Fore = System.Drawing.Color.Black;
            this.HoverFore = System.Drawing.Color.Black;
            this.ItemAnamorphosis = false;
            this.ItemBorder = System.Drawing.Color.FromArgb(224, 224, 224);
            this.ItemBorderShow = false;
            this.ItemBorder = System.Drawing.Color.FromArgb(224, 224, 224);
            this.ItemBorder = System.Drawing.Color.FromArgb(224, 224, 224);
            this.ItemRadius = 1;
            this.ItemRadiusStyle = CCWin.SkinClass.RoundStyle.All;
            this.ItemBorder = System.Drawing.Color.FromArgb(224, 224, 224);
            this.ItemHover = System.Drawing.Color.FromArgb(224, 224, 224);
            this.Name = "contentMenuStrip";
            this.RadiusStyle = CCWin.SkinClass.RoundStyle.All;
            this.Size = new System.Drawing.Size(181, 402);
            this.SkinAllColor = true;
            this.TitleAnamorphosis = false;
            this.TitleColor = System.Drawing.Color.White;
            this.TitleRadius = 4;
            this.TitleRadiusStyle = CCWin.SkinClass.RoundStyle.All;
            this.ShowImageMargin = false;
        }
    }
}
