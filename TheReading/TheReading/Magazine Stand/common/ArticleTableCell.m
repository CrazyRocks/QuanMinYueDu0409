//
//  RecommentTableCell.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-16.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "ArticleTableCell.h"
#import <OWCoreText/OWInfiniteContentView.h>
#import <OWCoreText/OWInfiniteCoreTextLayouter.h>

@implementation ArticleTableCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        textLabel = [[OWCoreTextLabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.bounds)-20, CGRectGetHeight(self.bounds))];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        textLabel.numberOfLines = 5;
        [self.contentView addSubview:textLabel];
    }
    return self;
}

-(void)setContent:(LYArticleTableCellData *)info
{
    contentInfo = info;
    [contentInfo cellHeight];

    if(contentInfo.thumbnailURL)
    {
        [webImageView setHidden:NO];
        [webImageView sd_setImageWithURL:[NSURL URLWithString:contentInfo.thumbnailURL]];
    }
    else {
        [webImageView setHidden:YES];
    }
}

-(void)rerenderContent
{
    [contentInfo setAlreadyRead:YES];
}

-(NSArray *) getTextLines:(ArticleTableCell *)weakSelf
{
    return nil;    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
