//
//  UNHUD.h
//  UNApartmentGuest
//
//  Created by zhefu wang on 9/14/16.
//  Copyright © 2016 KevinZhang. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>

@interface UNOHUD : NSObject

//we could use a queue here, but in this simple case, three booleans are enough already.
@property (class, nonatomic, getter=isLoadingVisible) BOOL loadingVisible;
@property (class, nonatomic, getter=isLoadingPending) BOOL loadingPending;
@property (class, nonatomic, getter=isHUDVisible) BOOL HUDVisible;

+ (void)showLoading;
+ (void)showLoadingWithUserInteractionIgnored:(BOOL)isIgnoreUserInteraction;
+ (void)dismissLoading;
+ (void)dismissLoadingWithUserInteractionIgnoringEnd: (BOOL)isIgnoringEnd;

+ (void)showSuccessHUDWithContent: (NSString *)content;
+ (void)showErrorHUDWithContent: (NSString *)content;
+ (void)showInfoHUDWithContent: (NSString *)content;

+ (void)showHUDWithIcon: (UIImage *)icon content: (NSString *)content;
+ (void)dismissHUD;

+ (void)dismissAll;

@end
