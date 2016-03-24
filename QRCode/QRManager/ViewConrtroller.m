//
//  ViewConrtroller.m
//  QRManager
//
//  Created by zhaoguoqing on 16/3/21.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import "ViewConrtroller.h"
#import "QRCodeViewController.h"
@implementation ViewConrtroller

- (IBAction)decode:(id)sender {
    QRCodeViewController *vc = [[QRCodeViewController alloc] init];
    vc.decodeBlock = ^(NSString *message, QRCodeViewController *controller){
        NSLog(@"message: %@", message);
        [controller dismissViewControllerAnimated:YES completion:nil];
    };
    vc.cancelBlock = ^(QRCodeViewController *controller){
        [controller dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:vc animated:YES completion:nil];
}

@end
