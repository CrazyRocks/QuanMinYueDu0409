//
//  MagCollectionFooterView.h
//  LYMagazinesStand
//
//  Created by grenlight on 13-12-30.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableLoadMoreView.h"

@interface OWCollectionFooterLoadingMoreView : UICollectionReusableView
{
    __weak IBOutlet UIActivityIndicatorView *_refreshIndicator;
    __weak IBOutlet UILabel                 *_refreshStatusLabel;
    
    // control
    BOOL _isLoading, _isLastPage;
    
}

@property (nonatomic,assign,readonly) BOOL isLoading;
//是否为最后一页
@property (nonatomic,assign) BOOL isLastPage;
@property (nonatomic,assign) UIScrollView *owner;
@property (nonatomic,assign)  id<LoadMoreViewDelegate> delegate;

- (void)setupWithOwner:(UIScrollView *)aOwner ;

// 开始加载和结束加载动画
- (void)startLoading;
- (void)stopLoading;
//
- (void)startLoadingWithMessage:(NSString *)msg;
-(void)stopLoadingWithMessage:(NSString *)msg;

// 拖动过程中
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;

@end
