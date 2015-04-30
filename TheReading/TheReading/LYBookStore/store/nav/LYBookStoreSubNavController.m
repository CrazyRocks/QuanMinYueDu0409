//
//  LYBookStoreSubNavController.m
//  LYBookStore
//
//  Created by grenlight on 14-5-6.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYBookStoreSubNavController.h"
#import "LYBookCategorySortingController.h"
#import "LYBookListController.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "LYCollectionSearchHeader.h"

@interface LYBookStoreSubNavController ()
{
    LYCollectionSearchHeader *searchHeader;
    CGPoint shSchoolCenter, shHomeCenter, cntHomeCenter, cntSchoolCenter;

}
@end

@implementation LYBookStoreSubNavController


- (void)addNotification
{
    __unsafe_unretained typeof (self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:MAG_SHOW_SEARCHBAR object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf->searchHeader.center = weakSelf->shSchoolCenter;
            weakSelf->pagingController.view.center = weakSelf->cntSchoolCenter;
        }];
        
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MAG_HIDE_SEARCHBAR object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf->searchHeader.center = weakSelf->shHomeCenter;
            weakSelf->pagingController.view.center = weakSelf->cntHomeCenter;
        }];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [OWColor colorWithHexString:@"#fafafa"];
    
    [self addNotification];
}

#pragma mark 解决在 iOS7 下报Assertion failure in -[UIView layoutSublayersOfLayer:的bug
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self renderSearchHeader];
    [self.view layoutSubviews];
}

- (void)renderSearchHeader
{
    if (!searchHeader) {
        searchHeader = [[NSBundle bundleForClass:[LYCollectionSearchHeader class]] loadNibNamed:@"LYCollectionSearchHeader" owner:self options:nil][0];
        searchHeader.searchType = 1;
        shHomeCenter = CGPointMake(appWidth/2.0f, 40-CGRectGetHeight(searchHeader.frame)/2.0f);
        shSchoolCenter = shHomeCenter;
        shSchoolCenter.y += CGRectGetHeight(searchHeader.frame)+ 1;
        searchHeader.center = shHomeCenter;
        [self.view insertSubview:searchHeader atIndex:0];
    }
    
    cntHomeCenter = pagingController.view.center;
    cntSchoolCenter = cntHomeCenter;
    cntSchoolCenter.y += CGRectGetHeight(searchHeader.frame);
}

- (Class)getSortingControllerClass
{
    return [LYBookCategorySortingController class];
}

- (Class)getListControllerClass
{
    return [LYBookListController class];
}

- (NSArray *)subNavDataSource
{
    return self.categories;
}

- (NSInteger)getPageCount
{
    return self.categories.count;
}

#pragma mark subNavigationBar delegate
- (void)navigationBarItemChanged:(int)itemCount
{
    
}

- (void)navigationBarSelectedItem:(NSString *)itemID itemIndex:(NSInteger)index
{
    if (self.currentPageIndex != index) {
        [pagingController changePageCount:(int)([self subNavDataSource].count) displayIndex:index];
    }
}

#pragma mark pagingView Delegate
- (void)pagingView:(LYBookListController *)pv preloadPage:(NSInteger)pageIndex
{
    OWSubNavigationItem *cat = self.categories[pageIndex];
    NSLog(@"pre: %@", cat.catID);
    [pv requestLocalData:cat.catID];
}

- (void)pagingView:(LYBookListController *)pv loadPage:(NSInteger)pageIndex
{
    self.currentPageIndex = pageIndex;
    self.currentListController = pv;
    [navigationBar setSelectedIndex:pageIndex];
    
    OWSubNavigationItem *cat = self.categories[pageIndex];
    NSLog(@"loadPage: %@", cat.catID);

    if (![[OWAccessManager sharedInstance] isRefreshedCategory:cat.catID]) {
        NSLog(@"refreshedCategory: %@", cat.catID);

        [(LYBookListController *)self.currentListController requestList:cat.catID];
    }
}


@end
