using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk;

public class TimeUtils
{

    /// <summary>
    /// 与服务器时间差  使用本地 + diff 即可得到服务器时间
    /// 用于防止用户主动修改系统本地时间
    /// </summary>
    private static double Diff;

    private static DateTime minitime = new DateTime(1970, 1, 1, 0, 0, 0, 0);


    /// <summary>
    /// 返回当前秒级别的时间戳
    /// </summary>
    /// <returns></returns>
    public static long CurrentTime()
    {
        var ts = DateTime.UtcNow - minitime;
        long times = Convert.ToInt64(ts.TotalSeconds + SyncTimeDiff());
        return times;
    }

    /// <summary>
    /// 返回当前秒级别的时间戳
    /// </summary>
    /// <returns></returns>
    public static int CurrentIntTime()
    {
        var ts = DateTime.UtcNow - minitime;
        int times = Convert.ToInt32(ts.TotalSeconds + SyncTimeDiff());
        return times;
    }

    /// <summary>
    /// 返回当前秒级别的时间戳
    /// </summary>
    /// <returns></returns>
    public static double CurrentTimeDouble()
    {
        var ts = DateTime.UtcNow - minitime;
        return ts.TotalSeconds + SyncTimeDiff();
    }

    /// <summary>
    /// 返回当前毫秒时间戳
    /// </summary>
    /// <returns></returns>
    public static long CurrentTimeMillis()
    {
        var ts = DateTime.UtcNow - minitime;
        long times = Convert.ToInt64((ts.TotalSeconds + SyncTimeDiff()) * 1000);
        return times;
    }



    /// <summary>
    /// 返回当前毫秒小数点  0.445
    /// </summary>
    /// <returns></returns>

    static int count = 0;
    public static double CurrentMillisecondDecimal()
    {
        count++;
        return double.Parse("0." + count);
    }



    /// <summary>
    /// 返回 同步的服务器时间差，慎用！
    /// 仅适用于发送xmpp消息
    /// 为防止用户主动乱改系统时间导致发送时间错误的问题而编写的方法
    /// </summary>
    /// <returns>同步的服务器时间差</returns>
    public static double SyncTimeDiff()
    {
        return TimeUtils.Diff;
    }

    public static void SetTimeDiff(long stime)
    {

        var ts = DateTime.UtcNow - minitime;
        double diff = 0;
        if (stime.ToString().Length == 10) // 秒级别的时间戳
        {
            diff = (stime - ts.TotalSeconds);
            LogUtils.Error("秒服务器时间：" + stime + "  本地时间：" + ts.TotalSeconds + " 差值" + diff);
        }
        else
        {
            long times = Convert.ToInt64(ts.TotalSeconds * 1000);
            diff = (stime - times) / 1000.0;

            LogUtils.Error("毫秒秒服务器时间：" + stime + "  本地时间：" + times + " 差值" + diff);
        }
        TimeUtils.Diff = diff;
    }



    public static void SyscHttpTime()
    {
        HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "getCurrentTime")
              .AddParams("access_token", Applicate.Access_Token)
              .Build().Execute((suss, data) =>
              {
                  if (suss)
                  {
                      long sTime = UIUtils.DecodeLong(data, "data");
                      SetTimeDiff(sTime);
                  }
              });
    }


    /// <summary>
    /// 格式化时间
    /// </summary>
    /// <param name="time"></param>
    /// <param name="fromat"></param>
    /// <returns></returns>

    internal static string FromatCurrtTime()
    {
        DateTime dt = DateTime.Now;
        return dt.ToString("yyyy/MM/dd HH:mm:ss");   // yyyy/MM/dd HH:mm:ss
    }

    internal static string FromatTime(long time, string fromat)
    {
        DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1)); // 当地时区

        if (time.ToString().Length > 10)
        {
            double dtime = time / 1000.0;
            DateTime dt = startTime.AddSeconds(dtime);
            return dt.ToString(fromat);
        }
        else
        {
            DateTime dt = startTime.AddSeconds(time);
            return dt.ToString(fromat);
        }
    }


    /// <summary>
    /// 格式化时间 格式为 04-25 09:09
    /// </summary>
    /// <param name="time"></param>
    /// <returns></returns>
    internal static string FromatTime(long time)
    {
        return FromatTime(time, "MM-dd HH:mm");
    }

    internal static string FromatCountdown(long time)
    {
        if (time < 3600)
        {
            long minute = time / 60;
            long second = time % 60;
            return string.Format("{0:D2}", minute) + ":" + string.Format("{0:D2}", second);
        }
        else
        {
            long hour = time / 3600;
            long minute = time % 3600 / 60;
            long second = time % 3600 % 60;
            return string.Format("{0:D2}", hour) + ":" + string.Format("{0:D2}", minute) + ":" + string.Format("{0:D2}", second);
        }

    }

    #region 使用与最近消息列表显示时间

    /// <summary>
    /// 使用与最近消息列表显示时间
    /// </summary>
    /// <param name="time">秒</param>
    /// <returns></returns>
    /// 
    internal static string ChatLastTime(long time)
    {
        long delaySeconds = CurrentTime() - time;// 相差的秒数

        //if (delaySeconds < 10)
        //{
        //    return "刚刚";
        //}
        //else if (delaySeconds < 60)
        //{
        //    return delaySeconds + "秒前";
        //}
        //else if (delaySeconds < 60 * 30)
        //{
        //    return (delaySeconds / 60) + "分钟前";
        //}
        //else
        if (delaySeconds < 60 * 60 * 24)
        {
            if (TheSameDay(CurrentTime(), time))
            {
                // 同一天
                return FromatTime(time, "HH:mm");
            }
            else
            {
                // 昨天
                return "昨天";
            }
        }
        else if (delaySeconds < 60 * 60 * 72)
        {
            DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1)); // 当地时区
            DateTime dt = startTime.AddSeconds(time);
            return ToDayOfWeek(dt.DayOfWeek);
        }
        else
        {
            return FromatTime(time, "MM-dd");
        }
    }

    /// <summary>
    /// 使用与最近消息列表显示时间
    /// </summary>
    /// <param name="time">秒</param>
    /// <returns></returns>
    /// 
    internal static string ChatLastTime(double time)
    {
        return ChatLastTime((long)time);
    }

    #endregion


    /// <summary>
    /// 比较两个时间是否在同一天
    /// </summary>
    /// <param name="time1"></param>
    /// <param name="time2"></param>
    /// <returns></returns>
    private static bool TheSameDay(long time1, long time2)
    {
        DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1)); // 当地时区
        DateTime dt1 = startTime.AddSeconds(time1);
        DateTime dt2 = startTime.AddSeconds(time2);

        return dt1.Day == dt2.Day;
    }


    /// <summary>
    /// 返回泛型对应的星期字符串
    /// </summary>
    /// <param name="dayOfWeek"></param>
    /// <returns></returns>
    private static string ToDayOfWeek(DayOfWeek dayOfWeek)
    {
        switch (dayOfWeek)
        {
            case DayOfWeek.Monday:
                return "星期一";
            case DayOfWeek.Tuesday:
                return "星期二";
            case DayOfWeek.Wednesday:
                return "星期三";
            case DayOfWeek.Thursday:
                return "星期四";
            case DayOfWeek.Friday:
                return "星期五";
            case DayOfWeek.Saturday:
                return "星期六";
            case DayOfWeek.Sunday:
                return "星期天";
            default:
                return "";
        }

    }

}
