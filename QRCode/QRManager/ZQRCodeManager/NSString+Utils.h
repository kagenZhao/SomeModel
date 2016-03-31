//
//  NSString+Utils.h
//  DupiPlanet
//
//  Created by zhaoxy on 14-9-8.
//  Copyright (c) 2014年 team108. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (md5)

- (NSString *)md5;

@end

@interface NSString (Utils)

// 加密
+ (NSString*)AES256Encrypt:(NSString*)strSource withKey:(NSString*)key;

+ (NSString*)AES256Decrypt:(NSString*)dataSource withKey:(NSString*)key;



@end