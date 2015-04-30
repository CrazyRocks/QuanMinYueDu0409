//
//  LYShelfSlideMenuController.m
//  LYBookStore
//
//  Created by grenlight on 14/8/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYShelfSlideMenuController.h"
#import "LYSSlideMenuCell.h"
#import "ShelfViewController+SlideMenu.h"
#import "LYHelpViewController.h"

@interface LYShelfSlideMenuController ()

@end

@implementation LYShelfSlideMenuController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    _tableView.backgroundColor = [UIColor clearColor];
    
}

- (void)updateFrostedView
{
    FrostedGlassBackgroundView *frostedView = (id)self.view;
    frostedView.frostesView = self.parentViewController.view ;
    [frostedView generateFrostedGlassImage];
}

- (void)excuteRequest
{
    [statusManageView stopRequest];

    dataSource = [[OWTableViewDataSource alloc] initWithItems:@[@"帮助", @"搜索", @"书架整理", @"清理过期文件", @"我要4"] configureCellBlock:cellConfigBlock];
    
    _tableView.dataSource = dataSource;
    _tableView.delegate = self;
    
    [_tableView reloadData];
}

- (Class)cellClass
{
    return [LYSSlideMenuCell class];
}

- (void)configCell:(LYSSlideMenuCell *)cell data:(NSString *)title indexPath:(NSIndexPath *)indexPath
{
    [cell setInfo:title];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [UIView new];
    header.backgroundColor = [UIColor clearColor];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShelfViewController *controller = (ShelfViewController *)self.parentViewController;

    switch (indexPath.row) {
        case 0:
            [[OWNavigationController sharedInstance] pushViewController:[LYHelpViewController new] animationType:owNavAnimationTypeSlideFromBottom];
            break;
        
        case 1:
            [[NSNotificationCenter defaultCenter] postNotificationName:BOOKSHELF_SHOW_SEARCHBAR object:nil];
            break;
            
        case 2:
            [controller editShelf];
            break;
            
        case 3:
            
            break;
            
        case 4:
            [self vote];
            break;
            
        default:
            break;
    }
    
    [controller closeSlideMenu:nil];
}

#pragma mark 投票
- (void)vote
{
    NSString *url = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=";
    NSString *reviewURL = [NSString stringWithFormat:@"%@%i",url,660002357];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
}

@end
