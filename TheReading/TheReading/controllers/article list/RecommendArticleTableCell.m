//
//  RecommentTableCell.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-16.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "RecommendArticleTableCell.h"
#import <OWCoreText/OWCoreText.h>
#import <OWCoreText/OWInfiniteCoreTextLayouter.h>

@implementation RecommendArticleTableCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {        
        UIView *selectedBG = [[UIView alloc] initWithFrame:self.bounds];
        selectedBG.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectedBG;
        
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)awakeFromNib
{
    if (isPad) {
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        summaryLabel.font = [UIFont systemFontOfSize:16];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(titleLabel.frame);
    summaryLabel.preferredMaxLayoutWidth = CGRectGetWidth(summaryLabel.frame);
}

- (void)setContent:(LYArticleTableCellData *)info
{
    self.contentView.clipsToBounds = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    magLabel.backgroundColor = [UIColor clearColor];
    
    [logoImageView setHidden:YES];
    contentInfo = info;
    
    
    if ([contentInfo.thumbnailURL isKindOfClass:[NSString class]] &&
        [contentInfo.thumbnailURL componentsSeparatedByString:@"."].count >= 5) {
        webImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        [webImageView setHidden:NO];
        webImageView.clipsToBounds = YES;

        [webImageView sd_setImageWithURL:[NSURL URLWithString:contentInfo.thumbnailURL]];
        thumbTrailingConstraint.constant = 2;
        thumbHeightConstraint.constant = 70;
    }
    else {
        thumbHeightConstraint.constant = 40;
        thumbTrailingConstraint.constant = -100;
        [webImageView setHidden:YES];
    }

    titleLabel.text = info.title;
    summaryLabel.text = info.summary;
    magLabel.text = info.publishDateSection;
}

-(void)rerenderContent
{
    [contentInfo setAlreadyRead:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}



@end
