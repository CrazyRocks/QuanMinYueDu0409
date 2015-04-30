//
//  MenuTableHeader.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-4-22.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "MenuTableHeader.h"
#import "LYMagazinesStand.h"
#import <OWKit/OWKit.h>

@implementation MenuTableHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
   __block CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //渐变填充

    void(^drawGradinet)(NSArray *, CGPoint, CGPoint) = ^(NSArray *arr, CGPoint startPoint, CGPoint endPoint){
        CGGradientRef gradient;
        CGFloat components[8] = {
            [arr[0] floatValue], [arr[1] floatValue], [arr[2] floatValue], [arr[3] floatValue],
            [arr[4] floatValue], [arr[5] floatValue], [arr[6] floatValue], [arr[7] floatValue]
        };
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
        CGContextDrawLinearGradient(c, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
        CFRelease(gradient);
    };
    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"左侧边栏顶部"];
    NSArray *arr = style.gradientBackground;
    drawGradinet(arr, CGPointMake(0, 0), CGPointMake(0, CGRectGetHeight(rect)));
    
    CFRelease(colorSpace);
    
    CGContextSetLineWidth(c, style.hLineWidth);
  
    CGContextSetStrokeColorWithColor(c, style.hLineColor.CGColor);
    CGContextMoveToPoint(c, CGRectGetMinX(rect), CGRectGetMaxY(rect)-style.hLineWidth/2.0f);
    CGContextAddLineToPoint(c, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-style.hLineWidth/2.0f);
    CGContextDrawPath(c, kCGPathStroke );
}

@end
