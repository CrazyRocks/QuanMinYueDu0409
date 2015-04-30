//
//  GLPagingView.m
//  PublicLibrary
//
//  Created by grenlight on 14-3-7.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWPagingViewController.h"
#import "PathStyleGestureController.h"
#import "OWViewController.h"

@interface OWPagingViewController()
{    
    NSInteger           currentRequsted;
    
    CGRect         pageFrame;
    CGPoint        pageCenter;
    float          pageWidth;
    
    //当前滚动是否触发翻页
    BOOL           scrollViewCanPaging;
    //上一次的触发滚动时的视图偏移量
    float          scrollViewContentOffsetX;
    
    // 标记滚动是否由用户交互产生
    BOOL           scrollFeedbackFromOtherControl;
    
    //开始滚动的第一帧
    BOOL           isFirstScrollFrame;
    //滚动的开始坐标
    float          startScrollOffsetX;
}

@end


@implementation OWPagingViewController

@synthesize prePage, currentPage, nextPage;
@synthesize pageCount,pageDisplayed;

- (void)loadView
{
    _scrollView = [[UIScrollView alloc] init];
    self.view = _scrollView;
}

- (void)releaseData
{
    _scrollView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeSharedInstance];
    
    if (currentPage) {
        [self restoreViews];
    }
}

-(void)initializeSharedInstance
{
    _scrollView.showsVerticalScrollIndicator   = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled                  = YES;
    _scrollView.bounces                        = NO;
    [_scrollView setCanCancelContentTouches:YES];
    _scrollView.delaysContentTouches           = NO;
    _scrollView.delegate                       = self;
    _scrollView.contentInset = UIEdgeInsetsZero;

    _scrollView.backgroundColor = [UIColor clearColor];
    
}

- (void)completeConfig
{
    [self addChildViewController:prePage];
    [self addChildViewController:currentPage];
    [self addChildViewController:nextPage];
    
    [self loadSubview];
}

- (void)loadSubview
{
    pageCenter = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0f, CGRectGetMidY(_scrollView.bounds));

    pageFrame = _scrollView.bounds;
    pageWidth = pageFrame.size.width;

    [currentPage.view setFrame:pageFrame];
    
    pageFrame.origin.x = -CGRectGetWidth(pageFrame);
    [prePage.view setFrame:pageFrame];
    
    pageFrame.origin.x = CGRectGetWidth(pageFrame);
    [nextPage.view setFrame:pageFrame];
    
//    [_scrollView addSubview:prePage.view];
    [_scrollView addSubview:currentPage.view];
//    [_scrollView addSubview:nextPage.view];
    
    [PathStyleGestureController sharedInstance].canLeftMove = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect frame = currentPage.view.frame;
    frame.size.height = CGRectGetHeight(self.view.bounds);
    currentPage.view.frame = frame;
    
    frame = prePage.view.frame;
    frame.size.height = CGRectGetHeight(self.view.bounds);
    prePage.view.frame = frame;
    
    frame = nextPage.view.frame;
    frame.size.height = CGRectGetHeight(self.view.bounds);
    nextPage.view.frame = frame;
}

-(void)dealloc
{
    for (OWViewController *controller in self.childViewControllers) {
        [controller.view removeFromSuperview];
        [controller releaseData];
    }
      _scrollView.delegate = nil;
    [self releaseData];
}

- (void)restoreViews
{
    [self loadSubview];
    [self resetLayout];
}

- (void)changePageCount:(NSInteger)count displayIndex:(NSInteger)pageIndex
{
    if (count > 0) {
        pageCount = count;
    }
    pageDisplayed = pageIndex;
    [self resetLayout];
}

- (void)changePathStyleControllerMoveStatus
{
    if (pageDisplayed > 0) {
        [PathStyleGestureController sharedInstance].canLeftMove = NO;
        [PathStyleGestureController sharedInstance].canRightMove = NO;
    }
    else {
        [PathStyleGestureController sharedInstance].canLeftMove = YES;
        [PathStyleGestureController sharedInstance].canRightMove = YES;
    }
}

