//
//  SecurityManager.h
//  QRManager
//
//  Created by zhaoguoqing on 16/3/31.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import <Foundation/Foundation.h>

#define aeskey            @"kagenMonsterForGit"
#define des3key            @"kagenMonsterForGit"


@interface SecurityManager : NSObject
//DES3
+ (NSString*)DES3encrypt:(NSString*)plainText;
+ (NSString*)DES3decrypt:(NSString*)encryptText;
// AES
+ (NSString *)AESencrypt:(NSString *)plainText;
+ (NSString *)AESdecrypt:(NSString *)encryptText;
@end
