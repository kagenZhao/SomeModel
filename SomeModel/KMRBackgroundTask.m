//
//  KMRBackgroundTask.m
//  OpenGL
//
//  Created by Kagen Zhao on 2016/9/23.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import "KMRBackgroundTask.h"

@interface KMRBackgroundTask()
@property (assign, readwrite, nonatomic) UIBackgroundTaskIdentifier currentBgTask;
@end

@implementation KMRBackgroundTask

+ (instancetype)shared {
    static KMRBackgroundTask *task = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        task = [[KMRBackgroundTask alloc] init];
        task.currentBgTask = UIBackgroundTaskInvalid;
    });
    return task;
}

- (UIBackgroundTaskIdentifier)beginNewBackgroundTask {
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier newBgTaskId = UIBackgroundTaskInvalid;
    newBgTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:newBgTaskId];
    }];
    (_currentBgTask != UIBackgroundTaskInvalid) ? [application endBackgroundTask:_currentBgTask] : nil;
    self.currentBgTask = newBgTaskId;
    return newBgTaskId;
}

- (void)endCurrentBackgroundTask {
    (_currentBgTask != UIBackgroundTaskInvalid) ? [[UIApplication sharedApplication] endBackgroundTask:_currentBgTask] : nil;
}
@end
