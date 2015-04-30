//
//  PageImage.m
//  DragonSourceEPUB
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.

#import "PageImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation PageImage


-(id)initWithFrame:(CGRect)frame{
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

-(void)onTap:(UIGestureRecognizer *)gesture{
//    self.layer.shadowRadius = 0;
//    self.layer.shadowOpacity = 0.0;

    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self,@"image",self.superview,@"pageView", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"PageImageToFullScreen" object:nil userInfo:dic];
    
    [self removeGestureRecognizer:singleTap];
}

-(void)addTapGesture{
    [self addGestureRecognizer:singleTap];
//    self.layer.shadowRadius = 2;
//    self.layer.shadowOpacity = 0.5;
}

-(void)releaseSource{
    [self removeGestureRecognizer:singleTap];
    singleTap = nil;
}

@end
