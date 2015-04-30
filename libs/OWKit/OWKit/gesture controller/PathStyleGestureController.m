//
//  PathStyleGestureController.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-8.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "PathStyleGestureController.h"
#import "OWViewController.h"
#import "UIPanGestureRecognizer+Cancel.h"
#import "OWColor.h"

#define CONTENTVIEW_SCALE 0.95
#define LIKE163_SCALE 0.77

#define RIGHTSTATE_VISIBLESIZE_X [[PathStyleGestureController sharedInstance] rightStateVisibleX]
#define LEFTSTATE_VISIBLESIZE_X [[PathStyleGestureController sharedInstance] leftStateVisibleX]

@interface PathStyleGestureController ()
{
    UIView                  *transformView;
    
    UIView                  *mask;
    
}

@end

@implementation PathStyleGestureController

@synthesize currentState;
@synthesize like163Style;

+ (PathStyleGestureController *)sharedInstance
{
    static PathStyleGestureController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PathStyleGestureController alloc] init];
    });
    return instance;
}

- (void)configByRootController:(UIViewController *)root leftController:(OWViewController *)lc centerController:(OWViewController *)cc rightController:(OWViewController *)rc
{
    rootController = root;
    leftController = lc;
    centerController =cc;
    rightController = rc;
    [root addChildViewController:leftController];
    [root addChildViewController:centerController];
    [root addChildViewController:rightController];

    
    [self defaultSetting];
}

- (void)defaultSetting
{
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    pan.delegate = self;
    
    self.canLeftMove = YES;
    self.canRightMove = YES;
    self.leftStateVisibleX = 120;
    self.rightStateVisibleX = 63;
    self.gestureEnabled = YES;
    
    like163Style = NO;
}

- (void)configView
{
    if (!centerController.view.superview) {
        [rootController.view addSubview:rightController.view];
        [rootController.view addSubview:leftController.view];
        centerController.view.frame = CGRectMake(0, 0, appWidth, appHeight);
        [rootController.view addSubview:centerController.view];
        
        preCenter = nextCenter = homeCenter = centerController.view.center;
        preCenter.x -= (appWidth - RIGHTSTATE_VISIBLESIZE_X);
        nextCenter.x += (appWidth - LEFTSTATE_VISIBLESIZE_X);
        
        pan.delegate = centerController;
    }
}

- (void)recoverViewStatus
{
    if (currentState == owLeftState)
        [self intoLeftControllerView];
    
    else if (currentState == owRightState)
        [self intoRightControllerView];
}

- (CGPoint)getNextCenter
{
    return nextCenter;
}

- (void)renderMaskView:(UIView *)superView
{
    mask =[[UIView alloc] initWithFrame:centerController.view.bounds];
    mask.backgroundColor = [OWColor colorWithHex:0x000000 alpha:0.85];
    mask.userInteractionEnabled = NO;
    [superView addSubview:mask];
}

#pragma mark --gesture

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (!self.gestureEnabled && currentState == owCenterState) {
        return;
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
        [self gestureRecognizeBegan:gestureRecognizer];
    
    else if([gestureRecognizer state] == UIGestureRecognizerStateChanged)
        [self gestureRecognizeChanged:gestureRecognizer];
    
    else if([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
            [gestureRecognizer state] == UIGestureRecognizerStateCancelled)
        [self gestureRecognizeEnded:gestureRecognizer];
}

- (void)gestureRecognizeBegan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (!self.canRightMove && !self.canLeftMove) {
        [gestureRecognizer cancel];
        return;
    }
    
    isTouchBegin = YES;
    isTouchMoved = NO;
    startPoint = [gestureRecognizer translationInView:[UIApplication sharedApplication].keyWindow];
    centerCtrlViewStartPoint = centerController.view.center;
}

- (void)gestureRecognizeChanged:(UIPanGestureRecognizer *)gestureRecognizer
{
    currentPoint = [gestureRecognizer translationInView:[UIApplication sharedApplication].keyWindow];
    
    isTouchMoved = YES;
    if (isTouchBegin) {
        isTouchBegin = NO;
        needLeftRightMove = NO;
        
        if (abs(currentPoint.x - startPoint.x) > abs(currentPoint.y - startPoint.y)) {
            if (!self.canRightMove && currentPoint.x - startPoint.x >0) {
                [gestureRecognizer cancel];
                return;
            }
            if (!self.canLeftMove && currentPoint.x - startPoint.x < 0) {
                [gestureRecognizer cancel];
                return;
            }
            needLeftRightMove = YES;
            [self moveCenterControllerView:(currentPoint.x - startPoint.x)];
        }
     }
    else {
        if (needLeftRightMove) 
            [self moveCenterControllerView:(currentPoint.x - startPoint.x)];
    }
}

