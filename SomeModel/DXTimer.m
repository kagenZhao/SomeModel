//
//  DXTimer.m
//  Pods
//
//  Created by Javen Wang on 9/21/16.
//
//

#import "DXTimer.h"

@interface DXTimer ()
@property (nonatomic) dispatch_source_t source;
@property (nonatomic, copy) dispatch_block_t handler;
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) NSTimeInterval interval;
@property (nonatomic, readonly) void *keyContext;
@end

@implementation DXTimer

+ (instancetype)timerWithInterval:(NSTimeInterval)seconds handler:(dispatch_block_t)handler
{
    return [self timerWithInterval:seconds queue:nil handler:handler];
}

+ (instancetype)timerWithInterval:(NSTimeInterval)seconds queue:(dispatch_queue_t)queue handler:(dispatch_block_t)handler
{
    return [[DXTimer alloc] initWithInterval:seconds queue:queue handler:handler];
}

- (instancetype)initWithInterval:(NSTimeInterval)seconds queue:(dispatch_queue_t)queue handler:(dispatch_block_t)handler
{
    self = [super init];
    if (self) {
        _interval = seconds;
        _handler = [handler copy];
        _keyContext = &_keyContext;
        _queue = queue;
        if (!_queue) {
            _queue = dispatch_queue_create(NSStringFromClass([self class]).UTF8String, DISPATCH_QUEUE_SERIAL);
        }
        dispatch_queue_set_specific(_queue, _keyContext, _keyContext, NULL);
    }
    return self;
}

- (void)dealloc
{
    if (dispatch_get_specific(self.keyContext)) {
        [self doStop];
    } else {
        dispatch_sync(self.queue, ^{
            [self doStop];
        });
    }
    self.handler = nil;
    self.queue = nil;
}

- (void)start
{
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t blk = ^{
        __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf doStart];
        }
    };
    
    if (dispatch_get_specific(self.keyContext)) {
        blk();
    } else {
        dispatch_async(self.queue, blk);
    }
}

- (void)doStart
{
    if (!self.source) {
        self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
        const uint64_t nsec = self.interval * NSEC_PER_SEC;
        dispatch_source_set_event_handler(self.source, self.handler);
        dispatch_source_set_timer(self.source, dispatch_time(DISPATCH_TIME_NOW, nsec), nsec, 0);
        dispatch_resume(self.source);
    }
}

- (void)stop
{
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t blk = ^{
        __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf doStop];
        }
    };
    
    if (dispatch_get_specific(self.keyContext)) {
        blk();
    } else {
        dispatch_async(self.queue, blk);
    }
}

- (void)doStop
{
    if (self.source) {
        dispatch_source_cancel(self.source);
        self.source = nil;
    }
}

@end
