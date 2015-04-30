//
//  IssueCollectionViewHeader.m
//  TheReading
//
//  Created by grenlight on 15/1/8.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "IssueCollectionViewHeader.h"
#import <LYService/LYUtilityManager.h>

@implementation IssueCollectionViewHeader

- (void)awakeFromNib
{
    UIStyleObject *lineStyle = [[UIStyleManager sharedInstance] getStyle:@"杂志目录Header_SectionLine"];
    [splitLine drawByStyle:lineStyle];

    OWControlCSS *css = [[OWControlCSS alloc] init];
    css.textColor_normal = [OWColor colorWithHexString:@"#ffffff"];
    css.textColor_highlight = [OWColor colorWithHexString:@"#ffffff"];
    css.fillColor_normal = [OWColor gradientColorWithHexString:@"#8dc63f,#8dc63f"];
    css.fillColor_highlight = [OWColor gradientColorWithHexString:@"#8df64f,#8df64f"];
    css.borderWidth = 0;
    
    [addFocusBT setTitle:@"添加关注" style:css];
    addFocusBT.enabled = NO;
}

- (void)setMagInfo:(LYMagazineTableCellData *)info
{
    magInfo = info;
    [self checkFocused];
    
    magNameLB.text = info.magName;
    categoryLB.text = info.issn;
    cycleLB.text = [LYUtilityManager magazineCycleByType:info.cycle];
    CGSize size = CGSizeZero;
    if (info.summary) {
        size = [info.summary sizeWithFont:[UIFont systemFontOfSize:14] width:noteLB.frame.size.width];
    }
    CGRect frame = self.frame;
    frame.size.height = 106 + size.height + (size.height > 10 ? 30 : 20);
    self.frame = frame;
    
    CGRect nFrame = noteLB.frame;
    nFrame.size.height = size.height + 10;
    noteLB.frame = nFrame;
    
    noteLB.text = info.summary ?:@"";
}

- (void)checkFocused
{
    if (!magInfo || (requestedMagGUID && [requestedMagGUID isEqualToString:magInfo.magGUID])) {
        return;
    }
    requestedMagGUID = magInfo.magGUID;
    [LYMagazineManager isFocused:requestedMagGUID completion:^{
        addFocusBT.enabled = NO;
        [addFocusBT setTitle:@"已关注"];
    } fault:^{
        addFocusBT.enabled = YES;
        [addFocusBT setTitle:@"添加关注"];
    }];
}

- (void)addFocusButtonTapped:(id)sender
{
    [LYMagazineManager focusMagazine:magInfo bySender:sender];
}

@end
