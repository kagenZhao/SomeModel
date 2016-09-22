//
//  UILabel+VerticalAlgnment.h
//  test
//
//  Created by Kagen Zhao on 16/9/2.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, CustomeVerticalAlgnment) {
    CustomeVerticalAlgnmentMiddle = 0,
    CustomeVerticalAlgnmentTop,
    CustomeVerticalAlgnmentBottom,
};

@interface UILabel (VerticalAlgnment)

@property (nonatomic, assign, readwrite) CustomeVerticalAlgnment CustomeVertical;

@end
