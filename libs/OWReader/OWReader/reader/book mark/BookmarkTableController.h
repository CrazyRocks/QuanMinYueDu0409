//
//  BookmarkTableController.h
//  LogicBook
//
//  Created by iMac001 on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h>

@interface BookmarkTableController : OWCommonTableViewController

@property(copy)CatalogueSelectedBlock selectedItemChangedCallBack;
@property(copy)GLBasicBlock scrollCallBack;

-(void)setContentOffset:(CGPoint)offset;

@end
