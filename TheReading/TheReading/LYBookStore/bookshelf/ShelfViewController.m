//
//  ShelfViewController.m
//  LYEPUBReader
//
//  Created by grenlight on 14/6/13.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "ShelfViewController.h"
#import "LYBookShelfController.h"
#import "LYBookConfig.h"
#import "LYShelfFilterController.h"
#import <POP/POP.h>
#import "LYBookAddUserGuide.h"
#import "ShelfViewController+SlideMenu.h"
#import "LYSettingViewController.h"

@interface ShelfViewController ()
{
    LYBookShelfController *bookShelf;
    LYBookShelfController *magShelf;
    
    OWViewController    *currentController;
    
    LYShelfFilterController *filterController;
    
    ShelfSearchController *searchHeader;
    CGPoint shSchoolCenter, shHomeCenter, cntHomeCenter, cntSchoolCenter;
}
@end

@implementation ShelfViewController

- (id)init
{
    self = [super initWithNibName:@"ShelfViewController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        [LYBookConfig sharedInstance].bookShelfMode = lyBorrowMode;

        bookShelf = [[LYBookShelfController alloc] initWithNoneNavigationBar];
        magShelf.bookType = lyBook;
        [self addChildViewController:bookShelf];
        
        magShelf = [[LYBookShelfController alloc] initWithNoneNavigationBar];
        magShelf.bookType = lyMagazine;
        [self addChildViewController:magShelf];
        
        searchHeader = [ShelfSearchController new];
        searchHeader.delegate = self;
        [self addChildViewController:searchHeader];
        
        filterController = [[LYShelfFilterController alloc] init];
        [self addChildViewController:filterController];
        
        self.slideMenuController = [LYShelfSlideMenuController new];
        [self addChildViewController:self.slideMenuController];
        
        isFilterPanelVisible = NO;
                
        [self addNotification];
    }
    return self;
}

- (void)releaseData
{
    contentView.delegate = nil;
}

- (void)addNotification
{
    __unsafe_unretained typeof (self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"LYShelfFilter" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf filter:nil];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:BOOKSHELF_SHOW_SEARCHBAR object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (weakSelf && [weakSelf isViewLoaded]) {
            [weakSelf showSearchBar];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:BOOKSHELF_HIDE_SEARCHBAR object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (!weakSelf || ![weakSelf isViewLoaded]) {
            return ;
        }
        [weakSelf->searchHeader quitSearch];
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf->searchHeader.view.center = weakSelf->shHomeCenter;
            weakSelf->contentView.center = weakSelf->cntHomeCenter;
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"LYShelfSearch" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (weakSelf && [weakSelf isViewLoaded]) {
            [weakSelf addMaskView];
        }
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [OWColor colorWithHexString:@"#fafafa"];
    [navBar setTitle:@"我的书架"];
    
    //二维码用户指引
    [[LYBookAddUserGuide sharedUserGuide] addUserGuide:self];

    magShelf.view.frame = contentView.bounds;
    [contentView insertSubview:magShelf.view atIndex:0];
    
    CGRect rect = contentView.bounds;
    rect.origin.x = appWidth;
    bookShelf.view.frame = rect;
    [contentView insertSubview:bookShelf.view atIndex:0];
    contentView.contentSize = CGSizeMake(appWidth*2, CGRectGetHeight(contentView.frame));
    contentView.delegate = self;
    [self intoPage:0];
    
    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"书架模块顶部SegmentedControl"];
    [segmentControl setStyle:style];
    
    self.panGuestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:self.panGuestureRecognizer];
    
    menuHomeCenter = CGPointMake(-appWidth/2.0f, appHeight/2.0f);
    menuSchoolCenter = CGPointMake(appWidth/2.0f - 64, appHeight/2.0f);
    self.isMenuOpened = NO;
    self.touchMoving = NO;
    
    
    isHorizontalLayout = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self renderSearchHeader];
}

#pragma mark layout
- (void)layout:(id)sender
{
    if (isHorizontalLayout) {
        [bookShelf verticalLayout:nil];
        [magShelf verticalLayout:nil];
        [layoutButton setImage:[UIImage imageNamed:@"shelf_layout_verticle"] forState:UIControlStateNormal];
        
        isHorizontalLayout = NO;
    }
    else {
        [bookShelf horizontalLayout:nil];
        [magShelf horizontalLayout:nil];
        [layoutButton setImage:[UIImage imageNamed:@"shelf_layout_horizontal"] forState:UIControlStateNormal];

        isHorizontalLayout = YES;
    }
}

