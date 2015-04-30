//
//  CatelogueTableController.m
//  LogicBook
//
//  Created by iMac001 on 12-2-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CatalogueTableController.h"
#import "LYBookRenderManager.h"
#import "BSConfig.h"
#import "BSCoreDataDelegate.h"
#import "MyBooksManager.h"
//#import "GLNotificationName.h"
#import "JRReaderNotificationName.h"
#import "LYBookSceneManager.h"

@implementation CatalogueTableController

@synthesize selectedItemChangedCallBack;
@synthesize scrollCallBack;

- (id)init
{
    self = [super initWithNibName:@"CatalogueTableController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSceneMode) name:BOOK_SCENE_CHANGED object:nil];
        
    }
    return self;
}

- (void)releaseData
{
    [super releaseData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 0, appWidth, appHeight-64)];
    
    _tableView.tableHeaderView = self.tableHeader;
    _tableView.tableFooterView = self.tableFooter;
    
    [self loadSceneMode];
}

- (void)loadSceneMode
{
    UIStyleObject *viewStyle = [[LYBookSceneManager manager].styleManager getStyle:@"目录页"];
    
    self.view.backgroundColor = viewStyle.background;
    
    _tableView.backgroundColor = self.view.backgroundColor;
    
    [_tableView reloadData];
}

- (Class)cellClass
{
    return [CatalogueTableCell class];
}

- (void)configCell:(CatalogueTableCell *)cell data:(Catalogue *)data indexPath:(NSIndexPath *)indexPath
{
    [cell renderContent:data];
    
    cell.delegate = self;

    cell.backgroundColor = [UIColor clearColor];
}

- (void)excuteRequest
{
    self.requestComplete([LYBookRenderManager sharedInstance].catalogues, 1);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Catalogue *cat = dataSource.items[indexPath.row];
    
    return  ceilf([cat cellHeight:appWidth-50]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_OPEN_CONTENT object:nil];
    
    Catalogue *cat = dataSource.items[indexPath.row];
    [[LYBookRenderManager sharedInstance] intoCatelogue:cat];

    if(selectedItemChangedCallBack) {
        CGPoint cellPointInParentView = [currentCell convertPoint:CGPointZero toView:_tableView.superview];
        selectedItemChangedCallBack(cellPointInParentView.y,_tableView.contentOffset.y);
    }
}

//会被多次重复调用（用户反复滚动时）
-(void)tableCellSelected:(CatalogueTableCell *)cell
{
    currentCell = cell;
    float width = 25,height = 25;
   loadingCenter = CGPointMake(CGRectGetWidth(currentCell.frame)-(width+10), (CGRectGetHeight(currentCell.frame)-height)/2.0);
 
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
