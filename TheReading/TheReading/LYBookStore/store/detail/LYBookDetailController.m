//
//  LYBarcodeResultViewController.m
//  LYBookStore
//
//  Created by grenlight on 14-3-26.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYBookDetailController.h"
#import <LYService/LYService.h>
#import "LYEpubDownloadButton.h"
#import "LYBookItemData.h"

@interface LYBookDetailController ()

@end

@implementation LYBookDetailController

- (id)init
{
    self = [super initWithNibName:@"LYBookDetailController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [navBar setTitle:@"简介"];
    
    messageBT.hidden = YES;
    
    self.view.backgroundColor = [OWColor colorWithHex:0xf9f8f8];
    webView.backgroundColor = self.view.backgroundColor;
    webView.scrollView.backgroundColor = self.view.backgroundColor;
    
    [backButton setIcon:@"back_button" inBundle:nil];
    
    //去掉webView的shadow
    for (NSInteger x = 0; x < ([webView.scrollView subviews].count - 1); ++x) {
        [[webView.scrollView subviews][x] setHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self requestContent];
}

- (void)updateStatusBarStyle
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)requestContent
{
    messageBT.hidden = YES;

//    if (self.contentInfo) {
//        [self renderContent:self.contentInfo];
//        return;
//    }

    [self createStatusManageView];
    webView.alpha = 0;
    
    __unsafe_unretained typeof(self) weakSelf = self;

    [[MyBooksManager sharedInstance] getBookDetail:self.bookGUID successCallBack:^(NSDictionary *results) {
        [weakSelf renderContent:results];
    } failedCallBack:^(NSString *msg) {
        [weakSelf->statusManageView stopRequest];
        weakSelf->messageBT.hidden = NO;
        [weakSelf->messageBT setTitle:msg forState:UIControlStateNormal];
    }];
}

- (void)reloading:(id)sender
{
    [self requestContent];
}

- (void)renderContent:(NSDictionary *)result
{
    [statusManageView stopRequest];
    LYBookItemData *bookItem = [[LYBookItemData alloc] init];
    bookItem.name = result[@"BookName"];
    bookItem.price = @0;
    bookItem.cover = result[@"CoverImage"];
    bookItem.author = result[@"Author"];
//    bookItem.categoryName = result[@"Category"];
    bookItem.summary = result[@"Note"];
    bookItem.ISBN = result[@"ISBN"];
    bookItem.downloadUrl = result[@"epubDonwloadURL"];
    bookItem.publishName = result[@"PublishName"];
    bookItem.isBookMode = YES;
    
    NSString *headerHTML =[NSString stringWithFormat: @"<div><div style='float:left;width:100px; height:198px; '>\
    <img style='margin-top:20px; margin-left:15px; width:80px; height:116px;background-color:gray' src='%@'  /></div>\
    <div style='float:left;margin-left:5px;width:210px;height:198px; font-size:11px; color:gray'>\
    <h3 style='font-size:15px;color:black;margin-top:20px;'>%@</h3>\
    <p>作者：<span style='color:#121212'>%@</span></p>\
    <p>ISBN：<span style='color:#bb1100'>%@</span></p>\
                           <p>出版社信息：<span style='color:#121212'>%@</span></p>\
    </div></div>",bookItem.cover, bookItem.name, bookItem.author, bookItem.ISBN,bookItem.publishName];
    
    NSString *summary = bookItem.summary;
    if (!summary)
        summary = @"";
    
    [webView loadHTMLString:[NSString stringWithFormat:BOOK_DETAIL_HTML,headerHTML, summary] baseURL:nil];
    [self performSelector:@selector(animateIn) withObject:nil afterDelay:0.1];
    
    [downloadButton setBookInfo:bookItem];
}

- (void)animateIn
{
    headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 198);
    [webView.scrollView addSubview:headerView];
//    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, appHeight-64-198, 0);
//    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(webView.mas_top).with.offset(padding.top);
//        make.left.equalTo(webView.mas_left).with.offset(padding.left);
//        make.right.equalTo(webView.mas_right).with.offset(-padding.right);
//        make.height.mas_equalTo(198);
//
//    }];
    [UIView animateWithDuration:0.25 animations:^{
        webView.alpha = 1;
    }];
}

- (void)comeback:(id)sender
{
    if (self.navigationController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [super comeback:sender];
    }
}

@end
