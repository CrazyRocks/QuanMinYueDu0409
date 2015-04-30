//
//  LYFontSizeControllerViewController.m
//  LYBookStore
//
//  Created by grenlight on 14/6/24.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYFontSizeControllerViewController.h"
#import "LYBookConfig.h"
#import <OWKit/OWKit.h>
#import "LYBookRenderManager+Async.h"

#import "LYBookHelper.h"
#import "LYBookSceneManager.h"

@interface LYFontSizeControllerViewController ()

@end

@implementation LYFontSizeControllerViewController

- (id)init
{
    self = [super initWithNibName:@"LYFontSizeControllerViewController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        panelCenter = CGPointZero;
        selectedIndex = 0;
    }
    return self;
}

#pragma mark 动作计时器方法
-(void)actionTimer
{
    isAction = NO;
    timer = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    panel.backgroundColor = [UIColor clearColor];
    
    if (CGPointEqualToPoint(panelCenter, CGPointZero)) {
        panelCenter = panel.center;
    }
    referenceView.backgroundColor = [UIColor clearColor];
    panel.alpha = 0;
    panel.center = referenceView.center;
   
    mask = [[MaskBackgroundView alloc]initWithFrame:CGRectMake(0, 10, panel.bounds.size.width, panel.bounds.size.height-10)];
    maskHead = [[MaskBackgroundViewHeader alloc]initWithFrame:CGRectMake(0, 0, panel.bounds.size.width, 10) withStart:0.95f];
    
    [panel insertSubview:maskHead atIndex:0];
    [panel insertSubview:mask atIndex:0];
    
    sceneBt1.sceneName = @"cce6cd";
    sceneBt2.sceneName = @"dbd8d3";
    sceneBt3.sceneName = @"ecd68d";
    sceneBt4.sceneName = @"f9f1dc";
    
    [self loadSceneMode];
        
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tap];
    
    [OWAnimator basicAnimate:panel toScale:CGPointMake(0.1, 0.1) duration:0.01];
    [self performSelector:@selector(openPanel) withObject:nil afterDelay:0.03];
}

- (void)loadSceneMode
{
    UIStyleObject *fontStyle = [LYBookHelper styleNamed:@"字体SegmentedControl"];
    [segmentControl setStyle:fontStyle];
    
//    bgImageView.image = [LYBookHelper imageNamed:@"fontSize_panel"];
    [increaseButton setImage:[LYBookHelper imageNamed:@"fontSize_bigger"]
                    forState:UIControlStateNormal];
    [decreaseButton setImage:[LYBookHelper imageNamed:@"fontSize_smaller"]
                    forState:UIControlStateNormal];
    
    NSString *sceneString = [[LYBookSceneManager manager] sceneMode];
    if ([sceneBt1.sceneName isEqualToString:sceneString]) {
        currentSelectedBT = sceneBt1;
    }
    else if ([sceneBt2.sceneName isEqualToString:sceneString]) {
        currentSelectedBT = sceneBt2;
    }
    else if ([sceneBt3.sceneName isEqualToString:sceneString]) {
        currentSelectedBT = sceneBt3;
    }
    else if ([sceneBt4.sceneName isEqualToString:sceneString]) {
        currentSelectedBT = sceneBt4;
    }
    currentSelectedBT.selected = YES;
    
    [self initFontSegmentedControl];
}

- (void)tapped:(UIGestureRecognizer *)gesture
{
    self.view.userInteractionEnabled = NO;
    CGPoint location = [gesture locationInView:self.view];
    if (!CGRectContainsPoint(panel.frame, location)) {
        
//        if (isNeedReload) {
//            
            [self closePanel];
//
//        }else{
//            
//            [self closePanelUnRenderBook];
//        }
    }
    else {
        self.view.userInteractionEnabled = YES;
    }
}

- (void)updateButtonState
{
    float fs = [LYBookSceneManager manager].fontSizeScale;

    if (fs >= 1.3) {
        increaseButton.enabled = NO;
    }
    else {
        increaseButton.enabled = YES;
    }
    if (fs > 0.7) {
        decreaseButton.enabled = YES;
    }
    else {
        decreaseButton.enabled = NO;
    }
}

