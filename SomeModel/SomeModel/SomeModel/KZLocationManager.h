//
//  KZLocationManager.h
//  OpenGL
//
//  Created by Kagen Zhao on 2016/9/22.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN

/**
 用于利用定位来实现常驻后台
 
 首先请在修改info文件
 在info.plist 中添加:
 <key>NSLocationAlwaysUsageDescription</key>
 <string>请求定位时的文字描述</string>
 
 如果需要常驻后台 请添加后台刷新
 <key>UIBackgroundModes</key>
 <array>
 <string>fetch</string>
 <string>location</string>
 </array>
 
 使用简单, 只需在 AppDelegate 的 application:didFinishLaunchingWithOptions: 中调用以下方法
 [[KZLocationManager shared] setBackgroundUpdating:YES]
 [[KZLocationManager shared] startUpdatingLocation];
 也可以用于普通定位功能
 */
@interface KZLocationManager : NSObject<CLLocationManagerDelegate>

/**
 可以手动设置 locationManager 的属性, 但如果设置delegate 请用 locationDelegate
 */
@property (nonatomic, strong, readonly) CLLocationManager * locationManager;
/**
 CLLocationManager 的代理
 [KZLocationManager share].locationDelegate = SOME
 */
@property (nonatomic, weak, nullable) id <CLLocationManagerDelegate> locationDelegate;

/**
 单利方法
 */
+ (instancetype)shared;

/**
 开启定位功能
 此方法 会检测 设备是否支持定位, 和用户是否允许定位
 如果没有调用 setBackgroundUpdating 方法 则具有普通的定位功能
 @return 开启是否成功
 */
- (BOOL)startUpdatingLocation;
/**
 关闭定位功能
 此方法 === [[KZLocationManager shared].locationManager stopUpdatingLocation];
 */
- (void)stopUpdatingLocation;

/**
 检测设备是否支持定位功能
 */
- (BOOL)locationServicesEnabled;

/**
 检测用户是否允许定位
 */
- (BOOL)authorized;

/**
 设置是否开启后台常驻功能
 这个方法调用后, 请确认手机在前台时调用了以下方法, 否则app将不具备后台常驻功能
 [[KZLocationManager shared] startUpdatingLocation];
 */
- (void)setBackgroundUpdating:(BOOL)updating;

/**
 返回当前是否开启了常驻后台功能
 */
- (BOOL)isBackgroundUpdating;

@end
NS_ASSUME_NONNULL_END
