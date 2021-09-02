using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk
{
    using System;
    using System.Drawing;
    using System.Runtime.InteropServices;
    using System.Windows.Forms;

    public class RichTextBoxPrintCtrl : RichTextBox
    {
        private const double anInch = 14.4;
        [StructLayout(LayoutKind.Sequential)]
        private struct RECT
        {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }
        [StructLayout(LayoutKind.Sequential)]
        private struct CHARRANGE
        {
            public int cpMin;         //First character of range (0 for start of doc)
            public int cpMax;         //Last character of range (-1 for end of doc)
        }
        [StructLayout(LayoutKind.Sequential)]
        private struct FORMATRANGE
        {
            public IntPtr hdc;             //Actual DC to draw on
            public IntPtr hdcTarget;       //Target DC for determining text formatting
            public RECT rc;                //Region of the DC to draw to (in twips)
            public RECT rcPage;            //Region of the whole DC (page size) (in twips)
            public CHARRANGE chrg;         //Range of text to draw (see earlier declaration)
        }
        private const int WM_USER = 0x0400;
        private const int EM_FORMATRANGE = WM_USER + 57;
        [DllImport("USER32.dll")]
        private static extern IntPtr SendMessage(IntPtr hWnd, Int32 msg, Int32 wParam, Int32 lParam);

        public int PrintImage(int nStartFrom, Graphics g)
        {
            RECT rcToPrint = default(RECT);
            FORMATRANGE fr = default(FORMATRANGE);
            IntPtr iptHdc = IntPtr.Zero;
            IntPtr iptRes = IntPtr.Zero;
            IntPtr iptParam = IntPtr.Zero;
            // Calculate the area to render and print
            rcToPrint.Top = 0;
            rcToPrint.Bottom = (int)Math.Ceiling((g.VisibleClipBounds.Height * anInch));
            rcToPrint.Left = 0;
            rcToPrint.Right = (int)Math.Ceiling((g.VisibleClipBounds.Width * anInch));
            iptHdc = g.GetHdc();
            //Indicate character from to character to
            fr.chrg.cpMin = nStartFrom;
            fr.chrg.cpMax = -1;
            //Use the same DC for measuring and rendering point at printer hDC       
            fr.hdc = fr.hdcTarget = iptHdc;
            //Indicate the area on page to print
            fr.rc = rcToPrint;
            //Get the pointer to the FORMATRANGE structure in memory
            iptParam = Marshal.AllocCoTaskMem(Marshal.SizeOf(fr));
            Marshal.StructureToPtr(fr, iptParam, false);
            //Send the rendered data for printing
            iptRes = SendMessage(this.Handle, EM_FORMATRANGE, 1, iptParam.ToInt32());
            //Free the block of memory allocated
            Marshal.FreeCoTaskMem(iptParam);
            //Release the device context handle obtained by a previous call
            g.ReleaseHdc(iptHdc);
            //Return last + 1 character printer
            return iptRes.ToInt32();
        }
    }
}
