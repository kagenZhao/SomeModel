//
//  DXRedViewController.m
//  DXRouter
//
//  Created by wangyang on 2016/9/30.
//  Copyright © 2016年 tomcat2088. All rights reserved.
//

#import "DXRedViewController.h"
#import "DXRouter/DXRouter.h"

@interface DXRedViewController () <DXRouterViewControllerInstantiation>

@end

@implementation DXRedViewController

DXRouterInitPage()

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
}
@end
