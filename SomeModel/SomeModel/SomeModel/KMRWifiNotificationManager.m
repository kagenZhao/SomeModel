//  WifiNotificationManager.m
//  Created by Kagen Zhao on 16/9/21.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import "KMRWifiNotificationManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <objc/runtime.h>
#import <objc/message.h>

NSString * const KMRWifiDidChangedNotification = @"KMRWifiDidChangedNotification";

static NSString * const kKMRNotificationName = @"com.apple.system.config.network_change";
static CFStringRef const kKMRNotificationkey = CFSTR("com.apple.system.config.network_change");

@interface KMRWifiInfo ()
@property (nonatomic, copy  , readwrite) NSString *BSSID;
@property (nonatomic, copy  , readwrite) NSString *SSID;
@property (nonatomic, strong, readwrite) NSData *SSIDDATA;
@end

@implementation KMRWifiInfo

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
    return [NSString stringWithFormat:@"~~~BSSID: %@, ~~~SSID: %@, ~~~SSIDDATA: %@", _BSSID, _SSID, _SSIDDATA];
}

@end


@interface KMRWifiNotificationManager () {
    void * _observer;
}
@property (nonatomic, strong, readwrite) KMRWifiInfo *savedWifiInfo;
@property (nonatomic, assign, readwrite) BOOL isAddedNotification;
@property (nonatomic, strong, readwrite) NSMutableDictionary <NSValue *, NSMutableArray<NSString *> *> *targetActions;

@end

@implementation KMRWifiNotificationManager

+ (instancetype)shared {
    static KMRWifiNotificationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KMRWifiNotificationManager alloc] init];
        manager.savedWifiInfo = [manager getCurrentWifiInfo];
        manager->_observer = malloc(sizeof(void *));
        manager.targetActions = @{}.mutableCopy;
    });
    return manager;
}

- (void)addNotification {
    if (!_isAddedNotification) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        self->_observer,
                                        onNotifyCallback,
                                        kKMRNotificationkey,
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        _isAddedNotification = YES;
    } else NSLog(@"notification is already added");
}

- (void)removeNotification {
    if (_isAddedNotification) {
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                           self->_observer,
                                           kKMRNotificationkey,
                                           NULL);
        _isAddedNotification = NO;
    } else NSLog(@"there is no notification added");
}

void onNotifyCallback(CFNotificationCenterRef center, void *observer, CFNotificationName name, const void *object, CFDictionaryRef userInfo) {
    NSString* notifyName = (__bridge NSString*)name;
    
    if (![notifyName isEqualToString:kKMRNotificationName]) {
        NSLog(@"other Norification %@", notifyName);
        return;
    }
    
    KMRWifiNotificationManager *manager = [KMRWifiNotificationManager shared];
    KMRWifiInfo *currentWifiInfo = [manager getCurrentWifiInfo];
    BOOL sameBSSID = [manager.savedWifiInfo.BSSID isEqualToString:currentWifiInfo.BSSID];
    BOOL bothNoNil = manager.savedWifiInfo.BSSID == nil && currentWifiInfo.BSSID == nil;
    
    if (sameBSSID || bothNoNil) {
        return;
    }
    
    manager.savedWifiInfo = currentWifiInfo;
    [[NSNotificationCenter defaultCenter] postNotificationName:KMRWifiDidChangedNotification object:currentWifiInfo userInfo:@{KMRWifiDidChangedNotification: currentWifiInfo}];
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

- (KMRWifiInfo *)getCurrentWifiInfo {
    NSDictionary *info = nil;
    NSArray *ifs = CFBridgingRelease(CNCopySupportedInterfaces());
    for (NSString *ifnam in ifs) {
        info = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam));
    }
    KMRWifiInfo *wifiinfo = [[KMRWifiInfo alloc] initWithBSSID:info[@"BSSID"] SSID:info[@"SSID"] SSIDDATA:info[@"SSIDDATA"]];
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
    free(self->_observer);
}

@end

#if __has_include(<ReactiveCocoa/ReactiveCocoa.h>)
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString * const kKMRRacSingalAssociatedKey = @"KMRRacSingalAssociatedKey";

@implementation KMRWifiNotificationManager (ReactiveCocoa)

- (RACSignal *)rac_wifiNotificationSignal {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RACReplaySubject *signal = [[RACReplaySubject alloc] init];
        objc_setAssociatedObject(self, &kKMRRacSingalAssociatedKey, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KMRWifiDidChangedNotification object:nil] subscribeNext:^(NSNotification *noti) {
            [signal sendNext:noti.object];
        }];
    });
    return objc_getAssociatedObject(self, &kKMRRacSingalAssociatedKey);
}
@end
#endif
