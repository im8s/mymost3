using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using RichTextBoxLinks;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class USEGroupTips : UserControl
    {
        private string _tips;
        public string tips
        {
            get { return _tips; }
            set { _tips = value; }
        }
        public USEGroupTips()
        {
            InitializeComponent();
        }
       /// <summary>
       /// 获取控件中输入文字的宽度
       /// </summary>
       /// <param name="font"></param>
       /// <param name="control"></param>
       /// <param name="str"></param>
       /// <returns></returns>
        //private int FontWidth(Font font, Control control, string str)
        //{
        //    using (Graphics g = control.CreateGraphics())
        //    {
        //        SizeF siF = g.MeasureString(str, font); return (int)siF.Width;
        //    }
        //}

        /// <summary>
        ///  /// 获取控件中文字的高度，不累加
        /// </summary>
        /// <param name="font"></param>
        /// <param name="control"></param>
        /// <param name="str"></param>
        /// <returns></returns>
        //private int FontHeigh(Font font, Control control, string str)
        //{
        //    using (Graphics g = control.CreateGraphics())
        //    {
        //        SizeF siF = g.MeasureString(str, font); return (int)siF.Height;
        //    }
        //}
       
        /// <summary>
        /// 文本的高度自适应
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
       
    }
    //设置ritchbox的行间距
    public class CSetLineSpace
    {
        public const int WM_USER = 0x0400;
        public const int EM_GETPARAFORMAT = WM_USER + 61;
        public const int EM_SETPARAFORMAT = WM_USER + 71;
        public const long MAX_TAB_STOPS = 32;
        public const uint PFM_LINESPACING = 0x00000100;
        [StructLayout(LayoutKind.Sequential)]
        private struct PARAFORMAT2
        {
            public int cbSize;
            public uint dwMask;
            public short wNumbering;
            public short wReserved;
            public int dxStartIndent;
            public int dxRightIndent;
            public int dxOffset;
            public short wAlignment;
            public short cTabCount;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 32)]
            public int[] rgxTabs;
            public int dySpaceBefore;
            public int dySpaceAfter;
            public int dyLineSpacing;
            public short sStyle;
            public byte bLineSpacingRule;
            public byte bOutlineLevel;
            public short wShadingWeight;
            public short wShadingStyle;
            public short wNumberingStart;
            public short wNumberingStyle;
            public short wNumberingTab;
            public short wBorderSpace;
            public short wBorderWidth;
            public short wBorders;
        }

        [DllImport("user32", CharSet = CharSet.Auto)]
        private static extern IntPtr SendMessage(HandleRef hWnd, int msg, int wParam, ref PARAFORMAT2 lParam);

        /// <summary>
        /// 设置行距
        /// </summary>
        /// <param name="ctl">控件</param>
        /// <param name="dyLineSpacing">间距</param>
        public static void SetLineSpace(Control ctl, int dyLineSpacing)
        {
            PARAFORMAT2 fmt = new PARAFORMAT2();
            fmt.cbSize = Marshal.SizeOf(fmt);
            fmt.bLineSpacingRule = 4;// bLineSpacingRule;
            fmt.dyLineSpacing = dyLineSpacing;
            fmt.dwMask = PFM_LINESPACING;
            try
            {
                SendMessage(new HandleRef(ctl, ctl.Handle), EM_SETPARAFORMAT, 0, ref fmt);
            }
            catch
            {

            }
        }
    }
}
