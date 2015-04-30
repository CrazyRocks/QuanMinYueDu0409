//
//  OWCommonTableViewController.m
//  Xcode6AppTest
//
//  Created by grenlight on 14/6/27.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWCommonTableViewController.h"
#import "OWAnimator.h"

@interface OWCommonTableViewController ()

@end

@implementation OWCommonTableViewController

- (void)releaseData
{
    [self stopRefreshAndLoadMoreAnimation];
    
    refreshView.delegate = nil;
    [refreshView removeFromSuperview];
    refreshView = nil;
    
    loadMoreView.delegate = nil;
    [loadMoreView removeFromSuperview];
    loadMoreView = nil;
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [_tableView removeFromSuperview];
    _tableView = nil;
    
    [super releaseData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self configTableView];
    
    if (dataSource && dataSource.items && dataSource.items.count > 0) {
        _tableView.dataSource = dataSource;
        [_tableView reloadData];
    }
    else {
        [self performSelector:@selector(autoRefresh) withObject:nil afterDelay:0.1];
    }
}

- (BOOL)isEditable
{
    return NO;
}

- (void)configTableView
{
    [self setupRefreshView];
    [self setupLoadMoreView];
    
    __weak OWCommonTableViewController *weakSelf = self;
    cellConfigBlock =
    ^(UITableViewCell *cell, id item, NSIndexPath *indexPath) {
        [weakSelf configCell:cell data:item indexPath:indexPath];
    };
    
    if ([NSStringFromClass([self cellClass]) isEqualToString:@"UITableViewCell"]) {
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    else {
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self cellClass]) bundle:[NSBundle bundleForClass:[self cellClass]]]
         forCellReuseIdentifier:@"Cell"];
    }
  
    _tableView.delegate = self;
    
}

-(void)setTableState:(GLTableState)state
{
    _tableState = state ;
   
    //呈现的是本地数据时，不能自动【加载更多】，因为不知页码
    if(_tableState == glTableLocalDataState && [self ifNeedsLoadingMore]){
        loadMoreView.isLastPage = YES;
    }
}

#pragma mark request
- (void)requestData:(BOOL)isRefresh
{
    if (isRefresh) {
        pageIndex = 1;
        [self setTableState:glTableRefreshState];
        
    }
    else {
        pageIndex += 1;
        [self setTableState:glTableloadingMoreState];
    }
    
    __weak OWCommonTableViewController *weakSelf = self;

    self.requestComplete = ^(NSArray *result, NSInteger totalPage){
        [weakSelf completionNeedsExcute:result totalPage:totalPage];
    };
    
    self.reqestFault = ^(NSString *message){
        [weakSelf faultNeedsExcute:message];
    };
    [self excuteRequest];
}

- (void)completionNeedsExcute:(NSArray *)result totalPage:(NSInteger)totalPage
{
    if (result && result.count > 0) {
        if (pageIndex ==1) {
            pageCount = totalPage;
        }
        loadMoreView.isLastPage = (pageIndex ==  pageCount);
        [self parseDataToSection:result];
        [self extendRequestCompletion];
    }
    else {
        if (self->_tableState == glTableloadingMoreState) {
            self->pageIndex -= 1;
        }
        else if (self->_tableState == glTableRefreshState) {
            [self removeOldData];
        }
        [self stopRefreshAndLoadMoreAnimation];
    }
}

- (void)faultNeedsExcute:(NSString *)msg
{
    if (self->_tableState == glTableloadingMoreState) {
        self->pageIndex -= 1;
    }
    self->loadMoreView.isLastPage = YES;
    [self stopRefreshAndLoadMoreAnimation];
    [self->statusManageView requestFault];
    
    [self extendRequestFault];
}

- (void)removeOldData
{
    if ([self isEditable]) {
        dataSource = [[OWTableViewEditableDataSource alloc] initWithItems:[[NSMutableArray alloc] init] configureCellBlock:cellConfigBlock];
    }
    else {
        dataSource = [[OWTableViewDataSource alloc] initWithItems:[[NSMutableArray alloc] init] configureCellBlock:cellConfigBlock];
    }
    _tableView.dataSource = dataSource;
    [_tableView reloadData];
}

