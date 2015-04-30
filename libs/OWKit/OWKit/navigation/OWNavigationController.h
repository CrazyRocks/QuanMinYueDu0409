//
//  UINavigationController+SlideEffect.h
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-23.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPanGestureRecognizer+Cancel.h"

typedef enum {
    owNavAnimationTypeBasic,
    owNavAnimationTypeSlideFromLeft,
    owNavAnimationTypeSlideFromRight,
    owNavAnimationTypeSlideFromBottom,
    owNavAnimationTypeSlideToLeft,
    owNavAnimationTypeSlideToRight,
    owNavAnimationTypeSlideToBottom,
    owNavAnimationTypeDegressPathEffect,
}OWNavigationAnimationType;

@class OWViewController;

@interface OWNavigationController:UIViewController<UIGestureRecognizerDelegate>
{
    OWViewController *fromController, *toController;
    CGRect frame;
    
    UIPanGestureRecognizer      *pan;
    CGPoint startPoint, currentPoint;
    CGPoint touchHomeCenter, touchSchoolCenter;
    BOOL    isTouchBegin, isAnimating;
    
    UIView  *mask;
    
}
//是否可滑动
@property (nonatomic, assign) BOOL canMoveByPanGesture;

+ (OWNavigationController *)sharedInstance;

- (UIViewController *)topViewController;

- (void)releaseAllControllers;

- (void)setRooController:(OWViewController *)viewController;
- (void)pushViewController:(OWViewController *)viewController;
- (void)pushViewController:(OWViewController *)viewController animated:(BOOL)animated;
- (void)pushViewController:(OWViewController *)viewController
             animationType:(OWNavigationAnimationType)animationType;

- (void)popViewController;

/*
 不以导航动画的形式弹出，
 duration: 延时弹出将要弹出的controller，用于配合此controller上的定制动画
 */
- (void)popViewControllerWithNoneAnimation:(float)duration;

- (void)popViewController:(OWNavigationAnimationType)animationType;

//pop多次以返回到特定的层级
- (void)popByNumberOfTimes:(NSInteger)times
             animationType:(OWNavigationAnimationType)animationType;

- (void)popToViewController:(Class)className
             animationType:(OWNavigationAnimationType)animationType;

@end
