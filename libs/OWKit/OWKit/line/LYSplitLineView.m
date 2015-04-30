//
//  SplitLineView.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-26.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "LYSplitLineView.h"
#import "OWColor.h"

@implementation LYSplitLineView

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
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [OWColor colorWithHex:0x999999].CGColor);
    CGContextMoveToPoint(context, 0, CGRectGetHeight(self.bounds)-0.25);
    CGContextAddLineToPoint(context, rect.size.width,  CGRectGetHeight(self.bounds)-0.25);
    CGContextDrawPath(context, kCGPathStroke );
}

@end
