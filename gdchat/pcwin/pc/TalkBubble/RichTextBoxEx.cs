using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace TalkBubble
{
    public class RichTextBoxEx: RichTextBox
    {
        public RichTextBoxEx(string rtf)
        {
            this.Cursor = Cursors.Default;
            this.Rtf = rtf;
            this.DoubleClick += new EventHandler(richTextBoxEx_DoubleClick);
        }

        private void richTextBoxEx_DoubleClick(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(this.Rtf) || string.IsNullOrEmpty(this.Text))
                return;

            //获取当前鼠标双击行
            int selectionStart = this.SelectionStart;
            int currentRow = this.GetLineFromCharIndex(selectionStart);
            
            string[] sArray = Regex.Split(Rtf, @"\\par\r\n", RegexOptions.IgnoreCase);

            int _index = sArray[currentRow].IndexOf("pichgoal");
            if (_index < 0) return;
            string _rtf = this.Rtf.Remove(0, _index + 8);
            _index = _rtf.IndexOf("\r\n");
            _rtf = _rtf.Remove(0, _index);
            _index = _rtf.IndexOf("\\par\r\n");
            _rtf = _rtf.Remove(_index).Replace("}", "").Replace("\r\n", "");

            IList<string> _ImageList = new List<string>();
            _ImageList.Add(_rtf);

            Byte[] buffer = null;
            int _count = _rtf.Length / 2;
            for (int i = 0; i != _ImageList.Count; i++)
            {
                buffer = new Byte[_ImageList[i].Length / 2];
                //FileStream _File = new FileStream(Application.StartupPath + "\\" + i.ToString() + ".dat", FileMode.Create);

                for (int z = 0; z != _count; z++)
                {
                    string _TempText = _ImageList[i][z * 2].ToString() + _ImageList[i][(z * 2) + 1].ToString();
                    //_File.WriteByte(Convert.ToByte(_TempText, 16));
                    buffer[z] = Convert.ToByte(_TempText, 16);
                }

                //_File.Close();
            }

            MemoryStream ms = new MemoryStream(buffer);
            Image _a = Image.FromStream(ms);
            //Bitmap _a = new Bitmap(Application.StartupPath + "\\" + "0.dat");
            Bitmap _b = new Bitmap(100, 100);
            Graphics g = Graphics.FromImage(_b);

            g.InterpolationMode = InterpolationMode.HighQualityBicubic;

            g.DrawImage(_a, new Rectangle(0, 0, 100, 100), new Rectangle(0, 0, _a.Width, _a.Height), GraphicsUnit.Pixel);
            g.Dispose();
            if (_b != null)
            {
                _b.Save("D:\\aaa.jpg");

            }
            else
            {
                MessageBox.Show("as");
            }
        }
    }
}
