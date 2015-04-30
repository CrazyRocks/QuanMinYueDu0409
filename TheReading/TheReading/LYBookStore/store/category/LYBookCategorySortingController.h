//
//  WYArticleCategorySortingController.h
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>

@interface LYBookCategorySortingController : OWViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UICollectionView   *_collectionView;
}
@end
