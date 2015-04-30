//
//  MagCatSectionHeader.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-17.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "MagCatSectionHeader.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MagCatSectionHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.backgroundColor = [OWColor colorWithHex:0xf2f2ef];
    
    if (bg) {
        UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"杂志目录Header"];
        issueLB.textColor = style.fontColor;
        issueLB.font = [UIFont systemFontOfSize:style.fontSize];
        
        CGFloat red, green, blue, alpha;
        BOOL bl=[style.fontColor getRed:&red green:&green blue:&blue alpha:&alpha];
        if (bl) {
            UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.8];
            categoryLB.textColor = cycleLB.textColor = newColor;
        }
        
        [bg drawByStyle:style];
    }
    
    UIStyleObject *lineStyle = [[UIStyleManager sharedInstance] getStyle:@"杂志目录Header_SectionLine"];
    [splitLine drawByStyle:lineStyle];
    
    OWControlCSS *css = [[OWControlCSS alloc] init];
    css.textColor_normal = [OWColor colorWithHexString:@"#ffffff"];
    css.textColor_highlight = [OWColor colorWithHexString:@"#ffffff"];
    css.fillColor_normal = [OWColor gradientColorWithHexString:@"#8dc63f,#8dc63f"];
    css.fillColor_highlight = [OWColor gradientColorWithHexString:@"#8df64f,#8df64f"];
    css.borderWidth = 0;
    
    [addToShelfBT setTitle:@"添加到杂志架" style:css];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(download_begin:) name:MAG_DOWNLOAD_BEGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(download_progress:) name:MAG_DOWNLOAD_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(download_complete:) name:MAG_DOWNLOAD_COMPLETE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(download_error) name:MAG_DOWNLOAD_ERROR object:nil];
}

- (void)setTitle:(NSString *)title
{
    [titleLB setText:title];
}

- (void)setMagInfo:(LYMagazineInfo *)info
{
    magInfo = info;
    
    BOOL isDownloaded = [[LYMagazineShelfManager sharedInstance] isDownloaded:info];
    if (isDownloaded) {
        [addToShelfBT setTitle:@"已添加到杂志架"];
        [addToShelfBT setEnabled:NO];
    }
    else {
        [addToShelfBT setTitle:@"添加到杂志架"];
        [addToShelfBT setEnabled:YES];
    }
    
    [issueLB setText:info.FormattedIssue];
    [webImageView sd_setImageWithURL:[NSURL URLWithString:info.coverURL]];
    
    if (info.cycle) {
        cycleLB.hidden = categoryLB.hidden = NO;
        categoryLB.text = [NSString stringWithFormat:@"分类：%@",info.magazineCategory];
        cycleLB.text = [NSString stringWithFormat:@"刊期：%@",[LYUtilityManager magazineCycleByType:info.cycle]];
    }
    else {
        cycleLB.hidden = categoryLB.hidden = YES;
    }
}

- (void)setLocalMagInfo:(LYMagazineTableCellData *)info
{
    issueLB.text = [NSString stringWithFormat:@"%@年第%@期", info.year, info.issue];
    titleLB.text = [[CommonNetworkingManager sharedInstance] currentMagazine].magName;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark addToShelfButton delegate
- (void)downloadMagazine:(UIButton *)btn
{
    [[LYMagazineShelfManager sharedInstance] downloadMagazine:magInfo];

    [addToShelfBT setTitle: @"下载中..."];
    [addToShelfBT setSelected:YES];
}

#pragma mark download notification
- (void)download_begin:(NSNotification *)noti
{
    NSString *guid = ((LYMagazineInfo *)[noti.userInfo objectForKey:@"mag"]).magGUID;
    if (![magInfo.magGUID isEqualToString:guid]) return;
    
    if (![NSThread isMainThread]) {
        [NSThread mainThread];
    }
    [addToShelfBT setTitle:@"下载中..."];
}

- (void)download_progress:(NSNotification *)noti
{
    NSString *guid = ((LYMagazineInfo *)[noti.userInfo objectForKey:@"mag"]).magGUID;
    if (![magInfo.magGUID isEqualToString:guid]) return;
    
    if (![NSThread isMainThread]) {
        [NSThread mainThread];
    }
    float progress = [[noti.userInfo objectForKey:@"progress"] floatValue];
    [addToShelfBT setTitle:[NSString stringWithFormat:@"下载中 %.0f%@",(progress*100),@"%"]];
}

- (void)download_complete:(NSNotification *)noti
{
    NSString *guid = ((LYMagazineInfo *)[noti.userInfo objectForKey:@"mag"]).magGUID;
    if (![magInfo.magGUID isEqualToString:guid]) return;
    
    if (![NSThread isMainThread]) {
        [NSThread mainThread];
    }
    [addToShelfBT setEnabled:NO];
    [addToShelfBT setTitle:@"下载完成"];
}

- (void)download_error
{
    if (![NSThread isMainThread]) {
        [NSThread mainThread];
    }
    [addToShelfBT setTitle:@"下载失败"];
    [addToShelfBT setEnabled:YES];
}

@end
