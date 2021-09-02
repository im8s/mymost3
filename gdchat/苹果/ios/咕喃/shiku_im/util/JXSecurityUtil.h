//
//  JXSecurityUtil.h
//  shiku_im
//
//  Created by p on 2019/7/10.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXSecurityUtil : NSObject

@property (nonatomic, strong) NSString *privateAesStr;
@property (nonatomic) SecKeyRef publicKeyRef;
@property (nonatomic) SecKeyRef privateKeyRef;


@property (nonatomic, strong) NSString *privateAesStrDH;
@property (nonatomic) SecKeyRef publicKeyRefDH;
@property (nonatomic) SecKeyRef privateKeyRefDH;

+ (instancetype)sharedManager;

#pragma mark ---------RSA---------

// RSA生成秘钥对
- (void)generateKeyPairRSA;
// RSA获取私钥
- (SecKeyRef)getRSAPrivateKey;
// RSA根据私钥获取公钥
- (SecKeyRef)getRSAPublicKeyWithPrivateKey:(SecKeyRef)privateKey;
// 获取公钥base64
- (NSString *)getRSAPublicKeyAsBase64;
// 获取私钥base64
- (NSString *)getRSAPrivateKeyAsBase64;
//根据base64字符串获取秘钥
- (SecKeyRef)getRSAKeyWithBase64Str:(NSString *)base64Str isPrivateKey:(BOOL)isPrivateKey;
// 公钥转换成JAVA可用的base64
- (NSString *)getRSAPublicKeyAsBase64ForJavaServer;
// 根据通用的key 转换为iOS秘钥base64字符串
- (NSString *)getKeyForJavaServer:(NSData*)keyBits;
// JAVA可用base64秘钥字符串转iOS秘钥字符串
- (NSString *)getPublicKeyFromJavaServer:(NSString *)keyAsBase64;
// 将key转data
- (NSData *)getKeyBitsFromKey:(SecKeyRef)Key;
// RSA加密
- (NSData *)encryptMessageRSA:(NSData *)msgData;
- (NSData *)encryptMessageRSA:(NSData *)msgData withPublicKey:(SecKeyRef)publicKey;
// RSA解密
- (NSData *)decryptMessageRSA:(NSData *)msgData;
- (NSData *)decryptMessageRSA:(NSData *)msgData withPrivateKey:(SecKeyRef)privateKey;
// 获取签名
- (NSString *)getSignWithRSA:(NSString *)string withPriKey:(SecKeyRef)priKey;
// RSA验签
- (BOOL)verifyRSA:(NSString *)string signature:(NSString *)signature withPublivKey:(SecKeyRef)pubcKey;


#pragma mark ---------DH---------
// DH生成秘钥对
- (void)generateKeyPairDH;
// DH获取私钥
- (SecKeyRef)getDHPrivateKey;
// DH根据私钥获取公钥
- (SecKeyRef)getDHPublicKeyWithPrivateKey;
// 获取共享秘钥
- (NSData *) getSharedWithPrivateKey:(SecKeyRef)privateKey publicKey:(SecKeyRef)publicKey;

// 获取公钥base64
- (NSString *)getDHPublicKeyAsBase64;
// 获取私钥base64
- (NSString *)getDHPrivateKeyAsBase64;

//根据base64字符串获取秘钥
- (SecKeyRef)getDHKeyWithBase64Str:(NSString *)base64Str isPrivateKey:(BOOL)isPrivateKey;
// 公钥转换成JAVA可用的base64
- (NSString *)getDHPublicKeyAsBase64ForJavaServer;



// 获取mac值（HMACMD5算法）
- (NSData *)getHMACMD5:(NSData *)data key:(NSData *)keyData;


@end

NS_ASSUME_NONNULL_END
