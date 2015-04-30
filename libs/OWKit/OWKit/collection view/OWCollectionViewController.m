//
//  OWCollectionViewController.m
//  OWKit
//
//  Created by grenlight on 14/7/22.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWCollectionViewController.h"
#import "OWCollectionFooterLoadingMoreView.h"
#import "LYRefreshView.h"
#import "OWColor.h"

@implementation OWCollectionViewController

- (void)releaseData
{
    [statusManageView stopRequest];
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    [_collectionView removeFromSuperview];
    _collectionView = Nil;
    
    if (loadMoreView) {
        loadMoreView.delegate = nil;
        loadMoreView = nil;
    }
    if (refreshView) {
        refreshView.delegate = nil;
        refreshView = nil;
    }
    [super releaseData];
}

- (void)dealloc
{
    [self releaseData];
    
    [dataSource removeAllObjects];
    dataSource = nil;
}

#pragma mark view progress
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (dataSource && dataSource.count > 0) {
        [statusManageView stopRequest];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [OWColor colorWithHexString:@"#fafafa"];
    
    [self configCollectionView];
    
    if (dataSource && dataSource.count > 0) {
        [_collectionView reloadData];
    }
    else {
        dataSource = [[NSMutableArray alloc] init];
    }
}

#pragma mark collectionView config
- (Class)cellClass
{
    return nil;
}

- (BOOL)ifNeedsDrop_DownRefresh
{
    return NO;
}

- (BOOL)ifNeedsLoadingMore
{
    return NO;
}

- (Class)refreshViewClass
{
    return nil;
}

- (NSString *)refreshViewTitle
{
    return  @"";
}

- (void)registerHeaderNib
{
    UINib *headerNib = [UINib nibWithNibName:@"OWCollectionHeaderView"
                                      bundle:nil];
    [_collectionView registerNib:headerNib
      forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
             withReuseIdentifier:@"HeaderFooter"];
}

- (void)configCollectionViewHeader:(UICollectionReusableView *)headerView
{
    
}

- (void)configCollectionView
{
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([self cellClass]) bundle:[NSBundle bundleForClass:[self cellClass]]] forCellWithReuseIdentifier:@"Cell"];
    [_collectionView setDecelerationRate:0.8];
    
    [self registerHeaderNib];
    
    UINib *footerNib = [UINib nibWithNibName:@"OWCollectionFooterLoadingMoreView"
                                      bundle:nil];
    [_collectionView registerNib:footerNib
      forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
             withReuseIdentifier:@"HeaderFooter"];
    
    if ([self ifNeedsDrop_DownRefresh]) {
        Class refreshClass;
        if ([self refreshViewClass]) {
            refreshClass = [self refreshViewClass];
        }
        else {
            refreshClass = [LYRefreshView class];
        }
        refreshView = [[NSBundle bundleForClass:refreshClass]
                       loadNibNamed:NSStringFromClass(refreshClass) owner:self options:nil][0];
        
        refreshView.frame = CGRectMake(0, CGRectGetMinY(_collectionView.frame), CGRectGetWidth(_collectionView.frame), 0);
        [refreshView.titleLabel setText: [self refreshViewTitle]];
        refreshView.delegate = self;
        [refreshView setupWithOwner:_collectionView];
        [self.view addSubview:refreshView];

    }
    else {
        _collectionView.backgroundColor = self.view.backgroundColor;
    }
    
    [self configCollectionViewLayout];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
}

- (void)configCollectionViewLayout
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(90, 190);
}

#pragma mark request && data
- (void)requestDataSource:(BOOL)isFetchLatest
{
    __weak OWCollectionViewController *weakSelf = self;
    
    if (isFetchLatest) {
        pageIndex = 1;
    }
    else
        pageIndex += 1;
    
    if (pageIndex == 1 && (![self ifNeedsDrop_DownRefresh]) && (!isLocalData)) {
        [self createStatusManageView];
    }
    else {
        [statusManageView stopRequest];
    }
    
    self.requestComplete = ^(NSArray *arr, NSInteger pCount) {
        [weakSelf requestComplete:arr pageCount:pCount];
    };
    self.reqestFault = ^(NSString *msg){
        [weakSelf reqestFault:msg];
    };
    
    isLocalData = NO;
    [self excuteRequest];
}

//加载请求失败的视图
- (void)loadFaultStateView
{
    if (!dataSource || dataSource.count == 0) {
        [self showFaultStatusManageView];
    }
}

