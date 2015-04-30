//
//  LYSSlideMenuCell.m
//  LYBookStore
//
//  Created by grenlight on 14/8/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYSSlideMenuCell.h"

@implementation LYSSlideMenuCell

- (void)awakeFromNib
{
    [self setStyle];
}

- (void)setStyle
{
    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"侧边栏列表"];
    titleLB.textColor = style.fontColor;
    titleLB.font = [UIFont systemFontOfSize:style.fontSize];
    titleLB.highlightedTextColor = style.fontColor_selected;
    [splitLine drawByStyle:style];
    
    self.backgroundColor = style.background;
    UIView *selectedBg = [[UIView alloc] initWithFrame:self.bounds];
    selectedBg.backgroundColor = style.background_selected;
    self.selectedBackgroundView=selectedBg;
    self.contentView.backgroundColor = self.backgroundColor;
}

- (void)setInfo:(NSString *)title
{
    titleLB.text = title;
}

@end
