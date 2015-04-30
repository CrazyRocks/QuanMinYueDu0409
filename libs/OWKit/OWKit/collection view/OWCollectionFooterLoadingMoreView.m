//
//  MagCollectionFooterView.m
//  LYMagazinesStand
//
//  Created by grenlight on 13-12-30.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import "OWCollectionFooterLoadingMoreView.h"

@implementation OWCollectionFooterLoadingMoreView

@synthesize isLoading, owner, delegate;
@synthesize isLastPage = _isLastPage;

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
    [super awakeFromNib];
    self.alpha = 0;
    [_refreshIndicator setHidden:YES];
    [_refreshStatusLabel setHidden:YES];
}

-(void)setupWithOwner:(UIScrollView *)aOwner
{
    [_refreshIndicator setHidden:YES];
    [self setHidden:YES];

    owner = aOwner;
    self.alpha = 0;
    self.isLastPage = YES;
}

- (void)setIsLastPage:(BOOL)isLastPage
{
    _isLastPage = isLastPage;
    if (_isLastPage){
        [self setHidden:YES];
        [_refreshIndicator setHidden:YES];
        [_refreshStatusLabel setHidden:YES];
    }
    else {
        [self setHidden:NO];
        [_refreshIndicator setHidden:NO];
        [_refreshStatusLabel setHidden:NO];
    }
}

//  结束加载动画
- (void)stopLoading
{
    // control
    _isLoading = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self setHidden:YES];
    }];
    [_refreshIndicator stopAnimating];
    [_refreshIndicator setHidden:YES];
    
}

//  开始加载动画
- (void)startLoading
{
    if(_isLastPage) return;
    
    [self setHidden:NO];
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
    if (_isLoading || _isLastPage)
        return;
    
    float offsetBottom = owner.contentSize.height - (owner.contentOffset.y +(owner.bounds.size.height - owner.contentInset.top - owner.contentInset.bottom));
    
    if (offsetBottom > 20)
        return;
    
    [self startLoading];
    if ([delegate respondsToSelector:@selector(loadMoreViewDidCallBack)]) {
        [delegate loadMoreViewDidCallBack];
    }
    
}

-(void)dealloc
{
    [_refreshIndicator stopAnimating];
    
    delegate = nil;
}


@end
