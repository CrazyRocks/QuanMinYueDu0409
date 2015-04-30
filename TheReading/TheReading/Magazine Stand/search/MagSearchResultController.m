//
//  MagSearchResultControllerViewController.m
//  PublicLibrary
//
//  Created by grenlight on 13-12-7.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "MagSearchResultController.h"
#import "MagSearchTableCell.h"
#import <OWCoreText/OWHTMLToAttriString.h>
#import "MagCatelogueListController.h"
#import "LYMagazinesStandController.h"
#import "LYMagReaderViewController.h"
#import "LYMagazineGlobal.h"
#import "MagIssuesColllectionController.h"
#import "LYBookDetailController.h"

@interface MagSearchResultController ()

@end

@implementation MagSearchResultController

- (id)init
{
    self = [super initWithNibName:@"MagSearchResultController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        searchManager = [[LYSearchManager alloc] init];
        searchKeys = [NSMutableArray new];
        searchCount = @(0);
    }
    return self;
}

- (void)dealloc
{
    if (currentRequest) {
        [currentRequest cancel];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    listStyle = [[UIStyleManager sharedInstance] getStyle:@"杂志搜索列表"];
    self.view.backgroundColor = _tableView.backgroundColor = listStyle.background;
    
    searchField.delegate = self;

    if (!dataSource || dataSource.items.count == 0) {
        isInWebSearching = NO;
        needFilterResult = NO;
        
        [_tableView setHidden:YES];
    }
    else
        [_tableView reloadData];
    
    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"杂志搜索的取消按钮"];
    searchButton.titleLabel.textColor = style.fontColor;
    searchButton.titleLabel.font = [UIFont systemFontOfSize:style.fontSize];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showKeyboard];
    [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:1.0];
}

- (void)showKeyboard
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [searchField becomeFirstResponder];
}

- (BOOL)ifNeedsLoadingMore
{
    return YES;
}

//重写刷新事件，避免自动播放加载动画，因为此处是由用户输入发起的网络请求
- (void)autoRefresh
{
    
}

- (Class)cellClass
{
    return [MagSearchTableCell class];
}

- (void)configCell:(MagSearchTableCell *)cell data:(id)data indexPath:(NSIndexPath *)indexPath
{
    cell.listStyle = listStyle;
    if (self.searchType == 0) {
        [cell setContent:((LYMagazineSearchCellData *)data).magName];
    }
    else {
        [cell setContent:data[@"BookName"]];
    }
}

- (NSString *)loadingMessage
{
    return @"搜索中...";
}

- (NSString *)errorMessage
{
    NSString *suffix ;
    if (self.searchType == 0) {
        suffix = @"没有搜索到相关杂志";
    }
    else {
        suffix = @"没有搜索到相关图书";
    }
    if ([CommonNetworkingManager sharedInstance].isReachable) {
        return suffix;
    }
    else {
        return HTTPREQEUST_NONE_NETWORK;
    }
}

- (void)reloading:(id)sender
{
    [self beginSearch:searchKey];
}

-(void)beginSearch:(NSString *)keywords
{
    keywords = [keywords stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!keywords || [keywords isEqualToString:@""]) {
        [statusManageView stopRequest];
        [_tableView setHidden:YES];
        return;
    }
    if ([searchKey isEqualToString:keywords])
        return;
    
    searchKey = keywords;
    pageIndex = 1;
    [self performSelector:@selector(excuteRequest) withObject:Nil afterDelay:0.1];
}

- (void)excuteRequest
{
    if (currentRequest) {
        [currentRequest cancel];
    }
    if (pageIndex == 1) {
        [self createStatusManageView];
    }

    needFilterResult = NO;
    isInWebSearching = YES;
    [searchKeys addObject:searchKey];
    
    if (self.searchType == 0) {
        [self searchMagazine];
    }
    else {
        [self searchBook];
    }
}

- (void)searchMagazine
{
    __weak MagSearchResultController *weakSelf = self;
    currentRequest =
    [searchManager  searchMagazineByName:searchKey
                               pageIndex:pageIndex
                           countCallBack:^(NSNumber *number){
                               searchCount = number;
                           }
                         successCallBack:^(NSArray *result, NSInteger count){
                             [weakSelf requestComplete:result pageCount:count];
                             
                         } failedCallBack:^(NSString *message) {
                             [weakSelf requestError:message];
                             
                         } ];
}

