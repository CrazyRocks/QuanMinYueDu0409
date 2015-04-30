//
//  SettingTableFooter.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-11-23.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "SettingTableFooter.h"

@implementation SettingTableFooter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}


-(IBAction)loginOut:(id)sender
{
    if (self.delegate) {
        [self.delegate settingTableFooterTapped];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
