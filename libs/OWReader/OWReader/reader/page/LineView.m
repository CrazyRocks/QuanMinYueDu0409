//
//  LineView.m
//  LYBookStore
//
//  Created by grenlight on 14-9-28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LineView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LineView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
    }
    
    return self;
}

-(void)drawRect:(CGRect)rect
{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    CGContextBeginPath(context);
//    
//    CGContextMoveToPoint(context, _startPoint.x-10, _startPoint.y-10);
//    
//    if (_endPoint.x == 0) {
//        CGContextAddLineToPoint(context, _startPoint.x+10, _startPoint.y-10);
//        CGContextAddLineToPoint(context, _startPoint.x+10, _startPoint.y+10);
//        CGContextAddLineToPoint(context, _startPoint.x-10, _startPoint.y+10);
//    }else{
//        CGContextAddLineToPoint(context, self.frame.size.width/2,0);
//        CGContextAddLineToPoint(context, self.frame.size.width, 20);
//        CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
//        CGContextAddLineToPoint(context, 0, self.frame.size.height);
//        CGContextAddLineToPoint(context, 0, 300);
//    }
//
//    CGContextClosePath(context);
//    
////    [[OWColor colorWithHexString:@"#D3D3D3"] setFill]; //设置填充色
//    
//    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] setFill];
//    
//    
//    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] setStroke]; //设置边框颜色
//    
//    CGContextDrawPath(context,kCGPathFillStroke);//绘制路径path

}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return NO;
}




@end
