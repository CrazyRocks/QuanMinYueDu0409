//
//  OWModelViewAnimator.m
//  OWKit
//
//  Created by grenlight on 14/7/4.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWModalViewAnimator.h"
#import "OWColor.h"
#import <POP/POP.h>

@implementation OWModalViewAnimator

+ (OWModalViewAnimator *)animator
{
    static OWModalViewAnimator *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OWModalViewAnimator alloc] init];
    });
    return instance;
}

- (void)presenting:(UIViewController *)tController from:(UIViewController *)fController
{
    fromCtroller = fController;
    toController = tController;
    
    dimmingView = [[UIView alloc] initWithFrame:fromCtroller.view.bounds];
    dimmingView.backgroundColor = [OWColor colorWithHexString:@"#aa000000"];
    dimmingView.layer.opacity = 0.0;
    
    UIView *fromView = fromCtroller.view;
    fromView.userInteractionEnabled = NO;
    
    UIView *toView = toController.view;
    toView.center = CGPointMake(fromView.center.x, -fromView.center.y);
    
    [fromView addSubview:dimmingView];
    [fromView addSubview:toView];

    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    positionAnimation.toValue = @(fromView.center.y);
    positionAnimation.springBounciness = 10;
    [positionAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        fromView.userInteractionEnabled = YES;
    }];
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.springBounciness = 20;
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.2, 1.4)];
    
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue = @(0.5);
    
    [toView.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
    [toView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    [dimmingView.layer pop_addAnimation:opacityAnimation forKey:@"opacityAnimation"];
}

- (void)dismissing
{
    toController.view.userInteractionEnabled = NO;
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue = @(0.0);
    
    POPBasicAnimation *offscreenAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    offscreenAnimation.toValue = @(-fromCtroller.view.layer.position.y);
    [offscreenAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [toController.view removeFromSuperview];
        toController = nil;
    }];
    [toController.view.layer pop_addAnimation:offscreenAnimation forKey:@"offscreenAnimation"];
    [dimmingView.layer pop_addAnimation:opacityAnimation forKey:@"opacityAnimation"];
    
}
@end
