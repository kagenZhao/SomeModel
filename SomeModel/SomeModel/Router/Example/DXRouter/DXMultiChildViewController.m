//
//  DXMultiChildViewController.m
//  DXRouter
//
//  Created by wangyang on 2016/9/29.
//  Copyright © 2016年 tomcat2088. All rights reserved.
//

#import "DXMultiChildViewController.h"
#import "DXRouter/DXRouter.h"
#import "DXContentViewController.h"
#import "DXRedViewController.h"

@interface DXMultiChildViewController () <DXRouterViewControllerInstantiation>

@end

@implementation DXMultiChildViewController

DXRouterInitPage()

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:[[DXRouter shared] viewControllerInstanceWithName:@"DX"]];
    [self addChildViewController:[[DXRouter shared] viewControllerInstanceWithName:@"DXRed"]];
    [self addChildViewController:[[DXRouter shared] viewControllerInstanceWithName:@"DXContent"]];
    
    // Do any additional setup after loading the view.
}

@end
