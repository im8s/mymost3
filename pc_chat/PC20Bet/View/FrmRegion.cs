using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk
{
    public partial class FrmRegion : FrmBase
    {
        public Action<object,object> openAction { get; private set; }

        public FrmRegion()
        {
            InitializeComponent();
        }
         public ContextMenuStrip tool = null;

        private void FrmRegion_Load(object sender, EventArgs e)
        {
            Areas areas = new Areas();
            areas.parent_id = 1;
            areas.type = 2;
            List<Areas> listAreas = areas.GetChildrenList();
            foreach (Areas a in listAreas)
            {
                Button button = new Button();
                button.Tag = a.id;
                button.Text= a.name;
                button.Size = new Size(214, 25);
                //加载子级菜单
                Areas areas2 = new Areas();
                areas2.parent_id = a.id;
                areas2.type = 3;
                List<Areas> listAreeas2 = areas2.GetChildrenList();
                tool= new ContextMenuStrip();
                foreach (Areas a2 in listAreeas2)
                {                
                    ToolStripMenuItem tool2 = new ToolStripMenuItem();
                    tool2.Tag = a2.id;
                    tool2.Text = a2.name;
                    //tool.AutoClose = true;
                    tool.Items.Add(tool2);
                    button.MouseEnter += Button_MouseEnter;
                    flowLayoutPanel1.Controls.Add(button);
                }
                Console.WriteLine(a.id);
                Console.WriteLine(a.name);
            }
        }

        private void Button_MouseEnter(object sender, EventArgs e)
        {
            tool.Show((Button)sender, new Point(0, ((Button)sender).Size.Height));
        }
    }
}
