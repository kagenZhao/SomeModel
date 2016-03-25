//
//  QRManager.h
//  QRManager
//
//  Created by zhaoguoqing on 16/3/25.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QRManager : NSObject
+ (UIImage *)createQRCodeImageWithMessage:(NSString *)message;
@end
