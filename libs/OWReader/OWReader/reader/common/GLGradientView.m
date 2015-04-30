//
//  GLGradientView.m
//  GLView
//
//  Created by iMac001 on 12-2-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GLGradientView.h"
#import <OWKit/OWColor.h>


@implementation GLGradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextSaveGState(c);
    
    
    //渐变填充
    CGFloat components[12] = { 
        0xf4/255.0, 0xf4/255.0, 0xf2/255.0, 1.0, 
        0xE9/255.0, 0xe6/255.0, 0xe2/255.0, 1.0,
         0xf4/255.0, 0xf4/255.0, 0xf2/255.0, 1.0 
	};
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 3);
    CFRelease(colorSpace);
	CGContextDrawLinearGradient(c, gradient, CGPointZero, CGPointMake(rect.size.width, 0), kCGGradientDrawsBeforeStartLocation);
	CFRelease(gradient);
    
    CGContextSetStrokeColorWithColor(c, [OWColor colorWithHex:0xC7BFB7].CGColor);
    CGContextMoveToPoint(c, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(c, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextDrawPath(c, kCGPathStroke );

}


@end
