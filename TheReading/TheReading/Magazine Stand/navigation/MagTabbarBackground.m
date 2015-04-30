//
//  MagTabbar.m
//  TheReading
//
//  Created by grenlight on 15/1/23.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "MagTabbarBackground.h"

@implementation MagTabbarBackground

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [OWColor colorWithHex:0xf5f3ee];
    }
    return self;
}

- (void)awakeFromNib
{
    self.backgroundColor = [OWColor colorWithHex:0xf5f3ee];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextMoveToPoint(context, 0, 0.25);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds),  0.25);
    CGContextDrawPath(context, kCGPathStroke );

    NSInteger width = ceilf(CGRectGetWidth(rect)/4.0f);
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [OWColor colorWithHex:0xd4d4d4].CGColor);
    for (NSInteger i=1; i<4; i++) {
        CGContextMoveToPoint(context, width*i - 0.5, 0);
        CGContextAddLineToPoint(context, width*i - 0.5,  CGRectGetHeight(rect));
    }
    CGContextDrawPath(context, kCGPathStroke );
    
}

@end
