//
//  NSString+Utils.m
//  DupiPlanet
//
//  Created by zhaoxy on 14-9-8.
//  Copyright (c) 2014年 team108. All rights reserved.
//

#import "NSString+Utils.h"
#import <CommonCrypto/CommonDigest.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "NSData+Utils.h"


@implementation NSString (md5)

- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

@end

@implementation NSString (Utils)
// 加密
+ (NSString *)AES256Encrypt:(NSString*)strSource withKey:(NSString*)key {
    NSData *dataSource = [strSource dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipher = [dataSource AES256EncryptWithKey:key];
    
    if (cipher && cipher.length > 0) {
        
        Byte *datas = (Byte*)[cipher bytes];
        NSMutableString *output = [NSMutableString stringWithCapacity:cipher.length * 2];
        for(int i = 0; i < cipher.length; i++){
            [output appendFormat:@"%02x", datas[i]];
        }
        return output;
    }
    NSString *s = [cipher base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
    return s;
}


+ (NSString*)AES256Decrypt:(NSString *)dataSource withKey:(NSString*)key {
    NSData *d = [[NSData alloc] initWithBase64EncodedString:dataSource options:NSDataBase64DecodingIgnoreUnknownCharacters];
    //对数据进行解密
    NSData *result = [d AES256DecryptWithKey:key];
    NSString *s = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    return s;
}



@end
