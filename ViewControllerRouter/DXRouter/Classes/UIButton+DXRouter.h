//
//  UIButton+DXRouter.h
//  Pods
//
//  Created by wangyang on 2016/10/8.
//
//

#import <UIKit/UIKit.h>

@interface UIButton (DXRouter)

// DXRouter格式的hyperlink，比如 /DXHome/DXContent 或者  DXContent/#DXDialog
// '/'开头的是全路由，反之是附加路由，详情看WIKI http://gitlab.baidao.com/dxios/DXRouter/wikis/home
@property (copy, nonatomic) IBInspectable NSString *hyperlink;

@end
