//
//  UNHUD.m
//  UNApartmentGuest
//
//  Created by zhefu wang on 9/14/16.
//  Copyright © 2016 KevinZhang. All rights reserved.
//

#import "UNOHUD.h"
#import "UNOLoadingAnimationView.h"

#define TAG_LOADING_VIEW 7626
#define TAG_HUD_VIEW 7326

#define AUTO_DISMISS_SEC 2
#define GAP_BETWEEN_ICON_AND_TEXT 6
#define INSET_TOP 5
#define INSET_INNER_LEFT_RIGHT 8
#define INSET_OUTTER_LEFT_RIGHT 20

#define UIColorFromHexWithAlpha(hexValue,a) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:a]
#define UIColorFromHex(hexValue) UIColorFromHexWithAlpha(hexValue,1.0)

#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#define CLASS_PROPERTY_SETTER_GETTER(_type, _lowerName, _capName) static _type _##_lowerName;\
+(_type)is##_capName{@synchronized (self){ return _##_lowerName;}}\
+(void)set##_capName:(_type)_lowerName{@synchronized (self) {_##_lowerName=_lowerName;}}

@implementation UNOHUD

CLASS_PROPERTY_SETTER_GETTER(BOOL, loadingVisible, LoadingVisible)
CLASS_PROPERTY_SETTER_GETTER(BOOL, loadingPending, LoadingPending)
CLASS_PROPERTY_SETTER_GETTER(BOOL, HUDVisible, HUDVisible)


//sure we can simply hide or show the loading view as well.
+ (void)showLoading {
    [self showLoadingWithUserInteractionIgnored:NO];
}

