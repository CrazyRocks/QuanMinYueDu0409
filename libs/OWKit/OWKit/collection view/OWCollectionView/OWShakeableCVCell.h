//
//  OWShakeableCVCell.h
//  PageableAndDraggableCollectionView
//
//  Created by grenlight on 13-11-28.
//  Copyright (c) 2013年 oowwww. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@protocol OWShakeableCVCellDelegate;

@interface OWShakeableCVCell : UICollectionViewCell
{
    NSInteger shakeDegress;
    float scale;
    
    BOOL    isShaking, isInPressing;
    
}
@property (nonatomic, assign) id<OWShakeableCVCellDelegate> owDelegate;

- (void)isNeedsShake;

- (void)startShake;
- (void)stopShake;

@end

@protocol OWShakeableCVCellDelegate <NSObject>

@required
- (void)shakeView:(OWShakeableCVCell *)shakeView delete:(UIButton *)bt;
@end

