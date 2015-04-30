//
//  SelectionCell.m
//  TheReading
//
//  Created by grenlight on 15/1/6.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "SelectionCell.h"

@implementation SelectionCell

- (void)awakeFromNib {
    indicator.color = [UIColor blackColor];
    // Initialization code
}

- (void)showIndicator
{
    [indicator startAnimating];
    self.selected = NO;
}

- (void)hideIndicator
{
    [indicator stopAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
