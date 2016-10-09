//
//  KMRLocationManager.h
//  OpenGL
//
//  Created by Kagen Zhao on 2016/9/22.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


/**
 用于利用定位来实现常驻后台
 使用及其简单, 只需在 AppDelegate中调用以下方法
 [[[KMRLocationManager shared] setBackgroundUpdating:YES] startUpdatingLocation];
 也可以用于普通定位功能
 */
@interface KMRLocationManager : NSObject<CLLocationManagerDelegate>
@property (nonatomic, strong, readonly) CLLocationManager * locationManager;
/**
 CLLocationManager 的代理
 [KMRLocationManager share].locationDelegate = SOME
 */
@property (nonatomic, weak) id <CLLocationManagerDelegate> locationDelegate;

+ (instancetype)shared;

- (BOOL)startUpdatingLocation;

- (BOOL)locationServicesEnabled;
- (BOOL)authorized;

/**
 设置app后台常驻
 在info.plist 中添加: 
 <key>NSLocationAlwaysUsageDescription</key>
	<string>文字描述</string>
 <key>UIBackgroundModes</key>
 <array>
    <string>fetch</string>
    <string>location</string>
 </array>
 @param updating 是否设置后台常驻
 */
- (instancetype)setBackgroundUpdating:(BOOL)updating;
- (BOOL)isBackgroundUpdating;

@end
