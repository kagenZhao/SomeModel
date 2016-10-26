//
//  KZBackgroundTask.h
//  OpenGL
//
//  Created by Kagen Zhao on 2016/9/23.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
/**
 后台刷新功能
 
 如果需要常驻后台 请添加后台刷新
 <key>UIBackgroundModes</key>
 <array>
 <string>fetch</string>
 <string>location</string>
 </array>
 */
@interface KZBackgroundTask : NSObject

+ (instancetype)shared;

- (UIBackgroundTaskIdentifier)beginNewBackgroundTask;

- (void)endCurrentBackgroundTask;
@end
NS_ASSUME_NONNULL_END
