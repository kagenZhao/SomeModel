//
//  DXNotExistViewController.m
//  Pods
//
//  Created by wangyang on 2016/9/29.
//
//

#import "DXNotExistViewController.h"

@interface DXNotExistViewController ()

@end

@implementation DXNotExistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc]initWithFrame:self.view.bounds];
    label.text = @"404";
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

@end
