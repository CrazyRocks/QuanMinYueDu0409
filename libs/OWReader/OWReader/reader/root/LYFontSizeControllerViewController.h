//
//  LYFontSizeControllerViewController.h
//  LYBookStore
//
//  Created by grenlight on 14/6/24.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>
#import "MaskBackgroundView.h"
#import "OWSceneModeSelectionButton.h"

@interface LYFontSizeControllerViewController : XibAdaptToScreenController
{
    
    MaskBackgroundView *mask;
    MaskBackgroundViewHeader *maskHead;
    
    IBOutlet UIView         *panel;
    IBOutlet UIView         *referenceView;
    IBOutlet UIImageView    *bgImageView;
    IBOutlet UIButton       *increaseButton, *decreaseButton;
    
    IBOutlet KWFSegmentedControl *segmentControl;

    __weak IBOutlet OWSceneModeSelectionButton  *sceneBt1, *sceneBt2,*sceneBt3, *sceneBt4;
    OWSceneModeSelectionButton  *currentSelectedBT;
    
    CGPoint panelCenter;
    
    NSInteger       selectedIndex;
    
    BOOL isNeedReload;
    __unsafe_unretained IBOutlet UIButton *dayBtn;
    
    __unsafe_unretained IBOutlet UIButton *neightBtn;
    
    
    
    BOOL isAction;
    
    NSTimer *timer;
}

- (IBAction)increaseFontSize:(id)sender;
- (IBAction)decreaseFontsize:(id)sender;
- (IBAction)fontChange:(id)sender;

- (IBAction)sceneModeChanged:(id)sender;


@end
