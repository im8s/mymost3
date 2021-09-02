using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Drawing2D;
using WinFrmTalk;


namespace WinFrmTalk
{
    public partial class PicChangeControl : UserControl
    {
        private Image _PersonPic;//图像
        private string _UserName;

        public PicChangeControl()
        {
            InitializeComponent();

        }
        public Image PersonPic
        {
            get { return _PersonPic; }
            set { _PersonPic = value; }
        }
        public  string UserName
        {
            get { return _UserName; }
            set { _UserName = value; }
        }

        private void skinPictureBox1_Paint(object sender, PaintEventArgs e)
        {
            pictureBox1.Parent = panel1;
            panel1.BackColor = Color.Transparent;
            GraphicsPath path = new GraphicsPath();
            int h = pictureBox1.ClientRectangle.Width > pictureBox1.ClientRectangle.Height ? pictureBox1.Height : pictureBox1.Width;
            path.AddEllipse(pictureBox1.ClientRectangle.X, pictureBox1.ClientRectangle.Y, h-2, h-2);
            Region reg = new Region(path);
            this.pictureBox1.Region = reg;

            pictureBox1.BackgroundImage = _PersonPic;
           

            reg.Dispose();
            path.Dispose();
        }

        private void PicChangeControl_Load(object sender, EventArgs e)
        {
            //lblName.Text = UserName;
        }

        private void PicChangeControl_MouseMove(object sender, MouseEventArgs e)
        {
          //  panel1.BackColor = Color.Gray;
        }

        private void PicChangeControl_MouseLeave(object sender, EventArgs e)
        {
          //  panel1.BackColor = Color.Transparent;
        }

        private void panel1_MouseMove(object sender, MouseEventArgs e)
        {
           // panel1.BackColor = Color.Gray;
        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {

        }
    }
}

    
   
