using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Helper.MVVM;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    public partial class FrmFdTabTest : Form
    {
        static int pageIndex = 1;
        public FrmFdTabTest()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon.Handle);//加载icon图标
        }

        private void FrmFdTabTest_Load(object sender, EventArgs e)
        {
            //this.UpdateStyles();
            //Messenger.Default.Register<bool>(this, EQFrmInteraction.MoreFriendList, item => AddFriendList1());

            //for (int i = 0; i < 3; i++)

            newsItem1.pic_head.BackgroundImage = new Bitmap(@"C:\Users\10976\Pictures\微信截图_20190115150602.png");
            newsItem1.readNum = 3;
        }

        public void AddFriendList()
        {            
            List<Control> views;    //控件集合

            #region 初始化第一次加载数据
            myTabLayoutPanel1.ShowLoading();

            List<Friend> friends = new Friend().GetByPage(1, 500);
            views = new List<Control>();
            foreach (Friend friend in friends)
            {
                UserItem fdcrl = new UserItem();
                fdcrl.nickName = friend.nickName;
                ImageLoader.Instance.DisplayAvatar(friend.userId, fdcrl.pic_head);

                views.Add(fdcrl);
            }
            //添加控件
            myTabLayoutPanel1.AddViewsToPanel(views);
            #endregion

            #region 回调滚动自动加载监听
            //回调滚动自动加载监听
            myTabLayoutPanel1.AddScollerBouttom((index) => {


                //需要移除的item
                var item = myTabLayoutPanel1.showInfo_Panel.GetControlFromPosition(0, 1);
                myTabLayoutPanel1.RemoveItem(item);

                //需要插入的item
                UserItem insert_item = new UserItem();
                insert_item.nickName = "sdsaaaaa";
                myTabLayoutPanel1.InsertItem(insert_item, 1);

                #region 添加自定义控件集合
                views = new List<Control>();
                //获取滚动面板
                TableLayoutPanelEx showInfo_Panel = this.myTabLayoutPanel1.CurrentPanel;
                friends = new Friend().GetByPage(index, 50);
                foreach (Friend friend in friends)
                {
                    UserItem fdcrl = new UserItem();
                    fdcrl.nickName = friend.nickName;
                    ImageLoader.Instance.DisplayAvatar(friend.userId, fdcrl.pic_head);

                    views.Add(fdcrl);
                }
                #endregion

                //添加控件
                myTabLayoutPanel1.AddViewsToPanel(views);
            }, 500);
            #endregion
        }
    }
}
