//  WifiNotificationManager.h
//  Created by Kagen Zhao on 16/9/21.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
OBJC_EXTERN NSString * const KMRWifiDidChangedNotification;

@class KMRWifiInfo;

@interface KMRWifiInfo : NSObject

@property (nonatomic, copy  , readonly, nullable) NSString *BSSID;
@property (nonatomic, copy  , readonly, nullable) NSString *SSID;
@property (nonatomic, strong, readonly, nullable) NSData *SSIDDATA;

- (instancetype)initWithBSSID:(nullable NSString *)BSSID SSID:(nullable NSString *)SSID SSIDDATA:(nullable NSData *)SSIDDATA;

@end

@interface KMRWifiNotificationManager : NSObject

@property (nonatomic, strong, readonly,) KMRWifiInfo *savedWifiInfo;
@property (nonatomic, assign, readonly) BOOL notificationIsRunning;

+ (instancetype)shared;

- (void)addNotification;
- (void)removeNotification;

- (void)addCallBackTarget:(id)target action:(SEL)action;
- (void)removeCallBackTarget:(id)target action:(SEL)action;

@property (nonatomic, readonly, nullable) NSSet *allTarget;

@end


#if __has_include(<ReactiveCocoa/ReactiveCocoa.h>)

@class RACSignal;

@interface KMRWifiNotificationManager (ReactiveCocoa)

@property (nonatomic, strong, readonly) RACSignal *rac_wifiNotificationSignal;

@end

#endif

NS_ASSUME_NONNULL_END