- (void)reloading:(id)sender
{
    [self autoRefresh];
}

- (void)extendRequestCompletion
{
    
}

- (void)extendRequestFault
{
    
}

#pragma mark parse data
-(void)parseDataToSection:(NSArray *)arr
{
    [self preParseDataToSection:arr];
    [self stopRefreshAndLoadMoreAnimation];
    
    if (_tableState == glTableloadingMoreState) {
        NSInteger startIndex = dataSource.items.count;
        [dataSource.items addObjectsFromArray:arr];

        if (dataSource.isGroupStyle) {
            dataSource.sections = sectionKeys;

            [_tableView beginUpdates];
            for (NSInteger i=0; i < arr.count; i++) {
                [_tableView insertSections:[NSIndexSet indexSetWithIndex:startIndex+i]
                              withRowAnimation:UITableViewRowAnimationFade];
            }
            [_tableView endUpdates];

        }
        else {
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (NSInteger i = startIndex ; i <= (dataSource.items.count -1); i++) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(i) inSection:0];
                [indexPaths addObject:newIndexPath];
            }
            
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
            [_tableView endUpdates];
        }
    }
    else {
        //用于处理section收放动画
        if (!sectionsDataSource) {
            sectionsDataSource = [[NSMutableArray alloc] initWithArray:arr];
        }
        if ([self isEditable]) {
            dataSource = [[OWTableViewEditableDataSource alloc] initWithItems:arr
                                                           configureCellBlock:cellConfigBlock];
        }
        else {
            dataSource = [[OWTableViewDataSource alloc] initWithItems:arr
                                                   configureCellBlock:cellConfigBlock];
        }

        if (dataSource.isGroupStyle) {
            dataSource.sections = sectionKeys;
        }
        _tableView.dataSource = dataSource;
        [_tableView reloadData];
    }
    
    [self endParseDataToSection:arr];
    [statusManageView stopRequest];
    
}


- (void)preParseDataToSection:(NSArray *)arr
{
    
}

- (void)endParseDataToSection:(NSArray *)arr
{
    
}



#pragma mark config refresh && loadingMore

- (BOOL)ifNeedsDrop_DownRefresh
{
    return NO;
}

- (BOOL)ifNeedsLoadingMore
{
    return NO;
}

- (NSString *)refreshViewTitle
{
    return  @"全民移动阅读书库";
}

- (void)setupRefreshView
{
    if (![self ifNeedsDrop_DownRefresh]) {
        return;
    }
    if (!refreshView) {
        refreshView = [[NSBundle bundleForClass:[LYRefreshView class]] loadNibNamed:@"LYRefreshView2" owner:self options:nil][0];
        refreshView.frame = CGRectMake(0, CGRectGetMinY(_tableView.frame), appWidth, 0);
    }
    [refreshView.titleLabel setText: [self refreshViewTitle]];
    refreshView.delegate = self;
    [refreshView setupWithOwner:_tableView];
    [self.view addSubview:refreshView];
}


- (void)setupLoadMoreView
{
    if (![self ifNeedsLoadingMore]) {
        return;
    }
    if (!loadMoreView) {
        loadMoreView =  [[NSBundle bundleForClass:[TableLoadMoreView class]] loadNibNamed:@"TableLoadMoreView" owner:self options:nil][0];
        loadMoreView.backgroundColor = [UIColor clearColor];
    }
    
    loadMoreView.delegate = self;
    [loadMoreView setupWithOwner:_tableView];
    
    if(!_tableView.tableFooterView) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), CGRectGetHeight(loadMoreView.frame))];
        footerView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = footerView;
    }
    
    [_tableView.tableFooterView addSubview:loadMoreView];
}

- (void)stopRefreshAndLoadMoreAnimation
{
    if (_tableState == glTableRefreshState) {
        [refreshView stopLoading];
    }
    [loadMoreView stopLoading];
}

