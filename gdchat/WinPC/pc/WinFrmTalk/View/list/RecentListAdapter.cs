using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;
using WinFrmTalk.View;

public class RecentListAdapter : IBaseAdapter
{
    private List<Friend> datas;

    public FrmMain MainForm { get; set; }

    public RecentListLayout RecentList { get; set; }

    public void BindFriendData(List<Friend> data)
    {
        datas = data;
    }

    public override int GetItemCount()
    {
        if (UIUtils.IsNull(datas))
        {
            return 0;
        }

        return datas.Count;
    }

    public override Control OnCreateControl(int index)
    {
        Friend friend = datas[index];
        NewsItem item = new NewsItem();
        item.FriendData = friend;
        // 窗口句柄创建完成才能去加载头像
        //item.RefreshFriendImage();

        // 绑定点击事件
        item.Click += RecentList.MouseClickItem;
        item.DoubleClick += RecentList.SeparateChatForm;
        // 绑定右键菜单
        item = BindContextMenu(item);
        return item;


    }

    public override int OnMeasureHeight(int index)
    {
        return 60;
    }


    public void InsertData(int index, Friend data)
    {
        datas.Insert(index, data);
    }

    public override void RemoveData(int index)
    {
        datas.RemoveAt(index);
    }


    #region 设置右键菜单

    public NewsItem BindContextMenu(NewsItem item)
    {

        var deleteitem = new MenuItem() { Text = "删除" };
        deleteitem.Click += (sen, eve) =>
        {
            item.FriendData.UpdateLastContent(null, item.FriendData.LastMsgTime);
            RecentList.DeleteRecentItem(item.FriendData);
        };

        var stickTopItem = new MenuItem
        {
            Text = (item.FriendData.TopTime == 0 ? "置顶" : "取消置顶")
        };

        stickTopItem.Click += (sen, eve) =>
        {

            if (item.FriendData.TopTime > 0)//如果置顶时间为0则为未置顶
            {
                item.FriendData.UpdateTopTime(0);
                item.FriendData.TopTime = 0;
            }
            else
            {
                item.FriendData.TopTime = TimeUtils.CurrentIntTime();
                item.FriendData.UpdateTopTime(item.FriendData.TopTime);
            }

            //Console.WriteLine("最近消息列表修改置顶状态 "+ item.friendData.TopTime);

            Messenger.Default.Send(item.FriendData, MessageActions.UPDATE_FRIEND_TOP);

            // 保存置顶状态到服务器，刷新其他端
            RequestFriendTop(item.FriendData);
        };


        //设置右键菜单
        var menuList = new ContextMenu();
        menuList.Popup += (sen, eve) =>
        {
            RecentList.MouseClickItem(item, null);
        };
        menuList.MenuItems.Add(deleteitem);
        menuList.MenuItems.Add(stickTopItem);
        item.ContextMenu = menuList;
        return item;
    }

    private void RequestFriendTop(Friend friend)
    {
        string url = friend.IsGroup == 1 ? "room/member/setOfflineNoPushMsg" : "friends/update/OfflineNoPushMsg";
        string type = friend.IsGroup == 1 ? "1" : "2";
        string useridKey = friend.IsGroup == 1 ? "roomId" : "toUserId";
        string useridvalue = friend.IsGroup == 1 ? friend.RoomId : friend.UserId;
        string topvalue = friend.TopTime == 0 ? "0" : "1";

        HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + url)
               .AddParams("access_token", Applicate.Access_Token)
               .AddParams("userId", Applicate.MyAccount.userId)
               .AddParams(useridKey, useridvalue)
               .AddParams("type", type)
               .AddParams("offlineNoPushMsg", topvalue)
               .NoErrorTip()
               .Build().Execute(null);
    }

    #endregion


    public void ChangeData(int index, Friend friend)
    {
        datas[index] = friend;
    }


    public Friend GetData(int index)
    {
        return datas[index];
    }

    public void MoveData(int fromIndex, int toIndex)
    {
        if (fromIndex == toIndex)
        {
            return;
        }

        Friend temp = datas[fromIndex];

        // 从 1 --->   3
        if (fromIndex < toIndex)
        {
            int next = fromIndex + 1;
            while (next <= toIndex)
            {
                // 移动数据
                datas[next - 1] = datas[next];
                next++;
            }
        }
        else
        {
            // 从 5---->  2
            int next = fromIndex - 1;
            while (next >= toIndex)
            {
                // 移动数据
                datas[next + 1] = datas[next];
                next--;
            }
        }

        datas[toIndex] = temp;
    }


    public int GetIndexByFriendId(string userId)
    {
        //GetItemCount是否准确？
        for (int i = 0; i < GetItemCount(); i++)
        {
            string name = datas[i].NickName;
            if (datas[i].UserId.Equals(userId))
            {
                return i;
            }
        }

        return -1;
    }

    internal int GetTotalUnReadCount()
    {
        int totalcount = 0;

        foreach (var item in datas)
        {
            totalcount += item.MsgNum;

        }

        return totalcount;
    }

    internal int NextUnpoint(int currt)
    {
        int next = currt;
        for (int i = currt + 1; i < currt + GetItemCount(); i++)
        {
            next = i % GetItemCount();
            if (datas[next].MsgNum > 0)
            {
                return next;
            }
        }

        return currt;
    }
}
