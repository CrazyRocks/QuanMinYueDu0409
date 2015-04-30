//
//  VerticleScrollView.m
//  LYMagazinesStand
//
//  Created by grenlight on 14-3-9.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "VerticleScrollView.h"
#import "ArticleDetailController.h"
#import "NextChapterIndicator.h"

@implementation VerticleScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup:frame];
    }
    return self;
}

- (void)setup:(CGRect)frame
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontsize_changed) name:APP_FONTSIZE_CHANGED object:nil];
    
    NSArray *articles = [CommonNetworkingManager sharedInstance].articles;
    pageDisplayed = [CommonNetworkingManager sharedInstance].articleIndex;
    pageCount = articles.count;

    nextIndicator = [[NSBundle bundleForClass:[self class]] loadNibNamed:@"NextChapterIndicator" owner:self options:nil][0];
    [self addSubview:nextIndicator];
    
    currentCenter = CGPointMake(frame.size.width/2.0f, frame.size.height/2.0f);
    
    preCenter = nextCenter = currentCenter;
    preCenter.y -= frame.size.height;
    nextCenter.y += frame.size.height;
    
    contentView = [[ArticleDetailController alloc] init];
    contentView.view.frame = self.bounds;
    [self insertSubview:contentView.view atIndex:0];
    contentView.scrollView.delegate = self;
    
    [contentView setArticle:articles[pageDisplayed]];
    [contentView loadArticle];

}

- (void)dealloc
{
    contentView.scrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fontsize_changed
{
    [contentView fontSizeChange];
}

#pragma mark scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [nextIndicator scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self animateToNextCatelogue];
}

-(void)animateToNextCatelogue
{
    float temY = contentView.scrollView.contentOffset.y;
    if (temY< -40) {
        if(pageDisplayed == 0) return;
        
        pageDisplayed -= 1;
        [self createContentViewAt:preCenter];
        [self excuteCatelogueChangeAnimate:nextCenter];
    }
    else if (temY >(contentView.scrollView.contentSize.height - CGRectGetHeight(self.bounds) + 60)) {
        if ((pageDisplayed + 1) < pageCount) {
            pageDisplayed += 1;
            [self createContentViewAt:nextCenter];
            [self excuteCatelogueChangeAnimate:preCenter];
        }
    }
}

- (void)createContentViewAt:(CGPoint)center
{
    maskView = contentView;
    maskView.scrollView.delegate = nil;

    contentView = [[ArticleDetailController alloc] init];
    [contentView.view setFrame:self.bounds];
    [contentView.view setCenter:center];
    [self insertSubview:contentView.view atIndex:0];

    contentView.scrollView.delegate = self;
    NSArray *articles =[CommonNetworkingManager sharedInstance].articles;
    [contentView setArticle:articles[pageDisplayed]];
    //同步文章索引
    [CommonNetworkingManager sharedInstance].articleIndex = pageDisplayed;

}

-(void)excuteCatelogueChangeAnimate:(CGPoint)toCenter
{
    [UIView animateWithDuration:0.35 delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [maskView.view setCenter:toCenter];
        [contentView.view setCenter:currentCenter];
        if (toCenter.y < 0)
            [nextIndicator setAlpha:0];
    } completion:^(BOOL finished) {
        [maskView.view removeFromSuperview];
        maskView = nil;
        [nextIndicator goHome];
        [nextIndicator setAlpha:1];
        
        [contentView loadArticle];
        [self setNextIndicatorTitle];
    }];
}

- (void)setNextIndicatorTitle
{
    if (pageDisplayed+1 < pageCount) {
        NSArray *articles =[CommonNetworkingManager sharedInstance].articles;
        LYArticle *article = articles[pageDisplayed+1];
        nextIndicator.label.text = article.title;
    }
    else {
        nextIndicator.label.text = @"";
    }
   
}

@end
