//
//  BaseContainerViewController.m
//  ViewControllerContainer
//
//  Created by Kagen Zhao on 2016/10/14.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import "BaseContainerViewController.h"

@interface BaseContainerViewController ()

@end

@implementation BaseContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark Overrides
//NS_DEPRECATED_IOS(5_0,6_0)
- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers{
    return NO;
}

//NS_AVAILABLE_IOS(6_0)
- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
    return NO;
}

//NS_AVAILABLE_IOS(6_0)
- (BOOL)shouldAutomaticallyForwardRotationMethods{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController beginAppearanceTransition:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController endAppearanceTransition];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController beginAppearanceTransition:NO animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController endAppearanceTransition];
    }
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        [viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

/*
 NS_AVAILABLE_IOS(6_0)
 向下查看和旋转相关的ChildViewController的shouldAutorotate的值
 只有所有相关的子VC都支持Autorotate，才返回YES
 */
- (BOOL)shouldAutorotate{
    NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
    BOOL shouldAutorotate = YES;
    for (UIViewController *viewController in viewControllers) {
        shouldAutorotate = shouldAutorotate &&  [viewController shouldAutorotate];
    }
    
    return shouldAutorotate;
}

/*
 NS_AVAILABLE_IOS(6_0)
 此方法会在设备旋转且shouldAutorotate返回YES的时候才会被触发
 根据对应的所有支持的取向来决定是否需要旋转
 作为容器，支持的取向还决定于自己的相关子ViewControllers
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    NSUInteger supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
    NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        supportedInterfaceOrientations = supportedInterfaceOrientations & [viewController supportedInterfaceOrientations];
    }
    
    return supportedInterfaceOrientations;
}


/*
 NS_DEPRECATED_IOS(2_0, 6_0) 6.0以下，设备旋转时，此方法会被调用
 用来决定是否要旋转
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    BOOL shouldAutorotate = YES;
    NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
    for (UIViewController *viewController in viewControllers) {
        shouldAutorotate = shouldAutorotate &&  [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    return shouldAutorotate;
}

#pragma mark -
#pragma mark 下面两个方法是在需要的情况下给基类覆盖用的，毕竟不是所有的容器都需要将相关方法传递给所有的childViewControllers
- (NSArray *)childViewControllersWithAppearanceCallbackAutoForward{
    return self.childViewControllers;
}

- (NSArray *)childViewControllersWithRotationCallbackAutoForward{
    return self.childViewControllers;
}


@end
