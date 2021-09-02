using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;


class MAC
{
    public static byte[] Encode(string data, string key)
    {
        return Encode(ToByte(data), ToByte(key));
    }

    public static byte[] Encode(byte[] data, string key)
    {
        return Encode(data, ToByte(key));
    }

    public static byte[] Encode(byte[] data, byte[] key)
    {
        using (HMACMD5 hmac = new HMACMD5(key))
        {
            byte[] hash = hmac.ComputeHash(data);
            return hash;
        }
    }

    public static string EncodeBase64(string data, string key)
    {
        return EncodeBase64(ToByte(data), ToByte(key));
    }

    public static string EncodeBase64(string data, byte[] key)
    {
        return EncodeBase64(ToByte(data), key);
    }

    public static string EncodeBase64(byte[] data, string key)
    {
        return EncodeBase64(data, ToByte(key));
    }

    public static string EncodeBase64(byte[] data, byte[] key)
    {
        return Convert.ToBase64String(Encode(data, key));
    }


    public static byte[] ToByte(string input)
    {

        return Encoding.UTF8.GetBytes(input);
    }

}
