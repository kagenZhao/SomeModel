//
//  DXRouterHelperMacros.h
//  Pods
//
//  Created by wangyang on 2016/9/28.
//
//

#ifndef DXRouterHelperMacros_h
#define DXRouterHelperMacros_h

#define DXRouterInitPageFromStoryboard(StoryboardName,StoryboardID) \
+ (instancetype)instantiateViewController {\
    return [[UIStoryboard storyboardWithName:StoryboardName bundle:[NSBundle bundleForClass:self]] instantiateViewControllerWithIdentifier:StoryboardID];\
}

#define DXRouterInitPage() \
+ (instancetype)instantiateViewController {\
    return [self new];\
}

#define DXRouterInitDialog(WidthPadding,Height) \
@synthesize completedBlock;\
- (CGSize)dialogSize {\
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - WidthPadding * 2, Height);\
}

#endif /* DXRouterHelperMacros_h */
