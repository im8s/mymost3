using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;


public class AES
{
    private static readonly byte[] AES_IV = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };

    /// <summary>
    /// 加密成base 64 字符串
    /// </summary>
    /// <param name="data"></param>
    /// <param name="key"></param>
    /// <returns></returns>
    public static string EncryptBase64(string data, string key)
    {
        return EncryptBase64(data, ToByte(key));
    }

    public static string EncryptBase64(string data, byte[] key)
    {
        return EncryptBase64(ToByte(data), key);
    }

    /// <summary>
    /// 解密成base 64 字符串
    /// </summary>
    /// <param name="data"></param>
    /// <param name="key"></param>
    /// <returns></returns>
    public static string DecryptBase64(string data, string key)
    {
        byte[] bytes = Convert.FromBase64String(data);
        return DecryptBase64(bytes, ToByte(key));
    }

    /// <summary>
    /// 解密成base 64 字符串
    /// </summary>
    /// <param name="data"></param>
    /// <param name="key"></param>
    /// <returns></returns>
    public static byte[] DecryptBase64(string data, byte[] key)
    {
        byte[] bytes = Convert.FromBase64String(data);
        return Decrypt(bytes, key);
    }

    /// <summary>
    /// 加密成base 64 字符串
    /// </summary>
    /// <param name="data"></param>
    /// <param name="key"></param>
    /// <returns></returns>
    public static string EncryptBase64(byte[] data, byte[] key)
    {
        return Convert.ToBase64String(Encrypt(data, key));
    }


    /// <summary>
    /// 解密成base 64 字符串
    /// </summary>
    /// <param name="data"></param>
    /// <param name="key"></param>
    /// <returns></returns>
    public static string DecryptBase64(byte[] data, byte[] key)
    {
        return Encoding.UTF8.GetString(Decrypt(data, key));
    }



    /// <summary>
    /// AES 加密
    /// </summary>
    /// <param name="data"></param>
    /// <param name="key"></param>
    /// <returns></returns>
    public static byte[] Encrypt(byte[] data, byte[] key)
    {
        if (key.Length != 16)
        {
            byte[] temp = new byte[16];

            int length = Math.Min(16, key.Length);
            for (int i = 0; i < length; i++)
            {
                temp[i] = key[i];
            }

            key = temp;
        }

        //分组加密算法  
        using (SymmetricAlgorithm Aes = Rijndael.Create())
        {
            //设置密钥及密钥向量 
            Aes.Key = key;
            Aes.IV = AES_IV;

            using (MemoryStream ms = new MemoryStream())
            {
                using (CryptoStream cs = new CryptoStream(ms, Aes.CreateEncryptor(), CryptoStreamMode.Write))
                {
                    cs.Write(data, 0, data.Length);
                    cs.FlushFinalBlock();
                    byte[] cipherBytes = ms.ToArray();//得到加密后的字节数组   
                    cs.Close();
                    ms.Close();
                    return cipherBytes;
                }
            }
        }
    }



    /// <summary>
    /// AES解密
    /// </summary>
    /// <param name="data"></param>
    /// <param name="key"></param>
    /// <returns></returns>
    public static byte[] Decrypt(byte[] data, byte[] key)
    {
        if (key.Length != 16)
        {
            byte[] temp = new byte[16];

            int length = Math.Min(16, key.Length);
            for (int i = 0; i < length; i++)
            {
                temp[i] = key[i];
            }

            key = temp;
        }


        SymmetricAlgorithm Aes = Rijndael.Create();
        Aes.Key = key;
        Aes.IV = AES_IV;

        int lenth = 0;
        byte[] tempout = new byte[data.Length];
        using (MemoryStream ms = new MemoryStream(data))
        {
            using (CryptoStream cs = new CryptoStream(ms, Aes.CreateDecryptor(), CryptoStreamMode.Read))
            {
                lenth = cs.Read(tempout, 0, tempout.Length);
                cs.Close();
                ms.Close();
            }
        }

        byte[] result = new byte[lenth];
        Array.Copy(tempout, result, lenth);
        return result;
    }


    public static byte[] ToByte(string input)
    {
        return Encoding.UTF8.GetBytes(input);
    }

    public static string NewString(byte[] data)
    {
        return Encoding.UTF8.GetString(data);
    }
}
