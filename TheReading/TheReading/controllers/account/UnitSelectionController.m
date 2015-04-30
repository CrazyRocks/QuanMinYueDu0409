//
//  UnitSelectionController.m
//  TheReading
//
//  Created by grenlight on 15/1/6.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "UnitSelectionController.h"
#import <LYService/LYService.h>
#import "WYMenuManager.h"
#import "SelectionCell.h"

@interface UnitSelectionController ()
{
    SelectionCell *currentSelectedCell;
}
@end

@implementation UnitSelectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.tableFooterView = [UIView new];
    // Do any additional setup after loading the view from its nib.
}

- (void)excuteRequest
{
    [statusManageView stopRequest];
    dataSource = [[OWTableViewDataSource alloc] initWithItems:@[self.units]
                                         configureCellBlock:self->cellConfigBlock];
    _tableView.dataSource = dataSource;
    _tableView.delegate = self;
    [_tableView reloadData];
}

- (Class)cellClass
{
    return [SelectionCell class];
}

- (void)configCell:(SelectionCell *)cell data:(NSDictionary *)data indexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = data[@"UnitName"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.view.userInteractionEnabled = NO;

    NSDictionary *item = dataSource.items[0][indexPath.row];
    currentSelectedCell = (SelectionCell *)[_tableView cellForRowAtIndexPath:indexPath];
    [currentSelectedCell showIndicator];
    
    [LYAccountManager generateDomain:item];
    __unsafe_unretained typeof (self) weakSelf = self;
    [LYAccountManager getServiceList:^(NSDictionary *result){
        weakSelf.loginCompleteBlock();
    } fault:^(NSString *msg){
        [[OWMessageView sharedInstance] showMessage:msg autoClose:YES];
        [weakSelf requestError];
    }];
}

- (void)requestError
{
    [currentSelectedCell hideIndicator];
    self.view.userInteractionEnabled = YES;
}

@end
