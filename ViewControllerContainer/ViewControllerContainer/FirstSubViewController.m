//
//  FirstSubViewController.m
//  ViewControllerContainer
//
//  Created by Kagen Zhao on 2016/10/14.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//


#pragma mark - 参考资料 http://www.cocoachina.com/industry/20140523/8528.html
/// 参考资料 http://www.cocoachina.com/industry/20140523/8528.html



#import "FirstSubViewController.h"

@interface FirstSubViewController ()

@end

@implementation FirstSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    btn.frame = CGRectMake(50, 100, 30, 40);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor = [UIColor blueColor];
}
- (void)btnAction {
    [self beginAppearanceTransition:NO animated:YES];
    [UIView animateWithDuration:3 animations:^{
        self.view.frame = CGRectMake(0, 667, 375, 667);
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [self endAppearanceTransition];
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}



@end
