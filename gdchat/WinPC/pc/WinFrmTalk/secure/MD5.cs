using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;



public class MD5
{
    public static string StringMD5(string input)
    {
        string md5 = StringMD5(Encoding.UTF8.GetBytes(input));
        return md5;
    }


    public static string StringMD5(byte[] input)
    {
        byte[] s = Encrypt(input);

        string md5 = "";
        for (int i = 0; i < s.Length; i++)
        {
            md5 = md5 + s[i].ToString("x2");
        }

        return md5;
    }


    public static byte[] Encrypt(string input)
    {
        return Encrypt(Encoding.UTF8.GetBytes(input));
    }


    public static byte[] Encrypt(byte[] input)
    {
        using (MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider())
        {
            byte[] output = md5.ComputeHash(input);
            return output;
        }

        //System.Security.Cryptography.MD5 md5 = new MD5CryptoServiceProvider();
        //byte[] output = md5.ComputeHash(input);
        //return output;
    }


    public static string MD5Hex(string input)
    {
        return HEX.Encode(Encrypt(input));
    }


    public static string MD5Hex(byte[] input)
    {
        return HEX.Encode(Encrypt(input));
    }

}
