//
//  ViewController.m
//  SomeModel
//
//  Created by Kagen Zhao on 2016/10/9.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import "ViewController.h"
#import "KZWifiNotificationManager.h"
@interface ViewController ()
@property KZWifiNotificationManager *manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [[KZWifiNotificationManager alloc] init];
    [self.manager setNotifyCallBack:^(KZWifiInfo * info) {
        NSLog(@"info : %@", info);
        
        NSString *string = [[NSString alloc] initWithData:info.SSIDDATA encoding:NSUTF8StringEncoding];
        NSLog(@"dataString : %@", string);
    }];
    [self.manager startNotification];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
