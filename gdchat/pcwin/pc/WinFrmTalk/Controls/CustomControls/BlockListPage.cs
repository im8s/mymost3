using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;
using WinFrmTalk.View.list;

namespace WinFrmTalk
{

    /// <summary>
    /// 黑名单列表控件
    /// </summary>
    public partial class BlockListPage : UserControl
    {

        private BlackListAdapter mAdapter;

        bool isNeedLoad = false;
        int mPageIndex= 0;
		int removecount= 0;
        public BlockListPage()
        {
            InitializeComponent();
            mAdapter = new BlackListAdapter();
            mAdapter.BlockList = this;
            xListView.FooterRefresh += OnFooterRefresh;
        }

        private void OnFooterRefresh()
        {
            if (isNeedLoad)
            {
                mPageIndex++;
                DownloadBlackList();
            }
        }


        #region 加载黑名单
        public void LoadData()
        {
            mPageIndex = 0;
            DownloadBlackList();
        }
        #endregion

        #region 从服务器获取黑名单
        public void DownloadBlackList()
        {
			removecount = 0;            isNeedLoad = false;
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + ApplicateConst.BlackList)
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("pageSize", "10")
                .AddParams("pageIndex", mPageIndex.ToString())
                .Build()
                .Execute((sccess, list) =>
                {
                    if (sccess)
                    {
                        List<Friend> friends = new Friend().AttentionToFriends(list);
                        foreach (var friend in friends)
                        {
                            friend.Status = Friend.STATUS_18;//写入黑名单至数据库
                            if (!friend.InsertAuto())
                            {
                               LogUtils.Log("写入数据库失败： " + friend.NickName);
                            }
                        }
                        ShowBlackList(friends);
                       LogUtils.Log("down friends compte........");
                    }
                });
        }

        internal int GetListWidth()
        {
            return xListView.Width;
        }

        #endregion

        #region 加载黑名单列表
        private void ShowBlackList(List<Friend> friendList)
        {
            if (friendList == null)
            {
                //本地查询查询出黑名单列表
                //friendList = new Friend { IsGroup = 0 }.GetBlacksList();
                this.isNeedLoad = false;
                return;
            }

            if (friendList.Count == 10)
            {
                isNeedLoad = true;
            }


            if (mPageIndex == 0)
            {
                mAdapter.BindFriendData(friendList);
                xListView.SetAdapter(mAdapter);
            }
            else
            {
                int insert = mAdapter.GetItemCount();
                mAdapter.AppendRange(friendList);
                xListView.InsertRange(insert);
            }

            //mAdapter.BindFriendData(friendList);
            //xListView.SetAdapter(mAdapter);
        }
        #endregion

        #region 从黑名单列表中移除项
        private void RemoveBlockItem(string userId)
        {
            int index = mAdapter.GetIndexById(userId);
            if (index > -1)
            {
                xListView.RemoveItem(index);
                mAdapter.RemoveData(index);
 				removecount++;            }
     		if (removecount > 6)
            {
                // 重新加载一下
                LoadData();
            }        }
        #endregion

        #region 取消黑名单
        public void CancelBlock(BlackItem blockcontrol)
        {
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + ApplicateConst.DeleteBlackItem)
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("toUserId", blockcontrol.DataContext.UserId)
                .Build()
                //.AddErrorListener((issuccess, info) =>
                //{
                //    Messenger.Default.Send("取消黑名单失败：" + info, FrmMain.NOTIFY_NOTICE);//主窗口提示错误
                //})
                .Execute((issuccess, result) =>
                {
                    if (issuccess)//取消成功
                    {
                        RemoveBlockItem(blockcontrol.DataContext.UserId);
                        ShiKuManager.SendCancelBlockFriendMsg(blockcontrol.DataContext);//发送消息通知对应好友
                    }
                });
        }
        #endregion

    }
}
