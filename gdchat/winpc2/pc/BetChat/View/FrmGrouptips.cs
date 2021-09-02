using CCWin;
using Newtonsoft.Json;
using RichTextBoxLinks;
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
using WinFrmTalk.View.list;

namespace WinFrmTalk.View
{
    public partial class FrmGrouptips : FrmBase
    {
        public FrmGrouptips()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            mAdapter = new TipsAdapter();//公告适配
           
        }
        #region 全局变量
        public string roomId;//roomid
        public USEGroupTips SelectItems;//当前选中的项
        List<RoomMember> roommemberLst = new List<RoomMember>();//RoomMember集合

        private string userid = Applicate.MyAccount.userId;//当前用户的userid
        private LodingUtils loding;//等待符
        private Friend frienddata;//好友集合
        List<GroupNotices> groupNotices;//公告集合
        TipsAdapter mAdapter;
      
        #endregion
        #region 属性
        /// <summary>
        /// 当前用户角色
        /// </summary>
        public int CurrentRole
        {
            get; set;
        }
        /// <summary>
        /// 传参设置roomid
        /// </summary>
        /// <param name="RoomId"></param>
        public void SetData(Friend mfriend)
        {
            frienddata = mfriend;
            roomId = mfriend.RoomId;
        }
        /// <summary>
        /// 显示等待符
        /// </summary>
        private void ShowLodingDialog()
        {
            loding = new LodingUtils();
            loding.parent = palTab;
            loding.Title = "加载中";
            loding.start();
        }
        #endregion

        #region 加载公告
        /// <summary>
        /// 加载数据
        /// </summary>
        public void LoadData()
        {
            ShowLodingDialog();//等待符

            //判断当前角色是否有权限发布公告
            if (CurrentRole == 1 || CurrentRole == 2)
            {
                btnannounce.Visible = true;
            }
            else
            {
                btnannounce.Visible = false;
            }

            //获取群公告
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/get")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("roomId", roomId)
                .Build().Execute((sccess, room) =>
                {
                    if (sccess)
                    {
                        FillListData(room);//填充数据
                    }
                    loding.stop();//关闭等待符
                    
                });

        }
        #endregion
        #region  发布公告
        /// <summary>
        /// 发布公告
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnannounce_Click(object sender, EventArgs e)
        {

            AddTips addTips = new AddTips();//新公告编辑窗体
            addTips.ShowDialog();
            if (addTips.DialogResult == DialogResult.OK)
            {
                string notice = addTips.txtTips.Text;
                if (notice == "")
                {
                    HttpUtils.Instance.ShowTip("发布的新公告不能为空");
                    return;
                }
                else
                {
                    //ShowLodingDialog();
                    HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/update") //发布公告
                  .AddParams("access_token", Applicate.Access_Token)
                  .AddParams("roomId", roomId)
                  .AddParams("notice", notice)
                   .Build().Execute((sccess, room) =>
                   {
                       if (sccess)
                       {
                           GroupNotices group = new GroupNotices();
                           group.Time = UIUtils.CurrentTimeLong();
                           group.text = notice;
                           group.Userid = userid;
                           group.Roomid = roomId;
                           group.Id = UIUtils.DecodeString(room, "noticeId");
                           group.NickName = Applicate.MyAccount.nickname;

                           groupNotices.Insert(0, group);//公告集合新插入一行
                           palTab.InsertItem(0);
                       }
                       //loding.stop();
                   });
                }


            }

        }
        #endregion
        #region 右键菜单
        public void LblTips_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Right)
            {
                EQShowInfoPanelAlpha picture = sender as EQShowInfoPanelAlpha;//由于richbox有鼠标焦点问题，所以在绑定的时候在最顶层添加了一个透明面板
                //每一个item
                USEGroupTips uSEGroupTips = (USEGroupTips)picture.Parent;
                uSEGroupTips.ContextMenuStrip = ContextDel;//绑定右键菜单
                SelectItems = uSEGroupTips;
            }
        }
        #endregion
        #region  公告文本框的ContentsResized事件（自适应）
        public void lblTips_ContentsResized(object sender, ContentsResizedEventArgs e)
        {

            RichTextBoxEx richText = (RichTextBoxEx)sender;
            richText.Height = e.NewRectangle.Height + 10;

        }
        #endregion
        #region 将数据放入到面板中
        private void FillListData(Dictionary<string, object> keys)
        {

            RoomMember roomMember = new RoomMember();
            roomMember.roomId = roomId;
            roommemberLst = roomMember.TransToMember(keys, roomId);

            groupNotices = roomMember.NoticeLst;//获得公告集合
           
            mAdapter.SetMaengForm(this);
            mAdapter.BindDatas(groupNotices);
            palTab.SetAdapter(mAdapter);
        }
        #endregion
        #region 窗体关闭
        private void Grouptips2_FormClosed(object sender, FormClosedEventArgs e)
        {
            Applicate.tipsuseridlst.Remove(roomId);//关闭当前公告页面（避免同一页面多次重复打开）
            Messenger.Default.Unregister(this);//反注册
        }
        #endregion
        #region  删除群公告
        /// <summary>
        /// 删除群公告
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void menuitemDel_Click(object sender, EventArgs e)
        {
            HttpUtils.Instance.InitHttp(this);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "room/notice/delete") //删除公告
          .AddParams("access_token", Applicate.Access_Token)
          .AddParams("roomId", roomId)
          .AddParams("noticeId", SelectItems.Tag.ToString())
           .Build().Execute((sccess, room) =>
           {
               if (sccess)
               {
                   for (int i = 0; i < groupNotices.Count; i++)
                   {
                       if (groupNotices[i].Id == SelectItems.Tag.ToString())
                       {
                           palTab.RemoveItem(i);//从控件移除
                           mAdapter.RemoveData(i);//从数据集合移除
                           break;
                       }
                   }
                   Messenger.Default.Send(SelectItems.Tag.ToString(), MessageActions.Room_Deleate_ROOM_TIPS);
               }
               loding.stop();
           });
        }
        #endregion

        #region 编辑群公告
        /// <summary>
        ///编辑公告
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>

        private void menuitemEdi_Click(object sender, EventArgs e)
        {
            FrmTipsEdite frmTipsEdite = new FrmTipsEdite();
            frmTipsEdite.SetData(frienddata, SelectItems.tips, SelectItems.Tag.ToString());
            frmTipsEdite.Show();
            frmTipsEdite.sucerss = (sucee, tips) =>
                   {
                       if (sucee)
                       {

                           if (SelectItems.Controls["ritch"] != null)
                           {
                               SelectItems.Controls["ritch"].Text = tips;//更新新公告的内容
                               SelectItems.tips = tips;
                           }
                           //  SelectItems.ActiveControl.Text = tips;

                       }


                   };
        }
        #endregion
    }
}


