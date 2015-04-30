//
//  GLPagingView.h
//  PublicLibrary
//
//  Created by grenlight on 14-3-7.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWViewController.h"

@protocol OWPagingViewDelegate;

@interface OWPagingViewController : OWViewController<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    CGSize       contentSize;
}
//总页数
@property (nonatomic, assign) NSInteger           pageCount;
@property (nonatomic, assign) NSInteger           pageDisplayed;

@property(nonatomic,retain) OWViewController *prePage;
@property(nonatomic,retain) OWViewController *currentPage;
@property(nonatomic,retain) OWViewController *nextPage;

@property (nonatomic, assign) id<OWPagingViewDelegate>  pagingDelegate;

//完成页的配置
- (void)completeConfig;
//恢复状态
- (void)restoreViews;

//变更总页数及当前显示的页
- (void)changePageCount:(NSInteger)count displayIndex:(NSInteger)pageIndex;


@end

@protocol OWPagingViewDelegate <NSObject>

@required
- (void)pagingView:(OWViewController *)pv preloadPage:(NSInteger)pageIndex;
- (void)pagingView:(OWViewController *)pv loadPage:(NSInteger)pageIndex;

@end