- (void)requestComplete:(NSArray *)arr pageCount:(NSInteger)pCount
{
    pageCount = pCount;
    if (pageIndex == 1 && refreshView) {
        [refreshView stopLoading];
    }
    if (loadMoreView) {
        [loadMoreView stopLoading];
        loadMoreView.isLastPage = (pCount <= pageIndex);
    }

    if (arr && arr.count > 0) {
        requestedDataSource = arr;
        [self loadCollectionView];
        
    }
    else  {
        [self loadFaultStateView];
    }
}

- (void)reqestFault:(NSString *)msg
{
    if ([self ifNeedsLoadingMore] && loadMoreView) {
        [loadMoreView stopLoading];
    }
    if (pageIndex == 1 && refreshView) {
        [refreshView stopLoading];
    }
    
    if (pageIndex > 1) {
        pageIndex--;
    }
    [self loadFaultStateView];
    NSLog(@"error:%@",msg);
}

- (void)reloading:(id)sender
{
    [self requestDataSource:YES];
}

- (void)loadCollectionView
{
    [statusManageView stopRequest];

    if (pageIndex == 1) {
        __weak OWCollectionViewController *weakSelf = self;
        [self removeAllCells:^{
            [weakSelf reloadDataSource];
        }];
    }
    else {
        
        [self insertCells];
    }
}

- (void)reloadDataSource
{
    dataSource = [NSMutableArray arrayWithArray:requestedDataSource];
    [_collectionView reloadData];
}

#pragma mark cell 
- (void)removeAllCells:(void(^)())completion
{
    if(!dataSource && dataSource.count ==0) {
        
        if (completion) completion();
        return;
    }
    
    [_collectionView performBatchUpdates:^{
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (NSInteger i=0; i<dataSource.count; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:path];
        }
        [dataSource removeAllObjects];
        [_collectionView deleteItemsAtIndexPaths:indexPaths];
    } completion:^(BOOL finished) {
        
        if (completion) completion();
    }];
    
}

- (void)insertCells
{
    if (!requestedDataSource || requestedDataSource.count == 0)
        return;

    [_collectionView performBatchUpdates:^{
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (NSInteger i=0; i<requestedDataSource.count; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:dataSource.count +i inSection:0];
            [indexPaths addObject:path];
        }
        [dataSource addObjectsFromArray:requestedDataSource];
        [_collectionView insertItemsAtIndexPaths:indexPaths];
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark collection delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)theCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configCell:cell data:dataSource[indexPath.row] indexPath:indexPath];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)acollectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    //这是必须这么写，如果数据为空时返回nil，会导致crush
    UICollectionReusableView *headerFooter =
    [_collectionView dequeueReusableSupplementaryViewOfKind :kind
                                         withReuseIdentifier:@"HeaderFooter"
                                                forIndexPath:indexPath];
    
    if ([kind isEqualToString: UICollectionElementKindSectionFooter ]){
        if ([self ifNeedsLoadingMore]) {
            loadMoreView = (OWCollectionFooterLoadingMoreView *)headerFooter;
            loadMoreView.delegate = self;
            [loadMoreView setOwner:_collectionView];
        }
    }
    else if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {
        [self configCollectionViewHeader:headerFooter];
    }
    return headerFooter;
}

#pragma mark scroll delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= 0) {
        [refreshView scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if(!decelerate)
        [loadMoreView scrollViewDidEndDragging:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (loadMoreView) {
        [loadMoreView setIsLastPage:(pageCount <= pageIndex)];
        [loadMoreView scrollViewDidEndDragging:scrollView];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshView scrollViewDidScroll:scrollView];
}


#pragma mark refresh && loadingMore
-(void)autoRefresh
{
    if ([self ifNeedsDrop_DownRefresh]) {
        [_collectionView scrollRectToVisible:_collectionView.bounds animated:NO];
        [refreshView stopLoading];
        [refreshView scrollViewWillBeginDragging:_collectionView];
        [UIView animateWithDuration:0.3
                         animations:^{
                             _collectionView.contentOffset = CGPointMake(0, -80);
                         }
                         completion:^(BOOL finished) {
                             [refreshView scrollViewDidEndDragging:_collectionView willDecelerate:YES];
                         }];
    }
    else {
        [self createStatusManageView];
        [self requestDataSource:YES];
    }
    
}

-(void)refreshViewDidCallBack
{
    [refreshView startLoading];
    [self requestDataSource:YES];
}

- (void)loadMoreViewDidCallBack
{
    [self requestDataSource:NO];
}




@end
