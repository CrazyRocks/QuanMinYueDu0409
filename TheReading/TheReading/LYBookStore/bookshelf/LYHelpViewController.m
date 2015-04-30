//
//  LYHelpViewController.m
//  LYBookStore
//
//  Created by grenlight on 14/8/28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYHelpViewController.h"

@interface LYHelpViewController ()

@end

@implementation LYHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [navBar setTitle:@"帮助"];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createStatusManageView];
    
    [self performSelector:@selector(loadWebPage) withObject:nil afterDelay:0.5];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    webView.delegate = nil;
}

- (NSString *)errorMessage
{
    return @"网页加载失败，点击重试";
}

- (void)reloading:(id)sender
{
    [self loadWebPage];
}

- (void)loadWebPage
{
    webView.delegate = self;
    NSString *url = @"http://211.100.230.50:8888/dingyue/index-已登录.html";
    NSString *encodeURL =(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  (__bridge CFStringRef)url, nil, nil, kCFStringEncodingUTF8);
    [webView loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL URLWithString:encodeURL]]];
}

#pragma mark webview delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [statusManageView stopRequest];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error:%@",error.description);
    [statusManageView requestFault];
}

- (void)comeback:(id)sender
{
    [[OWNavigationController sharedInstance] popViewController:owNavAnimationTypeSlideToBottom];
}

@end
