//
//  UILabel+KZVerticalAlgnment.h
//  test
//
//  Created by Kagen Zhao on 16/9/2.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 UILabel文字垂直方向的对其方式

 - KZCustomeVerticalAlgnmentMiddle: 垂直居中对其
 - KZCustomeVerticalAlgnmentTop: 垂直居上对其
 - KZCustomeVerticalAlgnmentBottom: 垂直居下对齐
 */
typedef NS_ENUM(NSUInteger, KZCustomeVerticalAlgnment) {
    KZCustomeVerticalAlgnmentMiddle = 0,
    KZCustomeVerticalAlgnmentTop,
    KZCustomeVerticalAlgnmentBottom,
};

@interface UILabel (KZVerticalAlgnment)

@property (nonatomic, assign, readwrite) KZCustomeVerticalAlgnment CustomeVertical;

@end
