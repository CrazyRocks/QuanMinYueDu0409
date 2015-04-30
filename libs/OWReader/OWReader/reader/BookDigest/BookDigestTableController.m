//
//  BookmarkTableController.m
//  LogicBook
//
//  Created by iMac001 on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookDigestTableController.h"
#import "LYBookmarkManager.h"
//#import "BookmarkTableCellCell.h"
#import "BookDigestTableViewCell.h"
#import "GLLoading.h"
#import "LYBookRenderManager.h"
#import "MyBooksManager.h"
//#import "GLNotificationName.h"
#import "JRReaderNotificationName.h"
#import "LYBookSceneManager.h"
#import "LYBookHelper.h"

#import "MyBooksManager.h"

#import "BookDigest.h"
#import "JRBookDigestManager.h"


@interface BookDigestTableController ()
{
    IBOutlet UIView  *tableHeader;
    IBOutlet UIView  *tableFooter;
    
    BookDigestTableViewCell *currentCell, *temCell;
    GLLoading *loading;
    CGPoint loadingCenter;
    
    //是否需要刷新
    BOOL ifNeedsRefresh;
}
@end

@implementation BookDigestTableController

@synthesize selectedItemChangedCallBack;

@synthesize scrollCallBack;

- (id)init
{
    self = [super initWithNibName:@"BookDigestTableController" bundle:[NSBundle bundleForClass:[self class]]];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSceneMode) name:BOOK_SCENE_CHANGED object:nil];
        
    }
    return self;
}

- (void)releaseData
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super releaseData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 0, appWidth, appHeight-64)];

    _tableView.tableHeaderView = tableHeader;
    _tableView.tableFooterView = tableFooter;
    
    temCell = [[NSBundle mainBundle] loadNibNamed:@"BookDigestTableViewCell" owner:self options:nil][0];
    ifNeedsRefresh = YES;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LYBOOK_BOOKMARK_CHANGED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        ifNeedsRefresh = YES;
    }];
    
    [self loadSceneMode];
    
}

- (void)loadSceneMode
{
    UIStyleObject *viewStyle = [[LYBookSceneManager manager].styleManager getStyle:@"目录页"];
    self.view.backgroundColor = viewStyle.background;
    
    [_tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (ifNeedsRefresh) {
        [self autoRefresh];
    }
}

- (UIColor *)shimmeringColor
{
    return [UIColor grayColor];
}

- (NSString *)errorMessage
{
    return @"您还没有为本书添加笔记";
}

- (NSString *)loadingMessage
{
    return @"";
}

- (Class)cellClass
{
    return [BookDigestTableViewCell class];
}

- (void)configCell:(BookDigestTableViewCell *)cell data:(BookDigest *)data indexPath:(NSIndexPath *)indexPath
{
    [cell renderContent:data];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.backgroundColor = [UIColor clearColor];
}

- (void)excuteRequest
{
    
   [[JRBookDigestManager sharedInstance] loadThisBookDigestsAndNotes:[MyBooksManager sharedInstance].currentReadBook];
    
    NSMutableArray *list = [JRBookDigestManager sharedInstance].currentBookDigest;
    
    if (list && list.count > 0) {
        self.requestComplete(list, 1);
        dataSource.delegate = self;
    }
    else {
        _tableView.dataSource = nil;
        [_tableView reloadData];
        [statusManageView requestFault];
    }
    ifNeedsRefresh = NO;
}

#pragma mark tableVeiw delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookDigest *bd = dataSource.items[indexPath.row];
    [temCell renderContent:bd];

    [temCell setNeedsUpdateConstraints];
    [temCell updateConstraintsIfNeeded];
    
    temCell.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), 102);
    
    [temCell setNeedsLayout];
    [temCell layoutIfNeeded];
   
    CGFloat height = [temCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookDigest *bd = dataSource.items[indexPath.row];
    
    CGPoint cellPointInParentView = [currentCell convertPoint:CGPointZero toView:_tableView.superview];
    
    [[LYBookRenderManager sharedInstance] intoBookDigest:bd];

    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_OPEN_CONTENT object:nil];

    if(selectedItemChangedCallBack)
        selectedItemChangedCallBack(cellPointInParentView.y,_tableView.contentOffset.y);
}

#pragma mark delete cell

- (void)dataSourceDelete:(NSIndexPath *)indexPath
{
    BookDigest *bd = dataSource.items[indexPath.row];
    [[JRBookDigestManager sharedInstance] delegateThisBookDigestAndNotes:bd];
    
    [dataSource.items removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

-(void)setContentOffset:(CGPoint)offset
{
    [_tableView setContentOffset:offset];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int alpha = 1;
    if(_tableView.contentOffset.y <= 0)
        alpha = 0;
    if(scrollCallBack) scrollCallBack(alpha);

}

@end
