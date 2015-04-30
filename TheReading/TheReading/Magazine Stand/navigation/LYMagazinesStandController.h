//
//  NavPanelViewController.h
//  PublicLibrary
//
//  Created by grenlight on 13-12-5.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrostedGlassViewController.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

typedef enum {
    lyPanelState,
    lySearchState,
    lyTabBarState,
}MagNavPanelState;


@interface LYMagazinesStandController : XibAdaptToScreenController<UITabBarDelegate,
UIAlertViewDelegate>
{
    __weak IBOutlet  UITabBar    *tabBar;
    
    __weak IBOutlet  UIView        *contentView;
    
    CGPoint sfvHomeCenter, sfvInWindowHomeCenter;
   
    float    startPointY, currentPointY;
    
    CADisplayLink              *displayLink;
    
    UITabBarItem *selectedTabBarItem;
}
@property (nonatomic, strong) LYMenuData *menu;

@property (nonatomic, copy) ReturnMethod returnToPreController;

//缓存搜索结果及搜索关键字，退出搜索视图状态
- (void)outSearchState;

//导航进下一级时，先移除模糊效果层，
- (void)navigateOutBegin;

@end
