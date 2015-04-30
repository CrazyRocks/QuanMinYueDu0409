//
//  TableLoadMoreView.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-30.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "TableLoadMoreView.h"

@implementation TableLoadMoreView
@synthesize isLoading, owner, delegate;
@synthesize isLastPage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setupWithOwner:(UIScrollView *)aOwner
{
    [_refreshIndicator setHidden:YES];
    owner = aOwner;
    self.alpha = 0;
    isLastPage = NO;
}

//  结束加载动画
- (void)stopLoading
{
    // control
    _isLoading = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    }];
    [_refreshIndicator stopAnimating];
    [_refreshIndicator setHidden:YES];
    
}

//  开始加载动画
- (void)startLoading {
    if(isLastPage) return;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
    _isLoading = YES;
    [_refreshIndicator setHidden:NO];
    [_refreshIndicator startAnimating];
    
}

- (void)startLoadingWithMessage:(NSString *)msg
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
    [_refreshIndicator setHidden:NO];
    [_refreshIndicator startAnimating];
    [_refreshStatusLabel setText:msg];
}

- (void)stopLoadingWithMessage:(NSString *)msg
{
    [_refreshIndicator stopAnimating];
    [_refreshIndicator setHidden:YES];
    [_refreshStatusLabel setText:msg];

}


// refreshView 拖动结束后
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
{
    if (_isLoading || isLastPage)
        return;
    
    if (owner.contentOffset.y < appHeight) 
        return;
    
    if(ABS(owner.contentOffset.y) > (owner.contentSize.height - CGRectGetHeight(owner.bounds)-CGRectGetHeight(self.bounds)/2.0)){
        [self startLoading];
        if ([delegate respondsToSelector:@selector(loadMoreViewDidCallBack)]) {
            [delegate loadMoreViewDidCallBack];
        }
    }
   
}

-(void)dealloc
{
    [_refreshIndicator stopAnimating];

    delegate = nil;
}

@end
