//
//  MagazineTableCell.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-18.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "MagazineTableCell.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h> 

@implementation MagazineTableCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UIView *selectedBG = [[UIView alloc] initWithFrame:self.bounds];
        selectedBG.backgroundColor = [OWColor colorWithHex:tableCellSelectedColor];
        self.selectedBackgroundView = selectedBG;
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setContent:(LYMagazineItem *)mag
{
    magNameLabel.text = mag.magName;
    updateTimeLabel.text = [NSString stringWithFormat:@"%@年第%@期",mag.year,mag.issue];
    [webImageView sd_setImageWithURL:[NSURL URLWithString:mag.magIconURL]];
}


@end
