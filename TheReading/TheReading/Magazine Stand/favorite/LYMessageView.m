//
//  GLMessageView.m
//  LogicBook
//
//  Created by iMac001 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LYMessageView.h"
#import <QuartzCore/QuartzCore.h>


@implementation LYMessageView

static LYMessageView *instance;

- (id)init
{
    CGRect frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        [[[UIApplication sharedApplication]windows][0]addSubview:self];
        CGPoint center = self.center;
        CGRect panelFrame = CGRectMake(0, 0, 200, 50);
        panelV = [[UIView alloc]initWithFrame:panelFrame];
        [panelV setCenter:center];
        
        panelV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        panelV.layer.cornerRadius = 3;
        panelV.layer.masksToBounds = YES;
        panelV.layer.shadowColor=[UIColor blackColor].CGColor;
        panelV.layer.opaque = 0.3;
        panelV.layer.shadowRadius = 4;
        CGRect shadowRect = panelV.frame;
        shadowRect.origin.y += 6;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
        panelV.layer.shadowPath = path.CGPath;
        
        [self addSubview:panelV];
        messageLB = [[UILabel alloc]initWithFrame:panelFrame];
        messageLB.backgroundColor = [UIColor clearColor];
        messageLB.textAlignment = NSTextAlignmentCenter;
        messageLB.textColor = [UIColor whiteColor];
        messageLB.font = [UIFont systemFontOfSize:14];
        [panelV addSubview:messageLB];
        [panelV setAlpha:0];
    }
    return self;
}

+(LYMessageView *)sharedInstance{
    @synchronized(self){
        if(instance == nil){
            instance = [[LYMessageView alloc]init];
        }
        return instance;
    }
}

-(void)showMessage:(NSString *)msg autoClose:(BOOL)autoClose{
    messageLB.text = msg;    
    [UIView animateWithDuration:0.25 animations:^{
        [panelV setAlpha:1];
    } completion:^(BOOL finished) {
        if(autoClose){
            [UIView animateWithDuration:0.25 delay:1.5 options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [self setAlpha:0];
                             } completion:^(BOOL finished) {
                                [self removeFromSuperview];
                                CFRelease((__bridge CFTypeRef)self);
                             } ];    
        }
    }];
}

-(void)dealloc{
    instance = nil;
//    NSLog(@"GLMessageView dealloc");
}

@end
