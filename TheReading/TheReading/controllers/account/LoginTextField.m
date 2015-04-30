//
//  LoginTextField.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-27.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "LoginTextField.h"

@implementation LoginTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(7, 2, CGRectGetWidth(bounds)-14,
                      CGRectGetHeight(bounds)-4);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(7, 2, CGRectGetWidth(bounds)-14,
                      CGRectGetHeight(bounds)-4);

}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    __block CGFloat minx, midx, maxx, miny, midy, maxy;
    void(^drawRect)(CGRect) = ^(CGRect rrect) {
        minx = CGRectGetMinX(rrect);
        midx = CGRectGetMidX(rrect);
        maxx = CGRectGetMaxX(rrect);
        miny = CGRectGetMinY(rrect) ;
        midy = CGRectGetMidY(rrect) ;
        maxy = CGRectGetMaxY(rrect);
        CGContextMoveToPoint(context, minx , midy );
        CGContextAddArcToPoint(context, minx , miny , midx , miny, 4);
        CGContextAddArcToPoint(context, maxx , miny , maxx , midy , 4);
        CGContextAddArcToPoint(context, maxx , maxy , midx , maxy , 4);
        CGContextAddArcToPoint(context, minx , maxy, minx , midy , 4);
        CGContextClosePath(context);
    };
    CGRect borderRect = CGRectMake(0.25, 0.25, CGRectGetWidth(rect)-0.5f, CGRectGetHeight(rect)-0.5f);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetFillColorWithColor(context, [OWColor colorWithHex:0xfafafa].CGColor);
    CGContextSetStrokeColorWithColor(context, [OWColor colorWithHex:0xa7926d].CGColor);
    drawRect(borderRect);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
