using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;



  
    public class CaptureImageToolColorTable
    {
    
        private static readonly Color _borderColor = Color.FromArgb(65, 173, 236);//浅蓝
        private static readonly Color _backColorNormal = Color.Transparent;
        private static readonly Color _backColorHover = Color.Transparent;
    private static readonly Color _backColorPressed = Color.Transparent;
    private static readonly Color _foreColor = Color.FromArgb(12, 83, 124);//深蓝

        public CaptureImageToolColorTable() { }

        public virtual Color BorderColor
        {
            get { return _borderColor; }
        }

        public virtual Color BackColorNormal
        {
            get { return _backColorNormal; }
        }

        public virtual Color BackColorHover
        {
            get { return _backColorHover; }
        }

        public virtual Color BackColorPressed
        {
            get { return _backColorPressed; }
        }

        public virtual Color ForeColor
        {
            get { return _foreColor; }
        }
    }

