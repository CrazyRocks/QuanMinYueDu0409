//
//  ArticleTableCellData.m
//  LongYuan
//
//  Created by gren light on 12-6-19.
//  Copyright (c) 2012年 OOWWWW. All rights reserved.
//

#import "LYArticleTableCellData.h"
#import "LYUserEvent.h"
#import "LYArticleManager.h"
#import <OWCoreText/OWInfiniteCoreTextLayouter.h>
#import <OWCoreText/OWHTMLToAttriString.h>

@implementation LYArticleTableCellData

@synthesize title, summary, titleID, thumbnailURL, thumbnailHeight, thumbnailWidth, author, publishDate;
@synthesize magName, magIssue, magGUID, magYear, magazineIcon, sectionName;
@synthesize images;
@synthesize isEditMode, willDeleted;
@synthesize alreadyRead, thumbnailScreenHeight;

-(id)init
{
    self = [super init];
    if (self) {
        _searchedReadState = NO;
        self.labelCellHeight = 0;
        self.titleLabelHeight = 0;
    }
    return self;
}

- (void)dealloc
{
}

-(BOOL)alreadyRead
{
    if (_searchedReadState) {
       
    }
    else {
        _alreadyRead = [[LYArticleManager sharedInstance] alreadyRead:self.titleID];
        _searchedReadState = YES;
    }
     return _alreadyRead;
}

-(void)setAlreadyRead:(BOOL)aalreadyRead
{
    _alreadyRead = aalreadyRead;
    _searchedReadState = YES;
}

- (void)setCellHeight:(float)acellHeight
{
    _cellHeight = acellHeight;
}

- (float)cellHeight
{
    return [self labelCellHeight:0];
}

- (float)labelCellHeight:(float)thumbnailScreenWidth
{
    if (self.titleLabelHeight == 0) {
        float maxWidth = appWidth;
        if (isPad) {
            maxWidth -= 64;
        }
        float w = maxWidth -20;
        if (thumbnailURL) {
            w -= thumbnailScreenWidth;
        }
        UIFont *titleFont, *summaryFont ;
        if (isPad) {
            titleFont = [UIFont boldSystemFontOfSize:20];
            summaryFont = [UIFont systemFontOfSize:16];
        }
        else {
            titleFont = [UIFont systemFontOfSize:16];
            summaryFont = [UIFont systemFontOfSize:14];
        }
        CGSize tSize = [self string:self.title sizeWithFont:titleFont width:w];
        self.titleLabelHeight = tSize.height + 6;
        
        if (self.summary && self.summary.length > 2) {
            CGSize sSize = [self string:self.summary sizeWithFont:summaryFont width:w];
            float sh = summaryFont.lineHeight * 2 + 6;
            self.summaryLabelHeight =  ((sSize.height + 6) < sh) ?: sh;
        }
    }
    
    return self.titleLabelHeight + self.summaryLabelHeight + 10*2 + 5;
}

- (CGSize)string:(NSString *)str sizeWithFont:(UIFont *)font width:(float)width
{
    CGSize size;
    if (isiOS7) {
        NSDictionary *attribute = @{NSFontAttributeName: font};
        CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 5000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
        size = rect.size;
    }
    else {
        size = [str sizeWithFont:font forWidth:width lineBreakMode:NSLineBreakByWordWrapping];
    }
    return size;
}
@end
