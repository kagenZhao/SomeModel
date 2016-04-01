//
//  SecurityManager.h
//  QRManager
//
//  Created by zhaoguoqing on 16/3/31.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SecurityManager : NSObject
//DES3
+ (NSString*)DES3encrypt:(NSString*)plainText withKey:(NSString *)key;
+ (NSString*)DES3decrypt:(NSString*)encryptText withKey:(NSString *)key;
// AES
+ (NSString *)AESencrypt:(NSString *)plainText withKey:(NSString *)key;
+ (NSString *)AESdecrypt:(NSString *)encryptText withKey:(NSString *)key;
@end

@interface NSString (md5)

- (NSString *)md5;

@end