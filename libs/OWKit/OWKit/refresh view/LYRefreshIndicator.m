//
//  LYRefreshIndicator.m
//  OWKit
//
//  Created by grenlight on 14/7/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYRefreshIndicator.h"
#import <POP/POP.h>

@implementation LYRefreshIndicator

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc
{
    self.style = nil;
    [self stopAnimating];
}

- (void)startAnimating
{
    if (!isAnimating) {
//        displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(enterFrame)];
//        [displayLink setFrameInterval:self.frameInterval];
//        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        isAnimating = TRUE;
        
//        CATransform3D rotationTransform = CATransform3DIdentity;
//        [self.layer removeAllAnimations];
//        rotationTransform = CATransform3DRotate(rotationTransform, M_PI * 2, 0.0, 0.0, 1);
//        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionRepeat animations:^{
//            self.layer.transform = rotationTransform;
//        } completion:^(BOOL finished) {
//            
//        }];
        
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = @(M_PI * 2.0);
        rotationAnimation.duration = 0.6;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = INT32_MAX;
        
        [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
}


- (void)stopAnimating
{
    if (isAnimating) {
//        [displayLink invalidate];
//        displayLink = nil;
        isAnimating = FALSE;
        [self.layer removeAllAnimations];
//        [self.layer pop_removeAllAnimations];
    }

}

- (void)enterFrame
{
    currentStep++;
    
    [self setNeedsDisplay];
}

- (void)dropDistance:(float)distance
{
    if (isAnimating) {
        return;
    }
    self.transform = CGAffineTransformIdentity;

    progress = (distance - self.offsetY) / self.maxDropDownDistance;
    if (progress > 0.95)
        progress = 0.95;
    
    else if (progress < 0)
        progress = 0;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.style.borderColor.CGColor);
    CGContextSetLineWidth(context, self.style.borderWidth);
    
    CGContextAddArc(context, CGRectGetMidX(rect), CGRectGetMidY(rect), CGRectGetWidth(rect)/2.0-1.0, 0, M_PI*2, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    if (progress > 0) {
        CGContextSaveGState(context);
        
        CGContextSetStrokeColorWithColor(context, self.style.borderColor_selected.CGColor);
        CGContextAddArc(context, CGRectGetMidX(rect), CGRectGetMidY(rect), CGRectGetWidth(rect)/2.0-1,
                        -M_PI/2, -M_PI/2 + (M_PI*2*progress), 0);
        CGContextDrawPath(context, kCGPathStroke);
    }
   
    
}
@end
