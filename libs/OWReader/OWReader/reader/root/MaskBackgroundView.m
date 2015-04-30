//
//  MaskBackgroundView.m
//  JRReader
//
//  Created by grenlight on 14/11/17.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "MaskBackgroundView.h"
#import <OWKit/OWKit.h>

@implementation MaskBackgroundView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.9;
    }
    
    return self;
}


-(void)drawRect:(CGRect)rect
{

    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    // 简便起见，这里把圆角半径设置为长和宽平均值的1/10
    CGFloat radius = (width + height) * 0.01;
    
    // 获取CGContext，注意UIKit里用的是一个专门的函数
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 移动到初始点
    CGContextMoveToPoint(context, radius, 0);
    
    // 绘制第1条线和第1个1/4圆弧
    CGContextAddLineToPoint(context, width - radius, 0);
    CGContextAddArc(context, width - radius, radius, radius, -0.5 * M_PI, 0.0, 0);
    
    // 绘制第2条线和第2个1/4圆弧
    CGContextAddLineToPoint(context, width, height - radius);
    CGContextAddArc(context, width - radius, height - radius, radius, 0.0, 0.5 * M_PI, 0);
    
    // 绘制第3条线和第3个1/4圆弧
    CGContextAddLineToPoint(context, radius, height);
    CGContextAddArc(context, radius, height - radius, radius, 0.5 * M_PI, M_PI, 0);
    
    // 绘制第4条线和第4个1/4圆弧
    CGContextAddLineToPoint(context, 0, radius);
    CGContextAddArc(context, radius, radius, radius, M_PI, 1.5 * M_PI, 0);
    
    // 闭合路径
    CGContextClosePath(context);
    // 填充半透明黑色
    
//    #161616
    CGContextSetFillColorWithColor(context, [OWColor colorWithHexString:@"#161616"].CGColor);
    
    CGContextDrawPath(context, kCGPathFill);
    
    
    CGContextSetStrokeColorWithColor(context, [OWColor colorWithHexString:@"#99aaaaaa"].CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextMoveToPoint(context, 10, self.frame.size.height/3 + 0.25);
    CGContextAddLineToPoint(context, self.frame.size.width-10,self.frame.size.height/3 + 0.25);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, self.frame.size.width/2 + 0.25, 20);
    CGContextAddLineToPoint(context, self.frame.size.width/2 + 0.25,40);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, 10, self.frame.size.height/3 *2 + 0.25);
    CGContextAddLineToPoint(context, self.frame.size.width-10,self.frame.size.height/3 *2 + 0.25);
    CGContextStrokePath(context);
    
    CGContextDrawPath(context, kCGPathStroke);

}

@end

@implementation MaskBackgroundViewHeader

-(id)initWithFrame:(CGRect)frame withStart:(CGFloat)number
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        start = number;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.9;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, self.frame.size.width * start, 0);
    CGContextAddLineToPoint(context, self.frame.size.width *start +5, 10);
    CGContextAddLineToPoint(context, self.frame.size.width *start -5, 10);
    CGContextAddLineToPoint(context, self.frame.size.width *start, 0);
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, [OWColor colorWithHexString:@"#161616"].CGColor);
    CGContextDrawPath(context, kCGPathFill);
    
}




@end



