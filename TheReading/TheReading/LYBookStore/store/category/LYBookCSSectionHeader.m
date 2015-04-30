//
//  CategorySortingSectionHeader.m
//  PublicLibrary
//
//  Created by grenlight on 14-3-6.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYBookCSSectionHeader.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>

@implementation LYBookCSSectionHeader

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
    self.backgroundColor = [OWColor colorWithHexString:@"f5f5f5"];
    titleLB.textColor = [OWColor colorWithHexString:@"#ed1c24"];
}

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CGPoint center = titleLB.center;
        center.y -= 5;
        titleLB.center = center;
    }
    if (indexPath.section == 0) {
        titleLB.text = @"切换分类";
    }
}

@end
