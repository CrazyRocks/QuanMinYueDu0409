//
//  OWBorderView.m
//  Xcode6AppTest
//
//  Created by grenlight on 14/6/26.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWBorderView.h"

@implementation OWBorderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setStyle:(OWControlCSS *)cssStyle
{
    css = cssStyle;
    self.backgroundColor = [UIColor clearColor];
    [self setNeedsDisplay];
}

- (void)layoutIfNeeded
{
    [super layoutIfNeeded];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    __block CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    
    CGRect borderRect = CGRectMake(0.25, 0.25, CGRectGetWidth(rect)-0.5f, CGRectGetHeight(rect)-0.5f);
    __block CGFloat minx, midx, maxx, miny, midy, maxy;
    
    void(^DrawRect)(CGRect) = ^(CGRect rrect) {
        minx = CGRectGetMinX(rrect);
        midx = CGRectGetMidX(rrect);
        maxx = CGRectGetMaxX(rrect);
        miny = CGRectGetMinY(rrect) ;
        midy = CGRectGetMidY(rrect) ;
        maxy = CGRectGetMaxY(rrect);
        CGContextMoveToPoint(context, minx , midy );
        CGContextAddArcToPoint(context, minx , miny , midx , miny, css.cornerRadius);
        CGContextAddArcToPoint(context, maxx , miny , maxx , midy , css.cornerRadius);
        CGContextAddArcToPoint(context, maxx , maxy , midx , maxy , css.cornerRadius);
        CGContextAddArcToPoint(context, minx , maxy, minx , midy , css.cornerRadius);
        CGContextClosePath(context);
    };
    
    float(^getComponent)(NSInteger) = ^(NSInteger index){
        return  [css.fillColor_normal[index] floatValue];
    };
    
    //clip
    
    CGContextSetLineWidth(context, css.borderWidth / 2.0f);
    
    DrawRect(borderRect);
    CGContextClip(context);
    
    CGFloat components[8] = {
        getComponent(0), getComponent(1), getComponent(2), getComponent(3),
        getComponent(4), getComponent(5), getComponent(6), getComponent(7)
    };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, rect.size.height), kCGGradientDrawsBeforeStartLocation);
    CFRelease(gradient);
    CFRelease(colorSpace);
    
    CGContextSaveGState(context);
    
    //draw border
    CGContextSetStrokeColorWithColor(context, css.borderColor_normal.CGColor);
    DrawRect(borderRect);
    CGContextDrawPath(context, kCGPathStroke);
    
}

@end
