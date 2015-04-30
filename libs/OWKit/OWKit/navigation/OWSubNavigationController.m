//
//  OWSubNavigationController.m
//  PublicLibrary
//
//  Created by grenlight on 14-5-6.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWSubNavigationController.h"
#import "PathStyleGestureController.h"
#import "OWUpDownButton.h"


@interface OWSubNavigationController ()
{
    OWViewController        *sortingController;
}
@end

@implementation OWSubNavigationController

@synthesize currentListController;

- (id)init
{
    self = [super initWithNibName:@"OWSubNavigationController" bundle:[NSBundle bundleForClass:[OWSubNavigationController class]]];
    if (self) {
        if ([self ifNeedsSorting]) {
            sortingController = [[[self getSortingControllerClass] alloc] init];
            [self addChildViewController:sortingController];
        }
        
        pagingController = [[OWPagingViewController alloc] init];
        [self addChildViewController:pagingController];
        
        isExpand = NO;
        sortingPanelFrame = CGRectZero;
        self.currentPageIndex = -1;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sorttingControllerItemSelected:) name:@"BCSItemSelected" object:nil];
        
    }
    return self;
}


- (void)dealloc
{
    navigationBar.delegate = nil;
    pagingController.pagingDelegate = Nil;
    [self releaseData];
}

- (BOOL)ifNeedsSorting
{
    return YES;
}

- (void)sorttingControllerItemSelected:(NSNotification *)note
{
    if (![self isViewLoaded] || self.view.window == nil || self.view.superview == nil) {
        return;
    }
    NSDictionary *info= note.userInfo;
    [navigationBar autoTapByIndex:[info[@"selectedIndex"] integerValue] ];
    [self expandCategoriesPanel:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.clipsToBounds = YES;

    pagingController.view.backgroundColor = [UIColor lightGrayColor];
    pagingController.pageCount = [self getPageCount];
    pagingController.pageDisplayed = self.currentPageIndex;
    
    [self.view insertSubview:pagingController.view atIndex:0];
    UIEdgeInsets padding = UIEdgeInsetsMake(41, 0, 0, 0);
    [pagingController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(padding);
    }];
   
    if (self.currentPageIndex == -1) {
        currentListController = [[[self getListControllerClass] alloc] init];
        
        pagingController.prePage = [[[self getListControllerClass] alloc] init];
        pagingController.currentPage = currentListController;
        pagingController.nextPage = [[[self getListControllerClass] alloc] init];
        pagingController.pagingDelegate = self;
        
        self.view.alpha = 0;
    }
    else {
        [pagingController restoreViews];
    }
    
    if (![self ifNeedsSorting]) {
        [udButton removeFromSuperview];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.currentPageIndex == -1) {
        [pagingController completeConfig];
    }
    [self performSelector:@selector(renderContent) withObject:nil afterDelay:0.1];
}

- (void)renderContent
{
    navigationBar.delegate = self;

    if (self.currentPageIndex > -1) {
        [navigationBar renderItems:[self subNavDataSource] selectedIndex:self.currentPageIndex];
    }
    else {
        [navigationBar renderItems:[self subNavDataSource]];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 1;
    }];
}

- (void)setBackgroundColor:(UIColor *)color
{
    self.view.backgroundColor = color;
}

- (IBAction)expandCategoriesPanel:(id)sender
{
    if (CGRectEqualToRect(sortingPanelFrame, CGRectZero)) {
        sortingPanelFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.frame));
        homeCenter = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0f, CGRectGetHeight(sortingPanelFrame)/2.0f);
        schoolCenter = homeCenter;
        schoolCenter.y -= CGRectGetHeight(sortingPanelFrame);
    }
    if (isExpand) {
        [PathStyleGestureController sharedInstance].canLeftMove = YES;
        [PathStyleGestureController sharedInstance].canRightMove = YES;

        self.currentPageIndex = -1;
        
        [navigationBar renderItems:[self subNavDataSource]];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            sortingController.view.center = schoolCenter;
            navigationBar.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        [PathStyleGestureController sharedInstance].canLeftMove = NO;
        [PathStyleGestureController sharedInstance].canRightMove = NO;
        
        [sortingController.view setFrame:sortingPanelFrame];
        sortingController.view.center = schoolCenter;
        [self.view insertSubview:sortingController.view belowSubview:navigationBar];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            sortingController.view.center = homeCenter;
            navigationBar.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
    isExpand = !isExpand;
    [udButton setExpand:isExpand];
}


- (Class)getSortingControllerClass
{
    return nil;
}

- (Class)getListControllerClass
{
    return nil;
}

- (NSInteger)getPageCount
{
    return 0;
}

- (NSArray *)subNavDataSource
{
    return nil;
}

#pragma mark subNavBar delegate
- (float)navigationBarItemWidth
{
    return 80;
}

- (UIEdgeInsets)subNavigationBarEdgeInsets
{
    float rightDistance = 0;
    if ([self ifNeedsSorting]) {
        rightDistance = 31;
    }
    return UIEdgeInsetsMake(0, 0, 0, rightDistance);
}

#
- (void)pagingView:(OWViewController *)pv preloadPage:(NSInteger)pageIndex
{
    
}

- (void)pagingView:(OWViewController *)pv loadPage:(NSInteger)pageIndex
{
    self.currentPageIndex = pageIndex;
}

@end
