//  WifiNotificationManager.m
//  Created by Kagen Zhao on 16/9/21.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import "KZWifiNotificationManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <notify_keys.h>

NSString * const KZWifiDidChangedNotification = @"KZWifiDidChangedNotification";

static NSString * const kKZNotificationName = @kNotifySCNetworkChange;
static CFStringRef const kKZNotificationkey = CFSTR(kNotifySCNetworkChange);

@interface KZWifiInfo ()
@property (nonatomic, copy  , readwrite) NSString *BSSID;
@property (nonatomic, copy  , readwrite) NSString *SSID;
@property (nonatomic, strong, readwrite) NSData *SSIDDATA;
@end

@implementation KZWifiInfo

- (instancetype)initWithBSSID:(NSString *)BSSID SSID:(NSString *)SSID SSIDDATA:(NSData *)SSIDDATA {
    self = [super init];
    if (self) {
        _SSID = SSID.length ? [NSString stringWithString:SSID] : nil;
        _BSSID = BSSID.length ? [NSString stringWithString:BSSID] : nil;
        _SSIDDATA = SSIDDATA.length ? [NSData dataWithData:SSIDDATA] : nil;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"BSSID: %@, SSID: %@, SSIDDATA: %@", _BSSID, _SSID, _SSIDDATA];
}

@end


@interface KZWifiNotificationManager ()
@property (nonatomic, strong, readwrite) KZWifiInfo *savedWifiInfo;
@property (nonatomic, assign, readwrite) BOOL isAddedNotification;
@property (nonatomic, strong, readwrite) NSMutableDictionary <NSValue *, NSMutableArray<NSString *> *> *targetActions;

@end

@implementation KZWifiNotificationManager

+ (instancetype)shared {
    static KZWifiNotificationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KZWifiNotificationManager alloc] init];
        manager.savedWifiInfo = [manager getCurrentWifiInfo];
        manager.targetActions = @{}.mutableCopy;
    });
    return manager;
}

- (void)addNotification {
    if (!_isAddedNotification) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        (__bridge const void *)(self),
                                        onNotifyCallback,
                                        kKZNotificationkey,
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        _isAddedNotification = YES;
    } else NSLog(@"notification is already added");
}

- (void)removeNotification {
    if (_isAddedNotification) {
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                           (__bridge const void *)(self),
                                           kKZNotificationkey,
                                           NULL);
        _isAddedNotification = NO;
    } else NSLog(@"there is no notification added");
}

void onNotifyCallback(CFNotificationCenterRef center, void *observer, CFNotificationName name, const void *object, CFDictionaryRef userInfo) {
    NSString* notifyName = (__bridge NSString*)name;
    
    if (![notifyName isEqualToString:kKZNotificationName]) {
        NSLog(@"other Norification %@", notifyName);
        return;
    }
    
    KZWifiNotificationManager *manager = (__bridge KZWifiNotificationManager *)observer;
    KZWifiInfo *currentWifiInfo = [manager getCurrentWifiInfo];
    BOOL sameBSSID = [manager.savedWifiInfo.BSSID isEqualToString:currentWifiInfo.BSSID];
    BOOL bothNoNil = manager.savedWifiInfo.BSSID == nil && currentWifiInfo.BSSID == nil;
    
    if (sameBSSID || bothNoNil) {
        return;
    }
    
    manager.savedWifiInfo = currentWifiInfo;
    [[NSNotificationCenter defaultCenter] postNotificationName:KZWifiDidChangedNotification object:currentWifiInfo userInfo:@{KZWifiDidChangedNotification: currentWifiInfo}];
    [manager.targetActions enumerateKeysAndObjectsUsingBlock:^(NSValue *  _Nonnull targetPointer, NSMutableArray<NSString *> * _Nonnull actions, BOOL * _Nonnull stop) {
        [actions enumerateObjectsUsingBlock:^(NSString * _Nonnull selStr, NSUInteger idx, BOOL * _Nonnull stop) {
            SEL action = NSSelectorFromString(selStr);
            id target = [targetPointer pointerValue];
            ((void(*)(id, SEL, id))objc_msgSend)(target, action, currentWifiInfo);
        }];
    }];
}

- (void)addCallBackTarget:(id)target action:(SEL)action {
    NSString *selStr = [NSString stringWithUTF8String:sel_getName(action)];
    NSValue *targetPointer = [NSValue valueWithPointer:(__bridge const void * _Nullable)(target)];
    NSMutableArray *actions = self.targetActions[targetPointer];
    if (!actions) {
        actions = @[selStr].mutableCopy;
    } else {
        if ([actions indexOfObject:selStr] != NSNotFound) {
            NSLog(@"This target-action is already added");
            return;
        }
        [actions addObject:selStr];
    }
    
    [self.targetActions setObject:actions forKey:targetPointer];
}

- (void)removeCallBackTarget:(id)target action:(SEL)action {
    NSString *selStr = [NSString stringWithUTF8String:sel_getName(action)];
    NSValue *targetPointer = [NSValue valueWithPointer:(__bridge const void * _Nullable)(target)];
    NSMutableArray *actions = self.targetActions[targetPointer];
    if (actions) {
        if ([actions indexOfObject:selStr] != NSNotFound) {
            [actions removeObject:selStr];
            [self.targetActions setObject:actions forKey:targetPointer];
            return;
        }
    }
    NSLog(@"Without this target-action");
}

- (void)removeCallbackTarget:(id)target {
    NSValue *targetPointer = [NSValue valueWithPointer:(__bridge const void * _Nullable)(target)];
    [self.targetActions removeObjectForKey:targetPointer];
}

- (void)removeAllTarget {
    [self.targetActions removeAllObjects];
}

- (KZWifiInfo *)getCurrentWifiInfo {
    NSDictionary *info = nil;
    NSArray *ifs = CFBridgingRelease(CNCopySupportedInterfaces());
    for (NSString *ifnam in ifs) {
        info = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam));
    }
    KZWifiInfo *wifiinfo = [[KZWifiInfo alloc] initWithBSSID:info[@"BSSID"] SSID:info[@"SSID"] SSIDDATA:info[@"SSIDDATA"]];
    return wifiinfo;
}

- (BOOL)notificationIsRunning {
    return _isAddedNotification;
}

- (NSSet *)allTarget {
    NSMutableSet *set = [NSMutableSet set];
    [self.targetActions.allKeys enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [set addObject:[obj pointerValue]];
    }];
    return set;
}

- (void)dealloc {
    
}

@end

#if __has_include(<ReactiveCocoa/ReactiveCocoa.h>)
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString * const kKZRacSingalAssociatedKey = @"KZRacSingalAssociatedKey";

@implementation KZWifiNotificationManager (ReactiveCocoa)

- (RACSignal *)rac_wifiNotificationSignal {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RACReplaySubject *signal = [[RACReplaySubject alloc] init];
        objc_setAssociatedObject(self, &kKZRacSingalAssociatedKey, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KZWifiDidChangedNotification object:nil] subscribeNext:^(NSNotification *noti) {
            [signal sendNext:noti.object];
        }];
    });
    return objc_getAssociatedObject(self, &kKZRacSingalAssociatedKey);
}
@end
#endif
