//
//  OWCSSButton.m
//  YuanYang
//
//  Created by grenlight on 14/6/22.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "OWCSSButton.h"
#import <POP/POP.h>
#import "UIStyleManager.h"

@implementation OWCSSButton

- (instancetype)initWithFrame:(CGRect)frame
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
    [self addTarget:self action:@selector(scaleToSmall)
   forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(scaleAnimation)
   forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(scaleToDefault)
   forControlEvents:UIControlEventTouchDragExit];
}

- (void)setStyleName:(NSString *)styleName
{
    self.backgroundColor = [UIColor clearColor];
    
    css = [[UIStyleManager sharedInstance] getStyle:styleName];
    [self setTitleColor:css.fontColor forState:UIControlStateNormal];
    [self setTitleColor:css.fontColor_selected forState:UIControlStateHighlighted];    
}

- (void)scaleToSmall
{
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.95f, 0.95f)];
    [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSmallAnimation"];
}

- (void)scaleAnimation
{
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(3.f, 3.f)];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    scaleAnimation.springBounciness = 18.0f;
    [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSpringAnimation"];
}

- (void)scaleToDefault
{
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleDefaultAnimation"];
}


- (void)drawRect:(CGRect)rect
{
    __block CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    
    CGRect borderRect = CGRectMake(0.25, 0.25, CGRectGetWidth(rect)-0.5f, CGRectGetHeight(rect)-1.0f);
    __block CGFloat minx, midx, maxx, miny, midy, maxy;
    
    void(^DrawRect)(CGRect) = ^(CGRect rrect) {
        minx = CGRectGetMinX(rrect);
        midx = CGRectGetMidX(rrect);
        maxx = CGRectGetMaxX(rrect);
        miny = CGRectGetMinY(rrect) ;
        midy = CGRectGetMidY(rrect) ;
        maxy = CGRectGetMaxY(rrect);
        CGContextMoveToPoint(context, minx , midy );
        CGContextAddArcToPoint(context, minx , miny , midx , miny, css.cornerRadius);
        CGContextAddArcToPoint(context, maxx , miny , maxx , midy , css.cornerRadius);
        CGContextAddArcToPoint(context, maxx , maxy , midx , maxy , css.cornerRadius);
        CGContextAddArcToPoint(context, minx , maxy, minx , midy , css.cornerRadius);
        CGContextClosePath(context);
    };
    
    float(^getComponent)(NSInteger) = ^(NSInteger index){
        if (self.highlighted) {
            return  [css.gradientBackground_selected[index] floatValue];
        }
        return  [css.gradientBackground[index] floatValue];
    };
    
    //draw fill
    CGContextSaveGState(context);
    
    DrawRect(borderRect);
    CGContextClip(context);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient;
    if (css.gradientBackground.count == 8) {
        CGFloat components[8] = {
            getComponent(0), getComponent(1), getComponent(2), getComponent(3),
            getComponent(4), getComponent(5), getComponent(6), getComponent(7)
        };
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
    }
    else {
        // if (css.gradientBackground.count >= 12)
        CGFloat components[12] = {
            getComponent(0), getComponent(1), getComponent(2), getComponent(3),
            getComponent(4), getComponent(5), getComponent(6), getComponent(7),
            getComponent(8), getComponent(9), getComponent(10), getComponent(11)
        };
        gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 3);
    }
    
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, rect.size.height), kCGGradientDrawsBeforeStartLocation);
    CFRelease(gradient);
    CFRelease(colorSpace);
    
    CGContextRestoreGState(context);
    
    //draw border
    CGContextSetStrokeColorWithColor(context, css.borderColor.CGColor);
    DrawRect(borderRect);
    CGContextDrawPath(context, kCGPathStroke);
    
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

@end
