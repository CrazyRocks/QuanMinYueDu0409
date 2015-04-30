//
//  LYEpubDownloadButton.m
//  LYBookStore
//
//  Created by grenlight on 14-3-31.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYEpubDownloadButton.h"
#import "LYBookDownloadManager.h"
#import "LYBookItemData.h"
#import "MyBook.h"
#import "MyBooksManager.h"
#import "LYBookConfig.h"
#import <OWKit/OWKit.h>
#import "LYBookShelfController.h"
#import "BSReaderViewController.h"

@implementation LYEpubDownloadButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup
{
    self.layer.cornerRadius = 4;
    currentStatus = lyNormal;
    
    tileLable = [[UILabel alloc] initWithFrame:self.bounds];
    tileLable.textAlignment = NSTextAlignmentCenter ;
    tileLable.backgroundColor = [UIColor clearColor];
    tileLable.textColor = [UIColor whiteColor];
    tileLable.font = [UIFont systemFontOfSize:12];
    [self addSubview:tileLable];
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [tileLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(padding);
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(download_begin:) name:BOOK_DOWNLOAD_BEGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(download_progress:) name:BOOK_DOWNLOAD_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(download_complete:) name:BOOK_DOWNLOAD_COMPLETE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(download_error) name:BOOK_DOWNLOAD_ERROR object:nil];
    
    [self changeBackground];
}

- (void)changeBackground
{
    NSString *color = @"#8dc63f";
    if (currentStatus == lyHighlighted) {
        color = @"#77aa31";
    }
    else if (currentStatus == lyDownloaded) {
        color = @"#4687f0";
    }
    else if (currentStatus == lyDownloading) {
        color = @"#3fc69e";
    }
    else if (currentStatus == lyContinueBorrow) {
        color = @"#8dc63f";
    }
    self.backgroundColor = [OWColor colorWithHexString:color];

}

- (void)tapped
{
    if (currentStatus == lyDownloaded) {
        //返回到书架
//        if ([LYBookConfig sharedInstance].bookShelfMode == lyBorrowMode) {
//            [[OWNavigationController sharedInstance] popToViewController:
//             [LYBookShelfController class] animationType:owNavAnimationTypeDegressPathEffect];
//        }
//        else {
//            [[OWNavigationController sharedInstance] popByNumberOfTimes:2 animationType:owNavAnimationTypeDegressPathEffect];
//        }
        
        // 阅读
        [[MyBooksManager sharedInstance] setReadBookByName:bookInfo.name];

        BSReaderViewController *controller = [[BSReaderViewController alloc] init];
        [[OWNavigationController sharedInstance] pushViewController:controller animationType:owNavAnimationTypeDegressPathEffect];
        [controller openWithNoneCover];
        
        return;
    }
    
    if ((currentStatus == lyFree || currentStatus == lyCloud) &&
        bookInfo.downloadUrl && bookInfo.downloadUrl.length > 10) {
        downloadingBook = [[MyBooksManager sharedInstance] createABook:bookInfo isSimple:NO];

        if ([CommonNetworkingManager sharedInstance].isWifiConnection) {
            [self startDownloading];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"当前使用的不是wifi，下载需要消耗您的上网流量" delegate:self cancelButtonTitle:@"以后下载" otherButtonTitles:@"立即下载", nil];
            [alertView show];
        }
    }
    else if (currentStatus == lyContinueBorrow) {
        [[MyBooksManager sharedInstance] continueBorrow:bookInfo];
        
        currentStatus = lyDownloaded;
        tileLable.text = [NSString stringWithFormat: @"继借成功,您已获得%@天的阅读权限", bookInfo.expireIn];
    }
    else {
        tileLable.text = @"下载地址无效，无法完成下载";
    }
}

- (void)startDownloading
{
    currentStatus = lyDownloading;
    [self changeBackground];

    [[LYBookDownloadManager sharedInstance] download:downloadingBook];
    
    tileLable.text = @"正在下载...";
    self.userInteractionEnabled = NO;
}

#pragma mark alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self startDownloading];
    }
}

- (void)setBookInfo:(LYBookItemData *)bookItem
{
    bookInfo = bookItem;
    downloadStatus = [[MyBooksManager sharedInstance] isDownloaded:bookInfo.bGUID];
    if (downloadStatus == 1) {
        currentStatus = lyDownloaded;
        tileLable.text = @"阅 读";
    }
    else if (downloadStatus == 2) {
        currentStatus = lyContinueBorrow;
        tileLable.text = @"续借";
    }
    else {
        currentStatus = lyFree;
        if ([LYBookConfig sharedInstance].bookShelfMode == lyStoreMode)
            tileLable.text = @"添加到书架";
        else
            tileLable.text = @"借阅";
    }
    [self changeBackground];
}

#pragma mark download notification
- (void)download_begin:(NSNotification *)noti
{
    NSString *bn = ((MyBook *)[noti.userInfo objectForKey:@"bookInfo"]).bookID;
    if (![bookInfo.bGUID isEqualToString:bn]) return;
    
    tileLable.text = @"下载中...";
}

- (void)download_progress:(NSNotification *)noti
{
    NSString *bn = ((MyBook *)[noti.userInfo objectForKey:@"bookInfo"]).bookID;
    if (![bookInfo.bGUID isEqualToString:bn]) return;
    
    float progress = [[noti.userInfo objectForKey:@"progress"] floatValue];
    tileLable.text = [NSString stringWithFormat:@"下载中 %.0f%@",(progress*100),@"%"];
}

- (void)download_complete:(NSNotification *)noti
{
    NSString *bn = ((MyBook *)[noti.userInfo objectForKey:@"bookInfo"]).bookID;
    if (![bookInfo.bGUID isEqualToString:bn]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    tileLable.text = @"阅 读";
    currentStatus = lyDownloaded;
    
    [self changeBackground];
    
    self.userInteractionEnabled = YES;
}

- (void)download_error
{
    tileLable.text = @"下载失败";
    currentStatus = lyFree;
    self.userInteractionEnabled = YES;
    
    [self changeBackground];

}




@end
