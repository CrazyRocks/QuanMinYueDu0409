//
//  FullScreenWebViewController.m
//  GoodSui
//
//  Created by grenlight on 14-2-14.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "FullScreenWebViewController.h"

@interface FullScreenWebViewController ()

@end

@implementation FullScreenWebViewController

+ (FullScreenWebViewController *)sharedInstance
{
    static FullScreenWebViewController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FullScreenWebViewController alloc] init];
    });
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    webView.backgroundColor = self.view.backgroundColor;
    webView.scrollView.backgroundColor = self.view.backgroundColor;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    //去掉webView的shadow
    for (int x = 0; x < ([webView.scrollView subviews].count - 1); ++x) {
        [[webView.scrollView subviews][x] setHidden:YES];
    }
    
    if (!tapGesture) {
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.delegate = self;
        tapGesture.cancelsTouchesInView = NO;
    }
    [self.view addGestureRecognizer:tapGesture];
}

- (void)showImage:(NSString *)url
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.view.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    
    NSString *html = [NSString stringWithFormat:FULLSCREEN_HTML, url];
    [webView loadHTMLString:html baseURL:Nil];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1;
    }];
}

- (void)singleTap
{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];

        [self.view removeFromSuperview];
        self.view = Nil;
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
