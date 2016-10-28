//
//  ViewConrtroller.m
//  QRManager
//
//  Created by zhaoguoqing on 16/3/21.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import "ViewConrtroller.h"
#import "QRManager.h"

@interface ViewConrtroller ()
@property (weak, nonatomic) IBOutlet UIImageView *qrimage;

@end

@implementation ViewConrtroller
- (IBAction)create:(id)sender {
  
  // 用CIFilter
  UIImage *img = [QRManager createQRCodeImageWithMessage:@"1" size:_qrimage.frame.size.width color:[UIColor redColor] topImg:[UIImage imageNamed:@"2"]];
  // 用libqrencode
  _qrimage.image = img;
    
    NSString *key = [@"kagenMonsterForGit" md5];
    
    NSString *a = [SecurityManager AESencrypt:@"wuxianliang" withKey:key];
    NSString *b = [SecurityManager AESdecrypt:a withKey:key];
    
    NSLog(@"-----------------AES-----------------");
    NSLog(@"%@", a);
    NSLog(@"%@", b);
    
    
    
    
    NSString *c = [SecurityManager DES3encrypt:@"wuxianliang" withKey:key];
    NSString *d = [SecurityManager DES3decrypt:c withKey:key];
    
    NSLog(@"-----------------DES3-----------------");
    NSLog(@"%@", c);
    NSLog(@"%@", d);

}

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
