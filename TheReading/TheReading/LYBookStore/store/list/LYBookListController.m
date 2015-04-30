//
//  LYBookListController.m
//  LYBookStore
//
//  Created by grenlight on 14-5-7.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYBookListController.h"
#import "MyBooksManager.h"
#import "LYBookListCell.h"
#import <LYService/LYService.h>
#import "LYBookDetailController.h"
#import <OWKit/OWKit.h>

@interface LYBookListController ()
{
    MyBooksManager *booksManager;
}
@end

@implementation LYBookListController

- (id)init
{
    self = [super initWithNibName:@"LYBookListController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    booksManager = [MyBooksManager sharedInstance];
}

- (void)releaseData
{
    [super releaseData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    noDataMessage = @"没有图书数据";
    
    self.view.backgroundColor = _collectionView.backgroundColor = [OWColor colorWithHexString:@"#fafafa"];
    
    if (dataSource && dataSource.count > 0) {
        _collectionView.dataSource = self;
        [_collectionView reloadData];
    }
    
    if (isPad) {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
        layout.itemSize = CGSizeMake(150, 118 * 140/80.0F + 47);
        layout.sectionInset = UIEdgeInsetsMake(25, 30, 40, 30);
    }
}

- (Class)cellClass
{
    return  [LYBookListCell class];
}

- (BOOL)ifNeedsDrop_DownRefresh
{
    return YES;
}

- (BOOL)ifNeedsLoadingMore
{
    return YES;
}

- (NSString *)refreshViewTitle
{
    return @"中国全民移动阅读书库";
}

- (Class)refreshViewClass
{
    return [LYRefreshView2 class];
}

- (void)configCell:(LYBookListCell *)cell data:(NSDictionary *)data indexPath:(NSIndexPath *)indexPath
{
    [cell setContent:data];
}

- (void)requestLocalData:(NSString *)cid
{
    if ([categoryID isEqualToString:cid] && dataSource && dataSource.count > 0) {
        return;
    }
    categoryID = cid;
    pageCount = 1;
    isLocalData = YES;
    
    NSArray *arr = [[OWAccessManager sharedInstance] getListByCategory:cid];
    if (arr && arr.count > 0) {
        dataSource = [arr mutableCopy];
    }
    else {
        dataSource = [NSMutableArray new];
    }
    [_collectionView reloadData];
}

- (void)requestList:(NSString *)cid
{
    categoryID = cid;

    [self performSelector:@selector(autoRefresh) withObject:nil afterDelay:0.1];
}

- (void)excuteRequest
{
    [httpRequest cancel];
    NSLog(@"-----excuteRequest---: %@", categoryID);
   httpRequest = [booksManager getBookList:categoryID pageIndex:pageIndex successCallBack:self.requestComplete failedCallBack:self.reqestFault];
}


#pragma mark collection delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = dataSource[indexPath.row];
    LYBookDetailController *detailController = [[LYBookDetailController alloc] init];
    detailController.bookGUID = info[@"BookGuid"];
    detailController.contentInfo = info;
    
    [[OWNavigationController sharedInstance] pushViewController:detailController animationType:owNavAnimationTypeDegressPathEffect];
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

@end
