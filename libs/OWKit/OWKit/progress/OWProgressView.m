//
//  CircleView.m
//  Popping
//
//  Created by André Schneider on 21.05.14.
//  Copyright (c) 2014 André Schneider. All rights reserved.
//

#import "OWProgressView.h"
#import <POP/POP.h>
#import "OWAnimator.h"

@interface OWProgressView()
@property(nonatomic) UIView *lineView;
- (void)addCircleLayer;
- (void)animateToStrokeEnd:(CGFloat)strokeEnd;
@end

@implementation OWProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    [self addCircleLayer];
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Instance Methods

- (void)setStrokeEnd:(CGFloat)strokeEnd animated:(BOOL)animated
{
    if (animated) {
        [self animateToStrokeEnd:strokeEnd];
        return;
    }
}

#pragma mark - Property Setters

- (void)setStrokeColor:(UIColor *)strokeColor
{
    self.lineView.backgroundColor = strokeColor;
    _strokeColor = strokeColor;
}

#pragma mark - Private Instance methods

- (void)addCircleLayer
{
    self.lineView = [[UIView alloc] initWithFrame:self.bounds];
    [OWAnimator basicAnimate:self.lineView toScale:CGPointMake(1, 0.1) duration:0.01];
    [self addSubview:self.lineView];
}

- (void)animateToStrokeEnd:(CGFloat)strokeEnd
{
    POPSpringAnimation *strokeAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleX];
    strokeAnimation.toValue = @(strokeEnd);
    strokeAnimation.springBounciness = 12.f;
    strokeAnimation.removedOnCompletion = YES;
    [self.lineView pop_addAnimation:strokeAnimation forKey:@"kPOPViewScaleX"];
}

@end
