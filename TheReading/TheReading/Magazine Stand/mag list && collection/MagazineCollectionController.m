//
//  SubscriptionCollectionController.m
//  PublicLibrary
//
//  Created by grenlight on 13-12-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "MagazineCollectionController.h"
#import "MagCVCell.h"
#import "MagCatelogueListController.h"
#import "MagsStandGradientBG.h"
#import "LYMagazinesStandController.h"
#import "LYMagReaderViewController.h"
#import "LYMagazineGlobal.h"
#import <OWKit/OWKit.h>
#import "MagIssuesColllectionController.h"

@interface MagazineCollectionController ()
{    
    CGPoint shSchoolCenter, shHomeCenter, cntHomeCenter, cntSchoolCenter;
}
@end

@implementation MagazineCollectionController

- (id)init
{
    self = [super initWithNibName:@"MagazineCollectionController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.isLocalMagazine = NO;
    self.isMagazineIssue = NO;
    
    requestManager = [[LYMagazineManager alloc] init];
    self.collectionViewLayoutStyle = lyCVLayoutStyleNone;
    
    pageIndex = 1;
    pageCount = 0;
    
    isEditMode = NO;
    isNoneData = NO;
}

#pragma mark 解决在 iOS7 下报Assertion failure in -[UIView layoutSublayersOfLayer:的bug
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.view layoutSubviews];
}

- (NSString *)loadingMessage
{
    return @"正在获取杂志列表";
}

- (NSString *)errorMessage
{
    if (self.isLocalMagazine) {
        return @"还没有您下载的杂志";
    }
    else if (isLocalData) {
        return @"";
    }
    else if (![CommonNetworkingManager sharedInstance].isReachable) {
        return HTTPREQEUST_NONE_NETWORK;
    }
    else {
        return NONE_COMTENT_ERROR;
    }
}

- (NSString *)refreshViewTitle
{
    return @"中国全民移动阅读书库";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    noDataMessage = @"没有杂志数据";
        
    self.view.backgroundColor = _collectionView.backgroundColor = [OWColor colorWithHexString:@"#fafafa"];
}

#pragma mark config collectionview
- (void)configCollectionViewLayout
{
     //使用自定义的UICollectionViewFlowLayout 加载不了 header & footer,应该是实现里没有包含这一块的处理
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(99, 155);
    [layout setSectionInset:UIEdgeInsetsMake(10, 5, 24, 5)];
    [layout setMinimumInteritemSpacing:0];
    [layout setFooterReferenceSize:CGSizeMake(appWidth, 107)];
    
    if (isPad) {
        layout.itemSize = CGSizeMake(150, 102 * 150/79.0F + 43);
        layout.sectionInset = UIEdgeInsetsMake(25, 30, 40, 30);
    }
}

- (BOOL)ifNeedsDrop_DownRefresh
{
    if (self.isLocalMagazine) {
        return NO;
    }
    return YES;
}

- (BOOL)ifNeedsLoadingMore
{
    if (self.isLocalMagazine) {
        return NO;
    }
    return YES;
}

- (Class)cellClass
{
    return [MagCVCell class];
}

- (Class)refreshViewClass
{
    return [LYRefreshView2 class];
}

- (void)configCell:(MagCVCell *)cell data:(id)data indexPath:(NSIndexPath *)indexPath
{
    [cell setContent:data];
    
    [self addedCellIfNeedsShake:cell];
}


#pragma mark operate data
- (void)renderByCategory:(NSString *)category
{
    if ([_collectionView.collectionViewLayout respondsToSelector:@selector(setLayoutStyle:)]) {
        ((MagCVLayout *)_collectionView.collectionViewLayout).layoutStyle
        = self.collectionViewLayoutStyle;
    }

    currentCategory = category;
    [self autoRefresh];
}


