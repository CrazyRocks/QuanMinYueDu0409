//
//  OWChooseMask.m
//  OWCoreText
//
//  Created by grenlight on 14-10-10.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWChooseMask.h"

@implementation OWChooseMask

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self _init];
        
    }
    
    return self;
}

-(void)_init
{
    
    self.backgroundColor = [UIColor clearColor];
//    self.backgroundColor = [UIColor blueColor];
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenMe:)];
    recognizer.delegate = self;
    [self addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenMe:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenMe:)];
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
}

-(void)hiddenMe:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.hidden = YES;
        
        if ([self.maskDelegate respondsToSelector:@selector(clearMaskAndChooseArray)]) {
            [self.maskDelegate clearMaskAndChooseArray];
        }

    }
    
    self.hidden = YES;
    
    if ([self.maskDelegate respondsToSelector:@selector(clearMaskAndChooseArray)]) {
        [self.maskDelegate clearMaskAndChooseArray];
    }
}

-(void)hiddenMeQ
{
    self.hidden = YES;
    
    if ([self.maskDelegate respondsToSelector:@selector(clearMaskAndChooseArray)]) {
        [self.maskDelegate clearMaskAndChooseArray];
    }
}



-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
//    NSLog(@"%@",NSStringFromClass([gestureRecognizer.view class]));
    
    if ([gestureRecognizer.view isKindOfClass:[UIImageView class]]) {
        return NO;
    }
    return YES;
}



-(void)showMask
{
    self.hidden = NO;
}




@end
