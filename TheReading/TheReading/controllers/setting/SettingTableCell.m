//
//  SettingTableCell.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-30.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "SettingTableCell.h"
#import <LYService/LYService.h>

@implementation SettingTableCell
@synthesize customLable;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIView *selectedBG = [[UIView alloc] initWithFrame:self.bounds];
    selectedBG.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView = selectedBG;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setImageView:(UIImage *)image
{
    [customSwitch setHidden:YES];
    [customImageView setHidden:YES];
    [rightLable setHidden:YES];

    if(!(image == nil))
    {
        [customImageView setHidden:NO];
        customImageView.image = image;
    }
}

-(void)setSwitchByUserDefaultKey:(NSString *)key
{
    [rightLable setHidden:YES];
    [customImageView setHidden:YES];
    [customSwitch setHidden:NO];
    
    userDefaultKey = key;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [customSwitch setOn:[userDefaults boolForKey:userDefaultKey]];
}

-(void)showRightLable
{
    [customImageView setHidden:YES];
    [customSwitch setHidden:YES];
    [rightLable setHidden:NO];
    
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    [rightLable setText:[NSString stringWithFormat:@"%@(0x%x)",version, 20141126]];
}

-(IBAction)switchValueChanged:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:customSwitch.on forKey:userDefaultKey];
    [userDefaults synchronize];
    if([userDefaultKey isEqualToString:AUTO_DOWNLOAD]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_DOWNLOAD object:nil];
    }
}
@end
