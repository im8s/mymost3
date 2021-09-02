//
//  AESUtil.m
//  shiku_im
//
//  Created by p on 2019/7/12.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "AESUtil.h"

@implementation AESUtil

static Byte iv[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};

/*
 Aes加密 Data
 */
+(NSData *)encryptAESData:(NSData *)data key:(NSData *)keyData {
    
//    NSString *key = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
    
    size_t  dataInLength = [data length];
    const void * dataIn = (const void *)[data bytes];
    CCCryptorStatus ccStatus;
    uint8_t *dataOut = NULL;
    size_t dataOutMoved = 0;
    size_t dataOutAvailable = (dataInLength + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首个字节的值设为值0
    //    const void *iv = (const void *) [ivDes cStringUsingEncoding:NSASCIIStringEncoding];
    //CCCrypt函数 加密/解密
    ccStatus = CCCrypt(kCCEncrypt,  //加密/解密
                       kCCAlgorithmAES128, //加密根据哪个标准（des，3des，aes。。。。）
                       kCCOptionPKCS7Padding,   //选项分组密码算法(des:对每块分组加一次密 3DES：对每块分组加三个不同的密)
                       [keyData bytes],  //密钥 加密和解密的密钥必须一致
                       kCCKeySizeAES128,   //DES密钥的大小（kCCKeySizeDES=8）
                       iv,  //可选的初始矢量
                       dataIn,  //数据的存储单元
                       dataInLength,    //数据的大小
                       (void *)dataOut, //用于返回数据
                       dataOutAvailable,    //输出大小
                       &dataOutMoved);  //偏移

    NSData *data1 = [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
    free(dataOut);
    return data1;
}

/*
 Aes解密  Data
 */
+(NSData *)decryptAESData:(NSData *)data key:(NSData *)keyData {
    
    const void *dataIn;
    size_t dataInLength;
    dataInLength = [data length];
    dataIn = [data bytes];
    CCCryptorStatus ccStatus;
    uint8_t *dataOut = NULL; //可以理解位type/typedef 的缩写（有效的维护了代码）
    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    size_t dataOutMoved = 0;
    
    dataOutAvailable = (dataInLength + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首 1 个字节的值设为值 0
    //    const void *ivDes = (const void *) [iv cStringUsingEncoding:NSASCIIStringEncoding];
    //CCCrypt函数 加密/解密
    ccStatus = CCCrypt(kCCDecrypt,//  加密/解密
                       kCCAlgorithmAES128,//  加密根据哪个标准（des，3des，aes。。。。）
                       kCCOptionPKCS7Padding,//  选项分组密码算法(des:对每块分组加一次密  3DES：对每块分组加三个不同的密)
                       [keyData bytes],  //密钥    加密和解密的密钥必须一致
                       kCCKeySizeAES128,//   DES 密钥的大小（kCCKeySizeDES=8）
                       iv, //  可选的初始矢量
                       dataIn, // 数据的存储单元
                       dataInLength,// 数据的大小
                       (void *)dataOut,// 用于返回数据
                       dataOutAvailable,
                       &dataOutMoved);
    
    //    NSString * plaintStr  = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved] encoding:NSUTF8StringEncoding];
    NSData *data1 = [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
    free(dataOut);
    return data1;
}

@end
