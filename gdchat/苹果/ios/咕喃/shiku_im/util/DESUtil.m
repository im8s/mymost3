//
//  DESUtil.m
//  shiku_im
//
//  Created by 1 on 17/4/27.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "DESUtil.h"
@interface DESUtil()
+(NSString *)encryptDESStr:(NSString *)sText key:(NSString *)key andDesiv:(NSString *)ivDes;
+(NSString *)decryptDESStr:(NSString *)sText key:(NSString *)key andDesiv:(NSString *)ivDes;

@end
@implementation DESUtil

static Byte iv[] = {1,2,3,4,5,6,7,8};

//+(NSString *)encryptUseDES:(NSString *)plainText key:(NSString *)key
//{
//    if (!plainText || [plainText isEqualToString:@""]) {
//        return @"";
//    }
//    
//    NSString *ciphertext = nil;
//    
//    NSData *textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSUInteger dataLength = [textData length];
//    
//    long isAdd = dataLength%8;
//    isAdd > 0 ? (isAdd = dataLength/8 + 1) : (isAdd = dataLength/8);
//    
//    unsigned char buffer[isAdd*8];
//    memset(buffer, 0, isAdd*8*sizeof(char));
//    
//    size_t bufferSize = dataLength + kCCBlockSizeDES;
//    size_t numBytesEncrypted = 0;
//    
//    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
//                                          kCCAlgorithmDES,
//                                          kCCOptionPKCS7Padding,
//                                          [key UTF8String],
//                                          kCCKeySizeDES,
//                                          iv,
//                                          [textData bytes],
//                                          dataLength,
//                                          buffer,
//                                          bufferSize,
//                                          &numBytesEncrypted);
//    
//    if (cryptStatus == kCCSuccess) {
//        
//        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
//        
//        ciphertext = [data base64EncodedStringWithOptions:0];
//        
//    }
//    
//    return ciphertext;
//    
//}
//+(NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key
//{
//    if (!cipherText || [cipherText isEqualToString:@""]) {
//        return @"";
//    }
//    
//    NSString *plaintext = nil;
//    NSData *cipherdata = [[NSData alloc] initWithBase64EncodedString:cipherText options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    NSUInteger dataLength = [cipherdata length];
//    
//    
//    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
//    dataOutAvailable = (dataLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
//    
//    long isAdd = dataLength%8;
//    isAdd > 0 ? (isAdd = dataLength/8 + 1) : (isAdd = dataLength/8);
//    
//    unsigned char buffer[isAdd*8];
//    memset(buffer, 0, isAdd*8*sizeof(char));
//    size_t numBytesDecrypted = 0;
//    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
//                                          kCCAlgorithmDES,
//                                          kCCOptionPKCS7Padding,
//                                          [key UTF8String],
//                                          kCCKeySizeDES,
//                                          iv,
//                                          [cipherdata bytes],
//                                          [cipherdata length],
//                                          buffer,
//                                          dataOutAvailable,
//                                          &numBytesDecrypted);
//    if(cryptStatus == kCCSuccess) {
//        NSData *plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
//        plaintext = [[NSString alloc]initWithData:plaindata encoding:NSUTF8StringEncoding];
//    }
//    return plaintext;
//}

+(NSString *)encryptDESStr:(NSString *)sText key:(NSString *)key{
    return [self encryptDESStr:sText key:key andDesiv:nil];
}
+(NSString *)decryptDESStr:(NSString *)sText key:(NSString *)key{
    return [self decryptDESStr:sText key:key andDesiv:nil];
}


