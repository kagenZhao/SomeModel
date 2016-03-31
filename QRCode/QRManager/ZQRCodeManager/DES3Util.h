//
//  DES3Util.h
//  Oeasy
//
//  Created by zhaoguoqing on 16/3/30.
//
//

#import <Foundation/Foundation.h>
#define gkey            @"oeasy.com/user/addFriends"
@interface DES3Util : NSObject
+ (NSString*)encrypt:(NSString*)plainText;
+ (NSString*)decrypt:(NSString*)encryptText;


@end
