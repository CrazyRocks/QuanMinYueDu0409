//
//  LYBookPageScrollController.h
//  LYBookStore
//
//  Created by grenlight on 14-4-28.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>
#import <OWCoreText/JRDigestModel.h>
//#import "NotesViewController.h"
#import "BookDigest.h"
#import "VideoViewController.h"

#import "MusicControlBtn.h"

#import "AudioViewController.h"


@class LYBookSliderController, LYBookNavigationBarController;

@interface LYBookPageRootController : loadViewAdaptToScreenController<MusicControlBtnDelegate,AudioViewControllerDelegate>
{
    //是否正在改变字体字号设置
    BOOL isFontChanging;
    
//    UIPanGestureRecognizer *twoPan;
    
}
@property (nonatomic, retain) AudioViewController *audioCtrl;
@property (nonatomic, retain) MusicControlBtn *musicBtn;
@property (nonatomic, retain) VideoViewController *video;
//@property (nonatomic, retain)    NotesViewController *noteEditor;
@property (nonatomic, strong)    LYBookSliderController *sliderController;
@property (nonatomic, strong)    LYBookNavigationBarController   *navBarController;

- (void)hideAccessory;

@end
