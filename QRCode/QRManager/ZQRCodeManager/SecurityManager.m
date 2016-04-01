//
//  SecurityManager.m
//  QRManager
//
//  Created by zhaoguoqing on 16/3/31.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import "SecurityManager.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "GTMBase64.h"

#define gIv             @"01234567"
@implementation SecurityManager
+ (NSString*)DES3encrypt:(NSString*)plainText withKey:(NSString *)key
{
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainTextBufferSize = [data length];
    const void *vplainText = (const void *)[data bytes];
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    const void *vkey = (const void *) [key UTF8String];
    const void *vinitVec = (const void *) [gIv UTF8String];
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    NSString *result = [GTMBase64 stringByEncodingData:myData];
    return result;
}


// 解密方法

+ (NSString*)DES3decrypt:(NSString*)encryptText withKey:(NSString *)key {
    NSData *encryptData = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    size_t plainTextBufferSize = [encryptData length];
    const void *vplainText = [encryptData bytes];
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    const void *vkey = (const void *) [key UTF8String];
    const void *vinitVec = (const void *) [gIv UTF8String];
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
    return result;
}

+ (NSString *)AESencrypt:(NSString *)plainText withKey:(NSString *)key{
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus;
    cryptStatus = CCCrypt(kCCEncrypt,
                          kCCAlgorithmAES128,
                          kCCOptionPKCS7Padding,
                          keyPtr,
                          kCCKeySizeAES256,
                          NULL ,
                          [data bytes],
                          dataLength,
                          buffer,
                          bufferSize,
                          &numBytesEncrypted);
    NSData *myData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    NSString *result = [GTMBase64 stringByEncodingData:myData];
    return result;
    
}
+ (NSString *)AESdecrypt:(NSString *)encryptText withKey:(NSString *)key{
    NSData *encryptData = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [encryptData length];
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus;
    cryptStatus = CCCrypt(kCCDecrypt,
                          kCCAlgorithmAES128,
                          kCCOptionPKCS7Padding,
                          keyPtr,
                          kCCKeySizeAES256,
                          NULL,
                          [encryptData bytes],
                          dataLength,
                          buffer,
                          bufferSize,
                          &numBytesDecrypted);
    NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:buffer length:numBytesDecrypted] encoding:NSUTF8StringEncoding];
    return result;
}

@end


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


