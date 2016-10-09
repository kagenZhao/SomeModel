//
//  KZBackgroundTask.h
//  OpenGL
//
//  Created by Kagen Zhao on 2016/9/23.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 后台刷新功能
 */
@interface KZBackgroundTask : NSObject

+ (instancetype)shared;

- (UIBackgroundTaskIdentifier)beginNewBackgroundTask;

- (void)endCurrentBackgroundTask;
@end
