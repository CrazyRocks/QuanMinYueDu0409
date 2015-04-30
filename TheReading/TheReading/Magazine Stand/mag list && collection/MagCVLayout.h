//
//  MagCVLayout.h
//  PublicLibrary
//
//  Created by grenlight on 13-12-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    lyCVLayoutStyleNone,
    lyCVLayoutStyleScale
}LYCVLayoutStyle;

@interface MagCVLayout : UICollectionViewFlowLayout
{
    UIEdgeInsets    sectionInset;
    
    float       itemGap,  rowGap, minContentHeight;
    
    uint    rowCount;
    //内容高度
    CGSize       contentSize;
    
    //被放大的那一行
    CGSize      maxModeItemSize;
    float       maxModeItemGap, maxModeInsetLeft, maxRowHeight;
    //当前已经被放大的行 及 可被放大的最大行号
    uint        currentMaxModeRow;
    //当前正在放大的行的放大系数
    float       maxRatio;
    //当前正在放大行的 左边距/间距 因子
    float       leftFactor, marginFactor, widthFactor, heightFactor;
    
    
    //正在执行缩放动画时，不需重新计算缩放行
    BOOL        inMaxModeAnimating;
    
    float       startOffsetY, currentOffsetY;
    
}

@property (nonatomic, assign) uint      pageCount;
@property (nonatomic, assign) CGSize    itemSize;
@property (nonatomic, assign) int       cellCount;

@property (nonatomic, assign) LYCVLayoutStyle layoutStyle;

- (void)collectionViewBeginDragging;
- (void)collectionViewDidScroll;
- (void)collectionViewWillBeginDecelerating;
- (void)collectionViewEndScroll;
@end
