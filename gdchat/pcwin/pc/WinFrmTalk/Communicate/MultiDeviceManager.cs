using System;
using System.Collections.Generic;

/// <summary>
/// 多点登录管理
/// </summary>
public class MultiDeviceManager
{
    private static Dictionary<string, bool> allDevice;
    private static MultiDeviceManager _instance;

    // 单例模式
    private MultiDeviceManager()
    {
    }

    private void InitDeviceState()
    {
        allDevice = new Dictionary<string, bool>();
        allDevice.Add("android", false);
        allDevice.Add("ios", false);
        allDevice.Add("web", false);
        allDevice.Add("mac", false);
    }

    // 是否开启多点登录
    public bool IsEnable { get; set; }


    public static MultiDeviceManager Instance => _instance ?? (_instance = new MultiDeviceManager());


    internal void ChangeDeviceState(string device)
    {
        InitDeviceState();

        if (!UIUtils.IsNull(device) && device.Length > 3)
        {
            string[] dev = device.Split(',');

            foreach (var item in dev)
            {
                if (allDevice.ContainsKey(item))
                {
                    allDevice[item] = true;
                }
            }
        }

        Console.WriteLine("ChangeDeviceState: " + device);
    }


    /// <summary>
    /// 判断设备是否在线
    /// </summary>
    /// <param name="userid"></param>
    /// <returns></returns>
    public bool IsDeviceLine(string userid)
    {
        if (allDevice!= null)
        {
            if (allDevice.ContainsKey(userid))
            {
                return allDevice[userid];
            }
        }
       
        return false;
    }
}
