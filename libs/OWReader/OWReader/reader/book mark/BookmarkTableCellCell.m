//
//  BookmarkTableCellCell.m
//  LogicBook
//
//  Created by iMac001 on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookmarkTableCellCell.h"
#import "GLGradientView.h"
#import "BSGlobalAttri.h"
#import "LYBookSceneManager.h"
#import "JRReaderNotificationName.h"

//顶边距
#define PADDING_TOP 17

@implementation BookmarkTableCellCell;

- (void)awakeFromNib {
    // Initialization code
    
    [self loadSceneMode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSceneMode) name:BOOK_SCENE_CHANGED object:nil];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadSceneMode
{
    style = [[LYBookSceneManager manager].styleManager getStyle:@"目录列表cell"];
    
    textLB.textColor = style.fontColor;
    textLB.highlightedTextColor = style.fontColor_selected;
    dateLB.textColor = style.fontColor;
    dateLB.highlightedTextColor = style.fontColor_selected;
    summaryLB.textColor = style.fontColor;
    summaryLB.highlightedTextColor = style.fontColor;

    [splitLine drawByStyle:style];
    
    self.selectedBackgroundView = [[GLGradientView alloc]init];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = self.backgroundColor;
}

-(void)renderContent:(Bookmark *)bm
{
    self.backgroundColor = [UIColor clearColor];

    bmark = bm;
    font = [BSGlobalAttri sharedInstance].catFont;
    tFrame = CGRectMake(0, PADDING_TOP, self.frame.size.width , 24);
    
    
    [textLB setText:bmark.catName];
    
    NSTimeInterval oldInterval = [bmark.addDate timeIntervalSince1970];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSTimeInterval currentInterval = [localeDate timeIntervalSince1970];
    uint miniment = floor((currentInterval - oldInterval)/60.0f);
    NSString *dateStr;
    
    if(miniment == 0)
        dateStr = @"刚刚";
    else if(miniment < 60)
        dateStr = [NSString stringWithFormat:@"%i分钟前",miniment];
    else{
        uint hour = floor(miniment/60.0f);
        if(hour < 24)
            dateStr = [NSString stringWithFormat:@"%i小时前",hour];
        else {
            uint day = floor(hour /24.0f);
            if(day < 31)
                dateStr = [NSString stringWithFormat:@"%i天前",day];
            else {
                NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
                [inputFormatter setDateFormat:@"yy-MM-dd"];
                dateStr = [inputFormatter stringFromDate:bmark.addDate] ; 
            }

        }
    }
    [dateLB setText:dateStr];
    
    [summaryLB setText:bmark.summary];
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        textLB.textColor = style.fontColor_selected;
        dateLB.textColor = style.fontColor_selected;
    }
    else {
        textLB.textColor = style.fontColor;
        dateLB.textColor = style.fontColor;
    }
}

@end