- (void)gestureRecognizeEnded:(UIPanGestureRecognizer *)gestureRecognizer
{
    float moveDistance = centerController.view.center.x - centerCtrlViewStartPoint.x;
    
    if (CGPointEqualToPoint(homeCenter, centerCtrlViewStartPoint)) {
        if (moveDistance > RIGHTSTATE_VISIBLESIZE_X) {
            [self intoLeftControllerView];
        }
        else if (moveDistance < -RIGHTSTATE_VISIBLESIZE_X) {
            [self intoRightControllerView];
        }
        else {
            [self intoCenterControllerView];
        }
    }
    else if (CGPointEqualToPoint(preCenter, centerCtrlViewStartPoint)) {
        
        if (moveDistance > RIGHTSTATE_VISIBLESIZE_X) {
            [self intoCenterControllerView];
        }
        else {
            [self intoRightControllerView];
        }
    }
    else {
        if (moveDistance < -RIGHTSTATE_VISIBLESIZE_X) {
            [self intoCenterControllerView];
        }
        else {
            [self intoLeftControllerView];
        }
    }
}

#pragma mark --move
- (void)moveCenterControllerView:(float)offsetX
{
    CGPoint viewCenter = centerCtrlViewStartPoint;
    viewCenter.x += offsetX;
    [mask setHidden:NO];
    
    if (!rightController && viewCenter.x < homeCenter.x)
        return;
    
    if (viewCenter.x > homeCenter.x) {
        [rightController.view setHidden:YES];
        [leftController.view setHidden:NO];
        transformView = leftController.view;
    }
    else {
        [rightController.view setHidden:NO];
        [leftController.view setHidden:YES];
        transformView = rightController.view;
    }
    [centerController.view setCenter:viewCenter];
    float rate = abs(homeCenter.x - viewCenter.x)/(appWidth-LEFTSTATE_VISIBLESIZE_X);
    [mask setAlpha:0.9 - 0.9*(rate)];
    if (like163Style) {
        float scale = 1 - (1.0f-LIKE163_SCALE)*rate;
        centerController.view.transform = CGAffineTransformMakeScale(scale, scale);
    }
    else {
        float scale = CONTENTVIEW_SCALE + (1-CONTENTVIEW_SCALE)*rate;
        transformView.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)intoLeftControllerView
{
    [self configView];
//    if (!self.canRightMove) {
//        return;
//    }
    
    [rightController.view setHidden:YES];
    [leftController.view setHidden:NO];
    
    if ([centerController respondsToSelector:@selector(intoFreeze)]) {
        [centerController intoFreeze];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [centerController.view setCenter:nextCenter];
        [mask setAlpha:0];
        if (like163Style) {
            centerController.view.transform = CGAffineTransformMakeScale(LIKE163_SCALE, LIKE163_SCALE);
        }
        else {
            transformView.transform = CGAffineTransformMakeScale(1, 1);
        }
    } completion:^(BOOL finished) {
        [mask setHidden:YES];
        currentState = owLeftState;
        [centerController.view addGestureRecognizer:pan];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChannelState" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:OUT_CENTERCONTROLLER object:nil];
}

- (void)intoCenterControllerView
{
    [self configView];
    [UIView animateWithDuration:0.2 animations:^{
        [centerController.view setCenter:homeCenter];
        [mask setAlpha:1];
        if (like163Style) {
            centerController.view.transform = CGAffineTransformMakeScale(1, 1);
        }
        else {
            transformView.transform = CGAffineTransformMakeScale(CONTENTVIEW_SCALE, CONTENTVIEW_SCALE);
        }
    } completion:^(BOOL finished) {
        if ([centerController respondsToSelector:@selector(outFreeze)]) {
            [centerController outFreeze];
        }
        
        if (finished) {
            currentState = owCenterState;
            [mask setHidden:YES];
        }
        [centerController.view removeGestureRecognizer:pan];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ContentState" object:nil];
    
}

- (void)intoRightControllerView
{
    [self configView];
    [rightController.view setHidden:NO];
    [leftController.view setHidden:YES];
    [UIView animateWithDuration:0.25
                     animations:^{
                         [centerController.view setCenter:preCenter];
                         [mask setAlpha:0];
                         if (like163Style) {
                             centerController.view.transform = CGAffineTransformMakeScale(LIKE163_SCALE, LIKE163_SCALE);
                         }
                         else {
                             rightController.view.transform = CGAffineTransformMakeScale(1, 1);
                         }
                     }
                     completion:^(BOOL finished) {
                         currentState = owRightState;
                         [mask setHidden:YES];
                         [centerController.view addGestureRecognizer:pan];
                     }];
    [[NSNotificationCenter defaultCenter] postNotificationName:OUT_CENTERCONTROLLER object:nil];

}

- (void)intoLeftOrCenterControllerView
{
    [self configView];
    CGPoint targetCenter = centerController.view.center;
    if (targetCenter.x > homeCenter.x) 
        [self intoCenterControllerView];
    else 
        [self intoLeftControllerView];
}

- (void)intoRightOrCenterControllerView
{
    [self configView];
    CGPoint targetCenter = centerController.view.center;
    if (targetCenter.x < homeCenter.x)
        [self intoCenterControllerView];
    else
        [self intoRightControllerView];
}

- (void)cancelAnyGestureRecognize
{
    [pan cancel];
}

#pragma mark gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    else {
        return YES;
    }
}


@end
