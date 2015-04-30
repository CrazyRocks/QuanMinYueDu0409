//
//  OWAnimator.h
//  YuanYang
//
//  Created by grenlight on 14/6/22.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <POP/POP.h>
#import <UIKit/UIKit.h> 

@interface OWAnimator : NSObject

+ (instancetype)animator;

+ (void)spring:(UIView *)v toScale:(float)scale;
+ (void)spring:(UIView *)v toScale:(CGPoint)scale delay:(NSTimeInterval)delay;
+ (void)basicAnimate:(UIView *)v toScale:(CGPoint)scale duration:(NSTimeInterval)duration;
+ (void)basicAnimate:(UIView *)v toScale:(CGPoint)scale  duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;
+ (void)basicAnimate:(UIView *)v toScale:(CGPoint)scale duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void(^)())completion;

+ (void)basicAnimate:(UIView *)v toAlpha:(float)alpha duration:(NSTimeInterval)duration;
+ (void)basicAnimate:(UIView *)v toAlpha:(float)alpha duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

+ (void)basicAnimate:(UIView *)v toColor:(UIColor *)color duration:(NSTimeInterval)duration;
+ (void)basicAnimate:(UIView *)v toColor:(UIColor *)color duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

+ (void)basicAnimate:(UIView *)v toRect:(CGRect)rect duration:(NSTimeInterval)duration;
+ (void)basicAnimate:(UIView *)v toRect:(CGRect)rect duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;


+ (void)spring:(UIView *)v toPosition:(CGPoint)position;
+ (void)spring:(UIView *)v toPosition:(CGPoint)position delay:(NSTimeInterval)delay;
+ (void)basicAnimate:(UIView *)v toPosition:(CGPoint)position duration:(NSTimeInterval)duration;
+ (void)basicAnimate:(UIView *)v toPosition:(CGPoint)position duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

+ (void)horizontalShake:(CALayer *)layer onPosition:(float)px;

@end
