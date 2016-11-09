//
//  DXTabViewController.m
//  DXRouter
//
//  Created by wangyang on 2016/9/30.
//  Copyright © 2016年 tomcat2088. All rights reserved.
//

#import "DXTabViewController.h"
#import "DXRouter/DXRouter.h"

@interface DXTabViewController () <DXRouterViewControllerInstantiation>

@end

@implementation DXTabViewController

DXRouterInitPage()

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:[[DXRouter shared] viewControllerInstanceWithName:@"DXA"]];
    [self addChildViewController:[[DXRouter shared] viewControllerInstanceWithName:@"DXHome"]];
    [self addChildViewController:[[DXRouter shared] viewControllerInstanceWithName:@"DXRed"]];
}

@end
