//
//  WYMainMenuController.m
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "WYMainMenuController.h"
#import "MainMenuCell.h"
#import "WYContentCanvasController.h"
#import <LYService/LYAccountManager.h>
#import "LYRightSlideControllerViewController.h"
#import "WYRootController_iPad.h"

@interface WYMainMenuController ()
{
    MainMenuCell   *selectedCell;
}
@end

@implementation WYMainMenuController

- (id)init
{
    if (self = [super initWithNibName:@"WYMainMenuController" bundle:nil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(intoLeft) name:@"ChannelState" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outLeft) name:@"ContentState" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView.backgroundColor = [UIColor clearColor];
    
    CGFloat headerHeight = 0, viewWidth = appWidth;
    UIColor *bgColor = [UIColor blackColor];
    if (isPad) {
        bgView.hidden = YES;
        bgColor = [OWColor colorWithHex:0x595959];
        headerHeight = 40;
        viewWidth = 64;
        accountButton.hidden = NO;
    }
    else {
        headerHeight = 66;
    }
    
    [self.view setFrame:CGRectMake(0, 0, viewWidth, appHeight)];
    self.view.backgroundColor = bgColor;

    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appWidth, headerHeight)];
}

- (Class)cellClass
{
    return [MainMenuCell class];
}

- (void)configCell:(MainMenuCell *)cell data:(LYMenuData *)item indexPath:(NSIndexPath *)indexPath
{
    [cell setContent:item];
}

- (void)excuteRequest
{
    NSArray *modules = [LYAccountManager GetMenuList];
    if (modules && modules.count > 0) {
        NSMutableArray *list = [NSMutableArray arrayWithArray:modules];
        LYMenuData *searchMenu = [MTLJSONAdapter modelOfClass:[LYMenuData class] fromJSONDictionary:@{@"MenuName":@"文库", @"MenuValue":@"search:0"} error:nil];
        [list addObject:searchMenu];
        
//        LYMenuData *audioMenu = [MTLJSONAdapter modelOfClass:[LYMenuData class] fromJSONDictionary:@{@"MenuName":@"听书", @"MenuValue":@"audio:0"} error:nil];
//        [list addObject:audioMenu];
//        LYMenuData *videoMenu = [MTLJSONAdapter modelOfClass:[LYMenuData class] fromJSONDictionary:@{@"MenuName":@"视频", @"MenuValue":@"video:0"} error:nil];
//        [list addObject:videoMenu];

        needShowHomePage = NO;
        dataSource = [[OWTableViewDataSource alloc] initWithItems:list configureCellBlock:self->cellConfigBlock];
        _tableView.dataSource = dataSource;
        _tableView.delegate = self;
        [_tableView reloadData];

        [statusManageView stopRequest];
        [self performSelector:@selector(defaultSelection) withObject:Nil afterDelay:0.1];
    }
}

- (void)defaultSelection
{
    [self selectedByIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)selectedByIndexPath:(NSIndexPath *)indexPath
{
    [selectedCell setSelected:NO];
    
    selectedCell = (id)[_tableView cellForRowAtIndexPath:indexPath];
    [selectedCell setSelected:YES];
    
    LYMenuData *menu = dataSource.items[indexPath.row];
    [self.contentCanvasController openMenu:menu];

    [self.contentCanvasController setNavTitle:menu.menuName];
}

#pragma mark table delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isPad) {
        return 80;
    }
    else {
        return 52;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectedByIndexPath:indexPath];
}


#pragma mark action

- (void)intoAccount:(id)sender
{
    WYRootController_iPad *padController = (WYRootController_iPad *)self.parentViewController;
    if (padController) {
        [padController performSelector:@selector(intoAccountView)];
    }
}

- (void)intoLeft
{
//    if (_tableView.visibleCells.count == 0) {
//        return;
//    }
//    CGRect frame = ((UITableViewCell *)_tableView.visibleCells[0]).bounds;
//    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
//    [_tableView.visibleCells enumerateObjectsUsingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
//        [OWAnimator spring:obj.contentView toPosition:center delay:0.05 + 0.07*idx];
//    }];
}

- (void)outLeft
{
//    if (_tableView.visibleCells.count == 0) {
//        return;
//    }
//    CGRect frame = ((UITableViewCell *)_tableView.visibleCells[0]).bounds;
//    CGPoint center = CGPointMake(CGRectGetMidX(frame)-80, CGRectGetMidY(frame));
//    [_tableView.visibleCells enumerateObjectsUsingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
//        [OWAnimator basicAnimate:obj.contentView toPosition:center duration:0.2 delay:0.1 + 0.05*idx];
//    }];
}

@end
