//
//  SubscriptionCollectionController.h
//  PublicLibrary
//
//  Created by grenlight on 13-12-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MagCVLayout.h"
#import <OWKit/OWKit.h>
#import <OWKit/GLWaterDropletRefresh.h>
#import <LYService/LYService.h>

@class OWActivityIndicatorView;
@class MagsStandGradientBG;

@interface MagazineCollectionController : OWCollectionViewController
{
    MagsStandGradientBG       *gradientBg;
    
    //最新的更新日期
    NSDate                *latestDate;
        
    NSString    *noDataMessage;
    BOOL        isNoneData;
    
    BOOL        isEditMode;
    
    NSString    *currentCategory;
    
    LYMagazineManager   *requestManager;

}
@property (nonatomic, assign) LYCVLayoutStyle collectionViewLayoutStyle;
@property (nonatomic, assign) BOOL              isLocalMagazine;
@property (nonatomic, assign) BOOL              isMagazineIssue;

- (void)setup;

- (void)loadCollectionView;

- (void)renderByCategory:(NSString *)category;

- (void)loadLocalData:(NSString *)category;

- (void)updateRequestState;

//添加到collectionView的cell 是否要摆动
- (void)addedCellIfNeedsShake:(OWShakeableCVCell *)cell;

- (void)outEditMode;

@end
