//
//  NavBarBackgroundView.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-8-18.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "OWGradientBackgroundView.h"
#import "UIStyleManager.h"

@implementation OWGradientBackgroundView

- (void)drawByStyle:(UIStyleObject *)aStyle
{
    style = aStyle;
    self.backgroundColor = [UIColor clearColor];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //渐变填充
    NSArray *arr = style.gradientBackground;
    CGGradientRef gradient;
    if (arr.count == 8) {
        CGFloat components[8] = {
            [arr[0] floatValue], [arr[1] floatValue], [arr[2] floatValue], [arr[3] floatValue],
            [arr[4] floatValue], [arr[5] floatValue],[arr[6] floatValue], [arr[7] floatValue]
        };
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
    }
    else {
        CGFloat components[12] = {
            [arr[0] floatValue], [arr[1] floatValue], [arr[2] floatValue], [arr[3] floatValue],
            [arr[4] floatValue], [arr[5] floatValue], [arr[6] floatValue], [arr[7] floatValue],
            [arr[8] floatValue], [arr[9] floatValue], [arr[10] floatValue], [arr[11] floatValue]
        };
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 3);
    }
    
    CGContextDrawLinearGradient(c, gradient, CGPointZero, CGPointMake(0, rect.size.height), kCGGradientDrawsBeforeStartLocation);
    
    CFRelease(gradient);
    CFRelease(colorSpace);
    
    CGContextSetStrokeColorWithColor(c, style.hLineColor.CGColor);
    CGContextSetLineWidth(c,style.hLineWidth);
    CGContextMoveToPoint(c, 0, rect.size.height-style.hLineWidth/2.0f);
    CGContextAddLineToPoint(c, rect.size.width, rect.size.height-style.hLineWidth/2.0f);
    
    CGContextStrokePath(c);    
}

@end
