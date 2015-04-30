//
//  WYArticleCategorySortingController.m
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYBookCategorySortingController.h"
#import "LYBookCSCell.h"
#import "LYBookCSSectionHeader.h"
#import "LYBookConfig.h"

@interface LYBookCategorySortingController ()

@end

@implementation LYBookCategorySortingController

- (id)init
{
    self = [super initWithNibName:@"LYBookCategorySortingController" bundle:[NSBundle bundleForClass:[self class]]];
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

    [_collectionView registerNib:[UINib nibWithNibName:@"LYBookCSCell" bundle:[NSBundle bundleForClass:[self class]]] forCellWithReuseIdentifier:@"Cell"];
    UINib *sectionHeaderNib = [UINib nibWithNibName:[NSString stringWithFormat:@"%@",[LYBookCSSectionHeader class]] bundle:[NSBundle bundleForClass:[self class]]];
    [_collectionView registerNib:sectionHeaderNib  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionHeader"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
}

#pragma mark collection delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    [collectionView.collectionViewLayout invalidateLayout];
    
    return [LYBookConfig sharedInstance].bookCategories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)theCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    LYBookCSCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    OWSubNavigationItem *cat = [LYBookConfig sharedInstance].bookCategories[indexPath.row];
    
    [cell setInfo:cat];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)acollectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
      LYBookCSSectionHeader *header = [acollectionView dequeueReusableSupplementaryViewOfKind :kind
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