- (void)increaseFontSize:(id)sender
{
    
    float fs = [LYBookSceneManager manager].fontSizeScale;
    if (fs < 1.3) {
        self.view.userInteractionEnabled = NO;

        fs += 0.1;
        [self changeFontSizeScale:fs];
    }
    
    isNeedReload = YES;
    
}

- (void)decreaseFontsize:(id)sender
{
    float fs = [LYBookSceneManager manager].fontSizeScale;
    if (fs > 0.7) {
        self.view.userInteractionEnabled = NO;

        fs -= 0.1;
        [self changeFontSizeScale:fs];
    }
    
    isNeedReload = YES;
}

- (void)changeFontSizeScale:(float)scale
{
    [[LYBookSceneManager manager] setFontSizeScale:scale];
    [[LYBookRenderManager sharedInstance] reRenderCurrentPage];
    
    [self updateButtonState];
    self.view.userInteractionEnabled = YES;
}

#pragma mark font segmented
- (void)initFontSegmentedControl
{
    NSString *fn = [LYBookSceneManager manager].fontName;
    selectedIndex = 0;
    if ([fn isEqualToString:@"SIL-Kai-Reg-Jian"]) {
        selectedIndex = 0;
    }
    else if ([fn isEqualToString:@"SimHei"]) {
        selectedIndex = 1;
    }
    else if ([fn isEqualToString:@"SimSun"]) {
        selectedIndex = 2;
    }
    else if ([fn isEqualToString:@"FangSong"]) {
        selectedIndex = 3;
    }
    [segmentControl setSelectedSegmentIndex:selectedIndex];
}

- (void)fontChange:(KWFSegmentedControl *)sender
{
    if (selectedIndex == sender.selectedSegmentIndex) {
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    selectedIndex = sender.selectedSegmentIndex;
    
    NSString *fontName;
    switch (sender.selectedSegmentIndex) {
        case 0:
            fontName = @"SIL-Kai-Reg-Jian";
            break;
        case 1:
            fontName = @"SimHei";
            break;
            
        case 2:
            fontName = @"SimSun";
            break;
            
        default:
            fontName = @"FangSong";
            break;
    }
    
    [[LYBookSceneManager manager] setFontName:fontName];
    
    [[LYBookRenderManager sharedInstance] reRenderCurrentPage];
    
    [LYBookRenderManager sharedInstance].isChangeFont = YES;
    
     [self performSelector:@selector(interactionEnable) withObject:nil afterDelay:0.5];
}

- (void)interactionEnable
{
    self.view.userInteractionEnabled = YES;
}

#pragma mark scene mode
- (void)sceneModeChanged:(OWSceneModeSelectionButton *)sender
{
    if (currentSelectedBT == sender) {
        return;
    }
    currentSelectedBT.selected = NO;
    sender.selected = YES;
    currentSelectedBT = sender;
    
    self.view.userInteractionEnabled = NO;
    [[LYBookSceneManager manager] changeSceneMode:sender.sceneName];
    [self performSelector:@selector(interactionEnable) withObject:nil afterDelay:0.5];
}


#pragma mark view animation
- (void)openPanel
{
    [OWAnimator spring:panel toScale:1];
    [OWAnimator basicAnimate:panel toPosition:panelCenter duration:0.2];
    [OWAnimator basicAnimate:panel toAlpha:1 duration:0.2];
    
    [self updateButtonState];
    
    panel.alpha = 1.0f;
    
    self.view.userInteractionEnabled = YES;
}

- (void)closePanel
{
    isNeedReload = NO;
    
    [OWAnimator basicAnimate:panel toScale:CGPointMake(0.1, 0.1) duration:0.2];
    [OWAnimator basicAnimate:panel toPosition:referenceView.center duration:0.2];
    [OWAnimator basicAnimate:panel toAlpha:0 duration:0.15];
    [self performSelector:@selector(releaseView) withObject:nil afterDelay:0.3];
    
    panel.alpha = 0.0f;
    
    [[LYBookRenderManager sharedInstance] performSelector:@selector(reRenderBook) withObject:nil afterDelay:0.1];
}


- (void)releaseView
{
    [self.view removeFromSuperview];
    self.view = nil;
    
}
@end
