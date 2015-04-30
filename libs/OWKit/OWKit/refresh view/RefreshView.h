//
//  RefreshView.h
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RefreshViewDelegate;

@interface RefreshView : UIView{
    UIImageView *_refreshArrowImageView;
    UIActivityIndicatorView *_refreshIndicator;
    UILabel *_refreshStatusLabel;
    
    // control
    BOOL _isLoading;
    BOOL _isDragging;
}

@property (nonatomic,assign,readonly) BOOL isLoading;
@property (nonatomic,assign) UIScrollView *owner;
@property (nonatomic,assign)  id<RefreshViewDelegate> delegate;

- (void)setupWithOwner:(UIScrollView *)aOwner ;

// 开始加载和结束加载动画
- (void)startLoading;
- (void)stopLoading;

// 拖动过程中
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end
@protocol RefreshViewDelegate <NSObject>
- (void)refreshViewDidCallBack;
@end