- (void)searchBook
{
    __weak MagSearchResultController *weakSelf = self;
    currentRequest =
    [searchManager  searchBook:searchKey
                     pageIndex:pageIndex
                 countCallBack:^(NSNumber *number){
                     searchCount = number;
                 }
               successCallBack:^(NSArray *result, NSInteger count){
                   [weakSelf requestComplete:result pageCount:count];
                   
               } failedCallBack:^(NSString *message) {
                   [weakSelf requestError:message];
                   
               } ];
}

- (void)requestComplete:(NSArray *)result pageCount:(NSInteger)count
{
    if (searchKeys.count > 0) {
        [searchKeys removeObjectAtIndex:0];
    }
    originalData = result;
    pageCount = count;
    [self parseDataToSection:result];
    isInWebSearching = NO;
}

- (void)requestError:(NSString *)msg
{
    if (searchKeys.count > 0) {
        [searchKeys removeObjectAtIndex:0];
    }
    if (searchKeys.count == 0) {
        isInWebSearching = NO;
        [statusManageView requestFault];
    }
}

- (void)parseDataToSection:(NSArray *)arr
{
    [statusManageView stopRequest];
    [_tableView setHidden:NO];
    NSMutableArray *filterArray;
    
    if (needFilterResult) {
        filterArray = [[NSMutableArray alloc] init];
        if (self.searchType == 0) {
            for (LYMagazineSearchCellData *cellData in arr) {
                NSRange range = [cellData.magName rangeOfString:searchKey];
                if (range.length >0) {
                    [filterArray addObject:cellData];
                }
            }
        }
        else {
            for (NSDictionary *cellData in arr) {
                NSRange range = [cellData[@"BookName"] rangeOfString:searchKey];
                if (range.length >0) {
                    [filterArray addObject:cellData];
                }
            }
        }
        
        [dataSource.items removeAllObjects];

//        NSMutableArray *indexes = [[NSMutableArray alloc] init];
//        for (uint i = 0 ; i < rowCount; i++) {
//            [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
//        }
        _tableView.dataSource = nil;
        [_tableView reloadData];
//        [_tableView beginUpdates];
//         [ _tableView deleteSections:[NSIndexSet indexSetWithIndex:1]  withRowAnimation:UITableViewRowAnimationFade];
//        [_tableView endUpdates];
    }
    else
        filterArray = (NSMutableArray *)arr;
    
    if (filterArray && filterArray.count >0) {
        [super parseDataToSection:filterArray];
    }
    else {
        [_tableView setHidden:YES];
        [statusManageView requestFault];
    }
    
}

#pragma mark table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([searchCount integerValue] <= 0) {
        tableView.hidden = YES;
    }
    else {
        tableView.hidden = NO;
    }
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 36)];
    header.backgroundColor = [OWColor colorWithHex:0xf9f9f9];
    UILabel *txt = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 36)];
    txt.font = [UIFont systemFontOfSize:13];
    txt.textColor = [UIColor darkGrayColor];
    txt.text = [NSString stringWithFormat:@"查询出%@本", searchCount];
    [header addSubview:txt];
    
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellData = dataSource.items[indexPath.row];

    if (self.searchType == 0) {
        MagIssuesColllectionController *issuesController = [[MagIssuesColllectionController alloc] initWithMagCell:(LYMagazineTableCellData *)cellData];
        
        [self.navigationController pushViewController:issuesController animated:YES];
    }
    else {
        LYBookDetailController *detailController = [[LYBookDetailController alloc] init];
        detailController.bookGUID = ((NSDictionary *)cellData)[@"BookGuid"];
        detailController.contentInfo = (NSDictionary *)cellData;
        [self.navigationController pushViewController:detailController animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)comeback:(id)sender
{
    [searchField resignFirstResponder];
    [[OWNavigationController sharedInstance] popViewController:owNavAnimationTypeSlideToBottom];
}

#pragma mark textField delegate

//在iOS 7.0.3下，拼音输入法选中文是不会触发这个事件
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self beginSearch:searchField.text];
    return YES;
}


@end
