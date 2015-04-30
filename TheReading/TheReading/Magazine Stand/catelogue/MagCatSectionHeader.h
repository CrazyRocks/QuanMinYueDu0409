//
//  MagCatSectionHeader.h
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-17.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@class OWGradientBackgroundView;

@interface MagCatSectionHeader : UIView
{
    __weak IBOutlet OWGradientBackgroundView    *bg;
    __weak IBOutlet OWSplitLineView             *splitLine;
    
    __weak IBOutlet OWButton             *addToShelfBT;
    
    __weak IBOutlet UILabel    *titleLB, *magNameLB, *issueLB, *cycleLB, *categoryLB;
    
    __weak IBOutlet UIImageView  *webImageView;

    LYMagazineInfo  *magInfo;
}
- (void)setTitle:(NSString *)title;

- (void)setMagInfo:(LYMagazineInfo *)info;
//当是本地数据时调用
- (void)setLocalMagInfo:(LYMagazineTableCellData *)info;

- (IBAction)downloadMagazine:(UIButton *)btn;

@end
