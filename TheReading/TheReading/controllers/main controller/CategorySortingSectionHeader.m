//
//  CategorySortingSectionHeader.m
//  PublicLibrary
//
//  Created by grenlight on 14-3-6.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "CategorySortingSectionHeader.h"
#import <OWKit/OWKit.h>

@implementation CategorySortingSectionHeader

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
        //马云峰2014.11.11 16：10修改
        //titleLB.text = @"拖拽排序";
        titleLB.text = @"已选频道";
    }
    else {
        //马云峰2014.11.11 16：10修改
        //titleLB.text = @"拖拽至上面一栏添加更多栏目";
        titleLB.text = @"点击频道名称，添加至上栏";
    }
}

@end
