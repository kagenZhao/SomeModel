//  WifiNotificationManager.h
//  Created by Kagen Zhao on 16/9/21.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/**
 用于监听的 NotificationName
 */
OBJC_EXTERN NSNotificationName const KZWifiDidChangedNotification;

@class KZWifiInfo;

@interface KZWifiInfo : NSObject

/**
 MAC地址
 */
@property (nonatomic, copy  , readonly, nullable) NSString *BSSID;

/**
 WIFI名称
 */
@property (nonatomic, copy  , readonly, nullable) NSString *SSID;


/**
 唯一初始化方法

 @param BSSID MAC地址
 @param SSID WIFI名称
 */
- (instancetype)initWithBSSID:(nullable NSString *)BSSID SSID:(nullable NSString *)SSID;

@end

@interface KZWifiNotificationManager : NSObject


/**
 保存的当前WIFI信息
 */
@property (nonatomic, strong, readonly) KZWifiInfo *savedWifiInfo;

/**
 当前这个实例是否开启了监听
 */
@property (nonatomic, assign, readonly) BOOL notificationIsRunning;

/**
 当有变化时的 block 回调
 */
@property (nonatomic, copy, readwrite) void(^notifyCallBack)(KZWifiInfo *info);

/**
 单利方法 (可以不用, 但请自行维护生命周期)
 */
+ (instancetype)shared;

/**
 获取最新的WIFI信息
 */
+ (KZWifiInfo *)getCurrentWifiInfo;

/**
 开启监听状态
 */
- (void)startNotification;

/**
 关闭监听状态
 */
- (void)stopNotification;

/**
 添加回调
 */
- (void)addCallBackTarget:(id)target action:(SEL)action;

/**
 删除某一个回调
 */
- (void)removeCallBackTarget:(id)target action:(SEL)action;

/**
 删除某一个target 的所有回调
 */
- (void)removeCallbackTarget:(id)target;

/**
 删除所有回调
 */
- (void)removeAllTarget;

/**
 当前实例的所有 target 集合
 */
@property (nonatomic, readonly, nullable) NSSet *allTarget;

@end


/**
 如果项目引用了 ReactiveCocoa 则可以使用信号量来监听WIFI改变
 */
#if __has_include(<ReactiveCocoa/ReactiveCocoa.h>)

@class RACSignal;

@interface KZWifiNotificationManager (ReactiveCocoa)

/**
 返回当前实例的 信号量
 */
@property (nonatomic, strong, readonly) RACSignal *rac_wifiNotificationSignal;

@end

#endif

NS_ASSUME_NONNULL_END
