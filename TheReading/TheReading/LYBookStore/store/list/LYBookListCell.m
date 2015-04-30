//
//  LYBookListCell.m
//  LYBookStore
//
//  Created by grenlight on 14-5-7.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYBookListCell.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation LYBookListCell

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
    
    [self showBorder];
}

- (void)showBorder
{
    webImageView.backgroundColor = [UIColor clearColor];
    webImageView.contentMode = UIViewContentModeScaleAspectFill;
    webImageView.layer.cornerRadius = 0;
    webImageView.layer.borderWidth = 0.5;
    webImageView.layer.borderColor = [OWColor colorWithHex:0xaaaaaa].CGColor;
    webImageView.clipsToBounds = YES;
}

- (void)setContent:(NSDictionary *)info
{
    [webImageView setImageWithURL:info[@"CoverImages"]];
    UIFont *font = [UIFont systemFontOfSize:12];
    CGSize size = [info[@"BookName"] sizeWithFont:font width:CGRectGetWidth(bookNameLB.frame)];
    
    if (size.height > 15) {
        titleHeightConstraint.constant = 30;
    }
    else {
        titleHeightConstraint.constant = 15;
    }
    bookNameLB.text = info[@"BookName"];
}

@end
