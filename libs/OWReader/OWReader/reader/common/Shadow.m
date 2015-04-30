//
//  Shadow.m
//  QuartzTest
//
//  Created by iMac001 on 11-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Shadow.h"

@interface Shadow()
-(void)rightShadow:(CGContextRef)context rect:(CGRect)rect;
-(void)allShadow:(CGContextRef)context rect:(CGRect)rect;
@end

@implementation Shadow

- (id)initWithFrame:(CGRect)frame blur:(CGFloat)blur shadowDirection:(ShadowDirection)direction
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        blurDistance = blur;
        shadowDirection = direction;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(shadowDirection == glSHADOWDIRECTION_RIGHT){
        [self rightShadow:context rect:rect]; 
    }else if(shadowDirection == glSHADOWDIRECTION_ALL){
        [self allShadow:context rect:rect];
    }

}
-(void)allShadow:(CGContextRef)context rect:(CGRect)rect{
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(5, 0), blurDistance, [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor);
    
    CGContextSetRGBFillColor (context, 1, 1, 1,1);
    CGContextSetRGBFillColor(context, 1, 0, 0, 1.0);
    
	CGContextSetLineWidth(context, 1.0);
    //    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1 alpha:1].CGColor);
	CGContextSetLineWidth(context, 1);
    float maxx = CGRectGetMaxX(rect) - blurDistance;
    float maxy =CGRectGetMaxY(rect);
    
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect);
	float radius = 6;
    
	CGContextMoveToPoint(context, minx, miny);
    CGContextAddLineToPoint(context, maxx, miny);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddLineToPoint(context, minx, maxy);
    CGContextAddLineToPoint(context, minx, miny);

    
    CGContextClosePath(context);    
    CGContextDrawPath(context, kCGPathFill);

    CGContextRestoreGState(context);
}
-(void)rightShadow:(CGContextRef)context rect:(CGRect)rect{
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), blurDistance, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor);
    
    CGContextSetRGBFillColor (context, 1, 1, 1,1);
	CGContextSetLineWidth(context, 1);
//    float maxX = CGRectGetMaxX(rect) - blurDistance;
//    float maxY =CGRectGetMaxY(rect);
//	CGContextMoveToPoint(context, 0, 0);
//    CGContextAddLineToPoint(context, maxX, 0);
//    CGContextAddLineToPoint(context, maxX, maxY);
//    CGContextAddLineToPoint(context, 0, maxY);
//    CGContextAddLineToPoint(context, 0, 0);
    
    float maxx = CGRectGetMaxX(rect) - blurDistance;
    float maxy =CGRectGetMaxY(rect);
    
    CGFloat minx = CGRectGetMinX(rect), midx = maxx / 2;
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect);
	float radius = 6;
    
	CGContextMoveToPoint(context, minx, miny);
    CGContextAddLineToPoint(context, midx, miny);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddLineToPoint(context, minx, maxy);
    CGContextAddLineToPoint(context, minx, miny);
    
    CGContextClosePath(context);    
    CGContextDrawPath(context, kCGPathFill);
    CGContextRestoreGState(context);
}


@end
