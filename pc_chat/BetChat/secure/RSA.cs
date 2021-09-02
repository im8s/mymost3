using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Security;
using System;
using System.Security.Cryptography;
using System.Text;

/// <summary>
/// version 1.1
/// 替换微软系统rsa解密
/// 2019-10-14 20:22:57
/// </summary>
class RSA
{
    /// <summary>
    /// 加密成base64字符编码
    /// </summary>
    /// <param name="data"></param>
    /// <param name="publicKey"></param>
    /// <returns></returns>
    public static string EncryptBase64Pk1(string content, string pk1publicKey)
    {
        // 公钥加密过程 (pk1和pk8的公钥是一样的所以不用转)  pk1->xml  xml -> 加密
        byte[] pk1byte = Convert.FromBase64String(pk1publicKey);

        string xmlpublickey = RSAKeyConvert.RSAPublicKeyJava2DotNet(pk1byte);

        byte[] enstr = Encrypt(ToByte(content), xmlpublickey);

        return Convert.ToBase64String(enstr);
    }


    /// <summary>
    /// 解密base64编码的字符串
    /// </summary>
    /// <param name="data">base64编码的字符串</param>
    /// <param name="privateKey">私钥pkcs1格式的私钥</param>
    /// <returns></returns>
    public static string DecryptFromBase64Pk1(string data, string pk1privateKey)
    {
        // 私钥解密过程 pk1->pk8  pk8->xml  xml -> 加密
        byte[] pk1byte = Convert.FromBase64String(pk1privateKey);

        //byte[] pk8byte = RSAKeyConvert.ConvertPkcs1ToPkcs8(pk1byte);

        //string xmlprivatekey = RSAKeyConvert.RSAPrivateKeyJava2DotNet(pk8byte);

        byte[] result = Decrypt(Convert.FromBase64String(data), pk1byte);
        if (result == null)
        {
            return "";
        }
        else
        {
            return Encoding.UTF8.GetString(result);
        }
    }



    /// <summary>
    /// 加密成base64字符编码
    /// </summary>
    /// <param name="data"></param>
    /// <param name="publicKey"></param>
    /// <returns></returns>
    public static string EncryptBase64Pk1(string content, byte[] pk1publicKey)
    {
        string xmlpublickey = RSAKeyConvert.RSAPublicKeyJava2DotNet(pk1publicKey);

        byte[] enstr = Encrypt(ToByte(content), xmlpublickey);

        return Convert.ToBase64String(enstr);
    }


    /// <summary>
    /// 解密base64编码的字符串
    /// </summary>
    /// <param name="data">base64编码的字符串</param>
    /// <param name="privateKey">私钥pkcs1格式的私钥</param>
    /// <returns></returns>
    public static byte[] DecryptFromBase64Pk1(string data, byte[] pk1privateKey)
    {
        byte[] result = Decrypt(Convert.FromBase64String(data), pk1privateKey);
        //return Encoding.UTF8.GetString(result);
        return result;
    }


    public static RsaKeyPairx CreateRsaKey()
    {

        RSACryptoServiceProvider rsa = new RSACryptoServiceProvider();
        string xmlPrivateKey = rsa.ToXmlString(true);//XML密钥
        string xmlPublicKey = rsa.ToXmlString(false);//XML公钥
        byte[] publickey = RSAKeyConvert.RSAPublicKeyDotNet2Java(xmlPublicKey);
        byte[] privatepk8key = RSAKeyConvert.RSAPrivateKeyDotNet2Java(xmlPrivateKey);
        byte[] privatekey = RSAKeyConvert.ConvertPkcs8ToPkcs1(privatepk8key);

        var keypair = new RsaKeyPairx(publickey, privatekey);


        return keypair;
    }



    /// <summary>
    ///  RSA私钥加密
    /// </summary>
    /// <param name="data">加密字符串</param>
    /// <param name="privateKey">公钥</param>
    /// <returns></returns>
    private static byte[] Encrypt(byte[] data, string publicKey)
    {
        try
        {
            byte[] encryptedData;
            //Create a new instance of RSACryptoServiceProvider.
            using (RSACryptoServiceProvider RSA = new RSACryptoServiceProvider())
            {
                //Import the RSA Key information. This only needs
                //toinclude the public key information.
                RSA.FromXmlString(publicKey);

                //Encrypt the passed byte array and specify OAEP padding.  
                //OAEP padding is only available on Microsoft Windows XP or
                //later.  
                encryptedData = RSA.Encrypt(data, false);
            }
            return encryptedData;
        }
        //Catch and display a CryptographicException  
        //to the console.
        catch (CryptographicException e)
        {
            Console.WriteLine(e.Message);

            return null;
        }
    }


    /// <summary>
    ///  RSA私钥解密
    /// </summary>
    /// <param name="data">加密字符串</param>
    /// <param name="privateKey">私钥</param>
    /// <returns></returns>
    private static byte[] Decrypt(byte[] data, byte[] privateKey)
    {
        try
        {
            AsymmetricKeyParameter priKey = ParseRsaPrivateKey(privateKey);
            IBufferedCipher c = CipherUtilities.GetCipher("RSA/ECB/PKCS1Padding");
            c.Init(false, priKey);
            return c.DoFinal(data);
        }
        catch (Exception e)
        {
            return null;
        }
    }

