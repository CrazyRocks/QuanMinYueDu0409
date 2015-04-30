//
//  OWShakeView.m
//  ShakeUIView
//
//  Created by 龙源 on 13-10-29.
//  Copyright (c) 2013年 suraj. All rights reserved.
//

#import "OWShakeView.h"

@implementation OWShakeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    
    isShaking = NO;
    isInPressing = NO;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self addGestureRecognizer:longPressGesture];
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setFrame:CGRectMake(-43, -43, 110, 110)];
    [deleteButton setImage:[UIImage imageNamed:@"deleteCollectionItem_bt_normal"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setAlpha:0];
}

- (void)dealloc
{
    self.delegate = nil;
}

- (void)startShake
{
    if (isInPressing) return;
    
    isShaking = YES;
    scale = 0.9;
    
    //生成一个－5 ～ 5 之间的旋转角度值
    void(^calculateDegress)() = ^{
        shakeDegress = (arc4random() % 11) - 5;
    };
    calculateDegress();
    
    if (shakeDegress == 0)
        calculateDegress();
    
    [self addSubview:deleteButton];
    [UIView animateWithDuration:0.2 animations:^{
        [deleteButton setAlpha:1];
    }];
    
    if (self.superview.superview) {
        [self.superview.superview bringSubviewToFront:deleteButton];
    }
    CGAffineTransform trancform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-shakeDegress));
    trancform = CGAffineTransformScale(trancform, scale, scale);
    
    void(^completion)(BOOL) = ^(BOOL finished){
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                         animations:^ {
                             self.transform = CGAffineTransformRotate(trancform, RADIANS(shakeDegress));
                         }
                         completion:NULL
         ];
    };
    
    [UIView animateWithDuration:0.15 animations:^{
        self.transform = trancform;
    } completion:completion];
    
}

- (void)stopShake
{
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
                     animations:^ {
                         self.transform = CGAffineTransformIdentity;
                         [deleteButton setAlpha:0];
                     }
                     completion:^(BOOL bl){
                         isShaking = NO;
                     }
     ];
}

- (void)pressScale:(float)scaleSize
{
    [UIView animateWithDuration:0.2 animations:^{
        [deleteButton setAlpha:0];
    }];

    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
                     animations:^ {
                         self.transform = CGAffineTransformScale(CGAffineTransformIdentity,scaleSize, scaleSize);
                     }
                     completion:^(BOOL bl){
                         if (scaleSize == 1 && isShaking)
                             [self startShake];
                     }
     ];
}

#pragma mark button && gesture event
- (void)deleteButtonTapped:(UIButton *)sender
{
    if (self.delegate)
        [self.delegate shakeView:self delete:sender];
}

- (void)longPressed:(UIGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self pressScale:1.05];
            isInPressing = YES;

            if (!isShaking) {
                if (self.delegate)
                    [self.delegate shakeView_longPressed];
            }
        }
            break;
            
        default:
        {
            isInPressing = NO;
            isShaking = YES;
            
            [self pressScale:1];
        }
            break;
    }
   
}
@end