+ (void)showLoadingWithUserInteractionIgnored:(BOOL)isIgnoreUserInteraction {
    if (isIgnoreUserInteraction)
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    if (self.isHUDVisible) {
        self.loadingPending = YES;
        return;
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    while (1){
        //remove all previous loading view
        UIView *oldView = [window viewWithTag:TAG_LOADING_VIEW];
        if (oldView)
            [oldView removeFromSuperview];
        else break;
    }
    
    UIView *loadingView = [[UIView alloc] initWithFrame:window.bounds];
    loadingView.userInteractionEnabled = NO;
    if (isIgnoreUserInteraction)
        loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    else loadingView.backgroundColor = [UIColor clearColor];
    UNOLoadingAnimationView *viewLoadingAnimation = [[UNOLoadingAnimationView alloc] initWithFrame:CGRectMake(0, 0, 106, 106)];
    [loadingView addSubview:viewLoadingAnimation];
    loadingView.tag = TAG_LOADING_VIEW;
    [viewLoadingAnimation startAnimation];
    viewLoadingAnimation.center = window.center;
    
    [window addSubview:loadingView];
    
    loadingView.alpha = 0.0f;
    [UIView beginAnimations:nil context:(__bridge void *)(loadingView)];
    [UIView setAnimationDelay:0.5];
    [UIView setAnimationDuration:0.2];
    loadingView.alpha = 1.0f;
    [UIView commitAnimations];
    
    loadingView.hidden = NO;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.loadingPending = NO;
    self.loadingVisible = YES;
}

+ (void)dismissAll {
    //the order is important. Must first dismiss loading to set loadingPending flag to false
    [self dismissLoading];
    [self dismissHUD];
}

+ (void)dismissLoading {
    [self dismissLoadingWithUserInteractionIgnoringEnd:YES];
}

+ (void)dismissLoadingWithUserInteractionIgnoringEnd: (BOOL)isIgnoringEnd {
    if (isIgnoringEnd && [[UIApplication sharedApplication] isIgnoringInteractionEvents])
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

    for (UIWindow *window in [UIApplication sharedApplication].windows){
        while(1){
            UIView *loadingView = [window viewWithTag:TAG_LOADING_VIEW];
            if (loadingView){
                loadingView.hidden = YES;
                UNOLoadingAnimationView *viewLoadingAnimation = [loadingView.subviews firstObject];
                [viewLoadingAnimation stop];
                [loadingView removeFromSuperview];
            } else break;
        }
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.loadingVisible = NO;
    self.loadingPending = NO;
}

+ (void)showSuccessHUDWithContent: (NSString *)content {
    [self showHUDWithIcon:[UIImage imageNamed:@"PodUnovoUIComponentsResources.bundle/tick_dark"] content:content];
}

+ (void)showErrorHUDWithContent: (NSString *)content {
    [self showHUDWithIcon:[UIImage imageNamed:@"PodUnovoUIComponentsResources.bundle/error_dark"] content:content staySeconds:3];
}

+ (void)showInfoHUDWithContent: (NSString *)content {
    [self showHUDWithIcon:nil content:content];
}
+ (void)showHUDWithIcon: (UIImage *)icon content: (NSString *)content {
    [self showHUDWithIcon:icon content:content staySeconds:AUTO_DISMISS_SEC];
}

+ (void)showHUDWithIcon: (UIImage *)icon content: (NSString *)content staySeconds: (NSInteger)sec{
    if (self.isLoadingVisible) {
        [self dismissLoadingWithUserInteractionIgnoringEnd:NO];
        self.loadingPending = YES;
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    while (1){
        //remove previous hud
        UIView *oldView = [window viewWithTag:TAG_HUD_VIEW];
        if (oldView)
            [oldView removeFromSuperview];
        else break;
    }
    
    UIView *viewHUD = [UIView new];
    viewHUD.tag = TAG_HUD_VIEW;
    viewHUD.backgroundColor = UIColorFromHex(0xe6e6e6);
    viewHUD.clipsToBounds = YES;
    viewHUD.layer.cornerRadius = 5;
    CGFloat width = INSET_INNER_LEFT_RIGHT << 1;
    CGFloat height = 0;
    CGFloat offsetX = INSET_INNER_LEFT_RIGHT;
    UIImageView *imageViewIcon;
    if (icon) {
        imageViewIcon = [[UIImageView alloc] initWithImage: icon];
        width += CGRectGetWidth(imageViewIcon.bounds) + GAP_BETWEEN_ICON_AND_TEXT;
        height = CGRectGetHeight(imageViewIcon.bounds);
        imageViewIcon.frame = CGRectMake(INSET_INNER_LEFT_RIGHT, INSET_TOP, CGRectGetWidth(imageViewIcon.bounds), CGRectGetHeight(imageViewIcon.bounds));
        offsetX = CGRectGetMaxX(imageViewIcon.frame) + GAP_BETWEEN_ICON_AND_TEXT;
        [viewHUD addSubview:imageViewIcon];
    }
    
    UILabel *labelContent = [UILabel new];
    labelContent.font = [UIFont systemFontOfSize:16];
    labelContent.textColor = UIColorFromHex(0x454545);
    labelContent.textAlignment = NSTextAlignmentLeft;
    labelContent.numberOfLines = 1;
    labelContent.text = content;
    [labelContent sizeToFit];
    
    if (CGRectGetWidth(labelContent.bounds) + width + INSET_OUTTER_LEFT_RIGHT > SCREEN_WIDTH) {
        //multiple line mode
        labelContent.numberOfLines = 0;
        {
            CGRect frame = labelContent.frame;
            frame.size.width = SCREEN_WIDTH - width - INSET_OUTTER_LEFT_RIGHT;
            labelContent.frame = frame;
        }
        [labelContent sizeToFit];
    }
    
    height = MAX(height, CGRectGetHeight(labelContent.bounds));
    labelContent.frame = CGRectMake(offsetX, INSET_TOP, CGRectGetWidth(labelContent.bounds), height);
    [viewHUD addSubview:labelContent];
    
    width += CGRectGetWidth(labelContent.bounds);
    viewHUD.frame = CGRectMake(0, 0, width, height + INSET_TOP * 2);
    viewHUD.center = CGPointMake(window.center.x, CGRectGetMaxY(window.bounds) - CGRectGetMidY(viewHUD.bounds) - CGRectGetHeight(window.bounds) * 0.1);
    viewHUD.alpha = 0;
    {
        CGRect frame = viewHUD.frame;
        frame.origin.y += 30;
        viewHUD.frame = frame;
    }
    [window addSubview:viewHUD];
    
    if (imageViewIcon) {
        CGPoint imageCenter = imageViewIcon.center;
        imageCenter.y = labelContent.center.y;
        imageViewIcon.center = imageCenter;
    }
        
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = viewHUD.frame;
        frame.origin.y -= 30;
        viewHUD.frame = frame;
        viewHUD.alpha = 1;
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissHUDForHUDView:viewHUD];
    });
    self.HUDVisible = YES;
}

+ (void)dismissHUDForHUDView: (UIView *)viewHUD {
    if (!viewHUD) {
        self.HUDVisible = NO;
        if (self.isLoadingPending)
            [self showLoading];
        return;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = viewHUD.frame;
        frame.origin.y += 30;
        viewHUD.frame = frame;
        viewHUD.alpha = 0;
    } completion:^(BOOL finished) {
        [viewHUD removeFromSuperview];
        self.HUDVisible = NO;
        if (self.isLoadingPending)
            [self showLoading];
    }];
}

+ (void)dismissHUD {
    UIView *viewHUD = [[[UIApplication sharedApplication] keyWindow] viewWithTag:TAG_HUD_VIEW];
    [self dismissHUDForHUDView:viewHUD];
}

@end
