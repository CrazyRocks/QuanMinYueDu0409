//
//  RequestStatusViewManager.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-11.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "RequestStatusManageView.h"
#import "OWActivityIndicatorView.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "OWViewController.h"

@implementation RequestStatusManageView

@synthesize  msgViewFrame;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    self.frontColor = [UIColor blackColor];
}

- (void)dealloc
{
    [self stopRequest];
    [indicatorView removeFromSuperview];
    indicatorView = nil;
    self.loadingMessage = nil;
    self.errorMessage = nil;
    self.frontColor = nil;
}

- (BOOL)isInternetReachable
{
   return [AFNetworkReachabilityManager sharedManager].isReachable;
}

- (void)startRequest
{
    [reloadButton setHidden:YES];

    [self startIndicatorViewAnimation];
}

- (void)stopRequest
{
    [self stopIndicatorViewAnimation];
}

- (void)requestFault
{
    [self stopRequest];
    
    if (!reloadButton) {
        reloadButton = [UIButton buttonWithType:UIButtonTypeCustom] ;
        [reloadButton setFrame:CGRectMake(0, 0, appWidth, 40)];
        [reloadButton addTarget:self action:@selector(networkMessageViewTapped) forControlEvents:UIControlEventTouchUpInside];
        [reloadButton setTitle:self.errorMessage forState:UIControlStateNormal];
        [reloadButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    CGPoint center = CGPointMake(appWidth / 2.0f, CGRectGetMidY(self.bounds) - 44);
    [reloadButton setCenter:center];
    [self addSubview:reloadButton];
    [reloadButton setHidden:NO];
    self.hidden = NO;
}


#pragma mark networkMessageViewController delegate
- (void)networkMessageViewTapped
{
    [self.parentViewController reloading:nil];
}

#pragma mark OWShimmeringView

- (void)createIndicatorView
{
    if (!indicatorView) {
        indicatorView = [[OWShimmeringView alloc] initWithMessage:self.loadingMessage];
        [indicatorView setCenter:CGPointMake(appWidth/2.0f, CGRectGetHeight(self.bounds)/2.0f-30)];
    }
    indicatorView.frontColor = self.frontColor;
    
    [self addSubview:indicatorView];
    [indicatorView setHidden:NO];

}

- (void)startIndicatorViewAnimation
{
    self.hidden = NO;

    [self createIndicatorView];
}

- (void)stopIndicatorViewAnimation
{
    [indicatorView setHidden:YES];
    self.hidden = YES;

}
@end
