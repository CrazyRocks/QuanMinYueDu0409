//
//  LYShelfFilterController.m
//  LYBookStore
//
//  Created by grenlight on 14/6/18.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYShelfFilterController.h"
#import "LYSFCell.h"
#import "MyBooksManager.h"

@interface LYShelfFilterController ()

@end

@implementation LYShelfFilterController

- (id)init
{
    self = [super initWithNibName:@"LYShelfFilterController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.frame = CGRectMake(0, 0, appWidth, 200);
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundColor = self.view.backgroundColor;

}

- (Class)cellClass
{
    return [LYSFCell class];
}

- (void)configCell:(LYSFCell *)cell data:(NSString *)data indexPath:(NSIndexPath *)indexPath
{
    [cell setInfo:data];
}

- (void)refreshData
{
    [self excuteRequest];
}

- (void)excuteRequest
{
    [statusManageView stopRequest];
    NSArray *allBooks = [[MyBooksManager sharedInstance] allMyBooks];
    NSMutableArray *filters = [[NSMutableArray alloc] init];
    [filters addObject:@"全部"];
    NSInteger index = 0;
    for (MyBook *book in allBooks) {
        if (book.unitName && (![book.unitName isEqualToString:@"0"])
            && (![filters containsObject:book.unitName])) {
            [filters addObject:book.unitName];
            index ++;
        }
    }
    dataSource = [[OWTableViewDataSource alloc] initWithItems:filters configureCellBlock:cellConfigBlock];
    
    _tableView.dataSource = dataSource;
   
    _tableView.delegate = self;
    [_tableView reloadData];
    
    [self performSelector:@selector(restoreLastSelection) withObject:nil afterDelay:0.5];

}

- (void)restoreLastSelection
{
    NSInteger row = 0;
    for (NSInteger i=0; i<dataSource.items.count; i++) {
        if ([dataSource.items[i] isEqualToString:lastSelectedItem]) {
            row = i;
        }
    }
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lastSelectedItem = dataSource.items[indexPath.row];
    NSDictionary *info = @{@"filter":lastSelectedItem};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LYShelfFilter" object:nil userInfo:info];
}


@end
