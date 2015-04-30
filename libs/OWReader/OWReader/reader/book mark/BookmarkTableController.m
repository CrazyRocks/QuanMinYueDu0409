//
//  BookmarkTableController.m
//  LogicBook
//
//  Created by iMac001 on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookmarkTableController.h"
#import "LYBookmarkManager.h"
#import "BookmarkTableCellCell.h"
#import "GLLoading.h"
#import "LYBookRenderManager.h"
#import "MyBooksManager.h"
//#import "GLNotificationName.h"
#import "JRReaderNotificationName.h"
#import "LYBookSceneManager.h"
#import "LYBookHelper.h"

@interface BookmarkTableController ()
{
    IBOutlet UIView  *tableHeader;
    IBOutlet UIView  *tableFooter;
    
    BookmarkTableCellCell *currentCell;
    GLLoading *loading;
    CGPoint loadingCenter;
    
    //是否需要刷新
    BOOL ifNeedsRefresh;
}
@end

@implementation BookmarkTableController

@synthesize selectedItemChangedCallBack;

@synthesize scrollCallBack;

- (id)init
{
    self = [super initWithNibName:@"BookmarkTableController" bundle:[NSBundle bundleForClass:[self class]]];
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
    return @"您还没有为本书添加书签";
}

- (NSString *)loadingMessage
{
    return @"";
}

- (Class)cellClass
{
    return [BookmarkTableCellCell class];
}

- (void)configCell:(BookmarkTableCellCell *)cell data:(Bookmark *)data indexPath:(NSIndexPath *)indexPath
{
    [cell renderContent:data];
}


- (void)excuteRequest
{
    LYBookmarkManager *bmManager = [LYBookmarkManager sharedInstance];
    NSArray *list = [bmManager getBookmarkList];
    if (list && list.count > 0) {
        self.requestComplete(list, 1);
    }
    else  {
        _tableView.dataSource = nil;
        [_tableView reloadData];
        [statusManageView requestFault];
    }
    
    ifNeedsRefresh = NO;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bookmark *bm = dataSource.items[indexPath.row];
    CGPoint cellPointInParentView = [currentCell convertPoint:CGPointZero toView:_tableView.superview];
    [[LYBookRenderManager sharedInstance] intoBookmark:bm];

    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_OPEN_CONTENT object:nil];

    if(selectedItemChangedCallBack)
        selectedItemChangedCallBack(cellPointInParentView.y,_tableView.contentOffset.y);
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

-(void)dealloc
{
    _tableView.delegate = nil;
    [self releaseData];
}

@end
