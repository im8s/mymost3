using Org.BouncyCastle.Asn1;
using Org.BouncyCastle.Asn1.Pkcs;
using Org.BouncyCastle.Asn1.Sec;
using Org.BouncyCastle.Asn1.X509;
using Org.BouncyCastle.Asn1.X9;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Parameters;
using Org.BouncyCastle.Math;
using Org.BouncyCastle.Pkcs;
using Org.BouncyCastle.Security;
using Org.BouncyCastle.Utilities;
using Org.BouncyCastle.X509;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

class ECDH
{

    const string Algorithm = "ECDH";

    // 生成dh密钥对
    public static ECDHKeyPair CretaeDHKeyPair()
    {
        // 从框架中取出 secp256k1 曲线
        //X9ECParameters x9 = ECNamedCurveTable.GetByName("SecP256k1"); // SecP256k1
        //// 根据曲线生成 ec参数
        //ECDomainParameters ecSpec = new ECDomainParameters(x9.Curve, x9.G, x9.N, x9.H);

        // 从框架中取出 ecdh 密钥生成器
        IAsymmetricCipherKeyPairGenerator keyGen = GeneratorUtilities.GetKeyPairGenerator(Algorithm);
        // 根据 secp256k1 曲线 初始化 ecdh 密钥生成器 

        keyGen.Init(new ECKeyGenerationParameters(SecObjectIdentifiers.SecP256k1, new SecureRandom()));
        // 生成随机的密钥对
        AsymmetricCipherKeyPair aKeyPair = keyGen.GenerateKeyPair();

        // 将生成的密钥对转换成 byte数组  pkcs#8
        //byte[] publickey = SubjectPublicKeyInfoFactory.CreateSubjectPublicKeyInfo(aKeyPair.Public).GetEncoded();
        //byte[] privatekey = PrivateKeyInfoFactory.CreatePrivateKeyInfo(aKeyPair.Private).GetEncoded();

        // 将生成的密钥对转换成 byte数组  pkcs#1
        byte[] publickey1 = SubjectPublicKeyInfoFactory.CreateSubjectPublicKeyInfo(aKeyPair.Public).ToAsn1Object().GetDerEncoded();
        byte[] privatekey1 = PrivateKeyInfoFactory.CreatePrivateKeyInfo(aKeyPair.Private).ParsePrivateKey().GetDerEncoded();

        // 返回自定义的ecdh密钥对
        return new ECDHKeyPair(publickey1, privatekey1);
    }



    // 密钥协商
    public static byte[] ComputeSharedSecret(byte[] myPrivateKey, byte[] recePublicKey)
    {
        // 将私钥byte[] 转换成私钥类 
        var privKey = TryGetPrivateKey(myPrivateKey);  //PrivateKeyFactory.CreateKey(myPrivateKey);

        // 将公钥byte[] 转换成公钥类
        var publicKey = PublicKeyFactory.CreateKey(recePublicKey);

        // 从框架中取出 ecdh 协议
        var keyAgreeBasic = AgreementUtilities.GetBasicAgreement(Algorithm);
        // 传入私钥 初始化 协议
        keyAgreeBasic.Init(privKey);

        // 协商密钥
        BigInteger k1 = keyAgreeBasic.CalculateAgreement(publicKey);

        Console.WriteLine("Secret: {0}", k1.ToString());
        // 转换成byte[] 数组
        return k1.ToByteArray();
    }



    // 私钥兼容性处理
    public static AsymmetricKeyParameter TryGetPrivateKey(byte[] privateKey)
    {
        try
        {
            Asn1Object prim = Asn1Object.FromByteArray(privateKey);
            var algorith = new AlgorithmIdentifier(X9ObjectIdentifiers.IdECPublicKey, SecObjectIdentifiers.SecP256k1);
            var private8key = PrivateKeyFactory.CreateKey(new PrivateKeyInfo(algorith, prim));
            return private8key;
        }
        catch (Exception)
        {
            var privKey = PrivateKeyFactory.CreateKey(privateKey);
            return privKey;
        }
    }




    public class ECDHKeyPair
    {
        public byte[] PublicKey { get; set; }
        public byte[] PrivateKey { get; set; }

        public ECDHKeyPair(byte[] publickey, byte[] privatekey)
        {
            PrivateKey = privatekey;
            PublicKey = publickey;
        }

        internal string ToPublicString()
        {
            return Convert.ToBase64String(PublicKey);
        }

