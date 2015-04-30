//
//  WaterDropletRefresh.h
//  RefreshEffect
//
//  Created by grenlight on 14-1-1.
//  Copyright (c) 2014年 OWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterDropletView.h"
#import "OWBlockDefine.h"


@interface GLWaterDropletRefresh : UIView
{
    WaterDropletView *dropletView;
    
//    水滴已经下落，则视图固定不动，完成刷新后自动收回，否则跟随滚动视图滚动
    BOOL            isDropped;
//    是否可以跟随滚动视图移动？
//    isDropped=YES 时，如果视图已经复位且滚动视图的滚动发生在复位之前，则不再响应本次滚动
    BOOL            canMoveable;
    
    CGPoint normalCenter, refreshingCenter;
    
    UIView  *bg;

}

@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic,assign)__unsafe_unretained UIScrollView *owner;

@property (nonatomic, copy) GLNoneParamBlock refreshBlock;

- (id)initWithWidth:(float)w;

//滚动视图开始滚动，在此时判断是否能能移动视图，
- (void)ownerTouchBegan;

- (void)dropByOffsetY:(float)offsetY;

- (void)stopAnimating;


@end
