//
//  LYMagCategorySottingController.m
//  LYMagazinesStand
//
//  Created by grenlight on 14-5-15.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYMagCategorySottingController.h"
#import "LYMagazineCSCell.h"
#import "LYMagazineCSSectionHeader.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "LYMagazineGlobal.h"

@interface LYMagCategorySottingController ()
{
}
@end

@implementation LYMagCategorySottingController

- (id)init
{
    self = [super initWithNibName:@"LYMagCategorySottingController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [OWColor colorWithHexString:@"f5f5f5"];
    //    OWPagingLayout *flowLayout = [[OWPagingLayout alloc] init];
    //    flowLayout.itemSize = CGSizeMake(69, 30);
    //    flowLayout.cellCount = cats.count;
    //
    //    [_collectionView setCollectionViewLayout:flowLayout];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"LYMagazineCSCell" bundle:[NSBundle bundleForClass:[self class]]] forCellWithReuseIdentifier:@"Cell"];
    UINib *sectionHeaderNib = [UINib nibWithNibName:[NSString stringWithFormat:@"%@",[LYMagazineCSSectionHeader class]] bundle:[NSBundle bundleForClass:[self class]]];
    [_collectionView registerNib:sectionHeaderNib  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionHeader"];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [_collectionView reloadData];
}

#pragma mark collection delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    [collectionView.collectionViewLayout invalidateLayout];
    
    return [LYMagazineGlobal sharedInstance].magCategories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)theCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    LYMagazineCSCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    OWSubNavigationItem *cat = [LYMagazineGlobal sharedInstance].magCategories[indexPath.row];
    
    [cell setInfo:cat];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)acollectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        LYMagazineCSSectionHeader *header = [acollectionView dequeueReusableSupplementaryViewOfKind :kind
                                                                                 withReuseIdentifier:@"SectionHeader"
                                                                                        forIndexPath:indexPath];
        [header setIndexPath:indexPath];
        return header;
    }
    
    return Nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = @{@"selectedIndex":[NSNumber numberWithInteger:indexPath.item]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BCSItemSelected" object:nil userInfo:info];
}


@end
