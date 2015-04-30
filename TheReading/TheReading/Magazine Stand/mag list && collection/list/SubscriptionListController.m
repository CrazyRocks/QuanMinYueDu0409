//
//  SubscriptionListController.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-11.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "SubscriptionListController.h"
#import "MagazineTableCell.h"
#import "MagCatelogueListController.h"

@interface SubscriptionListController ()
{
    LYMagazineManager       *requestManager;
}

@end

@implementation SubscriptionListController

- (id)init
{
    self = [super initWithNibName:@"SubscriptionListController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        requestManager = [[LYMagazineManager alloc] init];
    }
    return self;
}

- (void)releaseData
{
    [super releaseData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!needShowNavigationBar) {
        [navBar removeFromSuperview];
        navBar = Nil;
        
       
        [self.view addSubview:_tableView];
    }
    else
       [navBar setTitle:@"期刊"];
    
    [messageLB setHidden:YES];
    _tableView.tableHeaderView = nil;

    cellConfigBlock =
    ^(MagazineTableCell *cell, NSDictionary *item, NSIndexPath *indexPath) {
        [cell setContent:item];
    };
    
    [_tableView registerNib:[UINib nibWithNibName:@"MagazineTableCell" bundle:[NSBundle bundleForClass:[MagazineTableCell class]]]
     forCellReuseIdentifier:@"Cell"];
    
    if (!dataSource || !dataSource.items || dataSource.items.count == 0) {
        [self requesLocalData];
        [self requestDataSource:YES];
    }
    else {
        _tableView.dataSource = dataSource;
        [_tableView reloadData];
        [_tableView setContentOffset:tableContentOffset];
    }
}

- (void)requesLocalData
{
}

- (void)requestDataSource:(BOOL)isFetchLatest
{
    if( ![[CommonNetworkingManager sharedInstance] isReachable]){
        [self stopRefreshAndLoadMoreAnimation];
        return;
    }    
    if (isFetchLatest) {
        pageIndex = 1;
        
    }
    else {
        pageIndex += 1;
        
    }
    
    __unsafe_unretained SubscriptionListController *weakSelf = self;
    GLHttpRequstMultiResults completionBlock = ^(NSArray *arr, NSInteger pCount) {
        [weakSelf->statusManageView stopRequest];
        weakSelf->pageCount = pCount;
        weakSelf->loadMoreView.isLastPage = YES;
        
        if (arr && arr.count > 0) {
            [weakSelf->_tableView setHidden:NO];
            [weakSelf->messageLB setHidden:YES];
            weakSelf->_tableState = glTableNormalState;
            [weakSelf parseDataToSection:arr];
        }
        else if (!weakSelf->dataSource || !weakSelf->dataSource.items || weakSelf->dataSource.items.count == 0) {
            [weakSelf->_tableView setHidden:YES];
            [weakSelf->messageLB setHidden:NO];
            [weakSelf->messageLB setText:@"还没有杂志"];
        }
    };
    
    [((LYMagazineManager *)requestManager)
     getSubscriptionList:completionBlock
     failedCallBack:^(NSString *msg) {
         [[OWMessageView sharedInstance] showMessage:msg autoClose:YES];
         NSLog(@"订阅列表请求失败");
    }];
}

- (void)reloading:(id)sender
{
    [self requestDataSource:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)section
{
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYMagazineTableCellData *info ;
    info = dataSource.items[indexPath.row];

    [[CommonNetworkingManager sharedInstance] setCurrentMagazine:info];
    [self.navigationController pushViewController:[[MagCatelogueListController alloc] init]
      animated:YES];
    
}


// 刷新数据
- (void)refreshViewDidCallBack
{
    [refreshView startLoading];
    [self requestDataSource:YES];
}

//加载更多
-(void)loadMoreViewDidCallBack
{
    [self requestDataSource:NO];
    
}

- (void)networkMessageViewTapped
{
    [statusManageView startRequest];

    [self requestDataSource:YES];
}


@end
