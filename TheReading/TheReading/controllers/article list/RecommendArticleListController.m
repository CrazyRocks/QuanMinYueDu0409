//
//  RecommendArticleListController.m
//  PublicLibrary
//
//  Created by grenlight on 14-3-7.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "RecommendArticleListController.h"
#import <QuartzCore/QuartzCore.h>
#import <OWCoreText/OWCoreText.h>
#import "RecommendArticleTableCell.h"
#import <OWCoreText/OWHTMLToAttriString.h>
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

//列表尾的视图高度，在此处呈现【更多】按钮等
#define TABELVIEW_FOOTERVIEW_HEIGHT 70

@interface RecommendArticleListController ()
{
    //当前是否已经使用的是本地数据
    BOOL isLocalData;
    //当前分类ID
    NSString *currentCID;
    
    LYRecommendManager *requestManager;
    
    RecommendArticleTableCell *tempCell;
}

@end

@implementation RecommendArticleListController

-(id)init
{
    self = [super initWithNibName:@"RecommendArticleListController" bundle:nil];
    if(self) {
        requestManager = [[LYRecommendManager alloc] init];
    }
    return self;
}

- (id)initWithNoneNavigationBar
{
    self = [super initWithNoneNavigationBar];
    if(self) {
        requestManager = [[LYRecommendManager alloc] init];
    }
    return self;
}

- (void)releaseData
{
    [super releaseData];
}

- (void)viewDidLoad
{
    tempCell = [[NSBundle mainBundle] loadNibNamed:@"RecommendArticleTableCell" owner:self options:nil][0];
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [OWColor colorWithHexString:@"#fafafa"];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.editing = NO;
    [CommonNetworkingManager sharedInstance].fromList = glRecommendList;
}

- (void)setTitle:(NSString *)title
{
    [navBar setTitle:title];
}

- (BOOL)ifNeedsDrop_DownRefresh
{
    return YES;
}

- (BOOL)ifNeedsLoadingMore
{
    return YES;
}

- (Class)cellClass
{
    return [RecommendArticleTableCell class];
}

- (void)configCell:(RecommendArticleTableCell *)cell data:(LYArticleTableCellData *)item indexPath:(NSIndexPath *)indexPath
{
    [cell setContent:item];
}

- (void)loadLocalData:(NSString *)cid
{
    if ([cid isEqualToString:currentCID] && dataSource && dataSource.items && dataSource.items.count > 0)
        return;
    
    currentCID = cid;
    [requestManager cancelRequest];
    
    pageIndex = 1;
    pageCount = 1;
    [self setTableState:glTableLocalDataState];
    loadMoreView.isLastPage = YES;

    [refreshView stopLoading];
    isLocalData = YES;
    
    [_tableView scrollRectToVisible:_tableView.bounds animated:NO];
    
    __weak RecommendArticleListController *weakSelf = self;
    [requestManager getLocalRecommendList:cid successCallBack:^(NSArray *result){
        [weakSelf parseDataToSection:result];
    } failedCallBack:^(NSString *message){
        
    }];
}

- (void)requestArticleList:(NSString *)cid
{
    if ([cid isEqualToString:currentCID] && dataSource && dataSource.items.count > 0 && (!isLocalData))
        return;
    
    currentCID = cid;
    [self autoRefresh];
    
//    [self requestArticleList:cid fetchLatest:YES];
}

- (void)excuteRequest
{
    if (!currentCID) {
        return;
    }
    
    [requestManager cancelRequest];
    [requestManager getRecommendList : currentCID
                           pageIndex : pageIndex
                     successCallBack : self.requestComplete
                      failedCallBack : self.reqestFault];
}

- (void)extendRequestCompletion
{
    [[OWAccessManager sharedInstance] saveRefreshedCategory:currentCID];
}

- (void)parseDataToSection:(NSArray *)arr
{
    if (pageIndex == 1) {
        [_tableView scrollRectToVisible:_tableView.bounds animated:NO];
    }
    for (LYArticleTableCellData *cellData in arr) {
        cellData.textRect = CGRectMake(10, 15, appWidth-20, 300);
    }
    [super parseDataToSection:arr];
}

#pragma mark table delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LYArticleTableCellData *bd = dataSource.items[indexPath.row];
    [tempCell setContent:bd];
    
    [tempCell setNeedsUpdateConstraints];
    [tempCell updateConstraintsIfNeeded];
    
    tempCell.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), 90);
    
    [tempCell setNeedsLayout];
    [tempCell layoutIfNeeded];
    
    CGFloat height = [tempCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CommonNetworkingManager sharedInstance].articles = dataSource.items;
    [CommonNetworkingManager sharedInstance].articleIndex = indexPath.row;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FromRecommendListToArticleDetail" object:nil];
    ArticleDetailMainController *detailController = [[ArticleDetailMainController alloc] init];
    detailController.isRecommendArticleMode = YES;
    
    [self.navigationController pushViewController:detailController animated:YES];
    [detailController renderContentView];

    // 重绘已读样式
    RecommendArticleTableCell *cell = (RecommendArticleTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell rerenderContent];
}


@end
