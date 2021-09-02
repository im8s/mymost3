using System;
using System.Text;


public class SkSSLUtils
{

    /// <summary>
    /// 根据用户输入的密码获取 密文密码
    /// </summary>
    /// <param name="inputpwd"></param>
    /// <returns></returns>
    public static string CiphertextPwd(string inputpwd)
    {

        byte[] md5pwd = MD5.Encrypt(inputpwd);

        byte[] aespwd = AES.Encrypt(md5pwd, md5pwd);

        string hexpwd = MD5.MD5Hex(aespwd);

        Console.WriteLine("CiphertextPwd:  " + hexpwd);

        return hexpwd;
    }

    /// <summary>
    /// 根据用户输入的密码获取 明文密码钥匙
    /// </summary>
    /// <param name="inputpwd"></param>
    /// <returns></returns>
    public static byte[] ObviousPwd(string inputpwd)
    {
        byte[] md5pwd = MD5.Encrypt(inputpwd);

        return md5pwd;
    }

  

}
