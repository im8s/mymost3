using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using WinFrmTalk;
using WinFrmTalk.Model;
using WinFrmTalk.Properties;

public class ImageLoader
{

    // 单例模式 
    private ImageLoader()
    {
        mConfig = new ImageLoadConfig();
    }

    private static ImageLoader _instance;
    public static ImageLoader Instance => _instance ?? (_instance = new ImageLoader());


    private ImageLoadConfig mConfig;

    public ImageRequstBuild Load(string url)
    {
        ImageRequstBuild build = new ImageRequstBuild(mConfig);
        build.LoadUrl(url);
        return build;
    }

    public GroupAppendBuild Load(List<string> urls)
    {
        GroupAppendBuild build = new GroupAppendBuild(urls);
        return build;
    }



    public void DisplayImage(string url, PictureBox view)
    {
        Load(url).Into(view);
    }


    public void DisplayImage(string url, PictureBox view, bool cache)
    {
        if (cache)
        {
            DisplayImage(url, view);
        }
        else
        {
            Load(url).NoCache().NoReadCache().Into(view);
        }
    }

    /// <summary>
    /// 刷新头像缓存
    /// </summary>
    /// <param name="userId"></param>
    internal void RefreshAvatar(string userId)
    {

        if (string.IsNullOrEmpty(userId))
        {
            return;
        }

        if (userId.Length > 8)
        {
            return;
        }

        if ("10000".Equals(userId) || Friend.ID_NEW_FRIEND.Equals(userId) || Friend.ID_BAN_LIST.Equals(userId))
        {
            return;
        }

        if ("android".Equals(userId) || "ios".Equals(userId) || "mac".Equals(userId) || "web".Equals(userId))
        {
            return;
        }

        int userIdInt = -1;
        try
        {
            userIdInt = int.Parse(userId);
        }
        catch (Exception)
        {
        }

        if (userIdInt == -1 || userIdInt == 0)
        {
            return;
        }

        int dirName = userIdInt % 10000;
        string turl = Applicate.URLDATA.data.downloadAvatarUrl + "avatar/t/" + dirName + "/" + userId + ".jpg";
        string ourl = Applicate.URLDATA.data.downloadAvatarUrl + "avatar/o/" + dirName + "/" + userId + ".jpg";

        ImageCacheManager.Instance.ClearImageCache(turl);
        ImageCacheManager.Instance.ClearImageCache(ourl);

    }

    /// <summary>
    /// 加载头像
    /// </summary>
    /// <param name="userId"> 用户id</param>
    /// <param name="view">控件</param>
    internal void DisplayAvatar(string userId, PictureBox view)
    {
        DisplayAvatar(userId, view, true);
    }

    internal void DisplayAvatar(string userId, Action<Bitmap> compte)
    {
        DisplayAvatar(userId, true, compte);
    }

    internal void DisplayAvatar(string userId, bool isThumb, Action<Bitmap> compte)
    {
        DisplayAvatar(userId, null, isThumb, compte);
    }

    internal void DisplayAvatar(string userId, PictureBox view, Action<Bitmap> compte)
    {
        DisplayAvatar(userId, view, true, compte);
    }

    internal void DisplayAvatar(string userId, PictureBox view, bool isThumb, Action<Bitmap> compte = null)
    {
        if (UIUtils.IsNull(userId))
        {
            // 加载默认头像
            if (view != null)
            {
                view.BackgroundImage = Resources.avatar_default;
            }
            compte?.Invoke(Resources.avatar_default);
            return;
        }

        if (IsOtherHead(userId, view, compte))
        {
            return;
        }


        int userIdInt = -1;
        try
        {
            userIdInt = int.Parse(userId);
        }
        catch (Exception)
        {
            // 加载默认头像 可能是群组
            if (view != null)
            {
                view.BackgroundImage = Resources.avatar_group;
            }
            compte?.Invoke(Resources.avatar_group);
        }

        if (userIdInt == -1 || userIdInt == 0)
        {
            // 加载默认头像// 加载默认头像
            if (view != null)
            {
                view.BackgroundImage = Resources.avatar_default;
            }
            compte?.Invoke(Resources.avatar_default);
            return;
        }

        int dirName = userIdInt % 10000;

        string url = null;

        if (isThumb)
        {
            url = Applicate.URLDATA.data.downloadAvatarUrl + "avatar/t/" + dirName + "/" + userId + ".jpg";
        }
        else
        {
            url = Applicate.URLDATA.data.downloadAvatarUrl + "avatar/o/" + dirName + "/" + userId + ".jpg";
        }

        //Console.WriteLine("头像地址" + url);
        Load(url).Error(Resources.avatar_default).Background().Avatar().CompteListener(compte).Into(view);
    }


