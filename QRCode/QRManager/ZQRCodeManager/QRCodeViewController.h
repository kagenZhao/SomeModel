//
//  ViewController.h
//  QRManager
//
//  Created by zhaoguoqing on 16/3/21.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QRCodeViewController;
@protocol QRCodeControllerDelegate <NSObject>
- (void)decodeWithMessage:(NSString *)message QRcontroller:(QRCodeViewController *)controller;
- (void)cancelWithContrller:(QRCodeViewController *)controller;
@end


@interface QRCodeViewController : UIViewController
@property (nonatomic, weak) id<QRCodeControllerDelegate> qrDelegate;
@property (nonatomic, copy) void(^decodeBlock)(NSString *message, QRCodeViewController *controller);
@property (nonatomic, copy) void(^cancelBlock)(QRCodeViewController *controller);
@end

