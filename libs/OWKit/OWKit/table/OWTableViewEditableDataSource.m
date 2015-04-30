//
//  OWTableViewEditableDataSource.m
//  OWKit
//
//  Created by grenlight on 15/1/30.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "OWTableViewEditableDataSource.h"

@implementation OWTableViewEditableDataSource


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.delegate) {
            [self.delegate dataSourceDelete:indexPath];
        }
    }
}

@end