//重设布局，调整页在scrollview中的位置
- (void)resetLayout
{
    [self changePathStyleControllerMoveStatus];
    
    _scrollView.contentSize = CGSizeMake(pageWidth*pageCount, CGRectGetHeight(_scrollView.bounds));
    
    pageFrame.origin.x = pageDisplayed * pageWidth;
    [_scrollView scrollRectToVisible:pageFrame animated:NO];
    
    [currentPage.view setFrame:pageFrame];
    [self.pagingDelegate pagingView:currentPage preloadPage:pageDisplayed];
    [self.pagingDelegate pagingView:currentPage loadPage:pageDisplayed];
    
    pageFrame.origin.x = (pageDisplayed + 1) * pageWidth;
    [nextPage.view setFrame:pageFrame];
    
    if (pageDisplayed < (pageCount -1))
        [self.pagingDelegate pagingView:nextPage preloadPage:(pageDisplayed+1)];
    
    NSInteger pageIndex = pageDisplayed - 1;
    pageFrame.origin.x = pageIndex * pageWidth;
    if (pageIndex < 0) {
        pageFrame.origin.x = pageIndex * pageWidth;
    }
    else {
        [self.pagingDelegate pagingView:prePage preloadPage:pageIndex];
    }
    [prePage.view setFrame:pageFrame];
}


- (void)swapPage
{
    NSInteger pageToDisplay = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (pageToDisplay == pageDisplayed) {
        scrollViewCanPaging = NO;
		return;
	}//下一页
    else if (pageToDisplay == pageDisplayed+1) {
        
        //不是最后一页时，才加载下一页
        if (pageToDisplay+1 < pageCount) {
            pageFrame.origin.x = pageWidth * (pageToDisplay+1);
            [prePage.view setFrame:pageFrame];
        }
        OWViewController *temp = currentPage;
        currentPage = nextPage;
        nextPage = prePage;
        prePage = temp;
        
	}//上一页
    else {
        //不是第一页时，才加载上一页
        if (pageToDisplay == pageDisplayed-1) {
            if (pageToDisplay-1 >= 0) {
                pageFrame.origin.x = pageWidth*(pageToDisplay-1);
                [nextPage.view setFrame:pageFrame];
            }
        }
        OWViewController *temp = currentPage;
        currentPage = prePage;
        prePage = nextPage;
        nextPage = temp;
    }
    scrollViewCanPaging = YES;
    pageDisplayed = pageToDisplay;
    
    [self changePathStyleControllerMoveStatus];
}


/*
 scrollview  delegate method
 */

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (isFirstScrollFrame) {
        isFirstScrollFrame = NO;
        //当是第一页时，向左
        if (pageDisplayed > 0 || _scrollView.contentOffset.x < 0) {
            [[PathStyleGestureController sharedInstance] cancelAnyGestureRecognize];
        }
    }
    
    //这个方法会被多个场景调用（分页控件，旋转屏幕，resizing),
    //此处只对用户dragging触发的调用进行处理
    if (scrollFeedbackFromOtherControl) {
        return;
    }
    //调整页面位置与渲染分开，解决快速滚动时的页面衔接
    [self swapPage];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //    [currentPage hideAccessoryView];
    scrollFeedbackFromOtherControl = NO;
    
    isFirstScrollFrame = YES;
    startScrollOffsetX = _scrollView.contentOffset.x;
    
    [self.view addSubview:prePage.view];
    [self.view addSubview:nextPage.view];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    scrollFeedbackFromOtherControl = YES;
    [self.pagingDelegate pagingView:currentPage loadPage:pageDisplayed];
    if (pageDisplayed+1 < pageCount) {
        [self.pagingDelegate pagingView:nextPage preloadPage:pageDisplayed+1];
    }
    if (pageDisplayed > 0) {
        [self.pagingDelegate pagingView:prePage preloadPage:pageDisplayed-1];
    }
    [prePage.view removeFromSuperview];
    [nextPage.view removeFromSuperview];
}

#pragma mark pageview delegate
- (void)pageView_ScrollEnable:(BOOL)bl
{
    
}

@end