    internal bool IsOtherHead(string userId, PictureBox view, Action<Bitmap> compte)
    {

        Bitmap image = null;
        if (Friend.ID_SYSTEM.Equals(userId))
        {
            // 系统号
            image = Resources.avatar_notice;
        }

        if (Friend.ID_NEW_FRIEND.Equals(userId))
        {
            // 新的朋友头像
            image = Resources.avatar_newfriends;
        }


        if (Friend.ID_BAN_LIST.Equals(userId))
        {
            // 黑名单的头像            
            image = Resources.ic_head_black;
        }


        if ("android".Equals(userId))
        {
            // android手机
            image = Resources.ic_head_android;
        }

        if ("ios".Equals(userId))
        {
            // ios手机
            image = Resources.ic_head_phone;
        }
        if ("mac".Equals(userId) || "web".Equals(userId))
        {
            // 电脑
            image = Resources.ic_head_pc;
        }


        if (userId.Length > 8)
        {
            // 加载群头像
            image = Resources.avatar_default;
        }

        if (!BitmapUtils.IsNull(image))
        {

            if (view != null)
            {
                image = BitmapUtils.GetRoundImage(image, view.Width);
                view.BackgroundImage = image;
            }
            else
            {
                image = BitmapUtils.GetRoundImage(image, 36);
            }

            compte?.Invoke(image);
            return true;
        }



        return false;
    }


    /// <summary>
    /// 显示一个群成员管理头像 DisplayGroupAvatar
    /// </summary>
    /// <param name="userId">用户id</param>
    /// <param name="view">控件</param>
    /// <param name="role">身份</param>

    internal void DisplayGroupManager(string userId, PictureBox view, int role)
    {
        string url = GetHeadUrl(userId, true);

        Load(url).Error((str) =>
        {
            Bitmap bitmap = BitmapUtils.AppendGroupAvatar(Resources.avatar_default, role);
            view.Image = bitmap;

        }).Into((bit, path) =>
        {
            Bitmap bitmap = BitmapUtils.AppendGroupAvatar(bit, role);
            view.Image = bitmap;
        });
    }

    internal void DisplayGroupAvatar(string roomJid, string roomId, PictureBox view, Action<Bitmap> compte = null)
    {
        int roomJidCode = UIUtils.HashCode(roomJid);
        int a = Math.Abs(roomJidCode % 10000);
        int b = Math.Abs(roomJidCode % 20000);

        string roomUrl = Applicate.URLDATA.data.downloadAvatarUrl + "avatar/o/" + a + "/" + b + "/" + roomJid + ".jpg";

        Load(roomUrl).Error((str) =>
        {
            AppendRoomHead(roomId, view, compte);

        }).Into((bit, path) =>
        {
            bit = BitmapUtils.GetRoundImage(bit);
            if (view != null)
            {
                bit = BitmapUtils.ChangeSize(bit, view.Width, view.Width);
                view.BackgroundImage = bit;
            }

            view.BackgroundImage = bit;
            compte?.Invoke(bit);
        });


    }


    private void AppendRoomHead(string roomId, PictureBox view, Action<Bitmap> compte = null)
    {

        RoomMember roomMember = new RoomMember() { roomId = roomId };
        List<RoomMember> menbers = roomMember.GetRommMemberListByHead();

        if (menbers == null || menbers.Count < 2)
        {
            // 加载群头像
            Bitmap bitmap = BitmapUtils.GetRoundImage(Resources.avatar_group);

            if (view != null)
            {
                bitmap = BitmapUtils.ChangeSize(bitmap, view.Width, view.Width);
            }


            if (view != null)
            {
                view.BackgroundImage = bitmap;
                view.Refresh();
            }

            compte?.Invoke(bitmap);
        }
        else
        {
            List<string> urls = new List<string>();

            int count = Math.Min(menbers.Count, 5);
            for (int i = 0; i < count; i++)
            {
                urls.Add(GetHeadUrl(menbers[i].userId));
            }

            Load(urls).CompteListener(compte).Into(view);
        }
    }


    internal void SetAppConfig(ImageLoadConfig loadConfig)
    {
        mConfig = loadConfig;
        ImageCacheManager.Instance.SetMaxCount(loadConfig.maxCount);
    }

    public string GetHeadUrl(string userId, bool isThumb = true)
    {
        if (string.IsNullOrEmpty(userId) || userId.Length > 8)
        {
            // 加载默认头像
            return "";
        }

        int userIdInt = -1;
        try
        {
            userIdInt = int.Parse(userId);
        }
        catch (Exception)
        {
            // 加载默认头像
            //可能是群组
        }

        if (userIdInt == -1 || userIdInt == 0)
        {
            // 加载默认头像
            return "";
        }

        int dirName = userIdInt % 10000;

        string url = null;

        if (isThumb)
        {
            url = Applicate.URLDATA.data.downloadAvatarUrl + "avatar/t/" + dirName + "/" + userId + ".jpg";
        }
        else
        {
            url = Applicate.URLDATA.data.downloadAvatarUrl + "avatar/o/" + dirName + "/" + userId + ".jpg";
        }

        //LogUtils.Log("头像地址" + url);

        return url;
    }

}
