using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk.Model;

public class LocalDataUtils
{

    private static LocalConfigure configure;


    public static void SetStringData(string key, string value)
    {
        configure = new LocalConfigure() { AppKey = key, ValueStr = value };
       int index=  configure.InsertLCData();
        Console.WriteLine("index :"+index);
    }

    public static void SetIntData(string key, int value)
    {
        configure = new LocalConfigure() { AppKey = key, ValueInt = value };
        configure.InsertLCData();
    }

    public static void SetBoolData(string key, bool value)
    {

        configure = new LocalConfigure() { AppKey = key, ValueInt = value?1:0 };
        configure.InsertLCData();
    }


    public static void SetLongData(string key,long value)
    {
        configure = new LocalConfigure() { AppKey = key, ValueLong = value};
        configure.InsertLCData();
    }


    public static string GetStringData(string key, string def = "") {

        configure = new LocalConfigure() { AppKey = key};

        string value = configure.QueryStrValueByKey();
        if (string.IsNullOrEmpty(value))
        {
            value = def;
        }

        return value;
    }


    public static int GetIntData(string key, int def = 0)
    {
        configure = new LocalConfigure() { AppKey = key };

        int value = configure.QueryIntValueByKey();
        if (value == 0)
        {
            value = def;
        }

        return value;
    }
    
    public static bool GetBoolData(string key)
    {
        configure = new LocalConfigure() { AppKey = key };
        int value = configure.QueryIntValueByKey() ;
        return value == 1;
    }

    public static long GetLongData(string key, long def = 0)
    {
        configure = new LocalConfigure() { AppKey = key };

        long value = configure.QueryLongValueByKey();
        if (value == 0)
        {
            value = def;
        }

        return value;
    }


}