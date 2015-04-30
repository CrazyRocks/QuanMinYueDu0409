//
//  OWImage.h
//  OWUIKit
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWImage : NSObject

+(UIImage *)imageWithName:(NSString *)name;
+(UIImage *)imageWithName:(NSString *)name bundle:(NSBundle *)bundle;

+(UIImage *)imageWithData:(NSData *)data;
+(UIImage *)imageWithScaleImage:(UIImage *)img;
//返回九宫格缩放的图片
+(UIImage *)imageWithNoneDeformable:(UIImage *)img cornerRadius:(float)radius;
+(UIImage *)imageWithNoneDeformable:(UIImage *)img edgeInsets:(UIEdgeInsets)edge;

+(UIImage *)CompositeImage:(UIView *)view ;
+(UIImage *)CompositeImage:(UIView *)view scale:(float)scale ;
+(UIImage*)imageFromView:(UIView *)view ;


+ (UIImage*)resizeImage:(UIImage*)image toWidth:(uint)width height:(uint)height;
@end
