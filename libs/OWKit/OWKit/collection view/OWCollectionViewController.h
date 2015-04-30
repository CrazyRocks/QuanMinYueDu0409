//
//  OWCollectionViewController.h
//  OWKit
//
//  Created by grenlight on 14/7/22.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWViewController.h"
#import "LYRefreshView.h"
#import "TableLoadMoreView.h"
#import "OWBlockDefine.h"

@class OWCollectionFooterLoadingMoreView;
@interface OWCollectionViewController : OWViewController<UICollectionViewDataSource,
UICollectionViewDelegate,LoadMoreViewDelegate, RefreshViewDelegate>
{
    __weak IBOutlet UICollectionView   *_collectionView;
    
    NSMutableArray     *dataSource;
    NSArray            *requestedDataSource;
    BOOL        isLocalData;

    
    NSInteger                   pageIndex;
    NSInteger                   pageCount;
    
    OWCollectionFooterLoadingMoreView   *loadMoreView;
    LYRefreshView                       *refreshView;

}


@property (nonatomic, copy) GLHttpRequstMultiResults requestComplete;
@property (nonatomic, copy) GLHttpRequstFault reqestFault;


- (void)registerHeaderNib;

- (void)configCollectionViewLayout;
- (void)configCollectionViewHeader:(UICollectionReusableView *)headerView;

- (void)configCell:(id)cell data:(id)data indexPath:(NSIndexPath *)indexPath;
- (Class)cellClass;

- (BOOL)ifNeedsDrop_DownRefresh;
- (BOOL)ifNeedsLoadingMore;
- (Class)refreshViewClass;
- (NSString *)refreshViewTitle;

- (void)autoRefresh;

- (void)excuteRequest;

-(void)parseDataToSection:(NSArray *)arr;

//扩展回调
- (void)extendRequestCompletion;
- (void)extendRequestFault;

//解析数据前
- (void)preParseDataToSection:(NSArray *)arr;
//解析数据后
- (void)endParseDataToSection:(NSArray *)arr;

- (void)stopRefreshAndLoadMoreAnimation;

@end
