//
//  GLNoiceBackgroundView.m
//  GLView
//
//  Created by  on 11-12-31.
//  Copyright (c) 2011年 grenlight. All rights reserved.
//

#import "GLNoiceBackgroundView.h"

@interface GLNoiceBackgroundView()
{
    NSString *imagePath;
    UIImage *noise;
}
@end

@implementation GLNoiceBackgroundView

- (id)initWithFrame:(CGRect)frame bgColor:(UIColor *)color bgImage:(NSString *)image;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        imagePath = [[NSBundle mainBundle] pathForResource:image ofType:@"png"];
        self.backgroundColor = color;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect bounds = self.bounds;
    
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:bounds];
    
    CGContextAddPath(context, [path CGPath]);
    CGContextClip(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    noise = [UIImage imageWithContentsOfFile:imagePath];

    [noise drawAsPatternInRect:bounds];
    
    CGContextRestoreGState(context);
}

@end
