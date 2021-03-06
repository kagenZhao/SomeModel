//
//  KZLocationManager.m
//  OpenGL
//
//  Created by Kagen Zhao on 2016/9/22.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import "KZLocationManager.h"
#import <UIKit/UIKit.h>
#import "KZBackgroundTask.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface KZLocationManager ()
@property (nonatomic, strong, readwrite) CLLocationManager * locationManager;
@property (nonatomic, assign, readwrite) BOOL needUpdatingLocationInBackground;
@property (nonatomic, strong, readwrite) id enterBackgroundObserver;
@property (nonatomic, strong, readwrite) id becomeActiveObserver;
@end

@implementation KZLocationManager

+ (instancetype)shared {
    static KZLocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KZLocationManager alloc] init];
        [manager locationManager];
    });
    return manager;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.allowsBackgroundLocationUpdates = YES;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (BOOL)startUpdatingLocation {
    NSAssert(self.locationManager.delegate == self, @"设置CLLocationManager代理 ,请参考 '[KZLocationManager share].locationDelegate = SOME' ");
    if (!self.locationServicesEnabled) {
        NSLog(@"开启定位失败---[CLLocationManager locationServicesEnabled] == false");
        return NO;
    } else if(!self.authorized){
        NSLog(@"开启定位失败---[CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || kCLAuthorizationStatusRestricted");
        return NO;
    } else {
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
        return YES;
    }
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
}

- (BOOL)locationServicesEnabled {
    if (![CLLocationManager locationServicesEnabled]) {
        return NO;
    }
    return YES;
}
- (BOOL)authorized {
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
        return NO;
    }
    return YES;
}

- (void)setBackgroundUpdating:(BOOL)updating {
    self.needUpdatingLocationInBackground = updating;
    if (updating) {
        __weak __typeof(&*self) wSelf = self;
        self.enterBackgroundObserver = !_enterBackgroundObserver ? [[NSNotificationCenter defaultCenter]
                                                                    addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                                    object:nil
                                                                    queue:nil
                                                                    usingBlock:^(NSNotification * _Nonnull note) {
                                                                        __strong __typeof(&*wSelf) sSelf = wSelf;
                                                                        [sSelf applicationEnterBackground];
                                                                    }] : _enterBackgroundObserver;
        self.becomeActiveObserver = !_becomeActiveObserver ? [[NSNotificationCenter defaultCenter]
                                                              addObserverForName:UIApplicationDidBecomeActiveNotification
                                                              object:nil
                                                              queue:nil
                                                              usingBlock:^(NSNotification * _Nonnull note) {
                                                                  [[KZBackgroundTask shared] endCurrentBackgroundTask];
                                                              }] : _becomeActiveObserver;
    } else {
        _enterBackgroundObserver ? [[NSNotificationCenter defaultCenter] removeObserver:_enterBackgroundObserver] : nil;
        _becomeActiveObserver ? [[NSNotificationCenter defaultCenter] removeObserver:_becomeActiveObserver] : nil;
        self.enterBackgroundObserver = nil;
        self.becomeActiveObserver = nil;
    }
}

- (BOOL)isBackgroundUpdating {
    return _needUpdatingLocationInBackground;
}

- (void)applicationEnterBackground {
    [self beginBackgroundUpdatingLocation];
}

- (BOOL)beginBackgroundUpdatingLocation {
    BOOL x = [self startUpdatingLocation];
    [[KZBackgroundTask shared] beginNewBackgroundTask];
    return x;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (self.needUpdatingLocationInBackground) {
        static BOOL once = NO;
        if (once == YES) return;
        __weak __typeof(&*self) self_weak = self;
        [self after:10 block:^{
            __strong __typeof(&*self_weak)self_strong = self_weak;
            [self_strong stopUpdatingLocation];
            once = NO;
        }];
        [self after:120 block:^{
            __strong __typeof(&*self_weak)self_strong = self_weak;
            [self_strong beginBackgroundUpdatingLocation];
        }];
        once = YES;
    }
    if ([self.locationDelegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
        [self.locationDelegate locationManager:manager didUpdateLocations:locations];
    }
}

- (void)after:(NSTimeInterval)interval block:(dispatch_block_t)block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

#pragma mark Method Forwarding

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ( [super respondsToSelector:aSelector] )
        return YES;
    if ([self.locationDelegate respondsToSelector:aSelector])
        return YES;
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if(!signature) {
        if([_locationDelegate respondsToSelector:selector]) {
            return [(NSObject *)_locationDelegate methodSignatureForSelector:selector];
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    if ([_locationDelegate respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:_locationDelegate];
    }
}


@end

