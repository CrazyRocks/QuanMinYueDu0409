//
//  PageScrollView.m
//  DragonSourceReader
//
//  Created by iMac001 on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HorizontalPageScrollView.h"
#import "ArticleDetailMainController.h"
#import <OWCoreText/OWCoreTextLayouter.h>
#import "ArticleDetailController.h"


@interface HorizontalPageScrollView()
{
    NSInteger           pageDisplayed;

    NSInteger           currentRequsted;
    //总页数
    NSInteger           pageCount;
    
    CGRect         pageFrame;
    float          pageWidth;
    
    CommonNetworkingManager *manager;
    
    //当前滚动是否触发翻页
    BOOL           scrollViewCanPaging;
    //上一次的触发滚动时的视图偏移量
    float          scrollViewContentOffsetX;
    
    // 标记滚动是否由用户交互产生
    BOOL           scrollFeedbackFromOtherControl;
        
}
@end

@implementation HorizontalPageScrollView


@synthesize prePage, currentPage, nextPage;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeSharedInstance];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self initializeSharedInstance];
    }
    return self;
}

-(void)initializeSharedInstance
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontsize_changed) name:APP_FONTSIZE_CHANGED object:nil];
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.pagingEnabled = YES;
    [self setCanCancelContentTouches:NO];
    self.delaysContentTouches = NO;
    
    contentCanvas = [[UIView alloc] initWithFrame:self.bounds];
    contentCanvas.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [self insertSubview:contentCanvas atIndex:0];
    self.delegate = self;
    
    pageFrame = self.bounds;
    pageWidth = pageFrame.size.width;
    currentPage = [[ArticleDetailController alloc]init];
    currentPage.delegate = self;
    [currentPage setPagePosition:pageFrame];

    pageFrame.origin.x = -CGRectGetWidth(pageFrame);
    prePage = [[ArticleDetailController alloc]init];
    prePage.delegate = self;
    [prePage setPagePosition:pageFrame];
    
    pageFrame.origin.x = CGRectGetWidth(pageFrame);
    nextPage = [[ArticleDetailController alloc]init];
    nextPage.delegate = self;
    [nextPage setPagePosition:pageFrame];

    prePage.view.autoresizingMask = contentCanvas.autoresizingMask;
    currentPage.view.autoresizingMask = prePage.view.autoresizingMask;
    nextPage.view.autoresizingMask = prePage.view.autoresizingMask;

    [contentCanvas addSubview:prePage.view];
    [contentCanvas addSubview:currentPage.view];
    [contentCanvas addSubview:nextPage.view];
        
    manager = [CommonNetworkingManager sharedInstance];
    
    [self resetLayout];
}

-(void)dealloc
{
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)fontsize_changed
{
    [currentPage fontSizeChange];
    [nextPage fontSizeChange];
    [prePage fontSizeChange];
}

//重设布局，调整文章页在scrollview中的位置
-(void)resetLayout
{
    NSArray *articles = [CommonNetworkingManager sharedInstance].articles;
    pageDisplayed = [CommonNetworkingManager sharedInstance].articleIndex;
    pageCount = articles.count;
    
    self.contentSize = CGSizeMake(pageWidth*articles.count, CGRectGetHeight(pageFrame));
    CGRect canvasFrame = contentCanvas.frame;
    canvasFrame.size.width = pageWidth*articles.count;
    [contentCanvas setFrame:canvasFrame];
    
    pageFrame.origin.x = pageDisplayed * pageWidth;
    [self scrollRectToVisible:pageFrame animated:NO];

    [currentPage setPagePosition:pageFrame];
    [currentPage setArticle:articles[pageDisplayed]];
    
    pageFrame.origin.x = (pageDisplayed + 1) * pageWidth;
    [nextPage setPagePosition:pageFrame];
    if(pageDisplayed < (articles.count -1))
        [nextPage setArticle:articles[(pageDisplayed+1)]];
    
    NSInteger pageIndex = pageDisplayed -1;
    pageFrame.origin.x = pageIndex * pageWidth;

    if (pageIndex < 0) {
        pageFrame.origin.x = pageIndex * pageWidth;
    }
    else {
        [prePage setArticle:articles[pageIndex]];
    }
    [prePage setPagePosition:pageFrame];    
}

- (void)switchPage
{
    int pageToDisplay = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (pageToDisplay == pageDisplayed) {
        scrollViewCanPaging = NO;
		return;
	}//下一页
    else if (pageToDisplay == pageDisplayed+1) {
        
        //不是最后一页时，才加载下一页
        if(pageToDisplay+1 < pageCount){
            pageFrame.origin.x = pageWidth * (pageToDisplay+1);
            [prePage setPagePosition:pageFrame];
            [prePage setArticle:[CommonNetworkingManager sharedInstance].articles[(pageToDisplay+1)]];
        }        
        ArticleDetailController *temp = currentPage;
        currentPage = nextPage;
        nextPage = prePage;
        prePage = temp;
        
	}//上一页
    else {
        //不是第一页时，才加载上一页
        if(pageToDisplay == pageDisplayed-1){
            if (pageToDisplay-1 >= 0) {
                pageFrame.origin.x = pageWidth*(pageToDisplay-1);
                [nextPage setPagePosition:pageFrame];
                [nextPage setArticle:[CommonNetworkingManager sharedInstance].articles[(pageToDisplay-1)]];
            }
        }
        ArticleDetailController *temp = currentPage;
        currentPage = prePage;
        prePage = nextPage;
        nextPage = temp;
        
    }    
    scrollViewCanPaging = YES;
    pageDisplayed = pageToDisplay;
    //同步文章索引
    [CommonNetworkingManager sharedInstance].articleIndex = pageDisplayed;

}

-(void)renderArticle
{
    [currentPage loadArticle];
}

/*
 scrollview  delegate method
 */

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    //这个方法会被多个场景调用（分页控件，旋转屏幕，resizing),
    //此处只对用户dragging触发的调用进行处理
    if (scrollFeedbackFromOtherControl) {
        return;
    }
    //调整页面位置与渲染分开，解决快速滚动时的页面衔接
    [self switchPage];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [currentPage hideAccessoryView];
    scrollFeedbackFromOtherControl = NO;
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    scrollFeedbackFromOtherControl = YES;
    [self renderArticle];
}

/*
 page delegate
 */
-(void)pageView_ScrollEnable:(BOOL)bl
{

}

@end
