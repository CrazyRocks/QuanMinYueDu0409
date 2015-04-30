//
//  MagazineCatelogueTableViewController.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-18.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h> 

@interface MagCatelogueListController : OWCommonTableViewController
{
    __weak IBOutlet UIButton      *continueButton;
    
    NSMutableArray         *magazineFirstSectionIndexes, *magInfos, *articles;
            
}

- (IBAction)addFocus:(id)sender;

@end