    /// <summary>
    /// 解析成rsa私钥
    /// 兼容pkcs8和pkcs1
    /// </summary>
    /// <param name="privateKey"></param>
    /// <returns></returns>
    private static AsymmetricKeyParameter ParseRsaPrivateKey(byte[] privateKey)
    {
        AsymmetricKeyParameter priKey = null;
        try
        {
            // pkcs1 转成 pkcs8
            var pkcs8 = RSAKeyConvert.ConvertPkcs1ToPkcs8(privateKey);
            priKey = PrivateKeyFactory.CreateKey(pkcs8);
        }
        catch (Exception e)
        {
            priKey = PrivateKeyFactory.CreateKey(privateKey);
        }

        return priKey;
    }



    /// <summary>
    ///  RSA私钥解密 弃用，坑逼微软不能解密某些rsa
    /// </summary>
    /// <param name="data">加密字符串</param>
    /// <param name="privateKey">私钥</param>
    /// <returns></returns>
    private static byte[] Decrypt1(byte[] data, string xmlPrivateKey)
    {
        try
        {
            byte[] decryptedData;
            //Create a new instance of RSACryptoServiceProvider.
            using (RSACryptoServiceProvider RSA = new RSACryptoServiceProvider())
            {
                //Import the RSA Key information. This needs
                //to include the private key information.
                RSA.FromXmlString(xmlPrivateKey);

                //Decrypt the passed byte array and specify OAEP padding.  
                //OAEP padding is only available on Microsoft Windows XP or
                //later.  
                decryptedData = RSA.Decrypt(data, false);
            }
            return decryptedData;
        }
        //Catch and display a CryptographicException  
        //to the console.
        catch (CryptographicException e)
        {
            Console.WriteLine(e.ToString());
            return null;
        }
    }

    // 签名
    internal static byte[] Sign(byte[] data, string xmlPrivateKey)
    {
        try
        {
            byte[] decryptedData;
            //Create a new instance of RSACryptoServiceProvider.
            using (RSACryptoServiceProvider RSA = new RSACryptoServiceProvider())
            {
                //Import the RSA Key information. This needs
                //to include the private key information.
                RSA.FromXmlString(xmlPrivateKey);

                //签名
                decryptedData = RSA.SignData(data, new SHA1CryptoServiceProvider());
            }
            return decryptedData;
        }
        //Catch and display a CryptographicException  
        //to the console.
        catch (CryptographicException e)
        {
            Console.WriteLine(e.ToString());
            return null;
        }
    }

    // 验签
    internal static bool Verify(byte[] data, string xmlPublickKey, byte[] sign)
    {
        try
        {
            bool result;
            //Create a new instance of RSACryptoServiceProvider.
            using (RSACryptoServiceProvider RSA = new RSACryptoServiceProvider())
            {
                //Import the RSA Key information. This needs
                //to include the private key information.
                RSA.FromXmlString(xmlPublickKey);

                //验签
                result = RSA.VerifyData(data, new SHA1CryptoServiceProvider(), sign);
            }
            return result;
        }

        //Catch and display a CryptographicException  
        //to the console.
        catch (CryptographicException e)
        {
            Console.WriteLine(e.ToString());
            return false;
        }
    }


    //验证签名
    public static bool VerifyFromBase64(string data, string pk1publicKey, string sign)
    {
        byte[] SignedData = Convert.FromBase64String(sign);
        byte[] pk1byte = Convert.FromBase64String(pk1publicKey);
        string xmlpublickey = RSAKeyConvert.RSAPublicKeyJava2DotNet(pk1byte);

        return Verify(ToByte(data), xmlpublickey, SignedData);
    }


    //对数据签名
    public static string SignBase64(string data, string pk1privateKey)
    {
        if (UIUtils.IsNull(data) || UIUtils.IsNull(pk1privateKey))
        {
            return "";
        }

        byte[] pk1byte = Convert.FromBase64String(pk1privateKey);
        byte[] pk8byte = RSAKeyConvert.ConvertPkcs1ToPkcs8(pk1byte);
        string xmlprivatekey = RSAKeyConvert.RSAPrivateKeyJava2DotNet(pk8byte);

        byte[] signedData = Sign(ToByte(data), xmlprivatekey);

        return Convert.ToBase64String(signedData);
    }

    public static byte[] ToByte(string input)
    {
        return Encoding.UTF8.GetBytes(input);
    }


    public class RsaKeyPairx
    {
        public byte[] PrivateKey { get; }
        public byte[] Publickey { get; }

        public RsaKeyPairx(byte[] publickey, byte[] privatekey)
        {
            PrivateKey = privatekey;
            Publickey = publickey;
        }

        internal string ToPublicString()
        {
            return Convert.ToBase64String(Publickey);
        }

        internal string ToPrivateString()
        {
            return Convert.ToBase64String(PrivateKey);
        }

    }
}