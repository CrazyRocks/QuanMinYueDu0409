//
//  WYRootController_iPad.m
//  TheReading
//
//  Created by grenlight on 15/1/12.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "WYRootController_iPad.h"
#import "WYMainMenuController.h"
#import "WYContentCanvasController.h"
#import "LYRightSlideControllerViewController.h"

@interface WYRootController_iPad ()
{
    WYMainMenuController        *menuController;
    WYContentCanvasController   *canvasController;
    
    LYRightSlideControllerViewController *rightCtrl;

}
@end

@implementation WYRootController_iPad

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!menuController) {
        canvasController = [[WYContentCanvasController alloc] init];
        [self addChildViewController:canvasController];
        
        menuController = [[WYMainMenuController alloc] init];
        menuController.contentCanvasController = canvasController;
        [self addChildViewController:menuController];
    }
    [self.view addSubview:menuController.view];
    canvasController.view.frame = CGRectMake(64, 0, appWidth-64, appHeight);
    [self.view addSubview:canvasController.view];
}

- (void)intoAccountView
{
    if (!rightCtrl) {
        rightCtrl = [[LYRightSlideControllerViewController alloc] init];
        rightCtrl.contentCanvasController = canvasController;
        [self addChildViewController:rightCtrl];
    }
    CGPoint to ;
    BOOL isquit = YES;
    if ([rightCtrl isViewLoaded] && rightCtrl.view.superview) {
        to = CGPointMake(appWidth + CGRectGetWidth(rightCtrl.view.frame)/2.0f, appHeight/2.0f);
    }
    else {
        isquit = NO;
        CGRect f = rightCtrl.view.frame;
        f.size.height = appHeight;
        f.size.width = appWidth;
        rightCtrl.view.frame = f;
        
        to = CGPointMake(appWidth - CGRectGetWidth(f)/2.0f, appHeight/2.0f);
        
        CGPoint from = CGPointMake(appWidth + CGRectGetWidth(f)/2.0f, appHeight/2.0f);
        rightCtrl.view.center = from;
        [self.view addSubview:rightCtrl.view];
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        rightCtrl.view.center = to;
    } completion:^(BOOL finished) {
        if (isquit && finished) {
            [rightCtrl.view removeFromSuperview];
        }
    }];
}

@end
