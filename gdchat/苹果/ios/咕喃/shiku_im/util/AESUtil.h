//
//  AESUtil.h
//  shiku_im
//
//  Created by p on 2019/7/12.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

NS_ASSUME_NONNULL_BEGIN

@interface AESUtil : NSObject

/*
 Aes加密 Data
 */
+(NSData *)encryptAESData:(NSData *)data key:(NSData *)keyData;

/*
 Aes解密  Data
 */
+(NSData *)decryptAESData:(NSData *)data key:(NSData *)keyData;

@end

NS_ASSUME_NONNULL_END