#pragma mark 显示搜索条
- (void)showSearchBar
{
    [UIView animateWithDuration:0.2 animations:^{
        self->searchHeader.view.center = self->shSchoolCenter;
        self->contentView.center = self->cntSchoolCenter;
    }];
}

- (void)renderSearchHeader
{
    shHomeCenter = CGPointMake(appWidth/2.0f, 64- 49/2.0f);
    shSchoolCenter = shHomeCenter;
    shSchoolCenter.y += 49 + 1;
    
    if (![searchHeader isViewLoaded]) {
        searchHeader.view.center = shHomeCenter;
        [self.view insertSubview:searchHeader.view atIndex:0];
    }
    
    cntHomeCenter = CGPointMake(appWidth/2.0f, 64 + CGRectGetHeight(contentView.frame)/2.0f);
    cntSchoolCenter = cntHomeCenter;
    cntSchoolCenter.y += 49;
}

#pragma mark 整理书架
- (void)editShelf
{
    [bookShelf beginEdit];
    [magShelf beginEdit];
}

- (void)segmentedValueChanged:(KWFSegmentedControl *)sender
{
    [self intoPage:sender.selectedSegmentIndex];
}

- (void)intoPage:(NSInteger)page
{
    CGPoint offset = CGPointMake(appWidth*page, 0);
    [UIView animateWithDuration:0.3 animations:^{
        contentView.contentOffset = offset;
    } completion:^(BOOL finished) {
       
    }];
}

- (void)scanButtonTapped:(id)sender
{
    [searchHeader quitSearch];
    [self hideFilter];
    
    [[LYBookAddUserGuide sharedUserGuide] removeUserCuide];
}

- (void)setting:(id)sender
{
    [[OWNavigationController sharedInstance] pushViewController:[[LYSettingViewController alloc] init] animationType:owNavAnimationTypeSlideFromBottom];
}

- (void)updateStatusBarStyle
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
   
}

- (void)filter:(UIButton *)sender
{
    if (isFilterPanelVisible) {
        [self hideFilter];
    }
    else {
        [self showFilter];
    }
    
}

- (void)maskViewTapped
{
    [self hideFilter];
    [self closeSlideMenu:nil];
    [searchHeader quitSearch];
}

#pragma mark mask
- (void)addMaskView
{
    if (!filterBGMask) {
        filterBGMask = [[UIView alloc] initWithFrame:self.view.bounds];
        filterBGMask.backgroundColor = [OWColor colorWithHexString:@"#0a000000"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped)];
        [filterBGMask addGestureRecognizer:tap];
    }
    filterBGMask.alpha = 0.5;
    [self.view addSubview:filterBGMask];
}

- (void)fadeInMaskView
{
    [self addMaskView];
    filterBGMask.alpha = 0;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        filterBGMask.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)fadeOutMaskView
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        filterBGMask.alpha = 0;
    } completion:^(BOOL finished) {
        [filterBGMask removeFromSuperview];
    }];
}

- (void)showFilter
{
    isFilterPanelVisible = YES;

    [self fadeInMaskView];
    
    filterController.view.center = CGPointMake(appWidth/2.0f, appHeight + CGRectGetHeight(filterController.view.frame)/2.0f);
    [self.view insertSubview:filterController.view aboveSubview:filterBGMask];
    [filterController refreshData];

    CGPoint center = CGPointMake(appWidth/2.0f, appHeight - CGRectGetHeight(filterController.view.frame)/2.0f);
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    positionAnimation.toValue = @(center.y);
    positionAnimation.springBounciness = 10;
    [filterController.view pop_addAnimation:positionAnimation forKey:@"positionAnimation"];

}

- (void)hideFilter
{
    [self fadeOutMaskView];

    [self hideFilterRetainMask];
}

- (void)hideFilterRetainMask
{
    isFilterPanelVisible = NO;
    CGPoint center = CGPointMake(appWidth/2.0f, appHeight + CGRectGetHeight(filterController.view.frame)/2.0f );
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        filterController.view.center = center;
    } completion:^(BOOL finished) {
        [filterController.view removeFromSuperview];
    }];
}


#pragma mark SearchBar delegate
- (void)shelfFilterButtonTapped
{
    [self filter:nil];
}

- (void)shelfSearchedByKey:(NSString *)key
{
    
}

#pragma mark scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0) {
        [segmentControl setSelectedSegmentIndex:0];
    }
    else {
        [segmentControl setSelectedSegmentIndex:1];
    }
}
@end
