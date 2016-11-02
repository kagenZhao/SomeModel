//
//  UNOLoadingAnimationView.m
//  UNApartmentGuest
//
//  Created by zhefu wang on 09/10/2016.
//  Copyright © 2016 Unovo. All rights reserved.
//

#import "UNOLoadingAnimationView.h"

#define POSITION_Y_BEGIN 60
#define POSITION_Y_END 40

@interface UNOLoadingAnimationView()

@property (nonatomic, strong) CADisplayLink *timer;
@property (nonatomic) CFTimeInterval lastStep;
@property (nonatomic) CFTimeInterval timeOffset;
@property (nonatomic) CFTimeInterval duration;
@property (nonatomic, strong) CALayer *layerIcon;

@property (nonatomic, strong) NSArray *imageList;

@end


@implementation UNOLoadingAnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        [self initUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 4;
    self.clipsToBounds = YES;
}

- (NSArray *)imageList {
    if (!_imageList) {
        _imageList = @[((__bridge id _Nullable)[UIImage imageNamed:@"PodUnovoUIComponentsResources.bundle/Loading_1"].CGImage),
                       ((__bridge id _Nullable)[UIImage imageNamed:@"PodUnovoUIComponentsResources.bundle/Loading_2"].CGImage),
                       ((__bridge id _Nullable)[UIImage imageNamed:@"PodUnovoUIComponentsResources.bundle/Loading_3"].CGImage),
                       ((__bridge id _Nullable)[UIImage imageNamed:@"PodUnovoUIComponentsResources.bundle/Loading_4"].CGImage)];
    }
    return _imageList;
}

- (CADisplayLink *)timer {
    if (!_timer) {
        _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(step:)];
    }
    return _timer;
}

- (CALayer *)layerIcon {
    if (!_layerIcon) {
        _layerIcon = [CALayer new];
        _layerIcon.frame = CGRectMake(30.5, 40, 45, 45);
        _layerIcon.contents = [self.imageList firstObject];
        _layerIcon.contentsGravity = kCAGravityResizeAspectFill;
    }
    return _layerIcon;
}

- (void)resetTime {
    self.timeOffset = 0;
    self.lastStep = CACurrentMediaTime();
}

- (void)startAnimation {
    if (_layerIcon) {
        [_layerIcon removeFromSuperlayer];
        _layerIcon = nil;
    }
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    [self resetTime];
    
    [self.layer addSublayer:self.layerIcon];
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stop {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (CGFloat)interpolateFrom:(CGFloat)from to:(CGFloat)to time: (CFTimeInterval)time {
    return (to - from) * time + from;
}

- (void)step:(CADisplayLink *)timer {
    CFTimeInterval thisStep = CACurrentMediaTime();
    CFTimeInterval stepDuration = thisStep - self.lastStep;
    self.lastStep = thisStep;
    self.timeOffset += stepDuration;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    

    CGFloat value = POSITION_Y_BEGIN;
    if (self.timeOffset >= 0 && self.timeOffset <= 0.2) {
        CFTimeInterval time = self.timeOffset / 0.2;
        //you can use custom timing function here to modify time like this: time = CurveEaseIn(time). CurveEaseIn should be implemented by yourself;
        value = [self interpolateFrom: POSITION_Y_BEGIN to: POSITION_Y_END time: time];
    } else if (self.timeOffset > 0.2 && self.timeOffset <= 0.5) {
        CFTimeInterval time = (self.timeOffset - 0.2) / 0.3;
        //you can use custom timing function here to modify time like this: time = CurveEaseIn(time). CurveEaseIn should be implemented by yourself;
        value = [self interpolateFrom: POSITION_Y_END to: POSITION_Y_BEGIN time: time];
    }
    self.layerIcon.position = CGPointMake(self.layerIcon.position.x, value);
    
    if (self.timeOffset > 0.4) {
        static NSInteger index = 0;
        index = (index + 1) % 4;
        self.layerIcon.contents = self.imageList[index];
        [self resetTime];
    }
    [CATransaction commit];
}


@end
