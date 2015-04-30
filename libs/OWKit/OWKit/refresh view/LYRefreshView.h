//
//  RefreshView.h
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshView.h" 
#import "UIStyleObject.h"

@protocol RefreshViewDelegate;

@interface LYRefreshView : UIView
{
    __weak IBOutlet UIImageView             *_refreshArrowImageView;
    __weak IBOutlet UIActivityIndicatorView *_refreshIndicator;
    __weak IBOutlet UILabel                 *_refreshStatusLabel;
    
    // control
    BOOL _isLoading;
    BOOL _isDragging;
}
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic,assign,readonly) BOOL isLoading;
@property (nonatomic,weak) UIScrollView *owner;
@property (nonatomic,assign)  id<RefreshViewDelegate> delegate;

- (void)setupWithOwner:(UIScrollView *)aOwner ;

- (void)setStyle:(UIStyleObject *)style;

// 开始加载和结束加载动画
- (void)startLoading;
- (void)stopLoading;

// 拖动过程中
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end

