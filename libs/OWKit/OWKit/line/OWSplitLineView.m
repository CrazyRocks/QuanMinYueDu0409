//
//  OWSplitLineView.m
//  LYCommonLibrary
//
//  Created by grenlight on 14-1-16.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "OWSplitLineView.h"
#import "UIStyleManager.h"

@implementation OWSplitLineView

- (void)drawByStyle:(UIStyleObject *)aStyle
{
    style = aStyle;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}
-(void)setup
{
    self.backgroundColor = [UIColor clearColor];
}


-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, style.hLineWidth);
    CGContextSetStrokeColorWithColor(context, style.hLineColor.CGColor);
    CGContextMoveToPoint(context, 0, CGRectGetHeight(self.bounds)-style.hLineWidth/2.0f);
    CGContextAddLineToPoint(context, rect.size.width,  CGRectGetHeight(self.bounds)-style.hLineWidth/2.0f);
    CGContextDrawPath(context, kCGPathStroke );
}


@end
