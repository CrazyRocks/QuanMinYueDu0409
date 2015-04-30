//
//  IssueCollectionViewHeader.h
//  TheReading
//
//  Created by grenlight on 15/1/8.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssueCollectionViewHeader : UICollectionReusableView
{
    __weak IBOutlet UILabel    *magNameLB, *cycleLB, *categoryLB, *noteLB;
    __weak IBOutlet OWSplitLineView      *splitLine;
    __weak IBOutlet OWButton             *addFocusBT;

    LYMagazineTableCellData  *magInfo;
    NSString    *requestedMagGUID;
}

- (void)setMagInfo:(LYMagazineTableCellData *)info;

- (IBAction)addFocusButtonTapped:(id)sender;

@end
