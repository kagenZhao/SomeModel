//
//  DXAViewController.m
//  DXRouter
//
//  Created by wangyang on 2016/9/30.
//  Copyright © 2016年 tomcat2088. All rights reserved.
//

#import "DXAViewController.h"
#import "DXRouter/DXRouter.h"

@interface DXAViewController () <DXRouterViewControllerInstantiation>

@end

@implementation DXAViewController

DXRouterInitPageFromStoryboard(@"Main", @"DXAViewController")

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)showDialogClicked:(id)sender {
    //[[DXRouter shared] presentAsDialog:@"DXDialog"];
}

@end
