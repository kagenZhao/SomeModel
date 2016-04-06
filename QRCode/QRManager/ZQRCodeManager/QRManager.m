//
//  QRManager.m
//  QRManager
//
//  Created by zhaoguoqing on 16/3/25.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import "QRManager.h"
@implementation QRManager

+ (UIImage *)createQRCodeImageWithMessage:(NSString *)message size:(CGFloat)size color:(UIColor *)color topImg:(UIImage *)topImg {
    
    CIImage *ciImg = [self createQRForString:message];
    UIImage *outputImg = [self createNonInterpolatedUIImageFormCIImage:ciImg withSize:size];
    
    if (color) {
        CIColor *c = [CIColor colorWithCGColor:color.CGColor];
        outputImg = [self imageBlackToTransparent:outputImg withRed:c.red * 255 andGreen:c.green * 255 andBlue:c.blue * 255];
    }
    if (topImg) {
        UIImage *t = [self circleImageWithImage:topImg Corner:topImg.size.width / 9.0];
        UIGraphicsBeginImageContextWithOptions(outputImg.size, NO, 0);
        [outputImg drawInRect:CGRectMake(0, 0, outputImg.size.width, outputImg.size.height)];
        float r = outputImg.size.width * 5 / 21;
        CGRect rect = CGRectMake((outputImg.size.width-r)/2, (outputImg.size.height-r)/2 ,r, r);
        [t drawInRect:rect];
        outputImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return outputImg;
}


+ (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = nil;
    stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return qrFilter.outputImage;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}


+ (UIImage *)circleImageWithImage:(UIImage *)image Corner:(CGFloat)corner {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    CGContextRef ctx1 = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx1, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx1, CGRectMake(0, 0, image.size.width, image.size.height));
    UIImage *backImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    CGContextRef ctx2 = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, image.size.width, image.size.height) cornerRadius:corner];
    CGContextAddPath(ctx2, path.CGPath);
    CGContextClip(ctx2);
    [image drawInRect:rect];
    UIImage *upImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    CGContextRef ctx3 = UIGraphicsGetCurrentContext();
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, image.size.width, image.size.height) cornerRadius:corner];
    CGContextAddPath(ctx3, path2.CGPath);
    CGContextClip(ctx3);
    [backImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [upImage drawInRect:CGRectMake(image.size.width / 15.0, image.size.width / 15.0, image.size.width - (image.size.width / 15.0 * 2), image.size.height - (image.size.width / 15.0 * 2))];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
