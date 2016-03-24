//
//  QRView.h
//  QRManager
//
//  Created by zhaoguoqing on 16/3/21.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol QRViewDelegate <NSObject>
- (void)decodeMessage:(NSString *)message;
- (void)cancel;
@end

@interface QRView : UIView
@property (nonatomic, weak) id<QRViewDelegate>delegate;
@property (nonatomic, weak) UIViewController *controller;
- (void)stopRunning;
- (void)startRunning;
@end
