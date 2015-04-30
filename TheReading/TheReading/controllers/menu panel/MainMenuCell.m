//
//  MainMenuCell.m
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "MainMenuCell.h"
#import "MTCBackgroundView.h"
#import "MTCSelectedBackgroundView.h"
#import <OWKit/OWKit.h>

@implementation MainMenuCell

- (void)awakeFromNib
{
    self.backgroundColor = self.contentView.backgroundColor = [UIColor clearColor];
    
    self.backgroundView = [[MTCBackgroundView alloc] init];
    self.selectedBackgroundView = [[MTCSelectedBackgroundView alloc] initWithFrame:self.bounds];
    
    self.needRenderForiPad = YES;
}

- (void)loadStyle
{
    NSString *styleName = @"左侧边栏列表";
    if (isPad && self.needRenderForiPad) {
        styleName = @"左侧边栏列表_Pad";
        iconLeftConstraint.constant = 19.5;
        titleLeftConstraint.constant = 0;
        titleLB.textAlignment = NSTextAlignmentCenter;
        titleTopConstraint.constant = iconTopConstraint.constant + CGRectGetHeight(iconView.frame) + CGRectGetHeight(titleLB.frame)/2.0;
    }
    style = [[UIStyleManager sharedInstance] getStyle:styleName];
    titleLB.textColor = style.fontColor;
    titleLB.font = [UIFont systemFontOfSize:style.fontSize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:YES];

    if (selected) {
        [OWAnimator spring:self.contentView toScale:1];
        iconView.image = [UIImage imageNamed:
                          [NSString stringWithFormat:@"%@_selected",cntInfo.menuType]];
        titleLB.textColor = style.fontColor_selected;
    }
    else {
        iconView.image = [UIImage imageNamed:cntInfo.menuType];
        titleLB.textColor = style.fontColor;
    }
}

- (void)setContent:(LYMenuData *)info
{
    cntInfo = info;
    titleLB.text = info.menuName;
    
    [self loadStyle];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (self.highlighted) {
        [OWAnimator basicAnimate:iconView toScale:CGPointMake(0.95, 0.95) duration:0.05];
        [OWAnimator basicAnimate:titleLB toScale:CGPointMake(0.95, 0.95) duration:0.05];
    }
    else {
        [OWAnimator spring:iconView toScale:1];
        [OWAnimator spring:titleLB toScale:1];
    }
}

@end
