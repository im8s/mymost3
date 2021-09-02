using CCWin;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View
{
    

    public partial class FrmGroupChose : CCSkinMain
    {
        
        Friend GroupList = new Friend();
        private string Userid;
        private int index;
        
        private List<Control> uSEGroupCards = new List<Control>();
        private List<Friend> groups = new List<Friend>();
        private List<UserItem> userList = new List<UserItem>();
       
        public FrmGroupChose()
        {
         
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon.Handle);//加载icon图标
        }

        private void listView1_MouseDown(object sender, MouseEventArgs e)
        {


        }

        private void lswGroups_SelectedIndexChanged(object sender, EventArgs e)
        {
            ListBox list = new ListBox();
            USEGrouopsAdded uSEGrouops = new USEGrouopsAdded();
            list.Items.Add(uSEGrouops);

        }

        private void lstgroup_SelectedIndexChanged(object sender, EventArgs e)
        {
            USEGrouopsAdded uSEGrouops = new USEGrouopsAdded();

        }

        private void FrmGroupChose_Load(object sender, EventArgs e)
        {

           /* AutoCompleteStringCollection strings = new AutoCompleteStringCollection();
            for (int i = 0; i < list.Count; i++)
            {
                strings.Add("查询字符");
            }
            textbox.AutoCompleteCustomSource = strings;
            textbox.AutoCompleteSource = AutoCompleteSource.CustomSource;
            textbox.AutoCompleteMode = AutoCompleteMode.Suggest;*/
            

            List<Friend> groupsList = GroupList.GetFriendsByIsGroup();//获取数据库中的数据
            groups = groupsList;
            palGroups.SuspendLayout();

            for (int i = 0; i < groupsList.Count;i ++)
            {
                UserItem uSEGrouops = new UserItem();
                //uSEGrouops.BindClass = groupsList[i];
                // uSEGrouops.Tag = groupsList[i];
                //uSEGrouops.isCancel = true;
                ImageLoader.Instance.DisplayAvatar(groupsList[i].userId, uSEGrouops.pic_head);
              
                //EGrouops.pic.PersonPic = groupsList[i].piv
                 if(groupsList[i].nickName =="555")
                {
                    string x = groupsList[i].roomId;
                }
                uSEGrouops.Size = new Size(273, 52);
                uSEGrouops.Location = new Point(0, 52 * i);
               uSEGrouops.nickName = groupsList[i].nickName;
                uSEGrouops.userId = groupsList[i].userId;//每
                Userid = groupsList[i].userId;
                index = i;
               
                uSEGroupCards.Add(uSEGrouops);
                userList.Add(uSEGrouops);
                uSEGrouops.Tag = i.ToString(); 

                uSEGrouops.chb.Tag = i.ToString();
                
                uSEGrouops.Click += USEGrouops_Click;
                
            }
            palGroups.AddViewsToPanel(uSEGroupCards);
            palGroups.ResumeLayout();

            btnSure.Enabled = false;
           
       
        }

       
        public void AddandRemove( int i,CheckBox  check)
        {
            USEGrouopsAdded uSEGrouopsAdded = new USEGrouopsAdded();

            uSEGrouopsAdded.Size = new Size(273, 52);

            uSEGrouopsAdded.Location = new Point(3, 52 * i);
            uSEGrouopsAdded.picGroups.PersonPic = WinFrmTalk.Properties.Resources.Logo;
            uSEGrouopsAdded.lblName.Text = groups[index].nickName;
            uSEGrouopsAdded.Name = groups[index].userId;
            uSEGrouopsAdded.CangroupsEvent += USEGrouopsAdded_CangroupsEvent;

            int indexs = 0;
            if (check.Checked)
            {
                for (int j = 0; j < pangropsAdd.Controls.Count; j++)
                {
                    if (pangropsAdd.Controls[j].Name == groups[index].userId)
                    {
                        indexs = j;
                    }
                }
                pangropsAdd.Controls.RemoveAt(indexs);

                check .Checked= false;

            }
            else
            {

                pangropsAdd.Controls.Add(uSEGrouopsAdded);
                check .Checked= true;


            }
            if (pangropsAdd.Controls.Count == 0)
            {
                btnSure.Enabled = false;
            }
            else
            {
                btnSure.Enabled = true;
            }
        }
        private void USEGrouops_Click(object sender, EventArgs e)
        {
            UserItem button = (UserItem)sender;
            int i = pangropsAdd.Controls.Count;
            //1.当前的状态和当前的个数
           index = Convert.ToInt32( button.Tag);
          

            AddandRemove(i, button.chb);


        }

        private void USEGrouops_groupsEvent(USEGroupCard uSEGroupCard, bool isAdd)
        {
          
          
        }

        private void USEGrouopsAdded_CangroupsEvent(USEGrouopsAdded uSEGrouopsAdded)
        {
            pangropsAdd.Controls.Remove(uSEGrouopsAdded);
            for (int i = 0; i < palGroups.Controls.Count; i++)
            {
                if (groups[i].userId== uSEGrouopsAdded.Name)
                {
                    UserItem useGroupCard = userList[i];
                   // useGroupCard.isCancel = false;
                    useGroupCard.chb.Checked = false;
                    break;
                }
            }
            ///throw new NotImplementedException();
        }
        
        
        private void panel4_MouseDown(object sender, MouseEventArgs e)
        {
      
        }

        private void flowLayoutPanel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void btnCan_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void pangropsAdd_Paint(object sender, PaintEventArgs e)
        {

        }
    }
}
