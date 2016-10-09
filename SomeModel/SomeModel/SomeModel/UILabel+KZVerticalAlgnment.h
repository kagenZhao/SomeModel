//
//  UILabel+KZVerticalAlgnment.h
//  test
//
//  Created by Kagen Zhao on 16/9/2.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, KZCustomeVerticalAlgnment) {
    KZCustomeVerticalAlgnmentMiddle = 0,
    KZCustomeVerticalAlgnmentTop,
    KZCustomeVerticalAlgnmentBottom,
};

@interface UILabel (KZVerticalAlgnment)

@property (nonatomic, assign, readwrite) KZCustomeVerticalAlgnment CustomeVertical;

@end
