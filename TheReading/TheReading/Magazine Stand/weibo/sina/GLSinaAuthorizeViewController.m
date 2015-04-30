//
//  SinaAuthorizeViewController.m
//  WeiBo_Test
//
//  Created by iMac001 on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GLSinaAuthorizeViewController.h"
#import "GLCommentManager.h"
#import "LYSinaWeiboConstants.h"
#import <QuartzCore/QuartzCore.h>

@interface GLSinaAuthorizeViewController ()
{
    //正常坐标及动画预置坐标
    CGPoint normalCenter, preCenter;
}
@end


@implementation GLSinaAuthorizeViewController

@synthesize delegate;

static GLSinaAuthorizeViewController * sharedInstance;

- (id)init
{
    self = [super initWithNibName:@"GLSinaAuthorizeViewController" bundle:nil];
    if (self) {
        sharedInstance = self;
        [sharedInstance initializeSharedInstance];
    }
    return self;
}

- (void)initializeSharedInstance
{
}

+ (GLSinaAuthorizeViewController *) sharedInstance{
//    @synchronized(self){
//        if (sharedInstance == nil){
//            sharedInstance = [[self alloc] init];
//            [sharedInstance initializeSharedInstance];
//        }
//        return(sharedInstance);
//    }
    return sharedInstance;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [webView setDelegate:self];
    
    //去掉webView的shadow
    for (int x = 0; x < 10; ++x) {
        [[webView.scrollView subviews][x] setHidden:YES];
    }
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView setCenter:webView.center];
    [self.view addSubview:indicatorView];
    [indicatorView startAnimating];
}

- (void)loadRequestWithURL:(NSURL *)url
{
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)show:(BOOL)animated
{
    [webView setAlpha:0];
}

- (void)hide
{
}

-(IBAction)quit:(id)sender
{
    if (delegate) {
        [delegate authorizeViewDidCancel:self];
    }
}

-(void)dealloc
{
    [indicatorView stopAnimating];

    delegate = nil;
    [webView loadHTMLString:@"" baseURL:nil];
    [webView stopLoading];
    webView.delegate = nil;
    [webView removeFromSuperview];
    webView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
//    NSLog(@"SinaAuthorizeViewController---------dealloc");
}


#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    [indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [indicatorView stopAnimating];

}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
//    NSLog(@"url = %@", url);
    
    NSString *siteRedirectURI = [NSString stringWithFormat:@"%@%@", kSinaWeiboSDKOAuth2APIDomain, kAppRedirectURI];
    
    if ([url hasPrefix:kAppRedirectURI] || [url hasPrefix:siteRedirectURI])
    {
        NSString *error_code = [LYSinaWeiboRequest getParamValueFromUrl:url paramName:@"error_code"];
        
        if (error_code)
        {
            NSString *error = [LYSinaWeiboRequest getParamValueFromUrl:url paramName:@"error"];
            NSString *error_uri = [LYSinaWeiboRequest getParamValueFromUrl:url paramName:@"error_uri"];
            NSString *error_description = [LYSinaWeiboRequest getParamValueFromUrl:url paramName:@"error_description"];
            
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       error, @"error",
                                       error_uri, @"error_uri",
                                       error_code, @"error_code",
                                       error_description, @"error_description", nil];
            
            [self hide];
            [delegate authorizeView:self didFailWithErrorInfo:errorInfo];
        }
        else
        {
            NSString *code = [LYSinaWeiboRequest getParamValueFromUrl:url paramName:@"code"];
            if (code)
            {
                [self hide];
                [delegate authorizeView:self didRecieveAuthorizationCode:code];
            }
        }
        
        return NO;
    }
    
    return YES;
}

@end
