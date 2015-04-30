//
//  ArticleHeaderViewController.m
//  LYMagazinesStand
//
//  Created by grenlight on 14-3-9.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "ArticleHeaderViewController.h"

@interface ArticleHeaderViewController ()

@end

@implementation ArticleHeaderViewController

- (id)init
{
    self = [super initWithNibName:@"ArticleHeaderViewController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"文章Header"];
    if (style) {
        lineView.backgroundColor = style.hLineColor;
        CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetHeight(self.view.bounds)-style.hLineWidth/2.0f);
        lineView.center = center;
    }
    
    magNameLB.font = [UIFont fontWithName:@"FZLTXHK--GBK1-0" size:12];
    timeLB.font = magNameLB.font;
    
    magNameLB.textColor = [OWColor colorWithHex:0x9096a0];
    timeLB.textColor = magNameLB.textColor;
}

- (void)setContentInfo:(LYArticleTableCellData *)cellData
{
    magNameLB.text = cellData.magName;
    timeLB.text = cellData.publishDateSection;
}

- (void)updateContentInfo:(LYArticle *)cellData
{
    magNameLB.text = cellData.magName;
    
    if ([cellData.magYear intValue] > 0)
        timeLB.text = [NSString stringWithFormat:@"%@年第%@期", cellData.magYear, cellData.magIssue];
}

@end
