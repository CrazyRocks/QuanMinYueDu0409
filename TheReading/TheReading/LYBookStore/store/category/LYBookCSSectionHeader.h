//
//  CategorySortingSectionHeader.h
//  PublicLibrary
//
//  Created by grenlight on 14-3-6.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYBookCSSectionHeader : UICollectionReusableView
{
    IBOutlet UILabel    *titleLB;
}

- (void)setIndexPath:(NSIndexPath *)indexPath;

@end
