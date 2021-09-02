//
//  MD5Util.m
//  shiku_im
//
//  Created by p on 2019/7/15.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "MD5Util.h"

@implementation MD5Util

+(NSString*)getMD5StringWithString:(NSString*)s{
    if(s==nil)
        return nil;
    //    if(s.length == 32){
    //        return s;
    //    }
    const char *buf = [s cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char md[MD5_DIGEST_LENGTH];
    unsigned long n = strlen(buf);
    MD5(buf, n, md);
    
    printf("%s md5: ", buf);
    char t[50]="",p[50]="";
    int i;
    for(i = 0; i< MD5_DIGEST_LENGTH; i++){
        sprintf(t, "%02x", md[i]);
        strcat(p, t);
        printf("%02x", md[i]);
    }
    s = [NSString stringWithCString:p encoding:NSUTF8StringEncoding];
    printf("/n");
    //    NSLog(@"%@",s);
    return s;
}

+(NSData*)getMD5DataWithData:(NSData*)data{
    if(data==nil)
        return nil;
    //    if(s.length == 32){
    //        return s;
    //    }
    const char *buf = [data bytes];
    unsigned char md[MD5_DIGEST_LENGTH];
    unsigned long n = strlen(buf);
    MD5(buf, n, md);
    
    printf("%s md5: ", buf);
    char t[50]="",p[50]="";
    int i;
    for(i = 0; i< MD5_DIGEST_LENGTH; i++){
        sprintf(t, "%02x", md[i]);
        strcat(p, t);
        printf("%02x", md[i]);
    }
    Byte * byteData = malloc(sizeof(p)*16);
    NSData *content=[NSData dataWithBytes:byteData length:16];
    
    printf("/n");
    //    NSLog(@"%@",s);
    return content;
}

+(NSData*)getMD5DataWithString:(NSString*)str{
    if(str==nil)
        return nil;
    //    if(s.length == 32){
    //        return s;
    //    }
    const char *buf = [str cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char md[MD5_DIGEST_LENGTH];
    unsigned long n = strlen(buf);
    MD5(buf, n, md);
    
    printf("%s md5: ", buf);
    char t[50]="",p[50]="";
    int i;
    for(i = 0; i< MD5_DIGEST_LENGTH; i++){
        sprintf(t, "%02x", md[i]);
        strcat(p, t);
        printf("%02x", md[i]);
    }
    Byte * byteData = malloc(sizeof(p));
    NSData *content=[NSData dataWithBytes:md length:sizeof(md)];
    
    printf("/n");
    //    NSLog(@"%@",s);
    return content;
}

+(NSString*)getMD5StringWithData:(NSData*)data {
    
    if(data==nil)
        return nil;
    //    if(s.length == 32){
    //        return s;
    //    }
    const char *buf = [data bytes];
    unsigned char md[MD5_DIGEST_LENGTH];
    unsigned long n = [data length];
    MD5(buf, n, md);
    
    printf("%s md5: ", buf);
    char t[50]="",p[50]="";
    int i;
    for(i = 0; i< MD5_DIGEST_LENGTH; i++){
        sprintf(t, "%02x", md[i]);
        strcat(p, t);
        printf("%02x", md[i]);
    }
    NSString *s = [NSString stringWithCString:p encoding:NSUTF8StringEncoding];
    
    printf("/n");
    //    NSLog(@"%@",s);
    return s;
}


@end
