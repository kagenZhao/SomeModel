//
//  ViewController.m
//  ViewControllerContainer
//
//  Created by Kagen Zhao on 2016/10/14.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//


#pragma mark - 参考资料 http://www.cocoachina.com/industry/20140523/8528.html
/// 参考资料 http://www.cocoachina.com/industry/20140523/8528.html


#import "ViewController.h"
#import "FirstSubViewController.h"
#import "SecViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)Custom:(id)sender {
    
    FirstSubViewController *vc = [[FirstSubViewController alloc] init];
    [self addChildViewController:vc];
    vc.view.frame = CGRectMake(0, 667, 375, 667);
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    [vc beginAppearanceTransition:YES animated:YES];
    [UIView animateWithDuration:3 animations:^{
        vc.view.frame = CGRectMake(0, 0, 375, 667);
    } completion:^(BOOL finished) {
        [vc endAppearanceTransition];
    }];
    
    
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

@end
