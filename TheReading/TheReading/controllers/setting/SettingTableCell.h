//
//  SettingTableCell.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-30.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableCell : UITableViewCell
{
    __weak IBOutlet UIImageView   *customImageView;
    __weak IBOutlet UISwitch      *customSwitch;
    __weak IBOutlet UILabel       *rightLable;
    NSString               *userDefaultKey;
}
@property(nonatomic, weak)IBOutlet UILabel       *customLable;

-(void)setImageView:(UIImage *)image;
-(void)setSwitchByUserDefaultKey:(NSString *)key;
-(void)showRightLable;

-(IBAction)switchValueChanged:(id)sender;
@end
