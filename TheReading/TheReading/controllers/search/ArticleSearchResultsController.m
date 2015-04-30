//
//  ArticleSearchResultsController.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-26.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "ArticleSearchResultsController.h"
#import <QuartzCore/QuartzCore.h>
#import <OWCoreText/OWCoreText.h>
#import "ArticleSearchResultTableCell.h"
#import "AppDelegate.h"
#import <OWCoreText/OWHTMLToAttriString.h>

@interface ArticleSearchResultsController ()
{
    UITapGestureRecognizer *tap;
    UIView *keysPanel;
    LYSearchManager     *requestManager;
    
    UIStyleObject   *style;
    
    ArticleSearchResultTableCell    *tempCell;
}
@end

@implementation ArticleSearchResultsController

- (id)init
{
    self = [super initWithNibName:@"ArticleSearchResultsController" bundle:nil];
    if (self) {
        requestManager = [[LYSearchManager alloc] init];
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        searchCount = @(0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    style = [[UIStyleManager sharedInstance] getStyle:@"文章搜索列表"];
    if (style.useBackgroundImage) {
        _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:style.background_Image]];
    }
    else {
        _tableView.backgroundColor = style.background;
    }

    tempCell = [[NSBundle mainBundle] loadNibNamed:@"ArticleSearchResultTableCell" owner:self options:nil][0];
    [_noneResultMessageLB setHidden:YES];
    [_indicatorView setHidden:YES];
    
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    if (!dataSource || dataSource.items.count == 0) {
        [self.view addGestureRecognizer:tap];
    }
//    [self renderHotKeys];
}

//这个空方法用来重写父级行为
- (void)autoRefresh
{
    if (!_keywords || _keywords.length == 0) {
        return;
    }
    [super autoRefresh];
}

- (Class)cellClass
{
    return [ArticleSearchResultTableCell class];
}

- (void)configCell:(ArticleSearchResultTableCell *)cell data:(LYArticleTableCellData *)data indexPath:(NSIndexPath *)indexPath
{
    [cell setStyleObject:style];
    [cell setContent:data];
}

- (NSString *)loadingMessage
{
    return @"搜索中...";
}

- (NSString *)errorMessage
{
    if ([CommonNetworkingManager sharedInstance].isReachable) {
        return @"没有搜索到相关文章";
    }
    else {
        return HTTPREQEUST_NONE_NETWORK;
    }
}

- (BOOL)ifNeedsLoadingMore
{
    return YES;
}

- (void)preParseDataToSection:(NSArray *)arr
{
    [self.view removeGestureRecognizer:tap];
}

- (void)extendRequestFault
{
    [self.view addGestureRecognizer:tap];
}

- (void)tapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseKeyboard" object:nil];
}

- (void)renderHotKeys
{
    GLParamBlock completion = ^(NSArray *arr){
        if (!keysPanel) {
            keysPanel = [[UIView alloc] initWithFrame:self.view.bounds];
            keysPanel.backgroundColor = [UIColor clearColor];
        }
        float startX = 20, startY = 30, paddingLeft = 20;
        for (NSDictionary *item in arr) {
            NSString *key=item[@"hotword"];
            CGSize titleSize = CGSizeMake(appWidth, 20);
            titleSize = [key sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:titleSize
                            lineBreakMode:NSLineBreakByWordWrapping];
            
            float keyWidth = titleSize.width + 20;
            
            if (startX + keyWidth > appWidth - paddingLeft) {
                startY += 40;
            }
        }
       
    };
    GLHttpRequstFault fault = ^(NSString *msg){
        
    };
    
    [((LYSearchManager *)requestManager) getKeys:completion failedCallBack:fault];
}

- (void)reloading:(id)sender
{
    [self beginSearch:_keywords];
}

-(void)beginSearch:(NSString *)keywords
{
    [keysPanel removeFromSuperview];
    
    if (![_keywords isEqualToString:keywords]) {
        _keywords = keywords;
        [httpRequest cancel];
        
        searchCount = 0;
        _tableView.dataSource = nil;
        [_tableView reloadData];
        
        [self createStatusManageView];
        [self autoRefresh];
    }
}

- (void)excuteRequest
{
    __unsafe_unretained ArticleSearchResultsController *weakSelf = self;
    httpRequest = [requestManager searchArticlesByTitle:_keywords
                                              pageIndex:pageIndex
                                          countCallBack:^(NSNumber *number){
                                              searchCount = number;
                                          }
                                        successCallBack:^(NSArray *result, NSInteger pc){
                                            if (result.count > 0) {
                                                weakSelf.requestComplete(result, pc);
                                                [weakSelf->statusManageView stopRequest];
                                            }
                                            else {
                                                [weakSelf->statusManageView requestFault];
                                            }
                                        }
                                         failedCallBack:^(NSString *msg){
                                             weakSelf.reqestFault(msg);
                                             [weakSelf->statusManageView requestFault];
                                         } ];
}

#pragma mark tableView delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([searchCount integerValue] <= 0 || _tableView.dataSource == nil) {
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
    txt.text = [NSString stringWithFormat:@"查询出%@篇", searchCount];
    [header addSubview:txt];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYArticleTableCellData *item = dataSource.items[indexPath.row];
    [tempCell setContent:item];
    
    [tempCell setNeedsUpdateConstraints];
    [tempCell updateConstraintsIfNeeded];
    
    tempCell.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), 102);
    
    [tempCell setNeedsLayout];
    [tempCell layoutIfNeeded];
    
    CGFloat height = [tempCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CommonNetworkingManager sharedInstance].articles = dataSource.items;
    [CommonNetworkingManager sharedInstance].articleIndex = indexPath.row;
    
    ArticleDetailMainController *detailController = [[ArticleDetailMainController alloc] init];
    detailController.isRecommendArticleMode = YES;
    [self.navigationController pushViewController:detailController animated:YES];
    [detailController renderContentView];

}

@end
