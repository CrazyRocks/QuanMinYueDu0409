//
//  BookDigestTableViewCell.m
//  LYBookStore
//
//  Created by grenlight on 14-10-16.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "BookDigestTableViewCell.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>
#import "JRReaderNotificationName.h"
#import "GLGradientView.h"
#import "BSGlobalAttri.h"
#import "LYBookSceneManager.h"
//顶边距
#define PADDING_TOP 17


@implementation BookDigestTableViewCell

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
    
    _digestStrLab.textColor = style.fontColor;
    messageLab.textColor = style.fontColor;
    pageLab.textColor = style.fontColor;
    timeLab.textColor = style.fontColor;
    msgLab.textColor = style.fontColor;
    
    [line drawByStyle:style];
    
    self.selectedBackgroundView = [[GLGradientView alloc]init];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = self.backgroundColor;
    
//    style = [[LYBookSceneManager manager].styleManager getStyle:@"目录列表cell"];
//    
//    textLB.textColor = style.fontColor;
//    textLB.highlightedTextColor = style.fontColor_selected;
//    dateLB.textColor = style.fontColor;
//    dateLB.highlightedTextColor = style.fontColor_selected;
//    summaryLB.textColor = style.fontColor;
//    summaryLB.highlightedTextColor = style.fontColor;
//    
//    [splitLine drawByStyle:style];
//    
//    self.selectedBackgroundView = [[GLGradientView alloc]init];
//    self.backgroundColor = [UIColor clearColor];
//    self.contentView.backgroundColor = self.backgroundColor;
}



-(void)renderContent:(BookDigest *)bd
{
    _digestModel = bd;
    
    _digestStrLab.text = bd.summary;
    
    NSTimeInterval oldInterval = [bd.addDate timeIntervalSince1970];
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
                dateStr = [inputFormatter stringFromDate:bd.addDate] ;
            }
        }
    }
    
    [timeLab setText:dateStr];
    
    if (_digestModel.digestNote) {
        msgLab.hidden = NO;
        messageLab.hidden = NO;
        messageLab.text = _digestModel.digestNote;
        lineTopConstraint.constant = 6;
    }
    else{
        msgLab.hidden = YES;
        messageLab.hidden = YES;
        messageLab.text = @"";
        lineTopConstraint.constant = 0;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    self.digestStrLab.preferredMaxLayoutWidth = CGRectGetWidth(self.digestStrLab.frame);
    messageLab.preferredMaxLayoutWidth = CGRectGetWidth(messageLab.frame);
}

- (CGFloat)getCellHeight
{
    return CGRectGetMaxY(line.frame);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    
    
}

@end
