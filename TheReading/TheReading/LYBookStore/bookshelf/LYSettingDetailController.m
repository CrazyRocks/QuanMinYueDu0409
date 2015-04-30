//
//  LYSettingDetailController.m
//  LYBookStore
//
//  Created by grenlight on 14/8/28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYSettingDetailController.h"

@interface LYSettingDetailController ()

@end

@implementation LYSettingDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setTitle:(NSString *)title
{
    [navBar setTitle:title];
}

- (void)comeback:(id)sender
{
    [[OWNavigationController sharedInstance] popByNumberOfTimes:1
                                                  animationType: owNavAnimationTypeDegressPathEffect];
}

- (void)close:(id)sender
{
    [[OWNavigationController sharedInstance] popByNumberOfTimes:2
                                                  animationType: owNavAnimationTypeSlideToBottom];
}

@end