+(NSString *)encryptDESStr:(NSString *)sText key:(NSString *)key andDesiv:(NSString *)ivDes
{

    sText = [NSString stringWithFormat:@"%@",sText];
    if ((sText == nil || sText.length == 0) || (key == nil || key.length == 0)/*
                                                                               || (ivDes == nil || ivDes.length == 0)*/)
    {
        return @"";
    }
    
    NSData* encryptData = [sText dataUsingEncoding:NSUTF8StringEncoding];
    size_t  dataInLength = [encryptData length];
    const void * dataIn = (const void *)[encryptData bytes];
    CCCryptorStatus ccStatus;
    uint8_t *dataOut = NULL;
    size_t dataOutMoved = 0;
    size_t dataOutAvailable = (dataInLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首个字节的值设为值0
    //    const void *iv = (const void *) [ivDes cStringUsingEncoding:NSASCIIStringEncoding];
    //CCCrypt函数 加密/解密
    ccStatus = CCCrypt(kCCEncrypt,  //加密/解密
                       kCCAlgorithm3DES, //加密根据哪个标准（des，3des，aes。。。。）
                       kCCOptionPKCS7Padding,   //选项分组密码算法(des:对每块分组加一次密 3DES：对每块分组加三个不同的密)
                       [key UTF8String],  //密钥 加密和解密的密钥必须一致
                       kCCKeySize3DES,   //DES密钥的大小（kCCKeySizeDES=8）
                       iv,  //可选的初始矢量
                       dataIn,  //数据的存储单元
                       dataInLength,    //数据的大小
                       (void *)dataOut, //用于返回数据
                       dataOutAvailable,    //输出大小
                       &dataOutMoved);  //偏移
    //编码 base64
    NSData *data = [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
    NSString *cipherStr = [data base64EncodedStringWithOptions:0];
    
    free(dataOut);
    return cipherStr;
}
+(NSString *)decryptDESStr:(NSString *)sText key:(NSString *)key andDesiv:(NSString *)ivDes
{
    if ((sText == nil || sText.length == 0) || (key == nil || key.length == 0)/*
                                                                               || (ivDes == nil || ivDes.length == 0)*/)
    {
        return @"";
    }
    const void *dataIn;
    size_t dataInLength;
    
    NSData *decryptData = [[NSData alloc] initWithBase64EncodedString:sText options:NSDataBase64DecodingIgnoreUnknownCharacters];
    dataInLength = [decryptData length];
    dataIn = [decryptData bytes];
    CCCryptorStatus ccStatus;
    uint8_t *dataOut = NULL; //可以理解位type/typedef 的缩写（有效的维护了代码）
    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    size_t dataOutMoved = 0;
    dataOutAvailable = (dataInLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首 1 个字节的值设为值 0
    //    const void *ivDes = (const void *) [iv cStringUsingEncoding:NSASCIIStringEncoding];
    //CCCrypt函数 加密/解密
    ccStatus = CCCrypt(kCCDecrypt,//  加密/解密
                       kCCAlgorithm3DES,//  加密根据哪个标准（des，3des，aes。。。。）
                       kCCOptionPKCS7Padding,//  选项分组密码算法(des:对每块分组加一次密  3DES：对每块分组加三个不同的密)
                       [key UTF8String],  //密钥    加密和解密的密钥必须一致
                       kCCKeySize3DES,//   DES 密钥的大小（kCCKeySizeDES=8）
                       iv, //  可选的初始矢量
                       dataIn, // 数据的存储单元
                       dataInLength,// 数据的大小
                       (void *)dataOut,// 用于返回数据
                       dataOutAvailable,
                       &dataOutMoved);
    NSString * plaintStr  = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved] encoding:NSUTF8StringEncoding];
    free(dataOut);
    return plaintStr;
}

//+(NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key
//{
//    NSString *ciphertext = nil;
//    NSData *textData = [clearText dataUsingEncoding:NSUTF8StringEncoding];
//    NSUInteger dataLength = [textData length];
//    unsigned long len = dataLength;
//    size_t bufferSize = dataLength + kCCBlockSizeAES128;
//    unsigned char buffer[len];
//    size_t numBytesEncrypted = 0;
//    static Byte ffff[] = {1,2,3,4,5,6,7,8};
//    //    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
//    //                                          kCCAlgorithmDES,
//    //                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
//    //                                          [key UTF8String],
//    //                                          kCCBlockSizeDES,
//    //                                          NULL,
//    //                                          [textData bytes],
//    //                                          dataLength,
//    //                                          buffer,
//    //                                          bufferSize,
//    //                                          &numBytesEncrypted);
//    
//    CCCryptorStatus cryptStatus2 = CCCrypt(kCCEncrypt,//模式
//                                           kCCAlgorithmDES,//加密方式
//                                           kCCOptionPKCS7Padding | kCCOptionECBMode,//填充算法
//                                           [@"12345678" UTF8String],//密匙字符串
//                                           kCCKeySizeDES,//加密位数
//                                           ffff,//可选初始化向量
//                                           [textData bytes],//加密数据
//                                           dataLength,//数据长
//                                           buffer,//输出
//                                           bufferSize,//dataOutAvailable
//                                           &numBytesEncrypted);//*dataOutMoved
//    
//    if (cryptStatus2 == kCCSuccess) {
//        NSLog(@"DES加密成功");
//        
//        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
//        NSString * base = [data base64EncodedStringWithOptions:0];
//        ciphertext = [self stringWithHexBytes2:data];
//        
//    }else{
//        NSLog(@"DES加密失败");
//    }
//    NSLog(@"%@",[self decryptUseDES:ciphertext key:key]);
////    free(buffer);
//    return ciphertext;
//}
//
//+(NSString *) decryptUseDES:(NSString *)plainText key:(NSString *)key
//{
//    NSString *cleartext = nil;
//    NSData *textData = [self parseHexToByteArray:plainText];
//    NSUInteger dataLength = [textData length];
//    unsigned long len = dataLength;
//    size_t bufferSize = dataLength + kCCBlockSizeAES128;
//    unsigned char buffer[len];
//    memset(buffer, 0, sizeof(char));
//    size_t numBytesEncrypted = 0;
//    
//    
//    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
//                                          kCCAlgorithmDES,
//                                          kCCOptionPKCS7Padding,
//                                          [key UTF8String],
//                                          kCCKeySizeDES,
//                                          NULL,
//                                          [textData bytes],
//                                          dataLength,
//                                          buffer,
//                                          bufferSize,
//                                          &numBytesEncrypted);
//    if (cryptStatus == kCCSuccess) {
//        NSLog(@"DES解密成功");
//        
//        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
//        cleartext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    }else{
//        NSLog(@"DES解密失败");
//    }
//    
////    free(buffer);
//    return cleartext;
//}


/*
 nsdata转成16进制字符串
 */
+ (NSString*)stringWithHexBytes2:(NSData *)sender {
    static const char hexdigits[] = "0123456789ABCDEF";
    const size_t numBytes = [sender length];
    const unsigned char* bytes = [sender bytes];
    char *strbuf = (char *)malloc(numBytes * 2 + 1);
    char *hex = strbuf;
    NSString *hexBytes = nil;
    
    for (int i = 0; i<numBytes; ++i) {
        const unsigned char c = *bytes++;
        *hex++ = hexdigits[(c >> 4) & 0xF];
        *hex++ = hexdigits[(c ) & 0xF];
    }
    
    *hex = 0;
    hexBytes = [NSString stringWithUTF8String:strbuf];
    
//    free(strbuf);
    return hexBytes;
}


/*
 将16进制数据转化成NSData 数组
 */
+(NSData*) parseHexToByteArray:(NSString*) hexString
{
    int j=0;
    Byte bytes[hexString.length];
    for(int i=0;i<[hexString length];i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:hexString.length/2];
    return newData;
}

/*
 Des加密 Data
 */
+(NSData *)encryptDESData:(NSData *)data key:(NSData *)keyData {
    
    NSString *key = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
    
    size_t  dataInLength = [data length];
    const void * dataIn = (const void *)[data bytes];
    CCCryptorStatus ccStatus;
    uint8_t *dataOut = NULL;
    size_t dataOutMoved = 0;
    size_t dataOutAvailable = (dataInLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首个字节的值设为值0
    //    const void *iv = (const void *) [ivDes cStringUsingEncoding:NSASCIIStringEncoding];
    //CCCrypt函数 加密/解密
    ccStatus = CCCrypt(kCCEncrypt,  //加密/解密
                       kCCAlgorithm3DES, //加密根据哪个标准（des，3des，aes。。。。）
                       kCCOptionPKCS7Padding,   //选项分组密码算法(des:对每块分组加一次密 3DES：对每块分组加三个不同的密)
                       [key UTF8String],  //密钥 加密和解密的密钥必须一致
                       kCCKeySize3DES,   //DES密钥的大小（kCCKeySizeDES=8）
                       iv,  //可选的初始矢量
                       dataIn,  //数据的存储单元
                       dataInLength,    //数据的大小
                       (void *)dataOut, //用于返回数据
                       dataOutAvailable,    //输出大小
                       &dataOutMoved);  //偏移
    //编码 base64
    NSData *data1 = [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
    free(dataOut);
    return data1;
}

/*
 Des解密  Data
 */
+(NSData *)decryptDESData:(NSData *)data key:(NSData *)keyData {
    
    NSString *key = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
    
    const void *dataIn;
    size_t dataInLength;
    dataInLength = [data length];
    dataIn = [data bytes];
    CCCryptorStatus ccStatus;
    uint8_t *dataOut = NULL; //可以理解位type/typedef 的缩写（有效的维护了代码）
    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    size_t dataOutMoved = 0;
    
    dataOutAvailable = (dataInLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首 1 个字节的值设为值 0
    //    const void *ivDes = (const void *) [iv cStringUsingEncoding:NSASCIIStringEncoding];
    //CCCrypt函数 加密/解密
    ccStatus = CCCrypt(kCCDecrypt,//  加密/解密
                       kCCAlgorithm3DES,//  加密根据哪个标准（des，3des，aes。。。。）
                       kCCOptionPKCS7Padding,//  选项分组密码算法(des:对每块分组加一次密  3DES：对每块分组加三个不同的密)
                       [key UTF8String],  //密钥    加密和解密的密钥必须一致
                       kCCKeySize3DES,//   DES 密钥的大小（kCCKeySizeDES=8）
                       iv, //  可选的初始矢量
                       dataIn, // 数据的存储单元
                       dataInLength,// 数据的大小
                       (void *)dataOut,// 用于返回数据
                       dataOutAvailable,
                       &dataOutMoved);

//    NSString * plaintStr  = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved] encoding:NSUTF8StringEncoding];
    free(dataOut);
    return [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
}



@end
