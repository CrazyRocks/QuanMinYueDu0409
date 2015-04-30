//
//  BubbleView.m
//  气泡控件
//
//  Created by iMac001 on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GLBubble.h"

#define kCornerRadius  4.0f

#define kTriangleHeight 7.0f
#define kTriangleRadius  8.0f

@implementation GLBubble

@synthesize anglePointX;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        anglePointX = 100;
        [self performSelector:@selector(initContent)];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame andAnglePoint:(float)apx{
    self = [super initWithFrame:frame];
    if (self) {
        anglePointX = apx;
        [self performSelector:@selector(initContent)];
    }
    return self;
}
-(void)initContent{
    self.backgroundColor = [UIColor clearColor]; 
}


- (void)drawRect:(CGRect)rect
{  
    UIColor *borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextSetShadowWithColor(c, CGSizeMake(0, 3), 3, [UIColor blackColor].CGColor);
	
	CGContextSaveGState(c);
	CGRect rectFrame = rect;
    rectFrame.size.height -= kTriangleHeight;
	// Rect with radius, will be used to clip the entire view
	CGFloat minx = CGRectGetMinX(rect) + 1, midx = CGRectGetMidX(rectFrame),
    maxx = CGRectGetMaxX(rectFrame) ;
	CGFloat miny = CGRectGetMinY(rect) + 1, midy = CGRectGetMidY(rectFrame) ,
    maxy = CGRectGetMaxY(rectFrame) ;
    float rightJoinX = anglePointX + kTriangleRadius ;
    float leftJoinX = anglePointX - kTriangleRadius;
    float anglePointY = maxy + kTriangleHeight - .5;
    
    CGContextMoveToPoint(c, minx - .5, midy - .5);
	CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, kCornerRadius);
	CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, kCornerRadius);
	CGContextAddArcToPoint(c, maxx - .5, maxy - .5, rightJoinX, maxy - .5, kCornerRadius);
    CGContextAddLineToPoint(c, rightJoinX, maxy - .5);
    //弧形尖角
//    CGContextAddArc(c, rightJoinX, rect.size.height - .5, kTriangleRadius,  3.0*(M_PI/2.0),M_PI, true);
//    CGContextAddArc(c, leftJoinX , rect.size.height - .5, kTriangleRadius,   0.0, 3.0*(M_PI/2.0),true);
    
    //直线尖角
    CGContextAddLineToPoint(c, anglePointX, anglePointY);
    CGContextAddLineToPoint(c, leftJoinX, maxy - .5);


    CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, kCornerRadius);
    CGContextClosePath(c);
    
	CGContextClip(c);
    
    //渐变填充
    CGFloat components[8] = { 
        0x15/255.0, 0x15/255.0, 0x15/255.0, 0.8, 
        0.0, 0.0, 0.0, .95
	};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
    CFRelease(colorSpace);
	CGContextDrawLinearGradient(c, gradient, CGPointZero, CGPointMake(0, rect.size.height), kCGGradientDrawsBeforeStartLocation);
	CFRelease(gradient);
    CGContextRestoreGState(c);
    
    
    CGContextSetStrokeColorWithColor(c, borderColor.CGColor);
    CGContextSetAllowsAntialiasing(c, TRUE);
    CGContextMoveToPoint(c, minx - .5, midy - .5);
	CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, kCornerRadius);
	CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, kCornerRadius);
	CGContextAddArcToPoint(c, maxx - .5, maxy - .5, rightJoinX, maxy - .5, kCornerRadius);
    
    CGContextAddLineToPoint(c, rightJoinX, maxy - .5);
    //弧形尖角
//    CGContextAddArc(c, rightJoinX, rect.size.height - .5, kTriangleRadius,  3.0*(M_PI/2.0),M_PI, true);
//    CGContextAddArc(c, leftJoinX , rect.size.height - .5, kTriangleRadius,   0.0, 3.0*(M_PI/2.0),true);
    
//直线尖角
    CGContextAddLineToPoint(c, anglePointX, anglePointY);
    CGContextAddLineToPoint(c, leftJoinX, maxy - .5);
    
	CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, kCornerRadius);
    CGContextClosePath(c);
	CGContextStrokePath(c);
 
}

-(void)drawView:(float)apX :(float)width{
    anglePointX = apX;
    CGRect newFrame = self.frame;
    newFrame.size.width = width;
    [self setFrame:newFrame];
    [self setNeedsDisplay];
}



@end
