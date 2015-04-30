//
//  GLMessageView.m
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWMessageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation OWMessageView

static OWMessageView *instance;

- (id)init
{
    CGRect frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        CGPoint center = self.center;
        CGRect panelFrame = CGRectMake(0, 0, 180, 50);
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
        messageLB = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 160, 30)];
        messageLB.backgroundColor = [UIColor clearColor];
        messageLB.textAlignment = NSTextAlignmentCenter;
        [messageLB setNumberOfLines:3];
        messageLB.textColor = [UIColor whiteColor];
        messageLB.font = [UIFont systemFontOfSize:14];
        messageLB.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [panelV addSubview:messageLB];
        [panelV setAlpha:0];
        
        isClosing = NO;
    }
    return self;
}

+(OWMessageView *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OWMessageView alloc]init];
    });
    return instance;
}

-(void)showMessage:(NSString *)msg autoClose:(BOOL)autoClose
{
    isClosing = NO;

    if ([NSThread isMainThread]) {
        [self safelyShowMessage:msg autoClose:autoClose];
    }
    else {
        __weak typeof (self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf safelyShowMessage:msg autoClose:autoClose];
        });
    }
}

- (void)safelyShowMessage:(NSString *)msg autoClose:(BOOL)autoClose
{
    [[[UIApplication sharedApplication]windows][0] addSubview:self];
    
    CGSize pSize = [msg sizeWithFont:messageLB.font constrainedToSize:CGSizeMake(160, 100)
                       lineBreakMode:NSLineBreakByWordWrapping];
    [panelV setFrame:CGRectMake(0, 0, 180, pSize.height + 32)];
    [panelV setCenter:self.center];
    
    [messageLB setText: msg];
    
    [UIView animateWithDuration:0.25 animations:^{
        [panelV setAlpha:1];
    } completion:^(BOOL finished) {
        if(autoClose){
            [self close];
        }
    }];
}


- (void)close
{
    if (!isClosing) {
        isClosing = YES;
        [UIView animateWithDuration:0.25 delay:1.5
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [panelV setAlpha:0];
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         } ];
    }
}

-(void)dealloc
{
    instance = nil;
}

@end
