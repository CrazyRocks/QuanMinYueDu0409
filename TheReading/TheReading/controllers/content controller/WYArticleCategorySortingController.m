//
//  WYArticleCategorySortingController.m
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "WYArticleCategorySortingController.h"
#import "WYMenuManager.h"
#import "CategorySortingCell.h"
#import "WYMenuManager.h"
#import "WYArticleCategory.h"
#import "CategorySortingSectionHeader.h"
#import <OWKit/OWKit.h>
#import "WYArticleListSubNavController.h"

@interface WYArticleCategorySortingController ()
{
    WYArticleListSubNavController *parentController;
}
@end

@implementation WYArticleCategorySortingController

- (id)init
{
    self = [super initWithNibName:@"WYArticleCategorySortingController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    parentController = (WYArticleListSubNavController *)self.parentViewController;
    self.view.backgroundColor = [OWColor colorWithHexString:@"f5f5f5"];
//    OWPagingLayout *flowLayout = [[OWPagingLayout alloc] init];
//    flowLayout.itemSize = CGSizeMake(69, 30);
//    flowLayout.cellCount = cats.count;
//    
//    [_collectionView setCollectionViewLayout:flowLayout];

    [_collectionView registerNib:[UINib nibWithNibName:@"CategorySortingCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    UINib *sectionHeaderNib = [UINib nibWithNibName:[NSString stringWithFormat:@"%@",[CategorySortingSectionHeader class]] bundle:Nil];
    [_collectionView registerNib:sectionHeaderNib  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionHeader"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
}

#pragma mark collection delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //马云峰修改，消除资讯频道展开时崩溃的bug
    //[collectionView.collectionViewLayout invalidateLayout];
    //马云峰修改结束
    if (section == 0)
        return parentController.menuManager.favoriteCats.count;
    else
        return parentController.menuManager.dislikeCats.count;
}

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return NO;
    
    if (toIndexPath.section == 0 && toIndexPath.row == 0)
        return NO;

    if (indexPath.section == 0 ) {
        return YES;
    }
    else {
        if (toIndexPath.section == 0)
            return YES;
        
        return NO;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)theCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    CategorySortingCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    LYCategoryCellData *cat;
    if (indexPath.section == 0)
        cat = parentController.menuManager.favoriteCats[indexPath.row];
    else
        cat = parentController.menuManager.dislikeCats[indexPath.row];
    
    [cell setInfo:cat];
    
    return cell;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *fromArr ;
    if (fromIndexPath.section == 0)
        fromArr = parentController.menuManager.favoriteCats;
    else
        fromArr = parentController.menuManager.dislikeCats;

    NSMutableArray *toArr ;
    if (toIndexPath.section == 0)
        toArr = parentController.menuManager.favoriteCats;
    else
        toArr = parentController.menuManager.dislikeCats;
    
    id item = fromArr[fromIndexPath.item];

    [fromArr removeObjectAtIndex:fromIndexPath.item];
    [toArr insertObject:item atIndex:toIndexPath.item];
    
    [parentController.menuManager updateSorting];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)acollectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
      CategorySortingSectionHeader *header = [acollectionView dequeueReusableSupplementaryViewOfKind :kind
                                             withReuseIdentifier:@"SectionHeader"
                                                    forIndexPath:indexPath];
        [header setIndexPath:indexPath];
        return header;
    }
    
    return Nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    CategorySortingCell *cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    //第一项【全部】不能被删除
    if (indexPath.section == 0 && indexPath.row == 0) {
        return ;
    }
    
    NSInteger section0Count = parentController.menuManager.favoriteCats.count;
    NSInteger section1Count = parentController.menuManager.dislikeCats.count;
    NSIndexPath *toIndexPath;
    if (indexPath.section == 0) {
        toIndexPath = [NSIndexPath indexPathForRow:section1Count inSection:1];
    }
    else {
        toIndexPath = [NSIndexPath indexPathForRow:section0Count inSection:0];
    }
    [[collectionView getHelper] moveItemAtIndexPath:indexPath toIndexPath:toIndexPath];
}
@end
