//
//  RefreshView.m
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "LYRefreshView.h"
#import "OWImage.h" 

#define REFRESH_LOADING_STATUS @"正在刷新"
#define REFRESH_PULL_DOWN_STATUS @"下拉即可刷新..."
#define REFRESH_RELEASED_STATUS @"松开立即刷新"
#define REFRESH_TRIGGER_HEIGHT 64

@implementation LYRefreshView
@synthesize isLoading, owner, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)setupWithOwner:(UIScrollView *)aOwner
{
    [_refreshIndicator setHidden:YES];
    owner = aOwner;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    _refreshArrowImageView.image =
    [OWImage imageWithName:@"refresh_row" bundle:bundle];
   
}


-(void)dealloc
{
    [_refreshIndicator stopAnimating];
    
    delegate = nil;
}

// refreshView 结束加载动画
- (void)stopLoading
{
    if (!_isLoading) {
        return;
    }
    _isLoading = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    if (owner) {
        owner.contentInset = UIEdgeInsetsZero;
        owner.contentOffset = CGPointZero;
    }
    _refreshArrowImageView.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
        
    [_refreshStatusLabel setText:REFRESH_PULL_DOWN_STATUS];
    _refreshArrowImageView.hidden = NO;
    [_refreshIndicator setHidden:YES];

    [_refreshIndicator stopAnimating];
}

- (void)startLoading
{
    _isLoading = YES;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
//    owner.contentOffset = CGPointMake(0, 0);
    owner.contentInset = UIEdgeInsetsMake(REFRESH_TRIGGER_HEIGHT, 0, 0, 0);
    [_refreshStatusLabel setText:REFRESH_LOADING_STATUS];
    _refreshArrowImageView.hidden = YES;
    [UIView commitAnimations];
    [_refreshIndicator setHidden:NO];

    [_refreshIndicator startAnimating];

}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_isLoading) return;
    _isDragging = YES;
}

// refreshView 拖动过程中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            scrollView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_TRIGGER_HEIGHT)
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (_isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < - REFRESH_TRIGGER_HEIGHT) {
            // User is scrolling above the header
            [_refreshStatusLabel setText: REFRESH_RELEASED_STATUS];
            _refreshArrowImageView.transform = CGAffineTransformMakeRotation(3.14);
        }
        else { // User is scrolling somewhere within the header
            [_refreshStatusLabel setText: REFRESH_PULL_DOWN_STATUS];
            _refreshArrowImageView.transform = CGAffineTransformMakeRotation(0);
        }
        [UIView commitAnimations];
    }
    else if(!_isDragging && !_isLoading){ 
        scrollView.contentInset = UIEdgeInsetsZero;
    }
}

// refreshView 拖动结束后
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_isLoading)
        return;
    
    _isDragging = NO;
    if (scrollView.contentOffset.y <= - REFRESH_TRIGGER_HEIGHT) {
        if ([delegate respondsToSelector:@selector(refreshViewDidCallBack)]) {
            [delegate refreshViewDidCallBack];
        }
    }
}

@end
