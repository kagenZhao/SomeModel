//
//  DXDialogViewController.m
//  DXRouter
//
//  Created by wangyang on 2016/9/30.
//  Copyright © 2016年 tomcat2088. All rights reserved.
//

#import "DXDialogViewController.h"
#import "DXRouter/DXRouter.h"

@interface DXDialogViewController () <DXRouterViewControllerInstantiation,DXRouterViewControllerDialog>

@end

@implementation DXDialogViewController

DXRouterInitPageFromStoryboard(@"Main", @"DXDialogViewController")
DXRouterInitDialog(30, 300)

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)closeButtonClicked:(id)sender {
    completedBlock(@"closed");
}

@end
