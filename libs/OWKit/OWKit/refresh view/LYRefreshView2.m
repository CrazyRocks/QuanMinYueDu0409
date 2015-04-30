//
//  LYRefreshView2.m
//  OWKit
//
//  Created by grenlight on 14/7/23.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYRefreshView2.h"
#import "UIStyleManager.h"

@implementation LYRefreshView2

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"下拉刷新"];
    self.backgroundColor = style.background;
    self.titleLabel.textColor = style.fontColor;
    self.titleLabel.font = [UIFont systemFontOfSize:style.fontSize];
    
    indicator.style = style;
    indicator.maxDropDownDistance = 30;
    indicator.offsetY = 35;
    
}

- (void)startLoading
{
    [super startLoading];
    [indicator startAnimating];
}

- (void)stopLoading
{
    [super stopLoading];
    [indicator stopAnimating];
}

// refreshView 拖动过程中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0)  {
        offsetY *= -1;
        
        CGRect newFrame = self.frame;
        newFrame.size.height = offsetY;
        self.frame = newFrame;
        
        [indicator dropDistance:offsetY];
    }
   
    
    [super scrollViewDidScroll:scrollView];
}

- (void)setStyle:(UIStyleObject *)style
{
    self.titleLabel.textColor = style.fontColor;
    self.backgroundColor = style.background;
}

@end
