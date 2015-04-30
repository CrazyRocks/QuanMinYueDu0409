//
//  OWImage.m
//  OWUIKit
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation OWImage

+ (UIImage *)imageWithName:(NSString *)name
{
    if (!name || [name isEqualToString:@""]) {
        return nil;
    }
    UIImage *image =[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"png"]];

    return [OWImage imageWithScaleImage:image];
}

+ (UIImage *)imageWithName:(NSString *)name bundle:(NSBundle *)bundle;
{
    if (!name || [name isEqualToString:@""]) {
        return nil;
    }
    
    UIImage *image ;
    image =[[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:name ofType:@"png"]];
//    NSLog(@"imagePath---:%@, %@", [bundle bundlePath], [bundle pathForResource:name ofType:@"png"]);
//    
    return [OWImage imageWithScaleImage:image];
}

+ (UIImage *)imageWithData:(NSData *)data
{
    UIImage *image = [UIImage imageWithData:data];
    return [OWImage imageWithScaleImage:image];
}

+ (UIImage *)imageWithScaleImage:(UIImage *)img
{
    return [[UIImage alloc] initWithCGImage:img.CGImage
                                      scale:[[UIScreen mainScreen] scale]
                                orientation:UIImageOrientationUp];
}

+ (UIImage *)imageWithNoneDeformable:(UIImage *)img cornerRadius:(float)radius
{
    //根据不同的系统版本调用适用的九宫格缩放方法
    return [OWImage imageWithNoneDeformable:img edgeInsets:UIEdgeInsetsMake(radius, radius, radius, radius)];
}

+ (UIImage *)imageWithNoneDeformable:(UIImage *)img edgeInsets:(UIEdgeInsets)edge
{
    //根据不同的系统版本调用适用的九宫格缩放方法
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending) {
        return [img stretchableImageWithLeftCapWidth:edge.left topCapHeight:edge.top];
    }
    return [img resizableImageWithCapInsets:edge];
}

+ (UIImage *)CompositeImage:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
//    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *compoundImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //保存图片到相册
//    UIImageWriteToSavedPhotosAlbum(compoundImage, nil, nil, nil); 
    return compoundImage;
}

+ (UIImage *)CompositeImage:(UIView *)view  scale:(float)scale
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *compoundImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return compoundImage;
}

+(UIImage*)imageFromView:(UIView *)view 
{
    CGSize imageSize = [view bounds].size;
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    CGContextConcatCTM(context, [view transform]);
    CGContextTranslateCTM(context,
                          -[view bounds].size.width * [[view layer] anchorPoint].x,
                          -[view bounds].size.height * [[view layer] anchorPoint].y);
    for (UIView *item in [view subviews]) {
        
        CGContextTranslateCTM(context, [item center].x, [item center].y);
        CGContextConcatCTM(context, [item transform]);
        CGContextTranslateCTM(context,
                              -[item bounds].size.width * [[item layer] anchorPoint].x,
                              -[item bounds].size.height * [[item layer] anchorPoint].y);
        [[item layer] renderInContext:context];

    }

    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


//创建合适大小的图片
+ (UIImage*)resizeImage:(UIImage*)image toWidth:(uint)width height:(uint)height
{
    if (width > 0 && height == 0) {
        height = (width / image.size.width)*image.size.height;
    }
    else if(width == 0 && height > 0){
        width = (height /image.size.height) * image.size.width;
    }

    float imgWidth=0, imgHeight=0;
    
    if ((image.size.width / width) < (image.size.height / height)) {
        imgWidth = width;
        imgHeight = image.size.height * (width / image.size.width);
    }
    else {
        imgHeight = height;
        imgWidth = image.size.width * (height / image.size.height);
    }
    
    CGSize size = CGSizeMake(width, height);  

    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the context because UIKit coordinate system is upside down to Quartz coordinate system
    CGContextTranslateCTM(context, 0.0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Draw the original image to the context
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake((imgWidth - width) / 2.0f, 0.0, imgWidth, imgHeight), image.CGImage);
    
    // Retrieve the UIImage from the current context
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut; 
}

@end
