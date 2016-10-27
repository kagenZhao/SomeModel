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

/**
 开始一个新的后台任务

 @return 任务ID
 */
- (UIBackgroundTaskIdentifier)beginNewBackgroundTask;

/**
 结束当前正在进行的任务
 */
- (void)endCurrentBackgroundTask;
@end
NS_ASSUME_NONNULL_END
