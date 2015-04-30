//
//  ShelfViewController+SlideMenu.m
//  LYBookStore
//
//  Created by grenlight on 14/8/26.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "ShelfViewController+SlideMenu.h"

@implementation ShelfViewController (SlideMenu)

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStatePossible) {
        return;
    }
    else if (gesture.state == UIGestureRecognizerStateBegan) {
        [self slideBegain:gesture];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self slideChanged:gesture];
    }
    else if (gesture.state == UIGestureRecognizerStateFailed) {
        [self slideCanceled:gesture];
    }
    else {
        [self slideStopped:gesture];
    }
}

- (void)slideBegain:(UIPanGestureRecognizer *)gesture
{
    [self hideFilterRetainMask];
    
    touchStart = [gesture translationInView:self.view];
    self.touchMoving = NO;
    
    if (self.isMenuOpened) {
        menuOriginalCenter = self.slideMenuController.view.center;
    }
    else {
        if (touchStart.x > 40) {
            [gesture cancel];
        }
        else {
            [self createSlideMenuView];
            menuOriginalCenter = menuHomeCenter;
        }
    }
}

- (void)slideChanged:(UIPanGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture translationInView:self.view];
    if (!self.isMenuOpened && !self.touchMoving &&
        (abs(touchPoint.x - touchStart.x) < abs(touchPoint.y - touchStart.y))) {
        [gesture cancel];
    }
    else {
        self.touchMoving = YES;
        float offsetX = touchPoint.x - touchStart.x;
        float centerX = menuOriginalCenter.x + offsetX;
        if (centerX > appWidth/2.0f)
            centerX = appWidth/2.0f;
        
        [UIView animateWithDuration:0.15 animations:^{
            self.slideMenuController.view.center = CGPointMake(centerX, menuOriginalCenter.y);
        }];
    }
}

- (void)slideStopped:(UIPanGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture translationInView:self.view];
    if (self.isMenuOpened) {
        if (touchStart.x - touchPoint.x > 20) {
            [self closeSlideMenu:nil];
        }
        else {
            [self openSlideMenu:nil];
        }
    }
    else {
        if (touchPoint.x - touchStart.x > 64) {
            [self openSlideMenu:nil];
        }
        else {
            [self closeSlideMenu:nil];
        }
    }
}

- (void)slideCanceled:(UIPanGestureRecognizer *)gesture
{
    [gesture cancel];
}

- (void)createSlideMenuView
{
    if (![self.slideMenuController isViewLoaded]) {
        self.slideMenuController.view.center = menuHomeCenter;
    }
    [self.view insertSubview:self.slideMenuController.view aboveSubview:filterBGMask];
    
    if (CGRectGetMinX(self.slideMenuController.view.frame) < -(appWidth-10)) {
        [self.slideMenuController updateFrostedView];
    }
}

- (void)openSlideMenu:(id)sender
{
    self.isMenuOpened = YES;
    [self fadeInMaskView];
    [self createSlideMenuView];
    [OWAnimator spring:self.slideMenuController.view toPosition:menuSchoolCenter];
}

- (void)closeSlideMenu:(id)sender
{
    self.isMenuOpened = NO;
    [OWAnimator spring:self.slideMenuController.view toPosition:menuHomeCenter];
    [self fadeOutMaskView];
}

@end
