//
//  DXTimer.h
//  Pods
//
//  Created by Javen Wang on 9/21/16.
//
//

#import <Foundation/Foundation.h>

@interface DXTimer : NSObject

+ (instancetype)timerWithInterval:(NSTimeInterval)seconds handler:(dispatch_block_t)handler;
+ (instancetype)timerWithInterval:(NSTimeInterval)seconds queue:(dispatch_queue_t)queue handler:(dispatch_block_t)handler;

- (void)start;
- (void)stop;

@end
