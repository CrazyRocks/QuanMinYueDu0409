//
//  MagCatListCellData.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-17.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "LYMagCatelogueTableCellData.h"
#import "LYUserEvent.h"
#import "LYArticleManager.h"
#import <OWCoreText/OWCoreText.h>
#import <OWCoreText/OWHTMLToAttriString.h>
#import <OWCoreText/OWInfiniteCoreTextLayouter.h>

@implementation LYMagCatelogueTableCellData

@synthesize title, summary, titleID, thumbnailURL, thumbnailHeight, thumbnailWidth, author, publishDate;
@synthesize magName, magIssue, magGUID, magYear, sectionName;
@synthesize isEditMode, willDeleted;
@synthesize alreadyRead, thumbnailScreenHeight;

- (float)cellHeight
{
    float w = appWidth-40;
    CGSize tSize = [self string:self.title sizeWithFont:[UIFont systemFontOfSize:16] width:w];
    
    return  tSize.height + 24;
}



@end
