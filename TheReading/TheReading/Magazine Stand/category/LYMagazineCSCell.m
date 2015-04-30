//
//  CategorySortingCell.m
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYMagazineCSCell.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@implementation LYMagazineCSCell

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
    self.backgroundColor = [OWColor colorWithHexString:@"#fafafa"];
    self.layer.borderColor = [OWColor colorWithHexString:@"#dadada"].CGColor;
    self.layer.borderWidth = 0.5;
}

- (void)setInfo:(OWSubNavigationItem *)category
{
    [title setText:category.catName];
}

@end
