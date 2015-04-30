//
//  LYFocusedMagCollectionController.m
//  LYMagazinesStand
//
//  Created by grenlight on 13-12-26.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import "LYFocusedMagCollectionController.h"
#import "LYMagazinesStandController.h"
#import "MagCVCell.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h> 


@interface LYFocusedMagCollectionController ()
{
}
@end

@implementation LYFocusedMagCollectionController

- (id)init
{
    self = [super initWithNibName:@"MagazineCollectionController" bundle:nil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isEditMode = NO;
    
    if (!longPressGestureRecognizer) {
        longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(handleLongPressGesture:)];
    }
    [self.view addGestureRecognizer:longPressGestureRecognizer];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self autoRefresh];
}

- (BOOL)ifNeedsDrop_DownRefresh
{
    return YES;
}

- (NSString *)loadingMessage
{
    return @"正在获取关注列表";
}

- (NSString *)errorMessage
{
    if (![CommonNetworkingManager sharedInstance].isReachable) {
        return HTTPREQEUST_NONE_NETWORK;
    }
    else {
        return @"还没有您关注的期刊";
    }
}


- (void)loadLocalData
{
    pageCount = 1;
    pageIndex = 1;

    NSArray *list = [requestManager getLocalFocusedMagazineList];
    
    if (list && list.count > 0) {
        dataSource = [NSMutableArray arrayWithArray:list];
        
        [_collectionView reloadData];
    }
    
}

- (void)excuteRequest
{
    if(![[CommonNetworkingManager sharedInstance] isReachable]) {
        [self updateRequestState];
        return;
    }

    httpRequest =  [requestManager getFocusedMagazineList:pageIndex
                                          successCallBack:self.requestComplete
                                           failedCallBack:self.reqestFault];

}


- (void)addedCellIfNeedsShake:(OWShakeableCVCell *)cell
{
    if (isEditMode)
        [cell startShake];
    else
        [cell stopShake];
}

#pragma mark gesture action
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [sender locationInView:_collectionView];
        for (UICollectionViewCell *cell in _collectionView.visibleCells) {
            if (CGRectContainsPoint(cell.frame, point)) {
                [self startShake];
            }
        }
    }
}

#pragma mark delete items
- (void)shakeView:(OWShakeableCVCell *)shakeView delete:(UIButton *)bt
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:shakeView];
    LYMagazineTableCellData *info = dataSource[indexPath.row];
    [[OWMessageView sharedInstance]
     showMessage:[NSString stringWithFormat:@"正在取消对《%@》的关注",info.magName]
     autoClose:NO];
    __unsafe_unretained LYFocusedMagCollectionController *weakSelf = self;
    [((LYMagazineManager *)requestManager)
     disfocusMagazine:info
     completion:^{
         [[OWMessageView sharedInstance]
          showMessage:[NSString stringWithFormat:@"已取消对《%@》的关注",info.magName]
          autoClose:YES];
         [weakSelf->_collectionView
          performBatchUpdates:^{
              [weakSelf->dataSource removeObjectAtIndex:indexPath.row];
              [weakSelf->_collectionView deleteItemsAtIndexPaths:@[indexPath]];
          }
          completion:^(BOOL finished) {
              if (finished)
                  [weakSelf startShake];
          }];
        
     } fault:^{
         [[OWMessageView sharedInstance] showMessage:@"操作失败" autoClose:YES];
     }];
}

#pragma mark shake
- (void)startShake
{
    isEditMode = YES;

    for (OWShakeableCVCell *cell in _collectionView.visibleCells) {
        cell.owDelegate = self;
        [cell startShake];
    }
}

- (void)stopShake
{
    for (OWShakeableCVCell *cell in _collectionView.visibleCells) {
        [cell stopShake];
    }
    isEditMode = NO;
}

- (void)outEditMode
{
    [self stopShake];
}
@end
