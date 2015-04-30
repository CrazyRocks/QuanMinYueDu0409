//
//  LYMagazineShelfController.m
//  LYMagazinesStand
//
//  Created by grenlight on 14-5-19.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYMagazineShelfController.h"

@interface LYMagazineShelfController ()

@end

@implementation LYMagazineShelfController


- (BOOL)ifNeedsDrop_DownRefresh
{
    return NO;
}

- (BOOL)ifNeedsLoadingMore
{
    return NO;
}

- (NSString *)loadingMessage
{
    return @"正在加载您已下载的杂志";
}

- (NSString *)errorMessage
{
    return @"还没有您下载的杂志";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadLocalData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopShake];
}

- (void)loadLocalData
{
    
    [self createStatusManageView];
    
    self.isLocalMagazine = YES;
    
    pageCount = 1;
    pageIndex = 1;
   
    NSArray *list = [[LYMagazineShelfManager sharedInstance] getAllMagazines];
    
    if (list && list.count > 0) {
        [statusManageView stopRequest];
        dataSource = [NSMutableArray arrayWithArray:list];
    }
    else {
        dataSource = nil;
        [statusManageView requestFault];
    }
    [_collectionView reloadData];

}

- (void)autoRefresh
{
    
}

#pragma mark delete items
- (void)shakeView:(OWShakeableCVCell *)shakeView delete:(UIButton *)bt
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:shakeView];
    LYMagazineTableCellData *info = dataSource[indexPath.row];
    __unsafe_unretained LYMagazineShelfController *weakSelf = self;
    [[LYMagazineShelfManager sharedInstance] deleteMagazine:info];
    [_collectionView performBatchUpdates:^{
         [weakSelf->dataSource removeObjectAtIndex:indexPath.row];
         [weakSelf->_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        if (weakSelf->dataSource.count >0) {
            [weakSelf startShake];
        }
        else {
            [weakSelf stopShake];
        }
    }];
}
@end
