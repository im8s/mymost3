using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk
{
    public partial class SearchControl : UserControl
    {
        public SearchControl()
        {
            InitializeComponent();
        }

        private string _GrayInputString;//搜索框地下的灰色字
        private int _Radius;

        public  string InputGrayString
        {
            get { return _GrayInputString; }
            set { _GrayInputString = value; }
        }
        public  int Radius
        {
            get { return _Radius; }
            set { _Radius = value; }
        }

        private void SearchControl_Load(object sender, EventArgs e)
        {
           
            textBox1.Text = InputGrayString;

            if (textBox1.Focused== false)
            {
               // textBox1.Text = InputGrayString;
           
             
                textBox1.BackColor = Color.Gainsboro;
                button1.Visible = false;
                
            }
            else
            {
                textBox1.Text ="";
                textBox1.BackColor = Color.White;
                button1.Visible = true;
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            textBox1.Text.Remove(0);
        }

        private void panel1_Paint(object sender, PaintEventArgs e)
        {
          //  Graphics grp = e.Graphics;
        }

        private void textBox1_AcceptsTabChanged(object sender, EventArgs e)
        {
            
        }

        private void textBox1_MouseEnter(object sender, EventArgs e)
        {
            textBox1.BackColor = Color.LightCyan;
            button1.Visible = true;
        }

        private void textBox1_MouseLeave(object sender, EventArgs e)
        {
            textBox1.BackColor = Color.White;
            button1.Visible = false;
        }
    }
}
