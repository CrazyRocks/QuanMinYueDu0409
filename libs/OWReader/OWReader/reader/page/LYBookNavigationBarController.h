//
//  LYBookNavigationBarController.h
//  LYBookStore
//
//  Created by grenlight on 14-4-28.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>
#import "OWBookButton.h"

@interface LYBookNavigationBarController : OWViewController
{
    CGPoint    homeCenter, schoolCenter;
    
    __weak IBOutlet OWBookButton *fontSizeButton, *returnButton, *catButton, *sceneModeButton;
    __unsafe_unretained IBOutlet OWBookButton *searchBtn;
}

- (void)show;
- (void)hide;

- (IBAction)changeSceneMode:(id)sender;

-(IBAction)addSearch:(id)sender;


@end