#pragma mark refresh && loadingMore
-(void)autoRefresh
{
    if ([self ifNeedsDrop_DownRefresh]) {
        [refreshView stopLoading];
        [refreshView scrollViewWillBeginDragging:_tableView];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             _tableView.contentOffset = CGPointMake(0, -80);
                         }
                         completion:^(BOOL finished) {
                             [refreshView scrollViewDidEndDragging:_tableView willDecelerate:YES];
                         }];
    }
    else {
        [self createStatusManageView];

        [self requestData:YES];
    }
    
}

-(void)refreshViewDidCallBack
{
    [refreshView startLoading];
    [self requestData:YES];
}

-(void)loadMoreViewDidCallBack
{
    [self requestData:NO];
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
    //    NSLog(@"scrollViewDidEndDragging");
    
    [refreshView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if(!decelerate)
        [loadMoreView scrollViewDidEndDragging:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //    NSLog(@"scrollViewDidEndDecelerating");
    [loadMoreView scrollViewDidEndDragging:scrollView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshView scrollViewDidScroll:scrollView];
}

#pragma mark section animation
- (BOOL)ifNeedsExpanding
{
    return YES;
}

- (void)sectionExpanding:(NSInteger )section
{
    NSArray *sd = sectionsDataSource[section];
    dataSource.items[section] = sd;
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = 0 ; i < sd.count; i++) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(i) inSection:section];
        [indexPaths addObject:newIndexPath];
    }
    
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:indexPaths
                      withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
    
}

- (void)sectionClose:(NSInteger )section
{
    NSArray *sd = sectionsDataSource[section];
    dataSource.items[section] = @[];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = 0 ; i < sd.count; i++) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(i) inSection:section];
        [indexPaths addObject:newIndexPath];
    }
    
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:indexPaths
                      withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
}


#pragma mark cell animation
- (void)animateIntoList:(OWCellAnimationDirection)direction
{
    if (!_tableView.visibleCells || _tableView.visibleCells.count == 0) {
        return;
    }
    CGRect frame = ((UITableViewCell *)_tableView.visibleCells[0]).bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    CGPoint target = center;
    if (direction == owCellAnimationLeft)
        target.x *= (-1);
    else
        target.x *= 3;
    
    [_tableView.visibleCells enumerateObjectsUsingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
//        obj.contentView.center = initCenter;
//        [OWAnimator spring:obj.contentView toPosition:center delay:0.05 + 0.07*idx];
        [OWAnimator basicAnimate:obj.contentView toPosition:target duration:0.45 delay:0.0 + 0.05*idx];
        
    }];
}

//将cell都回归到原本位置
- (void)animateToOriginal
{
    if (!_tableView.visibleCells || _tableView.visibleCells.count == 0) {
        return;
    }
    CGRect frame = ((UITableViewCell *)_tableView.visibleCells[0]).bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    
    [_tableView.visibleCells enumerateObjectsUsingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
        //        obj.contentView.center = initCenter;
        //        [OWAnimator spring:obj.contentView toPosition:center delay:0.05 + 0.07*idx];
        [OWAnimator basicAnimate:obj.contentView toPosition:center duration:0.1];
    }];
}

- (void)animateOutList:(OWCellAnimationDirection)direction
{
    if (!_tableView.visibleCells || _tableView.visibleCells.count == 0) {
        return;
    }
    CGRect frame = ((UITableViewCell *)_tableView.visibleCells[0]).bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    CGPoint tagetCenter = center;
    if (direction == owCellAnimationLeft)
        tagetCenter.x *= (-1);
    else
        tagetCenter.x *= 3;
    
    [_tableView.visibleCells enumerateObjectsUsingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
        [OWAnimator basicAnimate:obj.contentView toPosition:tagetCenter duration:0.45 delay:0.0 + 0.05*idx];
    }];
}

#pragma mark blank interface
- (Class)cellClass {
    return [UITableViewCell class];
}

- (void)configCell:(id)cell data:(id)data indexPath:(NSIndexPath *)indexPath{ }

- (void)excuteRequest{}

@end
