//
//  DESUtil.h
//  shiku_im
//
//  Created by 1 on 17/4/27.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface DESUtil : NSObject

/*
 Des加密 String
 */
//+(NSString *)encryptUseDES:(NSString *)plainText key:(NSString *)key;
+(NSString *)encryptDESStr:(NSString *)sText key:(NSString *)key;

/*
 Des解密  String
 */
//+(NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key;
+(NSString *)decryptDESStr:(NSString *)sText key:(NSString *)key;
/*
 nsdata转成16进制字符串
 */
+ (NSString*)stringWithHexBytes2:(NSData *)sende;

/*
 将16进制数据转化成NSData 数组
 */
+(NSData*) parseHexToByteArray:(NSString*) hexString;


/*
 Des加密 Data
 */
+(NSData *)encryptDESData:(NSData *)data key:(NSData *)keyData;

/*
 Des解密  Data
 */
+(NSData *)decryptDESData:(NSData *)data key:(NSData *)keyData;


@end
