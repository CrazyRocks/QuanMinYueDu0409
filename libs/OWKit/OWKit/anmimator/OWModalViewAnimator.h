//
//  OWModelViewAnimator.h
//  OWKit
//
//  Created by grenlight on 14/7/4.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWModalViewAnimator : NSObject
{
    UIView *dimmingView;
    UIViewController *fromCtroller, *toController;
}
+ (OWModalViewAnimator *)animator;

- (void)presenting:(UIViewController *)tController from:(UIViewController *)fController;

- (void)dismissing;

@end
