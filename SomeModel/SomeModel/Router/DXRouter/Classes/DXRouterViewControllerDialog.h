//
//  DXRouterViewControllerDialog.h
//  Pods
//
//  Created by wangyang on 2016/9/28.
//
//

#import <UIKit/UIkit.h>

typedef void(^DXRouterDialogCompleteBlock)(id result);

@protocol DXRouterViewControllerDialog <NSObject>

@required
@property (copy, nonatomic) DXRouterDialogCompleteBlock completedBlock;
- (CGSize)dialogSize;

@end
