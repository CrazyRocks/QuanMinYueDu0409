//
//  MagCatelogueCell.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-12.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "MagCatelogueCell.h"

@implementation MagCatelogueCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = self.contentView.backgroundColor = [OWColor colorWithHex:0xf2f2ef];
    
    self.backgroundView.backgroundColor = [OWColor colorWithHex:0xf2f2ef];
    
    self.selectedBackgroundView.backgroundColor = [OWColor colorWithHex:0xeeeeee];
}

- (void)setContent:(LYMagCatelogueTableCellData *)info
{
    titleLabel.text = info.title;
}


@end
