//
//  MagIssuesColllectionController.m
//  TheReading
//
//  Created by grenlight on 15/1/8.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "MagIssuesColllectionController.h"

@interface MagIssuesColllectionController ()

@end

@implementation MagIssuesColllectionController

- (id)initWithMagCell:(LYMagazineTableCellData *)info
{
    self = [super initWithNibName:@"MagIssuesColllectionController" bundle:nil];
    if (self) {
        [self setup];
        
        magInfoManager = [[LYMagazineInfoManager alloc] init];
        magInfoManager.magazineInfo = info;
        self.isMagazineIssue = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isLocalMagazine = NO;
    _collectionView.alpha = 0;
    [self autoRefresh];
}

- (void)registerHeaderNib
{
    UINib *headerNib = [UINib nibWithNibName:@"IssueCollectionViewHeader"
                                      bundle:nil];
    [_collectionView registerNib:headerNib
      forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
             withReuseIdentifier:@"HeaderFooter"];
}

- (void)configCollectionViewHeader:(IssueCollectionViewHeader *)headerView
{
    collectionHeaderView = headerView;
    [collectionHeaderView setMagInfo:magInfoManager.magazineInfo];
}

- (BOOL)ifNeedsDrop_DownRefresh
{
    return NO;
}

- (BOOL)ifNeedsLoadingMore
{
    return YES;
}

- (void)excuteRequest
{
    __unsafe_unretained typeof (self) weakSelf = self;
    [magInfoManager getIssueList:pageIndex completion:^(NSArray *list) {
        [weakSelf loadList:list];
    } fault:^(NSString *msg) {
        [weakSelf->statusManageView requestFault];
    }];
}

- (void)loadList:(NSArray *)list
{
    [collectionHeaderView setMagInfo:magInfoManager.magazineInfo];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    [layout setHeaderReferenceSize:CGSizeMake(appWidth, CGRectGetHeight(collectionHeaderView.frame))];
    self.requestComplete(list, (int)magInfoManager.yearList.count);
    [UIView animateWithDuration:0.3 animations:^{
        _collectionView.alpha = 1;
    }];
}

- (void)comeback:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
