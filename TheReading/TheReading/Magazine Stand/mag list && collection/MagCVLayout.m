//
//  MagCVLayout.m
//  PublicLibrary
//
//  Created by grenlight on 13-12-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "MagCVLayout.h"
#import <LYService/LYService.h>

#define ROW_ITEM_COUNT 3

@implementation MagCVLayout

- (id)init
{
    self = [super init];
    if (self) {
        inMaxModeAnimating = NO;
        currentMaxModeRow = 0;
        maxRatio = 0;
    }
    return self;
}

- (void)setCellCount:(int)cellCount
{
    _cellCount = cellCount;
    self.pageCount = ceil((float)_cellCount/3);
    sectionInset = UIEdgeInsetsMake(24, 25, 24, 25);
    itemGap = (appWidth - self.itemSize.width * ROW_ITEM_COUNT - sectionInset.left * 2)/(float)(ROW_ITEM_COUNT-1);
    rowGap = 24;
    
    maxModeItemSize = CGSizeMake(90, 120);
    maxRowHeight = maxModeItemSize.height + rowGap;

    maxModeInsetLeft = 10;
    maxModeItemGap =  (appWidth - maxModeItemSize.width * ROW_ITEM_COUNT - maxModeInsetLeft * 2)/(float)(ROW_ITEM_COUNT-1);
    
    rowCount = ceil(_cellCount/((float)ROW_ITEM_COUNT));
    minContentHeight = rowCount * (self.itemSize.height + rowGap) + 100;

    leftFactor = maxModeInsetLeft-sectionInset.left;
    marginFactor = maxModeItemGap - itemGap;
    widthFactor = maxModeItemSize.width - self.itemSize.width;
    heightFactor = maxModeItemSize.height - self.itemSize.height;
    
    contentSize = CGSizeMake(appWidth, minContentHeight);
}

-(void)prepareLayout
{
    [super prepareLayout];
}

-(CGSize)collectionViewContentSize
{
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    int row = floorf(path.row/(float)ROW_ITEM_COUNT);
    int rowIndex = path.row%ROW_ITEM_COUNT;
    
    float centerX, centerY;
    centerY = sectionInset.top + self.itemSize.height*(row+0.5) + rowGap * row;
    
    if (self.layoutStyle == lyCVLayoutStyleNone) {
        attributes.size = self.itemSize;
        centerX = sectionInset.left + self.itemSize.width*(rowIndex+ 0.5) + itemGap*rowIndex;
        contentSize = CGSizeMake(contentSize.width, minContentHeight);
    }
    else {
        if (row <= currentMaxModeRow) {
            attributes.size = maxModeItemSize;
            centerX = maxModeInsetLeft + maxModeItemSize.width*(rowIndex+ 0.5) + maxModeItemGap*rowIndex;
            centerY += 12 + 24*row;
        }
        else if (row == (currentMaxModeRow+1)) {
            attributes.size = CGSizeMake(self.itemSize.width + widthFactor*maxRatio, self.itemSize.height + heightFactor*maxRatio);
            centerX = sectionInset.left + leftFactor * maxRatio +
            attributes.size.width*(rowIndex+ 0.5) +
            itemGap*rowIndex + marginFactor*rowIndex*maxRatio;
            
            centerY += 24*row + ceil(12*maxRatio);
        }
        else {
            attributes.size = self.itemSize;
            centerX = sectionInset.left + self.itemSize.width*(rowIndex+ 0.5) + itemGap*rowIndex;
            
            centerY += 24*(currentMaxModeRow +1)+ ceil(24*maxRatio);
        }
        contentSize = CGSizeMake(contentSize.width, minContentHeight + 24 * currentMaxModeRow);
    }
    
    attributes.center = CGPointMake(centerX, centerY);
    return attributes;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    for (NSInteger i=0 ; i < _cellCount; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    
    return attributes;
}


- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForInsertedItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    attributes.alpha = 0.0;
    attributes.center = CGPointMake(0,0);
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDeletedItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    attributes.alpha = 0.0;
    attributes.center = CGPointMake(0, 0);
    attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    return attributes;
}

#pragma mark scroll method
- (void)collectionViewBeginDragging
{
    if (self.layoutStyle == lyCVLayoutStyleNone)
        return;
    
    startOffsetY = self.collectionView.contentOffset.y;
}

- (void)collectionViewDidScroll
{
    if (self.layoutStyle == lyCVLayoutStyleNone)
        return;
    
    currentOffsetY = self.collectionView.contentOffset.y;
    
    if (currentOffsetY < 0 || inMaxModeAnimating)
//    if (currentOffsetY < 0 )
        return;
    
    inMaxModeAnimating = YES;
    [self.collectionView performBatchUpdates:^{
        currentMaxModeRow = floorf(currentOffsetY/maxRowHeight);
        maxRatio = (currentOffsetY-(maxRowHeight*currentMaxModeRow)) / maxRowHeight;
        if (maxRatio < 0)
            maxRatio = 0;
    } completion:^(BOOL finished) {
        inMaxModeAnimating = NO;
    }];
}

- (void)collectionViewWillBeginDecelerating
{
    if (self.layoutStyle == lyCVLayoutStyleNone)
        return;
    
}

- (void)collectionViewEndScroll
{
    if (self.layoutStyle == lyCVLayoutStyleNone)
        return;
    
//    CGRect rect = CGRectMake(0, currentMaxModeRow * maxRowHeight, appWidth, CGRectGetHeight(self.collectionView.bounds));
//    [self.collectionView scrollRectToVisible:rect animated:YES];
}

@end
