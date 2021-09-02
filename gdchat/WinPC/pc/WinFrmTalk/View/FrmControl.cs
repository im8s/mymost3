using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View
{
    public partial class FrmControl : FrmSuspension
    {
        public Action<int> prefix;
        public FrmControl()
        {
            InitializeComponent();
            listCountry = new Country().GetCountries();
         
        }
        private List<Country> listCountry;
        private List<Control> controls = new List<Control>();
        internal   void loadData()
        {
            if(listCountry != null)
            {
                for (int i = 0; i < listCountry.Count; i++)
                {
                    UserCountry userCountry = new UserCountry();
                    userCountry.setdata(listCountry[i].country, listCountry[i].enName, listCountry[i].prefix.ToString());
                    userCountry.Click += UserCountry_Click;
                    controls.Add(userCountry);
                }
                palCountry.AddViewsToPanel(controls);
                Point p = new Point();
                p = Control.MousePosition;
                this.Location = new Point(Control.MousePosition.X - 30, Control.MousePosition.Y+20);
                this.Show();
            }
        }

        private void UserCountry_Click(object sender, EventArgs e)
        {
            UserCountry userCountry = (UserCountry)sender;
            prefix?.Invoke(userCountry.AreaC);
            this.Close();
           
        }
    }
}
