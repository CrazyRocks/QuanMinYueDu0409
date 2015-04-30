//
//  MagIssuesColllectionController.h
//  TheReading
//
//  Created by grenlight on 15/1/8.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "MagazineCollectionController.h"
#import "IssueCollectionViewHeader.h"

@interface MagIssuesColllectionController : MagazineCollectionController
{
    LYMagazineInfoManager *magInfoManager;
    __weak IssueCollectionViewHeader *collectionHeaderView;
}
- (id)initWithMagCell:(LYMagazineTableCellData *)info;

@end
