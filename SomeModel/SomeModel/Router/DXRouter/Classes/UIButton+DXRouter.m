//
//  UIButton+DXRouter.m
//  Pods
//
//  Created by wangyang on 2016/10/8.
//
//

#import "UIButton+DXRouter.h"
#import "DXRouter.h"

#import <objc/runtime.h>

const NSString * kHyperlinkKey;

@implementation UIButton (DXRouter)

- (void)setHyperlink:(NSString *)hyperlink {
    objc_setAssociatedObject(self, &kHyperlinkKey, hyperlink, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)hyperlink {
    return objc_getAssociatedObject(self, &kHyperlinkKey);
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (self.hyperlink && self.hyperlink.length > 0) {
        if ([self.hyperlink hasPrefix:@"/"]) {
            NSArray *router = [[self.hyperlink substringFromIndex:1] componentsSeparatedByString:@"/"];
            [[DXRouter shared] navigateWithArguments:nil fullRouter:router];
        } else {
            NSArray *router = [self.hyperlink componentsSeparatedByString:@"/"];
            [[DXRouter shared] navigateWithArguments:nil additionRouter:router];
        }
    }
    [super sendAction:action to:target forEvent:event];
}

@end
