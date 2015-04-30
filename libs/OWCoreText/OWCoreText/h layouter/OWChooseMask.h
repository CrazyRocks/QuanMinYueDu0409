//
//  OWChooseMask.h
//  OWCoreText
//
//  Created by grenlight on 14-10-10.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MaskDelegate <NSObject>

-(void)clearMaskAndChooseArray;

@end


@interface OWChooseMask : UIView<UIGestureRecognizerDelegate>

@property (assign) id<MaskDelegate>maskDelegate;

-(void)showMask;

-(void)hiddenMeQ;

@end
