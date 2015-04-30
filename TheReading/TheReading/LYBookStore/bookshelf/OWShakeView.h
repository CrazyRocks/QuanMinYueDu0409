//
//  OWShakeView.h
//  ShakeUIView
//
//  Created by 龙源 on 13-10-29.
//  Copyright (c) 2013年 suraj. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@protocol OWShakeViewDelegate;

@interface OWShakeView : UIView
{
    int shakeDegress;
    float scale;
    
    BOOL    isShaking, isInPressing;
    
    UIButton    *deleteButton;
}
@property (nonatomic, weak) id<OWShakeViewDelegate> delegate;

- (void)startShake;
- (void)stopShake;

@end

@protocol OWShakeViewDelegate <NSObject>

@required
- (void)shakeView_longPressed;
- (void)shakeView:(OWShakeView *)shakeView delete:(UIButton *)bt;
@end
