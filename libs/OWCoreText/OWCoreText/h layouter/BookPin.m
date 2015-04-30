//
//  BookPin.m
//  MyPin
//
//  Created by grenlight on 14/12/10.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "BookPin.h"
#import <QuartzCore/QuartzCore.h>

@implementation BookPin

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        [self setup];
        
    }
    
    return self;
}

-(void)setup
{
    
    self.backgroundColor = [UIColor clearColor];
    
    _headerImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 12, 12)];
    
    [_headerImage setImage:[UIImage imageNamed:@"reading_select"]];
    
    _headerImage.center = CGPointMake(self.frame.size.width/2, 6);
    
    [self addSubview:_headerImage];
}


-(void)drawRect:(CGRect)rect
{
    CGFloat starY = _headerImage.center.y;
    CGFloat endY = self.frame.size.height;
    
    CGFloat x = _headerImage.center.x;
    
    CGFloat lineWithd = 2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineWithd);
    
    CGContextSetRGBStrokeColor(context, 97.0f/255.0f, 73.0f/255.0f, 73.0f/255.0f, 1);//线条颜色
    CGContextMoveToPoint(context, x, starY);
    CGContextAddLineToPoint(context, x,endY);
    CGContextStrokePath(context);
}





@end
