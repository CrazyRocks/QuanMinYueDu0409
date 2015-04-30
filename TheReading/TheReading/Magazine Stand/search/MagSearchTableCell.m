//
//  MagSearchTableCell.m
//  PublicLibrary
//
//  Created by grenlight on 13-12-7.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "MagSearchTableCell.h"
#import <OWCoreText/OWInfiniteContentView.h>
#import <OWCoreText/OWInfiniteCoreTextLayouter.h>
#import <LYService/LYMagazineSearchCellData.h>

@implementation MagSearchTableCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIView *selectedBg = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView = selectedBg;
    self.textLabel.backgroundColor = [UIColor clearColor];
    if (isPad) {
        self.textLabel.font = [UIFont systemFontOfSize:17];
    }
    else {
        self.textLabel.font = [UIFont systemFontOfSize:15];
    }
}

- (void)setContent:(NSString *)title
{
    self.selectedBackgroundView.backgroundColor = self.listStyle.background_selected;
    self.textLabel.text = [NSString stringWithFormat:@"《%@》", title ];
}

@end
