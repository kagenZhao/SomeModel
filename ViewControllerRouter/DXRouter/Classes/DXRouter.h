//
// Created by wangyang on 16/9/19.
//
//
// 用于ViewController间跳转的解耦，通过ViewController的类名进行跳转，在本类的上下文中称之为'viewControllerName'。
// 比如DXHomeViewController，跳转时可使用
// [[DXRouter shared] navigateTo:@"DXHomeViewController" arguments:@{@"content":@"Hello"}]; 或者
// [[DXRouter shared] navigateTo:@"DXHome" arguments:@{@"content":@"Hello"}];
// 去掉'viewControllerName'尾部的ViewController也是支持的。
//
// ViewController想要支持DXRouter的跳转，需要实现DXRouterViewControllerInstantiation协议中的方法instantiateViewController，提供ViewController的实例。

#import <UIKit/UIKit.h>

#import "DXRouterViewControllerInstantiation.h"
#import "DXRouterViewControllerDialog.h"
#import "UIButton+DXRouter.h"

#include "DXRouterHelperMacros.h"

typedef enum : NSUInteger {
    DXRouterDialogPresentTypeWait,//等待上一个窗口关闭，默认
    DXRouterDialogPresentTypeIgnore,//如果已有窗口弹出，忽略新的窗口
    DXRouterDialogPresentTypeForce,//关闭之前的弹窗，弹出新的
} DXRouterDialogPresentType;

@interface DXRouter : NSObject

+ (DXRouter *)shared;
+ (void)startupWithHomeViewController:(NSString *)viewControllerName;

// 实例化ViewController
- (UIViewController *)viewControllerInstanceWithName:(NSString *)name;
- (UIViewController *)viewControllerInstanceWithName:(NSString *)name arguments:(NSDictionary *)arguments;

// 跳转到某个ViewController
- (void)navigateTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments;
// 跳转到某个ViewController，allowRepeat表示如果topViewController和要跳转的一样时，是否重复跳转
- (void)navigateTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments allowRepeat:(BOOL)allowRepeat;

// 回退
- (void)goBack;
- (void)goBackToRoot;
- (BOOL)goBackTo:(NSString *)viewControllerName;
// 往后跳转到第一个出现的viewControllerName对应的UIViewController
- (BOOL)goBackToFirstOf:(NSString *)viewControllerName;
// 往后跳转到最后一个出现的viewControllerName对应的UIViewController
- (BOOL)goBackToLastOf:(NSString *)viewControllerName;

// 以Dialog的形式展现ViewController
- (void)presentAsDialog:(NSString *)viewControllerName arguments:(NSDictionary *)arguments completeBlock:(DXRouterDialogCompleteBlock)completeBlock;
- (void)presentAsDialog:(NSString *)viewControllerName arguments:(NSDictionary *)arguments;
- (void)presentAsDialog:(NSString *)viewControllerName;
- (void)dismissDialog;

// 使用全路由，要求当前页面必须是router中第一个页面，如果forceJumpToFirstPage为YES，则会强行跳回第一个页面后再继续往后跳转。
- (void)navigateWithArguments:(NSDictionary *)arguments fullRouter:(NSArray *)router;
- (void)navigateWithArguments:(NSDictionary *)arguments fullRouter:(NSArray *)router forceJumpToFirstPage:(BOOL)force;

// 使用额外路由，直接从当前页面往后跳转router中的页面。
- (void)navigateWithArguments:(NSDictionary *)arguments additionRouter:(NSArray *)router;
@end
