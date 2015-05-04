//
//  WYRootArticleListController.m
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "WYArticleListSubNavController.h"
#import "WYArticleCategorySortingController.h"
#import "WYMenuManager.h"
#import "RecommendArticleListController.h"
#import "WYArticleCategory.h"
#import <LYService/LYService.h>
#import <OWKit/OWKit.h>


@implementation WYArticleListSubNavController


- (Class)getSortingControllerClass
{
    return [WYArticleCategorySortingController class];
}

- (Class)getListControllerClass
{
    return [RecommendArticleListController class];
}

- (NSInteger)getPageCount
{
    return self.menuManager.favoriteCats.count;
}

- (NSArray *)subNavDataSource
{
    if (!_subNavDataSource) {
        _subNavDataSource = self.menuManager.favoriteCats;
    }
    NSString *username = [LYAccountManager getUserName];
    NSString *localFav = [NSString stringWithFormat:@"%@_%@", kFAVCATSBYNAME, username];
    //NSLog(@"\r\n name:%@,cout:%ld", localFav, self.menuManager.favoriteCats.count);
    NSMutableArray *arrayLocal = [[NSMutableArray alloc]init];
    for (OWSubNavigationItem *cellData in self.menuManager.favoriteCats) {
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:cellData];
        [arrayLocal addObject:userData];
    }
    NSArray *localArr = [NSArray arrayWithArray:arrayLocal];
    
    [[NSUserDefaults standardUserDefaults] setObject:localArr forKey:localFav];
    return _subNavDataSource;
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
- (void)pagingView:(RecommendArticleListController *)pv preloadPage:(NSInteger)pageIndex
{
    OWSubNavigationItem *cat = self.menuManager.favoriteCats[pageIndex];
    [pv loadLocalData:cat.catID];
}

- (void)pagingView:(RecommendArticleListController *)pv loadPage:(NSInteger)pageIndex
{
    self.currentPageIndex = pageIndex;
    self.currentListController = pv;
    [navigationBar setSelectedIndex:pageIndex];

    OWSubNavigationItem *cat = self.menuManager.favoriteCats[pageIndex];

    if (![[OWAccessManager sharedInstance] isRefreshedCategory:cat.catID]) {
        [(RecommendArticleListController *)self.currentListController requestArticleList:cat.catID];
    }
}

@end
