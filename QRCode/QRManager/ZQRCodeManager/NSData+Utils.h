//
//  NSData+Utils.h
//  Oeasy
//
//  Created by zhaoguoqing on 16/3/30.
//
//

#import <Foundation/Foundation.h>

@interface NSData (Utils)
- (NSData*)AES256EncryptWithKey:(NSString*)key;
- (NSData*)AES256DecryptWithKey:(NSString*)key;
@end
