//
//  PageImage.m
//  DragonSourceEPUB
//
//  Created by iMac001 on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LYPageImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation LYPageImage

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.contentMode = UIViewContentModeScaleAspectFit;
//        self.layer.shadowRadius = 2;
//        self.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.layer.shadowOpacity = 0.5;
//        self.layer.shadowOffset = CGSizeMake(0, 0);
//        
//        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
//        self.layer.shadowPath = path.CGPath;
       
        self.userInteractionEnabled = YES;
        
        singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(onTap:)];  
        singleTap.numberOfTapsRequired = 1;
        [self addTapGesture];
    }
    return self;
}

-(void)onTap:(UIGestureRecognizer *)gesture
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self,@"image",self.superview,@"pageView", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"PageImageToFullScreen" object:nil userInfo:dic];
    
    [self removeGestureRecognizer:singleTap];
}

-(void)addTapGesture
{
    [self addGestureRecognizer:singleTap];
//    self.layer.shadowRadius = 2;
//    self.layer.shadowOpacity = 0.5;
}

-(void)releaseSource
{
    [self removeGestureRecognizer:singleTap];
    singleTap = nil;
}

@end