        internal string ToPrivateString()
        {
            return Convert.ToBase64String(PrivateKey);
        }
    }





    /////////////////////////////////////////test/////////////////////////////////////////
    
    private void Button2_Click(object sender, EventArgs e)
    {
        // test pc
        var aKeyPair = ECDH.CretaeDHKeyPair();
        var bKeyPair = ECDH.CretaeDHKeyPair();

        var s1 = ECDH.ComputeSharedSecret(aKeyPair.PrivateKey, bKeyPair.PublicKey);
        var s2 = ECDH.ComputeSharedSecret(bKeyPair.PrivateKey, aKeyPair.PublicKey);

        // success s1 == s2
        bool equal = Arrays.AreEqual(s1, s2);

        Console.WriteLine("test pcresult : " + equal);
    }

    private void Button3_Click(object sender, EventArgs e)
    {
        // test android 
        string apublickey = "MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAECnIoYlaZ7IK2u7rSKpG86kF9JRTy05/8qtn3YLRmnhPj6P/Y+vA/M3jC7snfeuBhvdqda+8QL6XIP6SP0wchWA==";
        string aprivatekey = "MIGNAgEAMBAGByqGSM49AgEGBSuBBAAKBHYwdAIBAQQgztDVaP0kV3WSQ7MX58KDwGxYlFkcRKt4cwWVvlP7KrGgBwYFK4EEAAqhRANCAAQKcihiVpnsgra7utIqkbzqQX0lFPLTn/yq2fdgtGaeE+Po/9j68D8zeMLuyd964GG92p1r7xAvpcg/pI/TByFY";

        string bpublickey = "MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEdDUzfpfkMPLDigXNvExhNs7nXXqz8huIcxxjnshaYsoXDE97KjptLR5rugk4po5gQjhihskS1tmREoXlnyU8zw==";
        string bprivatekey = "MIGNAgEAMBAGByqGSM49AgEGBSuBBAAKBHYwdAIBAQQgO88xAcjiRUBgzWurtbO7cmx+FhguIs8bqnaR1Qij1C2gBwYFK4EEAAqhRANCAAR0NTN+l+Qw8sOKBc28TGE2zudderPyG4hzHGOeyFpiyhcMT3sqOm0tHmu6CTimjmBCOGKGyRLW2ZESheWfJTzP";


        var apk = Convert.FromBase64String(apublickey);
        var avk = Convert.FromBase64String(aprivatekey);


        var bpk = Convert.FromBase64String(bpublickey);
        var bvk = Convert.FromBase64String(bprivatekey);

        var s1 = ECDH.ComputeSharedSecret(avk, bpk);
        var s2 = ECDH.ComputeSharedSecret(bvk, apk);

        // success s1 == s2
        bool equal = Arrays.AreEqual(s1, s2);

        Console.WriteLine("test android result : " + equal);
    }

    private void Button4_Click(object sender, EventArgs e)
    {
        // test android and pc

        var aKeyPair = ECDH.CretaeDHKeyPair();

        string apublickey = "MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAECnIoYlaZ7IK2u7rSKpG86kF9JRTy05/8qtn3YLRmnhPj6P/Y+vA/M3jC7snfeuBhvdqda+8QL6XIP6SP0wchWA==";
        string aprivatekey = "MIGNAgEAMBAGByqGSM49AgEGBSuBBAAKBHYwdAIBAQQgztDVaP0kV3WSQ7MX58KDwGxYlFkcRKt4cwWVvlP7KrGgBwYFK4EEAAqhRANCAAQKcihiVpnsgra7utIqkbzqQX0lFPLTn/yq2fdgtGaeE+Po/9j68D8zeMLuyd964GG92p1r7xAvpcg/pI/TByFY";


        Console.WriteLine("android public key :" + apublickey);
        Console.WriteLine("android private key :" + aprivatekey);

        Console.WriteLine();
        Console.WriteLine();

        Console.WriteLine("pc public key :" + aKeyPair.ToPublicString());
        Console.WriteLine("pc private key :" + aKeyPair.ToPrivateString());


        var apk = Convert.FromBase64String(apublickey);
        var avk = Convert.FromBase64String(aprivatekey);

        var s1 = ECDH.ComputeSharedSecret(avk, aKeyPair.PublicKey);
        var s2 = ECDH.ComputeSharedSecret(aKeyPair.PrivateKey, apk);

        bool equal = Arrays.AreEqual(s1, s2);
        Console.WriteLine("test android and pc result : " + equal);
    }


}