//
//  MTCBackgroundView.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-4-22.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "MTCBackgroundView.h"
#import "GlobalManager.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@implementation MTCBackgroundView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();    
    
    NSString *styleName = @"左侧边栏列表";
    if (isPad) {
        styleName = @"左侧边栏列表_Pad";
    }
    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:styleName];
    CGContextSetFillColorWithColor(c, style.background.CGColor);
    CGContextFillRect(c, rect);
    
    CGContextSetLineWidth(c, style.vLineWidth);
    CGContextSetStrokeColorWithColor(c, style.vLineColor.CGColor);

    CGContextMoveToPoint(c, 1, CGRectGetMinY(rect));
    CGContextAddLineToPoint(c, 1, CGRectGetMaxY(rect)-style.hLineWidth);
    CGContextDrawPath(c, kCGPathStroke );
    
    CGContextSetLineWidth(c, style.hLineWidth);
    CGContextSetStrokeColorWithColor(c, style.hLineColor.CGColor);
    CGContextMoveToPoint(c, CGRectGetMinX(rect), CGRectGetMaxY(rect)-style.hLineWidth/2.0f);
    CGContextAddLineToPoint(c, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-style.hLineWidth/2.0f);
    CGContextDrawPath(c, kCGPathStroke );
   }

@end
