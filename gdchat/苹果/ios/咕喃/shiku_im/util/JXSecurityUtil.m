//
//  JXSecurityUtil.m
//  shiku_im
//
//  Created by p on 2019/7/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXSecurityUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "AESUtil.h"
#import "DESUtil.h"
#import "MD5Util.h"

#if DEBUG
    #define LOGGING_FACILITY(X, Y)    \
    NSAssert(X, Y);

    #define LOGGING_FACILITY1(X, Y, Z)    \
    NSAssert1(X, Y, Z);
#else
    #define LOGGING_FACILITY(X, Y)    \
    if (!(X)) {            \
        NSLog(Y);        \
    }

    #define LOGGING_FACILITY1(X, Y, Z)    \
    if (!(X)) {                \
        NSLog(Y, Z);        \
    }
#endif

@interface JXSecurityUtil ()

@property (strong, nonatomic) NSString * publicIdentifier;
@property (strong, nonatomic) NSString * privateIdentifier;

@end

@implementation JXSecurityUtil{
    
    
    size_t kSecAttrKeySizeInBitsLength;
}

+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static JXSecurityUtil *instance;
    dispatch_once(&onceToken, ^{
        instance = [[JXSecurityUtil alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if ([super init]) {
        _publicIdentifier = [NSString stringWithFormat:@"com.RSA.publicIdentifier.mykey.%@",g_myself.userId];
        _privateIdentifier = [NSString stringWithFormat:@"com.RSA.privateIdentifier.mykey.%@",g_myself.userId];
        // 获取本地aes加密后的私钥
        _privateAesStr = [g_default objectForKey:kMyPayPrivateKey];
    }
    return self;
}

#pragma mark ---------RSA---------
// 创建最新秘钥对
- (void)generateKeyPairRSA {
    
    
    _privateKeyRef = [self getRSAPrivateKey];
    
    _publicKeyRef = [self getRSAPublicKeyWithPrivateKey:_privateKeyRef];
    
    //    OSStatus sanityCheck = noErr;
    //    _publicKeyRef = NULL;
    //    _privateKeyRef = NULL;
    //
    //    // First delete current keys.
    ////    [self deleteAsymmetricKeys];
    //
    //    // Container dictionaries.
    //    NSMutableDictionary * privateKeyAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    //    NSMutableDictionary * publicKeyAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    //    NSMutableDictionary * keyPairAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    //
    //    // Set top level dictionary for the keypair.
    //    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    //    [keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:kSecAttrKeySizeInBitsLength] forKey:(__bridge id)kSecAttrKeySizeInBits];
    //
    //    // Set the private key dictionary.
    //    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    //    [privateKeyAttr setObject:_privateIdentifier forKey:(__bridge id)kSecAttrApplicationTag];
    //    // See SecKey.h to set other flag values.
    //
    //    // Set the public key dictionary.
    //    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    //    [publicKeyAttr setObject:_publicIdentifier forKey:(__bridge id)kSecAttrApplicationTag];
    //    // See SecKey.h to set other flag values.
    //
    //    // Set attributes to top level dictionary.
    //    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    //    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    //
    //    // SecKeyGeneratePair returns the SecKeyRefs just for educational purposes.
    //    sanityCheck = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &_publicKeyRef, &_privateKeyRef);
    //    LOGGING_FACILITY( sanityCheck == noErr && _publicKeyRef != NULL && _privateKeyRef != NULL, @"Something went wrong with generating the key pair." );
    //
    //    NSString *pubStr = [self getPublicKeyAsBase64];
    //    NSString *pubJavaStr = [self getPublicKeyAsBase64ForJavaServer];
    //    NSString *priStr = [self getPrivateKeyAsBase64];
    //    NSLog(@"zhang_pubStr = %@", pubStr);
    //    NSLog(@"zhang_pubJavaStr = %@", pubJavaStr);
    //    NSLog(@"zhang_priStr = %@", priStr);
    
    
}

// RSA创建私钥
- (SecKeyRef)getRSAPrivateKey {
    
    
    NSData* tag = [@"com.example.keys.mykey" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* attributes =@{
                                (id)kSecAttrKeyType : (id)kSecAttrKeyTypeRSA,
                                (id)kSecAttrKeySizeInBits : @1024,
                                (id)kSecPrivateKeyAttrs : @{
                                        (id)kSecAttrIsPermanent : @YES,
                                        (id)kSecAttrApplicationTag : tag,
                                        },
                                };
    
    CFErrorRef error = NULL;
    SecKeyRef privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes,
                                                 &error);
    if (!privateKey) {
        NSError *err = CFBridgingRelease(error);  // ARC takes ownership
        // Handle the error. . .
        NSLog(@"getPrivateKeyError - %@", err);
    }
    return privateKey;
}

// RSA根据私钥获取公钥
- (SecKeyRef)getRSAPublicKeyWithPrivateKey:(SecKeyRef)privateKey{

    SecKeyRef publicKey = SecKeyCopyPublicKey(privateKey);
    return publicKey;
}

- (void)setPrivateAesStr:(NSString *)privateAesStr {
    _privateAesStr = privateAesStr;
    // aes加密后的私钥保存本地
    [g_default setObject:privateAesStr forKey:kMyPayPrivateKey];
}

// 将秘钥key转data
- (NSData *)getKeyBitsFromKey:(SecKeyRef)Key {

    CFErrorRef error = NULL;
    NSData* keyData = (NSData*)CFBridgingRelease(  // ARC takes ownership
                                                 SecKeyCopyExternalRepresentation(Key, &error)
                                                 );
    if (!keyData) {
        NSError *err = CFBridgingRelease(error);  // ARC takes ownership
        // Handle the error. . .
        NSLog(@"getKeyBitsFromKeyError - %@", err);
    }
    
    return keyData;
}

// 根据秘钥的base64字符串转换为秘钥key
- (SecKeyRef)getRSAKeyWithBase64Str:(NSString *)base64Str isPrivateKey:(BOOL)isPrivateKey {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    // The key is assumed to be public, 2048-bit RSA
    NSDictionary* options;
    if (isPrivateKey) {
        options =@{
                   (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                   (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPrivate,
                   (id)kSecAttrKeySizeInBits: @1024,
                   };
    }else {
        options =@{
                   (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                   (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPublic,
                   (id)kSecAttrKeySizeInBits: @1024,
                   };
    }
    CFErrorRef error = NULL;
    SecKeyRef key = SecKeyCreateWithData((__bridge CFDataRef)data,
                                         (__bridge CFDictionaryRef)options,
                                         &error);
    if (!key) {
        NSError *err = CFBridgingRelease(error);  // ARC takes ownership
        // Handle the error. . .
    }
    
    return key;
}

// 根据通用的key 转换为iOS秘钥base64字符串
- (NSString *)getKeyForJavaServer:(NSData*)keyBits {
    
    static const unsigned char _encodedRSAEncryptionOID[15] = {
        
        /* Sequence of length 0xd made up of OID followed by NULL */
        0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00
        
    };
    
    // That gives us the "BITSTRING component of a full DER
    // encoded RSA public key - We now need to build the rest
    
    unsigned char builder[15];
    NSMutableData * encKey = [[NSMutableData alloc] init];
    int bitstringEncLength;
    
    // When we get to the bitstring - how will we encode it?
    
    if  ([keyBits length ] + 1  < 128 )
        bitstringEncLength = 1 ;
    else
        bitstringEncLength = (int)(([keyBits length] + 1 ) / 256 ) + 2;
    
    // Overall we have a sequence of a certain length
    builder[0] = 0x30;    // ASN.1 encoding representing a SEQUENCE
    // Build up overall size made up of -
    // size of OID + size of bitstring encoding + size of actual key
    size_t i = sizeof(_encodedRSAEncryptionOID) + 2 + bitstringEncLength +
    [keyBits length];
    size_t j = encodeLength(&builder[1], i);
    [encKey appendBytes:builder length:j +1];
    
    // First part of the sequence is the OID
    [encKey appendBytes:_encodedRSAEncryptionOID
                 length:sizeof(_encodedRSAEncryptionOID)];
    
    // Now add the bitstring
    builder[0] = 0x03;
    j = encodeLength(&builder[1], [keyBits length] + 1);
    builder[j+1] = 0x00;
    [encKey appendBytes:builder length:j + 2];
    
    // Now the actual key
    [encKey appendData:keyBits];
    
    // base64 encode encKey and return
    return [encKey base64EncodedStringWithOptions:0];
    
}

size_t encodeLength(unsigned char * buf, size_t length) {
    
    // encode length in ASN.1 DER format
    if (length < 128) {
        buf[0] = length;
        return 1;
    }
    
    size_t i = (length / 256) + 1;
    buf[0] = i + 0x80;
    for (size_t j = 0 ; j < i; ++j) {
        buf[i - j] = length & 0xFF;
        length = length >> 8;
    }
    
    return i + 1;
}

// 删除之前存储的秘钥
- (void)deleteAsymmetricKeys {
    
    OSStatus sanityCheck = noErr;
    NSMutableDictionary * queryPublicKey        = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * queryPrivateKey       = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * queryServPublicKey    = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:_publicIdentifier forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Set the private key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:_privateIdentifier forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Delete the private key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPrivateKey);
    LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing private key, OSStatus == %ld.", (long)sanityCheck );
    
    // Delete the public key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing public key, OSStatus == %ld.", (long)sanityCheck );
    
    
    if (_publicKeyRef) CFRelease(_publicKeyRef);
    if (_privateKeyRef) CFRelease(_privateKeyRef);
}

// 获取公钥的base64字符串
- (NSString *)getRSAPublicKeyAsBase64 {
    return [[self getKeyBitsFromKey:_publicKeyRef] base64EncodedStringWithOptions:0];
}

// 获取私钥的base64字符串
- (NSString *)getRSAPrivateKeyAsBase64 {
    
    return [[self getKeyBitsFromKey:_privateKeyRef] base64EncodedStringWithOptions:0];
}

// 获取通用公钥base64字符串
- (NSString *)getRSAPublicKeyAsBase64ForJavaServer {
    return [self getKeyForJavaServer:[self getKeyBitsFromKey:_publicKeyRef]];
}

// JAVA可用base64秘钥字符串转iOS秘钥字符串
- (NSString *)getPublicKeyFromJavaServer:(NSString *)keyAsBase64 {
    
    /* First decode the Base64 string */
    NSData *rawFormattedKey = [[NSData alloc] initWithBase64EncodedString:keyAsBase64 options:0];
    
    
    /* Now strip the uncessary ASN encoding guff at the start */
    unsigned char * bytes = (unsigned char *)[rawFormattedKey bytes];
    size_t bytesLen = [rawFormattedKey length];
    
    /* Strip the initial stuff */
    size_t i = 0;
    if (bytes[i++] != 0x30)
        return FALSE;
    
    /* Skip size bytes */
    if (bytes[i] > 0x80)
        i += bytes[i] - 0x80 + 1;
    else
        i++;
    
    if (i >= bytesLen)
        return FALSE;
    
    if (bytes[i] != 0x30)
        return FALSE;
    
    /* Skip OID */
    i += 15;
    
    if (i >= bytesLen - 2)
        return FALSE;
    
    if (bytes[i++] != 0x03)
        return FALSE;
    
    /* Skip length and null */
    if (bytes[i] > 0x80)
        i += bytes[i] - 0x80 + 1;
    else
        i++;
    
    if (i >= bytesLen)
        return FALSE;
    
    if (bytes[i++] != 0x00)
        return FALSE;
    
    if (i >= bytesLen)
        return FALSE;
    
    /* Here we go! */
    NSData * extractedKey = [NSData dataWithBytes:&bytes[i] length:bytesLen - i];
    
    // Base64 Encoding
    NSString *javaLessBase64String = [extractedKey base64EncodedStringWithOptions:0];
    return javaLessBase64String;
}

// RSA加密
- (NSData *)encryptMessageRSA:(NSData *)msgData{
    return [self encryptMessageRSA:msgData withPublicKey:_publicKeyRef];
}

- (NSData *)encryptMessageRSA:(NSData *)msgData withPublicKey:(SecKeyRef)publicKey {
    
    NSData *data = msgData;
    
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0*0, cipherBufferSize);
    
    NSData *plainTextBytes = data;
    size_t blockSize = cipherBufferSize - 11;
    size_t blockCount = (size_t)ceil([plainTextBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [NSMutableData dataWithCapacity:0];
    
    for (int i=0; i<blockCount; i++) {
        
        int bufferSize = (int)MIN(blockSize,[plainTextBytes length] - i * blockSize);
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        
        OSStatus status = SecKeyEncrypt(publicKey,
                                        kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
                                        &cipherBufferSize);
        
        if (status == noErr){
            NSData *encryptedBytes = [NSData dataWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
            
        }else{
            
            if (cipherBuffer) {
                free(cipherBuffer);
            }
            return nil;
        }
    }
    if (cipherBuffer) free(cipherBuffer);
    
    return encryptedData;
}


// RSA解密
- (NSData *)decryptMessageRSA:(NSData *)msgData {
    return [self decryptMessageRSA:msgData withPrivateKey:_privateKeyRef];
}
- (NSData *)decryptMessageRSA:(NSData *)msgData withPrivateKey:(SecKeyRef)privateKey {
    NSData *data = msgData;
    size_t cipherBufferSize = SecKeyGetBlockSize(privateKey);
    size_t keyBufferSize = [data length];
    
    NSMutableData *bits = [NSMutableData dataWithLength:keyBufferSize];
    OSStatus sanityCheck = SecKeyDecrypt(privateKey,
                                         kSecPaddingPKCS1,
                                         (const uint8_t *) [data bytes],
                                         cipherBufferSize,
                                         [bits mutableBytes],
                                         &keyBufferSize);
    
    if (sanityCheck != 0) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:sanityCheck userInfo:nil];
        NSLog(@"Error: %@", [error description]);
        
        return nil;
    }
    
    NSAssert(sanityCheck == noErr, @"Error decrypting, OSStatus == %ld.", (long)sanityCheck);
    
    [bits setLength:keyBufferSize];
    
    return bits;
}


// digest message with sha1
- (NSData *)sha1:(NSString *)str
{
    const void *data = [str cStringUsingEncoding:NSUTF8StringEncoding];
    CC_LONG len = (CC_LONG)strlen(data);
    uint8_t * md = malloc( CC_SHA1_DIGEST_LENGTH * sizeof(uint8_t) );;
    CC_SHA1(data, len, md);
    return [NSData dataWithBytes:md length:CC_SHA1_DIGEST_LENGTH];
}

// RSA签名
- (NSString *)getSignWithRSA:(NSString *)string withPriKey:(SecKeyRef)priKey {
    
    SecKeyRef privateKeyRef = priKey;
    if (!privateKeyRef) { NSLog(@"添加私钥失败"); return  nil; }
    NSData *sha1Data = [self sha1:string];
    unsigned char *sig = (unsigned char *)malloc(256);
    size_t sig_len = SecKeyGetBlockSize(privateKeyRef);
    OSStatus status = SecKeyRawSign(privateKeyRef, kSecPaddingPKCS1SHA1, [sha1Data bytes], CC_SHA1_DIGEST_LENGTH, sig, &sig_len);
    
    if (status != noErr) { NSLog(@"加签失败:%d",status); return nil; }
    
    NSData *outData = [NSData dataWithBytes:sig length:sig_len];
    return [outData base64EncodedStringWithOptions:0];
}

// RSA验签
- (BOOL)verifyRSA:(NSString *)string signature:(NSString *)signature withPublivKey:(SecKeyRef)pubcKey {
    
    SecKeyRef publicKeyRef = pubcKey;
    if (!publicKeyRef) { NSLog(@"添加公钥失败"); return NO; }
    NSData *originData = [self sha1:string];
    NSData *signatureData = [[NSData alloc] initWithBase64EncodedString:signature options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!originData || !signatureData) { return NO; }
    OSStatus status =  SecKeyRawVerify(publicKeyRef, kSecPaddingPKCS1SHA1, [originData bytes], originData.length, [signatureData bytes], signatureData.length);
    
    if (status ==noErr) { return  YES; }
    else{ NSLog(@"验签失败:%d",status); return NO; }
}



#pragma mark ---------DH---------
// DH生成秘钥对
- (void)generateKeyPairDH {
    CFErrorRef error = NULL;
    SecAccessControlRef sacObject;
    
    //设置ACL，使用kSecAccessControlTouchIDAny表示使用Touch ID来保护密钥。
    sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                kSecAccessControlTouchIDAny | kSecAccessControlPrivateKeyUsage, &error);
    
    NSDictionary *parameters = @{
//                                 (__bridge id)kSecAttrTokenID: (__bridge id)kSecAttrTokenIDSecureEnclave,//表示使用SecureEnclave来保存密钥
                                 (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeEC,//表示产生ECC密钥对，注意目前只支持256位的ECC算法
                                 (__bridge id)kSecAttrKeySizeInBits: @256,
                                 (__bridge id)kSecPrivateKeyAttrs: @{
//                                         (__bridge id)kSecAttrAccessControl: (__bridge_transfer id)sacObject,
                                         (__bridge id)kSecAttrIsPermanent: @YES,
//                                         (__bridge id)kSecAttrLabel: @"my-se-key",
                                         },
                                 };
 
    SecKeyRef publicKey, privateKey;
    OSStatus status = SecKeyGeneratePair((__bridge CFDictionaryRef)parameters, &publicKey, &privateKey);
    if (status == errSecSuccess) {
        
        NSData *privateKeyData1 = [g_securityUtil getKeyBitsFromKey:privateKey];
        NSData *publicKeyData1 = [g_securityUtil getKeyBitsFromKey:publicKey];
        
        NSString *priStr1 = [g_securityUtil getDHPrivateKeyAsBase64];
        NSString *pubStr = [g_securityUtil getDHPublicKeyAsBase64];
    }
    return;
    [self getDHPrivateKey];
    [self getDHPublicKeyWithPrivateKey];
}
// DH获取私钥
- (SecKeyRef)getDHPrivateKey {
    
    NSData* tag = [@"com.example.keys.mykey.DH" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* attributes =@{
                                (id)kSecAttrKeyType : (id)kSecAttrKeyTypeEC,
                                (id)kSecAttrKeySizeInBits : @256,
                                (id)kSecPrivateKeyAttrs : @{
                                        (id)kSecAttrIsPermanent : @NO,
                                        (id)kSecAttrApplicationTag : tag,
                                        },
                                };
    
    CFErrorRef error = NULL;
    SecKeyRef privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes,
                                                 &error);
    if (!privateKey) {
        NSError *err = CFBridgingRelease(error);  // ARC takes ownership
        // Handle the error. . .
        NSLog(@"getPrivateKeyError - %@", err);
    }
    _privateKeyRefDH = privateKey;
    return privateKey;
}
// DH根据私钥获取公钥
- (SecKeyRef)getDHPublicKeyWithPrivateKey {
    
    SecKeyRef publicKey = SecKeyCopyPublicKey(_privateKeyRefDH);
    _publicKeyRefDH = publicKey;
    return publicKey;
}

// 获取共享秘钥
- (NSData *) getSharedWithPrivateKey:(SecKeyRef)privateKey publicKey:(SecKeyRef)publicKey {
    NSString *identifier = [NSBundle mainBundle].bundleIdentifier;
    NSData *sharedData = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = @{
                             (id)kSecKeyKeyExchangeParameterRequestedSize : @(sharedData.length),
                             (id)kSecKeyKeyExchangeParameterSharedInfo : sharedData
                             
                             };
    CFErrorRef error = NULL;
    CFDataRef dataRef = SecKeyCopyKeyExchangeResult(privateKey, kSecKeyAlgorithmECDHKeyExchangeStandardX963SHA256, publicKey, (__bridge CFDictionaryRef)params, &error);
    
    return (__bridge NSData *)dataRef;
}

// 获取公钥base64
- (NSString *)getDHPublicKeyAsBase64 {
    return [[self getKeyBitsFromKey:_publicKeyRefDH] base64EncodedStringWithOptions:0];
}
// 获取私钥base64
- (NSString *)getDHPrivateKeyAsBase64 {
    
    return [[self getKeyBitsFromKey:_privateKeyRefDH] base64EncodedStringWithOptions:0];
}

//根据base64字符串获取秘钥
- (SecKeyRef)getDHKeyWithBase64Str:(NSString *)base64Str isPrivateKey:(BOOL)isPrivateKey {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    // The key is assumed to be public, 2048-bit RSA
    NSDictionary* options;
    if (isPrivateKey) {
        options =@{
                   (id)kSecAttrKeyType: (id)kSecAttrKeyTypeEC,
                   (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPrivate,
                   (id)kSecAttrKeySizeInBits: @256,
                   };
    }else {
        options =@{
                   (id)kSecAttrKeyType: (id)kSecAttrKeyTypeEC,
                   (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPublic,
                   (id)kSecAttrKeySizeInBits: @256,
                   };
    }
    CFErrorRef error = NULL;
    SecKeyRef key = SecKeyCreateWithData((__bridge CFDataRef)data,
                                         (__bridge CFDictionaryRef)options,
                                         &error);
    if (!key) {
        NSError *err = CFBridgingRelease(error);  // ARC takes ownership
        // Handle the error. . .
    }
    
    return key;
}
// 公钥转换成JAVA可用的base64
- (NSString *)getDHPublicKeyAsBase64ForJavaServer {
    return [self getKeyForJavaServer:[self getKeyBitsFromKey:_publicKeyRefDH]];
}



// 获取mac值（HMACMD5算法）
- (NSData *)getHMACMD5:(NSData *)data key:(NSData *)keyData {
    size_t dataLength = data.length;
    NSData *keys = keyData;
    size_t keyLength = keys.length;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgMD5, [keys bytes], keyLength, [data bytes], dataLength, result);
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        printf("%d ",result[i]);
    }
    printf("\n-------%s-------\n",result);
    //这里需要将result 转base64编码，再传回去
    NSData *data1 = [[NSData alloc] initWithBytes:result length:sizeof(result)];
    
    //    NSString *base64 = [data1 base64EncodedStringWithOptions:0];
    return data1;
}

void CCHmac(CCHmacAlgorithm algorithm,/* kCCHmacAlgSHA1, kCCHmacAlgMD5 */
            const void *key,
            size_t keyLength,/* length of key in bytes */
            const void *data,
            size_t dataLength,/* length of data in bytes */
            void *macOut)/* MAC written here */
__OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);

@end
