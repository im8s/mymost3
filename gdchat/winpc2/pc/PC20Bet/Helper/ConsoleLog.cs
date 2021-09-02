using System;

public static class ConsoleLog
{
    #region 控制台输出

    /// <summary>
    /// 控制台输出
    /// </summary>
    /// <param name="text"></param>

    /// <summary>
    /// 控制台输出
    /// </summary>
    /// <param name="text"></param>
    public static void Output(object text)
    {
       LogUtils.Log(text.ToString());
    }

    /// <summary>
    /// 控制台输出
    /// </summary>
    /// <param name="text"></param>
    /// <param name="arg0"></param>
    public static void Output(string text, object arg0)
    {
        try
        {
          
           Console.WriteLine(text+arg0);
        }
        catch (Exception ex)
        {
           LogUtils.Log(ex.Message);
        }
    }
    #endregion

}
