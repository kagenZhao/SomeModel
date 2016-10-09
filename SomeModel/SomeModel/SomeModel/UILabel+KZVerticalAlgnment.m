//
//  UILabel+KZVerticalAlgnment.m
//  test
//
//  Created by Kagen Zhao on 16/9/2.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import "UILabel+KZVerticalAlgnment.h"
#import <objc/objc-runtime.h>


static NSString *const kKZCustomeVerticalKey = @"kCustomeVerticalKey";

@implementation UILabel (VerticalAlgnment)

- (void)setCustomeVertical:(KZCustomeVerticalAlgnment)CustomeVertical {
    objc_setAssociatedObject(self, &kKZCustomeVerticalKey, @(CustomeVertical), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsDisplay];
}

- (KZCustomeVerticalAlgnment)CustomeVertical {
    return [objc_getAssociatedObject(self, &kKZCustomeVerticalKey) integerValue];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method m1 = class_getInstanceMethod([UILabel class], @selector(textRectForBounds:limitedToNumberOfLines:));
        Method m2 = class_getInstanceMethod([UILabel class], @selector(swz_textRectForBounds:limitedToNumberOfLines:));
        Method m3 = class_getInstanceMethod([UILabel class], @selector(drawTextInRect:));
        Method m4 = class_getInstanceMethod([UILabel class], @selector(swz_drawTextInRect:));
        method_exchangeImplementations(m1, m2);
        method_exchangeImplementations(m3, m4);
    });
}

- (CGRect)swz_textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [self swz_textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.CustomeVertical) {
        case KZCustomeVerticalAlgnmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
        case KZCustomeVerticalAlgnmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case KZCustomeVerticalAlgnmentMiddle:
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
    }
    return textRect;
}

-(void)swz_drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [self swz_drawTextInRect:actualRect];
}


@end
