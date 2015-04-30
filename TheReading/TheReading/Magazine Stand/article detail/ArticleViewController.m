//
//  CoreTextPageViewController.m
//  DragonSourceEPUB
//
//  Created by iMac001 on 12-1-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ArticleViewController.h"
#import <OWCoreText/OWCoreText.h>
#import "ArticleDetailMainController.h"
#import "HorizontalPageScrollView.h"
#import <OWCoreText/OWHTMLToAttriString.h>
#import <LYService/LYService.h>
#import <OWKit/OWKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ArticleViewController()
{
    //保持当前文章，用于调整字体时再次使用
    LYArticle                               *articleDetail;
    
    BOOL                                   loadCompleted;

}

@end

@implementation ArticleViewController

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        requestManager = [[LYArticleManager alloc] init];
    }
    return self;
}

- (void)releaseData
{
    self.delegate = nil;
    [super releaseData];
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [OWColor colorWithHexString:@"#f2f2f2"];
    articleDetail = nil;
}

- (void)setPagePosition:(CGRect)rect
{
    [self.view setFrame:rect];
    if(!pageContentView) {
        CGRect contentFrame = self.view.bounds;
        pageContentView = [[OWInfiniteScrollView alloc] initWithFrame:contentFrame];
        [pageContentView setContentInset:UIEdgeInsetsMake(0, 19, 30, 19)];
        
        pageContentView.backgroundColor = [OWColor colorWithHexString:@"#FBFBFB"];
        pageContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:pageContentView];
        [pageContentView setDelegate:self];
        loadCompleted = NO;
    }
}

-(void)setArticle:(LYArticleTableCellData *)article
{
    if (currentArticle != article) {
        articleDetail = nil;
        currentArticle = article;
        currentState = glArticleDetailInitState;
        [self loadHeader];

        [pageContentView setScrollsToTop:YES];
    }
}

-(void)loadHeader
{
    currentState = glArticleDetailTitleState;
    pageContentView.contentOffset = CGPointZero;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    OWHTMLToAttriString *htmlToAttriString = [OWHTMLToAttriString sharedInstance] ;
    [htmlToAttriString setImageBasicPath:@"http://img1.qikan.com.cn"];
    if ([defaults floatForKey:APP_FONTSIZE]==appFontsize_normal)
        [htmlToAttriString setCSS:@"articleDetail"];
    else
        [htmlToAttriString setCSS:@"articleDetail_fontSizeLarge"];
    
    [self generateHeaderHTML];
    [self renderTextView];
}

-(void)loadArticle
{
    if(currentState == glArticleDetailCompleteState)
        return;
    
    //收藏状态变更
    [[NSNotificationCenter defaultCenter] postNotificationName:CURRENTARTICLE_CHANGED object:nil];

    GLParamBlock faultBlock = ^(NSString *message) {
        [statusManageView requestFault];
    };
    
    GLParamBlock  successBlock = ^(LYArticle *art) {
        currentState = glArticleDetailCompleteState;
        articleDetail = art;
        [self generateContentHTML];
        loadCompleted = YES;
    };
    
    [requestManager getArticleDetail:successBlock fault:faultBlock ];
    
}

- (void)reloading:(id)sender
{
    [self loadArticle];
}

- (void)generateHeaderHTML
{
    contentHTML = [NSString stringWithFormat:@"<p></p><h3>%@</h3>",currentArticle.title];
}

- (void)generateContentHTML
{
    if(articleDetail== nil) return;
    [self generateHeaderHTML];
    if (currentArticle.thumbnailURL && currentArticle.thumbnailURL.length >0) {
        contentHTML = [NSString stringWithFormat:@"<img src='%@' />", currentArticle.thumbnailURL];
    }
    else {
        contentHTML = @"";
    }
    NSString *author = @"", *magazineName = @"";
    if (currentArticle.author) {
        author = currentArticle.author;
    }
    else if (articleDetail.author) {
        author = articleDetail.author;
    }
    
    if (currentArticle.magName) {
        magazineName = currentArticle.magName;
    }
    else if (articleDetail.magName) {
        magazineName = articleDetail.magName;
    }
    contentHTML = [NSString stringWithFormat:@"%@<p></p><h3>%@</h3><h5>%@ %@</h5><blockquote>%@</blockquote>%@",contentHTML,articleDetail.title, magazineName, author,
                   articleDetail.summary, articleDetail.content];
    contentHTML = [contentHTML stringByReplacingOccurrencesOfString:@"<div" withString:@"<p"];
    contentHTML = [contentHTML stringByReplacingOccurrencesOfString:@"</div>" withString:@"</p>"];

    [self renderTextView];
}

-(void)renderTextView
{
    [pageContentView rerenderContent:contentHTML defaultImageSize:CGSizeMake(290, 160)];
}

- (void)fontSizeChange
{
    __unsafe_unretained ArticleViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf renderTextView];
    });
}

- (void)pageContentLoadComplete:(GLCTPageInfo *)info{

}

-(NSString *)getArticleWebURL
{
    NSMutableString *message = [[NSMutableString alloc] init];
    [message appendString:@"#龙源阅读# "];
    
   if(articleDetail){
       [message appendString:articleDetail.title];
       [message appendString:@""];
       [message appendString: articleDetail.webURL];
   }
   else{
       [message appendString: @"http://m.qikan.com"];
   }
    return message;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

@end
