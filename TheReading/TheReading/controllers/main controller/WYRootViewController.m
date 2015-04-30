//
//  WYRootViewController.m
//  PublicLibrary
//
//  Created by grenlight on 14-1-22.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "WYRootViewController.h"
#import "WYMainMenuController.h"
#import "WYContentCanvasController.h"
#import <CoreMotion/CoreMotion.h>
#import "LYRightSlideControllerViewController.h"

@interface WYRootViewController ()
{
    PathStyleGestureController *gestureController;
    WYMainMenuController        *menuController;
    WYContentCanvasController   *canvasController;
    LYRightSlideControllerViewController    *rightController;
    CMMotionManager         *motionManager;

}
@end

@implementation WYRootViewController

- (id)init
{
    if (self=[super init]) {
        gestureController = [PathStyleGestureController sharedInstance];
        canvasController = [[WYContentCanvasController alloc] init];

        menuController = [[WYMainMenuController alloc] init];
        menuController.contentCanvasController = canvasController;

//        menuController = [[UIViewController alloc] init];
//        canvasController = [[UIViewController alloc] init];
//        rightController = [[UIViewController alloc] init];
        rightController = [[LYRightSlideControllerViewController alloc] init];
        rightController.contentCanvasController = canvasController;
        
        [gestureController configByRootController:self
                                   leftController:menuController
                                 centerController:canvasController
                                  rightController:rightController];
        
        [gestureController setLeftStateVisibleX:120];
        [gestureController setRightStateVisibleX:65];
        gestureController.like163Style = NO;
        gestureController.gestureEnabled = NO;
        
//        //设备旋转方向
//        motionManager = [[CMMotionManager alloc] init];
//        if (motionManager.deviceMotionAvailable) {
//            motionManager.deviceMotionUpdateInterval = 0.1;
//            
//            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motionData, NSError *error) {
//                if ([self isViewLoaded] && (self.view.window != nil || NULL != self.view.superview)) {
//                    if (motionData.gravity.x < -0.8 && gestureController.currentState == owLeftState) {
//                        [gestureController intoCenterControllerView];
//                    }
//                    else if (motionData.gravity.x > 0.8 && gestureController.currentState == owCenterState) {
//                        [gestureController intoLeftControllerView];
//                    }
//                }
//            }];
//        }
                
        [[LYSyncManager sharedInstance] startSync];
    }
    return self;
}

- (void)updateStatusBarStyle
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    [gestureController intoCenterControllerView];
    [self updateStatusBarStyle];
}

@end
