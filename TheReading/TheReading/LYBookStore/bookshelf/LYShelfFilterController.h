//
//  LYShelfFilterController.h
//  LYBookStore
//
//  Created by grenlight on 14/6/18.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <OWKit/OWCommonTableViewController.h>

@interface LYShelfFilterController : OWCommonTableViewController
{
    NSString *lastSelectedItem;
}
- (void)refreshData;

@end
