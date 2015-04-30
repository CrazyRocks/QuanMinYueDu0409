//
//  PathStyleGestureController.h
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-8.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#define INTO_CENTERCONTROLLER @"into_centerController"
#define OUT_CENTERCONTROLLER    @"out_cengerController"


typedef enum {
    owLeftState = 0,
    owRightState,
    owCenterState,
    owArticleDetailState,
}OWGestureStatus;

@class OWViewController;

@interface PathStyleGestureController : NSObject<UIGestureRecognizerDelegate>
{
    CGPoint startPoint, currentPoint;
    BOOL    isTouchBegin, isTouchMoved, needLeftRightMove;
    
    CGPoint preCenter, homeCenter, nextCenter, centerCtrlViewStartPoint;

    UIPanGestureRecognizer      *pan;
        
    __weak UIViewController *rootController;
    OWViewController *leftController;
    OWViewController *centerController;
    OWViewController *rightController;
}

@property (nonatomic, assign) BOOL canLeftMove;
@property (nonatomic, assign) BOOL canRightMove;
//横划手势是否可用
@property (nonatomic, assign) BOOL  gestureEnabled;

@property (nonatomic, assign) OWGestureStatus currentState;

//左边打开状态时，右滑视图的X轴上的可见区大小
@property (nonatomic, assign) float leftStateVisibleX ;
@property (nonatomic, assign) float rightStateVisibleX;

/*
 类网易新闻交互
 当侧滑打开侧边栏时，中间栏渐缩，关闭侧边栏时，中间栏渐放
 */
@property (nonatomic, assign) BOOL like163Style;

+ (PathStyleGestureController *)sharedInstance;

- (void)configByRootController:(UIViewController *)root leftController:(OWViewController *)lc centerController:(OWViewController *)cc rightController:(OWViewController *)rc;

//取消手势识别
- (void)cancelAnyGestureRecognize;


- (CGPoint)getNextCenter;

- (void)renderMaskView:(UIView *)superView;

- (void)intoLeftControllerView;
- (void)intoLeftOrCenterControllerView;
- (void)intoCenterControllerView;
- (void)intoRightOrCenterControllerView;

//恢复视图状态
- (void)recoverViewStatus;

@end


