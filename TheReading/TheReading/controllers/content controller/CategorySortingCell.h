//
//  CategorySortingCell.h
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OWSubNavigationItem;

@interface CategorySortingCell : UICollectionViewCell
{
    __weak IBOutlet UILabel *title;
}
- (void)setInfo:(OWSubNavigationItem *)category;

@end
