//
//  MagSearchFrame.m
//  LYMagazinesStand
//
//  Created by grenlight on 14-5-23.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "MagSearchFrame.h"
#import <LYService/LYService.h>
#import <OWKit/OWKit.h>

@implementation MagSearchFrame

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"magSearch_icon"]];
    [self addSubview:icon];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"杂志搜索框"];
    
    __block CGFloat minx, midx, maxx, miny, midy, maxy;
    
    void(^DrawRect)(CGRect) = ^(CGRect rrect) {
        minx = CGRectGetMinX(rrect);
        midx = CGRectGetMidX(rrect);
        maxx = CGRectGetMaxX(rrect);
        miny = CGRectGetMinY(rrect) ;
        midy = CGRectGetMidY(rrect) ;
        maxy = CGRectGetMaxY(rrect);
        CGContextMoveToPoint(context, minx , midy );
        CGContextAddArcToPoint(context, minx , miny , midx , miny, style.cornerRadius);
        CGContextAddArcToPoint(context, maxx , miny , maxx , midy , style.cornerRadius);
        CGContextAddArcToPoint(context, maxx , maxy , midx , maxy , style.cornerRadius);
        CGContextAddArcToPoint(context, minx , maxy, minx , midy , style.cornerRadius);
        CGContextClosePath(context);
    };
    
    CGRect borderRect = CGRectMake(style.borderWidth/2.0f, style.borderWidth/2.0f, CGRectGetWidth(rect)-style.borderWidth, CGRectGetHeight(rect)-style.borderWidth);
    CGContextSetLineWidth(context, style.borderWidth);
    CGContextSetStrokeColorWithColor(context, style.borderColor.CGColor);
    if (style.fillColor)
        CGContextSetFillColorWithColor(context, style.fillColor.CGColor);
    
    DrawRect(borderRect);
    
    if (style.fillColor)
        CGContextDrawPath(context, kCGPathFillStroke);
    else
        CGContextDrawPath(context, kCGPathStroke);

}

@end
