//
//  ArticleDetailController.m
//  GoodSui
//
//  Created by 龙源 on 13-7-25.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "ArticleDetailController.h"
#import "FullScreenWebViewController.h"
#import "ArticleHeaderViewController.h"

@interface ArticleDetailController ()
{
    ArticleHeaderViewController *headerController;
    LYArticleManager        *requestManager;
}
@property WebViewJavascriptBridge* bridge;

@end

@implementation ArticleDetailController

- (id)init
{
    self = [super initWithNibName:@"ArticleDetailController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    requestManager = [[LYArticleManager alloc] init];

    headerController = [[ArticleHeaderViewController alloc] init];
    [self addChildViewController:headerController];
}

- (void)releaseData
{
    [statusManageView stopRequest];
    [webView loadHTMLString:@"" baseURL:nil];
    [webView stopLoading];
    
    webView.delegate = Nil;
    webView.scrollView.delegate = Nil;
    [webView removeFromSuperview];
    webView = nil;
    
    _bridge = nil;
    
    [requestManager cancelRequest];
    requestManager = nil;
    
    [super releaseData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [OWColor colorWithHexString:@"F6F5EF"];
    
    webView.delegate = self;
    webView.backgroundColor = self.view.backgroundColor;
    webView.scrollView.backgroundColor = webView.backgroundColor;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.scrollView = webView.scrollView;
    
    //去掉webView的shadow
    for (int x = 0; x < ([webView.scrollView subviews].count - 1); ++x) {
        [[webView.scrollView subviews][x] setHidden:YES];
    }
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        
    }];
    
    [_bridge registerHandler:@"fullScreen" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[FullScreenWebViewController sharedInstance] showImage:data];
    }];
}

- (NSString *)loadingMessage
{
    return @"正在加载文章";
}

- (NSString *)errorMessage
{
    if ([CommonNetworkingManager sharedInstance].isReachable) {
        return @"加载失败，点击此处可重新加载";
    }
    else {
        return HTTPREQEUST_NONE_NETWORK;
    }
}

- (void)setPagePosition:(CGRect)rect
{
    [self.view setFrame:rect];
    [webView.scrollView setContentOffset:CGPointZero];
}

- (void)setArticle:(LYArticleTableCellData *)article
{
    if (article && [article.titleID isEqualToString:currentArticle.titleID]) {
        return;
    }
    currentState = glArticleDetailTitleState;
    [webView loadHTMLString:@"<html><body style='background-color:#F6F5EF'></body></html>" baseURL:Nil];
    CGRect frame = headerController.view.frame;
    frame.size.width = CGRectGetWidth(self.view.frame);
    headerController.view.frame = frame;
    [webView.scrollView addSubview:headerController.view];
    
    [headerController setContentInfo:article];
}

-(void)loadArticle
{
    if(currentState == glArticleDetailCompleteState)
        return;
    
    [self createStatusManageView];
    //收藏状态变更
    [[NSNotificationCenter defaultCenter] postNotificationName:CURRENTARTICLE_CHANGED object:nil];
    
    __weak typeof (self) weakSelf = self;
    GLParamBlock faultBlock = ^(NSString *message) {
        [weakSelf requestFault:message];
    };
    
    GLParamBlock  successBlock = ^(LYArticle *art) {
        [weakSelf renderArticle:art];
    };
    
    [requestManager getArticleDetail:successBlock fault:faultBlock ];
}

- (void)renderArticle:(LYArticle *)art
{
    [statusManageView stopRequest];

    self.contentOffset = CGPointZero;

    currentState = glArticleDetailCompleteState;
    articleDetail = art;
    [self renderByFontSize];
}

- (void)requestFault:(NSString *)msg
{
    [statusManageView requestFault];
}

- (void)renderByFontSize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float fontSize = [defaults floatForKey:APP_FONTSIZE];
    if (fontSize < 10) {
        fontSize = appFontsize_normal;
        [defaults setFloat:fontSize forKey:APP_FONTSIZE];
        [defaults synchronize];
    }
//    articleDetail.summary = @"aaaaa xxxx xxxx xxx xxxxxxx xxxxaaaaa xxxx xxxx xxx xxxxxxx xxxxaaaaa xxxx xxxx xxx xxxxxxx xxxx";
    NSMutableString *blockquote = [NSMutableString stringWithString:@""];
    NSString *summary = articleDetail.summary;
    if (summary) {
        summary = [LYUtilityManager stringByTrimmingAllSpaces:summary];
    }
    /*
     客户要求：没有摘要也要显示那两条线、
     */
    if (!summary) {
        summary = @"";
    }
    float quoteSize = fontSize-4;
    [blockquote appendString:@"<hr style=\"margint-top:20px; border:1px #a0a6b0 solid;\
     -webkit-transform:scale(1,0.5);\"/>"];
    [blockquote appendFormat:@"<blockquote style='margin:10px 0px 10px 0px;padding:0px;\
     font-color:#9096a0;font-size:%fpx;line-height:%fpx\
     border-bottom:1px #ff0000 solid;transform: scaleY(0.5);'>",quoteSize,quoteSize*1.5];
    [blockquote appendString:summary];
    [blockquote appendString:@"</blockquote>"];
    [blockquote appendString:@"<hr style=\"border:1px #a0a6b0 solid; -webkit-transform:scale(1,0.5)\"/>"];
    
    
    NSString *author = @"";
    if (articleDetail.author && ![articleDetail.author isEqualToString:@""]) {
        author = [NSString stringWithFormat:@"作者：%@", articleDetail.author];
    }
    float imgWidth = CGRectGetWidth(self.view.frame)-34;
    
    NSString *html = [NSString stringWithFormat:HTML_CONTENT,imgWidth, articleDetail.title, author, blockquote,fontSize, fontSize*1.5, articleDetail.content];
    [webView loadHTMLString:html baseURL:Nil];
    [headerController updateContentInfo:articleDetail];
    [webView.scrollView addSubview:headerController.view];
   
}

- (void)fontSizeChange
{
    self.contentOffset = webView.scrollView.contentOffset;
    webView.alpha = 0;
    [self renderByFontSize];
}

- (void)reloading:(id)sender
{
    [self loadArticle];
}

- (void)clearContent
{
    [webView setAlpha:0];
}


- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    [self performSelector:@selector(limitHorizontalScroll) withObject:nil afterDelay:0];
    [UIView animateWithDuration:0.3 animations:^{
        webView.alpha = 1;
    }];
}

- (void)limitHorizontalScroll
{
    CGSize contentSize = webView.scrollView.contentSize ;
    contentSize.width  = appWidth;
    [webView.scrollView setContentSize:contentSize];
    [webView.scrollView setContentOffset:self.contentOffset];
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


@end
