//
//  LYSettingViewController.m
//  LYBookStore
//
//  Created by grenlight on 14/8/28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYSettingViewController.h"
#import "LYSettingDetailController.h"
#import "LYSettingViewCell.h"
#import "LYSettingDetailController.h"

@interface LYSettingViewController ()

@end

@implementation LYSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [navBar setTitle:@"设置"];
    // Do any additional setup after loading the view from its nib.
}

- (Class)cellClass
{
    return [LYSettingViewCell class];
}

- (void)configCell:(LYSettingViewCell *)cell data:(NSString *)item indexPath:(NSIndexPath *)indexPath
{
    [cell.titleLable setText:item];
    [cell renderStyleByTable:_tableView indexPath:indexPath];
}

- (void)excuteRequest
{
    [statusManageView stopRequest];
    
    dataSource = [[OWTableViewDataSource alloc] initWithItems:@[@"关于", @"检查更新", @"书架欢迎页", @"启用新手指引"] configureCellBlock:cellConfigBlock];
    
    _tableView.dataSource = dataSource;
    _tableView.delegate = self;
    
    [_tableView reloadData];

}

- (void)comeback:(id)sender
{
    [[OWNavigationController sharedInstance] popViewController:owNavAnimationTypeSlideToBottom];
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYSettingViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 1:
            [cell checkUpdate];
            break;
            
        default: {
            LYSettingDetailController *detailController = [[LYSettingDetailController alloc] init];
            [[OWNavigationController sharedInstance]
             pushViewController:detailController
             animationType:owNavAnimationTypeDegressPathEffect];
            [detailController setTitle:dataSource.items[indexPath.row]];
        }

            break;
    }
}

@end
