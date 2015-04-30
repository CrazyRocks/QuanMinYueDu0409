//
//  RefreshView.m
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "RefreshView.h"
#import "OWImage.h"
#import "OWColor.h"
#define REFRESH_LOADING_STATUS @"正在刷新"
#define REFRESH_PULL_DOWN_STATUS @"下拉刷新"
#define REFRESH_RELEASED_STATUS @"松开立即刷新"
#define REFRESH_UPDATE_TIME_PREFIX @"最后更新: "
#define REFRESH_TRIGGER_HEIGHT 60

@implementation RefreshView
@synthesize isLoading, owner, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect lbFrame = CGRectMake(0, 20, CGRectGetWidth(frame), 20);

        _refreshStatusLabel = [[UILabel alloc]initWithFrame:lbFrame];
        _refreshStatusLabel.textColor = [UIColor whiteColor];
         _refreshStatusLabel.textAlignment = NSTextAlignmentCenter;
        _refreshStatusLabel.backgroundColor = [UIColor clearColor];
       _refreshStatusLabel.shadowColor = [OWColor colorWithHex:0x454545];
        
        
        lbFrame.origin.y = (frame.size.height - 30)/2.0f;
        lbFrame.size = CGSizeMake(12, 30);
        _refreshArrowImageView = [[UIImageView alloc]initWithFrame:lbFrame];
        
        [self addSubview:_refreshArrowImageView];
        [self addSubview:_refreshStatusLabel];
    }
    return self;
}
-(void)setupWithOwner:(UIScrollView *)aOwner{
    owner = aOwner; 
    if(!_refreshIndicator){
        _refreshIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _refreshIndicator.frame = CGRectMake(0, 0, 20.0f, 20.0f);
        [_refreshIndicator setCenter:_refreshArrowImageView.center];
        [_refreshIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_refreshIndicator]; 
    }
    _refreshArrowImageView.image = [OWImage imageWithName:@"blueArrow"];
    
}

// refreshView 结束加载动画
- (void)stopLoading {
    // control
    _isLoading = NO;
    
    // Animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    //    _owner.contentInset = UIEdgeInsetsZero;
    owner.contentOffset = CGPointZero;
    _refreshArrowImageView.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
        
    [_refreshStatusLabel setText: REFRESH_PULL_DOWN_STATUS];
    _refreshArrowImageView.hidden = NO;
    [_refreshIndicator stopAnimating];
}

// refreshView 开始加载动画
- (void)startLoading {
    // control
    _isLoading = YES;
    // Animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    owner.contentOffset = CGPointMake(0, -REFRESH_TRIGGER_HEIGHT);
    owner.contentInset = UIEdgeInsetsMake(REFRESH_TRIGGER_HEIGHT, 0, 0, 0);
    [_refreshStatusLabel setText: REFRESH_LOADING_STATUS];
    _refreshArrowImageView.hidden = YES;
    [UIView commitAnimations];
    [_refreshIndicator startAnimating];

}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_isLoading) return;
    _isDragging = YES;
}
// refreshView 拖动过程中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            scrollView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_TRIGGER_HEIGHT)
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (_isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < - REFRESH_TRIGGER_HEIGHT) {
            // User is scrolling above the header
            [_refreshStatusLabel setText: REFRESH_RELEASED_STATUS];
            _refreshArrowImageView.transform = CGAffineTransformMakeRotation(3.14);
        } else { // User is scrolling somewhere within the header
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
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_isLoading) return;
    _isDragging = NO;
    if (scrollView.contentOffset.y <= - REFRESH_TRIGGER_HEIGHT) {
        if ([delegate respondsToSelector:@selector(refreshViewDidCallBack)]) {
            [delegate refreshViewDidCallBack];
        }
    }
}
-(void)dealloc{
    [_refreshIndicator stopAnimating];
    delegate = nil;
}
@end
