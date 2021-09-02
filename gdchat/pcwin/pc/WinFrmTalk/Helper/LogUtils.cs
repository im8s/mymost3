using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk;

public class LogUtils
{

    private  const bool SAVE_OUTPUT = false;

    public static void Log(string msg)
    {
        //       LogUtils.Log(msg);
        Console.WriteLine(msg);
        if (SAVE_OUTPUT)
        {
            Save(msg);
        }
    }


    public static void Error(string msg) {

        LogUtils.Log(msg);
        Save(msg);
    }


    public static void Save(string msg) {
        LogHelper.log.Error(msg);
    }

}
