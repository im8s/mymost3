using System;
using System.Text;
using System.Security.Cryptography;
using WinFrmTalk.Model;
using WinFrmTalk;

public class DES
{
    /// <summary>
    /// 默认密钥向量
    /// </summary>
    private static readonly byte[] iv = { 1, 2, 3, 4, 5, 6, 7, 8 };

    /// <summary>
    /// 3des加密算法
    /// </summary>
    private static byte[] Encrypt(string content, byte[] key, CipherMode mode = CipherMode.CBC)
    {
        if (UIUtils.IsNull(content))
        {
            return null;
        }

        if (key == null || key.Length == 0)
        {
            return null;
        }

        try
        {
            using (TripleDESCryptoServiceProvider des = new TripleDESCryptoServiceProvider())
            {
                des.Key = key;
                des.Mode = mode;
                des.IV = iv;

                var desEncrypt = des.CreateEncryptor();
                var buffer = AES.ToByte(content);
                return desEncrypt.TransformFinalBlock(buffer, 0, buffer.Length);
            }
        }
        catch (Exception)
        {
            return null;
        }
    }


    /// <summary>
    /// 3des解密算法
    /// </summary>
    private static byte[] Decrypt(string content, byte[] key, CipherMode mode = CipherMode.CBC)
    {

        if (UIUtils.IsNull(content))
        {
            return null;
        }

        if (key == null || key.Length == 0)
        {
            return null;
        }

        try
        {
            using (TripleDESCryptoServiceProvider des = new TripleDESCryptoServiceProvider())
            {
                des.Key = key;
                des.Mode = mode;
                des.IV = iv;
                des.Padding = PaddingMode.PKCS7;

                var desDecrypt = des.CreateDecryptor();
                byte[] buffer = Convert.FromBase64String(content);

                return desDecrypt.TransformFinalBlock(buffer, 0, buffer.Length);
            }
        }
        catch (Exception)
        {
            return null;
        }
    }


    /// <summary>
    /// 消息加密
    /// </summary>
    public static void EncryptMessage(MessageObject message)
    {
        long timeSend = (long)message.timeSend;

        EncryptMessage(message, timeSend);
    }

    /// <summary>
    /// 消息加密
    /// </summary>
    public static void EncryptMessage(MessageObject message, long timeSend)
    {
        string keys = MD5.MD5Hex(Applicate.API_KEY + timeSend + message.messageId).Substring(0, 24);

        var result = Encrypt(message.content, AES.ToByte(keys));

        if (result != null && result.Length > 0)
        {
            message.content = Convert.ToBase64String(result);
            message.isEncrypt = 1;
        }
    }

    /// <summary>
    /// 消息解密
    /// </summary>
    public static void DecryptMessage(MessageObject message)
    {
        long timeSend = (long)message.timeSend;
        DecryptMessage(message, timeSend);
    }


    /// <summary>
    /// 消息解密
    /// </summary>
    public static void DecryptMessage(MessageObject message, long timeSend)
    {
        string keys = MD5.MD5Hex(Applicate.API_KEY + timeSend + message.messageId).Substring(0, 24);

        var result = Decrypt(message.content, AES.ToByte(keys));

        if (result != null && result.Length > 0)
        {
            message.content = AES.NewString(result);
            message.isEncrypt = 0;
        }
    }

    /// <summary>
    /// 消息解密
    /// </summary>
    public static string DecryptMessage(string content, long timeSend, string messageId)
    {
        try
        {
            string keys = MD5.MD5Hex(Applicate.API_KEY + timeSend + messageId).Substring(0, 24);

        var result = Decrypt(content, AES.ToByte(keys));

            if (result != null && result.Length > 0)
            {
                return AES.NewString(result);
            }
            else
            {
                return content;
            }
        }
        catch (Exception)
        {
            return content;
        }
       
    }
}
