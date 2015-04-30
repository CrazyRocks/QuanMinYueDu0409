//
//  BookmarkTableCellCell.h
//  LogicBook
//
//  Created by iMac001 on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bookmark.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>

@interface BookmarkTableCellCell : UITableViewCell
{
    
     __weak IBOutlet UILabel  *textLB;
     __weak IBOutlet UILabel *summaryLB;
     __weak IBOutlet UILabel *dateLB;
    
    __weak IBOutlet OWSplitLineView *splitLine;

    Bookmark *bmark;
    
    UIFont *font;
    CGRect tFrame;
    
    UIStyleObject *style;
    
}

-(void)renderContent:(Bookmark *)bm;


@end
