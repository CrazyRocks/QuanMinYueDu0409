//
//  LYMagazinesSubNavController.m
//  LYMagazinesStand
//
//  Created by grenlight on 14-5-15.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYMagazinesSubNavController.h"
#import "MagazineCollectionController.h"
#import "LYMagCategorySottingController.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "LYCollectionSearchHeader.h"

@interface LYMagazinesSubNavController ()
{
    LYCollectionSearchHeader *searchHeader;
    
    CGPoint shSchoolCenter, shHomeCenter, cntHomeCenter, cntSchoolCenter;
}
@end

@implementation LYMagazinesSubNavController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

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
        searchHeader.searchType = 0;
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
    return [LYMagCategorySottingController class];
}

- (Class)getListControllerClass
{
    return [MagazineCollectionController class];
}

- (NSArray *)subNavDataSource
{
    return self.categories;
}



#pragma mark subNavigationBar delegate
- (void)navigationBarItemChanged:(int)itemCount
{
    
}

- (void)navigationBarSelectedItem:(NSString *)itemID itemIndex:(NSInteger)index
{
    if (self.currentPageIndex != index) {
        [pagingController changePageCount:(int)(self.categories.count) displayIndex:index];
    }
}

#pragma mark pagingView Delegate
- (void)pagingView:(MagazineCollectionController *)pv preloadPage:(NSInteger)pageIndex
{
    //预先先加载缓存后，就无法自动下拉刷新了？目前没确定原因
    OWSubNavigationItem *cat = self.categories[pageIndex];
    [pv loadLocalData:cat.catID];
}

- (void)pagingView:(MagazineCollectionController *)pv loadPage:(NSInteger)pageIndex
{
    self.currentPageIndex = pageIndex;
    self.currentListController = pv;
    [navigationBar setSelectedIndex:pageIndex];
    
    OWSubNavigationItem *cat = self.categories[pageIndex];
    [(MagazineCollectionController *)self.currentListController renderByCategory:cat.catID];
}


@end
