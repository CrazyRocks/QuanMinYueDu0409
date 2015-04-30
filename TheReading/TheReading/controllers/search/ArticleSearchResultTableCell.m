//
//  ArticleSearchResultTableCell.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-26.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "ArticleSearchResultTableCell.h"
#import <OWCoreText/OWCoreText.h>
#import <OWCoreText/OWInfiniteCoreTextLayouter.h>

@implementation ArticleSearchResultTableCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.contentMode = UIViewContentModeTopLeft;
        
        UIView *selectedBG = [[UIView alloc] initWithFrame:self.bounds];
        
        selectedBG.backgroundColor = [OWColor colorWithHex:0x10999999];
        
        self.selectedBackgroundView = selectedBG;
       
    }
    return self;
}

- (void)awakeFromNib
{
    if (isPad) {
        titleLB.font = [UIFont systemFontOfSize:16];
    }
}

- (void)setStyleObject:(UIStyleObject *)styleObject
{
    if (_styleObject != styleObject) {
        _styleObject = styleObject;
        if (_styleObject.background_selected) {
            self.selectedBackgroundView.backgroundColor = _styleObject.background_selected;
        }
        [splitLine drawByStyle:_styleObject];
    }
}

-(void)setContent:(LYArticleTableCellData *)info
{
    contentInfo = info;
    titleLB.text = info.title;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];

    titleLB.preferredMaxLayoutWidth = CGRectGetWidth(titleLB.frame);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
