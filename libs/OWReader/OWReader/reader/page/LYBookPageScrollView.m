//
//  PageScrollView.m
//  DragonSourceReader
//
//  Created by iMac001 on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LYBookPageScrollView.h"
#import "LYBookRenderManager.h"
#import "MyBooksManager.h"
#import "LYBookPageRootController.h"
#import "JRBookDigestManager.h"

@interface LYBookPageScrollView()
{
    NSInteger pageDisplayed;
    NSInteger pageCount; 
    CGRect pageFrame;
    float pageWidth;
    
    LYBookRenderManager *manager;
   
    //当前滚动是否触发翻页
    BOOL scrollViewCanPaging;
    //上一次的触发滚动时的视图偏移量
    float scrollViewContentOffsetX;
    
    // 标记滚动是否由用户交互产生
    BOOL scrollFeedbackFromOtherControl;
    
}
@end

@implementation LYBookPageScrollView


@synthesize prePage, currentPage, nextPage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        pageClass = [PageViewController class];
        
        [self initializeSharedInstance];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame pageClass:(Class)pageClassName
{
    self = [super initWithFrame:frame];
    if (self) {
        pageClass = pageClassName;

        [self initializeSharedInstance];
    }
    return self;
}

//#pragma mark 更新当前页码
//-(void)changeCurrentPageNumbers:(NSNotification *)notification
//{
////    [currentPage getsTheCurrentView];
//}



-(void)initializeSharedInstance
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setScrollViewUserTouchNo) name:@"scrollNo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setScrollViewUserTouchYes) name:@"scrollYes" object:nil];
    
#pragma mark 重新计算后更新通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrentPageNumbers:) name:@"ChangeWordSize_GetScreen" object:nil];
    
    
    //先提取所有书摘
    [[JRBookDigestManager sharedInstance] loadThisBookDigestsAndNotes:[MyBooksManager sharedInstance].currentReadBook];
    
    
    self.backgroundColor = [UIColor clearColor];
    
    self.delaysContentTouches = YES;
    self.delegate = self;
    self.pagingEnabled = YES;
    [self setCanCancelContentTouches:NO];
//    self.delaysContentTouches = NO;

    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    pageFrame = CGRectMake(0, 0, appWidth, appHeight);
    
    pageWidth = pageFrame.size.width;
    currentPage = [[pageClass alloc]init];
    currentPage.delegate = self;
    [currentPage setPagePosition:pageFrame];
    
    
    pageFrame.origin.x = 2*CGRectGetWidth(pageFrame);
    prePage = [[pageClass alloc]init];
    prePage.delegate = self;
    [prePage setPagePosition:pageFrame];
//    [prePage setVideoPlayerShow];
    
    pageFrame.origin.x = CGRectGetWidth(pageFrame);
    nextPage = [[pageClass alloc]init];
    nextPage.delegate = self;
    [nextPage setPagePosition:pageFrame];
//    [nextPage setVideoPlayerShow];
    
    [self addSubview:prePage.view];
    [self addSubview:currentPage.view];
    [self addSubview:nextPage.view];
    
    manager = [LYBookRenderManager sharedInstance];
    
    self.delaysContentTouches = YES;
}

- (void)setPageCount:(NSInteger)count
{
    pageCount = count;
    CGSize size = self.frame.size;
    self.contentSize = CGSizeMake(size.width *count, size.height);
    
    [self.parentController.sliderController setPageCount:pageCount];
}

- (void)setPageDisplayed:(NSInteger)pgIndex
{
    pageDisplayed = pgIndex;

    [self.parentController.sliderController setPageDisplayed:pageDisplayed];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        pageFrame = self.bounds;
        if(pgIndex > 1)
            pageFrame.origin.x = pageWidth * (pgIndex - 2);
        else
            pageFrame.origin.x = pageWidth * (pgIndex + 1);
        
        [prePage.view setFrame:pageFrame];
        
        if(pgIndex < pageCount)
            pageFrame.origin.x = (pageWidth) * pgIndex;
        else
            pageFrame.origin.x = pageWidth*(pgIndex-2);
        
        [nextPage setPagePosition:pageFrame];
        
        pageFrame.origin.x = pageWidth * (pgIndex-1);
        
        [currentPage setPagePosition:pageFrame];
        
        [self scrollRectToVisible:pageFrame animated:NO];
        
        scrollViewContentOffsetX = self.contentOffset.x;
        
    });
   
}

- (void)switchPage
{
    // Switch the page when more than 50% of the previous/next page is visible
    NSInteger pageToDisplay = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 2;
    
    if (pageToDisplay == pageDisplayed) {
        scrollViewCanPaging = NO;
		return;
	}//下一页
    else if (pageToDisplay == pageDisplayed+1) {
        
        //不是最后一页时，才加载下一页
        if(pageToDisplay < pageCount){
            pageFrame.origin.x = pageWidth * pageToDisplay;
            [prePage setPagePosition:pageFrame];
            [prePage setPageInfo:nil :pageToDisplay + 1];
        }
        
        PageViewController *temp = currentPage;
        currentPage = nextPage;
        nextPage = prePage;
        prePage = temp;

	}//上一页
    else {
        
        //不是第一页时，才加载上一页
        if( pageToDisplay == pageDisplayed-1){
            pageFrame.origin.x = pageWidth*(pageToDisplay-2);
            [nextPage setPagePosition:pageFrame];
            [nextPage setPageInfo:nil :pageToDisplay - 1];
        }
        
        PageViewController *temp = currentPage;
        currentPage = prePage;
        prePage = nextPage;
        nextPage = temp;
    }
    
    scrollViewCanPaging = YES;
 
    pageDisplayed = pageToDisplay;
}

/*
 scrollview  delegate method
 */

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    //这个方法会被多个场景调用（分页控件，旋转屏幕，resizing),
    //此处只对用户dragging触发的调用进行处理
    if (scrollFeedbackFromOtherControl) {
        return;
    }
    //调整页面位置与渲染分开，解决快速滚动时的页面衔接
    
    [self switchPage];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.parentController hideAccessory];
    scrollFeedbackFromOtherControl = NO;
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x < 0) {
        [[OWMessageView sharedInstance] showMessage:@"已经是第一页了" autoClose:YES];
    }
    else if ((scrollView.contentOffset.x + appWidth > scrollView.contentSize.width) ) {
        [[OWMessageView sharedInstance] showMessage:@"已经是最后一页了" autoClose:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    scrollFeedbackFromOtherControl = YES;

    //更新界面上的所有文本视图，由文本视图本身去判断是否要更新（页码不变不更新）
    [manager setCurrentPageNumber:pageDisplayed];
}



#pragma mark page delegate
-(void)pageView_ScrollEnable:(BOOL)bl
{
    
}

- (void)pageView_Scrolling
{
    [self.parentController hideAccessory];
}

#pragma mark 设置是否可以滚动
-(void)setScrollViewUserTouchNo
{
    self.scrollEnabled = NO;
}

-(void)setScrollViewUserTouchYes
{
    self.scrollEnabled = YES;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
