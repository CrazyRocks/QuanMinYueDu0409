//
//  OWAnimator.m
//  YuanYang
//
//  Created by grenlight on 14/6/22.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWAnimator.h"

@implementation OWAnimator

+ (instancetype)animator
{
    static OWAnimator *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OWAnimator alloc] init];
    });
    return instance;
}

#pragma mark  scale animation
+ (void)spring:(UIView *)v toScale:(float)scale
{
    [[OWAnimator animator] springView:v toScaleValue:[NSValue valueWithCGPoint:CGPointMake(scale, scale)]];
}

+ (void)spring:(UIView *)v toScale:(CGPoint)scale delay:(NSTimeInterval)delay
{
    [[OWAnimator animator] performSelector:@selector(springViewToScale:)
                                withObject:@[v,[NSValue valueWithCGPoint:scale]]
                                afterDelay:delay];
}

- (void)springViewToScale:(NSArray *)params
{
    [self springView:params[0] toScaleValue:params[1]];
}

- (void)springView:(UIView *)v toScaleValue:(NSValue *)scale
{
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation.toValue = scale;
    scaleAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    scaleAnimation.springBounciness = 15.f;
    [v pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

+ (void)basicAnimate:(UIView *)v toScale:(CGPoint)scale duration:(NSTimeInterval)duration
{
    [[OWAnimator animator] basicAnimateView:v toScaleValue:[NSValue valueWithCGPoint:scale] duration:duration completion:nil] ;
}

+ (void)basicAnimate:(UIView *)v toScale:(CGPoint)scale duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void(^)())completion
{
    [[OWAnimator animator] performSelector:@selector(basicAnimateViewToScale:)
                                withObject:@[v,[NSValue valueWithCGPoint:scale],@(duration),[completion copy]]
                                afterDelay:delay];
}

- (void)basicAnimateViewToScale:(NSArray *)params
{
    [self basicAnimateView:params[0] toScaleValue:params[1] duration:[params[2] floatValue] completion:params[3]];
}

- (void)basicAnimateView:(UIView *)v toScaleValue:(NSValue *)scaleValue duration:(float)duration completion:(void(^)())completion
{
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    animation.toValue = scaleValue;
    animation.duration = duration;
    [animation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        if (completion) {
           completion();
        }
    }];
    [v pop_addAnimation:animation forKey:@"scaleAnimation"];
}

#pragma mark color
+ (void)basicAnimate:(UIView *)v toColor:(UIColor *)color duration:(NSTimeInterval)duration
{
    [OWAnimator basicAnimate:v toColor:color duration:duration delay:0];
}

+ (void)basicAnimate:(UIView *)v toColor:(UIColor *)color duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
    animation.toValue = color;
    animation.duration = duration;
    [v.layer pop_addAnimation:animation forKey:@"backgroundColorAnimation"];
}

#pragma mark UIView's Frame, Bounds
+ (void)basicAnimate:(UIView *)v toRect:(CGRect)rect duration:(NSTimeInterval)duration
{
    [OWAnimator basicAnimate:v toRect:rect duration:duration delay:0];
}

+ (void)basicAnimate:(UIView *)v toRect:(CGRect)rect duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    animation.toValue = [NSValue valueWithCGRect:rect];
    animation.duration = duration;
    [v.layer pop_addAnimation:animation forKey:@"UIViewBoundsAnimation"];
}

#pragma mark alpha animation
+ (void)basicAnimate:(UIView *)v toAlpha:(float)alpha duration:(NSTimeInterval)duration
{
    [[OWAnimator animator] basicAnimateView:v toAlphaValue:@(alpha) duration:duration];

}

+ (void)basicAnimate:(UIView *)v toAlpha:(float)alpha duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    [[OWAnimator animator] performSelector:@selector(basicAnimateViewToAlpha:)
                                withObject:@[v, @(alpha), @(duration)]
                                afterDelay:delay];
}

- (void)basicAnimateViewToAlpha:(NSArray *)params
{
    [self basicAnimateView:params[0] toAlphaValue:params[1] duration:[params[2] floatValue]];
}

- (void)basicAnimateView:(UIView *)v toAlphaValue:(NSNumber *)AlphaValue duration:(NSTimeInterval)duration
{
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    animation.toValue = AlphaValue;
    animation.duration = duration;
    [v.layer pop_addAnimation:animation forKey:@"fadeAnimation"];
}

#pragma mark position animation

+ (void)spring:(UIView *)v toPosition:(CGPoint)position
{
    [[OWAnimator animator] springView:v toPositionValue:[NSValue valueWithCGPoint:position]];
   
}

+ (void)spring:(UIView *)v toPosition:(CGPoint)position delay:(NSTimeInterval)delay
{
    [[OWAnimator animator] performSelector:@selector(springViewToPosition:)
                                withObject:@[v,[NSValue valueWithCGPoint:position]]
                                afterDelay:delay];
}

- (void)springViewToPosition:(NSArray *)params
{
    [self springView:params[0] toPositionValue:params[1]];
}

- (void)springView:(UIView *)v toPositionValue:(NSValue *)position
{
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionAnimation.toValue = position;
    positionAnimation.springBounciness = 10;
    [v pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
}

+ (void)basicAnimate:(UIView *)v toPosition:(CGPoint)position duration:(NSTimeInterval)duration
{
    [[OWAnimator animator] basicAnimateView:v toPositionValue:[NSValue valueWithCGPoint:position] duration:duration];
    
}

+ (void)basicAnimate:(UIView *)v toPosition:(CGPoint)position duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay
{
    [[OWAnimator animator] performSelector:@selector(basicAnimateViewToPosition:)
                                withObject:@[v,[NSValue valueWithCGPoint:position], @(duration)]
                                afterDelay:delay];
}

- (void)basicAnimateViewToPosition:(NSArray *)params
{
    [self basicAnimateView:params[0] toPositionValue:params[1] duration:[params[2] floatValue]];
}

- (void)basicAnimateView:(UIView *)v toPositionValue:(NSValue *)position duration:(NSTimeInterval)duration
{
    POPBasicAnimation *positionAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionAnimation.toValue = position;
    positionAnimation.duration = duration;
    [v pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
}

+ (void)horizontalShake:(CALayer *)layer onPosition:(float)px
{
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    positionAnimation.toValue = @(px);
    positionAnimation.fromValue = @(px-20);
    positionAnimation.springBounciness = 25;
    positionAnimation.springSpeed = 20;
    [layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
}

@end