//加载完本地数据之后再加载远程数据
- (void)loadLocalData:(NSString *)category
{
    if ([currentCategory isEqualToString:category] && dataSource && dataSource.count > 0) {
        return ;
    }
    
    isLocalData = YES;
    currentCategory = category;
    pageCount = 1;
    pageIndex = 1;
    __unsafe_unretained MagazineCollectionController *weakSelf = self;
    [requestManager getLocalMagazineList:category completion:^(NSArray *arr, NSInteger pCount) {
        weakSelf->pageCount = pCount;
        
        //此时不要显示loading more
        if (weakSelf->loadMoreView)
            weakSelf->loadMoreView.isLastPage = YES;
        
        if (arr && arr.count > 0) {
            weakSelf->isNoneData = NO;
            weakSelf->dataSource = [NSMutableArray arrayWithArray:arr];
            [weakSelf->_collectionView reloadData];
        }
        [weakSelf updateRequestState];
    }];
}

- (void)updateRequestState
{
    if (pageIndex < 2 && (!dataSource || dataSource.count == 0)) {
            [statusManageView requestFault];
    }
    else {
        [statusManageView stopRequest];
    }
}


- (void)excuteRequest
{
    if(self.isLocalMagazine ||
       ![[CommonNetworkingManager sharedInstance] isReachable]) {
        [self updateRequestState];
        return;
    }
    [requestManager getMagazineList:pageIndex
                         byCategory:currentCategory
                    successCallBack:self.requestComplete
                     failedCallBack:self.reqestFault];
}

#pragma mark collection delegate

- (void)addedCellIfNeedsShake:(OWShakeableCVCell *)cell
{
    
}

- (void)collectionView:(UICollectionView *)theCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isEditMode) {
        [self outEditMode];
        return;
    }
    //先隐藏搜索，避免返回时杂志封面动画与封面实际位置错位
     [[NSNotificationCenter defaultCenter] postNotificationName:MAG_HIDE_SEARCHBAR object:nil];
    
    LYMagazineTableCellData *info = dataSource[indexPath.row];
    if (self.isLocalMagazine || self.isMagazineIssue) {
        [[CommonNetworkingManager sharedInstance] setCurrentMagazine:info];
        [CommonNetworkingManager sharedInstance].articleIndex = 0;
        
        MagCVCell *cell = (id)[theCollectionView cellForItemAtIndexPath:indexPath];
        
        CGRect frame = [cell getCoverFrame];
        frame = [[UIApplication sharedApplication].keyWindow convertRect:frame fromView:cell];
        
        [LYMagazineGlobal sharedInstance].isLocalMagazine = self.isLocalMagazine;
        LYMagReaderViewController *controller = [[LYMagReaderViewController alloc] init];
        [[OWNavigationController sharedInstance] pushViewController:controller animated:NO];
        [controller openFromRect:frame cover:[cell getCover]];
    }
    else {
       MagIssuesColllectionController *issuesController = [[MagIssuesColllectionController alloc] initWithMagCell:info];
        [self.navigationController pushViewController:issuesController animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    //显示或隐藏搜索栏
    if (scrollView.contentOffset.y < -5) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MAG_SHOW_SEARCHBAR object:nil];
    }
    else if (scrollView.contentOffset.y > 5) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MAG_HIDE_SEARCHBAR object:nil];
    }
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{    
    if ([_collectionView.collectionViewLayout respondsToSelector:@selector(collectionViewWillBeginDecelerating)] && [_collectionView.collectionViewLayout isKindOfClass:[MagCVLayout class]]) {
           [((MagCVLayout *)_collectionView.collectionViewLayout) collectionViewWillBeginDecelerating];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [super scrollViewDidEndDecelerating:scrollView];
    
    if ([_collectionView.collectionViewLayout respondsToSelector:@selector(collectionViewEndScroll)] && [_collectionView.collectionViewLayout isKindOfClass:[MagCVLayout class]]) {
         [((MagCVLayout *)_collectionView.collectionViewLayout) collectionViewEndScroll];
    }
}

@end
