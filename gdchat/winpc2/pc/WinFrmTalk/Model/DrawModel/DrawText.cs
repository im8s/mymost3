using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.Model.DrawModel
{
    public class DrawText
    {
        string _content;
        Point _location;

        public string Content { get => _content; set => _content = value; }
        public Point Location { get => _location; set => _location = value; }
    }
}
