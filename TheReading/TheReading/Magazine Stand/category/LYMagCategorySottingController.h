//
//  LYMagCategorySottingController.h
//  LYMagazinesStand
//
//  Created by grenlight on 14-5-15.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@class LYMagazineManager;

@interface LYMagCategorySottingController : OWViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    __weak IBOutlet UICollectionView   *_collectionView;
}
@end
